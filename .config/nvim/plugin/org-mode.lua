vim.pack.add({ "https://github.com/nvim-orgmode/orgmode" })

-- Setup orgmode
require("orgmode").setup({
	org_agenda_files = "~/org/**/*",
	org_default_notes_file = "~/org/refile.org",
	org_capture_templates = {
		t = {
			description = "Task",
			template = "* TODO %?\n  %u",
		},
		f = {
			description = "Food diary",
			template = "\n* %<%Y-%m-%d %A>\n- Breakfast :: %?\n- Lunch ::\n- Dinner ::\n- Snack ::\n- Meal ::",
			target = "~/org/food-diary/food-diary.org",
			prepend = true,
		},
	},
})

-- Experimental LSP support
vim.lsp.enable("org")
