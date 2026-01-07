-- 03-git.lua
local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
  gh('lewis6991/gitsigns.nvim'),
  gh('tpope/vim-fugitive'),
  gh('ThePrimeagen/git-worktree.nvim'),
})

require('gitsigns').setup({
  signs = {
    add          = { text = '+' },
    change       = { text = '~' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local map = function(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end
    map('n', '<leader>gb', function() gs.blame_line({ full = true }) end)
  end,
})

require('git-worktree').setup()

local km = vim.keymap
km.set('n', '<leader>gt', ':G<CR>',                    { desc = '[G]it S[t]atus' })
km.set('n', '<leader>gB', ':G branch<CR>',             { desc = '[G]it [B]ranches' })
km.set('n', '<leader>gd', ':DiffviewFileHistory %<CR>', { desc = '[G]it [D]iff file' })
km.set('n', '<leader>gc', ':G commit<CR>',             { desc = '[G]it [C]ommit' })
km.set('n', '<leader>gp', ':G push<CR>',               { desc = '[G]it [P]ush' })
km.set('n', '<leader>ga', ':G add --all',              { desc = '[G]it Add [A]ll' })
km.set('n', '<leader>gl', ':GBrowse<CR>',              { desc = '[G]ithub [L]ink' })

km.set('n', '<leader>gs', function()
  Snacks.picker.git_status({
    prompt = 'Stage Files (Tab=select, s=stage, u=unstage)',
    actions = {
      files = {
        ['s'] = function(picker, items)
          for _, item in ipairs(items) do vim.fn.system({'git','add','--',item.file}) end
          vim.notify('Staged '..#items..' file(s)', vim.log.levels.INFO)
          picker:refresh()
        end,
        ['u'] = function(picker, items)
          for _, item in ipairs(items) do vim.fn.system({'git','reset','HEAD','--',item.file}) end
          vim.notify('Unstaged '..#items..' file(s)', vim.log.levels.INFO)
          picker:refresh()
        end,
        ['<cr>'] = function(picker, items)
          for _, item in ipairs(items) do vim.fn.system({'git','add','--',item.file}) end
          vim.notify('Staged '..#items..' file(s)', vim.log.levels.INFO)
          picker:refresh()
        end,
      },
    },
  })
end, { desc = '[G]it [S]tage files' })

km.set('n', '<leader>gwc', function()
  local dev_trees = require('user.dev_trees')
  local branch = vim.fn.systemlist('git rev-parse --abbrev-ref HEAD')[1]
  local name
  if branch == 'main' or branch == 'master' then
    name = vim.fn.input('Branch name: ')
    if name == '' then print('Branch name required'); return end
  else
    name = branch:gsub('/', '-')
  end
  dev_trees.create_dev_worktree(name, (branch == 'main' or branch == 'master') and name or branch)
end, { desc = '[G]it [W]orktree [C]reate' })

km.set('n', '<leader>gws', function()
  local dt = require('user.dev_trees')
  dt.pick_worktree(function(name) dt.switch_to_dev_worktree(name) end)
end, { desc = '[G]it [W]orktree [S]witch' })

km.set('n', '<leader>gwd', function()
  local dt = require('user.dev_trees')
  local cwd = vim.fn.getcwd()
  dt.pick_worktree(
    function(name) dt.delete_dev_worktree(name, true) end,
    function(name)
      if name == 'root' then return false end
      local p = dt.get_dev_worktree_path(name)
      return p and p.worktree_path ~= cwd
    end
  )
end, { desc = '[G]it [W]orktree [D]elete' })

km.set('n', '<leader>gwl', function()
  require('user.dev_trees').list_worktrees_picker()
end, { desc = '[G]it [W]orktree [L]ist' })
