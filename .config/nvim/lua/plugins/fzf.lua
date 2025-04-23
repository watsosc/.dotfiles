return {
	{
		"junegunn/fzf",
		build = "./install --bin",
	},
	{
		"ibhagwan/fzf-lua",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		version = "*",
		opts = function()
			local config = require("fzf-lua.config")
			local actions = require("fzf-lua.actions")

			config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
			config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
			config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
			config.defaults.keymap.fzf["ctrl-x"] = "jump"
			config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
			config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
			config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
			config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"

			return {
				fzf_colors = true,
				fzf_opts = {
					["--no-scrollbar"] = true,
				},
				defaults = {
					-- formatter = "path.filename_first",
					formatter = "path.dirname_first",
					no_header = true,
				},
				winopts = {
					width = 0.8,
					height = 0.8,
					row = 0.5,
					col = 0.5,
					preview = {
						scrollchars = { "┃", "" },
					},
				},
				files = {
					cwd_prompt = false,
					actions = {
						["alt-i"] = { actions.toggle_ignore },
						["alt-h"] = { actions.toggle_hidden },
					},
				},
				grep = {
					actions = {
						["alt-i"] = { actions.toggle_ignore },
						["alt-h"] = { actions.toggle_hidden },
					},
				},
				lsp = {
					symbols = {
						symbol_hl = function(s)
							return "TroubleIcon" .. s
						end,
						symbol_fmt = function(s)
							return s:lower() .. "\t"
						end,
						child_prefix = false,
					},
				},
			}
		end,
		config = function(_, opts)
			require("fzf-lua").setup(opts)
		end,
		keys = {
			{ "<leader>?", "<CMD>lua require('fzf-lua').oldfiles()<CR>", desc = "[?] Find recently opened files" },
			{
				"<leader>/",
				"<CMD>lua require('fzf-lua').lgrep_curbuf()<CR>",
				desc = "[/] Fuzzily search in current buffer",
			},
			{ "<leader>sh", "<CMD>lua require('fzf-lua').helptags()<CR>", desc = "[S]earch [H]elp" },
			{ "<leader>sk", "<CMD>lua require('fzf-lua').keymaps()<CR>", desc = "[S]earch [K]eymaps" },
			{ "<leader>sf", "<CMD>lua require('fzf-lua').files()<CR>", desc = "[S]earch [F]iles" },
			{ "<leader>sw", "<CMD>lua require('fzf-lua').grep_cword()<CR>", desc = "[S]earch Current [W]ord" },
			{
				"<leader>sW",
				"<CMD>lua require('fzf-lua').grep_cword( { root = false })<CR>",
				desc = "[S]earch Current [W]ord (cwd)",
			},
			{ "<leader>sg", "<CMD>lua require('fzf-lua').live_grep({file_type_query=true})<CR>", desc = "[S]earch by [G]rep" },
			{
				"<leader>sG",
				"<CMD>lua require('fzf-lua').live_grep( { root = false })<CR>",
				desc = "[S]earch by [G]rep (cwd)",
			},
			{ "<leader>sd", "<CMD>lua require('fzf-lua').diagnostics_document()<CR>", desc = "[S]earch [D]iagnostics" },
			{
				"<leader>sD",
				"<CMD>lua require('fzf-lua').diagnostics_workspace()<CR>",
				desc = "[S]earch Workspace [D]iagnostics",
			},
			{ "<leader>sr", "<CMD>lua require('fzf-lua').resume()<CR>", desc = "[S]earch [R]esume" },
			{ "<leader>s.", "<CMD>lua require('fzf-lua').oldfiles()<CR>", desc = "[S]earch Recent Files" },
			{ "<leader>stb", "<CMD>lua require('fzf-lua').git_branches()<CR>", desc = "[S]earch [G]it [B]ranches" },
			{ "<leader>stc", "<CMD>lua require('fzf-lua').git_commits()<CR>", desc = "[S]earch [G]it [C]ommits" },
			{ "<leader>sts", "<CMD>lua require('fzf-lua').git_stash()<CR>", desc = "[S]earch [G]it [S]tash" },
		},
	},
}
