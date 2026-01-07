return {
	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- Disable "format_on_save lsp_fallback" for languages that don't
				-- have a well standardized coding style. You can add additional
				-- languages here or re-enable it for the disabled ones.
				local filetype = vim.bo[bufnr].filetype
				local disable_filetypes = { c = true, cpp = true, ruby = true }
				local lsp_format_opt
				if disable_filetypes[filetype] then
					lsp_format_opt = "never"
				else
					lsp_format_opt = "fallback"
				end
				-- rubocop via bundle exec + shadowenv is slow; give it more time
				local timeout = (filetype == "ruby") and 2000 or 500
				return {
					timeout_ms = timeout,
					lsp_format = lsp_format_opt,
				}
			end,
			formatters_by_ft = {
				haskell = { "fourmolu" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				lua = { "stylua" },
				ruby = { "rubocop" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				yaml = { "prettier" },
				json = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				graphql = { "prettier" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				-- Conform can also run multiple formatters sequentially
				-- python = { "isort", "black" },
				--
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
			formatters = {
				prettier = {
					-- Always prefer the project-local prettier so it picks up
					-- the project's .prettierrc / prettier config and version.
					require_cwd = true,
					prefer_local = "node_modules/.bin",
				},
				rubocop = {
					command = vim.fn.expand("~/.config/nvim/rubocop-formatter-wrapper.sh"),
					args = { "--auto-correct-all", "--format", "quiet", "--stderr", "--stdin", "$FILENAME" },
					stdin = true,
					cwd = function(self, ctx)
						return require("conform.util").root_file({ ".rubocop.yml", "Gemfile" })(self, ctx)
					end,
				},
				shfmt = {
					command = "shfmt",
					args = { "-i", "2", "-bn", "-ci", "-sr", "-kp" },
					stdin = true,
				},
			},
		},
	},
}
