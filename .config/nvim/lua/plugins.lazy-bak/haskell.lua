return {
	{
		"mrcjkb/haskell-tools.nvim",
		version = "^4",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
		config = function()
			vim.g.haskell_tools = {
				hls = {
					-- In a nix environment, HLS is provided by the nix shell,
					-- not Mason. This just uses whatever `haskell-language-server-wrapper`
					-- is on PATH (set up by nix develop / nix-shell).
					cmd = function()
						return { "haskell-language-server-wrapper", "--lsp" }
					end,
					on_attach = function(client, bufnr, ht)
						local opts = { noremap = true, silent = true, buffer = bufnr }
						-- Code lenses (HLS relies heavily on these)
						vim.keymap.set("n", "<space>hl", vim.lsp.codelens.run, opts)
						-- Hoogle search for type signature under cursor
						vim.keymap.set("n", "<space>hs", ht.hoogle.hoogle_signature, opts)
						-- Evaluate all code snippets
						vim.keymap.set("n", "<space>ha", ht.lsp.buf_eval_all, opts)
						-- GHCi REPL
						vim.keymap.set("n", "<leader>hr", ht.repl.toggle, opts)
						vim.keymap.set("n", "<leader>hf", function()
							ht.repl.toggle(vim.api.nvim_buf_get_name(0))
						end, opts)
						vim.keymap.set("n", "<leader>hq", ht.repl.quit, opts)
					end,
					-- Load per-project HLS settings from hls.json if present
					settings = function(project_root)
						local ht = require("haskell-tools")
						return ht.lsp.load_hls_settings(project_root, {
							settings_file_pattern = "hls.json",
						})
					end,
					default_settings = {
						haskell = {
							-- Use fourmolu as the formatting provider (standard for nix+cabal)
							formattingProvider = "fourmolu",
							-- Check the whole project on load for better diagnostics
							checkProject = true,
						},
					},
				},
				tools = {
					repl = {
						-- Use cabal repl in nix+cabal projects
						handler = "builtin",
						builtin = {
							create_repl_window = function(view)
								return view.create_repl_split({ size = vim.o.lines / 3 })
							end,
						},
					},
					-- Auto-refresh code lenses
					codeLens = {
						autoRefresh = true,
					},
				},
			}
		end,
	},
}
