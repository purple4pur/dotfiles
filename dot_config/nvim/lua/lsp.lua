vim.opt.runtimepath:append(vim.fn.stdpath('config') .. '/lua/nvim-lspconfig')
local lspconfig = require('lspconfig')

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
        vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, opts)
        vim.keymap.set('n', '<tab>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<tab>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<tab>f', function() vim.lsp.buf.format({ async = true }) end, opts)
    end,
})

--lspconfig.lua_ls.setup({
--    -- reference: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#lua_ls
--    on_init = function(client)
--        local path = client.workspace_folders[1].name
--        if not vim.loop.fs_stat(path..'/.luarc.json') and not vim.loop.fs_stat(path..'/.luarc.jsonc') then
--            client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
--                Lua = {
--                    runtime = { version = 'LuaJIT' },
--                    workspace = {
--                        checkThirdParty = false,
--                        library = {
--                            vim.env.VIMRUNTIME
--                        },
--                    }
--                }
--            })
--            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
--        end
--        return true
--    end
--})

--lspconfig.verible.setup({ single_file_support = true })

--lspconfig.veridian.setup({ single_file_support = true })

--lspconfig.zls.setup({})
