local api, lsp = vim.api, vim.lsp
local command = api.nvim_create_user_command

local lsp_client_complete = function()
    local clients = lsp.get_clients()

    local C = {}
    for i = 1, #clients do
        C[i] = clients[i].name
    end

    return C
end

command("LspRestart", function(kwargs)
    local bufnr = api.nvim_get_current_buf()
    local name = kwargs.fargs[1]
    local clients = lsp.get_clients({
        bufnr = bufnr,
        name = name,
    })

    local detach_clients = {}
    for i = 1, #clients do
        local client = clients[i]
        client.stop(kwargs.bang)
        detach_clients[i] = {
            client,
            lsp.get_buffers_by_client_id(client.id),
        }
    end

    local timer = assert(vim.uv.new_timer())
    timer:start(500, 100, vim.schedule_wrap(function()
        for i = 1, #detach_clients do
            local client = detach_clients[i][1]
            local buffers = detach_clients[i][2]

            if client.is_stopped() then
                for j = 1, #buffers do
                    lsp.start(client.config, { bufnr = buffers[j] })
                end
                detach_clients[i] = nil
            end
        end

        if next(detach_clients) == nil and not timer:is_closing() then
            timer:close()
        end
    end))
end, { nargs = "*", complete = lsp_client_complete, bang = true })

command("LspStop", function(kwargs)
    local bufnr = api.nvim_get_current_buf()
    local name = kwargs.fargs[1]
    local clients = lsp.get_clients({
        bufnr = bufnr,
        name = name,
    })

    for i = 1, #clients do
        clients[i].stop(kwargs.bang)
    end
end, { nargs = "*", complete = lsp_client_complete, bang = true })

command("LspInfo", function()
    vim.cmd([[botright checkhealth vim.lsp]])
end, {})

command("LspLog", function()
    vim.cmd(string.format("tabnew %s", lsp.get_log_path()))
end, {})
