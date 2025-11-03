Bash expects those files to live under home directory, not .config/bash.
However I moved it here to maintain a single source of truth for my config file, and I use

```
ln -s ~/.config/bash/bashrc ~/.bashrc
ln -s ~/.config/bash/bash_profile ~/.bash_profile
ln -s ~/.config/bash/bash_logout ~/.bash_logout
```

to keep all those files in sync.
