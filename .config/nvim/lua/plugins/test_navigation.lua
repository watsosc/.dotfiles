-- Add test navigation with ]t and [t
return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      local test_patterns = {
        -- JavaScript/TypeScript test patterns
        javascript = {
          test_pattern = "^%s*[%w%.]+%s*%(.-function", -- it(), test(), describe() with function
          test_function = "^%s*[%w%.]+%s*%(.-function", -- Same for functions
        },
        typescript = {
          test_pattern = "^%s*[%w%.]+%s*%(.-function", -- Same as JavaScript
          test_function = "^%s*[%w%.]+%s*%(.-function",
        },
        ruby = {
          test_pattern = "^%s*def%s+test_",
          test_function = "^%s*def%s+test_", 
        },
        rust = {
          test_pattern = "#%[test%]",
          test_function = "#%[test%]",
        },
        lua = {
          test_pattern = "^%s*[%w%.]+%s*%(.-function", -- it(), describe() patterns from Busted
          test_function = "^%s*[%w%.]+%s*%(.-function",
        },
      }
      
      -- Helper function to find test patterns
      local function find_test(direction)
        local filetype = vim.bo.filetype
        local patterns = test_patterns[filetype]
        
        if not patterns then
          vim.notify("No test patterns defined for filetype: " .. filetype, vim.log.levels.WARN)
          return
        end
        
        local pattern = patterns.test_pattern
        local current_line = vim.fn.line('.')
        local line_count = vim.fn.line('$')
        
        if direction == "next" then
          for i = current_line + 1, line_count do
            local line_text = vim.fn.getline(i)
            if line_text:match(pattern) then
              vim.cmd('normal! ' .. i .. 'G^')
              return true
            end
          end
        else -- previous
          for i = current_line - 1, 1, -1 do
            local line_text = vim.fn.getline(i)
            if line_text:match(pattern) then
              vim.cmd('normal! ' .. i .. 'G^')
              return true
            end
          end
        end
        
        vim.notify("No " .. direction .. " test found", vim.log.levels.INFO)
        return false
      end
      
      -- Set up keymaps
      vim.keymap.set("n", "]t", function() find_test("next") end, { desc = "Next test" })
      vim.keymap.set("n", "[t", function() find_test("previous") end, { desc = "Previous test" })
    end,
  }
}