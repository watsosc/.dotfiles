-- 10-markdown.lua: lazy-loaded on first Markdown buffer
local gh = function(x) return 'https://github.com/' .. x end

vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  pattern  = { '*.md', '*.markdown' },
  once     = true,
  callback = function()
    vim.pack.add({
      gh('MeanderingProgrammer/render-markdown.nvim'),
      gh('iamcco/markdown-preview.nvim'),
    })

    require('render-markdown').setup({
      heading  = { enabled = true, sign = true,
                   icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' } },
      code     = { enabled = true, sign = true, style = 'full', position = 'left',
                   width = 'block', left_pad = 0, right_pad = 0 },
      bullet   = { enabled = true, icons = { '●', '○', '◆', '◇' } },
      checkbox = { enabled = true,
                   unchecked = { icon = '󰄱 ' }, checked = { icon = '󰱒 ' } },
      quote    = { enabled = true, icon = '▋' },
      pipe_table = { enabled = true, style = 'full' },
    })
    vim.keymap.set('n', '<leader>um', '<cmd>RenderMarkdown toggle<cr>', { desc = 'Toggle Markdown Rendering' })

    -- markdown-preview: install its node app once if not present
    local mkdp_path = vim.fn.stdpath('data') .. '/site/pack/core/opt/markdown-preview.nvim'
    if vim.fn.filereadable(mkdp_path .. '/app/index.html') == 0 then
      vim.fn['mkdp#util#install']()
    end
    -- config
    vim.g.mkdp_auto_start     = 0
    vim.g.mkdp_auto_close     = 1
    vim.g.mkdp_refresh_slow   = 0
    vim.g.mkdp_theme          = 'dark'
    vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', { desc = 'Toggle Markdown Preview' })
  end,
})
