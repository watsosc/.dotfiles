-- 01-ui.lua
local gh = function(x) return 'https://github.com/' .. x end

-- Statusline
vim.pack.add({ gh('nvim-lualine/lualine.nvim') })
require('lualine').setup({
  options = {
    theme        = 'catppuccin-mocha',
    icons_enabled = false,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'hostname' },
    lualine_c = { 'branch', { 'filename', path = 1 }, 'aerial' },
    lualine_x = { function() return vim.diagnostic.status() end, 'diff', 'encoding', 'fileformat' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },
  extensions = { 'fugitive' },
})

-- Indent guides
vim.pack.add({ gh('lukas-reineke/indent-blankline.nvim') })
require('ibl').setup({
  indent = { char = '┊' },
  scope  = {
    enabled    = true,
    show_start = false,
    highlight  = { 'Function', 'Label' },
    priority   = 500,
  },
})

-- Word/reference highlights under cursor
vim.pack.add({ gh('RRethy/vim-illuminate') })
require('illuminate').configure({
  providers            = { 'lsp', 'treesitter' },
  delay                = 200,
  large_file_cutoff    = 2000,
  large_file_overrides = { providers = { 'lsp' } },
})

-- Cursor-shape colour modes
vim.pack.add({ gh('mvllow/modes.nvim') })
require('modes').setup()

-- Keybinding popup
vim.pack.add({ gh('folke/which-key.nvim') })
require('which-key').setup({
  icons = {
    mappings = vim.g.have_nerd_font,
    keys     = vim.g.have_nerd_font and {} or {
      Up = '<Up> ', Down = '<Down> ', Left = '<Left> ', Right = '<Right> ',
      C = '<C-…> ', M = '<M-…> ', D = '<D-…> ', S = '<S-…> ',
      CR = '<CR> ', Esc = '<Esc> ', Space = '<Space> ', Tab = '<Tab> ',
      NL = '<NL> ', BS = '<BS> ',
    },
  },
  spec = {
    { '<leader>c', group = '[C]ode',      mode = { 'n', 'x' } },
    { '<leader>d', group = '[D]ocument' },
    { '<leader>l', group = '[L]SP' },
    { '<leader>g', group = '[G]it' },
    { '<leader>r', group = '[R]ename' },
    { '<leader>s', group = '[S]earch' },
    { '<leader>w', group = '[W]orkspace' },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = '[H]arpoon' },
    { '<leader>x', group = 'Trouble' },
    { '<leader>z', group = '[Z]en' },
    { '<leader>u', group = '[U]ndo' },
  },
})

-- Code outline sidebar
vim.pack.add({ gh('stevearc/aerial.nvim') })
require('aerial').setup({
  on_attach = function(bufnr)
    vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', { buffer = bufnr })
    vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', { buffer = bufnr })
  end,
  layout = { min_width = 0.1, max_width = 0.2 },
})
vim.keymap.set('n', '<leader>co', '<cmd>AerialToggle!<CR>', { desc = 'Toggle Aerial' })

-- Motion jump (gs = flash jump; gS = flash treesitter; f/F remain native find-char)
vim.pack.add({ gh('folke/flash.nvim') })
require('flash').setup({
  modes = { char = { enabled = false } },
})
vim.keymap.set({ 'n', 'x', 'o' }, 'gs', function() require('flash').jump() end,           { desc = 'Flash Jump' })
vim.keymap.set({ 'n', 'x', 'o' }, 'gS', function() require('flash').treesitter() end,     { desc = 'Flash Treesitter' })

-- TODO/FIXME/HACK comment highlights
vim.pack.add({ gh('folke/todo-comments.nvim') })
require('todo-comments').setup({ signs = false })

-- Zen / focus mode
vim.pack.add({ gh('folke/zen-mode.nvim') })
-- Don't call setup here; ZenMode is cmd-triggered
vim.keymap.set('n', '<leader>zz', vim.cmd.ZenMode, { desc = 'Toggle Zen Mode' })
