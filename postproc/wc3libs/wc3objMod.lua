require 'waterlua'

local t = {}

local function create(restrictedFieldsPool)
	local this = {}

	this.objs = {}

	this.origObjs = {}
	this.customObjs = {}

	this.fieldsPool = {}

	function this:addToFieldsPool(field, type)
		assert(field, 'no field')

		local t = {}

		this.fieldsPool[field] = t

		t.type = type
	end

	function this:addToFieldsPoolByMetaSlk(input)
		assert(input, 'no input')

		assert((type(input) == 'table') or (type(input) == 'string'), 'input neither table nor string')

		local slk

		if (type(input) == 'table') then
			slk = input
		else
			io.local_require([[slkLib]])

			slk = module_wc3slk.createSlk()

			slk:readFromFile(path)
		end

		for obj, objData in pairs(slk.objs) do
			this:addToFieldsPool(objData.vals['ID'], objData.vals['type'])
		end
	end

	function this:getObj(id)
		assert(id, 'no id')

		return this.objs[id]
	end

	function this:addObj(id, baseId)
		assert(id, 'no id')

		local obj = this.objs[id]

		assert((obj == nil), 'obj '..tostring(id)..' already used')

		obj = {}

		this.objs[id] = obj

		obj.baseId = baseId
		obj.custom = (baseId ~= nil)

		obj.fields = {}

		if custom then
			table.insert(this.customObjs, id)
		else
			table.insert(this.origObjs, id)
		end

		function obj:get(field, level)
			assert(field, 'no field')

			local fieldData = obj.fields[field]
print('A')
			if (fieldData == nil) then
				return nil
			end
print('B')
			if (level == nil) then
				level = 1
			end

			assert((type(level) == 'number'), 'level is not a number')

			local levelData = fieldData[level]
print('C', level)
			if (levelData == nil) then
				return nil
			end
print('D')
			return levelData.val
		end

		function obj:getAllLevels(field)
			assert(field, 'no field')

			local fieldData = obj.fields[field]

			local t = {}

			if (fieldData == nil) then
				return t
			end

			for level, levelData in pairs(fieldData) do
				t[level] = levelData.val
			end

			return t
		end

		function obj:setRaw(field, varType, val, level, dataPointer)
			assert(field, 'no field')

			local fieldData = obj.fields[field]

			if (fieldData == nil) then
				if restrictedFieldsPool then
					assert(this.fieldsPool[field], 'field '..tostring(field)..' not in fieldsPool')
				end

				fieldData = {}

				obj.fields[field] = fieldData
			end

			local fieldPoolData = this.fieldsPool[field]

			if (fieldPoolData ~= nil) then
				local fieldPoolDataType = fieldPoolData.type

				if (fieldPoolDataType ~= nil) then
					local valType = type(val)

					local throw = false

					if (fieldPoolDataType == 'bool') then
						if (valType ~= 'boolean') then
							throw = true
						end
					elseif ((fieldPoolDataType == 'int') or (fieldPoolDataType == 'channelType') or (fieldPoolDataType == 'channelFlags')) then
						if not isInt(val) then
							throw = true
						end
					elseif ((fieldPoolDataType == 'real') or (fieldPoolDataType == 'unreal')) then
						if (valType ~= 'number') then
							throw = true
						end
					else
						if (valType ~= 'string') then
							throw = true
						end
					end

					if throw then
						error(string.format('incompatible value '..tostring(val)..' <%s> for field %s, expected '..fieldPoolDataType, valType, field))
					end
				end
			end

			if (level == nil) then
				level = 1
			end

			assert((type(level) == 'number'), 'level is not a number')

			local levelData = fieldData[level]

			if (levelData == nil) then
				levelData = {}

				fieldData[level] = levelData
			end

			levelData.varType = varType
			levelData.val = val
			levelData.dataPointer = dataPointer
		end

		function obj:set(field, val, level)
			obj:setRaw(field, nil, val, level, nil)
		end

		function obj:addVal(field, varType, val, dataPointer)
			assert (field 'no field')

			local fieldData = objData.fields[field]
			local level

			if (fieldData == nil) then
				level = 1
			else
				level = #fieldData + 1
			end

			this:objSetVal(obj, field, varType, val, level, dataPointer)
		end

		function obj:deleteVal(field, level)
			assert(field, 'no field')

			local fieldData = obj.fields[field]

			assert(fieldData, 'field '..tostring(field)..' not available')

			if (level == nil) then
				level = 0
			end

			fieldData[level] = nil

			if (table.getSize(fieldData) == 0) then
				obj.fields[field] = nil
			end
		end

		function obj:remove()
			this.objs[id] = nil

			if obj.custom then
				local index

				for i, objId in pairs(this.customObjs) do
					if (objId == id) then
						index = i
					end
				end

				table.remove(this.customObjs, i)
			else
				local index

				for i, objId in pairs(this.origObjs) do
					if (objId == id) then
						index = i
					end
				end

				table.remove(this.origObjs, i)
			end
		end

		return obj
	end

	function this:merge(otherObjMod)
		assert(otherObjMod, 'no other objMod')

		for objId, otherObjData in pairs(otherObjMod.objs) do
			local objData = this:getObj(objId)

			if (objData == nil) then
				objData = this:addObj(objId, otherObjData.baseId)
			end

			for field, fieldData in pairs(otherObjData.fields) do
				for level, levelData in pairs(fieldData) do
					objData:setRaw(field, levelData.varType, levelData.val, level, levelData.dataPointer)
				end
			end
		end
	end

	function this:copy()
		local other = create()

		other:merge(this)

		return other
	end

	function this:print()
		for objId, objData in pairs(this.objs) do
			print(objId, objData.baseId)

			for field, fieldData in pairs(objData.fields) do
				print('\t', field)

				for level, levelData in pairs(fieldData) do
					print('\t\t', level, ' -> ', levelData.varType, levelData.val, levelData.dataPointer)
				end
			end
		end
	end

	require 'slkLib'

	this.metaSlk = slkLib.create()

	function this:addMeta(path)
		assert(path, 'no path')

		require 'slkLib'

		local slk = slkLib.create()

		slk:readFromFile(path)

		this.metaSlk:merge(slk)
	end

	function this:reduce(reduceMetaSlk)
		assert(reduceMetaSlk, 'no reduceMetaSlk')

		local outSlks = {}
		local outProfiles = {}
		local outObjMod = this--this:copy()

		local slkTrans = {
			
		}

		for objId, obj in pairs(outObjMod.objs) do
			for field, fieldData in pairs(obj.fields) do
				for level, levelData in pairs(fieldData) do
					local metaObj = reduceMetaSlk:getObj(field)

					local deleteFromObjMod = false

					if (metaObj ~= nil) then
						--obj:setRaw(field, metaObj:getVal('type'), levelData.val, level, metaObj:getVal('data'))

						local slkName = metaObj:getVal('slk')

						local slkField = metaObj:getVal('field')

						if (slkName == 'Profile') then
							local profileName = 'profile'

							local outProfile = outProfiles[profileName]

							if (outProfile == nil) then
								outProfile = wc3profile.create()

								outProfiles[profileName] = outProfile
							end

							local val = levelData.val

							local index = level

							if (metaObj:getVal('index') > 0) then
								level = level + metaObj:getVal('index')
							end

							local profileObj = outProfile:getObj(objId)

							if (profileObj == nil) then
								profileObj = outProfile:addObj(objId)
							end

							profileObj:set(slkField, val, index)

							deleteFromObjMod = true
						else
							local slkName = metaObj:getVal('slk')

							if (slkTrans[slkName] ~= nil) then
								slkName = slkTrans[slkName]
							end

							local outSlk = outSlks[slkName]

							if (outSlk == nil) then
								outSlk = slkLib.create()

								outSlks[slkName] = outSlk
							end

							local val = levelData.val

							if (metaObj:getVal('field', true) == 'Data') then
								slkField = slkField..string.char(string.byte('A') + levelData.dataPointer - 1)
							end

							local rep = metaObj:getVal('repeat', true)

							if ((rep ~= nil) and (rep > 0)) then
								slkField = slkField..tonumber(level)
							end

							if (outSlk.fields[slkField] ~= nil) then
								outSlk:addField(slkField)
							end

							local slkObj = outSlk:getObj(objId)

							if (slkObj == nil) then
								slkObj = outSlk:addObj(objId)
							end

							if not outSlk:containsField(slkField) then
								outSlk:addField(slkField)
							end

							slkObj:set(slkField, val)

							deleteFromObjMod = true
						end
					end

					if deleteFromObjMod then
						obj:deleteVal(field, level)

						if (table.getSize(obj.fields) == 0) then
							obj:remove()
						end
					end
				end
			end
		end

		return outSlks, outProfiles, outObjMod
	end

	--format 1
	local function maskFunc(root)
		root:add('fileVersion', 'int')

		wc3binaryFile.checkFormatVer('objMaskFunc', {1, 2}, root:getVal('fileVersion'))

		local varTypes = {}

		varTypes[0] = 'int'
		varTypes[1] = 'float'
		varTypes[2] = 'float'
		varTypes[3] = 'string'

		local function createPack(name)
			local pack = root:addNode(name)

			pack:add('objsAmount', 'int')

			local function createObj(index)
				local obj = pack:addNode('obj'..index)

				obj:add('base', 'id')
				obj:add('id', 'id')
				obj:add('modsAmount', 'int')

				local function createMod(index)
					local mod = obj:addNode('mod'..index)

					mod:add('id', 'id')
					mod:add('varType', 'int')

					mod:add('value', varTypes[mod:getVal('varType')])
					mod:add('endToken', 'id')
				end

				for i = 1, obj:getVal('modsAmount'), 1 do
					createMod(i)
				end
			end

			for i = 1, pack:getVal('objsAmount'), 1 do
				createObj(i)
			end
		end

		createPack('orig')
		createPack('custom')
	end

	--format 1
	local function exMaskFunc(root)
		root:add('fileVersion', 'int')

		wc3binaryFile.checkFormatVer('objExMaskFunc', {1, 2}, root:getVal('fileVersion'))

		local varTypes = {}

		varTypes[0] = 'int'
		varTypes[1] = 'float'
		varTypes[2] = 'float'
		varTypes[3] = 'string'

		local function createPack(name)
			local pack = root:addNode(name)

			pack:add('objsAmount', 'int')

			local function createObj(index)
				local obj = pack:addNode('obj'..index)

				obj:add('base', 'id')
				obj:add('id', 'id')
				obj:add('modsAmount', 'int')

				local function createMod(index)
					local mod = obj:addNode('mod'..index)

					mod:add('id', 'id')
					mod:add('varType', 'int')
					mod:add('variation', 'int')
					mod:add('dataPointer', 'int')

					mod:add('value', varTypes[mod:getVal('varType')])
					mod:add('endToken', 'id')
				end

				for i = 1, obj:getVal('modsAmount'), 1 do
					createMod(i)
				end
			end

			for i = 1, pack:getVal('objsAmount'), 1 do
				createObj(i)
			end
		end

		createPack('orig')
		createPack('custom')
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		root:add('fileVersion', 'int')
		root:setVal('fileVersion', 1)

		local varTypes = {}

		varTypes[0] = 'int'
		varTypes[1] = 'float'
		varTypes[2] = 'float'
		varTypes[3] = 'string'

		local isEmpty = true

		local function addPack(name, objTable)
			local function reduce()
				local newTable = {}

				for objIndex, objId in pairs(objTable) do
					local objData = this.objs[objId]

					local modsAmount = 0

					for field, fieldData in pairs(objData.fields) do
						local effLevelsAmount = 0

						for level, levelData in pairs(fieldData) do
							local val = levelData.val

							if ((val ~= false) and (val ~= 0) and (val ~= '')) then
								effLevelsAmount = effLevelsAmount + 1
								modsAmount = modsAmount + 1
							end
						end

						if not (effLevelsAmount > 0) then
							objData.fields[field] = nil
						end
					end

					if (modsAmount > 0) then
						newTable[#newTable + 1] = objId
					end
				end

				objTable = newTable
			end

			reduce()

			local pack = root:addNode(name)

			local objsAmount = table.getSize(objTable)

			pack:add('objsAmount', 'int')
			pack:setVal('objsAmount', objsAmount)

			if (objsAmount > 0) then
				for objIndex, objId in pairs(objTable) do
					local objData = this.objs[objId]

					local objNode = pack:addNode('obj'..objIndex)

					local baseId = objData.baseId or '0000'

					objNode:add('base', 'id')
					objNode:setVal('base', baseId)
					objNode:add('id', 'id')
					objNode:setVal('id', objId)

					local modIndex = 0

					for field, fieldData in pairs(objData.fields) do
						for level, levelData in pairs(fieldData) do
							local val = levelData.val

							if ((val ~= nil) and (val ~= false) and (val ~= 0) and (val ~= '')) then
								modIndex = modIndex + 1

								local modNode = objNode:addNode('mod'..modIndex)

								modNode:add('id', 'id')
								modNode:setVal('id', field)

								local varTypeIndex = levelData.varType

								if (varTypeIndex == nil) then
									local metaSlkObj = this.metaSlk:getObj(field)

									if (metaSlkObj ~= nil) then
										local metaVarType = metaSlkObj:getVal('type')

										local t = {}

										t['bool'] = 0
										t['int'] = 0
										t['real'] = 1
										t['unreal'] = 2
										t['string'] = 3

										varTypeIndex = t[metaVarType]

										if (varTypeIndex == nil) then
											varTypeIndex = 3
										end
									end
								end

								varTypeIndex = varTypeIndex or 0

								local varType = varTypes[varTypeIndex]

								if (val == true) then
									val = 1
								elseif (val == false) then
									val = 0
								end

								modNode:add('varType', 'int')
								modNode:setVal('varType', varTypeIndex)
								modNode:add('value', varType)
								modNode:setVal('value', val)

								modNode:add('variation', 'int')
								modNode:setVal('variation', level)

								local dataPointer = levelData.dataPointer

								if (dataPointer == nil) then
									local metaSlkObj = this.metaSlk.objs[objId]

									if (metaSlkObj ~= nil) then
										varType = metaSlkObj:getVal('data')
									end
								end

								dataPointer = dataPointer or 0

								modNode:add('dataPointer', 'int')
								modNode:setVal('dataPointer', dataPointer)

								modNode:add('endToken', 'id')
								modNode:setVal('endToken', '0000')
							end
						end
					end

					objNode:add('modsAmount', 'int')
					objNode:setVal('modsAmount', modIndex)
				end

				isEmpty = false
			end
		end

		addPack('orig', this.origObjs)
		addPack('custom', this.customObjs)

		if not isEmpty then
			local t = {
				w3u = maskFunc,
				w3t = maskFunc,
				w3b = maskFunc,
				w3d = exMaskFunc,
				w3a = exMaskFunc,
				w3h = maskFunc,
				w3q = exMaskFunc
			}

			local ext

			if this.type then
				ext = this.type
			else
				ext = io.getFileExtension(path)
			end

			assert(t[ext], 'extension '..tostring(ext)..' unknown')

			root:writeToFile(path, t[ext])
		end
	end

	function this:readFromFile(path)
		assert(path, 'no path')

		local t = {
			w3u = maskFunc,
			w3t = maskFunc,
			w3b = maskFunc,
			w3d = exMaskFunc,
			w3a = exMaskFunc,
			w3h = maskFunc,
			w3q = exMaskFunc
		}

		local ext = io.getFileExtension(path)

		assert(t[ext], 'extension '..tostring(ext)..' unknown')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		root:readFromFile(path, t[ext])

		this.type = ext

		local function addPack(name, custom)
			local pack = root:getSub(name)

			for i = 1, pack:getVal('objsAmount'), 1 do
				local objNode = pack:getSub('obj'..i)

				local objId

				if custom then
					objId = objNode:getVal('id')
				else
					objId = objNode:getVal('base')
				end

				local obj = this:addObj(objId, objNode:getVal('base'))

				for j = 1, objNode:getVal('modsAmount'), 1 do
					local modNode = objNode:getSub('mod'..j)

					local modId = modNode:getVal('id')

					local varType = modNode:getVal('varType')
					local val = modNode:getVal('value')

					local variation = modNode:getVal('variation', true)
					local dataPointer = modNode:getVal('dataPointer', true)

					obj:setRaw(modId, varType, val, variation, dataPointer)
				end
			end
		end

		addPack('orig', false)
		addPack('custom', true)
	end

	return this
end

t.create = create

expose('wc3objMod', t)