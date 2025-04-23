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

    -- Check if header already exists and extract Created and By lines
    local existing_created_date, existing_author = nil, nil
    for i = 1, vim.fn.line('$') do
        local line = vim.fn.getline(i)
        if line:find("Created:") then
            existing_created_date = line:match("Created: (%d+/%d+/%d+ %d+:%d+:%d+)")
            existing_author = line:match("by ([^ ]+)$")
        end
        if line:find("By:") then
            existing_author = line:match("By: ([^ ]+) ")
        end
        if existing_created_date and existing_author then break end
    end

    -- Use existing values if found, otherwise use defaults
    created_date = existing_created_date or created_date
    author = existing_author or author

    local comment = get_comment_style()

    -- Construct the header lines
    local header = {}
    table.insert(header,               comment.block_start .. " ************************************************************************** " .. comment.block_end)
    table.insert(header,               comment.block_start .. "                                                                            " .. comment.block_end)
    table.insert(header,               comment.block_start .. "                                                        :::      ::::::::   " .. comment.block_end)
    table.insert(header, string.format(comment.block_start ..                                               "   %-51s:+:      :+:    :+:   " .. comment.block_end, filename))
    table.insert(header,               comment.block_start .. "                                                    +:+ +:+         +:+     " .. comment.block_end)
    table.insert(header, string.format(comment.block_start ..                                   "   By: %s %-33s+#+  +:+       +#+         " .. comment.block_end, author, email))
    table.insert(header,               comment.block_start .. "                                                +#+#+#+#+#+   +#+           " .. comment.block_end)
    table.insert(header, string.format(comment.block_start ..                             "   Created: %-20sby %-18s#+#    #+#             " .. comment.block_end, created_date, author))
    table.insert(header, string.format(comment.block_start ..                            "   Updated: %-20sby %-17s###   ########.fr       " .. comment.block_end, updated_date, author))
    table.insert(header,               comment.block_start .. "                                                                            " .. comment.block_end)
    table.insert(header,               comment.block_start .. " ************************************************************************** " .. comment.block_end)

    -- Check for an existing header and replace it; otherwise insert at the top
    local first_line_of_header_found = false
    for i = 1, vim.fn.line('$') do
        local line = vim.fn.getline(i)
        if line:find("By:") then
            first_line_of_header_found = true
            vim.api.nvim_buf_set_lines(0, 0, #header, false, header) -- Replace the header block
            break
        end
    end

    if not first_line_of_header_found then
        vim.api.nvim_buf_set_lines(0, 0, 0, false, header) -- Insert new header at the top if none exists
    end
end

return M
