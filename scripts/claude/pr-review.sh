#!/usr/bin/env bash
#
# Fetch GitHub PR data for Claude Code analysis
# Usage: pr-review.sh [PR_NUMBER]
# If no PR number is provided, uses the current branch's PR

set -euo pipefail

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed" >&2
    echo "Install with: brew install gh" >&2
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "Error: Not in a git repository" >&2
    exit 1
fi

# Get PR number from argument or current branch
if [ $# -eq 1 ]; then
    PR_NUMBER="$1"
    echo "Fetching PR #${PR_NUMBER}..." >&2
else
    echo "No PR number provided. Checking current branch..." >&2
    
    # Try to get PR for current branch
    CURRENT_BRANCH=$(git branch --show-current)
    PR_INFO=$(gh pr list --head "$CURRENT_BRANCH" --json number --limit 1 2>/dev/null || true)
    
    if [ -z "$PR_INFO" ] || [ "$PR_INFO" = "[]" ]; then
        echo "Error: No PR found for current branch '$CURRENT_BRANCH'" >&2
        echo "Usage: pr-review.sh [PR_NUMBER]" >&2
        exit 1
    fi
    
    PR_NUMBER=$(echo "$PR_INFO" | jq -r '.[0].number')
    echo "Found PR #${PR_NUMBER} for branch '$CURRENT_BRANCH'" >&2
fi

# Fetch PR data with comments
echo "Fetching PR details and comments..." >&2

# Get PR details
PR_DATA=$(gh pr view "$PR_NUMBER" --json title,body,author,state,createdAt,updatedAt,headRefName,baseRefName,url)

# Get PR comments
PR_COMMENTS=$(gh api "repos/{owner}/{repo}/issues/${PR_NUMBER}/comments" --paginate)

# Get review comments (inline code comments)
REVIEW_COMMENTS=$(gh api "repos/{owner}/{repo}/pulls/${PR_NUMBER}/comments" --paginate)

# Get reviews
PR_REVIEWS=$(gh api "repos/{owner}/{repo}/pulls/${PR_NUMBER}/reviews" --paginate)

# Combine all data into a structured output
cat << EOF
=== PR #${PR_NUMBER} ===

$(echo "$PR_DATA" | jq -r '
"Title: \(.title)
Author: \(.author.login)
State: \(.state)
Branch: \(.headRefName) → \(.baseRefName)
URL: \(.url)
Created: \(.createdAt)
Updated: \(.updatedAt)

Description:
\(.body // "No description provided")"
')

=== Issue Comments ===
$(echo "$PR_COMMENTS" | jq -r '.[] | "
[\(.created_at)] @\(.user.login):
\(.body)
---"' || echo "No issue comments")

=== Code Review Comments ===
$(echo "$REVIEW_COMMENTS" | jq -r '.[] | "
[\(.created_at)] @\(.user.login) on \(.path):
\(.body)
---"' || echo "No review comments")

=== Reviews ===
$(echo "$PR_REVIEWS" | jq -r '.[] | "
[\(.submitted_at)] @\(.user.login) - \(.state):
\(.body // "No comment")
---"' || echo "No reviews")
EOF