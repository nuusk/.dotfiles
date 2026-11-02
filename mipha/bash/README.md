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
wa            # resume or start the Claude agent session for the current worktree
wa <name>     # resume/start the agent for ~/worktrees/<repo>/<name>
wa --pick     # choose a worktree, then resume/start its agent session
wa --list     # list worktrees and their latest Claude session
wa --new      # start a fresh Claude session for the current worktree
```

`wa` links worktrees to agents through Claude Code sessions under `~/.claude/projects/`, stored per directory, and resumes the newest one for that worktree.

### Other aliases

```bash
k      # kubectl
ls     # eza
bat    # cat
grep   # grep --color=auto
h      # print custom shortcut help
```
