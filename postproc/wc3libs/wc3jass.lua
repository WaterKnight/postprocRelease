--local identifierPat = "[A-Za-z0-9_$]"
local identifierPat = '[A-Za-z_$][A-Za-z0-9_$]*'

local t = {}

local function syntaxCheck(paths, throwError)
	paths = totable(paths)

	assert(paths, 'no paths')

	local res, errorMsg, outMsg = osLib.runProg(nil, io.local_dir()..'pjass.exe', paths)

	if throwError then
		assert(res, 'syntax in files '..table.concat(paths, '\t')..' malformed:\n'..outMsg)
	end

	return res, errorMsg, outMsg
end

t.syntaxCheck = syntaxCheck

local function syntaxCheckByWc3(path, wc3path)
	assert(wc3path, 'no wc3path')

	path = path or {}

	require 'portLib'

	local outputDir = io.local_dir()..[[Temp\]]

	mpqExtractLatest(path, [[Scripts\common.j]], outputDir, wc3path)
	mpqExtractLatest(path, [[Scripts\blizzard.j]], outputDir, wc3path)

	local res, errorMsg, outMsg = osLib.runProg(nil, io.local_dir()..'pjass.exe', {outputDir..[[Scripts\common.j]], outputDir..[[Scripts\blizzard.j]], path})

	return res, errorMsg, outMsg
end

t.syntaxCheckByWc3 = syntaxCheckByWc3

local function create()
	local this = {}

	this.types = {}
	this.typesByName = {}

	function this:createType(name, base)
		assert(name, 'no name')

		if (this.typesByName[name] ~= nil) then
			error('type '..name..' already declared')

			return
		end

		local ty = {}

		ty.name = name

		function ty:remove()
			this.typesByName[ty.name] = nil
			table.remove(this.types, ty.parentIndex)

			for i = ty.parentIndex, #this.types, 1 do
				this.types[i].parentIndex = i
			end
		end

		function ty:rename(name)
			this.typesByName[ty.name] = nil

			ty.name = name

			this.typesByName[name] = ty
		end

		function ty:setBase(base)
			ty.base = base
		end

		ty:setBase(base)

		function ty:output(outputWrite)
			local t = {}

			table.insert(t, 'type')
			table.insert(t, ty.name)
		
			if (ty.base ~= nil) then
				table.insert(t, 'extends')
				table.insert(t, ty.base)
			end
		
			outputWrite(table.concat(t, ' '))
		end

		ty.parentIndex = #this.types + 1

		this.types[ty.parentIndex] = ty
		this.typesByName[name] = ty

		return ty
	end

	function this:getTypeByName(name)
		local result = this.typesByName[name]

		if (result == nil) then
			--print('warning: type '..name..' does not exist')
		end

		return result
	end

	this.globals = {}
	this.globalsByName = {}

	function this:createGlobal(name, type, isArray, val, isConst)
		assert(name, 'no name')

		if (this.globalsByName[name] ~= nil) then
			error('global '..name..' already declared')

			return
		end

		local glob = {}

		glob.name = name
		glob.type = type
		glob.isArray = isArray
		glob.val = val
		glob.isConst = isConst

		function glob:remove()
			this.globalsByName[glob.name] = nil
			table.remove(this.globals, glob.parentIndex)

			for i = glob.parentIndex, #this.globals, 1 do
				this.globals[i].parentIndex = i
			end
		end

		function glob:rename(name)
			this.globalsByName[glob.name] = nil

			glob.name = name

			this.globalsByName[name] = glob
		end

		function glob:output(outputWrite)
			local t = {}
		
			if glob.isConst then
				table.insert(t, 'constant')
			end
		
			table.insert(t, glob.type)
		
			if glob.isArray then
				table.insert(t, 'array')
			end
		
			table.insert(t, glob.name)
		
			if glob.val then
				table.insert(t, '=')
		
				table.insert(t, glob.val)
			end
		
			outputWrite('\t'..table.concat(t, ' '))
		end

		glob.parentIndex = #this.globals + 1

		this.globals[glob.parentIndex] = glob
		this.globalsByName[name] = glob

		return glob
	end

	function this:getGlobalByName(name)
		local result = this.globalsByName[name]

		if (result == nil) then
			--print('warning: global '..name..' does not exist')
		end

		return result
	end

	this.funcs = {}
	this.funcsByName = {}

	function this:createFunc(name)
		assert(name, 'no name')

		if (this.funcsByName[name] ~= nil) then
			error('function '..name..' already declared')

			return
		end

		local func = {}

		func.name = name
		func.params = {}
		func.lines = {}

		function func:remove()
			this.funcsByName[func.name] = nil
			table.remove(this.funcs, func.parentIndex)

			for i = func.parentIndex, #this.funcs, 1 do
				this.funcs[i].parentIndex = i
			end
		end

		function func:move(newIndex)
			if (newIndex < 1) then
				newIndex = 1
			elseif (newIndex > #this.funcs) then
				newIndex = #this.funcs
			end

			func:remove()

			this.funcsByName[func.name] = func
			table.insert(this.funcs, newIndex, func)

			for i = newIndex, #this.funcs, 1 do
				this.funcs[i].parentIndex = i + 1
			end
		end

		function func:rename(name)
			this.funcsByName[func.name] = nil

			func.name = name

			this.funcsByName[name] = func
		end

		function func:setNative(isNative)
			func.isNative = isNative
		end

		function func:addLine(line, index)
			assert(line, 'no line')

			local line = line:split('\n')

			local c = 0

			for i = 1, #line, 1 do
				local line = line[i]:match('%s*([^%s].*[^%s])%s*')

				if (line ~= nil) then
					line = line:gsub('%s+', ' ')

					if index then
						table.insert(func.lines, index + c, line)
					else
						func.lines[#func.lines + 1] = line
					end

					c = c + 1
				end
			end
		end

		function func:setReturnType(type)
			func.returnType = type
		end

		function func:addParam(name, type)
			assert(name, 'no name')
			assert(type, 'no type')

			local t = {}

			t.name = name
			t.type = type

			func.params[#func.params + 1] = t
		end

		function func:output(outputWrite)
			local t = {}

			if func.isNative then
				table.insert(t, 'native')
			else
				table.insert(t, 'function')
			end

			table.insert(t, func.name)
			table.insert(t, 'takes')
		
			if (#func.params > 0) then
				local t2 = {}

				for i = 1, #func.params, 1 do
					table.insert(t2, func.params[i].type..' '..func.params[i].name)
				end
		
				table.insert(t, table.concat(t2, ','))
			else
				table.insert(t, 'nothing')
			end
		
			table.insert(t, 'returns')
		
			if func.returnType then
				table.insert(t, func.returnType)
			else
				table.insert(t, 'nothing')
			end

			outputWrite(table.concat(t, ' '))

			if not func.isNative then		
				for i = 1, #func.lines, 1 do
					outputWrite('\t'..func.lines[i])
				end

				outputWrite('endfunction')
			end
		end

		func.parentIndex = #this.funcs + 1

		this.funcs[func.parentIndex] = func
		this.funcsByName[name] = func

		return func
	end

	function this:getFuncByName(name)
		local result = this.funcsByName[name]

		if (result == nil) then
			--print('warning: func '..name..' does not exist')
		end

		return result
	end

	function this:merge(other)
		assert(other, 'no other')

		for _, global in pairs(other.globals) do
			local newGlobal = this:createGlobal(global.name, global.type, global.isArray, global.val, global.isConst)
		end

		for _, func in pairs(other.funcs) do
			local newFunc = this:createFunc(func.name)

			local params = func.params

			for i = 1, #params, 1 do
				local param = params[i]

				newFunc:addParam(param.name, param.type)
			end

			newFunc:setReturnType(func.returnType)

			local lines = func.lines

			for i = 1, #lines, 1 do
				local line = lines[i]

				newFunc:addLine(line)
			end
		end
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		local function writeTable(path, t)
			assert(path, 'no path')
			assert(t, 'no content')

			local f = io.open(path, 'w+')

			assert(f, 'cannot open '..path)

			f:write(table.concat(t, '\n'))

			f:close()
		end

		local output = {}
		local outputC = 0

		local function outputWrite(s)
			outputC = outputC + 1
			output[outputC] = s
		end

		for i = 1, #this.types, 1 do
			local ty = this.types[i]

			ty:output(outputWrite)
		end

		for i = 1, #this.funcs, 1 do
			local func = this.funcs[i]

			if func.isNative then
				func:output(outputWrite)
			end
		end

		outputWrite('globals')

		for i = 1, #this.globals, 1 do
			local var = this.globals[i]

			var:output(outputWrite)
		end

		outputWrite('endglobals')

		for i = 1, #this.funcs, 1 do
			local func = this.funcs[i]

			if not func.isNative then
				func:output(outputWrite)
			end
		end

		writeTable(path, output)
	end

	function this:readFromFile(path, wc3path)
		assert(path, 'no path')

		if (wc3path ~= nil) then
			local syntaxRes, syntaxErrorMsg, syntaxOutMsg = t.syntaxCheck(path, wc3path)

			assert(syntaxRes, 'syntax in file '..path..' malformed:\n'..syntaxOutMsg)
		end

		local input = io.open(path, 'r')

		assert(input, 'cannot open '..path)

		local inputLines = {}
		local inputLinesC = 0

		for line in input:lines() do
			if line:find('//', 1, true) then
				line = line:sub(1, line:find('//', 1, true) - 1)
			end

			line = line:match('%s*([^%s].*[^%s])%s*')

			if (line ~= nil) then
				line = line:gsub('%s+', ' ')

				inputLinesC = inputLinesC + 1
				inputLines[inputLinesC] = line
			end
		end

		input:close()

		local foundGlobals = false

		local i = 1

		while (i <= #inputLines) do
			local line = inputLines[i]

			if line:match('^type') then
				local name, base = line:match('^type%s+('..identifierPat..')%s+extends%s+('..identifierPat..')')

				if (name == nil) then
					name, base = line:match('^type%s+('..identifierPat..')')
				end

				this:createType(name, base)

				i = i + 1
			elseif line:match('globals$') then
				assert(not foundGlobals, 'already had a globals block')

				foundGlobals = true

				i = i + 1

				while ((i <= #inputLines)) do
					line = inputLines[i]

					if line:match('endglobals$') then
						break
					end

					local varType, varName = line:match('('..identifierPat..') array ('..identifierPat..')')

					if (varType ~= nil) then
						this:createGlobal(varName, varType, true, nil, false)
					else
						local varType, varName, val = line:match('('..identifierPat..') ('..identifierPat..')%s*=%s*(.+)')

						if (varType ~= nil) then
							this:createGlobal(varName, varType, false, val, false)
						else
							local varType, varName, val = line:match('const ('..identifierPat..') ('..identifierPat..')%s*=%s*(.+)')

							if (varType ~= nil) then
								this:createGlobal(varName, varType, false, val, true)
							else
								local varType, varName = line:match('('..identifierPat..') ('..identifierPat..')')

								if (varType ~= nil) then
									this:createGlobal(varName, varType, false, nil, false)
								else
									error('malformed variable definition in line:\n'..line)
								end
							end
						end
					end

					i = i + 1
				end

				assert(i <= #inputLines, 'missing endglobals')

				i = i + 1

				--break
			else
				local isNative = false
				local funcName, argLine, returnType = line:match('function ('..identifierPat..') takes (.*) returns ('..identifierPat..')$')

				if (funcName == nil) then
					funcName, argLine, returnType = line:match('native ('..identifierPat..') takes (.*) returns ('..identifierPat..')$')

					isNative = true
				end

				--assert(funcName, 'expected function declaration in line:\n'..line)

				if (funcName ~= nil) then
					local func = this:createFunc(funcName)

					func:setNative(isNative)

					if (returnType ~= 'nothing') then
						func:setReturnType(returnType)
					end

					local args = argLine:split(',')

					for i2 = 1, #args, 1 do
						if (args[i2] ~= 'nothing') then
							local argType, argName = args[i2]:match('('..identifierPat..')%s('..identifierPat..')')

							func:addParam(argName, argType)
						end
					end

					if not isNative then
						i = i + 1

						while ((i <= #inputLines)) do
							line = inputLines[i]

							if line:find('endfunction$') then
								break
							end

							func:addLine(line)

							i = i + 1
						end
					end

					assert(i <= #inputLines, 'missing endfunction')

					i = i + 1
				else
					i = i + 1
				end
			end
		end
	end

	return this
end

t.create = create

local function getNatives(path)
	assert(path, 'no path')

	local j = t.create()

	j:readFromFile(path)

	return j
end

t.getNatives = getNatives

 local function getNativesByWc3(wc3path)
	assert(wc3path, 'no path')

	local j = t.create()

	require 'portLib'

	local outputDir = io.local_dir()..[[Temp\]]

	mpqExtractLatest(nil, [[Scripts\common.j]], outputDir, wc3path)

	j:readFromFile(outputDir..[[Scripts\common.j]])

	return j
end

t.getNativesByWc3 = getNativesByWc3

expose('wc3jass', t)