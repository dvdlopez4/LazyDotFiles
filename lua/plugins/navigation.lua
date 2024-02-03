return {
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
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
            -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
        },
        keys = {
            { "<leader>ee", "<cmd>Neotree toggle focus<CR>", desc = "Toggle Neotree" },
            { "<leader>ef", "<cmd>Neotree focus<CR>",        desc = "Focus on Neotree" }
        }
    },
}
