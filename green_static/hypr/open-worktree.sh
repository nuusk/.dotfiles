#!/bin/bash
set -euo pipefail

repo="${WORKTREE_REPO:-$HOME/code/n9}"
worktrees_root="${WORKTREE_ROOT:-$HOME/worktrees/n9}"
launcher="$HOME/.config/hypr/glitch-launch.sh"

notify() {
  notify-send "Worktree" "$1" >/dev/null 2>&1 || true
}

select_branch() {
  {
    git -C "$repo" for-each-ref --format="%(refname:short)" refs/heads
    git -C "$repo" for-each-ref --format="%(refname:short)" refs/remotes/origin |
      sed "s#^origin/##" |
      grep -v "^HEAD$"
  } |
    sort -u |
    wofi --dmenu --prompt "Worktree branch"
}

existing_worktree_for_branch() {
  git -C "$repo" worktree list --porcelain |
    awk -v branch="refs/heads/$1" '
      $1 == "worktree" { path = substr($0, 10) }
      $1 == "branch" && $2 == branch { print path; exit }
    '
}

branch="${1:-}"
if [ -z "$branch" ]; then
  branch="$(select_branch)"
fi

if [ -z "$branch" ]; then
  exit 0
fi

worktree_path="$(existing_worktree_for_branch "$branch")"
if [ -z "$worktree_path" ]; then
  safe_name="${branch//\//-}"
  worktree_path="$worktrees_root/$safe_name"

  mkdir -p "$worktrees_root"

  if git -C "$repo" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$repo" worktree add "$worktree_path" "$branch"
  elif git -C "$repo" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    git -C "$repo" worktree add --track -b "$branch" "$worktree_path" "origin/$branch"
  else
    notify "Branch not found: $branch"
    exit 1
  fi
fi

"$launcher" kitty --directory "$worktree_path"
