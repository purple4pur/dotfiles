vim.opt.runtimepath:append(vim.fn.stdpath('config') .. '/lua')
require('lsp')
require('plugins')

vim.keymap.set('n', '<leader>T', function() vim.cmd('tabnew +terminal') end, { silent = true })
vim.keymap.set('t', '<C-\\>', '<C-\\><C-N>')

vim.api.nvim_create_user_command('Vims', function()
    vim.cmd('edit ' .. vim.fn.stdpath('config') .. '/lua/init.lua')
end, { bang = true })
vim.api.nvim_create_user_command('Srcs', function()
    vim.cmd('source ' .. vim.fn.stdpath('config') .. '/init.vim')
    vim.cmd('source ' .. vim.fn.stdpath('config') .. '/lua/init.lua')
    -- workaround to flush built-in statusline
    vim.cmd('tabnew')
    vim.cmd('quit')
    vim.cmd('tabprevious')
end, { bang = true })
