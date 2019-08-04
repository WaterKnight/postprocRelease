require 'waterlua'

local t = {}

t.create = function()
	local this = {}
	
	this.units = {}
	
	function this:createUnit()
		local unit = {}
		
		this.units[#this.units + 1] = unit
		unit.index = #this.units
		
		function unit:setTypeId(typeId)
			assert(typeId, 'no typeId')

			unit.typeId = typeId
		end
		
		function unit:setVariation(variation)
			assert(variation, 'no variation')

			unit.variation = variation
		end
		
		function unit:setPos(x, y, z)
			assert(x or y or z, 'no coordinates')

			x = x or 0
			y = y or 0
			z = z or 0

			unit.x = x
			unit.y = y
			unit.z = z
		end
		
		function unit:setAngle(ang)
			assert(ang, 'no angle')

			unit.ang = ang
		end
		
		function unit:setScale(x, y, z)
			assert(x or y or z, 'no coordinates')

			x = x or 0
			y = y or 0
			z = z or 0

			unit.scaleX = x
			unit.scaleY = y
			unit.scaleZ = z
		end
		
		function unit:setFlags(flags)
			assert(flags, 'no flags')

			unit.flags = flags
		end
		
		function unit:setOwnerIndex(ownerIndex)
			assert(ownerIndex, 'no ownerIndex')

			unit.ownerIndex = ownerIndex
		end

		function unit:setUnknown(val)
			assert(val, 'no val')

			unit.unknown = val
		end

		function unit:setUnknown2(val)
			assert(val, 'no val')

			unit.unknown2 = val
		end

		function unit:setLife(life)
			assert(life, 'no life')

			unit.life = life
		end
		
		function unit:setMana(mana)
			assert(mana, 'no mana')

			unit.mana = mana
		end

		function unit:setItemTablePointer(pointer)
			assert(pointer, 'no val')

			unit.itemTablePointer = pointer
		end
		
		unit.itemSets = {}
		
		function unit:createItemSet()
			local itemSet = {}
			
			function itemSet:remove()
				unit.itemSets[itemSet.index] = unit.itemSets[#unit.itemSets]
				unit.itemSets[#unit.itemSets] = nil
			end
			
			unit.itemSets[#unit.itemSets + 1] = itemSet
			itemSet.index = #unit.itemSets
			
			itemSet.items = {}

			function itemSet:addItem(typeId, chance)
				local item = {}

				function item:remove()
					itemSet.items[item.index] = itemSet.items[#itemSet.items]
					itemSet.items[#itemSet.items] = nil
				end

				itemSet.items[#itemSet.items + 1] = item
				item.index = #itemSet.items

				item.typeId = typeId
				item.chance = chance
			end

			return itemSet
		end
		
		function unit:setResourceAmount(amount)
			assert(amount, 'no amount')

			unit.resourceAmount = amount
		end

		function unit:setTargetAcquisition(val)
			assert(val, 'no val')

			unit.targetAcquisition = val
		end

		function unit:setHeroLevel(level)
			assert(level, 'no level')

			unit.heroLevel = level
		end

		function unit:setHeroStr(val)
			assert(val, 'no val')

			unit.heroStr = val
		end

		function unit:setHeroAgi(val)
			assert(val, 'no val')

			unit.heroAgi = val
		end

		function unit:setHeroInt(val)
			assert(val, 'no val')

			unit.heroInt = val
		end

		function unit:addInventoryItem(typeId, slot)
			assert(typeId, 'no typeId')

			if (slot == nil) then
				slot = 0

				while (unit.inventoryItemsBySlot[slot] ~= nil) do
					slot = slot + 1
				end
			end

			local item = unit.inventoryItemsBySlot[slot]

			if (item == nil) then
				item = {}

				unit.inventoryItemsBySlot[slot] = item
				unit.inventoryItems[#unit.inventoryItems + 1] = item
				item.index = #unit.inventoryItems
			end

			item.typeId = typeId
			item.chance = chance

			function item:remove()
				unit.inventoryItems[#item.index] = unit.inventoryItems[#unit.inventoryItems]
				unit.inventoryItems[#unit.inventoryItems] = nil
			end

			return item
		end

		unit.abils = {}

		function unit:createAbility(typeId, level, autocast)
			assert(typeId, 'no typeId')

			level = level or 1
			autocast = autocast or false

			local abil = {}

			unit.abils[#unit.abils + 1] = abil
			abil.index = #unit.abils

			abil.typeId = typeId
			abil.level = level
			abil.autocast = autocast

			function abil:remove()
				unit.abils[#abil.index] = unit.abils[#unit.abils]
				unit.abils[#unit.abils] = nil
			end

			return abil
		end

		function unit:setRandomFlag(val)
			assert(val, 'no val')

			unit.randomFlag = val
		end

		function unit:setRandomLevel(level)
			assert(level, 'no level')

			unit.randomLevel = level
		end

		function unit:setRandomLevel2(level)
			assert(level, 'no level')

			unit.randomLevel2 = level
		end

		function unit:setRandomLevel3(level)
			assert(level, 'no level')

			unit.randomLevel3 = level
		end

		function unit:setRandomClass(class)
			assert(class, 'no class')

			unit.randomClass = class
		end

		function unit:setRandomGroupIndex(index)
			assert(index, 'no index')

			unit.randomGroupIndex = index
		end

		function unit:setRandomGroupPosition(pos)
			assert(pos, 'no pos')

			unit.randomGroupPosition = pos
		end

		function createRandomUnit(typeId, chance)
			assert(typeId, 'no typeId')
			assert(chance, 'no chance')

			local randUnit = {}

			unit.randUnits[#unit.randUnits + 1] = randUnit
			randUnit.index = #unit.randUnits

			randUnit.typeId = typeId
			randUnit.chance = chance

			function randUnit:remove()
				unit.randUnits[#randUnit.index] = unit.randUnits[#unit.randUnits]
				unit.randUnits[#unit.randUnits] = nil
			end

			return randUnit
		end

		function unit:setCustomColor(colorIndex)
			assert(colorIndex, 'no colorIndex')

			unit.customColor = colorIndex
		end

		function unit:setWaygateTargetRectIndex(index)
			assert(index, 'no index')

			unit.waygateTargetRectIndex = index
		end

		function unit:setEditorID(id)
			assert(id, 'no id')

			unit.editorID = id
		end
		
		unit:setTypeId(0)
		unit:setVariation(0)
		unit:setPos(0, 0, 0)
		unit:setAngle(0)
		unit:setScale(1, 1, 1)
		unit:setFlags(0)
		unit:setOwnerIndex(0)
		unit:setUnknown(0)
		unit:setUnknown2(0)
		unit:setLife(-1)
		unit:setMana(-1)
		unit:setItemTablePointer(0)
		unit:setResourceAmount(0)
		unit:setTargetAcquisition(-1)

		unit:setHeroLevel(1)
		unit:setHeroStr(0)
		unit:setHeroAgi(0)
		unit:setHeroInt(0)

		unit:setRandomFlag(0)
		unit:setRandomLevel(0)
		unit:setRandomLevel2(0)
		unit:setRandomLevel3(0)
		unit:setRandomClass(0)
		unit:setRandomGroupIndex(0)
		unit:setRandomGroupPosition(0)

		unit:setCustomColor(-1)
		unit:setWaygateTargetRectIndex(-1)
		unit:setEditorID(0)

		function unit:remove()
			this.units[unit.index] = this.units[#this.units]
			this.units[#this.units] = nil
		end

		return unit
	end

	--format 8
	local function maskFunc(root)
		root:add('startToken', 'id')
		root:add('format', 'int')

		wc3binaryFile.checkFormatVer('dooUnitsMaskFunc', 8, root:getVal('format'))

		root:add('formatSub', 'int')

		root:add('unitsCount', 'int')

		for i = 1, root:getVal('unitsCount'), 1 do
			local unit = root:addNode('unit'..i)

			unit:add('type', 'id')

			unit:add('variation', 'int')

			unit:add('x', 'float')
			unit:add('y', 'float')
			unit:add('z', 'float')

			unit:add('angle', 'float')

			unit:add('scaleX', 'float')
			unit:add('scaleY', 'float')
			unit:add('scaleZ', 'float')

			unit:add('flags', 'byte')
			unit:add('ownerIndex', 'int')
			unit:add('unknown', 'byte')
			unit:add('unknown2', 'byte')

			unit:add('life', 'int')
			unit:add('mana', 'int')

			unit:add('itemTablePointer', 'int')

			unit:add('itemsDroppedCount', 'int')

			for i2 = 1, unit:getVal('itemsDroppedCount'), 1 do
				local itemSet = unit:addNode('item'..i2)

				itemSet:add('itemCount', 'int')

				for i3 = 1, itemSet:getVal('itemCount') do
					local item = itemSet:addNode('item'..i3)

					item:add('type', 'id')
					item:add('chance', 'int')
				end
			end

			unit:add('resourceAmount', 'int')

			unit:add('targetAcquisition', 'float')

			unit:add('heroLevel', 'int')
			unit:add('heroStr', 'int')
			unit:add('heroAgi', 'int')
			unit:add('heroInt', 'int')

			unit:add('inventoryItemsCount', 'int')

			for i2 = 1, unit:getVal('inventoryItemsCount'), 1 do
				local item = unit:addNode('inventoryItem'..i2)

				item:add('slot', 'int')
				item:add('type', 'id')
			end

			unit:add('abilityModsCount', 'int')

			for i2 = 1, unit:getVal('abilityModsCount'), 1 do
				local item = unit:addNode('abilityMod'..i2)

				item:add('type', 'id')
				item:add('autocast', 'int')
				item:add('level', 'int')
			end

			unit:add('randomFlag', 'int')

			if (unit:getVal('randomFlag') == 0) then
				unit:add('randomLevel', 'byte')
				unit:add('randomLevel2', 'byte')
				unit:add('randomLevel3', 'byte')

				unit:add('randomClass', 'byte')
			elseif (unit:getVal('randomFlag') == 1) then
				unit:add('randomGroupIndex', 'int')
				unit:add('randomGroupPosition', 'int')
			elseif (unit:getVal('randomFlag') == 2) then
				unit:add('randomUnitsCount', 'int')

				for i2 = 1, unit:getVal('randomUnitsCount'), 1 do
					local item = unit:addNode('randomUnit'..i2)

					item:add('type', 'id')
					item:add('chance', 'int')
				end
			end

			unit:add('customColor', 'int')
			unit:add('waygateTargetRectIndex', 'int')

			unit:add('editorID', 'int')

		end
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		require 'wc3binaryFile'

		local root = wc3binaryFile.create()

		root:add('startToken', 'id')
		root:setVal('startToken', 'W3do')

		root:add('format', 'int')
		root:setVal('format', 8)
		root:add('formatSub', 'int')
		root:setVal('formatSub', 0x0000000b)

		root:add('unitsCount', 'int')
		root:setVal('unitsCount', #this.units)

		for i = 1, #this.units, 1 do
			local unit = this.units[i]

			local unitNode = root:addNode('unit'..i)

			unitNode:add('type', 'id')
			unitNode:setVal('type', unit.typeId)

			unitNode:add('variation', 'int')
			unitNode:setVal('variation', unit.variation)

			unitNode:add('x', 'float')
			unitNode:setVal('x', unit.x)
			unitNode:add('y', 'float')
			unitNode:setVal('y', unit.y)
			unitNode:add('z', 'float')
			unitNode:setVal('z', unit.z)

			unitNode:add('angle', 'float')
			unitNode:setVal('angle', unit.ang)

			unitNode:add('scaleX', 'float')
			unitNode:setVal('scaleX', unit.scaleX)
			unitNode:add('scaleY', 'float')
			unitNode:setVal('scaleY', unit.scaleY)
			unitNode:add('scaleZ', 'float')
			unitNode:setVal('scaleZ', unit.scaleZ)

			unitNode:add('flags', 'byte')
			unitNode:setVal('flags', unit.flags)
			unitNode:add('ownerIndex', 'int')
			unitNode:setVal('ownerIndex', unit.ownerIndex)
			unitNode:add('unknown', 'byte')
			unitNode:setVal('unknown', unit.unknown)
			unitNode:add('unknown2', 'byte')
			unitNode:setVal('unknown2', unit.unknown2)

			unitNode:add('life', 'int')
			unitNode:setVal('life', unit.life)
			unitNode:add('mana', 'int')
			unitNode:setVal('mana', unit.mana)

			unitNode:add('itemTablePointer', 'int')
			unitNode:setVal('itemTablePointer', unit.itemTablePointer)

			unitNode:add('itemsDroppedCount', 'int')
			unitNode:setVal('itemsDroppedCount', #unit.itemSets)

			for i2 = 1, #unit.itemSets, 1 do
				local itemSetNode = unit:addNode('item'..i2)

				local itemSet = unit.itemSets[i2]

				itemSet:add('itemCount', 'int')
				itemSet:setVal('itemCount', #itemSet.items)

				for i3 = 1, #itemSet.items, 1 do
					local itemNode = itemSetNode:addNode('item'..i3)

					local item = itemSet.items[i3]

					itemNode:add('type', 'id')
					itemNode:setVal('type', item.typeId)
					itemNode:add('chance', 'int')
					itemNode:setVal('chance', item.chance)
				end
			end

			unitNode:add('resourceAmount', 'int')
			unitNode:setVal('resourceAmount', unit.resourceAmount)

			unitNode:add('targetAcquisition', 'float')
			unitNode:setVal('targetAcquisition', unit.targetAcquisition)

			unitNode:add('heroLevel', 'int')
			unitNode:setVal('heroLevel', unit.heroLevel)
			unitNode:add('heroStr', 'int')
			unitNode:setVal('heroStr', unit.heroStr)
			unitNode:add('heroAgi', 'int')
			unitNode:setVal('heroAgi', unit.heroAgi)
			unitNode:add('heroInt', 'int')
			unitNode:setVal('heroInt', unit.heroInt)

			unitNode:add('inventoryItemsCount', 'int')
			unitNode:setVal('inventoryItemsCount', #unit.inventoryItems)

			for i2 = 1, #unit.inventoryItems, 1 do
				local itemNode = unit:addNode('inventoryItem'..i2)

				item = unit.inventoryItems[i2]

				itemNode:add('slot', 'int')
				itemNode:setVal('slot', item.slot)
				itemNode:add('type', 'id')
				itemNode:setVal('type', item.typeId)
			end

			unitNode:add('abilityModsCount', 'int')
			unitNode:setVal('abilityModsCount', #unit.abils)

			for i2 = 1, #unit.abils, 1 do
				local itemNode = unit:addNode('abil'..i2)

				local abil = unit.abils[i2]

				abilNode:add('type', 'id')
				abilNode:setVal('type', abil.typeId)
				abilNode:add('autocast', 'int')
				abilNode:setVal('autocast', abil.autocast)
				abilNode:add('level', 'int')
				abilNode:setVal('level', abil.level)
			end

			unitNode:add('randomFlag', 'int')
			unitNode:setVal('randomFlag', unit.randomFlag)

			if (unit.randomLevel == 0) then
				unitNode:add('randomLevel', 'int')
				unitNode:setVal('randomLevel', unit.randomLevel)
				unitNode:add('randomLevel2', 'int')
				unitNode:setVal('randomLevel2', unit.randomLevel2)
				unitNode:add('randomLevel3', 'int')
				unitNode:setVal('randomLevel3', unit.randomLevel3)
			elseif (unit.randomLevel == 1) then
				unitNode:add('randomClass', 'int')
				unitNode:setVal('randomClass', unit.randomClass)
				unitNode:add('randomGroupIndex', 'int')
				unitNode:setVal('randomGroupIndex', unit.randomGroupIndex)
				unitNode:add('randomGroupPosition', 'int')
				unitNode:setVal('randomGroupPosition', unit.randomGroupIndex)
			elseif (unit.randomLevel == 2) then
				unitNode:add('randomUnitsCount', 'int')
				unitNode:setVal('randomUnitsCount', #unit.randUnits)

				for i2 = 1, #unit.randUnits, 1 do
					local itemNode = unitNode:addNode('randomUnit'..i2)

					local item = unit.randUnits[i2]

					itemNode:add('type', 'id')
					itemNode:setVal('type', item.typeId)
					itemNode:add('chance', 'int')
					itemNode:setVal('chance', item.chance)
				end
			end

			unitNode:add('customColor', 'int')
			unitNode:setVal('customColor', unit.customColor)
			unitNode:add('waygateTargetRectIndex', 'int')
			unitNode:setVal('waygateTargetRectIndex', unit.waygateTargetRectIndex)

			unitNode:add('editorID', 'int')
			unitNode:setVal('editorID', unit.editorID)
		end

		root:writeToFile(path, maskFunc)
	end
	
	function this:readFromFile(path)
		assert(path, 'no path')

		require 'wc3binaryFile'

		local root = wc3binaryFile.create()

		root:readFromFile(path, maskFunc)

		local count = root:getVal('unitsCount')

		assert(count, 'no unitsCount')

		for i = 1, count, 1 do
			local unitNode = root:getSub('unit'..i)

			local unit = this:createUnit()

			unit:setTypeId(unitNode:getVal('type'))
			unit:setVariation(unitNode:getVal('variation'))

			unit:setPos(unitNode:getVal('x'), unitNode:getVal('y'), unitNode:getVal('z'))

			unit:setAngle(unitNode:getVal('angle'))

			unit:setScale(unitNode:getVal('scaleX'), unitNode:getVal('scaleY'), unitNode:getVal('scaleZ'))

			unit:setFlags(unitNode:getVal('flags'))
			unit:setOwnerIndex(unitNode:getVal('ownerIndex'))
			unit:setUnknown(unitNode:getVal('unknown'))
			unit:setUnknown2(unitNode:getVal('unknown2'))

			unit:setLife(unitNode:getVal('life'))
			unit:setMana(unitNode:getVal('mana'))

			unit:setItemTablePointer(unitNode:getVal('itemTablePointer'))

			for i2 = 1, unitNode:getVal('itemsDroppedCount'), 1 do
				local itemSetNode = unitNode:getSub('item'..i2)

				local itemSet = dood:createItemSet()

				for i3 = 1, itemSetNode:getVal('itemCount'), 1 do
					local itemNode = itemSetNode:getSub('item'..i3)

					itemSet:addItem(itemNode:getVal('type'), itemNode:getVal('chance'))
				end
			end

			unit:setResourceAmount(unitNode:getVal('resourceAmount'))

			unit:setTargetAcquisition(unitNode:getVal('targetAcquisition'))

			unit:setHeroLevel(unitNode:getVal('heroLevel'))
			unit:setHeroStr(unitNode:getVal('heroStr'))
			unit:setHeroAgi(unitNode:getVal('heroAgi'))
			unit:setHeroInt(unitNode:getVal('heroInt'))

			for i2 = 1, unitNode:getVal('inventoryItemsCount'), 1 do
				local item = unitNode:getSub('inventoryItem'..i2)

				unit:addInventoryItem(unitNode:getVal('type'), unitNode:getVal('slot'))
			end

			for i2 = 1, unitNode:getVal('abilityModsCount'), 1 do
				local item = unitNode:getSub('abilityMod'..i2)

				unit:addAbility(item:getVal('type'), item:getVal('level'), item:getVal('autocast'))
			end

			unit:setRandomFlag(unitNode:getVal('randomFlag'))

			if (unit.randomFlag == 0) then
				unit:setRandomLevel(unitNode:getVal('randomLevel'))
				unit:setRandomLevel2(unitNode:getVal('randomLevel2'))
				unit:setRandomLevel3(unitNode:getVal('randomLevel3'))

				unit:setRandomClass(unitNode:getVal('randomClass'))
			elseif (unit.randomFlag == 1) then
				unit:setRandomGroupIndex(unitNode:getVal('randomGroupIndex'))
				unit:setRandomGroupPosition(unitNode:getVal('randomGroupPosition'))
			elseif (unit.randomFlag == 2) then
				unit:createRandomUnit(unitNode:getVal('type'), unitNode:getVal('chance'))
			end

			unit:setCustomColor(unitNode:getVal('customColor'))
			unit:setWaygateTargetRectIndex(unitNode:getVal('waygateTargetRectIndex'))

			unit:setEditorID(unitNode:getVal('editorID'))
		end
	end

	return this
end

expose('wc3dooUnits', t)