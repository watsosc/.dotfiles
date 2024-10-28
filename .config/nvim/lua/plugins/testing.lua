local g = vim.g

g["test#strategy"] = "neovim"

return {
	{
		"vim-test/vim-test",
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
			"haydenmeade/neotest-jest",
			"mrcjkb/neotest-haskell",
			"vim-test/vim-test",
			"nvim-neotest/neotest-vim-test",
		},
		opts = function()
			return {
				adapters = {
					require("neotest-jest")({
						jestCommand = "yarn test -- --watch",
					}),
					require("neotest-haskell"),
					require("neotest-vim-test")({
						ignore_filetypes = { "typescript", "javascript", "tsx", "haskell" },
					}),
				},
			}
		end,
		keys = {
			{ "<leader>ty", "<cmd>lua require('neotest').summary.toggle()<cr>", desc = "[T]est Summar[y]" },
			{ "<leader>tt", "<cmd>lua require('neotest').run.run()<cr>", desc = "[T]est Neares[t]" },
			{ "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", desc = "[T]est [F]ile" },
			{ "<leader>ts", "<cmd>lua require('neotest').run.stop()<cr>", desc = "[T]est [S]top" },
			{ "<leader>td", "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>", desc = "[T]est [D]ebug" },
			{ "<leader>ta", "<cmd>lua require('neotest').run.attach()<cr>", desc = "[T]est [A]ttach" },
			{
				"<leader>to",
				"<cmd>lua require('neotest').output_panel.toggle({ last_run = true })<cr>",
				desc = "[T]est [O]pen Panel",
			},
		},
	},
}
