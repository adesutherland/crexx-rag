#!/bin/sh

set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
phase3_setup="$script_dir/../phase-3-ingestion/setup.sh"

work_dir=$("$phase3_setup" "$@")
cp "$script_dir/mcp-requests.jsonl" "$work_dir/mcp-requests.jsonl"
cp "$script_dir/address-query.crexx" "$work_dir/address-query.crexx"
printf '%s\n' "$work_dir"
