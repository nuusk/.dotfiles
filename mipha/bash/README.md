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
wr <name>     # remove ~/worktrees/<repo>/<name>
wm            # cd to the current repo main worktree
wra           # remove all current repo worktrees under ~/worktrees/<repo>
ws            # search all workspaces under ~/worktrees with fzf, then cd to the selected one
wa            # open the Codex agent session assigned to the current worktree
```

`wa` stores the per-worktree Codex session mapping in:

```bash
~/.local/state/codex-worktree-agents/
```

### Other aliases

```bash
k      # kubectl
ls     # eza
bat    # cat
grep   # grep --color=auto
peon   # peon-ping controls
h      # print custom shortcut help
```
