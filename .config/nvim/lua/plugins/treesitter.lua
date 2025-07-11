return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-context',
        opts = {
          max_lines = 3,
        },
      },
      'nvim-treesitter/nvim-treesitter-textobjects',
      'windwp/nvim-ts-autotag',
      {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        opts = {
          check_ts = true,
        },
      },
    },
    build = function()
      require('nvim-treesitter.install').update { with_sync = true }()
    end,
    opts = {
      ensure_installed = {
        'javascript',
        'typescript',
        'lua',
        'rust',
        'luadoc',
        'tsx',
        'vim',
        'vimdoc',
        'html',
        'markdown',
        'haskell',
        'ruby',
        'kotlin',
        'query',
      },
      sync_install = false,
      auto_install = true,
      indent = {
        enable = true,
      },
      matchup = {
        enable = true,
      },
      highlight = { enable = true },
      autotag = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<bs>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']v'] = '@function.outer',
            [']c'] = '@class.outer',
            [']p'] = '@parameter.outer',
            [']t'] = '@test.outer',
          },
          goto_next_end = {
            [']V'] = '@function.outer',
            [']C'] = '@class.outer',
            [']P'] = '@parameter.outer',
            [']T'] = '@test.outer',
          },
          goto_previous_start = {
            ['[v'] = '@function.outer',
            ['[c'] = '@class.outer',
            ['[p'] = '@parameter.outer',
            ['[t'] = '@test.outer',
          },
          goto_previous_end = {
            ['[V'] = '@function.outer',
            ['[C'] = '@class.outer',
            ['[P'] = '@parameter.outer',
            ['[T'] = '@test.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>aw'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>aW'] = '@parameter.inner',
          },
        },
      },
    },
    config = function(_, opts)
      -- Configure Treesitter
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
}
