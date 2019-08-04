local t = {}

t.create = function()
	local this = {}

	this.objs = {}

	function this:addObj(id)
		assert(id, 'no id')

		local obj = {}

		this.objs[id] = obj

		function obj:setRampModelDir(val)
			obj.rampModelDir = val
		end

		function obj:setCliffModelDir(val)
			obj.cliffModelDir = val
		end

		function obj:setTexPath(path)
			this.texPath = path
		end

		function obj:setName(val)
			obj.name = val
		end

		function obj:setGroundTile(val)
			obj.groundTile = val
		end

		function obj:setUpperTile(val)
			obj.upperTile = val
		end

		function obj:setCliffClass(val)
			obj.cliffClass = val
		end

		function obj:setOldId(val)
			obj.oldId = val or 0
		end

		return obj
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		require 'slkLib'

		local slk = createSlk()

		slk:addField('cliffID')

		slk:addField('rampModelDir')
		slk:addField('cliffModelDir')

		slk:addField('texDir')
		slk:addField('texFile')

		slk:addField('name')
		slk:addField('groundTile')
		slk:addField('upperTile')
		slk:addField('cliffClass')
		slk:addField('oldID')
		slk:addField('version')
		slk:addField('InBeta')

		for i = 1, #this.objs, 1 do
			local obj = this.objs[i]

			local id = obj.id

			local slkObj = slk:addObj(id)

			slkObj:set('cliffModelDir', obj.cliffModelDir)
			slkObj:set('rampModelDir', obj.rampModelDir)

			slkObj:set('dir', getFolder(obj.texPath))
			slkObj:set('file', getFileName(obj.texPath, true))

			slkObj:set('name', obj.name)
			slkObj:set('groundTile', obj.groundTile)
			slkObj:set('upperTile', obj.upperTile)
			slkObj:set('cliffClass', obj.cliffClass)
			slkObj:set('oldID', obj.oldId)
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

			obj:setCliffModelDir(obj.vals['cliffModelDir'])
			obj:setRampModelDir(obj.vals['rampModelDir'])

			local texDir = objData.vals['texDir'] or ''
			local texFileName = objData.vals['texFile'] or ''

			local texPath = texDir..texFileName

			if (texPath ~= '') then
				obj:setTexPath(texPath)
			end

			obj:setName(obj.vals['name'])
			obj:setGroundTile(obj.vals['groundTile'])
			obj:setUpperTile(obj.vals['upperTile'])
			obj:setCliffClass(obj.vals['cliffClass'])
			obj:setOldId(obj.vals['oldID'])
		end
	end

	return this
end

expose('wc3cliff', t)