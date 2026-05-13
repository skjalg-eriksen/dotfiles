return {
  "ggandor/leap.nvim",
  config = function()
    vim.keymap.set({ "n", "x", "o" }, "s", function()
      require("leap").leap({
        target_windows = { vim.fn.win_getid() },
      })
    end)
  end,
}
