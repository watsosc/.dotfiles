-- 06-treesitter.lua
local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
  gh('nvim-treesitter/nvim-treesitter'),
  gh('nvim-treesitter/nvim-treesitter-context'),
  gh('nvim-treesitter/nvim-treesitter-textobjects'),
  gh('windwp/nvim-ts-autotag'),
})

require('nvim-treesitter.config').setup({
  ensure_installed = {
    'javascript', 'typescript', 'lua', 'rust', 'luadoc',
    'tsx', 'vim', 'vimdoc', 'html', 'markdown', 'markdown_inline',
    'haskell', 'ruby', 'query',
  },
  sync_install = false,
  auto_install = true,
  indent       = { enable = true },
  highlight    = { enable = true },
  autotag      = { enable = true },
  matchup      = { enable = true },
  incremental_selection = {
    enable  = true,
    keymaps = {
      init_selection    = '<c-space>',
      node_incremental  = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental  = '<bs>',
    },
  },
  textobjects = {
    select = {
      enable    = true,
      lookahead = true,
      keymaps   = {
        ['aa'] = '@parameter.outer', ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',  ['if'] = '@function.inner',
        ['ac'] = '@class.outer',     ['ic'] = '@class.inner',
      },
    },
    move = {
      enable     = true,
      set_jumps  = true,
      goto_next_start = {
        [']v'] = '@function.outer', [']c'] = '@class.outer',
        [']p'] = '@parameter.outer', [']t'] = '@test.outer',
      },
      goto_next_end = {
        [']V'] = '@function.outer', [']C'] = '@class.outer',
        [']P'] = '@parameter.outer', [']T'] = '@test.outer',
      },
      goto_previous_start = {
        ['[v'] = '@function.outer', ['[c'] = '@class.outer',
        ['[p'] = '@parameter.outer', ['[t'] = '@test.outer',
      },
      goto_previous_end = {
        ['[V'] = '@function.outer', ['[C'] = '@class.outer',
        ['[P'] = '@parameter.outer', ['[T'] = '@test.outer',
      },
    },
    swap = {
      enable = true,
      swap_next     = { ['<leader>aw'] = '@parameter.inner' },
      swap_previous = { ['<leader>aW'] = '@parameter.inner' },
    },
  },
})

require('treesitter-context').setup({ max_lines = 3 })

-- After first install, parsers need to be compiled. Run :TSUpdate once.
-- (Subsequent startups reuse compiled .so files from the pack directory.)
local parser_dir = vim.fn.stdpath('data') .. '/site/pack/core/opt/nvim-treesitter/parser'
if vim.fn.isdirectory(parser_dir) == 1 and #vim.fn.glob(parser_dir .. '/*.so', false, true) == 0 then
  vim.notify('nvim-treesitter: run :TSUpdate to compile parsers', vim.log.levels.INFO)
end
