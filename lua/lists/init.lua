local M = {}

M.filenames_to_quickfix = function(filenames)
    local items = vim.tbl_map(function(f)
        return { filename = f }
    end, filenames)
    vim.fn.setqflist(items)
end

M.filenames_to_args = function(filenames)
    vim.cmd "silent! argdelete *"
    local filenames_string = table.concat(filenames, " ")
    vim.cmd(string.format("argadd %s", filenames_string))
end

M.buf_dir = function()
    local buffer_name = vim.api.nvim_buf_get_name(0)
    if buffer_name == "" then
        vim.notify "No buffer open"
        return
    end
    local buffer_dir = vim.fn.fnamemodify(buffer_name, ":h")
    return vim.fn.readdir(buffer_dir)
end

M.buf_dir_to_quickfix = function()
    local filenames = M.buf_dir()
    if filenames then
        M.filenames_to_quickfix(filenames)
    end
end

M.buf_dir_to_args = function()
    local filenames = M.buf_dir()
    if filenames then
        M.filenames_to_args(filenames)
    end
end

M.cwd = function()
    local cwd = vim.fn.getcwd()
    return vim.fn.readdir(cwd)
end

M.cwd_to_quickfix = function()
    local filenames = M.cwd()
    if filenames then
        M.filenames_to_quickfix(filenames)
    end
end

M.cwd_to_args = function()
    local filenames = M.cwd()
    if filenames then
        M.filenames_to_args(filenames)
    end
end

M.args = function()
    return vim.fn.argv()
end

M.args_to_quickfix = function()
    local args = M.args()
    if args then
        M.filenames_to_quickfix(args)
    end
end

M.quickfix = function()
    return vim.fn.getqflist()
end

M.quickfix_to_args = function()
    local quickfix_items = M.quickfix()
    if quickfix_items then
        local filenames = vim.tbl_map(function(item)
            return item.filename
        end, quickfix_items)
        M.filenames_to_args(filenames)
    end
end

M.command = function(cmd)
    local output = vim.fn.systemlist(cmd)
    if vim.v.shell_error == 0 then
        return output
    end
end

M.command_to_quickfix = function(cmd)
    local filenames = M.command(cmd)
    if filenames then
        M.filenames_to_quickfix(filenames)
    end
end

M.command_to_args = function(cmd)
    local filenames = M.command(cmd)
    if filenames then
        M.filenames_to_args(filenames)
    end
end

return M