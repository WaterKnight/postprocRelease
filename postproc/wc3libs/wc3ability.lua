require 'waterlua'

local t = {}

local function createSlk()
	local this = {}

	require 'slkLib'

	this.rawSlk = slkLib.create()

	this.objs = {}

	function this:getObj(id)
		assert(id, 'no id')

		return this.objs[id]
	end

	function this:addObj(id)
		assert(id, 'no id')

		local obj = {}

		this.objs[id] = obj

		function obj:set(field, val)
			assert(field, 'no field')

			local slkObj = this.rawSlk:getObj(id)

			if (slkObj == nil) then
				slkObj = this.rawSlk:addObj(id)
			end

			this.rawSlk:addField(field)

			slkObj:set(field, val)
		end

		function obj:setCode(val)
			obj.code = val
		end

		function obj:setHero(val)
			obj.hero = val or 0
		end

		function obj:setItem(val)
			obj.item = val or 0
		end

		function obj:setRace(val)
			obj.race = val
		end

		function obj:setCheckDep(val)
			obj.checkDep = val or 0
		end

		function obj:setLevels(val)
			obj.levels = val or 1
		end

		function obj:setReqLevel(val)
			obj.reqLevel = val or 0
		end

		function obj:setLevelSkip(val)
			obj.levelSkip = val or 0
		end

		function obj:setPrio(val)
			obj.prio = val or 0
		end

		obj.targs = {}

		function obj:setTargs(val, level)
			if (level == nil) then
				level = 1
			end

			assert((level >= 1) and (level <= 4), 'level must be between 1 and 4 but got '..tostring(level))

			obj.targs[level] = val or 0
		end

		obj.castTime = {}

		function obj:setCastTime(val, level)
			if (level == nil) then
				level = 1
			end

			assert((level >= 1) and (level <= 4), 'level must be between 1 and 4 but got '..tostring(level))

			obj.castTime[level] = val or 0
		end

		obj.dur = {}

		function obj:setDur(val, level)
			if (level == nil) then
				level = 1
			end

			assert((level >= 1) and (level <= 4), 'level must be between 1 and 4 but got '..tostring(level))

			obj.dur[level] = val or 0
		end

		obj.heroDur = {}

		function obj:setHeroDur(val, level)
			if (level == nil) then
				level = 1
			end

			assert((level >= 1) and (level <= 4), 'level must be between 1 and 4 but got '..tostring(level))

			obj.heroDur[level] = val or 0
		end

		obj.cooldown = {}

		function obj:setCooldown(val, level)
			if (level == nil) then
				level = 1
			end

			assert((level >= 1) and (level <= 4), 'level must be between 1 and 4 but got '..tostring(level))

			obj.cooldown[level] = val or 0
		end

		obj.manaCost = {}

		function obj:setManaCost(val, level)
			if (level == nil) then
				level = 1
			end

			assert((level >= 1) and (level <= 4), 'level must be between 1 and 4 but got '..tostring(level))

			obj.manaCost[level] = val or 0
		end

		obj.area = {}

		function obj:setArea(val, level)
			if (level == nil) then
				level = 1
			end

			assert((level >= 1) and (level <= 4), 'level must be between 1 and 4 but got '..tostring(level))

			obj.area[level] = val or 0
		end

		obj.range = {}

		function obj:setRange(val, level)
			if (level == nil) then
				level = 1
			end

			assert((level >= 1) and (level <= 4), 'level must be between 1 and 4 but got '..tostring(level))

			obj.range[level] = val or 0
		end

		obj.data = {}

		for i = 0, 8, 1 do
			obj.data[i] = {}
		end

		function obj:setData(dataPt, val, level)
			if (dataPt == nil) then
				dataPt = 0
			end

			assert((dataPt >= 0) and (dataPt <= 9), 'dataPointer must be between 0 and 8 but got '..tostring(dataPt))

			if (level == nil) then
				level = 1
			end

			assert((level >= 1) and (level <= 4), 'level must be between 1 and 4 but got '..tostring(level))

			obj.data[dataPt][level] = val
		end

		obj.unitId = {}

		function obj:setUnitId(val, level)
			if (level == nil) then
				level = 1
			end

			assert((level >= 1) and (level <= 4), 'level must be between 1 and 4 but got '..tostring(level))

			obj.unitId[level] = val or 0
		end

		obj.buffId = {}

		function obj:setBuffId(val, level)
			if (level == nil) then
				level = 1
			end

			assert((level >= 1) and (level <= 4), 'level must be between 1 and 4 but got '..tostring(level))

			obj.buffId[level] = val or 0
		end

		obj.effectId = {}

		function obj:setEffectId(val, level)
			if (level == nil) then
				level = 1
			end

			assert((level >= 1) and (level <= 4), 'level must be between 1 and 4 but got '..tostring(level))

			obj.effectId[level] = val or 0
		end

		function obj:setRace(val)
			obj.race = val
		end

		return obj
	end

	function this:toSlk()
		require 'slkLib'

		local slk = slkLib.create()

		slk:addField('alias')

		slk:addField('code')

		slk:addField('comments')

		slk:addField('version')
		slk:addField('useInEditor')

		slk:addField('hero')
		slk:addField('item')

		slk:addField('sort')
		slk:addField('race')

		slk:addField('checkDep')

		slk:addField('levels')

		slk:addField('reqLevel')
		slk:addField('levelSkip')

		slk:addField('priority')

		for i = 1, 4, 1 do
			slk:addField(string.format('targs%i', i))
			slk:addField(string.format('Cast%i', i))
			slk:addField(string.format('Dur%i', i))
			slk:addField(string.format('HeroDur%i', i))
			slk:addField(string.format('Cool%i', i))
			slk:addField(string.format('Cost%i', i))
			slk:addField(string.format('Area%i', i))
			slk:addField(string.format('Rng%i', i))
			for dataPt = 0, 8, 1 do
				slk:addField(string.format('Data%s%i', string.char(string.byte('A') + dataPt), i))
			end
			slk:addField(string.format('UnitID%i', i))
			slk:addField(string.format('BuffID%i', i))
			slk:addField(string.format('EfctID%i', i))
		end

		slk:addField('InBeta')

		for objId, obj in pairs(this.objs) do
			local slkObj = slk:addObj(objId)

			slkObj:set('code', obj.code)

			slkObj:set('hero', obj.hero)
			slkObj:set('item', obj.item)
			slkObj:set('race', obj.race)

			slkObj:set('checkDep', obj.checkDep)

			slkObj:set('levels', obj.levels)
			slkObj:set('reqLevel', obj.reqLevel)
			slkObj:set('levelSkip', obj.levelSkip)

			slkObj:set('priority', obj.prio)

			for i = 1, 4, 1 do
				slkObj:set(string.format('targs%i', i), obj.targs[i])
				slkObj:set(string.format('Cast%i', i), obj.castTime[i])
				slkObj:set(string.format('Dur%i', i), obj.dur[i])
				slkObj:set(string.format('HeroDur%i', i), obj.heroDur[i])
				slkObj:set(string.format('Cool%i', i), obj.cooldown[i])
				slkObj:set(string.format('Cost%i', i), obj.manaCost[i])
				slkObj:set(string.format('Area%i', i), obj.area[i])
				slkObj:set(string.format('Rng%i', i), obj.range[i])

				for dataPt = 0, 8, 1 do
					slkObj:set(string.format('Data%s%i', string.char(string.byte('A') + dataPt), i), obj.data[dataPt][i])
				end

				slkObj:set(string.format('UnitID%i', i), obj.unitId[i])
				slkObj:set(string.format('BuffID%i', i), obj.buffId[i])
				slkObj:set(string.format('EfctID%i', i), obj.effectId[i])
			end
		end

		slk:merge(this.rawSlk)

		return slk
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		this:toSlk():writeToFile(path)
	end

	function this:readFromFile(path)
		assert(path, 'no path')

		require 'slkLib'

		local slk = createSlk()

		slk:readFromFile(path)

		for id, objData in pairs(slk.objs) do
			local obj = this:addObj(id)

			obj:setCode(objData.vals['code'])

			obj:setHero(objData.vals['hero'])
			obj:setItem(objData.vals['item'])
			obj:setRace(objData.vals['race'])

			obj:setCheckDep(objData.vals['checkDep'])

			obj:setLevels(objData.vals['levels'])
			obj:setReqLevel(objData.vals['reqLevel'])
			obj:setLevelSkip(objData.vals['levelSkip'])

			obj:setPrio(objData.vals['priority'])

			for i = 1, 4, 1 do
				obj:setTargs(i, objData.vals[string.format('targs%i', i)])
				obj:setCastTime(i, objData.vals[string.format('Cast%i', i)])
				obj:setDur(i, objData.vals[string.format('Dur%i', i)])
				obj:setHeroDur(i, objData.vals[string.format('HeroDur%i', i)])
				obj:setCooldown(i, objData.vals[string.format('Cool%i', i)])
				obj:setManaCost(i, objData.vals[string.format('Cost%i', i)])
				obj:setArea(i, objData.vals[string.format('Area%i', i)])
				obj:setRange(i, objData.vals[string.format('Rng%i', i)])
				for dataPt = 0, 8, 1 do
					obj:setData(dataPt, i, objData.vals[string.format('Data%s%i', string.char(string.byte('A') + dataPt), i)])
				end
				obj:setUnitId(i, objData.vals[string.format('UnitID%i', i)])
				obj:setBuffId(i, objData.vals[string.format('BuffID%i', i)])
				obj:setEffectId(i, objData.vals[string.format('EfctID%i', i)])
			end
		end
	end

	return this
end

t.createSlk = createSlk

local function createMod()
	local this = {}

	this.rawMod = wc3objMod.create()

	this.objs = {}

	function this:getObj(id)
		assert(id, 'no id')

		return this.objs[id]
	end

	function this:addObj(id, baseId)
		assert(id, 'no id')

		assert(this.objs[id] == nil, 'objId '..tostring(id)..' already used')

		local obj = {}

		this.objs[id] = obj

		obj.baseId = baseId

		function obj:set(field, val, level)
			local modObj = this.rawMod:getObj(id)

			if (modObj == nil) then
				modObj = this.rawMod:addObj(id)
			end

			modObj:set(field, val, level)
		end

		function obj:setName(val)
			obj.name = val
		end

		function obj:setEditorSuffix(val)
			obj.editorSuffix = val
		end

		function obj:setHero(val)
			obj.isHero = val or 0
		end

		function obj:setItem(val)
			obj.isItem = val or 0
		end

		function obj:setRace(val)
			obj.race = val
		end

		function obj:setButtonPos(x, y)
			obj.buttonPosX = x or 0
			obj.buttonPosY = y or 0
		end

		function obj:setButtonUnPos(x, y)
			obj.buttonUnPosX = x or 0
			obj.buttonUnPosY = y or 0
		end

		function obj:setButtonResearchPos(x, y)
			obj.buttonResearchPosX = x or 0
			obj.buttonResearchPosY = y or 0
		end

		function obj:setIcon(val)
			obj.icon = val
		end

		function obj:setIconUn(val)
			obj.iconUn = val
		end

		function obj:setIconResearch(val)
			obj.iconResearch = val
		end

		function obj:setCasterEffect(val)
			obj.casterEffect = val
		end

		function obj:setTargetEffect(val)
			obj.targetEffect = val
		end

		function obj:setSpecialEffect(val)
			obj.specialEffect = val
		end

		function obj:setEffect(val)
			obj.effect = val
		end

		function obj:setAreaEffect(val)
			obj.areaEffect = val
		end

		function obj:setBolt(val)
			obj.bolt = val
		end

		function obj:setMissileArt(val)
			obj.missileArt = val
		end

		function obj:setMissileSpeed(val)
			obj.missileSpeed = val or 0
		end

		function obj:setMissileArc(val)
			obj.missileArc = val or 0
		end

		function obj:setMissileHoming(val)
			obj.missileHoming = val or 0
		end

		function obj:setTargetAttachCount(val)
			obj.targetAttachCount = val or 0
		end

		obj.targetAttach = {}

		function obj:setTargetAttach(index, val)
			obj.targetAttach[index] = val
		end

		function obj:setCasterAttachCount(val)
			obj.casterAttachCount = val or 0
		end

		function obj:setCasterAttach(val)
			obj.casterAttach = val
		end

		function obj:setCasterAttach1(val)
			obj.casterAttach1 = val
		end

		function obj:setSpecialAttach(val)
			obj.specialAttach = val
		end

		function obj:setAnim(val)
			obj.anim = val
		end

		obj.tooltips = {}

		function obj:setTooltip(val, level)
			obj.tooltips[level] = val
		end

		obj.tooltipUns = {}

		function obj:setTooltipUn(val, level)
			obj.tooltipUns[level] = val
		end

		obj.uberTooltips = {}

		function obj:setUberTooltip(val, level)
			obj.uberTooltips[level] = val
		end

		obj.uberTooltipUns = {}

		function obj:setUberTooltipUn(val, level)
			obj.uberTooltipUn[level] = val
		end

		function obj:setTooltipResearch(val)
			obj.rtooltipResearch = val
		end

		function obj:setUberTooltipResearch(val)
			obj.uberTooltipResearch = val
		end

		function obj:setHotkeyResearch(val)
			obj.hotkeyResearch = val
		end

		function obj:setHotkey(val)
			obj.hotkey = val
		end

		function obj:setHotkeyUn(val)
			obj.hotkeyUn = val
		end

		function obj:setRequirement(val)
			obj.requirement = val
		end

		function obj:setRequirementsAmount(val)
			obj.requirementsAmount = val or 0
		end

		function obj:setCheckDep(val)
			obj.checkDep = val or 0
		end

		function obj:setPrio(val)
			obj.prio = val
		end

		function obj:setOrder(val)
			obj.order = val
		end

		function obj:setOrderUn(val)
			obj.orderUn = val
		end

		function obj:setOrderOn(val)
			obj.orderOn = val
		end

		function obj:setOrderOff(val)
			obj.orderOff = val
		end

		function obj:setSound(val)
			obj.sound = val
		end

		function obj:setSoundLoop(val)
			obj.soundLoop = val
		end

		function obj:setLevels(val)
		if (id == 'SL6C') then
		print('setlevels', val)
		end
			obj.levels = val or 1
		end

		function obj:setLevelReq(val)
			obj.levelReq = val or 0
		end

		function obj:setLevelSkip(val)
			obj.levelSkip = val or 0
		end

		obj.targets = {}

		function obj:setTargets(val, level)
			obj.targets[level] = val
		end

		obj.castTime = {}

		function obj:setCastTime(val, level)
			obj.castTime[level] = val or 0
		end

		obj.duration = {}

		function obj:setDuration(val, level)
			obj.duration[level] = val or 0
		end

		obj.heroDuration = {}

		function obj:setHeroDuration(val, level)
			obj.heroDuration[level] = val or 0
		end

		obj.cooldown = {}

		function obj:setCooldown(val, level)
			obj.cooldown[level] = val or 0
		end

		obj.manaCost = {}

		function obj:setManaCost(val, level)
			obj.manaCost[level] = val or 0
		end

		obj.area = {}

		function obj:setArea(val, level)
			obj.area[level] = val or 0
		end

		obj.range = {}

		function obj:setRange(val, level)
			obj.range[level] = val or 0
		end

		obj.buffId = {}

		function obj:setBuffId(val, level)
			obj.buffId[level] = val or 0
		end

		obj.effectId = {}

		function obj:setEffectId(val, level)
			obj.effectId[level] = val or 0
		end

		function obj:merge(other)
			assert(other, 'no other')

			local t = {

			}

			for i = 0, 5, 1 do
				t[#t + 1] = string.format('targetAttach%i', i)
			end

			for _, var in pairs(t) do
				obj[var] = other[var]
			end
		end

		return obj
	end

	function this:merge(other)
		assert(other, 'no other')

		for objId, otherObj in pairs(other.objs) do
			local obj = this.objs[objId]

			if (obj == nil) then
				obj = this:addObj(objId, otherObj.baseId)
			end

			obj:merge(otherObj)
		end
	end

	function this:reduceToSlk()
		local slk = slk.create()
		local objMod = objMod.create()

		
	end

	function this:toObjMod()
		require 'wc3objMod'

		local objMod = wc3objMod.create()

		for objId, obj in pairs(this.objs) do
			local modObj = objMod:addObj(objId, obj.baseId, (obj.baseId ~= nil))

			modObj:set('anam', obj.name)
			modObj:set('ansf', obj.editorSuffix)
			modObj:set('aher', obj.isHero)
			modObj:set('aite', obj.isItem)

			modObj:set('arac', obj.race)
			modObj:set('abpx', obj.buttonPosX)
			modObj:set('abpy', obj.buttonPosY)
			modObj:set('aupx', obj.buttonUnPosX)
			modObj:set('aupy', obj.buttonUnPosY)
			modObj:set('arpx', obj.buttonResearchPosX)
			modObj:set('arpy', obj.buttonResearchPosY)

			modObj:set('aart', obj.icon)
			modObj:set('auar', obj.iconUn)
			modObj:set('arar', obj.iconResearch)

			modObj:set('acat', obj.casterEffect)
			modObj:set('atat', obj.targetEffect)
			modObj:set('asat', obj.specialEffect)
			modObj:set('aeat', obj.effect)
			modObj:set('aaea', obj.areaEffect)

			modObj:set('alig', obj.bolt)

			modObj:set('amat', obj.missileArt)
			modObj:set('amsp', obj.missileSpeed)
			modObj:set('amac', obj.missileArc)
			modObj:set('amho', obj.missileHoming)

			modObj:set('atac', obj.targetAttachCount)

			for i = 0, 5, 1 do
				modObj:set(string.format('ata%i', i), obj.targetAttach[i])
			end

			modObj:set('acac', obj.casterAttachCount)
			modObj:set('acap', obj.casterAttach)
			modObj:set('aca1', obj.casterAttach1)
			modObj:set('aspt', obj.specialAttach)

			modObj:set('aani', obj.anim)

			for level, val in pairs(obj.tooltips) do
				modObj:set('atp1', val, level)
			end
			for level, val in pairs(obj.tooltipUns) do
				modObj:set('aut1', val, level)
			end
			for level, val in pairs(obj.uberTooltips) do
				modObj:set('aub1', val, level)
			end
			for level, val in pairs(obj.uberTooltipUns) do
				modObj:set('auu1', val, level)
			end

			modObj:set('aret', obj.tooltipResearch)
			modObj:set('arut', obj.uberTooltipResearch)

			modObj:set('arhk', obj.hotkeyResearch)
			modObj:set('ahky', obj.hotkey)
			modObj:set('auhk', obj.hotkeyUn)

			modObj:set('areq', obj.requirement)
			modObj:set('arqa', obj.requirementsAmount)
			modObj:set('achd', obj.checkDep)

			modObj:set('apri', obj.prio)
			modObj:set('aord', obj.order)
			modObj:set('aoru', obj.orderUn)
			modObj:set('aoro', obj.orderOn)
			modObj:set('aorf', obj.orderOff)

			modObj:set('aefs', obj.sound)
			modObj:set('aefl', obj.soundLoop)

			modObj:set('alev', obj.levels)
			modObj:set('arlv', obj.levelReq)
			modObj:set('alsk', obj.levelSkip)

			for level, val in pairs(obj.targets) do
				modObj:set('atar', val, level)
			end
			for level, val in pairs(obj.castTime) do
				modObj:set('acas', val, level)
			end
			for level, val in pairs(obj.duration) do
				modObj:set('adur', val, level)
			end
			for level, val in pairs(obj.heroDuration) do
				modObj:set('ahdu', val, level)
			end
			for level, val in pairs(obj.cooldown) do
				modObj:set('acdn', val, level)
			end
			for level, val in pairs(obj.manaCost) do
				modObj:set('amcs', val, level)
			end
			for level, val in pairs(obj.area) do
				modObj:set('aare', val, level)
			end
			for level, val in pairs(obj.range) do
				modObj:set('aran', val, level)
			end
			for level, val in pairs(obj.buffId) do
				modObj:set('abuf', val, level)
			end
			for level, val in pairs(obj.effectId) do
				modObj:set('aeff', val, level)
			end
		end

		objMod:addMeta(io.local_dir()..[[meta\AbilityMetaData.slk]])

		return objMod
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		this:toObjMod():writeToFile(path)
	end

	function this:fromObjMod(objMod)
		assert(objMod, 'no objMod')

		require 'wc3objMod'

		for objId, modObj in pairs(objMod.objs) do
			local obj = this:addObj(objId, modObj.baseId)

			obj:setName(modObj:getVal('anam'))
			obj:setEditorSuffix(modObj:getVal('ansf'))
			obj:setHero(modObj:getVal('aher'))
			obj:setItem(modObj:getVal('aite'))
			
			obj:setRace(modObj:getVal('arac'))
			obj:setButtonPos(modObj:getVal('abpx'), modObj:getVal('abpy'))
			obj:setButtonPosOff(modObj:getVal('aupx'), modObj:getVal('aupy'))
			obj:setResearchButtonPos(modObj:getVal('arpx'), modObj:getVal('arpy'))

			obj:setIcon(modObj:getVal('aart'))
			obj:setIconOff(modObj:getVal('auar'))
			obj:setResearchIcon(modObj:getVal('arar'))

			obj:setCasterEffect(modObj:getVal('acat'))
			obj:setTargetEffect(modObj:getVal('atat'))
			obj:setSpecialEffect(modObj:getVal('asat'))
			obj:setEffect(modObj:getVal('aeat'))
			obj:setAreaEffect(modObj:getVal('aaea'))

			obj:setBolt(modObj:getVal('alig'))

			obj:setMissileArt(modObj:getVal('amat'))
			obj:setMissileSpeed(modObj:getVal('amsp'))
			obj:setMissileArc(modObj:getVal('amac'))
			obj:setMissileHoming(modObj:getVal('amho'))

			obj:setTargetAttachCount(modObj:getVal('atac'))

			for i = 0, 5, 1 do
				obj:setTargetAttach(i, string.format(modObj:getVal('ata%i'), i))
			end

			obj:setCasterAttachCount(modObj:getVal('acac'))
			obj:setCasterAttach(modObj:getVal('acap'))
			obj:setCasterAttach1(modObj:getVal('aca1'))

			obj:setSpecialAttach(modObj:getVal('aspt'))

			obj:setAnim(modObj:getVal('aani'))

			for level, val in pairs(modObj:getValAllLevels('atp1')) do
				obj:setTooltip(level, val)
			end
			for level, val in pairs(modObj:getValAllLevels('aut1')) do
				obj:setTooltipOff(level, val)
			end
			for level, val in pairs(modObj:getValAllLevels('aub1')) do
				obj:setUberTooltip(level, val)
			end
			for level, val in pairs(modObj:getValAllLevels('auu1')) do
				obj:setUberTooltipOff(level, val)
			end

			obj:setResearchTooltip(modObj:getVal('aret'))
			obj:setResarchUberTooltip(modObj:getVal('arut'))

			obj:setResarchHotkey(modObj:getVal('arhk'))
			obj:setHotkey(modObj:getVal('ahky'))
			obj:setHotkeyOff(modObj:getVal('auhk'))

			obj:setRequirement(modObj:getVal('areq'))
			obj:setRequirementAmount(modObj:getVal('arqa'))
			obj:setCheckDep(modObj:getVal('achd'))

			obj:setPrio(modObj:getVal('apri'))
			obj:setOrder(modObj:getVal('aord'))
			obj:setOrderUn(modObj:getVal('aoru'))
			obj:setOrderOn(modObj:getVal('aoro'))
			obj:setOrderOff(modObj:getVal('aorf'))

			obj:setSound(modObj:getVal('aefs'))
			obj:setSoundLoop(modObj:getVal('aefl'))

			obj:setLevels(modObj:getVal('alev'))
			obj:setLevelReq(modObj:getVal('arlv'))
			obj:setLevelSkip(modObj:getVal('alsk'))

			obj:setTargets(modObj:getVal('atar'))

			for level, val in pairs(modObj:getValAllLevels('acas')) do
				obj:setCastTime(val, level)
			end
			for level, val in pairs(modObj:getValAllLevels('adur')) do
				obj:setDuration(val, level)
			end
			for level, val in pairs(modObj:getValAllLevels('ahdu')) do
				obj:setHeroDuration(val, level)
			end
			for level, val in pairs(modObj:getValAllLevels('acdn')) do
				obj:setCooldown(val, level)
			end
			for level, val in pairs(modObj:getValAllLevels('amcs')) do
				obj:setManaCost(val, level)
			end
			for level, val in pairs(modObj:getValAllLevels('aare')) do
				obj:setArea(val, level)
			end
			for level, val in pairs(modObj:getValAllLevels('aran')) do
				obj:setRange(val, level)
			end
			for level, val in pairs(modObj:getValAllLevels('abuf')) do
				obj:setBuffId(val, level)
			end
			for level, val in pairs(modObj:getValAllLevels('aeff')) do
				obj:setEffectId(val, level)
			end
		end
	end

	function this:readFromFile(path)
		assert(path, 'no path')

		require 'wc3objMod'

		local objMod = objMod.create()

		this:fromObjMod(objMod:readFromFile(path))
	end

	return this
end

t.createMod = createMod

require 'wc3objMerge'

local function createMix()
	local this = {}

	require 'wc3profile'

	this.slk = createSlk()
	this.profile = wc3profile.create()
	this.mod = createMod()

	local function reduce()
		require 'wc3objMerge'

		local merge = wc3objMerge.create()
for objId, obj in pairs(this.mod:toObjMod().objs) do
if objId == 'SL6C' then
	print('mod', objId, obj:get('alev'))
end
end
		merge:addSlk('AbilityData', this.slk:toSlk())
		merge:addMod('war3map.w3a', this.mod:toObjMod())

		local reduceMetaSlk = slkLib.create()

		reduceMetaSlk:readFromFile(io.local_dir()..[[meta\AbilityMetaData.slk]])

		return merge:mix(reduceMetaSlk)
	end

	function this:writeToDir(path, useReduce)
		assert(path, 'no path')

		local outSlk
		local outProfile
		local outMod

		if useReduce then
			local slks, profiles, mods = reduce()

			outSlk = slks['AbilityData']
			outProfile = profiles['profile']
			outMod = mods['war3map.w3a']
		else
			outSlk = this.slk:toSlk()
			outProfile = this.profile
			outMod = this.mod
		end

		path = io.toFolderPath(path)
for objId, obj in pairs(outMod.objs) do
if objId == 'SL6C' then
	print('modB', objId, obj:get('alev'))
end
end
		outSlk:writeToFile(path..[[Units\AbilityData.slk]])
		outProfile:writeToFile(path..[[Units\abilprofile.txt]])
		outMod:writeToFile(path..[[war3map.w3a]])
	end

	return this
end

t.createMix = createMix

expose('wc3ability', t)