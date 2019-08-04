require 'waterlua'

local t = {}

local function create()
	local this = {}

	function this:setMapName(name)
		this.mapName = name or ''
	end

	function this:setSavesAmount(val)
		this.savesAmount = val or 0
	end

	function this:addPlayer()
		local p = {}

		local states = {}
		local stateVals = {}

		function p:getState(name)
			assert(tableContains(name), 'state '..tostring(name)..' not available')

			return stateVals[name]
		end

		function p:setState(name, val)
			assert(tableContains(name), 'state '..tostring(name)..' not available')

			stateVals[name] = val
		end

		return p
	end

	local states = {
		savesAmount = 'int',
		editorVersion = 'int',
		mapName = 'string',
		mapAuthor = 'string',
		mapDescription = 'string',
		playersRecommendedAmount = 'string',

		boundaryMarginLeft = 'int',
		boundaryMarginRight = 'int',
		boundaryMarginBottom = 'int',
		boundaryMarginTop = 'int',
		mapWidthWithoutBoundaries = 'int',
		mapHeightWithoutBoundaries = 'int',

		tileset = 'char',
		campaignBackgroundIndex = 'int',
		loadingScreenText = 'string',
		loadingScreenTitle = 'string',
		loadingScreenSubtitle = 'string',
		loadingScreenIndex = 'int',
		prologueScreenText = 'string',
		prologueScreenTitle = 'string',
		prologueScreenSubtitle = 'string'
	}
	local stateVals = {}

	for i = 1, 8, 1 do
		states['cameraBounds'..i] = 'float'
	end

	function this:getState(name)
		assert(tableContains(name), 'state '..tostring(name)..' not available')

		return stateVals[name]
	end

	function this:setState(name, val)
		assert(tableContains(name), 'state '..tostring(name)..' not available')

		stateVals[name] = val
	end

	--format 18
	local function maskFunc_18(root)
		wc3binaryFile.checkFormatVer('infoFileMaskFunc', 18, root:getVal('formatVersion'))

		root:add('savesAmount', 'int')
		root:add('editorVersion', 'int')
		root:add('mapName', 'string')
		root:add('mapAuthor', 'string')
		root:add('mapDescription', 'string')
		root:add('playersRecommendedAmount', 'string')
		for i = 1, 8, 1 do
			root:add('cameraBounds'..i, 'float')
		end
		root:add('boundaryMarginLeft', 'int')
		root:add('boundaryMarginRight', 'int')
		root:add('boundaryMarginBottom', 'int')
		root:add('boundaryMarginTop', 'int')
		root:add('mapWidthWithoutBoundaries', 'int')
		root:add('mapHeightWithoutBoundaries', 'int')
		root:add('flags', 'int', {
						'hideMinimap',
						'modifyAllyPriorities',
						'meleeMap',
						'initialMapSizeLargeNeverModified',
						'maskedAreasPartiallyVisible',
						'fixedPlayerForceSetting',
						'useCustomForces',
						'useCustomTechtree',
						'useCustomAbilities',
						'useCustomUpgrades',
						'mapPropertiesWindowOpenedBefore',
						'showWaterWavesOnCliffShores',
						'showWaterWavesOnRollingShores'
					})

		root:add('tileset', 'char')
		root:add('campaignBackgroundIndex', 'int')
		root:add('loadingScreenText', 'string')
		root:add('loadingScreenTitle', 'string')
		root:add('loadingScreenSubtitle', 'string')
		root:add('loadingScreenIndex', 'int')
		root:add('prologueScreenText', 'string')
		root:add('prologueScreenTitle', 'string')
		root:add('prologueScreenSubtitle', 'string')

		root:add('maxPlayers', 'int')

		local function createPlayer(index)
			local p = root:addNode('player'..index)

			p:add('num', 'int')
			p:add('type', 'int')
			p:add('race', 'int')
			p:add('startLocation', 'int')
			p:add('name', 'string')
			p:add('startLocationX', 'float')
			p:add('startLocationY', 'float')

			local t = {}

			for i = 1, root:getVal('maxPlayers'), 1 do
				t[i] = 'player'..i
			end

			p:add('allyLowPriorityFlags', 'int', t)
			p:add('allyHighPriorityFlags', 'int', t)
		end

		for i = 1, root:getVal('maxPlayers'), 1 do
			createPlayer(i)
		end

		root:add('maxForces', 'int')

		local function createForce(index)
			local f = root:addNode('force'..index)

			f:add('flags', 'int', {'allied', 'alliedVictory', 'sharedVision', 'shareUnitControl', 'shareUnitControlAdvanced'})

			local t = {}

			for i = 1, root:getVal('maxPlayers'), 1 do
				t[i] = 'player'..i
			end

			f:add('players', 'int', t)

			f:add('name', 'string')
		end

		for i = 1, root:getVal('maxForces'), 1 do
			createForce(i)
		end

		root:add('upgradeModsAmount', 'int')

		local function createUpgradeMod(index)
			local u = root:addNode('upgrade'..index)

			local t = {}

			for i = 1, root:getVal('maxPlayers'), 1 do
				t[i] = 'player'..i
			end

			u:add('players', 'int', t)
			u:add('id', 'id')
			u:add('level', 'int')
			u:add('availability', 'int')
		end

		for i = 1, root:getVal('upgradeModsAmount'), 1 do
			createUpgradeMod(i)
		end

		root:add('techModsAmount', 'int')

		local function createTechMod(index)
			local tech = root:addNode('tech'..index)

			local t = {}

			for i = 1, root:getVal('maxPlayers'), 1 do
				t[i] = 'player'..i
			end

			tech:add('players', 'int', t)

			tech:add('id', 'id')
		end

		for i = 1, root:getVal('techModsAmount'), 1 do
			createTechMod(i)
		end

		root:add('unitTablesAmount', 'int')

		local function createUnitTable(index)
			local t = root:addNode('unitTable'..index)

			t:add('index', 'int')

			t:add('name', 'string')

			t:add('positionsAmount', 'int')

			for i = 1, t:getVal('positionsAmount'), 1 do
				t:add('positionType'..i, 'int')
			end

			t:add('setsAmount', 'int')

			local function createSet(index)
				local s = t:addNode('set'..index)

				s:add('chance', 'int')

				for i = 1, t:getVal('positionsAmount'), 1 do
					s:add('id'..i, 'id')
				end
			end

			for i = 1, t:getVal('setsAmount'), 1 do
				createSet(i)
			end
		end

		for i = 1, root:getVal('unitTablesAmount'), 1 do
			createUnitTable(i)
		end
	end

	--format 25
	local function maskFunc_25(root)
		wc3binaryFile.checkFormatVer('infoFileMaskFunc', 25, root:getVal('formatVersion'))

		root:add('savesAmount', 'int')
		root:add('editorVersion', 'int')
		root:add('mapName', 'string')
		root:add('mapAuthor', 'string')
		root:add('mapDescription', 'string')
		root:add('playersRecommendedAmount', 'string')
		for i = 1, 8, 1 do
			root:add('cameraBounds'..i, 'float')
		end
		root:add('boundaryMarginLeft', 'int')
		root:add('boundaryMarginRight', 'int')
		root:add('boundaryMarginBottom', 'int')
		root:add('boundaryMarginTop', 'int')
		root:add('mapWidthWithoutBoundaries', 'int')
		root:add('mapHeightWithoutBoundaries', 'int')
		root:add('flags', 'int', {
						'hideMinimap',
						'modifyAllyPriorities',
						'meleeMap',
						'initialMapSizeLargeNeverModified',
						'maskedAreasPartiallyVisible',
						'fixedPlayerForceSetting',
						'useCustomForces',
						'useCustomTechtree',
						'useCustomAbilities',
						'useCustomUpgrades',
						'mapPropertiesWindowOpenedBefore',
						'showWaterWavesOnCliffShores',
						'showWaterWavesOnRollingShores'
					})

		root:add('tileset', 'char')
		root:add('loadingScreenIndex', 'int')
		root:add('loadingScreenModelPath', 'string')
		root:add('loadingScreenText', 'string')
		root:add('loadingScreenTitle', 'string')
		root:add('loadingScreenSubtitle', 'string')
		root:add('gameData', 'int')
		root:add('prologueScreenPath', 'string')
		root:add('prologueScreenText', 'string')
		root:add('prologueScreenTitle', 'string')
		root:add('prologueScreenSubtitle', 'string')
		root:add('terrainFogType', 'int')
		root:add('terrainFogStartZHeight', 'float')
		root:add('terrainFogEndZHeight', 'float')
		root:add('terrainFogDensity', 'float')
		root:add('terrainFogBlue', 'byte')
		root:add('terrainFogGreen', 'byte')
		root:add('terrainFogRed', 'byte')
		root:add('terrainFogAlpha', 'byte')
		root:add('globalWeatherId', 'id')
		root:add('soundEnvironment', 'string')
		root:add('tilesetLightEnvironment', 'char')
		root:add('waterBlue', 'byte')
		root:add('waterGreen', 'byte')
		root:add('waterRed', 'byte')
		root:add('waterAlpha', 'byte')

		root:add('maxPlayers', 'int')

		local function createPlayer(index)
			local p = root:addNode('player'..index)

			p:add('num', 'int')
			p:add('type', 'int')
			p:add('race', 'int')
			p:add('startLocation', 'int')
			p:add('name', 'string')
			p:add('startLocationX', 'float')
			p:add('startLocationY', 'float')

			local t = {}

			for i = 1, root:getVal('maxPlayers'), 1 do
				t[i] = 'player'..i
			end

			p:add('allyLowPriorityFlags', 'int', t)
			p:add('allyHighPriorityFlags', 'int', t)

		end

		for i = 1, root:getVal('maxPlayers'), 1 do
			createPlayer(i)
		end

		root:add('maxForces', 'int')

		local function createForce(index)
			local f = root:addNode('force'..index)

			f:add('flags', 'int', {'allied', 'alliedVictory', 'sharedVision', 'shareUnitControl', 'shareUnitControlAdvanced'})

			local t = {}

			for i = 1, root:getVal('maxPlayers'), 1 do
				t[i] = 'player'..i
			end

			f:add('players', 'int', t)

			f:add('name', 'string')
		end

		for i = 1, root:getVal('maxForces'), 1 do
			createForce(i)
		end

		root:add('upgradeModsAmount', 'int')

		local function createUpgradeMod(index)
			local u = root:addNode('upgrade'..index)

			local t = {}

			for i = 1, root:getVal('maxPlayers'), 1 do
				t[i] = 'player'..i
			end

			u:add('players', 'int', t)
			u:add('id', 'id')
			u:add('level', 'int')
			u:add('availability', 'int')
		end

		for i = 1, root:getVal('upgradeModsAmount'), 1 do
			createUpgradeMod(i)
		end

		root:add('techModsAmount', 'int')

		local function createTechMod(index)
			local tech = root:addNode('tech'..index)

			local t = {}

			for i = 1, root:getVal('maxPlayers'), 1 do
				t[i] = 'player'..i
			end

			tech:add('players', 'int', t)

			tech:add('id', 'id')
		end

		for i = 1, root:getVal('techModsAmount'), 1 do
			createTechMod(i)
		end

		root:add('unitTablesAmount', 'int')

		local function createUnitTable(index)
			local t = root:addNode('unitTable'..index)

			t:add('index', 'int')

			t:add('name', 'string')

			t:add('positionsAmount', 'int')

			for i = 1, t:getVal('positionsAmount'), 1 do
				t:add('positionType'..i, 'int')
			end

			t:add('setsAmount', 'int')

			local function createSet(index)
				local s = t:addNode('set'..index)

				s:add('chance', 'int')

				for i = 1, t:getVal('positionsAmount'), 1 do
					s:add('id'..i, 'id')
				end
			end

			for i = 1, t:getVal('setsAmount'), 1 do
				createSet(i)
			end
		end

		for i = 1, root:getVal('unitTablesAmount'), 1 do
			createUnitTable(i)
		end

		root:add('itemTablesAmount', 'int')

		local function createItemTable(index)
			local t = root:addNode('itemTable'..index)

			t:add('index', 'int')
			t:add('name', 'string')
			t:add('setsAmount', 'int')

			local function createSet(index)
				local s = t:addNode('set'..index)

				s:add('itemsAmount', 'int')

				local function createItem(index)
					local i = s:addNode('item'..index)

					i:add('chance', 'int')
					i:add('id', 'id')
				end

				for i = 1, s:getVal('itemsAmount'), 1 do
					createItem(i)
				end
			end

			for i = 1, t:getVal('setsAmount'), 1 do
				createSet(i)
			end
		end

		for i = 1, root:getVal('itemTablesAmount'), 1 do
			createItemTable(i)
		end
	end

	local function maskFunc(root)
		root:add('formatVersion', 'int')

		local t = {}

		t[18] = maskFunc_18
		t[25] = maskFunc_25

		local version = root:getVal('formatVersion')

		t[version](root)
	end

	local origRoot

	function this:writeToFile(path)
		assert(path, 'no path')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		if (origRoot ~= nil) then
			root = origRoot
		end

		--root:add('formatVersion', 'int')
		--root:setVal('formatVersion', 18)

		root:setVal('mapName', this.mapName)
		root:setVal('savesAmount', this.savesAmount)

		for state, stateType in pairs(states) do
			--root:add(state, stateType)
			--root:setVal(state, this:getState(state))
		end

		root:writeToFile(path, maskFunc)
	end

	function this:readFromFile(path)
		assert(path, 'no path')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		origRoot = root

		root:readFromFile(path, maskFunc)

		this:setMapName(root:getVal('mapName'))
		this:setSavesAmount(root:getVal('savesAmount'))

		for state in pairs(states) do
			--this:setState(state, root:getVal(state))
		end
	end

	return this
end

t.create = create

expose('wc3info', t)