#!/bin/bash

set -e

subcommand=$1
options=$2
target=$3

# $options stays unquoted everywhere below: that is what lets a single input
# string like "-v -I test/vcl/includes" split into separate flags, and what lets
# an empty one disappear instead of becoming an empty argument.

if [ -e "$target" ]; then
  # An existing path is taken verbatim, so names containing spaces survive.
  targets=("$target")
else
  # Otherwise the target is treated as a pattern. The unquoted expansion is what
  # turns "path/to/*.vcl" into the files it matches; globstar lets "**" recurse
  # into subdirectories, and nullglob collapses a pattern that matches nothing to
  # an empty list so it can be reported instead of reaching falco raw.
  shopt -s globstar nullglob
  targets=($target)
  shopt -u globstar nullglob
fi

if [ "${#targets[@]}" -eq 0 ]; then
  echo "falco-github-action: no files matched target '$target'" >&2
  exit 1
fi

status=0
failed=0

for file in "${targets[@]}"; do
  if [ "${#targets[@]}" -gt 1 ]; then
    echo "==> $subcommand $file"
  fi

  code=0
  falco $subcommand $options "$file" || code=$?

  if [ "$code" -ne 0 ]; then
    failed=$((failed + 1))
    # Keep falco's own exit code; for a single target it is passed through as-is.
    status=$code
  fi
done

if [ "${#targets[@]}" -gt 1 ]; then
  echo "==> ${#targets[@]} targets checked, $failed failed"
fi

exit $status
