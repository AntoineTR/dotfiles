set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
let mapleader = " "

" source ~/.vimrc

call plug#begin('~/.config/nvim/plugged') 
"Theme
Plug 'morhetz/gruvbox'
Plug 'dracula/vim', { 'as': 'dracula' }

"File Explorer
Plug 'preservim/nerdtree'

" Telescope (fzf like) 
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" dotnet 
Plug 'OmniSharp/omnisharp-vim'
Plug 'dense-analysis/ale'

" debugger
Plug 'puremourning/vimspector'


call plug#end()

"Some remap for Omnisharp
"nnoremap <C-o><C-u> :OmniSharpFindUsages<CR>
nnoremap <C-o><C-d> :OmniSharpGotoDefinition<CR>
"nnoremap <C-o><C-d><C-p> :OmniSharpPreviewDefinition<CR>
"nnoremap <C-o><C-r> :!dotnet run
inoremap <expr> <Tab> pumvisible() ? '<C-n>' :                                                                                                                    
\ getline('.')[col('.')-2] =~# '[[:alnum:].-_#$]' ? '<C-x><C-o>' : '<Tab>'

"Ale is for linting ( unused usings, live errors )
let g:ale_linters = { 'cs': ['OmniSharp'] }
"Some reference problem between projects without this ...
"let g:OmniSharp_server_use_mono = 1


"vimspector remap and configs
"for normal mode - Launch Debugger
"nmap <Leader>dl :call vimspector#Launch()
nmap <Leader>dc :call vimspector#Reset()<CR>
 
"for normal mode - the word under the cursor
nmap <Leader>di <Plug>VimspectorBalloonEval
"for visual mode, the visually selected text
xmap <Leader>di <Plug>VimspectorBalloonEval

" https://github.com/puremourning/vimspector#human-mode
let g:vimspector_enable_mappings = 'HUMAN'


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
set colorcolumn=80
set clipboard=unnamed
set noswapfile
set updatetime=50

"Set Theme
colorscheme dracula

"Telescope Shortcut

nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>
nnoremap <Leader>pf :lua require('telescope.builtin').find_files()<CR>
"inoremap <silent><expr> <c-space> coc#refresh()
