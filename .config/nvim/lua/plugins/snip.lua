return {
	{
		"L3M0N4D3/LuaSnip",
		dependencies = {
			{
				"rafamadriz/friendly-snippets",
				config = function()
					require("luasnip.loaders.from_vscode").lazy_load()
				end,
			},
		},
		event = { "BufReadPost", "BufNewFile" },
		build = (function()
			return "make install_jsregexp"
		end)(),
		config = function()
			require("luasnip").setup({ enable_autosnippets = true })
		end,
	},
	{
		"mrcjkb/haskell-snippets.nvim",
		dependencies = { "L3MON4D3/LuaSnip" },
		ft = { "haskell", "lhaskell", "cabal", "cabalproject" },
		config = function()
			local haskell_snippets = require("haskell-snippets").all
			require("luasnip").add_snippets("haskell", haskell_snippets, { key = "haskell" })
		end,
	},
}
