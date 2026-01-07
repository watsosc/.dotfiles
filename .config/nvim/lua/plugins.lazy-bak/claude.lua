-- Simple integration with Claude for Neovim that opens dev claude in a terminal
return {
	{
		"folke/which-key.nvim",
		optional = true,
		opts = {
			defaults = {
				["<leader>c"] = { name = "+Claude" },
			},
		},
	},
	{
		dir = vim.fn.stdpath("config") .. "/lua/user/claude", -- Local plugin directory
		name = "claude.nvim",
		config = function()
			-- Create our claude command handler
			local M = {}

			-- Open Claude in a terminal
			function M.open_claude()
				-- Create a split on the right side
				vim.cmd("botright vnew")
				vim.cmd("vertical resize 100")

				-- Open terminal with dev claude
				vim.cmd("terminal claude")

				-- Set terminal buffer options
				local buf = vim.api.nvim_get_current_buf()
				vim.api.nvim_buf_set_name(buf, "Claude Terminal")
				vim.api.nvim_buf_set_option(buf, "filetype", "terminal")

				-- Set window options
				local win = vim.api.nvim_get_current_win()
				vim.api.nvim_win_set_option(win, "number", false)
				vim.api.nvim_win_set_option(win, "relativenumber", false)
				vim.api.nvim_win_set_option(win, "wrap", true)
				vim.api.nvim_win_set_option(win, "linebreak", true)

				-- Enter terminal mode to start typing immediately
				vim.cmd("startinsert")
				
				-- Add buffer-local keymap to allow Ctrl+H to move to left window
				vim.api.nvim_buf_set_keymap(
					buf,
					"t",  -- terminal mode
					"<C-h>",
					"<C-\\><C-n><C-w>h",
					{ noremap = true, silent = true, desc = "Move to left window" }
				)
				
				-- Add a global keymap for Ctrl+L in normal mode to move to right window and enter terminal mode
				-- This only needs to be set once, not for each buffer
				vim.keymap.set(
					"n", 
					"<C-l>", 
					function()
						local winid = vim.fn.win_getid(vim.fn.winnr("l"))
						if winid ~= 0 then
							vim.fn.win_gotoid(winid)
							local bufname = vim.api.nvim_buf_get_name(0)
							if bufname:match("Claude Terminal") then
								vim.cmd("startinsert")
							end
						else
							vim.cmd("wincmd l")
						end
					end,
					{ noremap = true, silent = true, desc = "Move to right window and enter terminal mode for Claude" }
				)
			end

			-- Register the command
			vim.api.nvim_create_user_command("Claude", M.open_claude, {})

			-- Set up keymap
			vim.keymap.set("n", "<leader>cc", M.open_claude, { desc = "[C]laude [C]hat", silent = true })
		end,
		-- Add keymapping to show up in which-key
		keys = {
			{ "<leader>cc", "<cmd>Claude<CR>", desc = "[C]laude [C]hat" },
		},
	},
}
