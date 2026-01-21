vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<C-m>", "I- <Esc>")
vim.keymap.set("v", "<C-m>", ":norm I- <cr><Esc>")

vim.keymap.set("v", "<C-t>", ":s/\\v[.;]\\s*\\r?$//e<CR>")

vim.keymap.set("v", "<C-b>", ":s/\\v^- \\zs([^.:;]*[.:;])/**\\1**/e<CR>")

vim.keymap.set("v", "s", "S", { remap = true })

vim.g.VM_mouse_mappings = 1
-- vim.g["surround_" .. string.byte('b')] = "**\r**"

-- Stay in visual mode while indenting
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")
