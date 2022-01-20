set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
let mapleader = " "

"PLUGINS

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')
"Theme
"Plug 'morhetz/gruvbox' -- switched to dracula
Plug 'dracula/vim', { 'as': 'dracula' }

"File Explorer
" Plug 'preservim/nerdtree'

"Commenter
"Plug 'preservim/nerdcommenter'
Plug 'tpope/vim-commentary'

" Telescope (fzf like)
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'

" Directory Tree
Plug 'elihunter173/dirbuf.nvim'

" Harpoon
Plug 'ThePrimeagen/harpoon'

" Fugitive - Git addon
Plug 'tpope/vim-fugitive'

" dotnet
" Plug 'OmniSharp/omnisharp-vim'
" Plug 'dense-analysis/ale'

" debugger
" Plug 'puremourning/vimspector'

" Coc Server
 Plug 'neoclide/coc.nvim',{'branch': 'release'}

" LSP Config
"Plug 'neovim/nvim-lspconfig'
"Plug 'williamboman/nvim-lsp-installer'

" treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Highlight
" Plug 'sheerun/vim-polyglot'

" Markdown preview
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

" Copilot
Plug 'github/copilot.vim'


call plug#end()


"nvim configs
set relativenumber
set nu
set guicursor=
set nohlsearch
set hidden
set noerrorbells
set tabstop=2 softtabstop=2
set shiftwidth=2
set expandtab
set smartindent
set nowrap
set incsearch
set scrolloff=5
set signcolumn=yes
set colorcolumn=140
set clipboard=unnamed
set noswapfile
set updatetime=50
filetype plugin on




"QuickFix List Remaps
map <C-j> :cn<CR>
map <C-k> :cp<CR>

