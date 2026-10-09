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

-- mapleader is set in config.keymaps, which config/init.lua requires before
-- this file, so it's already in place by the time lazy.nvim loads plugins.

vim.api.nvim_create_autocmd("FileType", {
    callback = function() pcall(vim.treesitter.start) end,
})

-- Setup lazy.nvim
require("lazy").setup({
    {
        'nvim-telescope/telescope.nvim',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- optional but recommended
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        -- keymaps: lua/config/keymaps.lua
    },
    {
        "rose-pine/neovim",
        name = "rose-pine",
        priority = 1000,
        config = function()
            local ok, matugen_palette = pcall(require, "matugen-colors")
            require("rose-pine").setup({
                palette = ok and { main = matugen_palette } or {},
            })
            vim.cmd.colorscheme("rose-pine")

            -- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            -- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        end
    },
    -- nvim-treesitter archived/broken on Neovim 0.12 — using system parsers + built-in treesitter instead
    -- {
    --     "nvim-treesitter/nvim-treesitter",
    --     branch = 'master',
    --     lazy = false,
    --     build = ":TSUpdate",
    --     config = function()
    --         require'nvim-treesitter.configs'.setup {
    --             ensure_installed = { "c", "lua", "java", "bash", "rust", "markdown", "markdown_inline", "dockerfile", "arduino", "cmake" },
    --             sync_install = false,
    --             auto_install = true,
    --             highlight = {
    --                 enable = true,
    --                 additional_vim_regex_highlighting = false,
    --             },
    --         }
    --     end
    -- },
    {
        "ThePrimeagen/harpoon",
        dependencies = { "nvim-lua/plenary.nvim" },
        -- keymaps: lua/config/keymaps.lua
    },
    {
        'echasnovski/mini.nvim',
        config = function()
            require('mini.comment').setup()
            require('mini.pairs').setup()
            require('mini.diff').setup()
        end
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = { 'echasnovski/mini.nvim' },                                              -- nvim-treesitter removed (archived/broken on Neovim 0.12)
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
    },
    {
        "mbbill/undotree",
        -- keymaps: lua/config/keymaps.lua
    },
    {
        "tpope/vim-fugitive",
        -- keymaps: lua/config/keymaps.lua
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
                    -- "pyright",        -- Python
                    "taplo",          -- TOML
                    "lua_ls",         -- Lua
                    "rust_analyzer",  -- Rust
                    "clangd",         -- C / C++
                    "jdtls",          -- Java
                    -- "bashls",         -- Bash
                    -- "dockerls",       -- Docker
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

            -- LSP keymaps (LspAttach autocmd): lua/config/keymaps.lua

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
        'mrcjkb/rustaceanvim',
        -- To avoid being surprised by breaking changes,
        -- I recommend you set a version range
        version = '^9',
        -- This plugin implements proper lazy-loading (see :h lua-plugin-lazy).
        -- No need for lazy.nvim to lazy-load it.
        lazy = false,
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
