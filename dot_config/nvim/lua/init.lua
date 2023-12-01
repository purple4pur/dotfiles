-- font
vim.o.guifont = 'Sarasa_Term_SC_Nerd:h11,终端更纱黑体-简_Nerd:h11'

-- keymaps
vim.keymap.set('n', '<leader>T', '<cmd>tabnew +terminal<CR>', { silent = true })
vim.keymap.set('t', '<C-\\>', '<C-\\><C-N>')
vim.api.nvim_create_user_command('Vims', 'edit ' .. vim.fn.stdpath('config') .. '/lua/init.lua', { bang = true })
vim.api.nvim_create_user_command('Srcs', function(opts)
    vim.cmd('source ' .. vim.fn.stdpath('config') .. '/init.vim')
    vim.cmd('source ' .. vim.fn.stdpath('config') .. '/lua/init.lua')
end, { bang = true })

-- plugins
vim.opt.runtimepath:append(vim.fn.stdpath('config') .. '/lua/glow.nvim')
require('glow').setup({
    border = 'none',
    width = 150,
    height = 100,
    width_ratio = 0.8,
    height_ratio = 0.8,
}) -- `<leader>p` to preview markdown
vim.keymap.set('n', '<leader>p', '<cmd>Glow<CR><cmd>nohlsearch<CR>')

vim.opt.runtimepath:append(vim.fn.stdpath('config') .. '/lua/mini.nvim')
require('mini.completion').setup()
require('mini.cursorword').setup()
require('mini.files').setup() -- `<leader>e<e/v/t>` to open
require('mini.indentscope').setup()
require('mini.jump2d').setup() -- `<CR>` to enter jump mode
require('mini.map').setup({
    symbols = {
        encode = require('mini.map').gen_encode_symbols.dot('4x2'),
    },
    window = { focusable = true },
}) -- `<leader>mm` to toggle
require('mini.move').setup() -- `<M-h/j/k/l>` to move
require('mini.pairs').setup()
require('mini.splitjoin').setup() -- `gS` to toggle
require('mini.starter').setup()
require('mini.statusline').setup()
require('mini.surround').setup() -- `s<a/d/r/h/f/F>` to add/delete/replace/highlight/f(F)ind
require('mini.trailspace').setup() -- `<leader>dz` to remove trailspaces/lines

vim.keymap.set('n', '<leader>ee', '<cmd>lua MiniFiles.open()<CR>')
vim.keymap.set('n', '<leader>ev', '<cmd>vnew<CR><cmd>lua MiniFiles.open()<CR>')
vim.keymap.set('n', '<leader>et', '<cmd>tabnew<CR><cmd>lua MiniFiles.open()<CR>')
vim.keymap.set('n', '<leader>mm', '<cmd>lua MiniMap.toggle()<CR>')
vim.keymap.set('n', '<leader>dz', '<cmd>lua MiniTrailspace.trim()<CR><cmd>lua MiniTrailspace.trim_last_lines()<CR>')

vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesWindowOpen',
    callback = function(args)
        local win_id = args.data.win_id
        vim.api.nvim_win_set_config(win_id, { border = 'rounded' })
    end,
})
