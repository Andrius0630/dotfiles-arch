vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")


vim.keymap.set("n", "J", "mzJ`z")
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

-- tmux-sessionizer
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer.sh<CR>")
vim.keymap.set("n", "<leader>f", "<cmd>silent !tmux neww tmux-sessionizer.sh<CR>")
-- vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux neww tmux-sessionizer.sh -s 0<CR>")
-- vim.keymap.set("n", "<M-t>", "<cmd>silent !tmux neww tmux-sessionizer.sh -s 1<CR>")
-- vim.keymap.set("n", "<M-n>", "<cmd>silent !tmux neww tmux-sessionizer.sh -s 2<CR>")
-- vim.keymap.set("n", "<M-s>", "<cmd>silent !tmux neww tmux-sessionizer.sh -s 3<CR>")

vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set({ "n", "v" }, "y", [["+y]])

vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d")

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
