local t = {}

local jassFormat = function(line, subArgs)
	assert(line, 'no line')

	if (type(subArgs) ~= 'table') then
		return line
	end

	for type in string.gmatch(line, '%%.-(%a)') do
		if (type == 'j') then
			if (subArgs[pos] ~= nil) then
				subArgs[pos] = toJassValue(subArgs[pos])
			end
		end
	end

	line = line:gsub('%%j', '%%s')

	return string.format(line, unpack(subArgs))
end

local function create()
	local this = {}

	this.varLines = {}

	local function addVarLine(s)
		this.varLines[#this.varLines + 1] = s
	end

	this.vars = {}

	function this:addVar(nameRaw, type, index, val)
		assert(nameRaw, 'no name')
		assert(type, 'no type')

		local name = nameRaw--toJassName(nameRaw)

		local expr

		if (index ~= nil) then
			expr = name..'['..index..']'
		else
			expr = name
		end

		local t = {}

		t[#t + 1] = 'static'
		t[#t + 1] = type
		if (index ~= nil) then
			t[#t + 1] = 'array'
		end
		t[#t + 1] = name
		if (val ~= nil) then
			if (index == nil) then
				t[#t + 1] = '='
				t[#t + 1] = val
			else
				this:addLine([[set %s = %s]], {expr, val})
			end
		end

		if (this.vars[name] ~= nil) then
			return expr
		end

		this.vars[name] = name

		if (index ~= nil) then
			--if (this ~= pathSharedJStreams[folder]) then
				--pathSharedJStreams[folder]:addVar(nameRaw, type, index)

				return expr
			--end
		end

		addVarLine(table.concat(t, ' '))

		return expr
	end

	this.lines = {}

	function this:addLine(line, subArgs)
		assert(line, 'no line')

		line = jassFormat(line, subArgs)

		if ((string.find(line, 'static') ~= 1) and (string.find(line, 'end') ~= 1)) then
			line = '\t'..line
		end

		this.lines[#this.lines + 1] = line
	end

	function this:write()
		local t = {}

		for i = 1, #this.varLines, 1 do
			t[#t + 1] = this.varLines[i]
		end

		for i = 1, #this.lines, 1 do
			t[#t + 1] = this.lines[i]
		end

		return t
	end

	return this
end

t.create = create

expose('vjass', t)