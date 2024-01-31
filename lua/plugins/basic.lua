return {
    -- the colorscheme should be available when starting Neovim
    {
        "folke/tokyonight.nvim",
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            -- load the colorscheme here
            vim.cmd([[colorscheme tokyonight]])
        end,
    },
    {
        "folke/which-key.nvim",
        lazy = true,
        config = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end
    },
    {
        "rcarriga/nvim-dap-ui",
        lazy = true,
        dependencies = { "mfussenegger/nvim-dap" }
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },

        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
            vim.keymap.set('n', '<C-p>', builtin.git_files, {})
            vim.keymap.set('n', '<leader>ps', function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") })
            end)

            vim.opt.foldmethod = "expr"
            vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
            vim.opt.foldenable = false
            require('telescope').load_extension('cder')
        end
    },
    {
        'nvim-treesitter/nvim-treesitter',
        config = function()
            require 'nvim-treesitter.configs'.setup {
                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                auto_install = true,

                incremental_selection = {
                    enable = true,
                    keymaps = {
                        node_incremental = "v",
                        node_decremental = "V",
                    },
                },
            }
        end,
        build = ":TSUpdate"
    },
    { 'nvim-treesitter/playground' },
    {
        'theprimeagen/harpoon',
        config = function()
            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")

            vim.keymap.set("n", "<leader>a", mark.add_file)
            vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)

            vim.keymap.set("n", "<leader><C-j>", function() ui.nav_file(1) end, { desc = "Harpoon file 1" })
            vim.keymap.set("n", "<leader><C-k>", function() ui.nav_file(2) end, { desc = "Harpoon file 2" })
            vim.keymap.set("n", "<leader><C-l>", function() ui.nav_file(3) end, { desc = "Harpoon file 3" })
            vim.keymap.set("n", "<leader><C-;>", function() ui.nav_file(4) end, { desc = "Harpoon file 4" })
        end
    },
    {
        'mbbill/undotree',
        keys = { { "<leader>u", "<cmd>UndotreeToggle<CR>" } }
    },
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup {
                current_line_blame           = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
                current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
                on_attach                    = function(bufnr)
                    local gs = package.loaded.gitsigns

                    -- Actions
                    vim.keymap.set('n', '<leader>hp', gs.preview_hunk)
                    vim.keymap.set('n', '<leader>tb', gs.toggle_current_line_blame)
                end
            }
        end
    },
    {
        'tpope/vim-fugitive',
        keys = {
            {
                "<leader>gs",
                "<cmd>Git<CR>",
                desc = "Open fugitive"
            },
            { "<leader>gl",  "<cmd>terminal git log --decorate<CR>" },
            { "<leader>gol", "<cmd>Git log --pretty='format:%h %ai %an %s %d'<CR>" },
            { "<leader>grl", "<cmd>Git log --raw<CR>" },
            { "<leader>gba", "<cmd>Git branch -a<CR>" },
            {
                "<leader>gB",
                "<cmd>Git blame<CR>",
                desc = "git blame"
            },
            {
                "<leader>gg",
                "<cmd>Git log --graph --format=format:'%C(auto)%h%C(reset) | %ad | %C(auto)%s%C(reset) | (%an)'<CR>",
                desc = "Pretty git graph"
            }
        },
        config = function()
            local my_fugitive_group = vim.api.nvim_create_augroup("my_fugitive_group", {})
            local autocmd = vim.api.nvim_create_autocmd
            autocmd("BufWinEnter", {
                group = my_fugitive_group,
                pattern = "*",
                callback = function()
                    if vim.bo.ft ~= "fugitive" then
                        return
                    end

                    local bufnr = vim.api.nvim_get_current_buf()
                    local opts = { buffer = bufnr, remap = false }
                    vim.keymap.set("n", "<leader>p", function()
                        vim.cmd.Git('push')
                    end, opts, { desc = "push" })

                    -- rebase always
                    vim.keymap.set("n", "<leader>P", function()
                        vim.cmd.Git({ 'pull', '--rebase' })
                    end, opts)

                    -- NOTE: It allows me to easily set the branch i am pushing and any tracking
                    -- needed if i did not set the branch up correctly
                    vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts);
                end,
            })
        end
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        dependencies = {
            -- LSP Support
            'neovim/nvim-lspconfig',             -- Required
            'williamboman/mason.nvim',           -- Optional
            'williamboman/mason-lspconfig.nvim', -- Optional

            -- Autocompletion
            'hrsh7th/nvim-cmp',         -- Required
            'hrsh7th/cmp-nvim-lsp',     -- Required
            'hrsh7th/cmp-buffer',       -- Optional
            'hrsh7th/cmp-path',         -- Optional
            'saadparwaiz1/cmp_luasnip', -- Optional
            'hrsh7th/cmp-nvim-lua',     -- Optional

            -- Snippets
            'L3MON4D3/LuaSnip',             -- Required
            'rafamadriz/friendly-snippets', -- Optional
        },
        config = function()
            local lsp = require('lsp-zero')
            local mason = require('mason')

            mason.setup()
            require('mason-lspconfig').setup({
                ensure_installed = { "bashls", "jsonls", "rust_analyzer", "tsserver", "html", "lua_ls" },
                handlers = {
                    lsp.default_setup,
                },
            })
            lsp.preset('recommended')


            local cmp = require('cmp')
            local cmp_action = require('lsp-zero').cmp_action()
            local cmp_select = { behavior = cmp.SelectBehavior.Select }
            cmp.setup({
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-f>'] = cmp_action.luasnip_jump_forward(),
                    ['<C-b>'] = cmp_action.luasnip_jump_backward(),
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-d>'] = cmp.mapping.scroll_docs(4),
                    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                })
            })

            lsp.set_preferences({
                sign_icons = {}
            })

            lsp.configure('lua_ls', {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = { 'vim' }
                        }
                    }
                }
            })

            local lspconfig = require("lspconfig")
            local pid = vim.fn.getpid()
            local omnisharp_bin = "/mnt/c/Users/Gamer/Downloads/omnisharp-linux-arm64-net6.0/OmniSharp"

            require 'lspconfig'.omnisharp.setup {
                cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(pid) },
                filetypes = { "cs", "vb" },
                root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj"),

                enable_ms_build_load_projects_on_demand = true,
                enable_roslyn_analyzers = true,
                enable_import_completion = true,
                analyze_open_documents_only = false,
                enable_editorconfig_support = true,
            }

            lsp.on_attach(function(client, bufnr)
                local opts = { buffer = bufnr, remap = false }

                vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
                vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
                vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
                vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
                vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
                vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
                vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
                vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
                vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
                vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
            end)

            lsp.setup()

            vim.diagnostic.config({
                virtual_text = true
            })
        end
    },
    {
        'nvim-lualine/lualine.nvim',
        config = function()
            local clients_lsp = function()
                local bufnr = vim.api.nvim_get_current_buf()

                local clients = vim.lsp.buf_get_clients(bufnr)
                if next(clients) == nil then
                    return ''
                end

                local c = {}
                for _, client in pairs(clients) do
                    table.insert(c, client.name)
                end
                return '\u{f085} ' .. table.concat(c, '|')
            end

            require('lualine').setup {
                options = {
                    icons_enabled = true,
                    theme = 'auto',
                    component_separators = { left = '', right = '' },
                    section_separators = { left = '', right = '' },
                    disabled_filetypes = {
                        statusline = {},
                        winbar = {},
                    },
                    ignore_focus = {},
                    always_divide_middle = true,
                    globalstatus = false,
                    refresh = {
                        statusline = 1000,
                        tabline = 1000,
                        winbar = 1000,
                    }
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff', 'diagnostics' },
                    lualine_c = { 'filename', function()
                        return 'Bufnr: ' .. vim.fn.bufnr()
                    end },
                    lualine_x = { 'encoding', 'fileformat', 'filetype', clients_lsp },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' }
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { 'filename' },
                    lualine_x = { 'location' },
                    lualine_y = {},
                    lualine_z = {}
                },
                tabline = {},
                winbar = {},
                inactive_winbar = {},
                extensions = {}
            }
        end
    },
    {
        'nvim-tree/nvim-web-devicons',
        config = function()
            require 'nvim-web-devicons'.setup {
                -- your personnal icons can go here (to override)
                -- you can specify color or cterm_color instead of specifying both of them
                -- DevIcon will be appended to `name`
                override = {
                    zsh = {
                        icon = "",
                        color = "#428850",
                        cterm_color = "65",
                        name = "Zsh"
                    }
                },
                -- globally enable different highlight colors per icon (default to true)
                -- if set to false all icons will have the default icon's color
                color_icons = true,
                -- globally enable default icons (default to false)
                -- will get overriden by `get_icons` option
                default = true,
                -- globally enable "strict" selection of icons - icon will be looked up in
                -- different tables, first by filename, and if not found by extension; this
                -- prevents cases when file doesn't have any extension but still gets some icon
                -- because its name happened to match some extension (default to false)
                strict = true,
                -- same as `override` but specifically for overrides by filename
                -- takes effect when `strict` is true
                override_by_filename = {
                    [".gitignore"] = {
                        icon = "",
                        color = "#f1502f",
                        name = "Gitignore"
                    }
                },
                -- same as `override` but specifically for overrides by extension
                -- takes effect when `strict` is true
                override_by_extension = {
                    ["log"] = {
                        icon = "",
                        color = "#81e043",
                        name = "Log"
                    }
                },
            }
        end

    },
    -- Lua
    {
        "folke/which-key.nvim",
        lazy = false,
        config = function()
            require("which-key").setup {
                plugins = {
                    marks = true,     -- shows a list of your marks on ' and `
                    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
                    -- the presets plugin, adds help for a bunch of default keybindings in Neovim
                    -- No actual key bindings are created
                    spelling = {
                        enabled = true,   -- enabling this will show WhichKey when pressing z= to select spelling suggestions
                        suggestions = 20, -- how many suggestions should be shown in the list?
                    },
                    presets = {
                        operators = true,    -- adds help for operators like d, y, ...
                        motions = true,      -- adds help for motions
                        text_objects = true, -- help for text objects triggered after entering an operator
                        windows = true,      -- default bindings on <c-w>
                        nav = true,          -- misc bindings to work with windows
                        z = true,            -- bindings for folds, spelling and others prefixed with z
                        g = true,            -- bindings for prefixed with g
                    },
                },
                -- add operators that will trigger motion and text object completion
                -- to enable all native operators, set the preset / operators plugin above
                operators = { gc = "Comments" },
                key_labels = {
                    -- override the label used to display some keys. It doesn't effect WK in any other way.
                    -- For example:
                    -- ["<space>"] = "SPC",
                    -- ["<cr>"] = "RET",
                    -- ["<tab>"] = "TAB",
                },
                motions = {
                    count = true,
                },
                icons = {
                    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
                    separator = "➜", -- symbol used between a key and it's label
                    group = "+", -- symbol prepended to a group
                },
                popup_mappings = {
                    scroll_down = "<c-d>", -- binding to scroll down inside the popup
                    scroll_up = "<c-u>",   -- binding to scroll up inside the popup
                },
                window = {
                    border = "none",          -- none, single, double, shadow
                    position = "bottom",      -- bottom, top
                    margin = { 1, 0, 1, 0 },  -- extra window margin [top, right, bottom, left]. When between 0 and 1, will be treated as a percentage of the screen size.
                    padding = { 1, 2, 1, 2 }, -- extra window padding [top, right, bottom, left]
                    winblend = 0,             -- value between 0-100 0 for fully opaque and 100 for fully transparent
                    zindex = 1000,            -- positive value to position WhichKey above other floating windows.
                },
                layout = {
                    height = { min = 4, max = 25 },                                               -- min and max height of the columns
                    width = { min = 20, max = 50 },                                               -- min and max width of the columns
                    spacing = 3,                                                                  -- spacing between columns
                    align = "left",                                                               -- align columns left, center or right
                },
                ignore_missing = false,                                                           -- enable this to hide mappings for which you didn't specify a label
                hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "^:", "^ ", "^call ", "^lua " }, -- hide mapping boilerplate
                show_help = true,                                                                 -- show a help message in the command line for using WhichKey
                show_keys = true,                                                                 -- show the currently pressed key and its label as a message in the command line
                triggers = "auto",                                                                -- automatically setup triggers
                -- triggers = {"<leader>"} -- or specifiy a list manually
                -- list of triggers, where WhichKey should not wait for timeoutlen and show immediately
                triggers_nowait = {
                    -- marks
                    "`",
                    "'",
                    "g`",
                    "g'",
                    -- registers
                    '"',
                    "<c-r>",
                    -- spelling
                    "z=",
                },
                triggers_blacklist = {
                    -- list of mode / prefixes that should never be hooked by WhichKey
                    -- this is mostly relevant for keymaps that start with a native binding
                    i = { "j", "k" },
                    v = { "j", "k" },
                },
                -- disable the WhichKey popup for certain buf types and file types.
                -- Disabled by default for Telescope
                disable = {
                    buftypes = {},
                    filetypes = {},
                },
            }
        end
    },
    -- lazy.nvim
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            -- add any options here
        },
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        },
        config = function()
            require("noice").setup({
                lsp = {
                    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true,
                    },
                },
                -- you can enable a preset for easier configuration
                presets = {
                    bottom_search = true,         -- use a classic bottom cmdline for search
                    command_palette = true,       -- position the cmdline and popupmenu together
                    long_message_to_split = true, -- long messages will be sent to a split
                    inc_rename = false,           -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = false,       -- add a border to hover docs and signature help
                },
            })
        end
    },
    {
        'zane-/cder.nvim',
        config = function()
            require('telescope').setup({
                extensions = {
                    cder = {
                        previewer_command =
                            'exa ' ..
                            '-a ' ..
                            '--color=always ' ..
                            '-T ' ..
                            '--level=3 ' ..
                            '--icons ' ..
                            '--long ' ..
                            '--no-permissions ' ..
                            '--no-user ' ..
                            '--no-filesize ' ..
                            '--ignore-glob=\".git|node_modules|cdk.out\"',
                        dir_command = {
                            'fdfind',
                            '--type=d',
                            '-E',
                            '{node_modules,GAIT}',
                            '.',
                            os.getenv('PROJ_DIR')
                        },
                        pager_command = 'batcat --plain --paging=always --pager="less -RS"',
                        mappings = {
                            default = function(directory)
                                vim.cmd.cd(directory)
                            end,
                            ['<CR>'] = function(directory)
                                vim.cmd.lcd(directory)
                                vim.cmd("e " .. directory)
                            end,
                        },
                    },
                },
            })
        end,
        keys = {
            { "<leader>pp", "<cmd>Telescope cder<CR>", desc = "Open projects" }
        }
    },
    {
        'kevinhwang91/nvim-ufo',
        dependencies = 'kevinhwang91/promise-async',
        config = function()
            vim.o.foldcolumn = '1' -- '0' is not bad
            vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
            vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
            vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

            require('ufo').setup({
                provider_selector = function(bufnr, filetype, buftype)
                    return { 'treesitter', 'indent' }
                end
            })
        end
    }
}
