local t = {}

local pathingTypes = {
	FLAG_UNKNOWN = 0x1,
	FLAG_WALK = 0x2,
	FLAG_FLY = 0x4,
	FLAG_BUILD = 0x8,
	FLAG_UNKNOWN2 = 0x10,
	FLAG_BLIGHT = 0x20,
	FLAG_WATER = 0x40,
	FLAG_UNKNOWN3 = 0x80
}

t.pathingTypes = pathingTypes

local function create()
	local this = {}

	this.cells = {}

	function this:getFlags(x, y)
		assert(x, 'no x')
		assert(y, 'no y')

		if (this.cells[x] == nil) then
			return 0
		end

		local res = this.cells[x][y] or 0

		return res
	end

	function this:isFlag(x, y, flag)
		return (bit.band(this:getFlags(x, y), flag) == flag)
	end

	function this:setFlags(x, y, flags)
		assert(x, 'no x')
		assert(y, 'no y')
		assert(flags, 'no flags')

		if (this.cells[x] == nil) then
			this.cells[x] = {}
		end

		this.cells[x][y] = flags
	end

	function this:addFlag(x, y, flag)
		assert(x, 'no x')
		assert(y, 'no y')
		assert(flag, 'no flag')

		this:setFlags(x, y, bit.bor(this:getFlags(x, y), flag))
	end

	function this:getFromCoords(x, y)
		assert(x, 'no x')
		assert(y, 'no y')
		assert(this.baseTerrain, 'no baseTerrain set')

		local mapMinX = this.baseTerrain:getMinX()
		local mapMinY = this.baseTerrain:getMinY()

		return math.floor((x - mapMinX) / 32), math.floor((y - mapMinY) / 32)
	end

	function this:setBaseTerrain(terrain)
		this.baseTerrain = terrain
	end

	--format 0
	local function maskFunc(root)
		root:add('startToken', 'id')
		root:add('format', 'int')

		wc3binaryFile.checkFormatVer('wpmMaskFunc', 0, root:getVal('format'))

		root:add('width', 'int')
		root:add('height', 'int')

		local flagsTable = {'unknown', 'walk', 'fly', 'build', 'unknown2', 'blight', 'water', 'unknown3'}

		local c = 1

		for y = 0, root:getVal('height') - 1, 1 do
			for x = 0, root:getVal('width') - 1, 1 do
				local cell = root:addNode('cell'..c)

				--cell:add('flags', 'byte', flagsTable)
				cell:add('flags', 'byte')

				c = c + 1
			end
		end
	end

	--format 0
	local function maskFuncEx(root, mode, stream)
		root:add('startToken', 'id')
		root:add('format', 'int')

		wc3binaryFile.checkFormatVer('wpmMaskFunc', 0, root:getVal('format'))

		root:add('width', 'int')
		root:add('height', 'int')

		local streamPos = stream.pos

		if (mode == 'reading') then
			local c = 1
			local til = root:getVal('height') * root:getVal('width')

			root.cellFlags = {}

			for c = 1, til, 1 do
				root.cellFlags[c] = stream:getAbs(streamPos + c - 1)
			end
		else
			local c = 1
			local til = root:getVal('height') * root:getVal('width')

			for c = 1, til, 1 do
				stream:setAbs(streamPos + c - 1, root.cellFlags[c])
			end

			stream.pos = streamPos + til
		end
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		root:add('startToken', 'id')
		root:setVal('startToken', 'MP3W')

		root:add('format', 'int')
		root:setVal('format', 0)

		root:add('width', 'int')
		root:setVal('width', this.width)
		root:add('height', 'int')
		root:setVal('height', this.height)

		local function boolToInt(b)
			if b then
				return 1
			end

			return 0
		end

		local c = 1

		root.cellFlags = {}

		for y = 0, this.height - 1, 1 do
			for x = 0, this.width - 1, 1 do
				root.cellFlags[c] = this:getFlags(x, y)

				c = c + 1
			end
		end

		root:writeToFile(path, maskFuncEx)
	end

	function this:readFromFile(path)
		assert(path, 'no path')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		root:readFromFile(path, maskFuncEx)

		local width = root:getVal('width')
		local height = root:getVal('height')

		this.width = width
		this.height = height

		local c = 1

		for y = 0, height - 1, 1 do
			for x = 0, width - 1, 1 do
				this:setFlags(x, y, root.cellFlags[c])

				c = c + 1
			end
		end
	end

	return this
end

t.create = create

expose('wc3wpm', t)