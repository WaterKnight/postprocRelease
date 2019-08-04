require 'waterlua'

local t = {}

local function create()
	local this = {}

	this.objs = {}

	function this:addObj(id)
		assert(id, 'no id')

		local obj = {}

		this.objs[id] = obj

		function obj:setTexPath(path)
			assert(path, 'no path')

			this.texPath = path
		end

		function obj:setAvgSegLen(val)
			assert(val, 'no val')

			this.avgSegLen = val
		end

		function obj:setWidth(val)
			assert(val, 'no val')

			this.width = val
		end

		function obj:setColor(red, green, blue, alpha)
			obj.red = red or 1
			obj.green = green or 1
			obj.blue = blue or 1
			obj.alpha = alpha or 1
		end

		function obj:setNoiseScale(val)
			assert(val, 'no val')

			this.noiseScale = val
		end

		function obj:setTexCoordScale(val)
			assert(val, 'no val')

			this.texCoordScale = val
		end

		function obj:setDuration(val)
			assert(val, 'no val')
			assert((val > 0), 'bolt duration must be greater than 0')

			this.duration = val
		end

		return obj
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		require 'slkLib'

		local slk = createSlk()

		slk:addField('Name')

		slk:addField('comment')

		slk:addField('Dir')
		slk:addField('file')

		slk:addField('AvgSegLen')
		slk:addField('Width')

		slk:addField('R')
		slk:addField('G')
		slk:addField('B')
		slk:addField('A')

		slk:addField('NoiseScale')
		slk:addField('TexCoordScale')
		slk:addField('Duration')

		slk:addField('version')

		for i = 1, #this.objs, 1 do
			local obj = this.objs[i]

			local id = obj.id

			local slkObj = slk:addObj(id)

			slkObj:set('Dir', getFolder(obj.texPath))
			slkObj:set('file', getFileName(obj.texPath))
			slkObj:set('AvgSegLen', obj.avgSegLen)
			slkObj:set('Width', obj.width)
			slkObj:set('R', obj.red)
			slkObj:set('G', obj.green)
			slkObj:set('B', obj.blue)
			slkObj:set('A', obj.alpha)
			slkObj:set('NoiseScale', obj.noiseScale)
			slkObj:set('TexCoordScale', obj.texCoordScale)
			slkObj:set('Duration', obj.duration)
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

			local texDir = objData.vals['Dir'] or ''
			local texFileName = objData.vals['file'] or ''

			local texPath = texDir..texFileName

			if (texPath ~= '') then
				obj:setTexPath(texPath)
			end

			obj:setAvgSegLength(objData.vals['AvgSegLen'])
			obj:setWidth(objData.vals['Width'])
			obj:setColor(objData.vals['R'], objData.vals['G'], objData.vals['B'], objData.vals['A'])
			obj:setNoiseScale(objData.vals['NoiseScale'])
			obj:setTexCoordScale(objData.vals['TexCoordScale'])
			obj:setDuration(objData.vals['Duration'])
		end
	end

	return this
end

t.create = create

expose('wc3bolt', t)