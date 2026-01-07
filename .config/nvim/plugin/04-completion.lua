-- 04-completion.lua
-- Loaded eagerly (not on InsertEnter) because LSP in 05-lsp.lua needs
-- blink.cmp capabilities at config time via vim.lsp.config('*', ...).
local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
  gh('L3MON4D3/LuaSnip'),
  gh('rafamadriz/friendly-snippets'),
  gh('saghen/blink.cmp'),
  gh('onsails/lspkind.nvim'),
})

-- LuaSnip: load vscode-style snippets from friendly-snippets
require('luasnip').setup({ enable_autosnippets = true })
require('luasnip.loaders.from_vscode').lazy_load()

-- Build jsregexp for LuaSnip regex snippets (runs once if not yet built)
local luasnip_path = vim.fn.stdpath('data') .. '/site/pack/core/opt/LuaSnip'
if vim.fn.isdirectory(luasnip_path) == 1
   and vim.fn.filereadable(luasnip_path .. '/build/jsregexp.so') == 0 then
  vim.notify('LuaSnip: building jsregexp (one-time)…', vim.log.levels.INFO)
  vim.fn.jobstart({ 'make', 'install_jsregexp' }, { cwd = luasnip_path })
end

require('blink.cmp').setup({
  keymap = { preset = 'super-tab' },
  fuzzy = { implementation = 'lua' },
  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant        = 'mono',
  },
  completion = {
    accept = { auto_brackets = { enabled = true } },
    menu   = { draw = { treesitter = { 'lsp' } } },
    list   = {
      selection = {
        preselect = function(ctx)
          return ctx.mode == 'cmdline' and 'auto_insert' or 'preselect'
        end,
      },
    },
  },
  snippets = {
    preset = 'luasnip',
    expand = function(s) require('luasnip').lsp_expand(s) end,
    active = function(filter)
      if filter and filter.direction then return require('luasnip').jumpable(filter.direction) end
      return require('luasnip').in_snippet()
    end,
    jump   = function(dir) require('luasnip').jump(dir) end,
  },
  sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
})
