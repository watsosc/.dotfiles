return {
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'catppuccin/nvim',
    config = function()
      require('catppuccin').setup {
        cmp = true,
        fidget = true,
        gitsigns = true,
        illuminate = {
          enabled = true,
          lsp = false,
        },
        mason = true,
        mini = {
          enabled = true,
        },
        nvimtree = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
      }

      vim.cmd 'colorscheme catppuccin-mocha'
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        theme = 'catppuccin',
        icons_enabled = false,
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'hostname' },
        lualine_c = { 'branch', { 'filename', path = 1 }, 'aerial' },
        lualine_x = { 'diff', 'encoding', 'fileformat' }, -- filetype causes lag
        lualine_y = { 'progress' },
        lualine_z = { 'location' },
      },
      extensions = { 'fugitive', 'fzf' },
    },
  },
  {
    'folke/zen-mode.nvim',
    opts = {
      window = {
        width = 120,
        options = {
          number = true,
          relativenumber = true,
        },
      },
    },
    cmd = 'ZenMode',
    keys = {
      { '<leader>zz', vim.cmd.ZenMode, desc = 'Toggle Zen Mode' },
    },
  },
  {
    'RRethy/vim-illuminate',
    config = function()
      require('illuminate').configure {
        providers = { 'lsp', 'treesitter' },
        delay = 200,
        large_file_cutoff = 2000,
        large_file_overrides = {
          providers = { 'lsp' },
        },
      }
    end,
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {
      indent = {
        char = '┊',
      },
      scope = {
        enabled = true,
        show_start = false,
        highlight = { 'Function', 'Label' },
        priority = 500,
      },
    },
  },
  {
    'mvllow/modes.nvim',
    config = function()
      require('modes').setup()
    end,
  },
}
