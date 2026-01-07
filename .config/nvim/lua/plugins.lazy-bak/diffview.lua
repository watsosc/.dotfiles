return {
  {
    'sindrets/diffview.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    keys = {
      { '<leader>dv', '<cmd>DiffviewOpen<cr>',  desc = 'Open [D]iff[V]iew for git' },
      { '<leader>dc', '<cmd>DiffviewClose<cr>', desc = '[D]iffview for git [C]lose' }
    },
  }
}
