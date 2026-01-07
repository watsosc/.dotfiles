return {
	{
		"vim-test/vim-test",
		config = function()
			-- Use neovim_sticky to reuse same terminal for all test runs
			vim.g["test#strategy"] = "neovim_sticky"

			-- Open terminal split at bottom
			vim.g["test#neovim#term_position"] = "belowright"

			-- Note: For debugging tests, use neotest with <leader>td
			-- vim-test is kept for quick test runs without debugging
		end,
	},
	{
		"nvim-neotest/neotest",
		lazy = true,
		event = "BufAdd */*test*/",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"nvim-neotest/neotest-plenary",
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
			"haydenmeade/neotest-jest",
			"zidhuss/neotest-minitest", -- For Rails minitest
			"olimorris/neotest-rspec", -- For RSpec
			"vim-test/vim-test",
		},
		config = function()
			require("neotest").setup({
				discovery = {
					enabled = false, -- Disable auto-discovery for performance
				},
				adapters = {
					require("neotest-jest")({
						jestCommand = "yarn test -- --watch",
					}),
					require("neotest-minitest"),
					require("neotest-rspec"),
				},
				icons = {
					passed = "✓",
					running = "⟳",
					failed = "✗",
					skipped = "○",
					unknown = "?",
				},
				-- Fix the sign display issue
				diagnostic = {
					enabled = false  -- Disable diagnostic signs to avoid confusion
				},
				-- Configure floating windows with borders
				floating = {
					border = "rounded",
					max_height = 0.8,
					max_width = 0.8,
					options = {}
				},
				-- Output window configuration
				output = {
					enabled = true,
					open_on_run = true,  -- Auto-open output when tests run
				},
				output_panel = {
					enabled = true,
					open = "botright split | resize 15"  -- Open at bottom with specific size
				},
				-- Disable status signs in gutter to avoid red X confusion
				status = {
					enabled = true,
					virtual_text = false,
					signs = false,  -- Disable signs in gutter
				},
			})

			-- Note: For debugging to work, you need the 'debug' gem in your Gemfile:
			-- gem "debug", ">= 1.0.0", group: [:development, :test]
			-- This is included by default in Rails 7+ applications

			-- Clear any existing signs when neotest loads
			vim.fn.sign_unplace("neotest")
		end,
		keys = {
			{ "<leader>ty", "<cmd>lua require('neotest').summary.toggle()<cr>", desc = "[T]est Summar[y]" },
			{
				"<leader>tt",
				function()
					require("neotest").run.run()
					require("neotest").output.open({ enter = false })  -- Auto-open output
				end,
				desc = "[T]est Neares[t]",
			},
			{
				"<leader>tf",
				function()
					require("neotest").run.run(vim.fn.expand("%"))
					require("neotest").output.open({ enter = false })  -- Auto-open output
				end,
				desc = "[T]est [F]ile",
			},
			{ "<leader>ts", "<cmd>lua require('neotest').run.stop()<cr>", desc = "[T]est [S]top" },
			{
				"<leader>td",
				function()
					-- Save file first, then run with DAP strategy
					-- Use noautocmd to avoid triggering formatters during debug
					vim.cmd("noautocmd write")
					require("neotest").run.run({ strategy = "dap" })
				end,
				desc = "[T]est [D]ebug",
			},
			{ "<leader>ta", "<cmd>lua require('neotest').run.attach()<cr>", desc = "[T]est [A]ttach" },
			{
				"<leader>to",
				function()
					require("neotest").output.open({ enter = true })
				end,
				desc = "[T]est [O]utput",
			},
		},
	},
}
