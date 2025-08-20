#!/bin/bash

# Check if AWS_PROFILE environment variable is set
if [[ -n "$AWS_PROFILE" ]]; then
  echo "$AWS_PROFILE"
fi