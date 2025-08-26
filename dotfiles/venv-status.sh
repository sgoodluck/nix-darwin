#!/bin/bash

# Check for active virtual environment
if [[ -n "$VIRTUAL_ENV" ]]; then
  echo "$(basename "$VIRTUAL_ENV")"
elif [[ -n "$CONDA_DEFAULT_ENV" ]] && [[ "$CONDA_DEFAULT_ENV" != "base" ]]; then
  echo "$CONDA_DEFAULT_ENV"
elif [[ -n "$PYENV_VERSION" ]]; then
  echo "$PYENV_VERSION"
fi