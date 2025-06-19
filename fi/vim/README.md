## vim

This is my setup of vim.

Make sure you have created directory $HOME/.vim/undodir beucase it is used by `.vimrc` as `undodir`

### Plugin manager

I use vim-plug as my plugin manager. Go to https://github.com/junegunn/vim-plug for installation guide. As of 02.01.2022, I installed it with:
```
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

### Font

To make NerdTree to work, make sure you have a Nerd Tree Compatible Font.
I went with Sauce Code Pro.

Since I'm using `i3`, I updated mmy `.config/i3/config` with
```
font pango:SauceCodePro Nerd Font 10
```
