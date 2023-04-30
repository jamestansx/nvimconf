return {
  "windwp/nvim-autopairs",
  event = "VeryLazy",
  opts = {
    check_ts = true,
    enable_check_bracket_line = true,
    fast_wrap = {
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = [=[[%'%"%>%]%)%}%,]]=],
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "Search",
      highlight_grey = "Comment",
    },
  },
  config = function(_, cfg)
    local npairs = require("nvim-autopairs")
    local Rule = require("nvim-autopairs.rule")
    local cond = require("nvim-autopairs.conds")
    npairs.setup(cfg)

    local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }

    -- Custom Rules --

    -- add spaces between parentheses
    npairs.add_rule(Rule(" ", " "):with_pair(function(opts)
      local pair = opts.line:sub(opts.col - 1, opts.col)
      return vim.tbl_contains({
        brackets[1][1] .. brackets[1][2],
        brackets[2][1] .. brackets[2][2],
        brackets[3][1] .. brackets[3][2],
      }, pair)
    end))
    for _, bracket in pairs(brackets) do
      npairs.add_rule(Rule(bracket[1] .. " ", " " .. bracket[2])
        :with_pair(function()
          return false
        end)
        :with_move(function(opts)
          return opts.prev_char:match(".%" .. bracket[2]) ~= nil
        end)
        :use_key(bracket[2]))
    end
  end,
}
