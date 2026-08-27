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
  gh('shopify-playground/hover-hints.nvim'),
})

-- lazydev: Lua LSP type annotations for Neovim runtime/config/plugins
require('lazydev').setup({
  library = {
    { path = 'luvit-meta/library', words = { 'vim%.uv' } },
  },
})

require('hover-hints').setup({
  filetypes = { 'ruby' },
  code_only = true,
  prefix = '  ',
  max_width = 100,
  keymap = '<leader>lh',
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
    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
      map('<leader>li', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, '[L]SP: Toggle [I]nlay Hints')
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

-- typescript-tools: TS/JS LSP driving the project-local tsserver directly
-- (ts_ls/vtsls can't be used here — global npm installs are blocked in this env).
--
-- Loaded on FileType so vim.lsp.enable can attach to the launch buffer and later
-- TS/JS buffers through the native Neovim 0.12 LSP configuration.
--
-- If TS LSP still fails to attach after a plugin update, pin typescript-tools to a
-- known-good revision in the vim.pack.add call below, e.g.:
--   { src = gh('pmizio/typescript-tools.nvim'), version = '<commit-sha>' }
local function find_working_npm_dir()
  for _, dir in ipairs(vim.split(vim.env.PATH or '', ':', { plain = true })) do
    local npm = vim.fs.joinpath(dir, 'npm')
    if vim.fn.executable(npm) == 1 then
      vim.fn.system({ npm, 'root', '-g' })
      if vim.v.shell_error == 0 then return dir end
    end
  end
end

vim.api.nvim_create_autocmd('FileType', {
  pattern  = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  once     = true,
  callback = function()
    vim.pack.add({
      gh('nvim-lua/plenary.nvim'), -- ensure available
      gh('pmizio/typescript-tools.nvim'),
    })

    local npm_dir = find_working_npm_dir()
    if npm_dir then vim.env.PATH = npm_dir .. ':' .. vim.env.PATH end
    require('typescript-tools').setup({
      settings = {
        tsserver_max_memory = 10240,
        tsserver_file_preferences = {
          includeInlayParameterNameHints = 'all',
          includeInlayParameterNameHintsWhenArgumentMatchesName = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayVariableTypeHintsWhenTypeMatchesName = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
      on_attach  = function(client)
        client.server_capabilities.documentFormattingProvider      = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
    })
  end,
})
