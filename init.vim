set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
" source ~/.vimrc

call plug#begin('~/.config/nvim/plugged') 
Plug 'morhetz/gruvbox'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'vim-airline/vim-airline'
Plug 'OmniSharp/omnisharp-vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'SirVer/ultisnips'
"Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()

set completeopt=menuone,noinsert,noselect,preview
let g:asyncomplete_auto_popup = 1
let g:asyncomplete_auto_completeopt = 0
let g:asyncomplete_force_refresh_on_context_changed = 1

let g:OmniSharp_server_stdio = 1
let g:OmniSharp_highlight_types = 2

" if using ultisnips, set g:OmniSharp_want_snippet to 1
let g:OmniSharp_want_snippet = 1
filetype plugin on
set omnifunc=syntaxcomplete#Complete
let g:OmniSharp_server_type = 'roslyn' 
let g:OmniSharp_prefer_global_sln = 1  
let g:OmniSharp_timeout = 10           



set relativenumber
set nu
set guicursor=
set nohlsearch
set hidden
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nowrap
set incsearch
set scrolloff=5
set signcolumn=yes
set colorcolumn=80
set clipboard=unnamed
set noswapfile
set clipboard=unnamed
set updatetime=50

colorscheme gruvbox
set background=dark

let mapleader = " "

nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>
nnoremap <Leader>pf :lua require('telescope.builtin').find_files()<CR>
"inoremap <silent><expr> <c-space> coc#refresh()
