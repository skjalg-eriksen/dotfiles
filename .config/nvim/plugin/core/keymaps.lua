-- buffers
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", {
	desc = "Save buffer",
})

vim.keymap.set("n", "<leader>q", "<cmd>bd<cr>", {
	desc = "Close buffer",
})

vim.keymap.set("n", "<leader>QQ", "<cmd>qall!<cr>", {
	desc = "Force quit Neovim",
})

-- User interface
vim.keymap.set("n", "<leader>uw", "<cmd>setlocal wrap!<cr>", {
	desc = "Toggle Wordwrap",
})

-- Editing
vim.keymap.set("n", "U", "<C-r>", {
	desc = "Redo",
})

-- disable shift movement
vim.keymap.set({ "n", "v", "i" }, "<S-Up>", "<Up>")
vim.keymap.set({ "n", "v", "i" }, "<S-Down>", "<Down>")
vim.keymap.set({ "n", "v", "i" }, "<S-Left>", "<Left>")
vim.keymap.set({ "n", "v", "i" }, "<S-Right>", "<Right>")

-- Norwegian characters that work reliably through tmux and terminal emulators.
vim.keymap.set("i", "<C-k>a", "å", { desc = "Insert å" })
vim.keymap.set("i", "<C-k>A", "Å", { desc = "Insert Å" })
vim.keymap.set("i", "<C-k>o", "ø", { desc = "Insert ø" })
vim.keymap.set("i", "<C-k>O", "Ø", { desc = "Insert Ø" })
vim.keymap.set("i", "<C-k>q", "æ", { desc = "Insert æ" })
vim.keymap.set("i", "<C-k>Q", "Æ", { desc = "Insert Æ" })
vim.keymap.set("i", "<C-g>a", "å", { desc = "Insert å" })
vim.keymap.set("i", "<C-g>A", "Å", { desc = "Insert Å" })
vim.keymap.set("i", "<C-g>o", "ø", { desc = "Insert ø" })
vim.keymap.set("i", "<C-g>O", "Ø", { desc = "Insert Ø" })
vim.keymap.set("i", "<C-g>q", "æ", { desc = "Insert æ" })
vim.keymap.set("i", "<C-g>Q", "Æ", { desc = "Insert Æ" })
