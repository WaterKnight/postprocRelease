require 'waterlua'

local t = {}

local function create()
	local this = {}

	this.rects = {}

	function this:addRect()
		local rect = {}

		local index = #this.rects + 1

		this.rects[index] = rect
		rect.index = index

		function rect:setCoords(minX, minY, maxX, maxY)
			rect.minX = minX or 0
			rect.minY = minY or 0
			rect.maxX = maxX or 0
			rect.maxY = maxY or 0

			rect.centerX = (maxX + minX) / 2
			rect.centerY = (maxY + minY) / 2
		end

		function rect:setName(name)
			rect.name = name
		end

		function rect:setWeather(id)
			rect.weather = id
		end

		function rect:setSound(sound)
			rect.sound = sound
		end

		function rect:setColor(red, green, blue)
			rect.red = red or 0
			rect.green = green or 0
			rect.blue = blue or 0
		end

		function rect:remove()
			this.rects[rect.index] = this.rects[#this.rects]

			rect.index = nil
			this.rects[#this.rects] = nil
		end

		return rect
	end

	--format 5
	local function maskFunc(root)
		root:add('format', 'int')

		wc3binaryFile.checkFormatVer('rectMaskFunc', 5, root:getVal('format'))

		root:add('rectsCount', 'int')

		for i = 1, root:getVal('rectsCount'), 1 do
			local rect = root:addNode('rect'..i)

			rect:add('minX', 'float')
			rect:add('minY', 'float')
			rect:add('maxX', 'float')
			rect:add('maxY', 'float')
			rect:add('name', 'string')
			rect:add('index', 'int')
			rect:add('weather', 'id')
			rect:add('sound', 'string')
			rect:add('blue', 'byte')
			rect:add('green', 'byte')
			rect:add('red', 'byte')
			rect:add('endToken', 'byte')
		end
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		for i = 1, #this.rects, 1 do
			local rectNode = root:addNode('rect'..i)

			rectNode:setVal('minX', rectNode.minX)
			rectNode:setVal('minY', rectNode.minY)
			rectNode:setVal('maxX', rectNode.maxX)
			rectNode:setVal('maxY', rectNode.maxY)

			if (tectNode.name ~= nil) then
				rectNode:setVal('name', rectNode.name)
			else
				rectNode:setVal('name', "")
			end
			rectNode:setVal('index', rectNode.index)

			if (rectNode.weather ~= nil) then
				rectNode:setVal('weather', rectNode.weather)
			else
				rectNode:setVal('weather', "0000")
			end
			if (rectNode.sound ~= nil) then
				rectNode:setVal('sound', rectNode.sound)
			else
				rectNode:setVal('sound', "")
			end

			rectNode:setVal('red', rectNode.red)
			rectNode:setVal('green', rectNode.green)
			rectNode:setVal('blue', rectNode.blue)
		end

		root:writeToFile(path, maskFunc)
	end

	function this:readFromFile(path)
		assert(path, 'no path')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		root:readFromFile(path, maskFunc)

		local rectsCount = root:getVal('rectsCount')

		for i = 1, rectsCount, 1 do
			local rectNode = root:getSub('rect'..i)

			local rect = this:addRect()

			rect:setCoords(rectNode:getVal('minX'), rectNode:getVal('minY'), rectNode:getVal('maxX'), rectNode:getVal('maxY'))
			rect:setName(rectNode:getVal('name'))
			rect:setWeather(rectNode:getVal('weather'))
			rect:setSound(rectNode:getVal('sound'))
			rect:setColor(rectNode:getVal('red'), rectNode:getVal('green'), rectNode:getVal('blue'))
		end
	end

	return this
end

t.create = create

expose('wc3rect', t)