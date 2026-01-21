-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "

-- Setup lazy.nvim
require("lazy").setup({
    {
        'nvim-telescope/telescope.nvim', tag = 'v0.2.1',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- optional but recommended
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find files' })
            vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Telescope git files' })
            vim.keymap.set('n', '<leader>ps', function()
                builtin.grep_string({ search = vim.fn.input("Grep > ") });
            end)
        end
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("rose-pine")

            -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        branch = 'master',
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require'nvim-treesitter.configs'.setup {
                -- A list of parser names, or "all" (the listed parsers MUST always be installed)
                ensure_installed = { "c", "lua", "java", "bash", "rust", "markdown", "markdown_inline", "dockerfile", "arduino", "cmake" },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                auto_install = true,

                highlight = {
                    enable = true,


                    additional_vim_regex_highlighting = false,
                },
            }
        end
    },
    { "nvim-treesitter/playground" },

    {
        "ThePrimeagen/harpoon",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local mark = require("harpoon.mark")
            local ui = require("harpoon.ui")

            vim.keymap.set("n", "<leader>a", mark.add_file)
            vim.keymap.set("n", "<C-e>", ui.toggle_quick_menu)


            vim.keymap.set("n", "<C-1>", function() ui.nav_file(1) end)
            vim.keymap.set("n", "<C-2>", function() ui.nav_file(2) end)
            vim.keymap.set("n", "<C-3>", function() ui.nav_file(3) end)
            vim.keymap.set("n", "<C-4>", function() ui.nav_file(4) end)
        end
    },
    {
        "mbbill/undotree",
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    },
    {
        "tpope/vim-fugitive",
        config = function()
            vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
        end

    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "pyright",        -- Python
                    "taplo",          -- TOML
                    "lua_ls",         -- Lua
                    "rust_analyzer",  -- Rust
                    "clangd",         -- C / C++
                    "jdtls",          -- Java
                    "bashls",         -- Bash
                    "dockerls",       -- Docker
                    "arduino_language_server", -- Arduino
                    -- Arch is too new for cmake, need to install system package
                    -- "cmake",          -- CMake
                },
                handlers = {
                    function(server_name) -- default handler (optional)
                        require("lspconfig")[server_name].setup {
                            capabilities = capabilities
                        }
                    end,

                    ["lua_ls"] = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.lua_ls.setup {
                            capabilities = capabilities,
                            settings = {
                                Lua = {
                                    format = {
                                        enable = true,
                                        -- Put format options here
                                        -- NOTE: the value should be STRING!!
                                        defaultConfig = {
                                            indent_style = "space",
                                            indent_size = "2",
                                        }
                                    },
                                }
                            }
                        }
                    end,
                }
            })


            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(e)
                    local opts = { buffer = e.buf }
                    vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
                    vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
                    vim.keymap.set('n', '<leader>vws', function() vim.lsp.buf.workspace_symbol() end, opts)
                    vim.keymap.set('n', '<leader>vd', function() vim.diagnostic.open_float() end, opts)
                    vim.keymap.set('n', '<leader>vca', function() vim.lsp.buf.code_action() end, opts)
                    vim.keymap.set('n', '<leader>vrr', function() vim.lsp.buf.references() end, opts)
                    vim.keymap.set('n', '<leader>vrn', function() vim.lsp.buf.rename() end, opts)
                    vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, opts)
                    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
                    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
                end,
            })

            vim.diagnostic.config({
                virtual_text = true, -- This is the line that shows the error next to the code
                signs = true,        -- Shows the Error/Warning icons in the gutter
                update_in_insert = true,
                underline = true,
                severity_sort = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            })

        end
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require('cmp')
            local cmp_select = { behavior = cmp.SelectBehavior.Select }

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                }, {
                    { name = 'buffer' },
                    { name = 'path' },
                })
            })
        end
    },
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {}
    },
    {
        "kylechui/nvim-surround",
        version = "^3.0.0", -- Use for stability; omit to use main branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({
                -- Configuration here, or leave empty to use defaults
                surrounds = {
                    ["*"] = {
                        add = { "**", "**" },
                        find = "%*%*.-%*%*",
                        delete = "^(%*%*)().*(%*%*)$",
                    },
                },
                aliases = {
                    ["a"] = ">",
                    ["b"] = "*",
                    ["B"] = "}",
                    ["r"] = "]",
                    ["q"] = { '"', "'", "`" },
                    ["s"] = { "}", "]", ")", ">", '"', "'", "`" },
                },
            })
        end
    },


    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { "rose-pine" } },
    -- install = { colorscheme = { "habamax" } },
    -- automatically check for plugin updates
    checker = { enabled = true },
})
