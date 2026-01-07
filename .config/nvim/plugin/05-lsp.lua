-- 05-lsp.lua
local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
  gh('folke/lazydev.nvim'),
  gh('Bilal2453/luvit-meta'),
  gh('neovim/nvim-lspconfig'),
  gh('williamboman/mason.nvim'),
  gh('williamboman/mason-lspconfig.nvim'),
  gh('nvimtools/none-ls.nvim'),
  gh('jay-babu/mason-null-ls.nvim'),
  gh('tpope/vim-rails'),
})

-- lazydev: Lua LSP type annotations for Neovim runtime/config/plugins
require('lazydev').setup({
  library = {
    { path = 'luvit-meta/library', words = { 'vim%.uv' } },
  },
})

-- LspAttach: keymaps and per-buffer LSP features
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('<leader>e',   vim.diagnostic.open_float,  'Open [D]iagnostic float')
    map('<leader>en',  vim.diagnostic.goto_next,   'Open [D]iagnostic [N]ext')
    map('<leader>ep',  vim.diagnostic.goto_prev,   'Open [D]iagnostic [P]rev')

    map('<leader>f', function()
      require('conform').format({ async = true, lsp_format = 'fallback' })
    end, '[F]ormat current buffer')

    map('gd',          function() Snacks.picker.lsp_definitions() end,             '[G]oto [D]efinition')
    map('gr',          function() Snacks.picker.lsp_references() end,              '[G]oto [R]eferences')
    map('gI',          function() Snacks.picker.lsp_implementations() end,         '[G]oto [I]mplementation')
    map('grt',         function() Snacks.picker.lsp_type_definitions() end,        '[G]oto [T]ype Definition')
    map('<leader>ds',  function() Snacks.picker.lsp_symbols() end,                 '[D]ocument [S]ymbols')
    map('<leader>ws',  function() Snacks.picker.lsp_symbols({ workspace = true }) end, '[W]orkspace [S]ymbols')
    map('<leader>rn',  vim.lsp.buf.rename,          '[R]e[n]ame')
    map('<leader>ea',  vim.lsp.buf.code_action,     '[E]rror [A]ction', { 'n', 'x' })
    map('gD',          vim.lsp.buf.declaration,     '[G]oto [D]eclaration')
    map('<leader>wd',  vim.lsp.buf.workspace_diagnostics, '[W]orkspace [D]iagnostics')

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
      local hl_group = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf, group = hl_group, callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf, group = hl_group, callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(e2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = 'kickstart-lsp-highlight', buffer = e2.buf })
        end,
      })
    end

    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- Broadcast blink.cmp capabilities to all servers
vim.lsp.config('*', {
  capabilities = vim.tbl_deep_extend(
    'force',
    vim.lsp.protocol.make_client_capabilities(),
    require('blink.cmp').get_lsp_capabilities()
  ),
})

-- Server-specific overrides
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      completion  = { callSnippet = 'Replace' },
      diagnostics = { globals = { 'vim' } },
    },
  },
})

vim.lsp.config('jsonls', {
  settings = {
    json = {
      validate = { enable = true },
      format   = { enable = true },
    },
  },
})

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = { 'lua_ls', 'graphql', 'html', 'eslint', 'jsonls', 'stylelint_lsp' },
  -- automatic_enable calls vim.lsp.enable() for every Mason-installed server.
  -- ruby_lsp/sorbet managed by ruby.lua; hls managed by haskell-tools.nvim.
  automatic_enable = {
    exclude = { 'ruby_lsp', 'sorbet', 'hls' },
  },
})

require('mason-null-ls').setup({ ensure_installed = {}, automatic_installation = false, handlers = {} })
local null_ls = require('null-ls')
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.ktlint,
    null_ls.builtins.diagnostics.ktlint,
  },
})

-- typescript-tools: lazy-loaded on first TypeScript/JavaScript buffer
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  pattern  = { '*.ts', '*.tsx', '*.js', '*.jsx' },
  once     = true,
  callback = function()
    vim.pack.add({
      gh('nvim-lua/plenary.nvim'), -- ensure available
      gh('pmizio/typescript-tools.nvim'),
    })
    require('typescript-tools').setup({
      settings = {
        tsserver_max_memory = 10240,
        root_dir            = require('lspconfig.util').root_pattern('package.json'),
      },
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider      = false
        client.server_capabilities.documentFormattingRangeProvider = false
      end,
    })
  end,
})
