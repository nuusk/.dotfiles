# OpenCode

Repo-safe OpenCode configuration for the `mipha` machine.

This directory intentionally omits live secrets and account-specific tokens.

## Included

- `opencode.json`
  Global OpenCode config with the MTG planeswalker agents enabled and the old `build` / `plan` agents disabled.
- `agents/`
  Primary agents:
  - `jace-the-mind-sculptor`
  - `teferi-hero-of-dominaria`
  - `chandra-torch-of-defiance`
  - `liliana-of-the-veil`
- `plugins/peon-ping.ts`
  Local OpenCode plugin.
- `peon-ping/config.json`
  Repo-safe plugin config.
- `package.json`
  Dependency manifest for local plugins.

## Install

Copy this directory into place:

```bash
mkdir -p ~/.config/opencode
cp ~/code/.dotfiles/mipha/opencode/opencode.json ~/.config/opencode/opencode.json
cp ~/code/.dotfiles/mipha/opencode/package.json ~/.config/opencode/package.json
cp ~/code/.dotfiles/mipha/opencode/.gitignore ~/.config/opencode/.gitignore
mkdir -p ~/.config/opencode/agents ~/.config/opencode/plugins ~/.config/opencode/peon-ping
cp ~/code/.dotfiles/mipha/opencode/agents/* ~/.config/opencode/agents/
cp ~/code/.dotfiles/mipha/opencode/plugins/* ~/.config/opencode/plugins/
cp ~/code/.dotfiles/mipha/opencode/peon-ping/config.json ~/.config/opencode/peon-ping/config.json
```

Then install plugin dependencies:

```bash
cd ~/.config/opencode
bun install
```

Restart OpenCode after copying the files.

## Manual Setup Required

### 1. Context7 API key

Set:

```bash
export CONTEXT7_API_KEY="..."
```

### 2. Groundcover MCP

The repo copy leaves Groundcover disabled by default.

To enable it, you need to set these environment variables and then change `"enabled": false` to `true` in `~/.config/opencode/opencode.json`:

```bash
export GROUNDCOVER_AUTH_HEADER="Bearer ..."
export GROUNDCOVER_TENANT_UUID="..."
export GROUNDCOVER_BACKEND_ID="..."
export GROUNDCOVER_TIMEZONE="Europe/Warsaw"
```

### 3. Atlassian MCP auth

The Atlassian MCP entry is present, but authentication still needs to be completed interactively in OpenCode / the provider flow.

### 4. Peon-ping packs

The repo-safe `peon-ping/config.json` does not hardcode a personal `packs_dir`.

If you want custom packs such as `pikmin`, you need to either:

1. install packs to the plugin's default path, or
2. manually add a `packs_dir` field to `~/.config/opencode/peon-ping/config.json`

Example:

```json
{
  "packs_dir": "/home/<you>/.claude/hooks/peon-ping/packs"
}
```

You may also want to change:

- `active_pack`
- `default_pack`

### 5. Built-in agent replacement

This config disables OpenCode's built-in `build` and `plan` agents and replaces them with the planeswalker primary agents.

Default agent:

- `teferi-hero-of-dominaria`

## Notes

- This directory is safe to commit because secrets were replaced with env-based placeholders or left disabled.
- Do not copy `node_modules/` into the repo.
