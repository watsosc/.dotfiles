return {
	{
		-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
		-- used for completion, annotations and signatures of Neovim apis
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"tpope/vim-rails",
	},
	{ "Bilal2453/luvit-meta", lazy = true },
	{
		"neovim/nvim-lspconfig",
		version = "*",
		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			{ "williamboman/mason-lspconfig.nvim" }, -- v2: automatic_enable replaces handlers
			"saghen/blink.cmp",
			"onsails/lspkind.nvim",
			"nvimtools/none-ls.nvim",
			"jay-babu/mason-null-ls.nvim",
			{
				"pmizio/typescript-tools.nvim",
				ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
				dependencies = { "nvim-lua/plenary.nvim" },
				config = function()
					-- lspconfig.util is accessed directly (not the deprecated framework)
					local root_pattern = require("lspconfig.util").root_pattern
					require("typescript-tools").setup({
						settings = {
							tsserver_max_memory = 10240,
							root_dir = root_pattern("package.json"),
						},
						on_attach = function(client)
							client.server_capabilities.documentFormattingProvider = false
							client.server_capabilities.documentFormattingRangeProvider = false
						end,
					})
				end,
			},
			-- haskell-tools.nvim is configured as a standalone plugin
			-- in lua/plugins/haskell.lua — it manages its own LSP lifecycle for HLS.
		},
		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("<leader>e", vim.diagnostic.open_float, "Open [D]iagnostic float")
					map("<leader>en", vim.diagnostic.goto_next, "Open [D]iagnostic [N]ext")
					map("<leader>ep", vim.diagnostic.goto_prev, "Open [D]iagnostic [P]rev")

					map("<leader>f", function()
						require("conform").format({ async = true, lsp_format = "fallback" })
					end, "[F]ormat current buffer")

					map("gd", function() Snacks.picker.lsp_definitions() end, "[G]oto [D]efinition")
					map("gr", function() Snacks.picker.lsp_references() end, "[G]oto [R]eferences")
					map("gI", function() Snacks.picker.lsp_implementations() end, "[G]oto [I]mplementation")
					-- grt is the 0.12 default for type_definition (kept explicit for Snacks picker)
					map("grt", function() Snacks.picker.lsp_type_definitions() end, "[G]oto [T]ype Definition")
					map("<leader>ds", function() Snacks.picker.lsp_symbols() end, "[D]ocument [S]ymbols")
					map("<leader>ws", function() Snacks.picker.lsp_symbols({ workspace = true }) end, "[W]orkspace [S]ymbols")
					map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("<leader>ea", vim.lsp.buf.code_action, "[E]rror [A]ction", { "n", "x" })
					-- gD = declaration (e.g. C header); grt = type definition
					map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					-- Pull diagnostics for the entire workspace (requires server support)
					map("<leader>wd", vim.lsp.buf.workspace_diagnostics, "[W]orkspace [D]iagnostics")

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			-- Broadcast blink.cmp capabilities to every server via the '*' wildcard config.
			-- nvim-lspconfig v2 loads server defaults from lsp/<name>.lua in the runtimepath;
			-- vim.lsp.config merges on top of those defaults before the server starts.
			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				require("blink.cmp").get_lsp_capabilities()
			)
			vim.lsp.config("*", { capabilities = capabilities })

			-- Server-specific overrides (merged with lsp/<name>.lua defaults from nvim-lspconfig)
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
						diagnostics = { globals = { "vim" } },
					},
				},
			})

			vim.lsp.config("jsonls", {
				settings = {
					json = {
						validate = { enable = true },
						format = { enable = true },
					},
				},
			})

			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"graphql",
					"html",
					"eslint",
					"jsonls",
					"stylelint_lsp",
				},
				-- v2 API: automatically calls vim.lsp.enable() for every installed server.
				-- ruby_lsp/sorbet are managed by ruby.lua; hls by haskell-tools.nvim.
				automatic_enable = {
					exclude = { "ruby_lsp", "sorbet", "hls" },
				},
			})

			require("mason-null-ls").setup({
				ensure_installed = {},
				automatic_installation = false,
				handlers = {},
			})
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.ktlint,
					null_ls.builtins.diagnostics.ktlint,
				},
			})
		end,
	},
}
