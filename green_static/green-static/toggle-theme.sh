#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
data_root="${XDG_DATA_HOME:-$HOME/.local/share}"
state_dir="$config_root/green-static"
state_file="$state_dir/current"
source_root="$script_dir/themes"
dunst_base="$script_dir/../dunst/dunstrc.base"
lock_file="${XDG_RUNTIME_DIR:-/tmp}/green-static-theme.lock"

read_mode() {
    local mode="dark"

    if [[ -r "$state_file" ]]; then
        read -r mode < "$state_file" || true
    fi

    case "$mode" in
        dark|light) printf '%s\n' "$mode" ;;
        *) printf '%s\n' dark ;;
    esac
}

print_status() {
    if [[ "$(read_mode)" == "light" ]]; then
        printf '{"text":"","alt":"light","class":"light","tooltip":"Light theme · click for dark"}\n'
    else
        printf '{"text":"","alt":"dark","class":"dark","tooltip":"Dark theme · click for light"}\n'
    fi
}

atomic_copy() {
    local source="$1"
    local target="$2"
    local temporary

    mkdir -p -- "$(dirname -- "$target")"
    temporary="$(mktemp "${target}.tmp.XXXXXX")"
    cp -- "$source" "$temporary"
    chmod --reference="$source" "$temporary" 2>/dev/null || true
    mv -f -- "$temporary" "$target"
}

write_state() {
    local mode="$1"
    local temporary

    mkdir -p -- "$state_dir"
    temporary="$(mktemp "${state_file}.tmp.XXXXXX")"
    printf '%s\n' "$mode" > "$temporary"
    mv -f -- "$temporary" "$state_file"
}

render_dunst_config() {
    local palette="$1"
    local target="$config_root/dunst/dunstrc"
    local temporary

    mkdir -p -- "$(dirname -- "$target")"
    temporary="$(mktemp "${target}.tmp.XXXXXX")"
    {
        cat -- "$dunst_base"
        printf '\n'
        cat -- "$palette"
    } > "$temporary"
    mv -f -- "$temporary" "$target"
}

install_light_kde_scheme() {
    local source="$source_root/light/GreenStaticLight.colors"

    mkdir -p -- "$data_root/color-schemes"
    atomic_copy "$source" "$data_root/color-schemes/GreenStaticLight.colors"
}

apply_kde_palette() {
    local palette="$1"
    local section=""
    local line key value

    command -v kwriteconfig6 >/dev/null 2>&1 || return 0

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%$'\r'}"
        case "$line" in
            ''|'#'*|';'*) continue ;;
            '['*']')
                section="${line:1:${#line}-2}"
                ;;
            *=*)
                [[ -n "$section" ]] || continue
                key="${line%%=*}"
                value="${line#*=}"
                kwriteconfig6 --file kdeglobals --group "$section" --key "$key" "$value"
                ;;
        esac
    done < "$palette"
}

reload_desktop() {
    local mode="$1"

    [[ "${GREEN_STATIC_SKIP_LIVE_RELOAD:-0}" == "1" ]] && return 0

    if command -v gsettings >/dev/null 2>&1; then
        if [[ "$mode" == "light" ]]; then
            gsettings set org.gnome.desktop.interface color-scheme prefer-light >/dev/null 2>&1 || true
        else
            gsettings set org.gnome.desktop.interface color-scheme prefer-dark >/dev/null 2>&1 || true
        fi
    fi

    hyprctl reload config-only >/dev/null 2>&1 || true
    pkill -SIGUSR2 -x waybar >/dev/null 2>&1 || true
    pkill -SIGUSR1 -x kitty >/dev/null 2>&1 || true
    dunstctl reload >/dev/null 2>&1 || true
    dbus-send --session --type=signal /KGlobalSettings \
        org.kde.KGlobalSettings.notifyChange int32:0 int32:0 >/dev/null 2>&1 || true
}

apply_mode() {
    local mode="$1"
    local theme_dir="$source_root/$mode"
    local kde_palette

    case "$mode" in
        dark) kde_palette="$theme_dir/GreenStatic.colors" ;;
        light) kde_palette="$theme_dir/GreenStaticLight.colors" ;;
        *)
            printf 'Unknown theme: %s\n' "$mode" >&2
            return 2
            ;;
    esac

    for required in \
        "$theme_dir/hyprland.conf" \
        "$theme_dir/waybar.css" \
        "$theme_dir/kitty.conf" \
        "$theme_dir/wofi.css" \
        "$theme_dir/gtk.css" \
        "$theme_dir/dunst.conf" \
        "$kde_palette" \
        "$dunst_base"; do
        if [[ ! -r "$required" ]]; then
            printf 'Missing theme file: %s\n' "$required" >&2
            return 1
        fi
    done

    atomic_copy "$theme_dir/hyprland.conf" "$config_root/hypr/theme.conf"
    atomic_copy "$theme_dir/waybar.css" "$config_root/waybar/theme.css"
    atomic_copy "$theme_dir/kitty.conf" "$config_root/kitty/theme.conf"
    atomic_copy "$theme_dir/wofi.css" "$config_root/wofi/theme.css"
    atomic_copy "$theme_dir/gtk.css" "$config_root/gtk-3.0/theme.css"
    atomic_copy "$theme_dir/gtk.css" "$config_root/gtk-4.0/theme.css"
    render_dunst_config "$theme_dir/dunst.conf"
    install_light_kde_scheme
    apply_kde_palette "$kde_palette"
    write_state "$mode"
    reload_desktop "$mode"
}

command="${1:-status}"

case "$command" in
    status)
        print_status
        ;;
    toggle)
        exec 9> "$lock_file"
        flock 9
        if [[ "$(read_mode)" == "dark" ]]; then
            apply_mode light
        else
            apply_mode dark
        fi
        ;;
    set)
        [[ $# -eq 2 ]] || {
            printf 'Usage: %s set dark|light\n' "$0" >&2
            exit 2
        }
        exec 9> "$lock_file"
        flock 9
        apply_mode "$2"
        ;;
    dark|light)
        exec 9> "$lock_file"
        flock 9
        apply_mode "$command"
        ;;
    *)
        printf 'Usage: %s {status|toggle|set dark|set light}\n' "$0" >&2
        exit 2
        ;;
esac
