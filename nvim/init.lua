vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

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

-- Route the system clipboard through bin/osc52-copy.
--
-- nvim's built-in OSC 52 support emits a correctly-formed
-- `ESC ] 52 ; c ; <b64>`, but tmux intercepts OSC 52 coming from a pane and
-- re-emits it with an EMPTY selection parameter (`ESC ] 52 ; ; <b64>`), which
-- mosh drops - mosh only accepts the `c` selection. osc52-copy sidesteps tmux
-- entirely by writing the sequence to the outer client's tty itself.
--
-- Reading the clipboard back is not possible over mosh (OSC 52 reads are not
-- forwarded), so paste serves whatever nvim last copied instead.
local osc52_copy = vim.fn.expand("~/.local/bin/osc52-copy")
if vim.fn.executable(osc52_copy) == 1 then
  local function paste()
    return vim.split(vim.fn.getreg('"'), "\n")
  end

  vim.g.clipboard = {
    name = "osc52-copy",
    copy = { ["+"] = { osc52_copy }, ["*"] = { osc52_copy } },
    paste = { ["+"] = paste, ["*"] = paste },
    cache_enabled = true,
  }
end
opt.swapfile = false
opt.updatetime = 50
opt.completeopt = { "menu", "menuone", "noselect" }
opt.fileformats = { "dos", "unix" }

vim.api.nvim_create_user_command("LineEndingsDos", function()
  vim.cmd([[silent! %s/\r$//e]])
  vim.bo.fileformat = "dos"
  vim.cmd("write")
end, { desc = "Normalize current buffer to Windows CRLF line endings" })

vim.api.nvim_create_user_command("LineEndingsUnix", function()
  vim.cmd([[silent! %s/\r$//e]])
  vim.bo.fileformat = "unix"
  vim.cmd("write")
end, { desc = "Normalize current buffer to Unix LF line endings" })

local terminal_buf
local terminal_win

local function toggle_floating_terminal()
  if terminal_win and vim.api.nvim_win_is_valid(terminal_win) then
    vim.api.nvim_win_hide(terminal_win)
    return
  end

  if not terminal_buf or not vim.api.nvim_buf_is_valid(terminal_buf) then
    terminal_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[terminal_buf].bufhidden = "hide"
  end

  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.8)
  terminal_win = vim.api.nvim_open_win(terminal_buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " Terminal ",
    title_pos = "center",
  })

  if vim.bo[terminal_buf].buftype ~= "terminal" then
    vim.fn.termopen({ vim.o.shell })
  end

  vim.cmd("startinsert")
end

vim.keymap.set("n", "<C-j>", ":cn<CR>", { silent = true })
vim.keymap.set("n", "<C-k>", ":cp<CR>", { silent = true })
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { silent = true, desc = "Show diagnostics float" })
vim.keymap.set("x", "p", [=["_dP]=], { desc = "Paste without yanking replaced text" })
vim.keymap.set("n", "<leader>tt", toggle_floating_terminal, { silent = true, desc = "Toggle terminal" })
vim.keymap.set("t", "<leader>tt", toggle_floating_terminal, { silent = true, desc = "Toggle terminal" })

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
