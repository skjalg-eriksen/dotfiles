local M = {}

local faker = require("nvim-faker.faker-cli")

local faker_commands = {
	["$fake.adjective"] = "word adjective",
	["$fake.firstName"] = "person firstName",
	["$fake.noun"] = "word noun",
	["$fake.sentence"] = "lorem sentence",
	["$fake.title"] = "lorem words 3",
	["$fake.verb"] = "word verb",
	["$fake.word"] = "word sample",
}

local function fake(command)
	local value, err = faker.execute_faker_cli_command(command)
	if not value then
		error("faker.nvim: " .. (err or "failed to generate a value"), 0)
	end
	return vim.trim(value)
end

local function random_item(values)
	return values[math.random(#values)]
end

local function random_string(length)
	local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
	local result = {}
	for _ = 1, length do
		local index = math.random(#chars)
		table.insert(result, chars:sub(index, index))
	end
	return table.concat(result)
end

local function quoted_arguments(value)
	local result = {}
	for argument in value:gmatch([['([^']*)']]) do
		table.insert(result, argument)
	end
	for argument in value:gmatch([["([^"]*)"]]) do
		table.insert(result, argument)
	end
	return result
end

function M.generate(name)
	if faker_commands[name] then
		return fake(faker_commands[name])
	end

	local min, max = name:match("^%$randomInt%((%-?%d+),%s*(%-?%d+)%)$")
	if min then
		return tostring(math.random(tonumber(min), tonumber(max)))
	end

	local length = name:match("^%$randomString%((%d+)%)$")
	if length then
		return random_string(tonumber(length))
	end

	if name:match("^%$randomChoice%(") then
		local choices = quoted_arguments(name)
		if #choices > 0 then
			return random_item(choices)
		end
	end
end

local function supports(name)
	return faker_commands[name] ~= nil
		or name:match("^%$randomInt%((%-?%d+),%s*(%-?%d+)%)$") ~= nil
		or name:match("^%$randomString%((%d+)%)$") ~= nil
		or name:match("^%$randomChoice%(") ~= nil
end

function M.register(bufnr)
	local dynamic_variables = require("rest-nvim.config").custom_dynamic_variables
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	for _, line in ipairs(lines) do
		for name in line:gmatch("{{%s*(%$.-)%s*}}") do
			local dynamic_name = vim.trim(name)
			if supports(dynamic_name) then
				dynamic_variables[dynamic_name] = function()
					return M.generate(dynamic_name)
				end
			end
		end
	end
end

return M
