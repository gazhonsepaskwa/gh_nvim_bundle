local M = {}

function M.generate_hpp_file(class_name)

	local class = class_name
	local hpp_lines = {}

	table.insert(hpp_lines, "#ifndef  " .. class.upper(class) .. "_HPP")
	table.insert(hpp_lines, "# define " .. class.upper(class) .. "_HPP")
	table.insert(hpp_lines, "")
	table.insert(hpp_lines, "class " .. class .. " {")
	table.insert(hpp_lines, "	protected:")
	table.insert(hpp_lines, "")
	table.insert(hpp_lines, "	private:")
	table.insert(hpp_lines, "")
	table.insert(hpp_lines, "	public:")
	table.insert(hpp_lines, "		" .. cCass .. "();")
	table.insert(hpp_lines, "")
	table.insert(hpp_lines, "	   ~" .. class .. "();")
	table.insert(hpp_lines, "")
	table.insert(hpp_lines, "		" .. class .. "(const " .. class .. " &other);")
	table.insert(hpp_lines, "		" .. class .. " &operator=(const " .. class .. " &other);")
	table.insert(hpp_lines, "")
	table.insert(hpp_lines, "};")
	table.insert(hpp_lines, "		// Member")
	table.insert(hpp_lines, "")
	table.insert(hpp_lines, "#endif")

	local hpp_file = class .. ".hpp"
	local out = io.open(hpp_file, "w")

	if not out then
		print("Error: Could not create hpp file")
		return
	end
	out:write(table.concat(hpp_lines, "\n"))
	out:close()

	print("Generated " .. hpp_file)
end

return M
