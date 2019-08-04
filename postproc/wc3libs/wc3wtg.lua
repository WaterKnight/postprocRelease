require 'waterlua'

local t = {}

local function create()
	local this = {}

	function this:addTrig()
		local trig = {}

		return trig
	end

	--format 7
	local guiTrigData

	local function initGuiTrigData()
		if guiTrigData then
			return guiTrigData.funcArgs
		end

		local funcArgs = {}

		local cat
		local f = io.local_open('TriggerData.txt')

		local catArgsOffset = {}

		catArgsOffset['TriggerEvents'] = 2
		catArgsOffset['TriggerConditions'] = 2
		catArgsOffset['TriggerActions'] = 2
		catArgsOffset['TriggerCalls'] = 4

		for line in f:lines() do
			if ((line ~= '') and (line:find('//', 1, true) ~= true)) then
				if (line:sub(1, 1) == '[') then
					cat = line:sub(2, line:find(']', 1, true) - 1)
				end
				if ((cat == 'TriggerEvents') or (cat == 'TriggerConditions') or (cat == 'TriggerActions') or (cat == 'TriggerCalls')) then
					if ((line:sub(1, 1) ~= '_') and line:find('=', 1, true)) then
						local field = line:sub(1, line:find('=', 1, true) - 1)
						local args = line:sub(line:find('=', 1, true) + 1, line:len()):split(',')

						local function add(...)
							local arg = {...}
							local n = select('#', ...)
							local t = {}

							for c = 1, n, 1 do
								if (arg[c] ~= 'nothing') then
									t[c] = arg[c]
								end
							end

							return t
						end

						args = add(unpack(args, catArgsOffset[cat], #args))

						funcArgs[field] = args
					end
				end
			end
		end

		f:close()

		guiTrigData = {}

		guiTrigData.funcArgs = funcArgs

		return funcArgs
	end

	local function maskFunc(root)
		local funcArgs = initGuiTrigData()

		if (funcArgs == nil) then
			error('guiTrigMaskFunc - missing funcArgs from TriggerData.txt')
		end

		root:add('startToken', 'id')
		root:add('format', 'int')

		checkFormatVer('guiTrigMaskFunc', 7, root:getVal('format'))

		local function createTrigCat(index)
			local c = root:addNode('trigCategory'..index)

			c:add('index', 'int')
			c:add('name', 'string')
			c:add('type', 'int')
		end

		root:add('trigCategoriesAmount', 'int')
		for i = 1, root:getVal('trigCategoriesAmount'), 1 do
			createTrigCat(i)
		end

		root:add('unknownNumB', 'int')

		local varArrayTable = {}

		local function createVar(index)
			local v = root:addNode('var'..index)

			local name = v:add('name', 'string')
			v:add('type', 'string')
			v:add('unknownNumE', 'int')
			local arrayFlag = v:add('arrayFlag', 'int')
			v:add('arraySize', 'int')
			v:add('initFlag', 'int')
			v:add('initVal', 'string')

			if (arrayFlag:getVal() ~= 0) then
				varArrayTable[name:getVal()] = true
			end
		end

		root:add('varAmount', 'int')
		for i = 1, root:getVal('varAmount'), 1 do
			createVar(i)
		end

		local function createTrig(index)
			local t = root:addNode('trig'..index)

			t:add('name', 'string')
			t:add('description', 'string')
			t:add('comment', 'int')
			t:add('enabled', 'int')
			t:add('customTxtFlag', 'int')
			t:add('initFlag', 'int')
			t:add('runOnMapInit', 'int')
			t:add('categoryIndex', 'int')

			t:add('ECAAmount', 'int')

			local function createECA(parent, index, hasBranch)
				local eca = parent:addNode('ECA'..index)

				eca:add('type', 'int')

				if hasBranch then
					eca:add('branch', 'int')
				end

				local field = eca:add('funcName', 'string')
				eca:add('enabled', 'int')

				local function createParam(parent, index, paramType)
					local param = parent:addNode('param'..index)

					if ((paramType == 'boolexpr') or (paramType == 'boolcall') or (paramType == 'eventcall')) then
						param:add('boolexpr_unknown1', 'int')
						param:add('boolexpr_unknown2', 'int')
						param:add('boolexpr_unknown3', 'char')

						createECA(param, '('..paramType..')', false)

						param:add('boolexpr_endToken', 'int')
					elseif (paramType == 'code') then
						param:add('code_unknown1', 'int')
						local dummyDoNothing = param:add('code_dummyDoNothing', 'int')
						if (dummyDoNothing:getVal() == 0x100) then
							param:add('code_unknown2', 'char')
						else
							for i = 2, 11, 1 do
								param:add('code_unknown'..i, 'char')
							end
						end

						createECA(param, '(code)', false)

						param:add('code_endToken', 'int')
					else
						local type = param:add('type', 'int')
						local val = param:add('val', 'string')

						local beginFunc = param:add('beginFunc', 'int')

						if (beginFunc:getVal() == 1) then
							param:add('beginFunc_type', 'int')

							local pos = root.scope:getCurReadPos()

							local field = param:add('beginFunc_val', 'string')
							param:add('beginFunc_beginFunc', 'int')

							field = field:getVal()

							if funcArgs[field] then
								for i = 1, #funcArgs[field], 1 do
									createParam(param, i, funcArgs[field][i])
								end
							else
								error('unknown func '..field..' at '..pos..' '..string.format('%x', pos))
							end

							param:add('beginFunc_endToken', 'int')
						end

						param:add('endToken', 'int')

						if ((type:getVal() == 1) and varArrayTable[val:getVal()]) then
							createParam(param, '(arrayIndex)', 'int')
						end
					end
				end

				field = field:getVal()

				if funcArgs[field] then
					for i = 1, #funcArgs[field], 1 do
						createParam(eca, i, funcArgs[field][i])
					end
				else
					error('unknown func '..field)
				end

				eca:add('ECAAmount', 'int')

				for i = 1, eca:getVal('ECAAmount'), 1 do
					createECA(eca, i, true)
				end
			end

			for i = 1, t:getVal('ECAAmount'), 1 do
				createECA(t, i, false)
			end
		end

		root:add('trigAmount', 'int')
		for i = 1, root:getVal('trigAmount'), 1 do
			createTrig(i)
		end
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		root:setVal('format', 1)

		for i = 1, #this.trigs, 1 do
			local trigNode = root:addNode('trig'..i)


		end

		root:writeToFile(path, maskFunc)
	end

	function this:readFromFile(path)
		assert(path, 'no path')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		root:readFromFile(path, maskFunc)

		local trigsCount = root:getVal('trigsCount')

		for i = 1, trigsCount, 1 do
			local trigNode = root:getSub('trig'..i)

			local trig = this:addTrig()


		end
	end

	return this
end

expose('wc3wtg', t)