local function show_function_lines()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local lang = vim.treesitter.language.get_lang(ft) or ft
  local parser = vim.treesitter.get_parser(bufnr, lang)
  if not parser then
    return
  end
  local ns = vim.api.nvim_create_namespace('function_lines')
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  -- Tree-sitter query for C functions, with three cases:
  --   Case 1: Regular function (no pointer)
  --   Case 2: Function returning a pointer (one pointer_declarator)
  --   Case 3: Function returning a double pointer (two pointer_declarator nodes)
  local query = vim.treesitter.query.parse(lang, [[
    ; Case 1: Regular function (no pointer)
    (function_definition
      declarator: (function_declarator
        declarator: (identifier) @func_name
      )
      body: (compound_statement) @func_body
    ) @func;
    ; Case 2: Function returning a pointer (one pointer_declarator)
    (function_definition
      declarator: (pointer_declarator
        declarator: (function_declarator
          declarator: (identifier) @func_name
        )
      )
      body: (compound_statement) @func_body
    ) @func;
    ; Case 3: Function returning a double pointer (two pointer_declarator nodes)
    (function_definition
      declarator: (pointer_declarator
        declarator: (pointer_declarator
          declarator: (function_declarator
            declarator: (identifier) @func_name
          )
        )
      )
      body: (compound_statement) @func_body
    ) @func
  ]])
  for _, tree in ipairs(parser:parse()) do
    local root = tree:root()
    -- Iterate over each capture from the query
    for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
      if query.captures[id] == "func_body" then
        -- Get the range of the compound statement.
        -- The range includes the braces, so we subtract 2 to get the interior.
        local start_line, _, end_line, _ = node:range()
        local total_lines = end_line - start_line - 1
        if total_lines < 0 then
          total_lines = 0
        end
        -- Get the lines between the braces.
        local lines = vim.api.nvim_buf_get_lines(bufnr, start_line + 1, end_line, false)
        local comment_lines = 0
        for _, line in ipairs(lines) do
          -- Adjust this pattern as needed for your comment style.
          if line:match("^%s*//") then
            comment_lines = comment_lines + 1
          end
        end
        local non_comment_lines = total_lines - comment_lines
        -- Prepare the virtual text.
        local virt_text = nil
        if comment_lines > 0 then
          -- If there are comment lines, display two numbers:
          --    Total lines / non-comment lines.
          virt_text = {{ ' 󰆧 ' .. total_lines .. ' / ' .. non_comment_lines, 'Comment' }}
        else
          -- If no comments, display only the total line count.
          virt_text = {{ ' 󰆧 ' .. total_lines, 'Comment' }}
        end
        -- Place the virtual text on the closing brace line.
        vim.api.nvim_buf_set_extmark(bufnr, ns, end_line, -1, {
          virt_text = virt_text,
          virt_text_pos = 'eol',
        })
      end
    end
  end
end
-- Auto-command to run the function for C files on buffer enter or after writing.
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
  pattern = '*.c',
  callback = show_function_lines,
})-- Auto-command to run the function for C files on buffer enter or after writing.
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
  pattern = '*.c',
  callback = show_function_lines,
})
