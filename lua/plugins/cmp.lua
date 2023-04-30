return {
  "hrsh7th/nvim-cmp",
  version = false,
  event = "InsertEnter",
  dependencies = {
    { "saadparwaiz1/cmp_luasnip", dependencies = { "L3MON4D3/LuaSnip" } },
    "doxnit/cmp-luasnip-choice",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "onsails/lspkind.nvim",
  },
  opts = function()
    local cmp = require("cmp")
    local map = cmp.mapping
    local winhl = "Pmenu:CmpPmenu,CursorLine:PmenuSel,Search:None"

    return {
      completion = {
        completeopt = table.concat(vim.opt.completeopt:get(), ","),
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      window = {
        completion = {
          winhighlight = winhl,
          col_offset = -3,
          side_padding = 0,
          scrollbar = false,
        },
        documentation = {
          winhighlight = winhl,
        },
      },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          -- Remove duplicated neovim lua api entries
          vim_item.dup = ({
            ["nvim_lua"] = 0,
            ["path"] = 0,
          })[entry.source.name] or 0

          local kind = require("lspkind").cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
          })(entry, vim_item)
          local str = vim.split(kind.kind, "%s", { trimempty = true })
          kind.kind = " " .. (str[1] or "") .. " "
          kind.menu = "    (" .. (str[2] or "") .. ")"

          return kind
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-u>"] = map.scroll_docs(-4),
        ["<C-d>"] = map.scroll_docs(4),
        ["<CR>"] = map({
          i = function(fallback)
            if cmp.visible() and cmp.get_active_entry() then
              cmp.confirm({
                behavior = cmp.ConfirmBehavior.Insert,
                select = false,
              })
            else
              fallback()
            end
          end,
          s = map.confirm({ select = true }),
          c = map.confirm({
            behavior = cmp.ConfirmBehavior.Insert,
            select = true,
          }),
        }),
        ["<C-e>"] = map.abort(),
        ["<C-y>"] = map.confirm({
          behavior = cmp.ConfirmBehavior.Insert,
          select = true,
        }, { "i", "c" }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          local luasnip = require("luasnip")
          if luasnip.expand_or_locally_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          local luasnip = require("luasnip")
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        {
          name = "nvim_lsp",
          entry_filter = function(entry, ctx)
            return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()]
              ~= "Text"
          end,
        },
        { name = "nvim_lua" },
        { name = "luasnip", { show_autosnippets = true } },
        { name = "luasnip_choice" },
        { name = "path" },
      }, {
        {
          name = "buffer",
          option = {
            keyword_length = 7,
            get_bufnrs = function()
              local bufs = vim.api.nvim_list_bufs()
              if #bufs == 1 and vim.api.nvim_buf_is_loaded(bufs[1]) then
                return bufs
              end
              local bfnrs = {}
              for _, bfnr in ipairs(bufs) do
                local byte_size = vim.api.nvim_buf_get_offset(
                  bfnr,
                  vim.api.nvim_buf_line_count(bfnr)
                )
                if
                  byte_size <= 1024 * 1024 and vim.api.nvim_buf_is_loaded(bfnr)
                then
                  table.insert(bfnrs, bfnr)
                end
              end
              return bfnrs
            end,
          },
        },
      }),
      sorting = {
        priority_weight = 2,
        comparators = {
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          -- ref: https://github.com/lukas-reineke/cmp-under-comparator
          function(entry1, entry2)
            local _, entry1_under = entry1.completion_item.label:find("^_+")
            local _, entry2_under = entry2.completion_item.label:find("^_+")
            entry1_under = entry1_under or 0
            entry2_under = entry2_under or 0
            if entry1_under > entry2_under then
              return false
            elseif entry1_under < entry2_under then
              return true
            end
          end,
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      },
      experimental = {
        ghost_text = {
          hl_group = "LspCodeLens",
        },
      },
    }
  end,
}
