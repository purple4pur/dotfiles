vim.opt.runtimepath:append(vim.fn.stdpath('config') .. '/lua/glow.nvim')
vim.opt.runtimepath:append(vim.fn.stdpath('config') .. '/lua/mini.nvim')

-- <leader>p: preview markdown
require('glow').setup({
    border = 'none',
    width = 150,
    height = 100,
    width_ratio = 0.8,
    height_ratio = 0.8,
})
vim.keymap.set('n', '<leader>p', '<cmd>Glow<CR><cmd>nohlsearch<CR>')

require('mini.completion').setup()
require('mini.cursorword').setup()

-- <leader>e<e/v/t>: open file explorer
require('mini.files').setup()
vim.api.nvim_create_autocmd('User', { -- :help MiniFiles # Customize windows
    pattern = 'MiniFilesWindowOpen',
    callback = function(args)
        local win_id = args.data.win_id
        vim.api.nvim_win_set_config(win_id, { border = 'rounded' })
    end,
})
vim.keymap.set('n', '<leader>ee', function() MiniFiles.open() end)
vim.keymap.set('n', '<leader>ev', function() vim.cmd('vnew') MiniFiles.open() end)
vim.keymap.set('n', '<leader>et', function() vim.cmd('tabnew') MiniFiles.open() end)

require('mini.indentscope').setup({ draw = {
    delay = 500,
    animation = require('mini.indentscope').gen_animation.linear({ duration = 10 }),
}})

-- <CR>: enter jump mode
require('mini.jump2d').setup()

-- <leader>mm: toggle
require('mini.map').setup({
    symbols = {
        encode = require('mini.map').gen_encode_symbols.dot('4x2'),
    },
    window = { focusable = true },
})
vim.keymap.set('n', '<leader>mm', function() MiniMap.toggle() end)

-- <M-h/j/k/l>: move
require('mini.move').setup()

--require('mini.pairs').setup()

-- gS: toggle
require('mini.splitjoin').setup()

require('mini.starter').setup()
require('mini.statusline').setup()

-- s<a/d/r/h/f/F>: add/delete/replace/highlight/f(F)ind
require('mini.surround').setup()

-- <leader>dz: remove trailspaces/lines
require('mini.trailspace').setup()
vim.keymap.set('n', '<leader>dz', function() MiniTrailspace.trim() MiniTrailspace.trim_last_lines() end)
