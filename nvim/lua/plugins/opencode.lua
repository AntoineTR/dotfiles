return {
  "sudo-tee/opencode.nvim",
  cmd = { "Opencode" },
  keys = {
    {
      "<leader>oo",
      function()
        require("opencode.api").open_output()
      end,
      desc = "Open Opencode output",
    },
    {
      "<leader>oa",
      function()
        require("opencode.api").switch_mode()
      end,
      desc = "Toggle Opencode mode (plan/build)",
    },
  },
  config = function()
    require("opencode").setup({
      default_global_keymaps = false,
      keymap = {
        editor = {
          ["<leader>oo"] = { "open_output", desc = "Open Opencode output" },
          ["<leader>oa"] = { "switch_mode", desc = "Toggle Opencode mode (plan/build)" },
        },
      },
    })

    vim.keymap.set("n", "<leader>oo", function()
      require("opencode.api").open_output()
    end, { silent = true, desc = "Open Opencode output" })

    vim.keymap.set("n", "<leader>oa", function()
      require("opencode.api").switch_mode()
    end, { silent = true, desc = "Toggle Opencode mode (plan/build)" })
  end,
}
