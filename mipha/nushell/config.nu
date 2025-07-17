# config.nu
#
# Installed by:
# version = "0.104.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

alias l = eza
alias t = tmux
alias k = kubectl
alias c = /home/nuus/.claude/local/claude

$env.config.buffer_editor = "nvim"
$env.PATH = ($env.PATH | append '/home/nuus/.cargo/bin')
$env.PATH = ($env.PATH | append ($env.HOME | path join "go" "bin"))
$env.PATH = ($env.PATH | append '/home/nuus/.local/share/../bin')
$env.PATH = ($env.PATH | append '/home/nuus/.npm-global/bin')

# Carapace - Autocompletion
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
source ~/.cache/carapace/init.nu

# Anthropic - needed by code companion in nvim
# $env.ANTHROPIC_KEY = (
#   ^gpg --quiet --decrypt ~/.secrets/anth_key.gpg
#   | str trim
# )


# Gemini CLI setup
$env.GOOGLE_CLOUD_PROJECT = 'atreides-465401'

