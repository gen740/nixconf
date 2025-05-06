vim.opt.clipboard = 'unnamed'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.signcolumn = 'yes'
vim.opt.list = true
vim.opt.listchars = { tab = '»─', trail = '␣', extends = '»', precedes = '«', nbsp = '%' }
vim.opt.pumheight = 15
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.cmdheight = 0

vim.g.netrw_banner = 0
vim.g.netrw_hide = 1
vim.g.netrw_list_hide = [[\(^\.\/\=$\)\|\(^\.\.\/\=$\)\|\(^\.DS_Store$\)]]

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
vim.api.nvim_set_hl(0, 'Whitespace', { fg = '#30363d' })

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
