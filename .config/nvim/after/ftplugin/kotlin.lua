-- Kotlin-specific settings
vim.bo.expandtab = true
vim.bo.shiftwidth = 4
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.textwidth = 100

-- Add key mappings for Kotlin-specific features
local map = function(keys, func, desc)
  vim.keymap.set("n", keys, func, { buffer = true, desc = desc })
end

-- Example mappings for Kotlin specific actions
map("<leader>kr", function() vim.lsp.buf.code_action() end, "Kotlin: [R]un Code Actions")
map("<leader>kp", function() vim.lsp.buf.format({ async = true }) end, "Kotlin: Format with ktlint")
map("<leader>kt", "<cmd>!./gradlew test<CR>", "Kotlin: Run Tests")

-- Enable inlay hints for Kotlin if supported by language server
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(true)
    end
  end,
  buffer = 0,
})