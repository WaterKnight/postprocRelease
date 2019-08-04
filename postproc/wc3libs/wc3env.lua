local t = {}

require 'waterlua'

local t = {}

local function create()
	local this = {}

	this.tileset = nil

	function this:setTileset(tileset)
		this.tileset = tileset
	end

	this.groundTypes = {}

	function this:addGroundType(val)
		assert(val, 'no val')

		this.groundTypes[#this.groundTypes + 1] = val
	end

	this.cliffTypes = {}

	function this:addCliffType(val)
		assert(val, 'no val')

		this.cliffTypes[#this.cliffTypes + 1] = val
	end

	function this:getMinX()
		return (this.centerX - (this.width - 1) * 128 / 2)
	end

	function this:getMinY()
		return (this.centerY - (this.height - 1) * 128 / 2)
	end

	function this:getMaxX()
		return (this.centerX + (this.width - 1) * 128 / 2)
	end

	function this:getMaxY()
		return (this.centerY + (this.height - 1) * 128 / 2)
	end

	function this:setSize(x, y)
		this.width = x or 0
		this.height = y or 0
	end

	function this:setCenter(x, y)
		this.centerX = x or 0
		this.centerY = y or 0
	end

	function this:indexByXY(x, y)
		assert(this.width and this.height, 'no dimensions set')

		return (y * this.width + x)
	end

	this.heights = {}

	function this:setHeight(x, y, val)
		this.heights[indexByXY(x, y)] = val or 0
	end

	this.waterHeights = {}

	function this:setWaterHeight(x, y, val)
		this.waterHeights[indexByXY(x, y)] = val or 0
	end

	this.waterBoundary = {}

	function this:setWaterBoundary(x, y, val)
		this.waterBoundary[indexByXY(x, y)] = val or 0
	end

	this.tex = {}

	function this:setTex(x, y, val)
		this.tex[indexByXY(x, y)] = val or 0
	end

	this.ramp = {}

	function this:setRamp(x, y, val)
		this.ramp[indexByXY(x, y)] = val or 0
	end

	this.blight = {}

	function this:setBlight(x, y, val)
		this.blight[indexByXY(x, y)] = val or 0
	end

	this.water = {}

	function this:setWater(x, y, val)
		this.water[indexByXY(x, y)] = val or 0
	end

	this.boundary = {}

	function this:setBoundary(x, y, val)
		this.boundary[indexByXY(x, y)] = val or 0
	end

	this.texDetails = {}

	function this:setTexDetails(x, y, val)
		this.texDetails[indexByXY(x, y)] = val or 0
	end

	this.cliffLayer = {}

	function this:setCliffLayer(x, y, val)
		this.cliffLayer[indexByXY(x, y)] = val or 0
	end

	this.cliffTex = {}

	function this:setCliffTex(x, y, val)
		this.cliffTex[indexByXY(x, y)] = val or 0
	end

	function this:addImp(path, stdFlag)
		assert(path, 'no path')

		assert((this.impsByPath[path] == nil), 'path '..tostring(path)..' already used')

		if (stdFlag == nil) then
			stdFlag = this.STD_FLAG_CUSTOM
		end

		local impData = {}

		impData.path = path
		impData.stdFlag = stdFlag

		this.impsByPath[path] = impData
	end

	function this:merge(otherImpFile)
		assert(otherImpFile, 'no other impFile')

		for _, impData in pairs(otherImpFile.impsByPath) do
			if (this.impsByPath[impData.path] == nil) then
				this:addImp(impData.path, impData.stdFlag)
			end
		end
	end

	--format 11
	local groundZero = 0x2000
	local waterZero = 89.6
	local cliffHeight = 0x0200

	local function rawToFinalGroundHeight(rawVal, cliffLevel)
		return ((rawVal - groundZero + (cliffLevel - 2) * cliffHeight) / 4)
	end

	local function finalGroundToRawHeight(finalVal, cliffLevel)
		return (finalVal * 4 - (cliffLevel - 2) * cliffHeight + groundZero)
	end

	local function rawToFinalWaterHeight(rawVal)
		return ((rawVal - groundZero) / 4) - waterZero
	end

	local function finalWaterToRawHeight(finalVal)
		return ((finalVal + waterZero) * 4 + groundZero)
	end

	--format 11
	local function maskFunc(root, mode)
		root:add('startToken', 'id')

		root:add('formatVersion', 'int')

		wc3binaryFile.checkFormatVer('envMaskFunc', 11, root:getVal('formatVersion'))

		root:add('mainTileset', 'char')
		root:add('customTilesetsFlag', 'int')

		root:add('groundTilesetsUsed', 'int')
		for i = 1, root:getVal('groundTilesetsUsed'), 1 do
			root:add('groundTileset'..i..'id', 'id')
		end

		root:add('cliffTilesetsUsed', 'int')
		for i = 1, root:getVal('cliffTilesetsUsed'), 1 do
			root:add('cliffTileset'..i..'id', 'id')
		end

		root:add('width', 'int')
		root:add('height', 'int')
		root:add('centerX', 'float')
		root:add('centerY', 'float')

		flagsTable = {'tex', 'tex', 'tex', 'tex', 'ramp', 'blight', 'water', 'boundary2'}
		cliffFlagsTable = {'layer', 'layer', 'layer', 'layer', 'cliffTex', 'cliffTex', 'cliffTex', 'cliffTex'}
		waterLevelFlagsTable = {[15] = 'boundary'}

		local tilesCount = root:getVal('height') * root:getVal('width')

		local loadDisplay

		if (mode == 'reading') then
			loadDisplay = createLoadPercDisplay(tilesCount, 'reading tiles...')
		else
			loadDisplay = createLoadPercDisplay(tilesCount, 'writing tiles...')
		end

		local format = string.format

		local function createTile(index)
			local tile = root:addNode(format('%i', index))

			tile:add('groundHeight', 'short')
			--tile:add('waterLevel', 'short', waterLevelFlagsTable)
			tile:add('waterLevel', 'short')
			--tile:add('flags', 'byte', flagsTable)
			tile:add('flags', 'byte')
			tile:add('textureDetails', 'byte')
			--tile:add('cliff', 'byte', cliffFlagsTable)
			tile:add('cliff', 'byte')

			loadDisplay:inc()
		end

		for i = 1, tilesCount, 1 do
			createTile(i)
		end
	end

	--format 11
	local function maskFuncEx(root, mode, stream)
		root:add('startToken', 'id')

		root:add('formatVersion', 'int')

		wc3binaryFile.checkFormatVer('envMaskFunc', 11, root:getVal('formatVersion'))

		root:add('mainTileset', 'char')
		root:add('customTilesetsFlag', 'int')

		root:add('groundTilesetsUsed', 'int')
		for i = 1, root:getVal('groundTilesetsUsed'), 1 do
			root:add('groundTileset'..i..'id', 'id')
		end

		root:add('cliffTilesetsUsed', 'int')
		for i = 1, root:getVal('cliffTilesetsUsed'), 1 do
			root:add('cliffTileset'..i..'id', 'id')
		end

		root:add('width', 'int')
		root:add('height', 'int')
		if (mode == 'writing') then
			root:setVal('minX', root:getVal('centerX') - (root:getVal('width') - 1) / 2 * 128)
			root:setVal('minY', root:getVal('centerY') - (root:getVal('height') - 1) / 2 * 128)
		end
		root:add('minX', 'float')
		root:add('minY', 'float')
		if (mode == 'reading') then
			root:setVal('centerX', root:getVal('centerX') + (root:getVal('width') - 1) / 2 * 128)
			root:setVal('centerY', root:getVal('centerY') + (root:getVal('height') - 1) / 2 * 128)
		end

		flagsTable = {'tex', 'tex', 'tex', 'tex', 'ramp', 'blight', 'water', 'boundary2'}
		cliffFlagsTable = {'layer', 'layer', 'layer', 'layer', 'cliffTex', 'cliffTex', 'cliffTex', 'cliffTex'}
		waterLevelFlagsTable = {[15] = 'boundary'}

		local tilesCount = root:getVal('height') * root:getVal('width')

		local loadDisplay

		if (mode == 'reading') then
			loadDisplay = createLoadPercDisplay(tilesCount, 'reading tiles...')
		else
			loadDisplay = createLoadPercDisplay(tilesCount, 'writing tiles...')
		end

		local c = 1

		root.tiles = {}

		local function createTile(index)
			local tile = {}

			root.tiles[c] = tile

			tile.groundHeight = stream:read('short')
			tile.waterLevel = stream:read('short')
			tile.flags = stream:read('byte')
			tile.textureDetails = stream:read('byte')
			tile.cliff = stream:read('byte')

			c = c + 1

			loadDisplay:inc()
		end

		for i = 1, tilesCount, 1 do
			createTile(i)
		end
	end

	--format 11
	local function maskFuncOnlyHeader(root, mode, stream)
		root:add('startToken', 'id')

		root:add('formatVersion', 'int')

		wc3binaryFile.checkFormatVer('envMaskFunc', 11, root:getVal('formatVersion'))

		root:add('mainTileset', 'char')
		root:add('customTilesetsFlag', 'int')

		root:add('groundTilesetsUsed', 'int')
		for i = 1, root:getVal('groundTilesetsUsed'), 1 do
			root:add('groundTileset'..i..'id', 'id')
		end

		root:add('cliffTilesetsUsed', 'int')
		for i = 1, root:getVal('cliffTilesetsUsed'), 1 do
			root:add('cliffTileset'..i..'id', 'id')
		end

		root:add('width', 'int')
		root:add('height', 'int')
		if (mode == 'writing') then
			root:setVal('minX', root:getVal('centerX') - (root:getVal('width') - 1) / 2 * 128)
			root:setVal('minY', root:getVal('centerY') - (root:getVal('height') - 1) / 2 * 128)
		end
		root:add('centerX', 'float')
		root:add('centerY', 'float')

		if (mode == 'reading') then
			root:setVal('centerX', root:getVal('centerX') + (root:getVal('width') - 1) / 2 * 128)
			root:setVal('centerY', root:getVal('centerY') + (root:getVal('height') - 1) / 2 * 128)
		end
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		root:setVal('mainTileset', this.tileset)
		root:setVal('customTilesetsFlag', this.hasCustomTiles)

		root:setVal('groundTilesetsUsed', #this.groundTypes)
		for i = 1, #this.groundTypes, 1 do
			root:setVal(string.format('groundTileset%iid', i))
		end

		root:setVal('cliffTilesetsUsed', #this.cliffTypes)
		for i = 1, #this.cliffTypes, 1 do
			root:setVal(string.format('cliffTileset%iid', i))
		end

		root:setVal('width', this.width)
		root:setVal('height', this.height)

		root:setVal('centerX', this.centerX)
		root:setVal('centerY', this.centerY)

		local tilesCount = width * height

		for i = 1, tilesCount, 1 do
			local tileNode = root:addNode('tile'..format('%i', i))

			tileNode:setVal('groundHeight', this.height[i])
			tileNode:setVal('waterLevel', this.waterHeight[i])
			tileNode:setVal('boundary', this.waterBoundary[i])

			tileNode:setVal('tex', this.tex[i])
			tileNode:setVal('ramp', this.ramp[i])
			tileNode:setVal('blight', this.blight[i])
			tileNode:setVal('water', this.water[i])
			tileNode:setVal('boundary2', this.boundary[i])

			tileNode:setVal('texDetails', this.texDetails[i])
			tileNode:setVal('layer', this.cliffLayer[i])
			tileNode:setVal('cliffTex', this.cliffTex[i])
		end

		root:writeToFile(path, maskFunc)
	end

	function this:readFromFile(path, onlyHeader)
		assert(path, 'no path')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		if onlyHeader then
			root:readFromFile(path, maskFuncOnlyHeader)
		else
			root:readFromFile(path, maskFunc)
		end

		this:setTileset(root:getVal('mainTileset'))
		this.hasCustomTiles = (root:getVal('customTilesetsFlag'))

		for i = 1, root:getVal('groundTilesetsUsed'), 1 do
			this:addGroundType(root:getVal('groundTileset'..i..'id'))
		end

		for i = 1, root:getVal('cliffTilesetsUsed'), 1 do
			this:addCliffType(root:getVal('cliffTileset'..i..'id'))
		end

		local width = root:getVal('width')
		local height = root:getVal('height')

		this:setSize(width, height)
		this:setCenter(root:getVal('centerX'), root:getVal('centerY'))

		if onlyHeader then
			return
		end

		local tilesCount = width * height

		for i = 1, tilesCount, 1 do
			local tileNode = root:getSub('tile'..format('%i', i))

			this:setHeightByIndex(i, tileNode:getVal('groundHeight'))
			this:setWaterHeightByIndex(i, tileNode:getVal('waterLevel'))
			this:setWaterBoundaryByIndex(i, tileNode:getVal('boundary'))

			this:setTexByIndex(i, tileNode:getVal('tex'))
			this:setRampByIndex(i, tileNode:getVal('ramp'))
			this:setBlightByIndex(i, tileNode:getVal('blight'))
			this:setWaterByIndex(i, tileNode:getVal('water'))
			this:setBoundaryByIndex(i, tileNode:getVal('boundary2'))

			this:setTexDetailsByIndex(i, tileNode:getVal('textureDetails'))
			this:setCliffLayerByIndex(i, tileNode:getVal('layer'))
			this:setCliffTexByIndex(i, tileNode:getVal('cliffTex'))
		end
	end

	return this
end

t.create = create

expose('wc3env', t)