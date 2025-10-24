local M = {}

local function get_home_dir()
  return os.getenv("HOME") or ""
end

local function path_exists(path)
  local stat = vim.uv.fs_stat(path)
  return stat ~= nil
end

local function create_directory(path)
  if not path_exists(path) then
    local success = vim.fn.mkdir(path, "p")
    return success == 1
  end
  return true
end

local function is_shopify_world_repo()
  -- Check if we're currently in Shopify's World monorepo
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  if not git_root then return false end

  -- Extract world root from various possible paths
  local possible_world_roots = {}

  -- If git_root is like /Users/seanwatson/world/trees/root/src, extract /Users/seanwatson/world
  local world_from_trees = git_root:match("^(.*)/trees/[^/]+/?.*$")
  if world_from_trees then
    table.insert(possible_world_roots, world_from_trees)
  end

  -- Other possible roots
  table.insert(possible_world_roots, git_root)
  local git_parent = git_root:gsub("/git$", "")
  table.insert(possible_world_roots, git_parent) -- Remove /git suffix if present
  table.insert(possible_world_roots, "/Users/seanwatson/world")   -- Direct path fallback

  for _, root in ipairs(possible_world_roots) do
    local world_markers = {
      root .. "/Shopfile",
      root .. "/.world",
      root .. "/dev.yml",
      root .. "/trees" -- Check for trees directory
    }

    for _, marker in ipairs(world_markers) do
      if path_exists(marker) then
        return true, root
      end
    end
  end

  return false, nil
end

function M.get_dev_worktree_path(tree_name)
  tree_name = tree_name or "root"
  local home = get_home_dir()

  local is_world, world_root = is_shopify_world_repo()

  if is_world then
    -- For Shopify's World monorepo: ~/world/trees/<name>/src/
    local base_path = world_root or (home .. "/world")
    local trees_path = base_path .. "/trees"
    local worktree_path = trees_path .. "/" .. tree_name .. "/src"

    return {
      base_path = base_path,
      trees_path = trees_path,
      worktree_path = worktree_path,
      is_world_repo = true
    }
  else
    -- For regular repositories: <repo_root>/trees/<name>/
    local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
    if not git_root then
      vim.notify("Not in a git repository", vim.log.levels.ERROR)
      return nil
    end

    local trees_path = git_root .. "/trees"
    local worktree_path = trees_path .. "/" .. tree_name

    return {
      base_path = git_root,
      trees_path = trees_path,
      worktree_path = worktree_path,
      is_world_repo = false
    }
  end
end

function M.create_dev_worktree(tree_name, source_branch)
  tree_name = tree_name or "root"
  source_branch = source_branch or "main"

  local paths = M.get_dev_worktree_path(tree_name)
  if not paths then return false end

  -- Create trees directory if it doesn't exist
  if not create_directory(paths.trees_path) then
    vim.notify("Failed to create trees directory: " .. paths.trees_path, vim.log.levels.ERROR)
    return false
  end

  -- Check if worktree already exists
  if path_exists(paths.worktree_path) then
    vim.notify("Worktree " .. tree_name .. " already exists at " .. paths.worktree_path, vim.log.levels.WARN)
    return true
  end

  -- Use git-worktree plugin to create the worktree
  local git_worktree = require("git-worktree")
  return git_worktree.create_worktree(paths.worktree_path, source_branch)
end

function M.delete_dev_worktree(tree_name, force)
  if not tree_name or tree_name == "root" then
    vim.notify("Cannot remove root worktree", vim.log.levels.ERROR)
    return false
  end

  local paths = M.get_dev_worktree_path(tree_name)
  if not paths then return false end

  if not path_exists(paths.worktree_path) then
    vim.notify("Worktree " .. tree_name .. " not found", vim.log.levels.WARN)
    return false
  end

  -- Use git-worktree plugin to delete the worktree
  local git_worktree = require("git-worktree")
  return git_worktree.delete_worktree(paths.worktree_path, force or false)
end

function M.switch_to_dev_worktree(tree_name)
  local paths = M.get_dev_worktree_path(tree_name)
  if not paths then return false end

  if not path_exists(paths.worktree_path) then
    vim.notify("Worktree " .. tree_name .. " not found at " .. paths.worktree_path, vim.log.levels.ERROR)
    return false
  end

  -- Get current relative path, accounting for different worktree structures
  local current_dir = vim.fn.getcwd()
  local relative_path = nil

  -- Try to extract relative path from current worktree structure
  local is_world, _ = is_shopify_world_repo()

  if is_world then
    -- For world repo: extract path after /trees/<name>/src/
    relative_path = current_dir:match("/trees/[^/]+/src/(.+)$")
  else
    -- For regular repo: extract path after /trees/<name>/
    relative_path = current_dir:match("/trees/[^/]+/(.+)$")
  end

  -- Fallback: try extracting relative path from any git root
  if not relative_path then
    local current_git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
    if current_git_root and current_dir:find(current_git_root, 1, true) == 1 then
      relative_path = current_dir:sub(#current_git_root + 2) -- +2 to skip the trailing slash
    end
  end

  -- Use git-worktree plugin to switch to the worktree
  local git_worktree = require("git-worktree")
  local success = git_worktree.switch_worktree(paths.worktree_path)

  -- If switch was successful and we have a relative path, try to navigate to the same location
  if success and relative_path and relative_path ~= "" then
    local target_path = paths.worktree_path .. "/" .. relative_path

    -- Check if the target path exists in the new worktree
    if path_exists(target_path) then
      vim.cmd("cd " .. vim.fn.fnameescape(target_path))
      vim.notify("Switched to worktree " .. tree_name .. " at " .. relative_path, vim.log.levels.INFO)
    else
      vim.notify("Switched to worktree " .. tree_name .. " (subdirectory " .. relative_path .. " not found)", vim.log.levels.INFO)
    end
  elseif success then
    vim.notify("Switched to worktree " .. tree_name, vim.log.levels.INFO)
  end

  return success
end

function M.list_dev_worktrees()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  if not git_root then
    vim.notify("Not in a git repository", vim.log.levels.ERROR)
    return {}
  end

  local git_cmd = string.format("cd %s && git worktree list", vim.fn.shellescape(git_root))
  local result = vim.fn.system(git_cmd)
  local exit_code = vim.v.shell_error

  if exit_code == 0 then
    local lines = vim.split(result, "\n", { trimempty = true })
    local formatted_output = {}

    for _, line in ipairs(lines) do
      -- Extract tree name from path for better display
      local tree_name = nil
      local is_world, _ = is_shopify_world_repo()

      if is_world then
        tree_name = line:match("/trees/([^/]+)/src")
      else
        tree_name = line:match("/trees/([^/]+)")
      end

      if tree_name then
        -- Replace the full path with just the tree name for cleaner display
        local display_line = line:gsub("^[^%s]+", "trees/" .. tree_name)
        table.insert(formatted_output, display_line)
      else
        -- Keep original line if we can't extract tree name (e.g., main worktree)
        table.insert(formatted_output, line)
      end
    end

    return formatted_output
  else
    vim.notify("Failed to list worktrees: " .. result, vim.log.levels.ERROR)
    return {}
  end
end

function M.get_available_dev_trees()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  if not git_root then return {} end

  -- Get all worktrees from git
  local git_cmd = string.format("cd %s && git worktree list --porcelain", vim.fn.shellescape(git_root))
  local result = vim.fn.system(git_cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 then
    return {}
  end

  local trees = {}
  local lines = vim.split(result, "\n", { trimempty = true })
  local is_world, _ = is_shopify_world_repo()

  for i, line in ipairs(lines) do
    if line:match("^worktree ") then
      local current_worktree = line:gsub("^worktree ", "")

      -- Look ahead to see if this worktree has a branch (skip bare repos)
      local has_branch = false
      local j = i + 1
      while j <= #lines and lines[j] ~= "" and not lines[j]:match("^worktree ") do
        if lines[j]:match("^branch ") then
          has_branch = true
          break
        end
        j = j + 1
      end

      -- Only process worktrees that have branches (skip bare repos)
      if has_branch and current_worktree then
        local tree_name = nil

        if is_world then
          -- For world repo: extract from ~/world/trees/<name>/src
          tree_name = current_worktree:match("/trees/([^/]+)/src/?$")
        else
          -- For regular repo: extract from <repo>/trees/<name>
          tree_name = current_worktree:match("/trees/([^/]+)/?$")
        end

        if tree_name then
          table.insert(trees, tree_name)
        end
      end
    end
  end

  -- Remove duplicates and sort
  local unique_trees = {}
  local seen = {}
  for _, tree in ipairs(trees) do
    if not seen[tree] then
      seen[tree] = true
      table.insert(unique_trees, tree)
    end
  end

  table.sort(unique_trees)
  return unique_trees
end

function M.pick_worktree(action_fn, filter_fn)
  local trees = M.get_available_dev_trees()

  if #trees == 0 then
    vim.notify("No dev trees found", vim.log.levels.WARN)
    return
  end

  -- Filter trees if filter function provided
  if filter_fn then
    local filtered_trees = {}
    for _, tree in ipairs(trees) do
      if filter_fn(tree) then
        table.insert(filtered_trees, tree)
      end
    end
    trees = filtered_trees
  end

  if #trees == 0 then
    vim.notify("No available trees to select", vim.log.levels.WARN)
    return
  end

  -- Create picker items - simpler format
  local items = {}
  for _, tree in ipairs(trees) do
    local paths = M.get_dev_worktree_path(tree)
    local display_text = tree

    -- Add path info for better context
    if paths then
      display_text = string.format("%-15s %s", tree, paths.worktree_path)
    end

    table.insert(items, display_text)
  end

  -- Use vim.ui.select for a simpler approach
  vim.ui.select(items, {
    prompt = "Select Worktree:",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if choice and action_fn then
      -- Extract tree name from the formatted display
      local tree_name = choice:match("^(%S+)")
      action_fn(tree_name)
    end
  end)
end

function M.list_worktrees_picker()
  local worktrees = M.list_dev_worktrees()

  if #worktrees == 0 then
    vim.notify("No worktrees found", vim.log.levels.WARN)
    return
  end

  vim.ui.select(worktrees, {
    prompt = "Git Worktrees:",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    -- Just viewing, no action needed
  end)
end

return M