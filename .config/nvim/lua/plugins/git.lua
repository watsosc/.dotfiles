return {
	{ -- Adds git related signs to the gutter, as well as utilities for managing changes
		"lewis6991/gitsigns.nvim",
		opts = {
			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, opts)
					opts = opts or {}
					opts.buffer = bufnr
					vim.keymap.set(mode, l, r, opts)
				end

				map("n", "<leader>gb", function()
					gs.blame_line({ full = true })
				end)
			end,
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},
	{
		"tpope/vim-fugitive",
		config = function()
			local keymap = vim.keymap

			keymap.set("n", "<leader>gt", ":G<CR>", { desc = "[G]it S[t]atus" })
			keymap.set("n", "<leader>gB", ":G branch<CR>", { desc = "[G]it [B]ranches (select to checkout)" })
			keymap.set("n", "<leader>gd", ":DiffviewFileHistory %<CR>", { desc = "[G]it [D]iff current file" })
			keymap.set("n", "<leader>gs", ":Gwrite<CR>", { desc = "[G]it [S]tage" })
			keymap.set("n", "<leader>gc", ":G commit<CR>", { desc = "[G]it [C]ommit" })
			keymap.set("n", "<leader>gp", ":G push<CR>", { desc = "[G]it [P]ush" })
			keymap.set("n", "<leader>ga", ":G add --all", { desc = "[G]it Add [A]ll" })
			keymap.set("n", "<leader>gl", ":GBrowse<CR>", { desc = "[G]ithub [L]ink" })

			-- Git worktree keymaps
			keymap.set("n", "<leader>gwc", function()
				local dev_trees = require("user.dev_trees")
				local current_branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]

				local tree_name
				if current_branch == "main" or current_branch == "master" then
					-- Prompt for branch name if on main/master
					tree_name = vim.fn.input("Branch name: ")
					if tree_name == "" then
						print("Branch name required when on " .. current_branch)
						return
					end
				else
					-- Sanitize current branch name (convert / to -)
					tree_name = current_branch:gsub("/", "-")
				end

				dev_trees.create_dev_worktree(tree_name, current_branch == "main" and tree_name or current_branch)
			end, { desc = "[G]it [W]orktree [C]reate" })

			keymap.set("n", "<leader>gws", function()
				local dev_trees = require("user.dev_trees")
				dev_trees.pick_worktree(function(tree_name)
					dev_trees.switch_to_dev_worktree(tree_name)
				end)
			end, { desc = "[G]it [W]orktree [S]witch" })

			keymap.set("n", "<leader>gwd", function()
				local dev_trees = require("user.dev_trees")
				local current_path = vim.fn.getcwd()

				dev_trees.pick_worktree(function(tree_name)
					dev_trees.delete_dev_worktree(tree_name, true)
				end, function(tree_name)
					-- Filter out current worktree and root
					if tree_name == "root" then return false end
					local paths = dev_trees.get_dev_worktree_path(tree_name)
					return paths and paths.worktree_path ~= current_path
				end)
			end, { desc = "[G]it [W]orktree [D]elete" })

			keymap.set("n", "<leader>gwl", function()
				local dev_trees = require("user.dev_trees")
				dev_trees.list_worktrees_picker()
			end, { desc = "[G]it [W]orktree [L]ist" })

		end,
	},
	{
		"ThePrimeagen/git-worktree.nvim",
		config = function()
			require("git-worktree").setup()
		end,
	},
}
