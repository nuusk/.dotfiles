# AGENTS

Personal config repo. **It is public:** anything committed is published.

## Layout

- `<host>/` (`fi/`, `mipha/`): snapshot of one workstation.
- Theme bundles: portable themes, each in its own top-level directory. Currently only `green_static/`, installed by `apply.sh`. Read a bundle's `AGENTS.md` before changing it.
- `.opencode/`, `.github/`, `.githooks/`, `scripts/`: repo automation and the privacy scanner.

## Path mapping

| Repo path | Live path |
|---|---|
| `<host>/.config/X`, `<host>/.local/X`, `<host>/.claude/X` | `~/.config/X`, `~/.local/X`, `~/.claude/X` |
| `<host>/.claude/settings.hooks.json` | sanitized `hooks` subset of `~/.claude/settings.json`; never commit the rest |
| `<host>/X` (everything else) | `~/.config/X` |
| `<host>/README.md` | not installed |

Files are copied, not symlinked. `~/.bashrc` and friends symlink into `~/.config/bash/`; see `<host>/bash/README.md`.

## Which snapshot

Only touch the snapshot of the machine you are on. Other hosts' snapshots may legitimately differ, so never overwrite them or "fix" them from here.

If it is unclear which directory is this machine, or none exists, ask the user. Do not guess, and do not put raw hostnames in the repo.

## Sync rules

After changing any config on a machine:

1. Copy the change into that host's snapshot, including new and deleted files.
2. If it affects a theme, also update the bundle for the theme in use, and keep its install script and docs accurate.
3. If it adds or removes a tracked tool, update that host's `README.md`.
4. Check drift, and tell the user about any remaining differences you did not cause.
5. Commit and push only when the user asks.

To sync another machine: `git pull`, review the diff, then copy over only what applies. Machine-specific values such as monitor layouts stay in that host's snapshot.

Drift check, run from the repo root with `h=<host>`:

```bash
git ls-files "$h" | while read -r f; do r=${f#"$h"/}
  case "$r" in README.md|.claude/settings.hooks.json) continue;; .config/*|.local/*|.claude/*) t=~/$r;; *) t=~/.config/$r;; esac
  [ -e "$t" ] || { echo "MISSING $r"; continue; }
  cmp -s "$f" "$t" || echo "DIFF $r"
done
```

This only compares tracked files. Check for new live files separately, with `diff -rq "$h/<dir>" ~/.config/<dir>`.

## Never commit

Secrets, tokens, credentials, API keys, private keys, account IDs, histories, caches, `node_modules`, or backups. Sanitize instead, as `mipha/opencode/` does, and document the manual setup in a README.

Enable the pre-push scanner once per clone:

```bash
git config core.hooksPath .githooks
```

CI runs the same scan after pushing, which is too late to keep something private. If it flags real data, stop and tell the user: the data needs rotating, and the history may need rewriting.

## Before finishing

Validate what you changed: `jq empty` for JSON, `bash -n` for shell scripts, `hyprctl reload` for Hyprland.
