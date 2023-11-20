-- font
vim.o.guifont = 'Sarasa_Term_SC_Nerd:h11,终端更纱黑体-简_Nerd:h11'

-- keymap
vim.keymap.set('n', '<leader>T', '<cmd>tabnew +terminal<CR>', { silent = true })
vim.keymap.set('t', '<C-\\>', '<C-\\><C-N>')
