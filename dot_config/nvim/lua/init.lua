-- font
vim.o.guifont = 'Sarasa_Term_SC_Nerd:h11,终端更纱黑体-简_Nerd:h11'

-- keymap
vim.keymap.set('n', '<leader>T', '<cmd>tabnew +terminal<CR>', { silent = true })
vim.keymap.set('t', '<C-\\>', '<C-\\><C-N>')

-- plugins
vim.opt.runtimepath:append(vim.fn.stdpath('config') .. '/lua/glow.nvim')
require('glow').setup({
    border = 'none',
    width = 150,
    height = 100,
    width_ratio = 0.8,
    height_ratio = 0.8,
})
