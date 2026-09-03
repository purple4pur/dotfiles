vim.opt.runtimepath:append(vim.fn.stdpath('config') .. '/lua/nvim-lspconfig')

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

--vim.lsp.config('lua_ls', {
--    -- reference: https://github.com/neovim/nvim-lspconfig/blob/master/lsp/lua_ls.lua
--    on_init = function(client)
--        if client.workspace_folders then
--            local path = client.workspace_folders[1].name
--            if not vim.uv.fs_stat(path .. '/.luarc.json') and not vim.uv.fs_stat(path .. '/.luarc.jsonc') then
--                client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua or {}, {
--                    runtime = { version = 'LuaJIT' },
--                    workspace = {
--                        checkThirdParty = false,
--                        library = {
--                            vim.env.VIMRUNTIME,
--                        },
--                    },
--                })
--            end
--        end
--    end,
--})
--vim.lsp.enable('lua_ls')

--vim.lsp.enable('verible')

--vim.lsp.enable('veridian')

--vim.lsp.enable('zls')
