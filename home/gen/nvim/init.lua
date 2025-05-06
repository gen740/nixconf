require('gen740.plugins')
require('gen740.options')
require('gen740.keymaps')
require('gen740.lsps')
-- vim.api.nvim_create_user_command('ShowLSPs', function()
--   local clients = vim.lsp.get_clients { bufnr = 0 }
--   if #clients == 0 then
--     print('No active LSPs for this buffer.')
--     return
--   end
--   for _, client in ipairs(clients) do
--     print('Active LSP: ' .. client.name)
--   end
-- end, {})
