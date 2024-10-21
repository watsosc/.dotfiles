return {
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
			"haydenmeade/neotest-jest",
			"mrcjkb/neotest-haskell",
		},
		opts = function()
			return {
				adapters = {
					require("neotest-jest")({
						jestCommand = "npm test -- --watch",
					}),
					require("neotest-haskell")({
						build_tools = { "stack", "cabal" },
						frameworks = { "tasty", "hspec", "sydtest" },
					}),
				},
			}
		end,
		keys = {
			{ "<leader>tw", "<cmd>lua require('neotest').run.run()<cr>", desc = "Run all tests" },
			{ "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand(' % '))<cr>", desc = "Run this test" },
			{ "<leader>ts", "<cmd>lua require('neotest').run.stop()<cr>", desc = "Stop running tests" },
			{ "<leader>tl", "<cmd>lua require('neotest').run.last()<cr>", desc = "Run last test" },
			{ "<leader>tr", "<cmd>lua require('neotest').run.repeat()<cr>", desc = "Repeat last test" },
			{ "<leader>td", "<cmd>lua require('neotest').run.debug()<cr>", desc = "Debug test" },
			{ "<leader>ta", "<cmd>lua require('neotest').run.attach()<cr>", desc = "Attach to test" },
			{ "<leader>tv", "<cmd>lua require('neotest').run.visit()<cr>", desc = "Visit test" },
			{
				"<leader>to",
				"<cmd>lua require('neotest').output_panel.toggle({ last_run = true })<cr>",
				desc = "Toggle output panel",
			},
		},
	},
}
