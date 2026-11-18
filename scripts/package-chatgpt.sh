#!/bin/sh
# Builds the ChatGPT plugin ZIP (Agent Plugins format) into dist/.
# Layout at the ZIP root: plugin.json, mcp.json, LICENSE, skills/ (and assets/ once there are icons).
set -eu

root="$(cd "$(dirname "$0")/.." && pwd)"
name="$(sed -n 's/^  "name": "\(.*\)",$/\1/p' "$root/chatgpt/plugin.json")"
version="$(sed -n 's/^  "version": "\(.*\)",$/\1/p' "$root/chatgpt/plugin.json")"
out="$root/dist/$name-$version.zip"
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT

cp "$root/chatgpt/plugin.json" "$root/chatgpt/mcp.json" "$root/LICENSE" "$stage/"
cp -R "$root/skills" "$stage/skills"
[ -d "$root/assets" ] && cp -R "$root/assets" "$stage/assets"

mkdir -p "$root/dist"
rm -f "$out"
(cd "$stage" && zip -qrX "$out" . -x '*.DS_Store')
echo "$out"
