return {
  -- Mason: LSP installer
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    }
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      { "williamboman/mason.nvim", opts = {} },
      {
        "williamboman/mason-lspconfig.nvim",
        opts = {
          ensure_installed = { "pyright", "ts_ls", "html", "cssls", "tailwindcss", "jsonls", "gopls" }
        }
      }
    },
    config = function()
      -- Setup LSP keymaps on attach
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local bufnr = args.buf
          vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

          local opts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<leader>ld', vim.diagnostic.open_float, opts)
          vim.keymap.set('n', '<leader>ai', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<leader>lf', vim.lsp.buf.format, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
          vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
        end
      })

      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Configure servers with vim.lsp.config (modern API)
      local servers = { 'gopls', 'ts_ls', 'html', 'cssls', 'tailwindcss', 'jsonls' }

      for _, server in ipairs(servers) do
        vim.lsp.config(server, {
          capabilities = capabilities,
          flags = { debounce_text_changes = 150 }
        })
      end

      -- Python with uv/poetry support
      vim.lsp.config('pyright', {
        capabilities = capabilities,
        before_init = function(_, config)
          local util = require('lspconfig.util')
          local py_root = util.find_git_ancestor(config.root_dir) or config.root_dir
          local uv_venv = py_root .. '/.venv'

          if vim.fn.isdirectory(uv_venv) == 1 then
            config.settings.python.pythonPath = uv_venv .. '/bin/python'
          else
            local poetry_env = vim.fn.trim(vim.fn.system('cd "' .. py_root .. '" && poetry env info -p 2>/dev/null'))
            if vim.v.shell_error == 0 and vim.fn.isdirectory(poetry_env) == 1 then
              config.settings.python.pythonPath = poetry_env .. '/bin/python'
            end
          end
        end,
        settings = {
          python = {
            analysis = {
              extraPaths = { vim.fn.expand("~/.stubs") },
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace"
            }
          }
        }
      })
    end
  },

  -- none-ls for additional formatting/linting
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvimtools/none-ls-extras.nvim",
    },
    config = function()
      local null_ls = require('null-ls')
      null_ls.setup({
        sources = {
          require("none-ls.diagnostics.ruff"),
          require("none-ls.formatting.ruff"),
          null_ls.builtins.code_actions.gitsigns,
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
            })
          end
        end,
      })
    end
  },

  -- LSP signature help
  {
    "ray-x/lsp_signature.nvim",
    event = "VeryLazy",
    config = function()
      require('lsp_signature').setup({
        bind = false,
      })
    end
  },
}