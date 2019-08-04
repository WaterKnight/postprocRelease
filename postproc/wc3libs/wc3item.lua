require 'waterlua'

local t = {}

t.create = function()
	local this = {}

	this.objs = {}

	function this:addObj(id)
		assert(id, 'no id')

		local obj = {}

		this.objs[id] = obj

		function obj:setClass(val)
			obj.class = val
		end

		function obj:setLevel(val)
			obj.level = val or 1
		end

		function obj:setOldLevel(val)
			obj.oldLevel = val or 1
		end

		function obj:setAbils(val)
			obj.abils = val
		end

		function obj:setCooldownId(val)
			obj.cooldownId = val
		end

		function obj:setIgnoreCooldown(val)
			obj.ignoreCooldown = val or 0
		end

		function obj:setCharges(val)
			obj.charges = val or 0
		end

		function obj:setPrio(val)
			obj.prio = val or 0
		end

		function obj:setUsable(val)
			obj.usable = val or 0
		end

		function obj:setPerishable(val)
			obj.perishable = val or 0
		end

		function obj:setDroppable(val)
			obj.droppable = val or 0
		end

		function obj:setPawnable(val)
			obj.pawnable = val or 0
		end

		function obj:setSellable(val)
			obj.sellable = val or 0
		end

		function obj:setRandomable(val)
			obj.canBeRandomed = val or 0
		end

		function obj:setPowerup(val)
			obj.powerup = val or 0
		end

		function obj:setDropOnDeath(val)
			obj.dropOnDeath = val or 0
		end

		function obj:setStockMax(val)
			obj.stockMax = val or 0
		end

		function obj:setStockRegen(val)
			obj.stockRegen = val or 0
		end

		function obj:setStockStart(val)
			obj.stockStart = val or 0
		end

		function obj:setGoldCost(val)
			obj.goldCost = val or 0
		end

		function obj:setLumberCost(val)
			obj.lumberCost = val or 0
		end

		function obj:setLife(val)
			obj.life = val or 0
		end

		function obj:setMorphable(val)
			obj.canBeMorphed = val or 0
		end

		function obj:setArmor(val)
			obj.armor = val
		end

		function obj:setModel(val)
			obj.model = val
		end

		function obj:setScale(val)
			obj.scale = val or 1
		end

		function obj:setSelSize(val)
			obj.selSize = val or 1
		end

		function obj:setColor(red, green, blue)
			obj.red = red or 255
			obj.green = green or 255
			obj.blue = blue or 255
		end

		return obj
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		require 'slkLib'

		local slk = createSlk()

		slk:addField('itemID')

		slk:addField('comment')

		slk:addField('scriptname')
		slk:addField('version')

		slk:addField('class')
		slk:addField('Level')
		slk:addField('oldLevel')

		slk:addField('abilList')

		slk:addField('cooldownID')
		slk:addField('ignoreCD')

		slk:addField('uses')
		slk:addField('prio')
		slk:addField('usable')
		slk:addField('perishable')
		slk:addField('droppable')
		slk:addField('pawnable')
		slk:addField('sellable')
		slk:addField('pickRandom')
		slk:addField('powerup')
		slk:addField('drop')
		slk:addField('stockMax')
		slk:addField('stockRegem')
		slk:addField('stockStart')

		slk:addField('goldcost')
		slk:addField('lumbercost')

		slk:addField('HP')
		slk:addField('morph')
		slk:addField('armor')

		slk:addField('file')
		slk:addField('scale')
		slk:addField('selSize')

		slk:addField('colorR')
		slk:addField('colorG')
		slk:addField('colorB')

		slk:addField('InBeta')

		for i = 1, #this.objs, 1 do
			local obj = this.objs[i]

			local id = obj.id

			local slkObj = slk:addObj(id)

			slkObj:set('class', obj.class)
			slkObj:set('Level', obj.level)
			slkObj:set('oldLevel', obj.oldLevel)
			slkObj:set('abilList', obj.abils)
			slkObj:set('cooldownID', obj.cooldownId)
			slkObj:set('ignoreCD', obj.ignoreCooldown)
			slkObj:set('uses', obj.charges)
			slkObj:set('prio', obj.prio)
			slkObj:set('usable', obj.canBeUsed)
			slkObj:set('perishable', obj.perishable)
			slkObj:set('droppable', obj.canBeDropped)
			slkObj:set('pawnable', obj.canBePawned)
			slkObj:set('sellable', obj.canBeSold)
			slkObj:set('pickRandom', obj.canBeRandomed)
			slkObj:set('powerup', obj.powerup)
			slkObj:set('drop', obj.dropOnDeath)
			slkObj:set('stockMax', obj.stockMax)
			slkObj:set('stockRegen', obj.stockRegen)
			slkObj:set('stockStart', obj.stockStart)
			slkObj:set('goldcost', obj.goldCost)
			slkObj:set('lumbercost', obj.lumberCost)
			slkObj:set('HP', obj.life)
			slkObj:set('morph', obj.canBeMorphed)
			slkObj:set('armor', obj.armor)
			slkObj:set('file', obj.model)
			slkObj:set('scale', obj.scale)
			slkObj:set('selSize', obj.selSize)
			slkObj:set('colorR', obj.red)
			slkObj:set('colorG', obj.green)
			slkObj:set('colorB', obj.blue)
		end

		slk:writeToFile(path)
	end

	function this:readFromFile(path)
		assert(path, 'no path')

		require 'slkLib'

		local slk = createSlk()

		slk:readFromFile(path)

		for id, objData in pairs(slk.objs) do
			local obj = this:addObj(id)

			obj:setClass(objData.vals['class'])
			obj:setLevel(objData.vals['Level'])
			obj:setOldLevel(objData.vals['oldLevel'])
			obj:setAbils(objData.vals['abilList'])
			obj:setCooldownId(objData.vals['cooldownID'])
			obj:setIgnoreCooldown(objData.vals['ignoreCD'])
			obj:setCharges(objData.vals['uses'])
			obj:setPrio(objData.vals['prio'])
			obj:setUsable(objData.vals['usable'])
			obj:setPerishable(objData.vals['perishable'])
			obj:setDroppable(objData.vals['droppable'])
			obj:setPawnable(objData.vals['pawnable'])
			obj:setSellable(objData.vals['sellable'])
			obj:setRandomable(objData.vals['pickRandom'])
			obj:setPowerup(objData.vals['powerup'])
			obj:setDropOnDeath(objData.vals['drop'])
			obj:setStockMax(objData.vals['stockMax'])
			obj:setStockRegen(objData.vals['stockRegen'])
			obj:setStockStart(objData.vals['stockStart'])
			obj:setGoldCost(objData.vals['goldcost'])
			obj:setLumberCost(objData.vals['lumbercost'])
			obj:setLife(objData.vals['HP'])
			obj:setMorphable(objData.vals['morph'])
			obj:setArmor(objData.vals['armor'])
			obj:setModel(objData.vals['file'])
			obj:setScale(objData.vals['scale'])
			obj:setSelSize(objData.vals['selSize'])
			obj:setColor(objData.vals['colorR'], objData.vals['colorG'], objData.vals['colorB'])
		end
	end

	return this
end

expose('wc3item', t)