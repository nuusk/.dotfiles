#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source_file="$script_dir/CustomKeys.txt"
wc3_prefix="${WC3_PREFIX:-$HOME/.local/share/Steam/steamapps/compatdata/2329597938/pfx}"
wc3_dir="$wc3_prefix/drive_c/users/steamuser/Documents/Warcraft III"
target_dir="$wc3_dir/CustomKeyBindings"
target_file="$target_dir/CustomKeys.txt"

if pgrep -x 'Warcraft III.exe|Warcraft III.ex' >/dev/null; then
    printf 'Exit Warcraft III first, then run this installer again.\n' >&2
    exit 1
fi
[[ -s "$source_file" && -d "$target_dir" ]] || {
    printf 'Prepared hotkey file or existing Warcraft profile was not found.\n' >&2
    exit 1
}
if [[ -e "$target_file" ]]; then
    backup_file="$target_file.before-grid-$(date +%Y%m%d-%H%M%S-%N).bak"
    cp -a -- "$target_file" "$backup_file"
    printf 'Previous hotkeys backed up to:\n%s\n' "$backup_file"
fi
staged_file=$(mktemp "$target_dir/.CustomKeys.XXXXXX")
cp -- "$source_file" "$staged_file"
chmod 644 "$staged_file"
cmp -s -- "$source_file" "$staged_file"
mv -f -- "$staged_file" "$target_file"
printf '\nInstalled:\n%s\n' "$target_file"
printf '\nIn Warcraft: Options > Input > Preset Keybindings > Custom.\n'
printf 'For your mouse, select Warcraft III Control Groups in Input Remapper and click Apply.\n'
