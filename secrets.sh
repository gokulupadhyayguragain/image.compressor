#!/bin/sh
while IFS='=' read -r key value; do
  [ -z "$key" ] && continue    # skip empty lines
  printf "%s" "$value" | gh secret set "$key" >/dev/null 2>&1
done < <(grep -v '^#' .env)
echo "Done."
