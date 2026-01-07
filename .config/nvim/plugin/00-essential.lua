-- 00-essential.lua
-- Must load first: foundational deps, colorscheme, and snacks (hooks statuscolumn/notifier/etc.)
local gh = function(x) return 'https://github.com/' .. x end

-- Shared deps used by many plugins
vim.pack.add({
  gh('nvim-lua/plenary.nvim'),
  gh('nvim-tree/nvim-web-devicons'),
  gh('nvim-neotest/nvim-nio'), -- dep of neotest + nvim-dap-ui
})

-- Snacks: priority=1000 equivalent — must come before any plugin that uses Snacks.*
vim.pack.add({ gh('folke/snacks.nvim') })
require('snacks').setup({
  indent      = { enabled = true },
  input       = { enabled = true },
  bigfile     = { enabled = true },
  notifier    = { enabled = true },
  quickfile   = { enabled = true },
  scope       = { enabled = true },
  scroll      = { enabled = true },
  statuscolumn = { enabled = true },
  words       = { enabled = true },
  picker = {
    enabled = true,
    sources = {
      files = { hidden = false, ignored = true, exclude = { '**/*.rbi' } },
      grep  = { exclude = { '**/*.rbi' } },
    },
  },
})

local sp = function(key, fn, desc)
  vim.keymap.set('n', key, fn, { desc = desc })
end
sp('<leader>?',   function() Snacks.picker.recent() end,           '[?] Find recently opened files')
sp('<leader>/',   function() Snacks.picker.grep_buffers() end,     '[/] Fuzzily search in current buffer')
sp('<leader>sh',  function() Snacks.picker.help() end,             '[S]earch [H]elp')
sp('<leader>sk',  function() Snacks.picker.keymaps() end,          '[S]earch [K]eymaps')
sp('<leader>sf',  function() Snacks.picker.files() end,            '[S]earch [F]iles')
sp('<leader>sw',  function() Snacks.picker.grep_word() end,        '[S]earch Current [W]ord')
sp('<leader>sg',  function() Snacks.picker.grep() end,             '[S]earch by [G]rep')
sp('<leader>sd',  function() Snacks.picker.diagnostics() end,      '[S]earch [D]iagnostics')
sp('<leader>sD',  function() Snacks.picker.diagnostics_buffer() end, '[S]earch Buffer [D]iagnostics')
sp('<leader>sr',  function() Snacks.picker.resume() end,           '[S]earch [R]esume')
sp('<leader>s.',  function() Snacks.picker.recent() end,           '[S]earch Recent Files')
sp('<leader>stb', function() Snacks.picker.git_branches() end,     '[S]earch Git [B]ranches')
sp('<leader>stc', function() Snacks.picker.git_log() end,          '[S]earch Git [C]ommits')
sp('<leader>sts', function() Snacks.picker.git_status() end,       '[S]earch Git [S]tatus')

-- Shadowenv: priority=100 equivalent — load early for correct env before LSP starts
vim.pack.add({ gh('Shopify/shadowenv.vim') })
vim.api.nvim_create_autocmd({ 'DirChanged', 'VimEnter' }, {
  callback = function() vim.cmd('silent! ShadowenvHook') end,
})

-- Colorscheme: load early so subsequent plugins inherit correct highlight groups
vim.pack.add({ gh('catppuccin/nvim') })
require('catppuccin').setup({
  integrations = {
    aerial          = true,
    cmp             = true,
    flash           = true,
    fzf             = true,
    gitsigns        = true,
    illuminate      = { enabled = true, lsp = false },
    lsp_trouble     = true,
    mason           = true,
    mini            = true,
    neotest         = true,
    nvimtree        = true,
    snacks          = true,
    treesitter      = true,
    treesitter_context = true,
    which_key       = true,
  },
})
vim.cmd('colorscheme catppuccin-mocha')
