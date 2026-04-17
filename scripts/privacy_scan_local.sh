#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
user_email="$(git -C "$repo_root" config user.email || true)"
home_path="$HOME"

tmp_added="$(mktemp)"
tmp_hits="$(mktemp)"
trap 'rm -f "$tmp_added" "$tmp_hits"' EXIT

# Only scan added lines from the pushed diff.
grep '^+' | grep -v '^+++' | sed 's/^+//' > "$tmp_added" || true

[ ! -s "$tmp_added" ] && exit 0

check_regex() {
  local label="$1"
  local regex="$2"
  if grep -En "$regex" "$tmp_added" > /dev/null 2>&1; then
    {
      echo "[$label]"
      grep -En "$regex" "$tmp_added"
      echo
    } >> "$tmp_hits"
    return 0
  fi
  return 1
}

check_fixed() {
  local label="$1"
  local needle="$2"
  [ -z "$needle" ] && return 1
  if grep -Fn "$needle" "$tmp_added" > /dev/null 2>&1; then
    {
      echo "[$label]"
      grep -Fn "$needle" "$tmp_added"
      echo
    } >> "$tmp_hits"
    return 0
  fi
  return 1
}

found=0

check_regex "OpenAI-style key" 'sk-[A-Za-z0-9]{20,}' && found=1 || true
check_regex "GitHub classic token" 'ghp_[A-Za-z0-9]{20,}' && found=1 || true
check_regex "GitHub fine-grained token" 'github_pat_[A-Za-z0-9_]{20,}' && found=1 || true
check_regex "AWS access key" 'AKIA[0-9A-Z]{16}' && found=1 || true
check_regex "Google API key" 'AIza[0-9A-Za-z\-_]{20,}' && found=1 || true
check_regex "Slack token" 'xox[baprs]-[A-Za-z0-9-]{10,}' && found=1 || true
check_regex "Groundcover service token" 'gcsa_[A-Z0-9_]{10,}' && found=1 || true
check_regex "Bearer token" 'Bearer[[:space:]]+[A-Za-z0-9._=-]{12,}' && found=1 || true
check_regex "Authorization header" 'Authorization[[:space:]]*[:=][[:space:]]*["'"'"']?(Bearer|Basic)[[:space:]]+[A-Za-z0-9._=-]{8,}' && found=1 || true

check_fixed "Personal home path" "$home_path" && found=1 || true
check_fixed "Git user email" "$user_email" && found=1 || true

if [ "$found" -eq 1 ]; then
  echo
  echo "Push blocked: possible secret or personal detail detected in the to-be-pushed diff."
  echo
  cat "$tmp_hits"
  echo "Review your changes, fix the issue, and push again."
  exit 1
fi

exit 0
