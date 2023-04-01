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
        return
    end
    local dir = vim.fs.dirname(buffer_name)
    local filenames = {}
    for name, type in vim.fs.dir(dir) do
        table.insert(filenames, string.format("%s/%s", dir, name))
    end
    return filenames
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

M.on_choice_edit = function(item)
    if not item then
        return
    end
    vim.cmd(string.format("edit %s", item))
end

M.on_choice_split = function(item)
    if not item then
        return
    end
    vim.cmd(string.format("split %s", item))
end

M.on_choice_vsplit = function(item)
    if not item then
        return
    end
    vim.cmd(string.format("vsplit %s", item))
end

M.on_choice_arg_edit = function(item, idx)
    if not item then
        return
    end
    vim.cmd(string.format("argument %d", idx))
end

M.on_choice_arg_split = function(item, idx)
    if not item then
        return
    end
    vim.cmd(string.format("sargument %d", idx))
end

M.on_choice_arg_vsplit = function(item, idx)
    if not item then
        return
    end
    vim.cmd(string.format("vertical sargument %d", idx))
end

M.select_arg = function()
    local args = M.args()
    vim.ui.select(args, { prompt = "Args" }, M.on_choice_arg_edit)
end

M.select_cwd = function()
    local files = M.cwd()
    vim.ui.select(files, { prompt = "Current directory" }, M.on_choice_edit)
end

M.select_buf_dir = function()
    local files = M.buf_dir()
    if not files then
        vim.notify("No buffer open")
        return
    end
    local dirname = vim.fs.dirname(files[1])
    vim.ui.select(files, {
        prompt = dirname,
        format_item = function(item) return vim.fs.basename(item) end
    }, M.on_choice_edit)
end

M.select_from_dir = function(dir)
    local files = vim.fn.readdir(dir)
    files = vim.tbl_map(function(f)
        return string.format("%s/%s", dir, f)
    end, files)
    vim.ui.select(files, { prompt = "Dir" }, M.on_choice_edit)
end

M.select_and_run_linter = function()
    local lint = require "lint"
    local filetype = vim.bo.ft
    local linters = lint.linters_by_ft [filetype]
    local on_choice = function(item)
        if not item then
            return
        end
        lint.try_lint(item)
    end
    vim.ui.select(linters, { prompt = "Linters" }, on_choice)
end

return M
