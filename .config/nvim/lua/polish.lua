if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- local wk = require('which-key')
--
-- local mappings = {
--     { "v-J", desc = "move lines Up" },
--     { "v-K", desc = "move lines Down" },
-- }
-- wk.add(mappings)

-- escape suspend keybinds
vim.keymap.set("n", "<C-z>", "<nop>")
vim.keymap.set("v", "<C-z>", "<nop>")

-- move lines up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
