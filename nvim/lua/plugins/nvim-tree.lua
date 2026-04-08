return {
  "nvim-tree/nvim-tree.lua",
  cmd = { "NvimTreeOpen", "NvimTreeToggle", "NvimTreeFindFile" },
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function(data)
        if vim.fn.isdirectory(data.file) ~= 1 then
          return
        end
        vim.cmd.cd(data.file)
        vim.cmd("NvimTreeOpen")
      end,
    })
  end,
  keys = {
    {
      "<leader>e",
      function()
        require("nvim-tree.api").tree.toggle()
      end,
      desc = "Toggle file explorer",
    },
  },
  opts = {
    view = {
      width = 30,
      preserve_window_proportions = true,
    },
    actions = {
      open_file = {
        quit_on_open = false,
      },
    },
    update_focused_file = {
      enable = true,
      update_root = false,
    },
  },
}
