---
description: Analyze GitHub PR feedback and suggest next steps
allowed_tools:
  - Bash
---

# PR Review Analysis

I'll fetch the PR data and analyze the feedback to help you understand the key themes and action items.

```bash
pr-review $ARGUMENTS
```

Based on the PR feedback, I'll analyze:

1. **Feedback Themes**
   - Common concerns raised by reviewers
   - Patterns in the feedback
   - Technical vs. stylistic comments

2. **Priority Action Items**
   - Must-fix issues blocking approval
   - Suggested improvements
   - Optional enhancements

3. **Communication Tone**
   - Overall sentiment of reviews
   - Constructive vs. critical feedback
   - Areas of agreement/disagreement

4. **Next Steps**
   - Specific commits needed to address feedback
   - Questions to clarify with reviewers
   - Additional testing or documentation needed

5. **Review Status**
   - Current approval status
   - Outstanding review requests
   - Merge readiness

I'll provide a clear summary with actionable next steps to help move the PR forward.