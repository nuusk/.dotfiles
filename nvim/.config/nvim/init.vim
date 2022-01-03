" Neovim configuration file
" For more info about these options, refer to: https://neovim.io/doc/user/options.html

" Set the line number (to the left)
:set number

" Uses the indent from previous line but also recognizes some C syntax to
" increase/reduce the indent where appropriate
:set smartindent

" Enables mouse support in all modes (a)
" n -> normal mode
" v -> visual mode
" i -> insert mode
" c -> command-line mode
" h -> all previous modes when editing a help file
" a -> all previous modes
" r -> for |hit-enter| and |more-prompt| prompt
:set mouse=a

" Number of spaces that a <tab> in the file counts for.
:set tabstop=4

" Number of spaces to use for each step of (auto)indent
:set shiftwidth=4

" I am yet to find out how this actually works
:set smarttab
:set softtabstop=4

" Plugins installed with vim-plug
call plug#begin('~/.vim/plugged')

Plug 'https://github.com/vim-airline/vim-airline' " Cool status bar
Plug 'https://github.com/preservim/nerdtree'
Plug 'https://github.com/tpope/vim-commentary' " Commenting stuff - gcc / gc
Plug 'https://github.com/ap/vim-css-color' " Preview HEX Colors
Plug 'https://github.com/rafi/awesome-vim-colorschemes' " Collection of color schemes for vim
Plug 'https://github.com/neoclide/coc.nvim'  " Auto Completion
Plug 'https://github.com/ryanoasis/vim-devicons' " Developer Iconsi
Plug 'https://github.com/terryma/vim-multiple-cursors' " CTRL + N for multiple cursors

call plug#end()

" Plugin Setup

" Nerd Tree
nnoremap <C-f> :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>

" coc
" :set completeopt-=preview " For No Previews

" confirm autocompletion by typing Tab
inoremap <expr> <Tab> pumvisible() ? coc#_select_confirm() : "<Tab>"
