vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.netrw_winsize = 25

local opt = vim.opt

opt.relativenumber = true
opt.number = true
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:block"
opt.hlsearch = false
opt.hidden = true
opt.errorbells = false
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.incsearch = true
opt.scrolloff = 5
opt.signcolumn = "yes"
opt.colorcolumn = "140"
opt.clipboard = "unnamed"
opt.swapfile = false
opt.updatetime = 50
opt.completeopt = { "menu", "menuone", "noselect" }

vim.keymap.set("n", "<C-j>", ":cn<CR>", { silent = true })
vim.keymap.set("n", "<C-k>", ":cp<CR>", { silent = true })
vim.keymap.set("n", "<leader>e", function()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "netrw" then
      vim.api.nvim_win_close(win, true)
      return
    end
  end
  vim.cmd("Lexplore")
end, { silent = true, desc = "Toggle sidebar explorer" })

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
})
