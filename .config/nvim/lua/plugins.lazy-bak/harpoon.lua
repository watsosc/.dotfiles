return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		opts = {
			menu = {
				width = vim.api.nvim_win_get_width(0) - 4,
			},
			settings = {
				save_on_toggle = true,
			},
		},
		keys = function()
			local keys = {
				{
					"<leader>ha",
					function()
						require("harpoon"):list():add()
					end,
					desc = "[H]arpoon [A]dd File",
				},
				{
					"<leader>hm",
					function()
						local harpoon = require("harpoon")
						harpoon.ui:toggle_quick_menu(harpoon:list())
					end,
					desc = "[H]arpoon Quick [M]enu",
				},
			}

			for i = 1, 5 do
				table.insert(keys, {
					"<leader>h" .. i,
					function()
						require("harpoon"):list():select(i)
					end,
					desc = "Harpoon to File " .. i,
				})
			end
			return keys
		end,
	},
}
