-- Must be set before lazy.nvim loads plugins (config/lazy.lua), so this file
-- has to be required before config.lazy in config/init.lua.
vim.g.mapleader = " "

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open file explorer (netrw)" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join line below, keep cursor position" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half-page down, center cursor" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half-page up, center cursor" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search match, centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search match, centered" })

vim.keymap.set("n", "<C-m>", "I- <Esc>", { desc = "Prefix line with '- ' (markdown list item)" })
vim.keymap.set("v", "<C-m>", ":norm I- <cr><Esc>", { desc = "Prefix selected lines with '- ' (markdown list items)" })

vim.keymap.set("v", "<C-t>", ":s/\\v[.;]\\s*\\r?$//e<CR>", { desc = "Strip trailing '.' or ';' from selected lines" })

vim.keymap.set("v", "<C-b>", ":s/\\v^- \\zs([^.:;]*[.:;])/**\\1**/e<CR>", { desc = "Bold the lead sentence of selected markdown list items" })

vim.keymap.set("v", "s", "S", { remap = true, desc = "Surround selection (nvim-surround)" })

-- Enables mouse support for multiple-cursors style visual selection.
vim.g.VM_mouse_mappings = 1

vim.keymap.set("v", ">", ">gv", { desc = "Indent selection, keep it selected" })
vim.keymap.set("v", "<", "<gv", { desc = "Outdent selection, keep it selected" })

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer.sh<CR>", { desc = "Open tmux-sessionizer in a new tmux window" })
vim.keymap.set("n", "<leader>f", "<cmd>silent !tmux neww tmux-sessionizer.sh<CR>", { desc = "Open tmux-sessionizer in a new tmux window" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over selection without clobbering the register" })

vim.keymap.set({ "n", "v" }, "y", [["+y]], { desc = "Yank to system clipboard" })

vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d", { desc = "Delete without yanking to a register" })

vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Exit insert mode" })

vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Ex mode" })

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search and replace word under cursor (whole buffer)" })
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make current file executable" })

-- Telescope (wrapped in functions so the plugin is only required on keypress)
vim.keymap.set("n", "<leader>pf", function() require("telescope.builtin").find_files() end,
    { desc = "Telescope: find files" })
vim.keymap.set("n", "<C-p>", function() require("telescope.builtin").git_files() end,
    { desc = "Telescope: find git-tracked files" })
vim.keymap.set("n", "<leader>ps", function()
    require("telescope.builtin").grep_string({ search = vim.fn.input("Grep > ") })
end, { desc = "Telescope: grep for a string" })

-- Harpoon
vim.keymap.set("n", "<leader>a", function() require("harpoon.mark").add_file() end,
    { desc = "Harpoon: add current file" })
vim.keymap.set("n", "<C-e>", function() require("harpoon.ui").toggle_quick_menu() end,
    { desc = "Harpoon: toggle quick menu" })
vim.keymap.set("n", "<leader>1", function() require("harpoon.ui").nav_file(1) end, { desc = "Harpoon: go to file 1" })
vim.keymap.set("n", "<leader>2", function() require("harpoon.ui").nav_file(2) end, { desc = "Harpoon: go to file 2" })
vim.keymap.set("n", "<leader>3", function() require("harpoon.ui").nav_file(3) end, { desc = "Harpoon: go to file 3" })
vim.keymap.set("n", "<leader>4", function() require("harpoon.ui").nav_file(4) end, { desc = "Harpoon: go to file 4" })

-- Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle undo tree" })

-- Fugitive
vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Open git status (fugitive)" })

-- LSP: buffer-local, set only where a language server has attached.
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local function opts(desc)
            return { buffer = event.buf, desc = "LSP: " .. desc }
        end

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("go to definition"))
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("hover documentation"))
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts("workspace symbols"))
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts("show line diagnostics"))
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts("code action"))
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts("list references"))
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts("rename symbol"))
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts("signature help"))
        vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts("next diagnostic"))
        vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts("previous diagnostic"))
    end,
})
