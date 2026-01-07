-- 02-editor.lua
local gh = function(x) return 'https://github.com/' .. x end

-- Tpope essentials
vim.pack.add({
  gh('tpope/vim-sleuth'),      -- auto-detect tabstop/shiftwidth
  gh('tpope/vim-rhubarb'),     -- GBrowse → GitHub
  gh('tpope/vim-unimpaired'),  -- [q ]q bracket mappings
  gh('tpope/vim-repeat'),      -- repeat plugin maps with .
  gh('mattn/emmet-vim'),       -- HTML/CSS expansion
})

-- mini.nvim: ai textobjects, surround, pairs
vim.pack.add({ gh('echasnovski/mini.nvim') })
require('mini.ai').setup({ n_lines = 500 })
require('mini.surround').setup({
  n_lines  = 500,
  mappings = {
    add          = 's',   -- s{motion}{char}  e.g. siw) → (word)
    delete       = 'ds',  -- ds{char}
    replace      = 'cs',  -- cs{old}{new}
    find         = 'sf',
    find_left    = 'sF',
    highlight    = 'sh',
    update_n_lines = 'sn',
  },
})
require('mini.pairs').setup()

-- File tree
vim.pack.add({ gh('nvim-tree/nvim-tree.lua') })
require('nvim-tree').setup({
  sync_root_with_cwd = true,
  disable_netrw      = true,
  hijack_cursor      = true,
  hijack_directories = { enable = true, auto_open = true },
  update_focused_file = { enable = true, update_cwd = true },
  sort    = { sorter = 'case_sensitive' },
  view    = { width = 30, adaptive_size = true, side = 'left' },
  renderer = {
    root_folder_label = false,
    highlight_git     = true,
    indent_markers    = { enable = true },
  },
  diagnostics = {
    enable       = true,
    show_on_dirs = true,
  },
  filters = { dotfiles = true },
})
vim.keymap.set('n', '<C-n>',     vim.cmd.NvimTreeToggle,   { desc = 'NvimTree Toggle' })
vim.keymap.set('n', '<leader>n', vim.cmd.NvimTreeFindFile, { desc = 'NvimTree Find File' })

-- Open nvim-tree when starting with a directory argument
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function(data)
    if vim.fn.isdirectory(data.file) ~= 1 then return end
    vim.cmd.cd(data.file)
    require('nvim-tree.api').tree.open()
    if vim.api.nvim_buf_is_valid(data.buf) then
      vim.api.nvim_buf_delete(data.buf, { force = true })
    end
  end,
})

-- Diagnostics / quickfix panel
vim.pack.add({ gh('folke/trouble.nvim') })
require('trouble').setup({
  modes = { lsp = { win = { position = 'right' } } },
})
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<cr>',              { desc = 'Diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<cr>', { desc = 'Buffer Diagnostics (Trouble)' })
vim.keymap.set('n', '<leader>cs', '<cmd>Trouble symbols toggle<cr>',                  { desc = 'Symbols (Trouble)' })
vim.keymap.set('n', '<leader>cS', '<cmd>Trouble lsp toggle<cr>',                      { desc = 'LSP (Trouble)' })
vim.keymap.set('n', '<leader>xL', '<cmd>Trouble loclist toggle<cr>',                  { desc = 'Location List (Trouble)' })
vim.keymap.set('n', '<leader>xQ', '<cmd>Trouble qflist toggle<cr>',                   { desc = 'Quickfix List (Trouble)' })
vim.keymap.set('n', '[q', function()
  if require('trouble').is_open() then require('trouble').prev({ skip_groups = true, jump = true })
  else local ok, err = pcall(vim.cmd.cprev); if not ok then vim.notify(err, vim.log.levels.ERROR) end end
end, { desc = 'Previous Trouble/Quickfix Item' })
vim.keymap.set('n', ']q', function()
  if require('trouble').is_open() then require('trouble').next({ skip_groups = true, jump = true })
  else local ok, err = pcall(vim.cmd.cnext); if not ok then vim.notify(err, vim.log.levels.ERROR) end end
end, { desc = 'Next Trouble/Quickfix Item' })

-- File bookmarks
vim.pack.add({ { src = gh('ThePrimeagen/harpoon'), version = 'harpoon2' } })
require('harpoon'):setup({
  menu     = { width = vim.api.nvim_win_get_width(0) - 4 },
  settings = { save_on_toggle = true },
})
vim.keymap.set('n', '<leader>ha', function() require('harpoon'):list():add() end,                            { desc = '[H]arpoon [A]dd' })
vim.keymap.set('n', '<leader>hm', function() local h = require('harpoon'); h.ui:toggle_quick_menu(h:list()) end, { desc = '[H]arpoon [M]enu' })
for i = 1, 5 do
  vim.keymap.set('n', '<leader>h' .. i, function() require('harpoon'):list():select(i) end, { desc = 'Harpoon File ' .. i })
end

-- Git diff viewer
vim.pack.add({ gh('sindrets/diffview.nvim') })
vim.keymap.set('n', '<leader>dv', '<cmd>DiffviewOpen<cr>',  { desc = 'Open [D]iff[V]iew' })
vim.keymap.set('n', '<leader>dc', '<cmd>DiffviewClose<cr>', { desc = '[D]iffview [C]lose' })
