-- 07-format.lua
-- conform is lazy-loaded on BufWritePre so it doesn't add to cold-start time.
local gh = function(x) return 'https://github.com/' .. x end

vim.api.nvim_create_autocmd({ 'BufWritePre', 'BufReadPre', 'BufNewFile' }, {
  once     = true,
  callback = function()
    vim.pack.add({ gh('stevearc/conform.nvim') })
    require('conform').setup({
      notify_on_error = false,
      format_on_save  = function(bufnr)
        local ft  = vim.bo[bufnr].filetype
        local disable = { c = true, cpp = true, ruby = true }
        local timeout = ft == 'ruby' and 2000 or 500
        return {
          timeout_ms = timeout,
          lsp_format = disable[ft] and 'never' or 'fallback',
        }
      end,
      formatters_by_ft = {
        haskell        = { 'fourmolu' },
        javascript     = { 'prettier' },
        javascriptreact = { 'prettier' },
        lua            = { 'stylua' },
        ruby           = { 'rubocop' },
        typescript     = { 'prettier' },
        typescriptreact = { 'prettier' },
        yaml           = { 'prettier' },
        json           = { 'prettier' },
        css            = { 'prettier' },
        html           = { 'prettier' },
        graphql        = { 'prettier' },
        sh             = { 'shfmt' },
        bash           = { 'shfmt' },
      },
      formatters = {
        prettier = {
          require_cwd  = true,
          prefer_local = 'node_modules/.bin',
        },
        rubocop = {
          command = vim.fn.expand('~/.config/nvim/rubocop-formatter-wrapper.sh'),
          args    = { '--auto-correct-all', '--format', 'quiet', '--stderr', '--stdin', '$FILENAME' },
          stdin   = true,
          cwd     = function(self, ctx)
            return require('conform.util').root_file({ '.rubocop.yml', 'Gemfile' })(self, ctx)
          end,
        },
        shfmt = {
          command = 'shfmt',
          args    = { '-i', '2', '-bn', '-ci', '-sr', '-kp' },
          stdin   = true,
        },
      },
    })
  end,
})
