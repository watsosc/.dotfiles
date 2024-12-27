return {
	{ -- Autocompletion
		"saghen/blink.cmp",
		version = "*",
		event = "InsertEnter",
		dependencies = {
			"L3MON4D3/LuaSnip",
			"folke/lazydev.nvim",
		},
		opts = {
			keymap = {
				preset = "default",
				["<C-y>"] = { "select_and_accept" },
			},
			appearance = {
				use_nvim_cmp_as_default = true,
				nerd_font_variant = "mono",
			},
			snippets = {
				expand = function(snippet)
					require("luasnip").lsp_expand(snippet)
				end,
				active = function(filter)
					if filter and filter.direction then
						return require("luasnip").jumpable(filter.direction)
					end
					return require("luasnip").in_snippet()
				end,
				jump = function(direction)
					require("luasnip").jump(direction)
				end,
			},
			sources = {
				default = { "lazydev", "lsp", "path", "luasnip", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
				},
			},
		},
		opts_extend = { "sources.default" },
	},
}
