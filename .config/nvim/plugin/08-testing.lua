-- 08-testing.lua
local gh = function(x) return 'https://github.com/' .. x end

-- vim-test: quick test runner (always available, lightweight)
vim.pack.add({ gh('vim-test/vim-test') })
vim.g['test#strategy']             = 'neovim_sticky'
vim.g['test#neovim#term_position'] = 'belowright'

-- nvim-dap: debugger (loaded eagerly — only activates when you call a dap command)
vim.pack.add({
  gh('mfussenegger/nvim-dap'),
  gh('rcarriga/nvim-dap-ui'),
  gh('suketa/nvim-dap-ruby'),
})
require('dapui').setup()

local dap = require('dap')
local fn  = vim.fn

fn.sign_define('DapBreakpoint',          { text = '',  texthl = 'debugBreakpoint', linehl = '',      numhl = 'debugBreakpoint' })
fn.sign_define('DapBreakpointCondition', { text = '',  texthl = 'DiagnosticSignWarn', linehl = '', numhl = 'debugBreakpoint' })
fn.sign_define('DapBreakpointRejected',  { text = '',  texthl = 'DiagnosticSignError', linehl = '', numhl = 'debugBreakpoint' })
fn.sign_define('DapLogPoint',            { text = ' ', texthl = 'debugBreakpoint', linehl = '',      numhl = 'debugBreakpoint' })
fn.sign_define('DapStopped',             { text = '',  texthl = 'debugBreakpoint', linehl = 'debugPC', numhl = 'DiagnosticSignError' })

local map = vim.keymap.set
map('n', '<leader>dC', dap.continue,          { desc = 'DAP: Continue' })
map('n', '<leader>db', dap.toggle_breakpoint,  { desc = 'DAP: Toggle breakpoint' })
map('n', '<leader>dB', function() dap.set_breakpoint(fn.input('Breakpoint condition: ')) end, { desc = 'DAP: Set breakpoint' })
map('n', '<leader>do', dap.step_over,          { desc = 'DAP: Step over' })
map('n', '<leader>dO', dap.step_out,           { desc = 'DAP: Step out' })
map('n', '<leader>dn', dap.step_into,          { desc = 'DAP: Step into' })
map('n', '<leader>dN', dap.step_back,          { desc = 'DAP: Step back' })
map('n', '<leader>dr', dap.repl.toggle,        { desc = 'DAP: Toggle REPL' })
map('n', '<leader>dl', dap.run_last,           { desc = 'DAP: Run last' })
map('n', '<leader>du', function() require('dapui').toggle({}) end, { desc = 'DAP: Toggle UI' })
map('n', '<leader>dt', dap.terminate,          { desc = 'DAP: Terminate' })
map('n', '<leader>d.', dap.goto_,             { desc = 'DAP: Go to' })
map('n', '<leader>dh', dap.run_to_cursor,      { desc = 'DAP: Run to cursor' })
map('n', '<leader>de', dap.set_exception_breakpoints, { desc = 'DAP: Exception breakpoints' })
map({ 'n', 'x' }, '<leader>dx', function() require('dapui').eval() end,                          { desc = 'DAP-UI: Eval' })
map('n', '<leader>dX', function() require('dapui').eval(fn.input('expression: '), {}) end,        { desc = 'DAP-UI: Eval expression' })

dap.listeners.after.event_initialized['dapui'] = function()
  require('dapui').open({})
end
dap.listeners.after.event_terminated['dapui'] = function()
  require('dapui').close({})
  vim.cmd('silent! bd! \\[dap-repl]')
end
dap.listeners.before.event_exited['dapui'] = function()
  require('dapui').close({})
  vim.cmd('silent! bd! \\[dap-repl]')
end

dap.adapters.codelldb = {
  type = 'server', port = '${port}',
  executable = { command = 'codelldb', args = { '--port', '${port}' } },
}
dap.adapters.node2 = {
  type = 'executable', command = 'node-debug2-adapter', args = {},
}
dap.configurations.typescript = {{
  type = 'node2', name = 'node attach', request = 'attach',
  program = '${file}', cwd = vim.fn.getcwd(), sourceMaps = true, protocol = 'inspector',
}}
dap.configurations.javascript = dap.configurations.typescript

require('dap-ruby').setup()

-- neotest: lazy-loaded on the first testable filetype.
-- Using FileType (not BufAdd) so it also fires for the buffer nvim is launched with;
-- BufAdd+once previously missed the startup buffer, leaving <leader>t* mappings
-- calling require('neotest') before it was ever loaded.
vim.api.nvim_create_autocmd('FileType', {
  pattern  = { 'ruby', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'lua', 'python' },
  once     = true,
  callback = function()
    vim.pack.add({
      gh('nvim-neotest/neotest'),
      gh('nvim-neotest/neotest-plenary'),
      gh('haydenmeade/neotest-jest'),
      gh('zidhuss/neotest-minitest'),
      gh('olimorris/neotest-rspec'),
      gh('antoinemadec/FixCursorHold.nvim'),
    })
    require('neotest').setup({
      discovery = { enabled = false },
      adapters  = {
        require('neotest-jest')({ jestCommand = 'yarn test -- --watch' }),
        require('neotest-minitest'),
        require('neotest-rspec'),
      },
      icons   = { passed = '✓', running = '⟳', failed = '✗', skipped = '○', unknown = '?' },
      diagnostic = { enabled = false },
      floating   = { border = 'rounded', max_height = 0.8, max_width = 0.8, options = {} },
      output     = { enabled = true, open_on_run = true },
      output_panel = { enabled = true, open = 'botright split | resize 15' },
      status     = { enabled = true, virtual_text = false, signs = false },
    })
    vim.fn.sign_unplace('neotest')
  end,
})

map('n', '<leader>ty', '<cmd>lua require("neotest").summary.toggle()<cr>',    { desc = '[T]est Summar[y]' })
map('n', '<leader>ts', '<cmd>lua require("neotest").run.stop()<cr>',          { desc = '[T]est [S]top' })
map('n', '<leader>ta', '<cmd>lua require("neotest").run.attach()<cr>',        { desc = '[T]est [A]ttach' })
map('n', '<leader>tt', function()
  require('neotest').run.run()
  require('neotest').output.open({ enter = false })
end, { desc = '[T]est Neares[t]' })
map('n', '<leader>tf', function()
  require('neotest').run.run(vim.fn.expand('%'))
  require('neotest').output.open({ enter = false })
end, { desc = '[T]est [F]ile' })
map('n', '<leader>td', function()
  vim.cmd('noautocmd write')
  require('neotest').run.run({ strategy = 'dap' })
end, { desc = '[T]est [D]ebug' })
map('n', '<leader>to', function()
  require('neotest').output.open({ enter = true })
end, { desc = '[T]est [O]utput' })
