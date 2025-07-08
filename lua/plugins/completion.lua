return {
  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      -- Setup LuaSnip
      luasnip.config.set_config {
        history = true,
        updateevents = 'TextChanged,TextChangedI',
      }

      -- Add Python snippets
      luasnip.add_snippets("python", {
        luasnip.s("br", {
          luasnip.t({"import ipdb; ipdb.set_trace()"}),
        })
      }, {
        key = "python",
      })

      -- Setup nvim-cmp
      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.close(),
          ['<C-y>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ['<Tab>'] = function(fallback)
            if cmp.visible() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
            elseif luasnip.expand_or_jumpable() then
              vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>luasnip-expand-or-jump', true, true, true), '')
            else
              fallback()
            end
          end,
        },
        sources = {
          { name = 'luasnip', option = { use_show_condition = false } },
          { name = 'nvim_lsp' },
        },
      }
    end
  },
}