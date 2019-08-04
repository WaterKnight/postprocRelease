require 'waterlua'

local t = {}

t.create = function()
	local this = {}
	
	this.doods = {}
	
	function this:createDoodad()
		local dood = {}
		
		this.doods[#this.doods + 1] = dood
		dood.index = #this.doods
		
		function dood:setTypeId(typeId)
			assert(typeId, 'no typeId')

			dood.typeId = typeId
		end
		
		function dood:setVariation(variation)
			assert(variation, 'no variation')

			dood.variation = variation
		end
		
		function dood:setPos(x, y, z)
			assert(x or y or z, 'no coordinates')

			x = x or 0
			y = y or 0
			z = z or 0

			dood.x = x
			dood.y = y
			dood.z = z
		end
		
		function dood:setAngle(ang)
			assert(ang, 'no angle')

			dood.ang = ang
		end
		
		function dood:setScale(x, y, z)
			assert(x or y or z, 'no coordinates')

			x = x or 0
			y = y or 0
			z = z or 0

			dood.scaleX = x
			dood.scaleY = y
			dood.scaleZ = z
		end
		
		function dood:setLife(life)
			assert(life, 'no life')

			dood.life = life
		end
		
		function dood:setFlags(flags)
			flags = flags or 0

			dood.flags = flags
		end
		
		function dood:setItemTablePointer(pointer)
			assert(pointer, 'no pointer')

			dood.itemTablePointer = pointer
		end
		
		dood.itemSets = {}
		
		function dood:createItemSet()
			local itemSet = {}
			
			function itemSet:remove()
				dood.itemSets[itemSet.index] = dood.itemSets[#dood.itemSets]
				dood.itemSets[#dood.itemSets] = nil
			end
			
			dood.itemSets[#dood.itemSets + 1] = itemSet
			itemSet.index = #dood.itemSets
			
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
		
		function dood:setEditorID(id)
			assert(id, 'no id')

			dood.editorID = id
		end
		
		dood:setTypeId(0)
		dood:setVariation(0)
		dood:setPos(0, 0, 0)
		dood:setAngle(0)
		dood:setScale(1, 1, 1)
		dood:setLife(100)
		dood:setFlags(0)

		dood:setItemTablePointer(0)
		dood:setEditorID(0)
		
		function dood:remove()
			this.doods[dood.index] = this.doods[#this.doods]
			this.doods[#this.doods] = nil
		end
		
		return dood
	end

	this.specialDoods = {}

	function this:createSpecialDoodad()
		local dood = {}

		function dood:remove()
			this.specialDoods[dood.index] = this.specialDoods[#this.specialDoods]
			this.specialDoods[#this.specialDoods] = nil
		end

		this.specialDoods[#this.specialDoods + 1] = dood
		dood.index = #this.specialDoods
		
		function dood:setTypeId(typeId)
			assert(typeId, 'no typeId')

			dood.typeId = typeId
		end

		function dood:setPos(x, y, z)
			assert(x or y or z, 'no coordinates')

			x = x or 0
			y = y or 0
			z = z or 0

			dood.x = x
			dood.y = y
			dood.z = z
		end

		dood:setTypeId(0)
		dood:setPos(0, 0, 0)

		return dood
	end

	--format 8
	function maskFunc(root)
		root:add('startToken', 'id')
		root:add('format', 'int')

		wc3binaryFile.checkFormatVer('dooMaskFunc', 8, root:getVal('format'))

		root:add('formatSub', 'int')

		root:add('treeCount', 'int')

		for i = 1, root:getVal('treeCount'), 1 do
			local tree = root:addNode('tree'..i)

			tree:add('type', 'id')

			tree:add('variation', 'int')
			tree:add('x', 'float')
			tree:add('y', 'float')
			tree:add('z', 'float')

			tree:add('angle', 'float')

			tree:add('scaleX', 'float')
			tree:add('scaleY', 'float')
			tree:add('scaleZ', 'float')

			tree:add('flags', 'byte')
			tree:add('life', 'byte')

			tree:add('itemTablePointer', 'int')

			tree:add('itemsDroppedCount', 'int')

			for i2 = 1, tree:getVal('itemsDroppedCount'), 1 do
				local itemSet = tree:addNode('item'..i2)

				itemSet:add('itemCount', 'int')

				for i3 = 1, itemSet:getVal('itemCount') do
					local item = itemSet:addNode('item'..i3)

					item:add('type', 'id')
					item:add('chance', 'int')
				end
			end

			tree:add('editorID', 'int')

		end

		--format 0
		root:add('specialTreeFormat', 'int')

		root:add('specialTreeCount', 'int')

		for i = 1, root:getVal('specialTreeCount'), 1 do
			local tree = root:addNode('specialTree'..i)

			tree:add('type', 'id')

			tree:add('z', 'float')
			tree:add('x', 'float')
			tree:add('y', 'float')
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

		root:add('treeCount', 'int')
		root:setVal('treeCount', #this.doods)

		for i = 1, #this.doods, 1 do
			local dood = this.doods[i]

			local doodNode = root:addNode('tree'..i)

			doodNode:add('type', 'id')
			doodNode:setVal('type', dood.typeId)

			doodNode:add('variation', 'int')
			doodNode:setVal('variation', dood.variation)

			doodNode:add('x', 'float')
			doodNode:setVal('x', dood.x)
			doodNode:add('y', 'float')
			doodNode:setVal('y', dood.y)
			doodNode:add('z', 'float')
			doodNode:setVal('z', dood.z)

			doodNode:add('angle', 'float')
			doodNode:setVal('angle', dood.ang)

			doodNode:add('scaleX', 'float')
			doodNode:setVal('scaleX', dood.scaleX)
			doodNode:add('scaleY', 'float')
			doodNode:setVal('scaleY', dood.scaleY)
			doodNode:add('scaleZ', 'float')
			doodNode:setVal('scaleZ', dood.scaleZ)

			doodNode:add('life', 'byte')
			doodNode:setVal('life', dood.life)

			doodNode:add('flags', 'byte')
			doodNode:setVal('flags', dood.flags)

			doodNode:add('itemTablePointer', 'int')
			doodNode:setVal('itemTablePointer', dood.itemTablePointer)

			doodNode:add('itemsDroppedCount', 'int')
			doodNode:setVal('itemsDroppedCount', #dood.itemSets)

			for i2 = 1, #dood.itemSets, 1 do
				local itemSetNode = dood:addNode('item'..i2)

				local itemSet = dood.itemSets[i2]

				itemSet:add('itemCount', 'int')
				itemSet:setVal('itemCount', #itemSet.items)

				for i3 = 1, #itemSet.items, 1 do
					local itemNode = itemSetNode:addNode('item'..i3)

					itemNode:add('type', 'id')
					itemNode:setVal('type', item.typeId)
					itemNode:add('chance', 'int')
					itemNode:setVal('chance', item.chance)
				end
			end

			doodNode:add('editorID', 'int')
			doodNode:setVal('editorID', dood.editorID)
		end

		root:add('specialTreeFormat', 'int')
		root:setVal('specialTreeFormat', 0)
		
		root:add('specialTreeCount', 'int')
		root:setVal('specialTreeCount', #this.specialDoods)

		for i = 1, #this.specialDoods, 1 do
			local doodNode = root:AddNode('specialTree'..i)

			local dood = this.specialDoods[i]

			doodNode:setVal('id', dood.typeId)

			doodNode:add('x', 'float')
			doodNode:setVal('x', dood.x)
			doodNode:add('y', 'float')
			doodNode:setVal('y', dood.y)
			doodNode:add('z', 'float')
			doodNode:setVal('z', dood.z)
		end

		root:writeToFile(path, maskFunc)
	end
	
	function this:readFromFile(path)
		assert(path, 'no path')

		require 'wc3binaryFile'

		local root = wc3binaryFile.create()

		root:readFromFile(path, maskFunc)

		local count = root:getVal('treeCount')

		assert(count, 'no treeCount')

		for i = 1, count, 1 do
			local doodNode = root:getSub('tree'..i)

			local dood = this:createDoodad()

			dood:setTypeId(doodNode:getVal('type'))
			dood:setVariation(doodNode:getVal('variation'))
			dood:setPos(doodNode:getVal('x'), doodNode:getVal('y'), doodNode:getVal('z'))
			dood:setAngle(doodNode:getVal('angle'))
			dood:setScale(doodNode:getVal('scaleX'), doodNode:getVal('scaleY'), doodNode:getVal('scaleZ'))
			dood:setLife(doodNode:getVal('life'))
			dood:setFlags(doodNode:getVal('flags'))

			dood:setItemTablePointer(doodNode:getVal('itemTablePointer'))

			for i2 = 1, doodNode:getVal('itemsDroppedCount'), 1 do
				local itemSetNode = dood:getSub('item'..i2)

				local itemSet = dood:createItemSet()

				for i3 = 1, itemSetNode:getVal('itemCount'), 1 do
					local itemNode = itemSetNode:getSub('item'..i3)

					itemSet:addItem(itemNode:getVal('type'), itemNode:getVal('chance'))
				end
			end

			dood:setEditorID(doodNode:getVal('editorID'))
		end

		local specialCount = root:getVal('specialTreeCount')

		assert(specialCount, 'no specialCount')

		for i = 1, specialCount, 1 do
			local doodNode = root:getSub('specialTree'..i)

			local dood = this:createSpecialDoodad()

			dood:setTypeId(doodNode:getVal('id'))

			dood:setPos(doodNode:getVal('x'), doodNode:getVal('y'), doodNode:getVal('z'))
		end
	end

	return this
end

expose('wc3doo', t)