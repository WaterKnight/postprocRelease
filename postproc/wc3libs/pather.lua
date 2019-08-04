local t = {}

local function getFolderType(path)
	assert(path, 'no path')

	if (path:sub(path:len() - 4, path:len()) == '.page') then
		return 'page'
	elseif (path:sub(path:len() - 4, path:len()) == '.pack') then
		return 'pack'
	elseif (path:sub(path:len() - 6, path:len()) == '.struct') then
		return 'struct'
	end

	return nil
end

t.getFolderType = getFolderType

local function getScriptRallyPath(path)
	assert(path, 'no path')

	local t = path:split('\\')

	local c = 1
	local lastStruct

	for k, v in pairs(t) do
		if (v == '') then
			t[k] = nil
		end
	end

	while t[c] do
		if (getFolderType(t[c]) == 'struct') then
			lastStruct = c
		end

		c = c + 1
	end

	if (lastStruct == nil) then
		return path
	end

	c = lastStruct + 1

	while (t[c] and (getFolderType(t[c]) == nil)) do
		c = c + 1
	end

	return table.concat(t, '\\', 1, c - 1)..'\\'
end

t.getScriptRallyPath = getScriptRallyPath

local function createPathMap(rootPath)
	assert(rootPath, 'no rootPath')

	local this = {}

	this.pathMap = {}

	function this:setRootPath(path)
		this.rootPath = io.toAbsPath(path)
	end

	this:setRootPath(rootPath)

	function this:reduceName(name)
		assert(name, 'no name')

		name = name:lower()
		name = name:gsub(' ', '')
		name = name:gsub('-', '')
		name = name:gsub([[']], '')

		return name
	end

	function this:add(key, target, keyIsName)
		assert(key, 'no key')
		assert(target, 'no target')

		if keyIsName then
			key = this:reduceName(key)
		end

		this.pathMap[key] = target
	end

	function this:getRefPath(path)
		assert(path, 'no path')

		path = io.toAbsPath(path)

		assert(rootPath, 'no rootpath set')

		local pos, posEnd = path:find(rootPath, 1, true)

		assert(pos, 'no '..tostring(rootPath)..' in '..tostring(path))

		path = path:sub(posEnd + 1, path:len())

		local curScope
		local t = path:split([[\]])

		path = nil

		for _, v in pairs(t) do
			if (v ~= '') then
				local include
				local type = getFolderType(v)

				if (type == 'page') then
					include = true
				elseif ((curScope == 'page') or (curScope == 'struct')) then
					if (type == 'pack') then
						curScope = type
					else
						include = true
					end
				end

				if include then
					if path then
						path = path..v..'\\'
					else
						path = v..'\\'
					end
				end

				if type then
					curScope = type
				end
			end
		end

		if (path == nil) then
			return ''
		end

		return path
	end

	function this:toFullPath(base, value, mainExtension)
		assert(this.rootPath, 'no rootPath set')

		assert(value, 'no path')

		value = value:dequote()

		local name = value

		if ((getFileExtension(value) == nil) and mainExtension) then
			value = value..'.'..mainExtension
		end

		if this.pathMap[value] then
			return this.pathMap[value]
		end

		local result

		if base then
			result = this:getRefPath(getFolder(base))..value

			if this.pathMap[result] then
				return this.pathMap[result]
			end
		end

		result = rootPath..value

		if this.pathMap[result] then
			return this.pathMap[result]
		end

		result = this:reduceName(name)

		if this.pathMap[result] then
			return this.pathMap[result]
		end

		return nil
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		local f = io.open(path, 'w+')

		local t = {}

		for key, target in pairs(this.pathMap) do
			if (t[target] == nil) then
				t[target] = {}
			end

			t[target][key] = key
		end

		for target, keys in pairs(t) do
			f:write('//', target, '\n')

			for key in pairs(keys) do
				f:write('\t', key, '\n')
			end
		end

		f:close()
	end

	return this
end

t.createPathMap = createPathMap

pather = t