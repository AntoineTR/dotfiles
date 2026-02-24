return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local on_attach = function(_, bufnr)
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
      end

      map("n", "gd", vim.lsp.buf.definition, "Go to definition")
      map("n", "gr", vim.lsp.buf.references, "References")
      map("n", "K", vim.lsp.buf.hover, "Hover")
      map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
      map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
      map("n", "<leader>f", function()
        vim.lsp.buf.format({ async = true })
      end, "Format")
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if ok_cmp then
      capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
    end

    require("mason").setup()
    local mlsp_ok, mlsp = pcall(require, "mason-lspconfig")

    local configured = {}
    local has_new_api = vim.lsp ~= nil and vim.lsp.config ~= nil and type(vim.lsp.enable) == "function"

    local function setup_server(server_name)
      if configured[server_name] then
        return
      end

      local ok = false

      if has_new_api then
        local ok_config = pcall(vim.lsp.config, server_name, {
          on_attach = on_attach,
          capabilities = capabilities,
        })
        local ok_enable = ok_config and pcall(vim.lsp.enable, server_name)
        ok = ok_enable
      else
        local lspconfig = require("lspconfig")
        if lspconfig[server_name] then
          lspconfig[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
          ok = true
        end
      end

      if ok then
        configured[server_name] = true
      end
    end

    if mlsp_ok then
      mlsp.setup({})

      if type(mlsp.setup_handlers) == "function" then
        mlsp.setup_handlers({
          function(server_name)
            setup_server(server_name)
          end,
        })
      end

      if type(mlsp.get_installed_servers) == "function" then
        for _, server_name in ipairs(mlsp.get_installed_servers()) do
          setup_server(server_name)
        end
      end
    end

    setup_server("terraformls")
  end,
}
