-- --
-- return { -- override blink.cmp plugin
--   "Saghen/blink.cmp",
--   dependencies = {
--     {
--       "giuxtaposition/blink-cmp-copilot",
--     },
--   },
--   opts = {
--     sources = {
--       default = { "lsp", "path", "snippets", "buffer", "copilot" },
--       providers = {
--         -- copilot = { score_offset = 5 },
--         copilot = {
--           name = "Copilot",
--           module = "blink-cmp-copilot",
--           score_offset = 100,
--           asnyc = true,
--         },
--         path = { score_offset = 3 },
--         lsp = { score_offset = 0 },
--         snippets = { score_offset = -1 },
--         buffer = { score_offset = -3 },
--       },
--     },
--   },
-- }
return {
  "saghen/blink.cmp",
  dependencies = {
    {
      "giuxtaposition/blink-cmp-copilot",
    },
  },
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "copilot" },
      providers = {
        copilot = {
          name = "copilot",
          module = "blink-cmp-copilot",
          score_offset = 100,
          async = true,
        },
      },
    },
  },
}
