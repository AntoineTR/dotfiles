require('telescope').setup{
    defaults = {
        mappings = {
            n = {
                ["<C-q>"] = actions.send_to_qflist,
            }
        }
    }
}
