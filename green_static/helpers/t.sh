#!/usr/bin/env bash
# Task tree for agent work: one Markdown file per task, one worktree and Claude session per task.
set -uo pipefail

tasks_dir="${TASKS_DIR:-$HOME/tasks}"
launcher="$HOME/.config/hypr/glitch-launch.sh"
[ -x "$launcher" ] || launcher=env
self="$(readlink -f "$0")"
declare -A file area title status repo branch deps session live_status live_pid
ids=()

usage() {
  cat <<USAGE
usage: t                  open the picker
       t ls [--all]       print the task tree
       t new [--area work|private] [--repo R] [--branch B] [--depends a,b] [--jira KEY] [title]
       t open [--fresh] ID
       t shell ID         open a terminal in the task's directory
       t edit ID
       t done ID          toggle done
       t deps ID          choose what ID waits for
USAGE
}

field() {
  awk -v k="$2:" 'NR==1 && $0!="---" {exit} NR>1 && $0=="---" {exit}
    NR>1 && index($0,k)==1 {sub(/^[^:]*:[ \t]*/,""); print; exit}' "$1"
}

set_field() {
  local tmp
  tmp="$(mktemp "$1.XXXXXX")" || return
  awk -v k="$2" -v v="$3" 'NR>1 && !d && $0=="---" {if (!s) print k": "v; d=1}
    NR>1 && !d && index($0,k":")==1 {print k": "v; s=1; next} {print}' "$1" >"$tmp" && mv "$tmp" "$1"
}

load() {
  local f id a
  shopt -s nullglob
  for a in work private; do
    for f in "$tasks_dir/$a"/*.md; do
      id="$(basename "$f" .md)"
      ids+=("$id")
      file[$id]="$f"
      area[$id]="$a"
      title[$id]="$(field "$f" title)"
      status[$id]="$(field "$f" status)"
      repo[$id]="$(field "$f" repo)"
      branch[$id]="$(field "$f" branch)"
      session[$id]="$(field "$f" session)"
      deps[$id]="$(field "$f" depends | tr -d '[]' | tr ',' ' ')"
    done
  done
  shopt -u nullglob
  load_live
}

load_live() {
  local sid st pid cwd id
  declare -A by_session by_cwd
  while IFS=$'\t' read -r sid st pid cwd; do
    by_session[$sid]="$st $pid"
    by_cwd[$cwd]="$st $pid"
  done < <(claude agents --json 2>/dev/null | jq -r '.[] | [.sessionId, (.status // "starting"), .pid, .cwd] | @tsv' 2>/dev/null)
  for id in "${ids[@]}"; do
    local hit="${by_session[${session[$id]:-none}]:-}"
    # A session started by hand in the task's worktree still counts as the task's session.
    [ -n "$hit" ] || [ -z "${branch[$id]}" ] || hit="${by_cwd[$HOME/worktrees/${repo[$id]}/${branch[$id]}]:-}"
    [ -n "$hit" ] || continue
    live_status[$id]="${hit% *}"
    live_pid[$id]="${hit##* }"
  done
}

unmet() {
  local d out=""
  for d in ${deps[$1]}; do
    [ "${status[$d]:-}" = done ] || out+="${out:+, }$d"
  done
  printf '%s' "$out"
}

state() {
  local blockers
  [ "${status[$1]}" = done ] && { echo done; return; }
  [ -z "${live_status[$1]:-}" ] || { echo "${live_status[$1]}"; return; }
  blockers="$(unmet "$1")"
  [ -z "$blockers" ] && echo ready || echo "blocked by $blockers"
}

row() {
  local id="$1" prefix="$2" st icon color label pad
  st="$(state "$id")"
  case "$st" in
    busy) icon="●" color=32 st=running ;;
    idle|waiting*) icon="◐" color=33 st="waiting on you" ;;
    done) icon="✓" color=90 ;;
    blocked*) icon="○" color=90 ;;
    *) icon="○" color=36 ;;
  esac
  label="$prefix$icon ${title[$id]:-$id}"
  pad=$((52 - ${#label}))
  [ "$pad" -gt 0 ] || pad=1
  printf '%s\t\033[%sm%s%*s %-16s %s\033[0m\n' "$id" "$color" "$label" "$pad" "" "${repo[$id]:--}" "$st"
}

walk() {
  local id="$1" prefix="$2" child_prefix="$3" children child i n
  seen[$id]=1
  row "$id" "$prefix"
  read -ra children <<<"${kids[$id]:-}"
  n=${#children[@]}
  for ((i = 0; i < n; i++)); do
    child="${children[$i]}"
    [ -z "${seen[$child]:-}" ] || continue
    if ((i == n - 1)); then
      walk "$child" "$child_prefix└─ " "$child_prefix   "
    else
      walk "$child" "$child_prefix├─ " "$child_prefix│  "
    fi
  done
}

rows() {
  local show_all="${1:-}" a id d parent any
  declare -A kids seen visible has_parent
  for id in "${ids[@]}"; do
    [ "$show_all" = --all ] || [ "${status[$id]}" != done ] && visible[$id]=1
  done
  # A task sits under its first visible dependency in the same area.
  for id in "${ids[@]}"; do
    [ -n "${visible[$id]:-}" ] || continue
    for d in ${deps[$id]}; do
      if [ -n "${visible[$d]:-}" ] && [ "${area[$d]}" = "${area[$id]}" ]; then
        kids[$d]+="$id "
        has_parent[$id]=1
        break
      fi
    done
  done
  for a in work private; do
    any=""
    for id in "${ids[@]}"; do
      [ -n "${visible[$id]:-}" ] && [ "${area[$id]}" = "$a" ] && any=1
    done
    [ -n "$any" ] || continue
    printf -- '-\t\033[1m%s\033[0m\n' "${a^^}"
    for id in "${ids[@]}"; do
      [ -n "${visible[$id]:-}" ] && [ "${area[$id]}" = "$a" ] && [ -z "${has_parent[$id]:-}" ] && walk "$id" "" ""
    done
    # Dependency cycles have no root, so show them instead of hiding them.
    for id in "${ids[@]}"; do
      [ -n "${visible[$id]:-}" ] && [ "${area[$id]}" = "$a" ] && [ -z "${seen[$id]:-}" ] && walk "$id" "" ""
    done
  done
  return 0
}

worktree_for() {
  local id="$1" root="$HOME/code/${repo[$id]}" b="${branch[$id]}" path
  [ -d "$root" ] || { echo "t: repo not found: $root" >&2; return 1; }
  [ -n "$b" ] || { echo "$root"; return; }
  path="$(git -C "$root" worktree list --porcelain | awk -v b="refs/heads/$b" '
    $1=="worktree" {p=substr($0,10)} $1=="branch" && $2==b {print p; exit}')"
  [ -z "$path" ] || { echo "$path"; return; }
  path="$HOME/worktrees/${repo[$id]}/$b"
  mkdir -p "$(dirname "$path")"
  if git -C "$root" show-ref --verify --quiet "refs/heads/$b"; then
    git -C "$root" worktree add "$path" "$b" >&2
  elif git -C "$root" show-ref --verify --quiet "refs/remotes/origin/$b"; then
    git -C "$root" worktree add --track -b "$b" "$path" "origin/$b" >&2
  else
    git -C "$root" worktree add -b "$b" "$path" >&2
  fi || { echo "t: could not create worktree for $b" >&2; return 1; }
  echo "$path"
}

focus_session() {
  local p="$1" clients
  clients=" $(hyprctl clients -j | jq -r '[.[].pid] | join(" ")') "
  while [ -n "$p" ] && [ "$p" -gt 1 ]; do
    if [[ "$clients" == *" $p "* ]]; then
      hyprctl dispatch "hl.dsp.focus({ window = \"pid:$p\" })" >/dev/null
      return
    fi
    p="$(ps -o ppid= -p "$p" | tr -d ' ')"
  done
  echo "t: session is running but has no window (pid $1)" >&2
  return 1
}

# Hyprland starts the window, so it outlives the picker and inherits nothing from this process.
launch() {
  local cwd="$1" script
  shift
  script="$(mktemp "${XDG_RUNTIME_DIR:-/tmp}/t-launch.XXXXXX")" || return
  {
    echo 'rm -- "$0"'
    printf 'exec %q kitty --directory %q' "$launcher" "$cwd"
    [ $# -eq 0 ] || printf ' %q' "$@"
    echo
  } >"$script"
  hyprctl dispatch "hl.dsp.exec_cmd(\"bash $script\")" >/dev/null || { rm -f "$script"; echo "t: could not start a window through Hyprland" >&2; return 1; }
}

task_dir() {
  if [ -n "${repo[$1]}" ]; then
    worktree_for "$1"
  else
    echo "$tasks_dir/${area[$1]}"
  fi
}

cmd_shell() {
  local id="${1:-}" cwd
  load
  [ -n "${file[$id]:-}" ] || { echo "t: no such task: $id" >&2; return 1; }
  cwd="$(task_dir "$id")" || return
  launch "$cwd"
}

cmd_open() {
  local fresh="" id cwd sid f blockers prompt
  local -a args
  [ "${1:-}" = --fresh ] && { fresh=1; shift; }
  id="${1:-}"
  load
  f="${file[$id]:-}"
  [ -n "$f" ] || { echo "t: no such task: $id" >&2; return 1; }
  [ "${status[$id]}" != done ] || { echo "t: $id is done" >&2; return 1; }
  if [ -n "${live_pid[$id]:-}" ]; then
    [ -z "$fresh" ] || { echo "t: $id already has a running session" >&2; return 1; }
    focus_session "${live_pid[$id]}"
    return
  fi
  blockers="$(unmet "$id")"
  [ -z "$blockers" ] || { echo "t: $id is blocked by $blockers" >&2; return 1; }

  cwd="$(task_dir "$id")" || return

  prompt="This session works on the task in $f, which is the source of truth for it. Before stopping, keep its Decisions and Next step sections current. You may create, split and update local tasks with \`t new\` and by editing files under $tasks_dir. Never create or change Jira issues without asking the user first. Its contents when this session opened:

$(cat "$f")"
  sid="${session[$id]}"
  if [ -z "$fresh" ] && [ -n "$sid" ] && [ -f "$HOME/.claude/projects/${cwd//[^a-zA-Z0-9]/-}/$sid.jsonl" ]; then
    args=(--resume "$sid")
  else
    sid="$(cat /proc/sys/kernel/random/uuid)"
    set_field "$f" session "$sid" || return
    args=(--session-id "$sid")
  fi
  args+=(--name "$id" --append-system-prompt "$prompt" --add-dir "$tasks_dir")
  launch "$cwd" bash -ic 'claude "$@"; exec bash -i' _ "${args[@]}"
}

slugify() {
  tr '[:upper:]' '[:lower:]' <<<"$1" | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//' | cut -c1-50 | sed 's/-*$//'
}

cmd_new() {
  local a="" r="" b="" d="" j="" t_="" id f dep
  while [ $# -gt 0 ]; do
    case "$1" in
      --area) a="$2"; shift 2 ;;
      --repo) r="$2"; shift 2 ;;
      --branch) b="$2"; shift 2 ;;
      --depends) d="$2"; shift 2 ;;
      --jira) j="$2"; shift 2 ;;
      *) t_="$1"; shift ;;
    esac
  done
  if [ -z "$t_" ]; then
    read -rp "title: " t_
    [ -n "$t_" ] || return 1
    [ -n "$a" ] || a="$(printf 'work\nprivate\n' | fzf --height=6 --prompt='area> ')" || return 1
    [ -n "$r" ] || r="$(find "$HOME/code" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | fzf --height=15 --prompt='repo (esc for none)> ')"
    [ -z "$r" ] || read -rei "$(slugify "$t_")" -p "branch: " b
  fi
  [ "$a" = work ] || [ "$a" = private ] || { echo "t: --area must be work or private" >&2; return 2; }
  id="$(slugify "$t_")"
  [ -n "$id" ] || { echo "t: title has no usable characters" >&2; return 2; }
  [ ! -e "$tasks_dir/work/$id.md" ] && [ ! -e "$tasks_dir/private/$id.md" ] || { echo "t: task exists: $id" >&2; return 1; }
  for dep in ${d//,/ }; do
    [ -e "$tasks_dir/work/$dep.md" ] || [ -e "$tasks_dir/private/$dep.md" ] || { echo "t: no such dependency: $dep" >&2; return 1; }
  done
  f="$tasks_dir/$a/$id.md"
  mkdir -p "$tasks_dir/$a"
  cat >"$f" <<TASK
---
title: $t_
status: open
repo: $r
branch: $b
depends: [${d//,/, }]
jira: $j
session:
---
Goal, constraints and links

## Decisions

## Next step
TASK
  echo "$id"
}

cmd_edit() {
  load
  [ -n "${file[${1:-}]:-}" ] || { echo "t: no such task: ${1:-}" >&2; return 1; }
  "${EDITOR:-nvim}" "${file[$1]}"
}

cmd_done() {
  load
  local f="${file[${1:-}]:-}"
  [ -n "$f" ] || { echo "t: no such task: ${1:-}" >&2; return 1; }
  if [ "${status[$1]}" = done ]; then set_field "$f" status open; else set_field "$f" status done; fi
}

cmd_deps() {
  load
  local id="${1:-}" d other changed picked
  [ -n "${file[$id]:-}" ] || { echo "t: no such task: $id" >&2; return 1; }
  # Tasks already waiting on this one are left out, so a dependency cycle can't be picked.
  declare -A waiting=([$id]=1)
  changed=1
  while [ -n "$changed" ]; do
    changed=""
    for other in "${ids[@]}"; do
      [ -z "${waiting[$other]:-}" ] || continue
      for d in ${deps[$other]}; do
        [ -z "${waiting[$d]:-}" ] || { waiting[$other]=1; changed=1; break; }
      done
    done
  done
  picked="$(
    {
      printf -- '-\t(waits for nothing)\n'
      for other in "${ids[@]}"; do
        [ -n "${waiting[$other]:-}" ] || [ "${status[$other]}" = done ] || printf '%s\t%s\n' "$other" "${title[$other]:-$other}"
      done
    } | fzf --multi --layout=reverse --delimiter=$'\t' --with-nth=2 \
      --header="What must finish before \"${title[$id]:-$id}\"? tab selects, enter saves, esc cancels"$'\n'"now: ${deps[$id]:-nothing}"
  )" || return 0
  picked="$(cut -f1 <<<"$picked" | grep -vx -- - | paste -sd, | sed 's/,/, /g')"
  set_field "${file[$id]}" depends "[$picked]"
}

picker() {
  local out key id msg=""
  local help=$'enter claude · ctrl-t terminal · ctrl-f fresh session · ctrl-n new\nctrl-e edit · ctrl-l waits for · ctrl-d done · ctrl-a show done'
  while :; do
    out="$("$self" _rows | fzf --ansi --no-sort --layout=reverse --delimiter=$'\t' --with-nth=2.. \
      --header="${msg:-$help}" --expect=ctrl-f,ctrl-t --preview="$self _show {1}" --preview-window=right,45% \
      --bind="ctrl-n:execute($self new)+reload($self _rows)" \
      --bind="ctrl-e:execute($self edit {1})+reload($self _rows)" \
      --bind="ctrl-l:execute($self deps {1})+reload($self _rows)" \
      --bind="ctrl-d:execute-silent($self done {1})+reload($self _rows)" \
      --bind="ctrl-a:reload($self _rows --all)")" || return 0
    key="$(sed -n 1p <<<"$out")"
    id="$(sed -n 2p <<<"$out" | cut -f1)"
    [ "$id" != - ] && [ -n "$id" ] || { msg=""; continue; }
    if [ "$key" = ctrl-t ]; then
      msg="$("$self" shell "$id" 2>&1)" && return 0
    elif [ "$key" = ctrl-f ]; then
      msg="$(cmd_open_sub --fresh "$id" 2>&1)" && return 0
    else
      msg="$(cmd_open_sub "$id" 2>&1)" && return 0
    fi
  done
}

# Runs in a new process because load fills global arrays.
cmd_open_sub() { "$self" open "$@"; }

case "${1:-}" in
  "") picker ;;
  ls) shift; load; rows "$@" | cut -f2- ;;
  new) shift; cmd_new "$@" ;;
  open) shift; cmd_open "$@" ;;
  shell) shift; cmd_shell "$@" ;;
  edit) shift; cmd_edit "$@" ;;
  done) shift; cmd_done "$@" ;;
  deps) shift; cmd_deps "$@" ;;
  _rows) shift; load; rows "$@" ;;
  _show) [ "${2:-}" = - ] || cat "$tasks_dir"/*/"${2:-}.md" 2>/dev/null ;;
  -h|--help|help) usage ;;
  *) usage >&2; exit 2 ;;
esac
