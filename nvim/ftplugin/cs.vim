"OMNISHARP - remaps
nnoremap <C-o><C-d> :OmniSharpGotoDefinition<CR>
inoremap <expr> <Tab> pumvisible() ? '<C-n>' :
\ getline('.')[col('.')-2] =~# '[[:alnum:].-_#$]' ? '<C-x><C-o>' : '<Tab>'

"Some remap for Omnisharp
"nnoremap <C-o><C-u> :OmniSharpFindUsages<CR>
"nnoremap <C-o><C-d><C-p> :OmniSharpPreviewDefinition<CR>
"nnoremap <C-o><C-r> :!dotnet run



"VIMSPECTOR - remap
"for normal mode - Launch Debugger
"nmap <Leader>dl :call vimspector#Launch()
nmap <Leader>dc :call vimspector#Reset()<CR>

"for normal mode - the word under the cursor
nmap <Leader>di <Plug>VimspectorBalloonEval
"for visual mode, the visually selected text
xmap <Leader>di <Plug>VimspectorBalloonEval

" https://github.com/puremourning/vimspector#human-mode
let g:vimspector_enable_mappings = 'HUMAN'
