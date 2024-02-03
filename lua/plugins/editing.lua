return {
    {
        "rcarriga/nvim-dap-ui",
        lazy = true,
        dependencies = { "mfussenegger/nvim-dap" }
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
            local omnisharp_bin = "~/.local/share/lazy/mason/packages/omnisharp/omnisharp"

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
            -- Option 2: nvim lsp as LSP client
            -- Tell the server the capability of foldingRange,
            -- Neovim hasn't added foldingRange to default capabilities, users must add it manually
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true
            }
            local language_servers = require("lspconfig").util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
            for _, ls in ipairs(language_servers) do
                require('lspconfig')[ls].setup({
                    capabilities = capabilities
                    -- you can add other fields for setting up lsp server in this table
                })
            end
            require('ufo').setup()

            require('ufo').setup({
                provider_selector = function(bufnr, filetype, buftype)
                    return { 'treesitter', 'indent' }
                end
            })
        end
    }
}
