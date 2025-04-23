local M = {}

-- Helper function to trim whitespace.
local function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Main function:
-- filename: The header file name, e.g. "MyClass.hpp"
function M.generate_cpp_file(header_file)
	-- Read the header file contents.
	if header_file  == nil or header_file == "" then
		header_file = vim.api.nvim_buf_get_name(0)
	end
	local file = io.open(header_file, "r")
	if not file then
		print("Error: could not open file " .. header_file)
		return
	end
	local content = file:read("*a")
	file:close()

	-- Extract the class name.
	-- In this example, we assume the header file name is the same as the class name.
	local class_name = header_file:match("([^/\\]+)%.hpp$")
	if not class_name then
		print("Error: could not determine class name from header file name.")
		return
	end

	-- Prepare a table to store function definitions.
	local functions = {}

	-- A very simple parser: we assume each function is declared on a single line.
	-- Look for setters (e.g., void setSomething(...);)
	for line in content:gmatch("[^\r\n]+") do
		line = trim(line)
		-- Match setters: assume declaration is like "void setX(type x);" (ignoring qualifiers).
		local set_func, args = line:match("void%s+(set%u%w*)%s*%(([^)]*)%)")
		if set_func then
			table.insert(functions, {name = set_func, args = trim(args), return_type = "void"})
		end

		-- Match getters: assume declaration is like "type getX(void) const;" or similar.
		-- We capture the return type, function name and arguments.
		local ret_type, get_func, args = line:match("([%w_:<>]+)%s+(get%u%w*)%s*%(([^)]*)%)")
		if ret_type and get_func then
			table.insert(functions, {name = get_func, args = trim(args), return_type = ret_type})
		end
	end

	-- Start building the content for the .cpp file.
	local cpp_lines = {}

	table.insert(cpp_lines, '#include "' .. class_name .. '.hpp"')
	table.insert(cpp_lines, "")  -- blank line

	table.insert(cpp_lines, "// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓")
	table.insert(cpp_lines, "// ┃          CONSTRUCTOR          ┃")
	table.insert(cpp_lines, "// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛")
	table.insert(cpp_lines, "")

	-- Default constructor.
	table.insert(cpp_lines, class_name .. "::" .. class_name .. "() {")
	table.insert(cpp_lines, "}")
	table.insert(cpp_lines, "")
	-- Copy constructor.
	table.insert(cpp_lines, class_name .. "::" .. class_name .. "(const " .. class_name .. " &other) { *this = other; }")
	table.insert(cpp_lines, "")
	-- Assignment operator.
	table.insert(cpp_lines, class_name .. " &" .. class_name .. "::operator=(const " .. class_name .. " &other) {")
	table.insert(cpp_lines, "    if (this == &other) { return *this; }")
	table.insert(cpp_lines, "")
	table.insert(cpp_lines, "    // copy")
	table.insert(cpp_lines, "    return *this;")
	table.insert(cpp_lines, "}")
	table.insert(cpp_lines, "")
	-- Destructor.
	table.insert(cpp_lines, "// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓")
	table.insert(cpp_lines, "// ┃          DESTRUCTOR           ┃")
	table.insert(cpp_lines, "// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛")
	table.insert(cpp_lines, "")
	table.insert(cpp_lines, class_name .. "::~" .. class_name .. "() {")
	table.insert(cpp_lines, "}")
	table.insert(cpp_lines, "")

	-- Generate stubs for other member functions (e.g., set and get functions).
	if #functions > 0 then
		table.insert(cpp_lines, "// ┏━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━┓")
		table.insert(cpp_lines, "// ┃     GET()     ┃     SET()     ┃")
		table.insert(cpp_lines, "// ┗━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━┛")
		table.insert(cpp_lines, "")
		for _, func in ipairs(functions) do
			-- If no arguments, we insert void explicitly.
			local args = func.args
			if args == "" then
				args = "void"
			end
			local line = func.return_type .. " " .. class_name .. "::" .. func.name .. "(" .. args .. ")"
			-- For getters, you might want to mark the function as const.
			if func.name:sub(1, 3) == "get" then
				line = line .. " const"
			end
			table.insert(cpp_lines, line .. " {")
			if func.name:sub(1, 3) == "get" then
				local string = ""
				table.insert(cpp_lines, "	return this->" .. string.lower(func.name:sub(4, 4)) ..  func.name:sub(5, func.name.len(func.name)) .. ";")
			end
			if func.name:sub(1, 3) == "set" then
				local string = ""
				table.insert(cpp_lines, "	this->" .. string.lower(func.name:sub(4, 4)) ..  func.name:sub(5, func.name.len(func.name)) .. " = " .. func.args:gsub('.*% ', '') .. ";")
			end
			table.insert(cpp_lines, "}")
			table.insert(cpp_lines, "")
		end
		table.insert(cpp_lines, "// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓")
		table.insert(cpp_lines, "// ┃             MEMBER            ┃")
		table.insert(cpp_lines, "// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛")
		table.insert(cpp_lines, "")
	else
		table.insert(cpp_lines, "// ┏━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━┓")
		table.insert(cpp_lines, "// ┃     GET()     ┃     SET()     ┃")
		table.insert(cpp_lines, "// ┗━━━━━━━━━━━━━━━┻━━━━━━━━━━━━━━━┛")
		table.insert(cpp_lines, "")
		table.insert(cpp_lines, "// ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓")
		table.insert(cpp_lines, "// ┃             MEMBER            ┃")
		table.insert(cpp_lines, "// ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛")
		table.insert(cpp_lines, "")
	end

	-- Write the generated content to the .cpp file.
	local cpp_file = class_name .. ".cpp"
	local dir = header_file:match("^(.*[/\\])") or ""
	local out = io.open(dir .. cpp_file, "w")
	if not out then
		print("Error: could not write to file " .. cpp_file)
		return
	end
	out:write(table.concat(cpp_lines, "\n"))
	out:close()

	print("Generated " .. cpp_file)
end

return M
