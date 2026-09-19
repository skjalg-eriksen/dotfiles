local M = {}

local pending_captures = {}
local session_variables = {}

local function lines(bufnr)
	return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
end

function M.find_auth_file(bufnr)
	local filename = vim.api.nvim_buf_get_name(bufnr)
	if filename == "" then
		return
	end

	return vim.fs.find("resterm.auth.http", {
		path = vim.fs.dirname(filename),
		upward = true,
		type = "file",
	})[1]
end

local function parse_directives(source, directive)
	local variables = {}
	for _, line in ipairs(source) do
		local name, value = line:match("^%s*#%s*@" .. directive .. "%s+([%w_.-]+)%s+(.+)%s*$")
		if name then
			variables[name] = value
		end
	end
	return variables
end

local function defaults(bufnr)
	local values = {}
	local auth_file = M.find_auth_file(bufnr)
	if auth_file then
		values = parse_directives(vim.fn.readfile(auth_file), "global")
	end
	return vim.tbl_extend("force", values, parse_directives(lines(bufnr), "file"))
end

local function names(bufnr)
	local result = defaults(bufnr)
	for name in pairs(session_variables) do
		result[name] = true
	end
	for _, line in ipairs(lines(bufnr)) do
		for name in line:gmatch("{{%s*([^}$][^}]*)%s*}}") do
			result[vim.trim(name)] = true
		end
	end

	result = vim.tbl_keys(result)
	table.sort(result)
	return result
end

function M.prepare(bufnr)
	for name, value in pairs(defaults(bufnr)) do
		vim.env[name] = session_variables[name] or value
	end
	for name, value in pairs(session_variables) do
		vim.env[name] = value
	end
end

local function set(name, value)
	session_variables[name] = value
	vim.env[name] = value
	vim.notify(("%s = %s"):format(name, value), vim.log.levels.INFO, {
		title = "rest.nvim variables",
	})
end

local function variable_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local column = vim.api.nvim_win_get_cursor(0)[2] + 1
	local start = 1

	while true do
		local first, last, name = line:find("{{%s*([^}]+)%s*}}", start)
		if not first then
			return
		end
		if column >= first and column <= last then
			name = vim.trim(name)
			return not vim.startswith(name, "$") and name or nil
		end
		start = last + 1
	end
end

function M.prompt(bufnr)
	local function prompt_value(name)
		local clipboard = vim.fn.getreg("+")
		vim.ui.input({
			prompt = name .. ": ",
			default = clipboard ~= "" and clipboard or session_variables[name] or vim.env[name],
		}, function(value)
			if value then
				set(name, value)
			end
		end)
	end

	local name = variable_under_cursor()
	if name then
		prompt_value(name)
		return
	end

	vim.ui.input({
		prompt = "Variable: ",
		completion = "customlist,v:lua.RestNvimVariableComplete",
	}, function(selected)
		if selected and selected ~= "" then
			prompt_value(selected)
		end
	end)
end

local function section_lines(bufnr, cursor_row)
	local source = lines(bufnr)
	local first = cursor_row
	while first > 1 and not source[first]:match("^%s*###") do
		first = first - 1
	end

	local last = cursor_row + 1
	while last <= #source and not source[last]:match("^%s*###") do
		last = last + 1
	end
	return vim.list_slice(source, first, last - 1)
end

function M.prepare_captures(bufnr, cursor_row)
	pending_captures = {}
	for _, line in ipairs(section_lines(bufnr, cursor_row)) do
		local name, path =
			line:match("^%s*#%s*@capture%s+global%s+([%w_.-]+)%s+" .. "{{response%.json%.([%w_.%[%]-]+)}}%s*$")
		if name then
			table.insert(pending_captures, { name = name, path = path })
		end
	end
end

local function json_path(value, path)
	for part in path:gmatch("[^.]+") do
		local key, index = part:match("^([%w_-]+)%[(%d+)]$")
		if key then
			value = type(value) == "table" and value[key] or nil
			value = type(value) == "table" and value[tonumber(index) + 1] or nil
		else
			value = type(value) == "table" and value[part] or nil
		end
		if value == nil then
			return
		end
	end
	return value
end

function M.apply_captures(response)
	if #pending_captures == 0 then
		return
	end

	local captures = pending_captures
	pending_captures = {}
	local ok, body = pcall(vim.json.decode, response.body or "")
	if not ok then
		vim.notify("Could not capture response variables because the body is not valid JSON", vim.log.levels.WARN, {
			title = "rest.nvim",
		})
		return
	end

	for _, capture in ipairs(captures) do
		local value = json_path(body, capture.path)
		if value == nil then
			vim.notify(
				("Could not capture %s: response.json.%s was not found"):format(capture.name, capture.path),
				vim.log.levels.WARN,
				{ title = "rest.nvim" }
			)
		elseif type(value) == "table" then
			set(capture.name, vim.json.encode(value))
		else
			set(capture.name, tostring(value))
		end
	end
end

function M.setup(current_buffer)
	_G.RestNvimVariableComplete = function()
		local bufnr = current_buffer()
		return bufnr and names(bufnr) or {}
	end

	vim.api.nvim_create_user_command("RestSet", function(opts)
		local name, value = opts.args:match("^(%S+)%s+(.+)$")
		if not name then
			vim.notify("Usage: RestSet <name> <value>", vim.log.levels.WARN, { title = "rest.nvim variables" })
			return
		end
		set(name, value)
	end, {
		nargs = "+",
		complete = function()
			local bufnr = current_buffer()
			return bufnr and names(bufnr) or {}
		end,
		desc = "Set a rest.nvim session variable",
	})

	vim.api.nvim_create_user_command("RestUnset", function(opts)
		session_variables[opts.args] = nil
		vim.env[opts.args] = nil
		local bufnr = current_buffer()
		if bufnr then
			M.prepare(bufnr)
		end
	end, {
		nargs = 1,
		complete = function()
			return vim.tbl_keys(session_variables)
		end,
		desc = "Clear a rest.nvim session variable override",
	})
end

return M
