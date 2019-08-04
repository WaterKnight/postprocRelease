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

		function obj:setEffect(val)
			obj.isEffect = val
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

		slk:addField('isEffect')
		slk:addField('version')
		slk:addField('useInEditor')

		slk:addField('sort')
		slk:addField('race')
		slk:addField('InBeta')

		for objId, obj in pairs(this.objs) do
			local slkObj = slk:addObj(objId)

			slkObj:set('code', obj.code)
			slkObj:set('isEffect', obj.isEffect)
			slkObj:set('race', obj.race)
		end
print('toSlkB', slk.pivotField)
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
			obj:setEffect(objData.vals['isEffect'])
			obj:setRace(objData.vals['race'])
		end
	end

	return this
end

t.createSlk = createSlk

local function createMod()
	local this = {}

	require 'wc3objMod'

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

		function obj:setTooltip(val)
			obj.tooltip = val
		end

		function obj:setUberTooltip(val)
			obj.uberTooltip = val
		end

		function obj:setEffect(val)
			obj.isEffect = val or 0
		end

		function obj:setRace(val)
			obj.race = val
		end

		function obj:setIcon(val)
			obj.icon = val
		end

		function obj:setBolt(val)
			obj.bolt = val
		end

		function obj:setDetail(val)
			obj.detail = val
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

		function obj:setTargetArt(val)
			obj.targetArt = val
		end

		function obj:setTargetAttachCount(val)
			obj.targetAttachCount = val or 0
		end

		obj.targetAttach = {}

		function obj:setTargetAttach(index, val)
			obj.targetAttach[index] = val
		end

		function obj:setEffectArt(val)
			obj.effectArt = val
		end

		function obj:setEffectAttach(val)
			obj.effectAttach = val
		end

		function obj:setSpecialArt(val)
			obj.specialArt = val
		end

		function obj:setSpecialAttach(val)
			obj.specialAttach = val
		end

		function obj:setSound(val)
			obj.sound = val
		end

		function obj:setSoundLoop(val)
			obj.soundLoop = val
		end

		function obj:merge(other)
			assert(other, 'no other')

			local t = {
				'name',
				'tooltip',
				'uberTooltip',

				'isEffect',
				'race',
				'icon',

				'bolt',
				'detail',

				'missileArt',
				'missileSpeed',
				'missileArc',
				'missileHoming',
				
				'targetArt',
				'targetAttachCount',
				'targetAttach',
				
				'effectArt',
				'effectAttach',

				'specialArt',
				'specialAttach',

				'sound',
				'soundLoop'
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

			modObj:set('fnam', obj.name)
			modObj:set('ftip', obj.tooltip)
			modObj:set('fube', obj.uberTooltip)

			modObj:set('feff', obj.isEffect)
			modObj:set('frac', obj.race)
			modObj:set('fart', obj.icon)

			modObj:set('flig', obj.bolt)
			modObj:set('fspd', obj.detail)

			modObj:set('fmat', obj.missileArt)
			modObj:set('fmsp', obj.missileSpeed)
			modObj:set('fmac', obj.missileArc)
			modObj:set('fmho', obj.missileHoming)

			modObj:set('ftat', obj.targetArt)
			modObj:set('ftac', obj.targetAttachCount)

			for i = 0, 5, 1 do
				modObj:set(string.format('fta%i', i), obj.targetAttach[i])
			end

			modObj:set('feat', obj.effectArt)
			modObj:set('feft', obj.effectAttach)

			modObj:set('fsat', obj.specialArt)
			modObj:set('fspt', obj.specialAttach)

			modObj:set('fefs', obj.sound)
			modObj:set('fefl', obj.soundLoop)
		end

		objMod:addMeta(io.local_dir()..[[meta\AbilityBuffMetaData.slk]])

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

			obj:setName(modObj:getVal('fnam'))
			obj:setTooltip(modObj:getVal('ftip'))
			obj:setUberTooltip(modObj:getVal('fube'))

			obj:setEffect(modObj:getVal('feff'))
			obj:setRace(modObj:getVal('frac'))
			obj:setIcon(modObj:getVal('fart'))

			obj:setBolt(modObj:getVal('flig'))
			obj:setDetail(modObj:getVal('fspd'))

			obj:setMissileArt(modObj:getVal('fmat'))
			obj:setMissileSpeed(modObj:getVal('fmsp'))
			obj:setMissileArc(modObj:getVal('fmac'))
			obj:setMissileHoming(modObj:getVal('fmho'))

			obj:setTargetArt(modObj:getVal('ftat'))
			obj:setTargetAttachCount(modObj:getVal('ftac'))
			obj:setTargetAttach(modObj:getVal('fta0'))
			obj:setTargetAttach(modObj:getVal('fta1'))
			obj:setTargetAttach(modObj:getVal('fta2'))
			obj:setTargetAttach(modObj:getVal('fta3'))
			obj:setTargetAttach(modObj:getVal('fta4'))
			obj:setTargetAttach(modObj:getVal('fta5'))

			obj:setEffectArt(modObj:getVal('feat'))
			obj:setEffectAttach(modObj:getVal('feft'))

			obj:setSpecialArt(modObj:getVal('fsat'))
			obj:setSpecialAttach(modObj:getVal('fspt'))

			obj:setEffectSound(modObj:getVal('fefs'))
			obj:setEffectSoundLoop(modObj:getVal('fefl'))
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

		merge:addSlk('AbilityBuffData', this.slk:toSlk())
		merge:addMod('war3map.w3h', this.mod:toObjMod())

		local reduceMetaSlk = slkLib.create()

		reduceMetaSlk:readFromFile(io.local_dir()..[[meta\AbilityBuffMetaData.slk]])

		return merge:mix(reduceMetaSlk)
	end

	function this:writeToDir(path, useReduce)
		assert(path, 'no path')

		local outSlk
		local outProfile
		local outMod

		if useReduce then
			local slks, profiles, mods = reduce()

			outSlk = slks['AbilityBuffData']
			outProfile = profiles['profile']
			outMod = mods['war3map.w3h']
		else
			outSlk = this.slk:toSlk()
			outProfile = this.profile
			outMod = this.mod:toObjMod()
		end

		path = io.toFolderPath(path)

		outSlk:writeToFile(path..[[Units\AbilityBuffData.slk]])
		outProfile:writeToFile(path..[[Units\buffprofile.txt]])
		outMod:writeToFile(path..[[war3map.w3h]])
	end

	return this
end

t.createMix = createMix

expose('wc3buff', t)