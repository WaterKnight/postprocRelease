require 'waterlua'

local t = {}

local function create()
	local this = {}

	function this:setDimensions(width, height)
		assert(width, 'no width')
		assert(height, 'no height')

		this.width = width
		this.height = height
	end

	function this:setOffsets(centerX, centerY)
		assert(centerX, 'no centerX')
		assert(centerY, 'no centerY')

		this.centerX = centerX
		this.centerY = centerY
	end

	this.dots = {}

	function this:setDot(index, flag)
		assert(index, 'no index')
		assert((flag ~= nil), 'no flag')

		this.dots[index] = flag
	end

	function this:dotIndexByXY(x, y)
		assert(this.width and this.height, 'no dimensions set')

		return (y * this.width + x)
	end

	function this:merge(other)
		assert(this.width and this.height, 'receiver has no dimensions set')
		assert(this.centerX and this.centerY, 'receiver has no offsets set')
		assert(other.width and other.height, 'transducer has no dimensions set')
		assert(other.centerX and other.centerY, 'transducer has no offsets set')

		local minX = ((other.centerX - other.width / 2) - (this.centerX - this.width / 2))
		local maxX = minX + other.width - 1
		local minY = ((other.centerY - other.height / 2) - (this.centerY - this.height / 2))
		local maxY = minY + other.height - 1

		local c = 0;

		for y = minY, maxY, 1 do
			for x = minX, maxX, 1 do
				if (other.dots[c] == true) then
					this:setDot(y * this.width + x, true)
				end

				c = c + 1
			end
		end
	end

	local function maskFunc(root, mode, stream)
		local size

		if (mode == 'reading') then
			size = #stream.bytes

			root:add('dotsCount', 'int', nil, true)
			root:setVal('dotsCount', size - 1)

			root.cells = {}

			while (stream.pos <= size) do
				root.cells[stream.pos - 1] = stream:read('byte')
			end
		else
			size = root:getVal('dotsCount') + 1

			while (stream.pos <= size) do
				stream:write('byte', root.cells[stream.pos - 1])
			end
		end
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		require 'wc3binaryFile'

		local root = wc3binaryFile.create()

		local count = this.width * this.height - 1

		root:add('dotsCount', 'int')
		root:setVal('dotsCount', count)

		root.cells = {}

		for i = 0, count, 1 do
			if (this.dots[i - 1] == true) then
				root.cells[i] = 0xff
			else
				root.cells[i] = 0x00
			end
		end

		root:writeToFile(path, maskFunc)
	end

	function this:readFromFile(path, envPath)
		assert(path, 'no path')

		require 'wc3binaryFile'

		if (envPath ~= nil) then
			require 'wc3env'

			local terrain = wc3env.create()

			terrain:readFromFile(envPath, true)

			this:setDimensions((terrain.width - 1) * 4, (terrain.height - 1) * 4)
			this:setOffsets(terrain.centerX / 32, terrain.centerY / 32)
		end

		local root = wc3binaryFile.create()

		root:readFromFile(path, maskFunc)

		local count = root:getVal('dotsCount')

		for i = 0, count, 1 do
			if (root.cells[i] == 0xff) then
				this:setDot(i, true)
			else
				this:setDot(i, false)
			end
		end
	end

	return this
end

t.create = create

expose('wc3shd', t)