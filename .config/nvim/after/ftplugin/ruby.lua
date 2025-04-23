-- Ruby-specific settings

-- Ruby-specific test configuration
vim.g["test#ruby#minitest#options"] = "--verbose"
vim.g["test#ruby#rspec#options"] = "--format documentation"

-- Ruby-specific settings
vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.textwidth = 100

-- Set up additional keymaps specific to Ruby development
local map = function(keys, cmd, desc)
  vim.keymap.set("n", keys, cmd, { buffer = true, desc = desc })
end

-- Ruby-specific keymaps
map("<leader>rc", "<cmd>Econtroller<CR>", "Ruby: Go to [C]ontroller")
map("<leader>rm", "<cmd>Emodel<CR>", "Ruby: Go to [M]odel")
map("<leader>rv", "<cmd>Eview<CR>", "Ruby: Go to [V]iew")
map("<leader>rb", "<cmd>Espec<CR>", "Ruby: Go to [S]pec")

-- Override neotest keymaps with vim-test for Ruby files
map("<leader>tt", "<cmd>TestNearest<CR>", "[T]est Neares[t]")
map("<leader>tf", "<cmd>TestFile<CR>", "[T]est [F]ile")