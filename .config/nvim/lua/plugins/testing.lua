return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'antoinemadec/FixCursorHold.nvim',
      'haydenmeade/neotest-jest',
      'mrcjkb/neotest-haskell',
    },
    opts = function()
      return {
        adapters = {
          require 'neotest-jest' {
            jestCommand = 'npm test -- --watch',
          },
          require 'neotest-haskell' {
            build_tools = { 'stack', 'cabal' },
            frameworks = { 'tasty', 'hspec', 'sydtest' },
          },
        },
      }
    end,
    keys = {
      { '<leader>tw', "<cmd>lua require('neotest').run.run()<cr>" },
      { '<leader>tf', "<cmd>lua require('neotest').run.run(vim.fn.expand(' % '))<cr>" },
      { '<leader>ts', "<cmd>lua require('neotest').run.stop()<cr>" },
      { '<leader>ta', "<cmd>lua require('neotest').run.attach()<cr>" },
      { '<leader>to', "<cmd>lua require('neotest').output_panel.toggle({ last_run = true })<cr>" },
    },
  },
}
