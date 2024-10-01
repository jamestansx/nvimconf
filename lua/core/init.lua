local api, fn, lsp, opt = vim.api, vim.fn, vim.lsp, vim.opt
local autocmd = api.nvim_create_autocmd
local augroup = api.nvim_create_augroup
local map = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

augroup("core", { clear = true })

-- bootstrap lazy.nvim
local lazy_path = table.concat({ fn.stdpath("data"), "/lazy/lazy.nvim" })
if not vim.uv.fs_stat(lazy_path) then
    vim.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazy_path,
    }):wait()
end
opt.rtp:prepend(lazy_path)

----------
-- options
----------
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true
opt.exrc = true -- automatically execute .nvim.lua
opt.hlsearch = false
opt.isfname:append("@-@") -- treat '@' as part of file name
opt.jumpoptions:append("stack,view")
opt.laststatus = 3 -- global statusline
opt.mousemodel = "extend" -- right click extends selection
opt.number = true
opt.pumheight = 5
opt.relativenumber = true
opt.shada = { "'10", "<0", "s10", "h", "/10", "r/tmp" }
opt.shiftround = true -- indent by N * vim.o.shiftwidth
opt.showmode = false
opt.signcolumn = "yes:1"
opt.termguicolors = true
opt.undofile = true
opt.virtualedit = "block" -- allow to extend cursors to void text area
opt.wildcharm = (""):byte() --  to trigger completion on cmdline mapping
opt.wildoptions:remove("pum") -- disable popup menu, use list in statusline
opt.wrap = false

-- vim.opt.wildignore:append({
--     "*.lock", "*cache", "*.swp",
--     "*.pyc", "*.pycache", "*/__pycache__/*",
--     "*/node_modules/*", "*.min.js",
--     "*.o", "*.obj", "*~",
-- })

opt.shortmess:append({
    I = true, -- hide default startup screen
    A = true, -- ignore swap warning message
    c = true, -- disable completion message
    a = true, -- shorter message format
})

opt.list = true
opt.listchars = {
    nbsp = "⦸",     -- U+29B8
    extends = "→",  -- U+2192
    precedes = "←", -- U+2190
    tab = "▹ ",    -- U+25B9
    trail = "·",    -- U+00B7
}

opt.diffopt:append({
    "algorithm:histogram",
    "indent-heuristic",
    "linematch:60",
})

-- better scroll
opt.scrolloff = 6
opt.sidescroll = 6
opt.sidescrolloff = 6

-- transparent popup
opt.pumblend = 10
opt.winblend = 10

-- persistent window splits
opt.splitbelow = true
opt.splitright = true

-- better search n replace behaviour
opt.ignorecase = true -- \C to disable case-insensitive behaviour
opt.inccommand = "split" -- show preview of replace command
opt.smartcase = true

if vim.fn.executable("rg") == 1 then
    opt.grepprg = "rg --no-heading --smart-case --vimgrep"
    opt.grepformat = {
        "%f:%l:%c:%m",
        "%f:%l:%m",
    }
end

vim.diagnostic.config({
    severity_sort = true,
    jump = {
        float = true,
    },
})

autocmd("FileType", {
    group = "core",
    callback = function()
        opt.formatoptions:remove("o")
    end,
})

---------------
-- autocommands
---------------
autocmd("TextYankPost", {
    group = "core",
    callback = function()
        vim.highlight.on_yank({ timeout = 69 })
    end,
})

autocmd("BufReadPost", {
    group = "core",
    callback = function()
        local exclude = { "gitcommit", "gitrebase", "help" }
        if vim.tbl_contains(exclude, vim.bo.ft) then
            return
        end

        local m = api.nvim_buf_get_mark(0, '"')
        if m[1] > 0 and m[1] <= api.nvim_buf_line_count(0) then
            pcall(api.nvim_win_set_cursor, 0, m)
        end
    end,
})

autocmd("BufNewFile", {
    group = "core",
    callback = function()
        autocmd("BufWritePre", {
            group = "core",
            buffer = 0,
            once = true,
            callback = function(ev)
                -- ignore uri pattern
                if ev.match:match([[^%w+://]]) then
                    return
                end

                local f = vim.uv.fs_realpath(ev.match) or ev.match
                fn.mkdir(fn.fnamemodify(f, ":p:h"), "p")
            end,
        })
    end,
})

autocmd("FileType", {
    group = "core",
    pattern = {
        "checkhealth",
        "qf",
        "help",
    },
    callback = function()
        -- perhaps remove this mapping.
        -- use <c-w><c-q> or :bd instead
        vim.keymap.set("n", "q", "<cmd>bdelete<cr>", {
            buffer = 0,
            nowait = true,
        })
    end,
})

----------
-- keymaps
----------
map("n", "n", "nzz")
map("n", "N", "Nzz")
map("n", "*", "*zz")
map("n", "#", "#zz")

-- https://github.com/mhinz/vim-galore#saner-command-line-history
map("c", "<c-n>", [[wildmenumode() == 1 ? "<c-n>" : "\<down\>"]], { expr = true })
map("c", "<c-p>", [[wildmenumode() == 1 ? "<c-p>" : "\<up\>"]], { expr = true })

------
-- lsp
------
local lspconfig = function(name, args)
    if args.enabled == false then
        return
    end

    augroup("core.lsp", { clear = false })
    autocmd("FileType", {
        group = "core.lsp",
        pattern = args.filetypes,
        callback = function(ev)
            if vim.bo[ev.buf].buftype == "nofile" then
                return
            end

            if (args.cmd) == "function" then
                vim.notify("TODO: Support function for lsp cmd", vim.log.levels.WARN)
                return
            end

            args.name = name

            args.capabilities = lsp.protocol.make_client_capabilities()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            args.capabilities = vim.tbl_deep_extend("force", args.capabilities, capabilities)

            args.markers = args.markers or {}
            args.markers[#args.markers + 1] = ".git"
            args.root_dir = vim.fs.root(ev.buf, args.markers)


            lsp.log.set_format_func(vim.inspect)
            lsp.start(args)
        end,
    })
end

autocmd("LspAttach", {
    group = "core",
    callback = function(ev)
        local buf = ev.buf
        local id = ev.data.client_id
        local handlers = lsp.handlers

        handlers["textDocument/signatureHelp"] = lsp.with(handlers.signature_help, {
            anchor_bias = "above",
        })
        handlers["textDocument/hover"] = lsp.with(handlers.hover, {
            anchor_bias = "above",
        })
    end,
})

lspconfig("dartls", {
    cmd = { "fvm", "dart", "language-server", "--protocol=lsp" },
    filetypes = "dart",
    markers = { "pubspec.yaml" },
    init_options = {
        onlyAnalyzeProjectsWithOpenFiles = true,
        suggestFromUnimportedLibraries = true,
    },
    settings = {
        dart = {
            completeFunctionCalls = true,
            showTodos = false,
        },
    },
})

----------
-- plugins
----------
vim.cmd([[packadd cfilter]])

local get_bufnrs = function()
    local buf = api.nvim_get_current_buf()
    local loc = api.nvim_buf_line_count(buf)
    local size = api.nvim_buf_get_offset(buf, loc)

    -- only source buffer with size below 1MB
    if size <= 1048576 then
        return { buf }
    end

    return {}
end

_G.oil_winbar = function()
    local dir = require("oil").get_current_dir()
    if dir then
        return fn.fnamemodify(dir, ":~")
    else
        return api.nvim_buf_get_name(0)
    end
end

local spec = {
    {
        "rebelot/kanagawa.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("kanagawa").setup({
                theme = "dragon",
                background = { dark = "dragon" },
                compile = true,
                transparent = true,

                overrides = function(C)
                    local T = C.theme
                    local P = C.palette

                    return {
                        -- dark completion menu
                        Pmenu = {
                            fg = T.ui.shade0,
                            bg = T.ui.bg_p1,
                            blend = vim.o.pumblend,
                        },
                        PmenuSel = { fg = "NONE", bg = T.ui.bg_p2 },
                        PmenuSbar = { bg = T.ui.bg_m1 },
                        PmenuThumb = { bg = T.ui.bg_p2 },

                        Boolean = { bold = false },
                    }
                end,
            })

            vim.cmd.colorscheme("kanagawa")
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        version = false,
        event = "InsertEnter",
        cmd = { "CmpStatus" },
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local cmp = require("cmp")
            local mapping = cmp.mapping

            cmp.setup({
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end,
                },
                mapping = mapping.preset.insert({
                    ["<c-e>"] = mapping.abort(),
                    ["<c-y>"] = mapping.confirm({ select = true }),
                    ["<cr>"] = mapping.confirm({ select = false }),
                    ["<c-u>"] = mapping.scroll_docs(-5),
                    ["<c-d>"] = mapping.scroll_docs(5),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                }, {
                    { name = "path" },
                    {
                        name = "buffer",
                        option = {
                            get_bufnrs = get_bufnrs,
                        },
                    },
                }),
                experimental = {
                    ghost_text = true,
                },
            })
        end,
    },
    {
        "mbbill/undotree",
        keys = {
            { "you", vim.cmd.UndotreeToggle, mode = "n" },
        },
        init = function()
            vim.g.undotree_WindowLayout = 2
            vim.g.undotree_ShortIndicators = 1
            vim.g.undotree_SetFocusWhenToggle = 1
            vim.g.undotree_HelpLine = 0
        end,
    },
    {
        "stevearc/oil.nvim",
        lazy = false,
        config = function()
            map("n", "-", "<cmd>Oil<cr>")

            require("oil").setup({
                view_options = {
                    show_hidden = true,
                    is_always_hidden = function(name, bufnr)
                        return name == ".."
                    end
                },
                win_options = {
                    winbar = [[%!v:lua.oil_winbar()]]
                }
            })
        end,
    },
}

require("lazy").setup({
    spec = spec,
    install = {
        colorscheme = { "kanagawa-dragon" },
    },
    checker = { enabled = false },
    change_detection = { notify = false },
    performance = {
        rtp = {
            disabled_plugins = {
                "tutor",
                "rplugin",
                "gzip",
                "tarPlugin",
                "zipPlugin",
                "spellfile",
            },
        },
    },
})
