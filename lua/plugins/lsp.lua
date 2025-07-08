return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local lspconfig = require('lspconfig')
      local util = require('lspconfig.util')
      
      -- Common on_attach function
      local on_attach = function(client, bufnr)
        local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
        buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- Mappings
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

      -- Configure LSP servers
      local servers = {
        'sourcekit', 'omnisharp', 'gopls', 'ts_ls', 'html', 'cssls', 'tailwindcss', 'jsonls'
      }

      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup {
          on_attach = on_attach,
          flags = {
            debounce_text_changes = 150,
          }
        }
      end

      -- Special Python configuration with uv support
      lspconfig.pyright.setup {
        on_attach = on_attach,
        before_init = function(_, config)
          local py_root = util.find_git_ancestor(config.root_dir) or config.root_dir
          
          -- Try to find and use uv virtual environment
          local uv_venv = py_root .. '/.venv'
          if vim.fn.isdirectory(uv_venv) == 1 then
            config.settings.python.pythonPath = uv_venv .. '/bin/python'
          else
            -- Fallback: Try poetry environment
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
              diagnosticMode = "workspace",
            },
          },
        },
      }
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