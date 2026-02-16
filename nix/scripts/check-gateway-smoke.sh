#!/bin/sh
set -e

if [ -z "${OPENCLAW_GATEWAY:-}" ]; then
  echo "OPENCLAW_GATEWAY is not set" >&2
  exit 1
fi

tmp_home="$(mktemp -d)"
export HOME="$tmp_home"
trap 'rm -rf "$tmp_home"' EXIT

"$OPENCLAW_GATEWAY/bin/openclaw" --help >/dev/null
