" lua << EOF
" local lsp_installer = require("nvim-lsp-installer")

" -- Register a handler that will be called for all installed servers.
" -- Alternatively, you may also register handlers on specific server instances instead (see example below).
" lsp_installer.on_server_ready(function(server)
"     local opts = {}

"     -- (optional) Customize the options passed to the server
"     --if server.name == "angularls" then
"      --   opts.cmd_cwd = '~/.local/share/nvim/lsp_servers/angularls' end

"     -- This setup() function is exactly the same as lspconfig's setup function.
"     -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
"     server:setup(opts)
" end)
" EOF
