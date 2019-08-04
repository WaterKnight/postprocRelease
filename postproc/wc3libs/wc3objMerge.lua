local t = {}

local function create()
	local this = {}

	this.slks = {}
	this.mods = {}
	this.profiles = {}

	this.slks = {}

	function this:mix(reduceMap)
		local outSlks = {}
		local outProfiles = {}
		local outMods = {}

		for name, slk in pairs(this.slks) do
			--name = name:lower()

			local outSlk = slkLib.create()

			outSlks[name] = outSlk

			outSlk:merge(slk)
		end

		for name, profile in pairs(this.profiles) do
			--name = name:lower()

			local outProfile = wc3profile.create()

			outProfiles[name] = outProfile

			outProfile:merge(profile)
		end

		for name, objMod in pairs(this.mods) do
			--name = name:lower()

			local slks, profiles, objMod = objMod:reduce(reduceMap)

			for name, slk in pairs(slks) do
				--name = name:lower()

				local outSlk = outSlks[name]

				if (outSlk == nil) then
					outSlk = slkLib.create()

					outSlks[name] = outSlk
				end

				outSlk:merge(slk)
			end

			for name, profile in pairs(profiles) do
				--name = name:lower()

				local outProfile = outProfiles[name]

				if (outProfile == nil) then
					outProfile = wc3profile.create()

					outProfiles[name] = outProfile
				end

				outProfile:merge(profile)
			end

			outMods[name] = objMod
		end

		return outSlks, outProfiles, outMods
	end

	function this:addSlk(name, slk)
		assert(name, 'no name')
		assert(slk, 'no slk')

		local mergedSlk = this.slks[name]

		if (mergedSlk == nil) then
			mergedSlk = slkLib.create()

			this.slks[name] = mergedSlk
		end

		mergedSlk:merge(slk)
	end

	function this:addProfile(name, profile)
		assert(name, 'no name')
		assert(val, 'no profile')

		local mergedProfile = this.profiles[name]

		if (mergedProfile == nil) then
			mergedProfile = wc3profile.create()

			this.profiles[name] = mergedProfile
		end

		mergedProfile:merge(profile)
	end

	function this:addMod(name, mod)
		assert(name, 'no name')
		assert(mod, 'no mod')

		local mergedMod = this.mods[name]

		if (mergedObjMod == nil) then
			mergedMod = wc3objMod.create()

			this.mods[name] = mergedMod
		end

		mergedMod:merge(mod)
	end

	return this
end

t.create = create

local function createMap(profilePath, wtsPath)
	local this = {}

	local headerSlksFolder = io.local_dir()..[[headerData\]]

	local headerSlks = {}

	require 'slkLib'

	for _, path in pairs(io.getFiles(headerSlksFolder, '*.slk')) do
		local folder = getFolder(path)
		local fileNameNoExt = getFileName(path, true)

		local pathNoExt = folder..fileNameNoExt

		local slk = slkLib.create()

		slk.path = pathNoExt
		slk:readFromFile(pathNoExt)

		headerSlks[#headerSlks + 1] = slk
	end

	this.outSlks = {}

	for i = 1, #headerSlks, 1 do
		local slk = headerSlks[i]

		local path = slk.path

		local outSlk = slkLib.create(path:sub(headerSlksFolder:len() + 1, path:len()))

		for field in pairs(slk.fields) do
			outSlk:addField(field)
		end

		outSlk.pivotField = slk.pivotField

		this.outSlks[getFileName(path, true):lower()] = outSlk
	end

	local metaSlksFolder = io.local_dir()..[[meta\]]
	local metaData = slkLib.create()
	local metaSlks = {}
	
	local function reduceSlkName(name)
		assert(name, 'no name')

		return getFileName(name, true):lower()
	end

	for _, path in pairs(io.getFiles(metaSlksFolder, '*.slk')) do
		local folder = getFolder(path)
		local fileNameNoExt = getFileName(path, true)

		local pathNoExt = folder..fileNameNoExt

		local slk = slkLib.create()

		metaSlks[reduceSlkName(fileNameNoExt)] = slk

		slk.path = pathNoExt
		slk:readFromFile(pathNoExt)

		metaData:merge(slk)
	end

	local fieldMetaNameToPureNameMap = {}
	local fieldPureNameToMetaNameMap = {}
	local fieldPureNameToMetaNameMapSpecific = {}
	local slkNameToMetaSlkMap = {}
	local metaSlkNamesFromObjType = {}

	for metaSlkName, metaSlk in pairs(metaSlks) do
		fieldPureNameToMetaNameMap[metaSlkName] = {}
		slkNameToMetaSlkMap[metaSlkName] = metaSlk

		for fieldMetaName, fieldMeta in pairs(metaSlk.objs) do
			local fieldPureName = fieldMeta.vals['field']
			local fieldIndex = fieldMeta.vals['index'] or 0

			if (fieldPureNameToMetaNameMap[metaSlkName][fieldIndex] == nil) then
				fieldPureNameToMetaNameMap[metaSlkName][fieldIndex] = {}
			end

			fieldPureNameToMetaNameMap[metaSlkName][fieldIndex][fieldPureName] = fieldMetaName

			local slkName = fieldMeta.vals['slk']:lower()
			
			if (slkName == 'doodaddata') then
				slkName = 'doodads'
			end

			if (fieldPureName == 'Data') then
				fieldPureName = fieldPureName..string.char(string.byte('A') + fieldMeta.vals['data'] - 1)
			end

			fieldMetaNameToPureNameMap[fieldMetaName] = fieldPureName

			if (fieldPureNameToMetaNameMap[slkName] == nil) then
				fieldPureNameToMetaNameMap[slkName] = {}
			end

			if (fieldPureNameToMetaNameMap[slkName][fieldIndex] == nil) then
				fieldPureNameToMetaNameMap[slkName][fieldIndex] = {}
			end

			fieldPureNameToMetaNameMap[slkName][fieldIndex][fieldPureName] = fieldMetaName

			if (fieldMeta.vals['useSpecific'] ~= nil) then
				local t = fieldMeta.vals['useSpecific']:split(',')

				if (#t > 0) then
					if (fieldPureNameToMetaNameMapSpecific[slkName] == nil) then
						fieldPureNameToMetaNameMapSpecific[slkName] = {}
					end

					if (fieldPureNameToMetaNameMapSpecific[slkName][fieldIndex] == nil) then
						fieldPureNameToMetaNameMapSpecific[slkName][fieldIndex] = {}
					end

					if (fieldPureNameToMetaNameMapSpecific[slkName][fieldIndex][fieldPureName] == nil) then
						fieldPureNameToMetaNameMapSpecific[slkName][fieldIndex][fieldPureName] = {}
					end

					for _, baseObjId in pairs(t) do
						fieldPureNameToMetaNameMapSpecific[slkName][fieldIndex][fieldPureName][baseObjId] = fieldMetaName
					end
				end
			end

			slkNameToMetaSlkMap[slkName] = metaSlk
		end
	end

	local function fieldMetaNameToPureName(metaName)
		return fieldMetaNameToPureNameMap[metaName]
	end

	local function pureNameToMetaNameByMetaSlk(metaSlk, pureName, index, baseObjId)
		assert(metaSlk, 'no metaSlk')
		assert(pureName, 'no pureName')

		index = index or -1

		for fieldMetaName, fieldMeta in pairs(metaSlk.objs) do
			if (pureName == fieldMeta.vals['field']) then
				if (index == fieldMeta.vals['index']) then
					if (baseObjId == nil) then
						if ((fieldMeta.vals['useSpecific'] == nil) or (#fieldMeta.vals['useSpecific']:split(',') == 0)) then
							return fieldMetaName
						end
					else
						if ((fieldMeta.vals['notSpecific'] == nil) or not table.contains(fieldMeta.vals['notSpecific']:split(','), baseObjId)) then
							if ((fieldMeta.vals['useSpecific'] == nil) or (#fieldMeta.vals['useSpecific']:split(',') == 0) or table.contains(fieldMeta.vals['useSpecific']:split(','), baseObjId)) then
								return fieldMetaName
							end
						end
					end
				end
			end
		end

		return nil
	end

	local function fieldPureNameToMetaName(pureName, slkName, baseObjId, objType, index)
		assert(pureName, 'no pureName')

		index = index or -1

		if (slkName == nil) then
			if (objType ~= nil) then
				for _, metaSlkName in pairs(metaSlkNamesFromObjType[objType]) do
					metaSlkName = reduceSlkName(metaSlkName)

					local metaSlk = slkNameToMetaSlkMap[metaSlkName]
	
					local ret = pureNameToMetaNameByMetaSlk(metaSlk, pureName, index, baseObjId)

					if (ret ~= nil) then
						return ret
					end
				end
			end

			if (baseObjId == nil) then
				for metaSlkName, metaSlk in pairs(metaSlks) do					
					local ret = pureNameToMetaNameByMetaSlk(metaSlk, pureName, index, baseObjId)

					if (ret ~= nil) then
						return ret
					end
				end
			end

			return nil
		end

		slkName = reduceSlkName(slkName)

		local metaSlk = slkNameToMetaSlkMap[slkName]

		return pureNameToMetaNameByMetaSlk(metaSlk, pureName, index, baseObjId)
	end

	local function fieldPureNameToMetaName2(pureName, slkName, baseObjId, objType, index)
		assert(pureName, 'no pureName')

		index = index or -1

		if (slkName == nil) then
			for _, slkName in pairs(metaSlksFromObjType[objType]) do
				slkName = reduceSlkName(slkName)

				local slk = fieldPureNameToMetaNameMap[slkName]
	
				if (slk ~= nil) then
					if ((slk[index] ~= nil) and (slk[index][pureName] ~= nil)) then
						return slk[index][pureName]
					end
				end
			end

			if (baseObjId == nil) then
				for slkName, slk in pairs(fieldPureNameToMetaNameMap) do
					if ((slk[index] ~= nil) and (slk[index][pureName] ~= nil)) then
						return slk[index][pureName]
					end
				end
			end

			return nil
		end

		slkName = reduceSlkName(slkName)

		

		if ((fieldPureNameToMetaNameMapSpecific[slkName] ~= nil) and (fieldPureNameToMetaNameMapSpecific[slkName][index] ~= nil) and (fieldPureNameToMetaNameMapSpecific[slkName][index][pureName] ~= nil) and (fieldPureNameToMetaNameMapSpecific[slkName][index][pureName][baseObjId] ~= nil)) then
			return fieldPureNameToMetaNameMapSpecific[slkName][index][pureName][baseObjId]
		end

		if (fieldPureNameToMetaNameMap[slkName][index] == nil) then
			return nil
		end

		return fieldPureNameToMetaNameMap[slkName][index][pureName]
	end

	this.metaData = metaData

	local function fieldMatchVal(field, val)
		local fieldType = this.metaData.objs[field].vals['type']

		if ((fieldType == 'bool') or (fieldType == 'int')) then
			if (type(val) ~= 'number') then
				return false
			end
			if (tostring(math.floor(val)) ~= tostring(val)) then
				return false
			end
		end
		if ((fieldType == 'real') or (fieldType == 'unreal')) then
			if (type(val) ~= 'number') then
				return false
			end
		end

		return true
	end

	this.fieldsPool = {}
	this.objs = {}

	function this:containsObj(id)
		assert(id, 'no id')

		return (this.objs[id] ~= nil)
	end

	function this:getObj(id)
		assert(id, 'no id')

		return this.objs[id]
	end

	function this:deleteObj(id)
		assert(id, 'no id')

		local obj = this.objs[id]

		assert(obj, 'obj '..tostring(id)..' not available')

		this.objs[id] = nil
	end

	function this:addObj(id, objType, baseId, profileIdent)
		assert(id, 'no id (arg1)')
		assert(objType, 'no objType (arg2)')

		local obj = this.objs[id]

		assert((obj == nil), 'obj '..tostring(id)..' already used')

		obj = {}

		this.objs[id] = obj

		obj.baseId = baseId
		obj.fields = {}
		obj.objType = objType
		obj.profileIdent = profileIdent

		function obj:containsField(field)
			assert(field, 'no field')

			return (obj.fields[field] ~= nil)
		end

		function obj:deleteField(field)
			assert(field, 'no field')

			local fieldData = obj.fields[field]

			assert(fieldData, 'field '..tostring(field)..' not available')

			obj.fields[field] = nil
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

		function obj:get(field, level)
			assert(field, 'no field')

			local fieldData = obj.fields[field]

			assert(fieldData, 'obj '..id..' has no field '..field)

			if (level == nil) then
				level = 0
			end

			local levelData = fieldData[level]

			assert(levelData, 'field '..field..' of obj '..id..' has no level data')

			return levelData.val
		end

		function obj:getBySlk(field)
			assert(field, 'no field')

			local level = field:match('(%d+)$')

			if (level ~= nil) then
				field = field:match('^([a-zA-Z]*)')
			end

			local metaField = fieldPureNameToMetaName(field, level)

			if (metaField ~= nil) then
				return obj:get(metaField, level)
			end

			return nil
		end

		function obj:set(field, varType, val, level, dataPointer)
			assert(field, 'no field')

			local fieldData = obj.fields[field]

			local fieldPoolData = this.fieldsPool[field]

			if (fieldData == nil) then
				if restrictedFieldsPool then
					assert(fieldPoolData, 'field '..tostring(field)..' not in fieldsPool')
				end

				fieldData = {}

				obj.fields[field] = fieldData
			end

			if fieldPoolData then
				local fieldPoolDataType = fieldPoolData.type

				if fieldPoolDataType then
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
				level = 0
			end

			local levelData = fieldData[level]

			if (levelData == nil) then
				levelData = {}

				fieldData[level] = levelData
			end

			levelData.varType = varType
			levelData.val = val
			levelData.dataPointer = dataPointer
		end

		function obj:setBySlk(field, val, slkName, baseObjId, fieldIndex)
			assert(field, 'no field')

			local level = tonumber(field:match('(%d+)$'))

			if (level ~= nil) then
				field = field:match('^([a-zA-Z]*)')
			end

			local metaField = fieldPureNameToMetaName(field, slkName, baseObjId, obj.objType, fieldIndex)

			if (metaField ~= nil) then
				if fieldMatchVal(metaField, val) then
					if (metaData.objs[metaField].vals['index'] ~= -1) then
						level = nil
					end

					obj:set(metaField, metaData.objs[metaField].vals['type'], val, level, metaData.objs[metaField].vals['data'])
				end
			else
				--error(string.format('field %s not found', field))
			end
		end

		return obj
	end

	function this:addSlk(path)
		assert(path, 'no path')

		require 'slkLib'

		local folder = getFolder(path)
		local fileNameNoExt = getFileName(path, true)

		local outSlk = this.outSlks[fileNameNoExt:lower()]

		if (outSlk == nil) then
			error('no header slk for '..path)
		end

		local slk = slkLib.create()

		slk.path = path
		slk:readFromFile(path)

		local slkName = fileNameNoExt:lower()

		local objTypeTable = {
			UnitAbilities = 'unit',
			UnitBalance = 'unit',
			UnitData = 'unit',
			unitUI = 'unit',
			UnitWeapons = 'unit',
			ItemData = 'item',
			DestructableData = 'destructable',
			AbilityData = 'ability',
			AbilityBuffData = 'buff',
			UpgradeData = 'upgrade'
		}

		local objType = objTypeTable[fileNameNoExt]

		for objId, slkObj in pairs(slk.objs) do
			local obj = this.objs[objId]

			if (obj == nil) then
				obj = this:addObj(objId, objType, nil)
			end

			local baseObjId = slkObj.vals['code']

			for field, val in pairs(slkObj.vals) do
				obj:setBySlk(field, val, slkName, baseObjId, nil)
			end
		end

		outSlk:merge(slk)
	end

	require 'wc3profile'

	local outProfile = wc3profile.create(wtsPath)

	function this:addProfile(profile)
		assert(profile, 'no path/object')

		if (type(profile) == 'string') then
			local path = profile

			profile = wc3profile.create()

			profile:readFromFile(path)
		end

		outProfile:merge(profile)

		for objId, profileObj in pairs(profile.objs) do
			local obj = this.objs[objId]

			if (obj == nil) then
				--obj = this:addObj(objId, nil)
			end

			if (obj ~= nil) then
				for field, fieldData in pairs(profileObj.vals) do
					for index, val in pairs(fieldData) do
						obj:setBySlk(field, val, nil, nil, index)
					end
				end
			end
		end
	end

	local outObjMods = {}

	function this:addObjMod(objMod)
		assert(objMod, 'no path/object')

		if (type(objMod) == 'string') then
			local path = objMod

			require 'wc3objMod'

			objMod = wc3objMod.create()

			objMod:readFromFile(path)
		end

		local ext = objMod.type

		if (ext == nil) then
			return
		end

		local objTypeTable = {
			w3u = 'unit',
			w3t = 'item',
			w3b = 'destructable',
			w3d = 'doodad',
			w3a = 'ability',
			w3h = 'buff',
			w3q = 'upgrade'
		}

		local objType = objTypeTable[ext]

		for objId, modObj in pairs(objMod.objs) do
			local baseId = modObj.base

			local obj = this.objs[objId]

			if (obj == nil) then
				obj = this:addObj(objId, objType, baseId)
			end

			if (baseId ~= nil) then
				for outSlkName, outSlk in pairs(this.outSlks) do
					if (outSlk.objs[baseId] ~= nil) then
						if (outSlk.objs[objId] == nil) then
							outSlk:addObj(objId)
						end

						outSlk:objMerge(objId, baseId)
					end
				end

				if (outProfile.objs[baseId]  ~= nil) then
					if (outProfile.objs[objId] == nil) then
						outProfile:addObj(objId)
					end

					outProfile:objMerge(objId, baseId)
				end
			end

			for field, fieldData in pairs(modObj.fields) do
				for level, levelData in pairs(fieldData) do
					local metaObj = metaData.objs[field]

						local deleteFromObjMod = false

					if (metaObj ~= nil) then
						obj:set(field, metaObj.vals['type'], levelData.val, level, metaObj.vals['data'])

						local slkName = metaObj.vals['slk']:lower()
						
						if (slkName == 'doodaddata') then
							slkName = 'doodads'
						end

						local slkField = metaObj.vals['field']

						if (slkName == 'profile') then
							local profileObj = outProfile.objs[objId]

							if (profileObj == nil) then
								profileObj = outProfile:addObj(objId)
							end

							local val = levelData.val

							local index = level

							if (metaObj.vals['index'] > 0) then
								level = level + metaObj.vals['index']
							end

							profileObj:set(slkField, val, index)

							deleteFromObjMod = true
						else
							local outSlk = this.outSlks[slkName:lower()]

							assert(outSlk, 'slk '..tostring(slkName)..' missing')

							local val = levelData.val

							if (metaObj.vals['field'] == 'Data') then
								slkField = slkField..string.char(string.byte('A') + levelData.dataPointer - 1)
							end

							if ((metaObj.vals['repeat'] ~= nil) and (metaObj.vals['repeat'] > 0)) then
								slkField = slkField..tonumber(level)
							end

							if outSlk.fields[slkField] then
								local slkObj = outSlk.objs[objId]

								if (slkObj == nil) then
									slkObj = outSlk:addObj(objId)
								end

								slkObj:set(slkField, val)

								deleteFromObjMod = true
							end
						end
					end

						if deleteFromObjMod or field=='wurs' then
							modObj:deleteVal(field, level)

							if (table.getSize(modObj.fields) == 0) then
								modObj:remove()
							end
						else
							--print('cannot delete', field, level)
						end
				end
			end
		end

		if (outObjMods[ext] == nil) then
			outObjMods[ext] = wc3objMod.create()

			outObjMods[ext].type = ext
		end

		outObjMods[ext]:merge(objMod)
	end

	function this:addFromDir(dir)
		assert(dir, 'no dir')

		for _, path in pairs(io.getFiles(dir, '*.slk')) do
			this:addSlk(path)
		end

		for _, path in pairs(io.getFiles(dir, '*.txt')) do
			this:addProfile(path)
		end

		for _, path in pairs(io.getFiles(dir, '*.w3*')) do
			this:addObjMod(path)
		end
	end

	function this:print()
		for i = 1, #objs, 1 do
			local obj = objs[i]

			print(obj.id)

			for field, val in pairs(obj.vals) do
				print('\t', field, '->', val)
			end
		end
	end

	function this:output(outDir, profilePath)
		assert(outDir, 'no outDir')
		assert(profilePath, 'no profilePath')

		outDir = io.toFolderPath(outDir)

		if not io.isAbsPath(profilePath) then
			profilePath = io.toAbsPath(profilePath, outDir)
		end

		io.flushDir(outDir)

		io.createDir(outDir)

		for _, slk in pairs(this.outSlks) do
			if (table.getSize(slk.objs) > 0) then
				slk:writeToFile(outDir..slk.path)
			end
		end

		--outProfile:writeToFile(outDir..[[Units\HumanAbilityFunc.txt]])
		outProfile:writeToFile(profilePath)

		for ext, objMod in pairs(outObjMods) do
			if (table.getSize(objMod.objs) > 0) then
				objMod:writeToFile(outDir..'war3map.'..ext)
			end
		end
	end

	local slkPaths = {
		[[Units\UnitAbilities.slk]],
		[[Units\UnitBalance.slk]],
		[[Units\UnitData.slk]],
		[[Units\unitUI.slk]],
		[[Units\UnitWeapons.slk]],

		[[Units\ItemData.slk]],
		[[Units\DestructableData.slk]],
		[[Units\AbilityData.slk]],
		[[Units\AbilityBuffData.slk]],
		[[Units\UpgradeData.slk]]
	}

	metaSlkNamesFromObjType = {
		unit = {
			[[Units\UnitMetaData.slk]]
		},

		item = {
			[[Units\UnitMetaData.slk]]
		},

		destructable = {
			[[DestructableMetaData.slk]]
		},

		doodad = {
			[[DoodadMetaData.slk]]
		},

		ability = {
			[[AbilityMetaData.slk]]
		},

		buff = {
			[[AbilityBuffMetaData.slk]]
		},

		upgrade = {
			[[UpgradeMetaData.slk]]
		}
	}

	local profilePaths = {
		[[Units\CampaignUnitStrings.txt]],

		[[Units\HumanUnitStrings.txt]],
		[[Units\NeutralUnitStrings.txt]],
		[[Units\NightElfUnitStrings.txt]],
		[[Units\OrcUnitStrings.txt]],
		[[Units\UndeadUnitStrings.txt]],

		[[Units\CampaignUnitFunc.txt]],
		[[Units\HumanUnitFunc.txt]],
		[[Units\NeutralUnitFunc.txt]],
		[[Units\NightElfUnitFunc.txt]],
		[[Units\OrcUnitFunc.txt]],
		[[Units\UndeadUnitFunc.txt]],

		[[Units\CampaignAbilityStrings.txt]],
		[[Units\CommonAbilityStrings.txt]],
		[[Units\HumanAbilityStrings.txt]],
		[[Units\NeutralAbilityStrings.txt]],
		[[Units\NightElfAbilityStrings.txt]],
		[[Units\OrcAbilityStrings.txt]],
		[[Units\UndeadAbilityStrings.txt]],
		[[Units\ItemAbilityStrings.txt]],

		[[Units\CampaignAbilityFunc.txt]],
		[[Units\CommonAbilityFunc.txt]],
		[[Units\HumanAbilityFunc.txt]],
		[[Units\NeutralAbilityFunc.txt]],
		[[Units\NightElfAbilityFunc.txt]],
		[[Units\OrcAbilityFunc.txt]],
		[[Units\UndeadAbilityFunc.txt]],
		[[Units\ItemAbilityFunc.txt]],

		[[Units\CampaignUpgradeStrings.txt]],
		[[Units\HumanUpgradeStrings.txt]],
		[[Units\NightElfUpgradeStrings.txt]],
		[[Units\OrcUpgradeStrings.txt]],
		[[Units\UndeadUpgradeStrings.txt]],
		[[Units\NeutralUpgradeStrings.txt]],

		[[Units\CampaignUpgradeFunc.txt]],
		[[Units\HumanUpgradeFunc.txt]],
		[[Units\NightElfUpgradeFunc.txt]],
		[[Units\OrcUpgradeFunc.txt]],
		[[Units\UndeadUpgradeFunc.txt]],
		[[Units\NeutralUpgradeFunc.txt]],

		[[Units\CommandStrings.txt]],
		[[Units\ItemStrings.txt]],

		[[Units\CommandFunc.txt]],
		[[Units\ItemFunc.txt]],
	}

	local objModPaths = {
		[[war3map.w3u]],
		[[war3map.w3t]],
		[[war3map.w3b]],
		[[war3map.w3d]],
		[[war3map.w3a]],
		[[war3map.w3h]],
		[[war3map.w3q]]
	}

	function this:readFromMap(mapPath, includeNativeMpqs, wc3path)
		assert(mapPath, 'no mapPath')

		local mpqPaths

		if includeNativeMpqs then
			assert(wc3path, 'want to include native mpqs but no wc3path')

			require 'portLib'

			mpqPaths = {mapPath, portLib.mpqGetWc3Paths(wc3path)}
		else
			mpqPaths = {mapPath}
		end

		local inputDir = io.local_dir()..[[Input\]]

		io.flushDir(inputDir)

		io.createDir(inputDir)

		require 'portLib'

		local commonExtPort = portLib.createMpqPort()

		for _, path in pairs(slkPaths) do
			commonExtPort:addExtract(path, inputDir)
		end

		for _, path in pairs(profilePaths) do
			commonExtPort:addExtract(path, inputDir)
		end

		commonExtPort:commit(mpqPaths)

		local mapExtPort = portLib.createMpqPort()

		for _, path in pairs(objModPaths) do
			mapExtPort:addExtract(path, inputDir)
		end

		mapExtPort:addExtract([[war3map.wts]], inputDir)

		mapExtPort:commit(mapPath)

		this:addFromDir(inputDir)
	end

	function this:writeToMap(mapPath)
		assert(mapPath, 'no mapPath')

		local outputDir = io.local_dir()..[[Output\]]

		this:output(outputDir, [[Units\CampaignUnitStrings.txt]])

		local impPort = portLib.createMpqPort()

		for _, path in pairs(objModPaths) do
			impPort:addDelete(path)
		end

		for _, path in pairs(io.getFiles(outputDir, '*')) do
			local targetPath = path:sub(outputDir:len() + 1, path:len())

			impPort:addImport(path, targetPath)
		end

		impPort:commit(mapPath)
	end

	return this
end

t.createMap = createMap

expose('wc3objMerge', t)