-- 11-copilot.lua: only loaded when ~/.config/github-copilot exists
local gh = function(x) return 'https://github.com/' .. x end

local config_home = vim.env.XDG_CONFIG_HOME or vim.fn.expand('~/.config')
if vim.fn.isdirectory(config_home .. '/github-copilot') == 0 then return end

vim.pack.add({
  gh('zbirenbaum/copilot.lua'),
  gh('CopilotC-Nvim/CopilotChat.nvim'),
})

require('copilot').setup({
  copilot_node_command = vim.fn.expand('~/.nvm/versions/node/v22.18.0/bin/node'),
  suggestion = {
    auto_trigger = true,
    keymap       = { accept = '<C-j>' },
  },
})

local user = vim.env.USER or 'User'
user = user:sub(1, 1):upper() .. user:sub(2)

require('CopilotChat').setup({
  auto_insert_mode = true,
  question_header  = '  ' .. user .. ' ',
  answer_header    = '  Copilot ',
  window           = { width = 0.4 },
})

-- Hide copilot inline suggestions when blink.cmp menu is open
vim.api.nvim_create_autocmd('User', {
  pattern  = 'BlinkCmpCompletionMenuOpen',
  callback = function()
    require('copilot.suggestion').dismiss()
    vim.b.copilot_suggestion_hidden = true
  end,
})
vim.api.nvim_create_autocmd('User', {
  pattern  = 'BlinkCmpCompletionMenuClose',
  callback = function() vim.b.copilot_suggestion_hidden = false end,
})

vim.keymap.set({ 'n', 'v' }, '<leader>oa', function() require('CopilotChat').toggle() end,  { desc = 'Toggle (CopilotChat)' })
vim.keymap.set({ 'n', 'v' }, '<leader>ox', function() require('CopilotChat').reset() end,   { desc = 'Clear (CopilotChat)' })
vim.keymap.set({ 'n', 'v' }, '<leader>oq', function()
  local input = vim.fn.input('Quick Chat: ')
  if input ~= '' then require('CopilotChat').ask(input) end
end, { desc = 'Quick Chat (CopilotChat)' })
vim.api.nvim_create_autocmd('BufEnter', {
  pattern  = 'copilot-chat',
  callback = function()
    vim.opt_local.relativenumber = false
    vim.opt_local.number         = false
    vim.keymap.set('i', '<C-s>', '<CR>', { buffer = true, desc = 'Submit Prompt', remap = true })
  end,
})
