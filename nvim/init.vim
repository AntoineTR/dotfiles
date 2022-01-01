set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
let mapleader = " "

"source ~/.vimrc

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
Plug 'preservim/nerdtree'

"Commenter
Plug 'preservim/nerdcommenter'

" Telescope (fzf like)
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" Harpoon
Plug 'ThePrimeagen/harpoon'

" Fugitive - Git addon
Plug 'tpope/vim-fugitive'

" dotnet
Plug 'OmniSharp/omnisharp-vim'
Plug 'dense-analysis/ale'

" debugger
Plug 'puremourning/vimspector'

" Coc Server
Plug 'neoclide/coc.nvim',{'branch': 'release'}

Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

"Highlight
Plug 'sheerun/vim-polyglot'

" Markdown preview
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

" Copilot
Plug 'github/copilot.vim'


call plug#end()

"CONFIG PLUGINS

"Ale is for linting ( unused usings, live errors )
"Should be split in ftplugin
let g:ale_linters = {
            \ 'cs': ['OmniSharp'],
            \ 'javascript': ['eslint'],
            \}
let g:ale_fix_on_save = 1
let g:ale_fixers = {
            \   '*': ['remove_trailing_lines', 'trim_whitespace'],
            \   'javascript': ['eslint'],
            \   'typescript': ['eslint','prettier','tslint'],
            \}
" Copilot configs

let g:copilot_filetypes = {
            \ 'markdown': v:true,
            \}


"Lua Files
lua require("leantoinetr")

"nvim configs
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
set colorcolumn=140
set clipboard=unnamed
set noswapfile
set updatetime=50
set autochdir
filetype plugin on

"Set Theme
colorscheme dracula


"Harpoon Remaps
nmap <leader>hh :lua require("harpoon.ui").toggle_quick_menu()<CR>
nmap <leader>ha :lua require("harpoon.mark").add_file()<CR>
nmap <leader>f :lua require("harpoon.ui").nav_prev()<CR>
nmap <leader>j :lua require("harpoon.ui").nav_next()<CR>

nmap <leader>a :G<CR>

"Fugitive Remaps
nmap <leader>gs :G<CR>
nmap <leader>gd :Gdiffsplit<CR>
nmap <leader>gp :Git push<CR>

"QuickFix List Remaps
map <C-j> :cn<CR>
map <C-k> :cp<CR>


"Typescript remap
let g:typescript_compiler_binary = 'tsc'
let g:typescript_compiler_options = ''
autocmd QuickFixCmdPost [^l]* nested cwindow
autocmd QuickFixCmdPost    l* nested lwindow
let g:coc_global_extensions = [ 'coc-tsserver' ]
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> ga <Plug>(coc-fix-current)
