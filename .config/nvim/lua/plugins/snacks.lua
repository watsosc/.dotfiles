return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			indent = { enabled = true },
			input = { enabled = true },
			bigfile = { enabled = true },
			notifier = { enabled = true },
			quickfile = { enabled = true },
			scope = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = true },
			words = { enabled = true },
			picker = { 
				enabled = true,
				sources = {
					files = {
						hidden = false,
						ignored = true,
						exclude = { "**/*.rbi" },
					},
					grep = {
						exclude = { "**/*.rbi" },
					},
				},
			},
		},
		keys = {
			{ "<leader>?", function() Snacks.picker.recent() end, desc = "[?] Find recently opened files" },
			{ "<leader>/", function() Snacks.picker.grep_buffers() end, desc = "[/] Fuzzily search in current buffer" },
			{ "<leader>sh", function() Snacks.picker.help() end, desc = "[S]earch [H]elp" },
			{ "<leader>sk", function() Snacks.picker.keymaps() end, desc = "[S]earch [K]eymaps" },
			{ "<leader>sf", function() Snacks.picker.files() end, desc = "[S]earch [F]iles" },
			{ "<leader>sw", function() Snacks.picker.grep_word() end, desc = "[S]earch Current [W]ord" },
			{ "<leader>sg", function() Snacks.picker.grep() end, desc = "[S]earch by [G]rep" },
			{ "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "[S]earch [D]iagnostics" },
			{ "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "[S]earch Buffer [D]iagnostics" },
			{ "<leader>sr", function() Snacks.picker.resume() end, desc = "[S]earch [R]esume" },
			{ "<leader>s.", function() Snacks.picker.recent() end, desc = "[S]earch Recent Files" },
			{ "<leader>stb", function() Snacks.picker.git_branches() end, desc = "[S]earch [G]it [B]ranches" },
			{ "<leader>stc", function() Snacks.picker.git_log() end, desc = "[S]earch [G]it [C]ommits" },
			{ "<leader>sts", function() Snacks.picker.git_status() end, desc = "[S]earch [G]it [S]tatus" },
		},
	},
	{
		"numToStr/Comment.nvim",
		opts = {},
	},
}
