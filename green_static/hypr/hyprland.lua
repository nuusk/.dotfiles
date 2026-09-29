-- Hyprland 0.55+ Lua configuration.
-- https://wiki.hypr.land/Configuring/Start/

local config_home = os.getenv("XDG_CONFIG_HOME")
if not config_home or config_home == "" then
    config_home = assert(os.getenv("HOME"), "HOME is not set") .. "/.config"
end

local hypr_dir = config_home .. "/hypr"
local theme = require("theme")

-- Portable default; customize output names and positions on the target machine.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.0 })

-- Programs and scripts
local terminal = hypr_dir .. "/glitch-launch.sh kitty"
local file_manager = "dolphin"
local menu = hypr_dir .. "/glitch-launch.sh --shader " .. hypr_dir .. "/shaders/wofi_glitch.frag wofi --show drun"
local screenshot = assert(os.getenv("HOME")) .. "/.local/bin/screenshot"
local wallpaper = hypr_dir .. "/awww_start.sh"
local wallpaper_cycle = hypr_dir .. "/awww_cycle.sh"
local wallpaper_listener = hypr_dir .. "/awww_monitor_listener.sh"
local next_background = hypr_dir .. "/awww_cycle_once.sh next"
local previous_background = hypr_dir .. "/awww_cycle_once.sh prev"
local toggle_crt = hypr_dir .. "/toggle-crt.sh"
local open_worktree = hypr_dir .. "/open-worktree.sh"
local workspace_overview = hypr_dir .. "/workspace-overview.sh"

-- Autostart
hl.on("hyprland.start", function()
    for _, command in ipairs({
        "waybar",
        "dunst",
        wallpaper,
        wallpaper_cycle,
        wallpaper_listener,
        "hyprsunset",
        "hypridle",
    }) do
        hl.exec_cmd(command)
    end
end)

-- Environment
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Look and feel
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = theme.active_border,
            inactive_border = theme.inactive_border,
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 4,
        rounding_power = 0,
        dim_around = 0.22,
        active_opacity = theme.active_opacity,
        inactive_opacity = theme.inactive_opacity,
        shadow = {
            enabled = true,
            range = 20,
            render_power = 3,
            color = theme.shadow,
        },
        blur = {
            enabled = true,
            size = 6,
            passes = 3,
            new_optimizations = true,
            noise = 0.02,
        },
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        preserve_split = true,
        force_split = 2,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        animate_manual_resizes = true,
    },
    input = {
        kb_layout = "pl",
        kb_variant = "",
        kb_model = "",
        kb_options = "caps:super",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

-- Animation curves
hl.curve("snap", {
    type = "bezier",
    points = { { 0.2, 0.9 }, { 0.1, 1.0 } },
})
hl.curve("easeOut", {
    type = "bezier",
    points = { { 0.05, 0.9 }, { 0.1, 1.0 } },
})
hl.curve("quickFade", {
    type = "bezier",
    points = { { 0.3, 0.0 }, { 0.2, 1.0 } },
})
hl.curve("linear", {
    type = "bezier",
    points = { { 0.0, 0.0 }, { 1.0, 1.0 } },
})

-- Animations
hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "snap", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 6, bezier = "easeOut", style = "popin 93%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "quickFade", style = "popin 96%" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "quickFade" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 2, bezier = "easeOut" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 2, bezier = "quickFade" })
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "easeOut", style = "fade" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 5, bezier = "easeOut", style = "popin 96%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 3, bezier = "quickFade", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 3, bezier = "easeOut" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 2, bezier = "quickFade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOut", style = "slidefadevert 8%" })
hl.animation({ leaf = "border", enabled = true, speed = 7, bezier = "easeOut" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 24, bezier = "linear", style = "loop" })

-- Per-device input override retained from the legacy config.
hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

-- Keybindings
local main_mod = "SUPER"

hl.bind(main_mod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(main_mod .. " + Q", hl.dsp.window.close())
hl.bind(main_mod .. " + W", hl.dsp.window.close())
hl.bind(main_mod .. " + N", hl.dsp.exec_cmd(previous_background))
hl.bind(main_mod .. " + M", hl.dsp.exec_cmd(next_background))
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(file_manager))
hl.bind(main_mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(main_mod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(main_mod .. " + TAB", hl.dsp.exec_cmd(workspace_overview))
hl.bind(main_mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(main_mod .. " + A", hl.dsp.exec_cmd(screenshot))
hl.bind(main_mod .. " + SHIFT + A", hl.dsp.exec_cmd(hypr_dir .. "/window-screenshot.sh"))
hl.bind(main_mod .. " + B", hl.dsp.exec_cmd(hypr_dir .. "/glitch-launch.sh firefox"))
hl.bind(main_mod .. " + T", hl.dsp.exec_cmd(open_worktree))
hl.bind("CTRL + ALT + SHIFT + A", hl.dsp.exec_cmd(next_background))
hl.bind("CTRL + ALT + SHIFT + B", hl.dsp.exec_cmd(toggle_crt))
hl.bind(main_mod .. " + R", hl.dsp.exec_cmd(hypr_dir .. "/toggle-record.sh"))
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- Brightness
hl.bind(main_mod .. " + F5", hl.dsp.exec_cmd("brightnessctl s 20%-"))
hl.bind(main_mod .. " + F6", hl.dsp.exec_cmd("brightnessctl s +20%"))

-- Focus movement
hl.bind(main_mod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(main_mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(main_mod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(main_mod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-10, with 10 mapped to key 0.
for workspace = 1, 10 do
    local key = workspace % 10
    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = workspace }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = workspace }))
end

local special_workspaces = {
    { name = "slack", key = "S", command = "slack", class = "^(Slack)$" },
    { name = "obsidian", key = "O", command = "obsidian", class = "^(obsidian)$" },
    { name = "onepassword", key = "P", command = "1password", class = "^(1Password)$" },
    { name = "signal", key = "Z", command = "signal-desktop", class = "^(signal)$" },
}

for _, workspace in ipairs(special_workspaces) do
    hl.bind(main_mod .. " + " .. workspace.key, hl.dsp.workspace.toggle_special(workspace.name))
    hl.bind(
        main_mod .. " + SHIFT + " .. workspace.key,
        hl.dsp.window.move({ workspace = "special:" .. workspace.name })
    )
end

-- Existing-workspace scroll navigation.
hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move and resize windows with the mouse.
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys.
local repeat_when_locked = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), repeat_when_locked)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), repeat_when_locked)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), repeat_when_locked)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), repeat_when_locked)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), repeat_when_locked)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), repeat_when_locked)

local when_locked = { locked = true }
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), when_locked)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), when_locked)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), when_locked)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), when_locked)

-- Special workspaces and their window placement rules.
for _, workspace in ipairs(special_workspaces) do
    hl.workspace_rule({
        workspace = "special:" .. workspace.name,
        on_created_empty = workspace.command,
    })

    hl.window_rule({
        name = workspace.name .. "-special-workspace",
        match = { class = workspace.class },
        workspace = "special:" .. workspace.name .. " silent",
    })
end

hl.layer_rule({
    match = { namespace = "wofi" },
    dim_around = true,
})
