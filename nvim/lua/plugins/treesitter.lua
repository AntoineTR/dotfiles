-- Manages treesitter parser installs (:TSInstall / :TSUpdate / ensure_installed).
-- Pinned to master: the main branch's installer needs the tree-sitter CLI,
-- which we don't install machine-wide.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = { "prisma" },
    })

    -- Treesitter highlighting is opt-in per filetype; nvim's regex syntax
    -- keeps covering everything else.
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "prisma" },
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}
