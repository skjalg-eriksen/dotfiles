-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize GitHub Copilot
return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function() require("copilot").setup {} end,
}

-- ended up using zbirenbaum/copilot.lua instead of github/copilot.vim
-- as its better integrated with blink.cmp

-- -@type LazySpec
-- return {
--   "github/copilot.vim",
--   config = function(plugin, opts)
--     require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
--     -- add more custom luasnip configuration such as filetype extend or custom snippets
--     local luasnip = require "luasnip"
--     luasnip.filetype_extend("javascript", { "javascriptreact" })
--   end,
--   opts = {
--     -- You can add configuration options here
--     -- For example, to enable or disable certain features
--     suggestion = {
--       enabled = false, -- Enable suggestions
--       auto_trigger = false, -- Automatically trigger suggestions
--       debounce = 100, -- Debounce time in milliseconds
--     },
--     panel = {
--       enabled = false, -- Enable the Copilot panel
--       auto_refresh = true, -- Automatically refresh the panel
--     },
--   },
-- }
