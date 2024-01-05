-- common settings
vim.o.guifont = 'Sarasa_Term_SC_Nerd:h11,终端更纱黑体-简_Nerd:h11'


-- keymaps
vim.keymap.set('n', '<leader>T', function() vim.cmd('tabnew +terminal') end, { silent = true })
vim.keymap.set('t', '<C-\\>', '<C-\\><C-N>')
vim.api.nvim_create_user_command('Vims', function()
    vim.cmd('edit ' .. vim.fn.stdpath('config') .. '/lua/init.lua')
end, { bang = true })
vim.api.nvim_create_user_command('Srcs', function()
    vim.cmd('source ' .. vim.fn.stdpath('config') .. '/init.vim')
    vim.cmd('source ' .. vim.fn.stdpath('config') .. '/lua/init.lua')
end, { bang = true })


-- lsp
vim.opt.runtimepath:append(vim.fn.stdpath('config') .. '/lua/nvim-lspconfig')
local lspconfig = require('lspconfig')
lspconfig.lua_ls.setup({
    -- reference: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
    on_init = function(client)
        local path = client.workspace_folders[1].name
        if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
            client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME
                        },
                    }
                }
            })
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
        return true
    end
})
lspconfig.verible.setup({ single_file_support = true })
lspconfig.veridian.setup({ single_file_support = true })
lspconfig.zls.setup({})

vim.diagnostic.config({
    signs = false,
    update_in_insert = true,
})
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<tab>d', vim.diagnostic.open_float)
vim.keymap.set('n', '<tab>q', vim.diagnostic.setloclist)
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<tab>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<tab>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<tab>f', function() vim.lsp.buf.format({ async = true }) end, opts)
    end,
})


-- plugins
vim.opt.runtimepath:append(vim.fn.stdpath('config') .. '/lua/glow.nvim')
require('glow').setup({
    border = 'none',
    width = 150,
    height = 100,
    width_ratio = 0.8,
    height_ratio = 0.8,
})                                 -- `<leader>p` to preview markdown
vim.keymap.set('n', '<leader>p', '<cmd>Glow<CR><cmd>nohlsearch<CR>') -- use vim's error message

vim.opt.runtimepath:append(vim.fn.stdpath('config') .. '/lua/mini.nvim')
require('mini.completion').setup()
require('mini.cursorword').setup()
require('mini.files').setup()      -- `<leader>e<e/v/t>` to open
require('mini.indentscope').setup()
require('mini.jump2d').setup()     -- `<CR>` to enter jump mode
require('mini.map').setup({
    symbols = {
        encode = require('mini.map').gen_encode_symbols.dot('4x2'),
    },
    window = { focusable = true },
})                                 -- `<leader>mm` to toggle
require('mini.move').setup()       -- `<M-h/j/k/l>` to move
require('mini.pairs').setup()
require('mini.splitjoin').setup()  -- `gS` to toggle
require('mini.starter').setup()
require('mini.statusline').setup()
require('mini.surround').setup()   -- `s<a/d/r/h/f/F>` to add/delete/replace/highlight/f(F)ind
require('mini.trailspace').setup() -- `<leader>dz` to remove trailspaces/lines

vim.keymap.set('n', '<leader>ee', function() MiniFiles.open() end)
vim.keymap.set('n', '<leader>ev', function() vim.cmd('vnew') MiniFiles.open() end)
vim.keymap.set('n', '<leader>et', function() vim.cmd('tabnew') MiniFiles.open() end)
vim.keymap.set('n', '<leader>mm', function() MiniMap.toggle() end)
vim.keymap.set('n', '<leader>dz', function() MiniTrailspace.trim() MiniTrailspace.trim_last_lines() end)

-- reference: :help MiniFiles # Customize windows
vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesWindowOpen',
    callback = function(args)
        local win_id = args.data.win_id
        vim.api.nvim_win_set_config(win_id, { border = 'rounded' })
    end,
})
