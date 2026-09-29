Bash expects those files to live under home directory, not .config/bash.
However I moved it here to maintain a single source of truth for my config file, and I use

```
ln -s ~/.config/bash/bashrc ~/.bashrc
ln -s ~/.config/bash/bash_profile ~/.bash_profile
ln -s ~/.config/bash/bash_logout ~/.bash_logout
```

to keep all those files in sync.

## Custom shortcuts

Defined in `bashrc`.

### Worktrees

```bash
wt <branch>   # create branch and worktree at ~/worktrees/<repo>/<branch>, then cd there
wl            # list current repo worktrees under ~/worktrees/<repo>
wr            # remove the current worktree, then cd to the main worktree
wr <name>     # force remove ~/worktrees/<repo>/<name>
wm            # cd to the current repo main worktree
wra           # remove all current repo worktrees under ~/worktrees/<repo>
ws            # search all workspaces under ~/worktrees with fzf, then cd to the selected one
wa            # resume or start the Codex agent session for the current worktree
wa <name>     # resume/start the agent for ~/worktrees/<repo>/<name>
wa --pick     # choose a worktree, then resume/start its agent session
wa --list     # list worktrees and their latest Codex session
wa --new      # start a fresh Codex session for the current worktree
```

`wa` links worktrees to agents by scanning Codex session metadata under `~/.codex/sessions`
and matching the session `cwd` to the worktree path.

### Other aliases

```bash
k      # kubectl
ls     # eza
bat    # cat
grep   # grep --color=auto
peon   # peon-ping controls
h      # print custom shortcut help
```
