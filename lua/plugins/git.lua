return {
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
                "<cmd>Git log --graph --format=format:'%C(auto)%h%C(reset) | %ad | %C(auto)%s%C(reset) | (%an) %d'<CR>",
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
        'pwntester/octo.nvim',
        priority = 30,
        dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope.nvim',
            -- OR 'ibhagwan/fzf-lua',
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require "octo".setup()
        end
    }
}
