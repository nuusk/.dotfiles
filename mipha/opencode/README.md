# OpenCode

Repo-safe OpenCode configuration for the `mipha` machine.

This directory intentionally omits live secrets and account-specific tokens.

## Included

- `opencode.json`
  Global OpenCode config with MCP entries.
- `package.json`
  Dependency manifest for local plugins.

## Install

Copy this directory into place:

```bash
mkdir -p ~/.config/opencode
cp ~/code/.dotfiles/mipha/opencode/opencode.json ~/.config/opencode/opencode.json
cp ~/code/.dotfiles/mipha/opencode/package.json ~/.config/opencode/package.json
cp ~/code/.dotfiles/mipha/opencode/.gitignore ~/.config/opencode/.gitignore
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


## Notes

- This directory is safe to commit because secrets were replaced with env-based placeholders or left disabled.
- Do not copy `node_modules/` into the repo.
