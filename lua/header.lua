local M = {}

local HEADER_LINE_LENGTH = 80

local function pad_text(content, total_length)
    local padding = total_length - #content
    if padding > 0 then
        return content .. string.rep(" ", padding)
    else
        return content:sub(1, total_length)
    end
end

local function get_comment_style()
    local filetype = vim.bo.filetype
    if filetype == "c" or filetype == "cpp" then
        return { block_start = "/*", block_end = "*/", line = " * " }
    elseif filetype == "bash" or filetype == "sh" or filetype == "python" then
        return { block_start = "#", block_end = "#", line = "#" }
    else
        return { block_start = "/*", block_end = "*/", line = " * " }
    end
end

function M.insert_header()
    local filename = vim.fn.expand('%:t') or ""
    local author = "nalebrun"                  								-- Replace with your name
    local email = "<nalebrun@student.s19.be>"								-- Replace with your email
    local updated_date = os.date('%Y/%m/%d %H:%M:%S')
    local created_date = updated_date

    for i = 1, vim.fn.line('$') do
        local line = vim.fn.getline(i)
        local match = line:match("Created: (%d+/%d+/%d+ %d+:%d+:%d+)")
        if match then
            created_date = match
            break
        end
    end

    local comment = get_comment_style()

    local header = {}
    table.insert(header, comment.block_start .. " ************************************************************************** " .. comment.block_end)
    table.insert(header, comment.block_start .. string.rep(" ", 76) .. comment.block_end)
    table.insert(header, comment.block_start .. "                                                        :::      ::::::::   " .. comment.block_end)
    table.insert(header, string.format(comment.block_start .. "   %-51s:+:      :+:    :+:   " .. comment.block_end, filename))
    table.insert(header, comment.block_start .. "                                                    +:+ +:+         +:+     " .. comment.block_end)
    table.insert(header, string.format(comment.block_start .. "   By: %s %-33s+#+  +:+       +#+         " .. comment.block_end, author, email))
    table.insert(header, comment.block_start .. "                                                +#+#+#+#+#+   +#+           " .. comment.block_end)
    table.insert(header, string.format(comment.block_start .. "   Created: %-20sby %-18s#+#    #+#             " .. comment.block_end, created_date, author))
    table.insert(header, string.format(comment.block_start .. "   Updated: %-20sby %-17s###   ########.fr       " .. comment.block_end, updated_date, author))
    table.insert(header, comment.block_start .. string.rep(" ", 76) .. comment.block_end)
    table.insert(header, comment.block_start .. " ************************************************************************** " .. comment.block_end)

    local line = vim.fn.getline(6)
    if line:find("By:") then
        vim.api.nvim_buf_set_lines(0, 0, #header, false, header)
    else
        vim.api.nvim_buf_set_lines(0, 0, 0, false, header)
    end
end

return M
