#!/bin/bash

# Get current kubernetes context and namespace
if command -v kubectl &> /dev/null; then
  # This will be empty if no context is set
  CONTEXT=$(kubectl config current-context 2>/dev/null)
  if [[ -n "$CONTEXT" ]]; then
    NAMESPACE=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
    # Default to 'default' namespace if not set
    NAMESPACE="${NAMESPACE:-default}"
    echo "${CONTEXT}:${NAMESPACE}"
  fi
  # If CONTEXT is empty, output nothing (no echo)
fi