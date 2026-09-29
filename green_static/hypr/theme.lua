local config_home = os.getenv("XDG_CONFIG_HOME")
if not config_home or config_home == "" then
    config_home = assert(os.getenv("HOME"), "HOME is not set") .. "/.config"
end

local mode = "dark"
local state_file = io.open(config_home .. "/green-static/current", "r")

if state_file then
    local configured_mode = state_file:read("*l")
    state_file:close()

    if configured_mode == "light" then
        mode = "light"
    end
end

local themes = {
    dark = {
        active_border = {
            colors = { "rgba(00ff80aa)", "rgba(00e5ffaa)" },
            angle = 45,
        },
        inactive_border = "rgba(1a233280)",
        shadow = "rgba(00ff8022)",
        active_opacity = 0.95,
        inactive_opacity = 0.88,
    },
    light = {
        active_border = {
            colors = { "rgba(006b46dd)", "rgba(006477cc)" },
            angle = 45,
        },
        inactive_border = "rgba(7f968cdd)",
        shadow = "rgba(14251f24)",
        active_opacity = 1.0,
        inactive_opacity = 1.0,
    },
}

return themes[mode]
