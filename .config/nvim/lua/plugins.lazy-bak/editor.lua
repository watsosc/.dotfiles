return {
	"tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
	"tpope/vim-rhubarb",
	"tpope/vim-unimpaired",
	"tpope/vim-repeat",
	"mattn/emmet-vim",
	{
		"folke/trouble.nvim",
		cmd = { "Trouble" },
		opts = {
			modes = {
				lsp = {
					win = { position = "right" },
				},
			},
		},
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
			{ "<leader>cs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols (Trouble)" },
			{ "<leader>cS", "<cmd>Trouble lsp toggle<cr>",                      desc = "LSP references/definitions/... (Trouble)" },
			{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location List (Trouble)" },
			{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix List (Trouble)" },
			{
				"[q",
				function()
					if require("trouble").is_open() then
						require("trouble").prev({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cprev)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Previous Trouble/Quickfix Item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						require("trouble").next({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cnext)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Next Trouble/Quickfix Item",
			},
		},
	},
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
	{
		"echasnovski/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({ n_lines = 500 })

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- Operator-style: s{motion}{char}
			-- - siw)  surround inner word with parens  → (word)
			-- - siw"  surround inner word with quotes  → "word"
			-- - ss)   surround current line with parens
			-- - ds)   delete surrounding parens
			-- - cs)"  change surrounding ) to "
			-- In visual mode: select text, then s{char}
			require("mini.surround").setup({
				n_lines = 500,
				mappings = {
					add = "s",            -- s{motion}{char} — overrides bare 's' (was cl)
					delete = "ds",         -- ds{char}
					replace = "cs",        -- cs{old}{new}
					find = "sf",
					find_left = "sF",
					highlight = "sh",
					update_n_lines = "sn",
				},
			})

			require("mini.pairs").setup()
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			sync_root_with_cwd = true,
			disable_netrw = true,
			hijack_cursor = true,
			hijack_directories = {
				enable = true,
				auto_open = true,
			},
			update_focused_file = {
				enable = true,
				update_cwd = true,
			},
			sort = {
				sorter = "case_sensitive",
			},
			view = {
				width = 30,
				adaptive_size = true,
				side = "left",
			},
			renderer = {
				root_folder_label = false,
				highlight_git = true,
				indent_markers = { enable = true },
				icons = {
					glyphs = {
						default = "",
						symlink = "",
						folder = {
							arrow_open = "",
							arrow_closed = "",
							default = "",
							open = "",
							empty = "",
							empty_open = "",
							symlink = "",
							symlink_open = "",
						},
						git = {
							unstaged = "",
							staged = "S",
							unmerged = "",
							renamed = "➜",
							untracked = "U",
							deleted = "",
							ignored = "◌",
						},
					},
				},
			},
			diagnostics = {
				enable = true,
				show_on_dirs = true,
				icons = {
					hint = "",
					info = "",
					warning = "",
					error = "",
				},
			},
			filters = {
				dotfiles = true,
			},
		},
		keys = {
			{ "<C-n>",     vim.cmd.NvimTreeToggle },
			{ "<leader>n", vim.cmd.NvimTreeFindFile },
		},
		init = function()
			-- Open nvim-tree when opening a directory
			vim.api.nvim_create_autocmd("VimEnter", {
				callback = function(data)
					-- Check if the argument is a directory
					local directory = vim.fn.isdirectory(data.file) == 1
					if not directory then
						return
					end

					-- Change to the directory
					vim.cmd.cd(data.file)

					-- Open nvim-tree
					require("nvim-tree.api").tree.open()

					-- Close the invalid buffer that was created
					local bufnr = data.buf
					if vim.api.nvim_buf_is_valid(bufnr) then
						vim.api.nvim_buf_delete(bufnr, { force = true })
					end
				end,
			})
		end,
	},
	{
		"stevearc/aerial.nvim",
		opts = {
			on_attach = function(bufnr)
				vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
				vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
			end,
			layout = {
				min_width = 0.1,
				max_width = 0.2,
			},
		},
		keys = {
			{ "<leader>co", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial" },
		},
	},
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		vscode = false,
		opts = {
			modes = {
				-- Keep native f/F/t/T motions; flash is on gs/gS instead
				char = {
					enabled = false,
				},
			},
		},
		keys = {
			-- gs = flash jump (s is now mini.surround; f/F remain native find-char motions)
			{ "gs", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Jump" },
			{ "gS", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
		},
	},
	{ -- Useful plugin to show you pending keybinds.
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts_extend = { "spec" },
		opts = {
			icons = {
				-- set icon mappings to true if you have a Nerd Font
				mappings = vim.g.have_nerd_font,
				-- If you are using a Nerd Font: set icons.keys to an empty table which will use the
				-- default whick-key.nvim defined Nerd Font icons, otherwise define a string table
				keys = vim.g.have_nerd_font and {} or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					C = "<C-…> ",
					M = "<M-…> ",
					D = "<D-…> ",
					S = "<S-…> ",
					CR = "<CR> ",
					Esc = "<Esc> ",
					ScrollWheelDown = "<ScrollWheelDown> ",
					ScrollWheelUp = "<ScrollWheelUp> ",
					NL = "<NL> ",
					BS = "<BS> ",
					Space = "<Space> ",
					Tab = "<Tab> ",
					F1 = "<F1>",
					F2 = "<F2>",
					F3 = "<F3>",
					F4 = "<F4>",
					F5 = "<F5>",
					F6 = "<F6>",
					F7 = "<F7>",
					F8 = "<F8>",
					F9 = "<F9>",
					F10 = "<F10>",
					F11 = "<F11>",
					F12 = "<F12>",
				},
			},

			-- Document existing key chains
			spec = {
				{ "<leader>c", group = "[C]ode",     mode = { "n", "x" } },
				{ "<leader>d", group = "[D]ocument" },
				{ "<leader>g", group = "[G]it" },
				{ "<leader>r", group = "[R]ename" },
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>w", group = "[W]orkspace" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "[H]arpoon" },
				{ "<leader>x", group = "Trouble" },
				{ "<leader>z", group = "[Z]en" },
				{ "<leader>u", group = "[U]ndo" },
			},
		},
	},
}
