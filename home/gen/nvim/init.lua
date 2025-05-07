vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.signcolumn = 'yes'
vim.opt.list = true
vim.opt.listchars = { tab = '»·', trail = '·', extends = '›', precedes = '‹' }
vim.opt.pumheight = 15
vim.opt.completeopt = { 'fuzzy', 'menu', 'menuone', 'noselect' }
vim.opt.cmdheight = 0

vim.g.netrw_banner = 0
vim.g.netrw_hide = 1
vim.g.netrw_list_hide = [[\(^\.\/\=$\)\|\(^\.\.\/\=$\)\|\(^\.DS_Store$\)]]
vim.g.netrw_sort_sequence = [[^[^\.].*\/$,^\..*\/$,^[^\.][^\/]*$,^\.[^\/]*$]]

vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.scrolloff = 0
  end,
})

vim.cmd('colorscheme github_dark_colorblind')
vim.api.nvim_set_hl(0, 'StatusLineNC', { bg = '#30363d', fg = '#0d1117' })
vim.api.nvim_set_hl(0, 'Whitespace', { fg = '#8b949e' })

vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    pcall(vim.treesitter.start)
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'netrw',
  callback = function()
    vim.wo.number = true
    vim.wo.relativenumber = true
  end,
})

local global_keymap = {
  i = {
    ['<c-l>'] = '<cmd>Copilot suggestion next<cr>',
    ['<c-h>'] = '<cmd>Copilot suggestion prev<cr>',
    ['<c-t>'] = '<cmd>Copilot suggestion accept<cr>',
    ['<m-w>'] = '<cmd>Copilot suggestion accept_word<cr>',
    ['<m-l>'] = '<cmd>Copilot suggestion accept_line<cr>',
  },
  n = {
    ['-'] = "<cmd>execute 'Explore ' . fnameescape(fnamemodify(expand('%:p'), ':h'))<cr>",
    ['<m-f>'] = function()
      vim.lsp.buf.format {
        async = false,
        filter = function(client)
          return (client.name ~= 'tsserver' and client.name ~= 'vtsls' and client.name ~= 'texlab')
        end,
      }
    end,

    --- LSP
    ['<space>e'] = vim.diagnostic.open_float,
    ['[d'] = function()
      vim.diagnostic.jump { count = -1, float = true }
    end,
    [']d'] = function()
      vim.diagnostic.jump { count = 1, float = true }
    end,
    ['<space>lc'] = vim.diagnostic.setloclist,
    ['<space>lo'] = vim.lsp.buf.outgoing_calls,
    ['<space>li'] = vim.lsp.buf.incoming_calls,
    ['gD'] = vim.lsp.buf.declaration,
    ['gd'] = vim.lsp.buf.definition,
    ['gr'] = vim.lsp.buf.references,
    ['K'] = vim.lsp.buf.hover,
    ['gi'] = vim.lsp.buf.implementation,
    ['<C-k>'] = vim.lsp.buf.signature_help,
    ['<space>D'] = vim.lsp.buf.type_definition,
    ['<space>rn'] = vim.lsp.buf.rename,
    ['<space>ca'] = function()
      vim.lsp.buf.code_action { apply = true }
    end,
  },
  x = {
    ['<space>p'] = '"_dP',
  },
  t = {
    ['<esc><esc>'] = '<C-\\><C-n>',
  },
}

for mode, keys in pairs(global_keymap) do
  for key, callback in pairs(keys) do
    if type(callback) == 'table' then
      vim.keymap.set(mode, key, callback[1], callback[2])
    else
      vim.keymap.set(mode, key, callback, { noremap = true, silent = true })
    end
  end
end

require('gen740.lsps')
