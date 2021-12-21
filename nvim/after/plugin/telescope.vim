if !exists('g:loaded_telescope') | finish | endif


nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep For > ")})<CR>
nnoremap <C-p> :lua require('telescope.builtin').git_files()<CR>
nnoremap <C-b> :lua require('telescope.builtin').git_branches()<CR>
"nnoremap <C-p> :lua require('telescope.builtin').find_files()<CR>
nnoremap <C-f> :lua require('telescope.builtin').file_browser()<CR>
nnoremap <silent> ;; <cmd>Telescope help_tags<cr>

lua << EOF
function telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

local telescope = require('telescope')
local actions = require('telescope.actions')
telescope.setup{
  defaults = {
    mappings = {
      n = {
          ["<C-q>"] = actions.send_to_qflist,
          ["q"] = actions.close
      },
    },
  }
}
EOF
