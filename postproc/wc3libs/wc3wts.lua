local t = {}

local function create()
	local this = {}

	this.strings = {}
	this.stringsLower = {}

	function this:getString(key)
		assert(key, 'no key')

		return this.strings[key]
	end

	function this:translate(s)
		local pos, posEnd, cap = s:find('TRIGSTR_0*(%d+)')

		while (pos ~= nil) do
			local key = tonumber(cap)

			local val = this:getString(key)

			if (val ~= nil) then
				s = s:sub(1, pos - 1)..val..s:sub(posEnd + 1, s:len())
			else
				s = s:sub(1, pos - 1)..'$'..'TRIGSTR_'..cap..'_NOT_FOUND'..'$'..s:sub(posEnd + 1, s:len())
			end

			pos, posEnd, cap = s:find('TRIGSTR_0*(%d+)')
		end

		local pos, posEnd, key = s:find('([^%s]+)', 1)

		while (pos ~= nil) do
			local val = this:getString(key) or this.stringsLower[key:lower()]

			if (val ~= nil) then
				s = s:sub(1, pos - 1)..val..s:sub(posEnd + 1, s:len())

				pos = pos + val:len()
			else
				pos = posEnd + 1
			end

			pos, posEnd, key = s:find('([^%s]+)', pos)
		end

		return s
	end

	function this:addString(key, val)
		assert(key, 'no key')
		assert(val, 'no val')

		this.strings[key] = val

		if (type(key) == 'string') then
			this.stringsLower[key:lower()] = val
		end
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		local f = io.open(path, 'w+')

		assert(f, string.format('could not open %s', path))

		for key, val in pairs(this.strings) do
			f:write(string.format('STRING %s\n{\n%s\n}\n', key, val))
		end

		f:close()
	end

	function this:readFromFile(path)
		assert(path, 'no path')

		local f = io.open(path, 'rb')

		assert(f, string.format('could not open %s', path))

		local input = f:read('*a')

		f:close()

		input = input:gsub('//[^\n]*\n', '')

		local t = {}

		for k, v in input:gmatch('STRING ([%d]+)[\n%s]*{([^}]*)[\n]*}') do
			local key = tonumber(k)
			local val = v

			val = val:match('^%c*(.*)')
			val = val:match('^(.*%C)')

			val = val or ''

			this:addString(key, val)
		end
	end

	function this:addTextFile(path)
		assert(path, 'no path')

		local f = io.open(path, 'r')

		assert(f, string.format('could not open %s', path))

		local input = f:read('*a')

		f:close()

		for _, line in pairs(input:split('\n')) do
			line = line:gsub('%c', '')

			local key, val = line:match('([^=]+)=(.+)')

			if (key ~= nil) then
				val = val:match('"*([^"]*)"*') or val

				this:addString(key, val)
			end
		end
	end

	return this
end

t.create = create

expose('wc3wts', t)