-- 09-langs.lua: language-specific plugins (Python, Haskell, Ruby)
local gh = function(x) return 'https://github.com/' .. x end

-- ── Python ────────────────────────────────────────────────────────────────────
-- Python tools stay optional on machines that do not open Python projects.
do
  local tools = {
    basedpyright = {
      executable = 'basedpyright-langserver',
      install = { 'uv', 'tool', 'install', 'basedpyright' },
    },
    ruff = {
      executable = 'ruff',
      install = { 'uv', 'tool', 'install', 'ruff@latest' },
    },
  }
  local state = {
    path_ready = false,
    path_pending = false,
    path_waiters = {},
    uv_bin_dir = nil,
    prompted = false,
    installing = false,
    enabled = {},
  }

  vim.lsp.config('basedpyright', {
    settings = {
      basedpyright = {
        disableOrganizeImports = true,
        analysis = {
          diagnosticMode = 'openFilesOnly',
        },
      },
    },
  })
  vim.lsp.config('ruff', {
    init_options = {
      settings = {
        configurationPreference = 'filesystemFirst',
      },
    },
  })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('python-lsp-attach', { clear = true }),
    callback = function(event)
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client.name == 'ruff' then
        client.server_capabilities.hoverProvider = false
      end
    end,
  })

  local function flush_path_waiters()
    local waiters = state.path_waiters
    state.path_waiters = {}
    for _, waiter in ipairs(waiters) do waiter() end
  end

  local function add_uv_bin_to_path(callback)
    if state.path_ready then
      if state.uv_bin_dir then
        local path = vim.env.PATH or ''
        if not vim.tbl_contains(vim.split(path, ':', { plain = true }), state.uv_bin_dir) then
          vim.env.PATH = state.uv_bin_dir .. ':' .. path
        end
      end
      callback()
      return
    end

    table.insert(state.path_waiters, callback)
    if state.path_pending then return end
    state.path_pending = true

    if vim.fn.executable('uv') == 0 then
      state.path_ready = true
      state.path_pending = false
      flush_path_waiters()
      return
    end

    vim.system({ 'uv', 'tool', 'dir', '--bin' }, { text = true }, function(result)
      local bin_dir = (result.stdout or ''):gsub('%s+$', '')
      if result.code == 0 and vim.fn.isdirectory(bin_dir) == 1 then
        state.uv_bin_dir = bin_dir
        local path = vim.env.PATH or ''
        if not vim.tbl_contains(vim.split(path, ':', { plain = true }), bin_dir) then
          vim.env.PATH = bin_dir .. ':' .. path
        end
      end
      vim.schedule(function()
        state.path_ready = true
        state.path_pending = false
        flush_path_waiters()
      end)
    end)
  end

  local function missing_tools()
    local missing = {}
    for name, tool in pairs(tools) do
      if vim.fn.executable(tool.executable) == 0 then
        table.insert(missing, name)
      end
    end
    table.sort(missing)
    return missing
  end

  local function enable_available_tools()
    for name, tool in pairs(tools) do
      if not state.enabled[name] and vim.fn.executable(tool.executable) == 1 then
        vim.lsp.enable(name)
        state.enabled[name] = true
      end
    end
  end

  local function install_tools(names, index)
    index = index or 1
    if index > #names then
      state.installing = false
      add_uv_bin_to_path(function()
        enable_available_tools()
      end)
      return
    end

    local name = names[index]
    vim.notify('Installing Python tool: ' .. name, vim.log.levels.INFO, { title = 'Python LSP' })
    vim.system(tools[name].install, { text = true }, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          state.installing = false
          local details = (result.stderr or ''):gsub('%s+$', '')
          vim.notify(
            'uv could not install ' .. name .. (details ~= '' and ': ' .. details or '.'),
            vim.log.levels.ERROR,
            { title = 'Python LSP' }
          )
          return
        end
        install_tools(names, index + 1)
      end)
    end)
  end

  local function install_missing(names)
    if state.installing then return end
    if vim.fn.executable('uv') == 0 then
      vim.notify(
        'Install uv before installing Python tools.',
        vim.log.levels.WARN,
        { title = 'Python LSP' }
      )
      return
    end
    state.installing = true
    install_tools(names)
  end

  local function prompt_for_tools(names)
    if state.prompted or state.installing then return end
    state.prompted = true
    local labels = table.concat(names, ', ')
    local uv_note = vim.fn.executable('uv') == 0 and ' (uv is not installed)' or ''
    vim.ui.select({ 'Install missing tools with uv', 'Skip for this session' }, {
      prompt = 'Python tools missing: ' .. labels .. uv_note,
    }, function(_, index)
      if index == 1 then install_missing(names) end
    end)
  end

  local function check_python_tools()
    if not vim.fs.root(0, {
      'pyproject.toml',
      'pyrightconfig.json',
      'ruff.toml',
      '.ruff.toml',
      'setup.py',
      'setup.cfg',
      'requirements.txt',
      'Pipfile',
      '.git',
    }) then
      return
    end

    add_uv_bin_to_path(function()
      enable_available_tools()
      local missing = missing_tools()
      if #missing > 0 then prompt_for_tools(missing) end
    end)
  end

  vim.api.nvim_create_user_command('PythonToolsInstall', function()
    add_uv_bin_to_path(function()
      local missing = missing_tools()
      if #missing == 0 then
        enable_available_tools()
        vim.notify('Python tools are already installed.', vim.log.levels.INFO, { title = 'Python LSP' })
        return
      end
      install_missing(missing)
    end)
  end, { desc = 'Install missing Python LSP tools with uv' })

  vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('python-lsp-tools', { clear = true }),
    pattern = 'python',
    callback = check_python_tools,
  })
end

-- ── Haskell ──────────────────────────────────────────────────────────────────
-- haskell-tools + snippets: loaded on first Haskell buffer
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  pattern  = { '*.hs', '*.lhs', '*.cabal' },
  once     = true,
  callback = function()
    vim.pack.add({
      gh('mrcjkb/haskell-tools.nvim'),
      gh('mrcjkb/haskell-snippets.nvim'),
    })

    local haskell_snippets = require('haskell-snippets').all
    require('luasnip').add_snippets('haskell', haskell_snippets, { key = 'haskell' })

    vim.g.haskell_tools = {
      hls = {
        cmd = function() return { 'haskell-language-server-wrapper', '--lsp' } end,
        on_attach = function(client, bufnr, ht)
          local opts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set('n', '<space>hl', vim.lsp.codelens.run,         opts)
          vim.keymap.set('n', '<space>hs', ht.hoogle.hoogle_signature,   opts)
          vim.keymap.set('n', '<space>ha', ht.lsp.buf_eval_all,          opts)
          vim.keymap.set('n', '<leader>hr', ht.repl.toggle,              opts)
          vim.keymap.set('n', '<leader>hf', function()
            ht.repl.toggle(vim.api.nvim_buf_get_name(0))
          end, opts)
          vim.keymap.set('n', '<leader>hq', ht.repl.quit, opts)
        end,
        settings = function(project_root)
          local ht = require('haskell-tools')
          return ht.lsp.load_hls_settings(project_root, { settings_file_pattern = 'hls.json' })
        end,
        default_settings = {
          haskell = {
            formattingProvider = 'fourmolu',
            checkProject       = true,
          },
        },
      },
      tools = {
        repl = {
          handler  = 'builtin',
          builtin  = {
            create_repl_window = function(view)
              return view.create_repl_split({ size = vim.o.lines / 3 })
            end,
          },
        },
        codeLens = { autoRefresh = true },
      },
    }
  end,
})

-- ── Ruby ──────────────────────────────────────────────────────────────────────
-- vim-sorbet: loaded on first Ruby buffer
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  pattern  = { '*.rb', '*.rake', 'Gemfile', 'Rakefile', '*.gemspec' },
  once     = true,
  callback = function()
    vim.pack.add({ gh('shopify/vim-sorbet') })
  end,
})

-- Ruby per-project LSP (ruby-lsp + sorbet with shadowenv support)
-- Mirrors the logic that was in lua/plugins/ruby.lua
do
  local util = require('lspconfig.util')

  local function make_capabilities()
    local ok, blink = pcall(require, 'blink.cmp')
    return ok and blink.get_lsp_capabilities() or vim.lsp.protocol.make_client_capabilities()
  end

  local function project_label(root)
    if not root or root == '' then return '?' end
    local label = vim.fs.basename(root)
    return (label and label ~= '' and label ~= '.') and label or root:gsub('[^%w_%-]+', '_')
  end

  local function ruby_cmd(root)
    if vim.fn.executable('shadowenv') == 1 then
      if root and root ~= '' then
        local bin = util.path.join(root, 'bin', 'ruby-lsp')
        if bin and vim.uv.fs_stat(bin) then return { 'shadowenv', 'exec', '--', bin } end
      end
      return { 'shadowenv', 'exec', '--', 'ruby-lsp' }
    end
    if root and root ~= '' then
      local bin = util.path.join(root, 'bin', 'ruby-lsp')
      if bin and vim.uv.fs_stat(bin) then return { bin } end
    end
    return { 'ruby-lsp' }
  end

  local function sorbet_cmd()
    local cmd = { 'bundle', 'exec', 'srb', 'tc', '--lsp' }
    if vim.fn.executable('shadowenv') == 1 then
      return vim.list_extend({ 'shadowenv', 'exec', '--' }, cmd)
    end
    return cmd
  end

  local state = { ruby = {}, sorbet = {}, buffers = {} }

  local function find_root(path, markers)
    if not path or path == '' then return nil end
    local dir = vim.fs.dirname(path)
    if not dir or dir == '' then return nil end
    local found = vim.fs.find(markers, { upward = true, path = dir, stop = vim.uv.os_homedir() })
    if #found == 0 then return nil end
    local root = vim.fs.dirname(found[1])
    if #markers == 1 and markers[1] == 'sorbet/config' then root = vim.fs.dirname(root) end
    return root
  end

  local function attach_existing(client_id, bufnr)
    if not client_id then return false end
    local client = vim.lsp.get_client_by_id(client_id)
    if not client or client:is_stopped() then return false end
    return vim.lsp.buf_attach_client(bufnr, client_id)
  end

  local function ensure(kind, bufnr, filepath, root_markers, cmd_fn, extra_config)
    local root = find_root(filepath, root_markers)
    if not root then return end
    local entry = state.buffers[bufnr] or {}
    entry[kind] = root
    state.buffers[bufnr] = entry
    if attach_existing(state[kind][root], bufnr) then return end

    local gemfile = util.path.join(root, 'Gemfile.lock')
    if not vim.uv.fs_stat(gemfile) then
      vim.schedule(function()
        pcall(vim.notify,
          string.format('%s: Gemfile.lock not found in %s. Run "dev up" first.', kind, project_label(root)),
          vim.log.levels.WARN, { title = kind })
      end)
      return
    end

    local config = vim.tbl_extend('force', {
      name         = string.format('%s(%s)', kind, project_label(root)),
      cmd          = cmd_fn(root),
      root_dir     = root,
      cmd_cwd      = root,
      capabilities = make_capabilities(),
      on_exit = function(code)
        if code == 1 then
          vim.schedule(function()
            pcall(vim.notify,
              string.format('%s exited with error in %s. Try "dev up".', kind, project_label(root)),
              vim.log.levels.ERROR, { title = kind })
          end)
        end
      end,
    }, extra_config or {})

    local client_id = vim.lsp.start(config, {
      bufnr = bufnr,
      reuse_client = function() return false end,
    })
    if client_id then state[kind][root] = client_id end
  end

  local function root_in_use(kind, root)
    for _, info in pairs(state.buffers) do
      if info[kind] == root then return true end
    end
    return false
  end

  local function cleanup(bufnr)
    local entry = state.buffers[bufnr]
    if not entry then return end
    state.buffers[bufnr] = nil
    for _, kind in ipairs({ 'ruby', 'sorbet' }) do
      if entry[kind] and not root_in_use(kind, entry[kind]) then
        local id = state[kind][entry[kind]]
        if id then
          local client = vim.lsp.get_client_by_id(id)
          if client then client:stop() end
        end
        state[kind][entry[kind]] = nil
      end
    end
  end

  local ruby_group = vim.api.nvim_create_augroup('ruby_shadowenv_lsp', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile', 'BufEnter' }, {
    group   = ruby_group,
    pattern = { '*.rb', '*.rake', 'Gemfile', 'Rakefile', '*.gemspec' },
    callback = function(args)
      local fp = vim.api.nvim_buf_get_name(args.buf)
      if fp == '' then return end
      ensure('ruby',   args.buf, fp, { 'Gemfile', '.ruby-lsp', 'config.ru', 'Rakefile', '.git', '.shadowenv.d' }, ruby_cmd)
      ensure('sorbet', args.buf, fp, { 'sorbet/config' },
        function() return sorbet_cmd() end,
        { filetypes = { 'ruby' } })
    end,
  })

  vim.api.nvim_create_autocmd('BufWipeout', {
    group   = ruby_group,
    pattern = { '*.rb', '*.rake', 'Gemfile', 'Rakefile', '*.gemspec' },
    callback = function(args) cleanup(args.buf) end,
  })
end
