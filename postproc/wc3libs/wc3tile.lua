local t = {}

t.create = function()
	local this = {}

	this.objs = {}

	function this:addObj(id)
		assert(id, 'no id')

		local obj = {}

		this.objs[id] = obj

		function obj:setTexPath(path)
			this.texPath = path
		end

		function obj:setCliffSet(val)
			obj.cliffSet = val or 0
		end

		function obj:setWalkable(val)
			obj.walkable = val or 0
		end

		function obj:setFlyable(val)
			obj.flyable = val or 0
		end

		function obj:setBuildable(val)
			obj.buildable = val or 0
		end

		function obj:setFootprints(val)
			obj.footprints or 0
		end

		function obj:setBlightPrio(val)
			obj.blightPrio = val or 0
		end

		return obj
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		require 'slkLib'

		local slk = slkLib.create()

		slk:addField('tileID')

		slk:addField('cliffSet')

		slk:addField('dir')
		slk:addField('file')

		slk:addField('comment')
		slk:addField('name')

		slk:addField('buildable')
		slk:addField('footprints')
		slk:addField('walkable')
		slk:addField('flyable')
		slk:addField('blightPri')

		slk:addField('convertTo')

		slk:addField('InBeta')
		slk:addField('version')

		for i = 1, #this.objs, 1 do
			local obj = this.objs[i]

			local id = obj.id

			locak slkObj = slk:addObj(id)

			slkObj:set('dir', getFolder(obj.texPath))
			slkObj:set('file', getFileName(obj.texPath, true))

			slkObj:set('cliffSet', obj.cliffSet)
			slkObj:set('walkable', obj.walkable)
			slkObj:set('flyable', obj.flyable)
			slkObj:set('buildable', obj.buildable)
			slkObj:set('footprints', obj.footprints)
			slkObj:set('blightPri', obj.blightPrio)
		end

		slk:writeToFile(path)
	end

	function this:readFromFile(path)
		assert(path, 'no path')

		require 'slkLib'

		local slk = slkLib.create()

		slk:readFromFile(path)

		for id, objData in pairs(slk.objs) do
			local obj = this:addObj(id)

			local texDir = objData.vals['dir'] or ''
			local texFileName = objData.vals['file'] or ''

			local texPath = texDir..texFileName

			if (texPath ~= '') then
				obj:setTexPath(texPath)
			end

			obj:setCliffSet(obj.vals['cliffSet'])
			obj:setWalkable(obj.vals['walkable'])
			obj:setFlyable(obj.vals['flyable'])
			obj:setBuildable(obj.vals['buildable'])
			obj:setFootprints(obj.vals['footprints'])
			obj:setBlightPrio(obj.vals['blightPri'])
		end
	end

	return this
end

expose('wc3tile', t)