local t = {}

t.create = function()
	local this = {}

	this.objs = {}

	function this:addObj(id)
		assert(id, 'no id')

		local obj = {}

		this.objs[id] = obj

		function obj:setTexPath(path)
			obj.texPath = path
		end

		function obj:setRows(val)
			obj.rows = val or 0
		end

		function obj:setColumns(val)
			obj.columns = val or 0
		end

		function obj:setBlendMode(val)
			obj.blendMode = val or 0
		end

		function obj:setScale(val)
			obj.scale = val or 1
		end

		function obj:setLifespan(val)
			obj.lifespan = val or 0
		end

		function obj:setLifespanParams(lifespanStart, lifespanEnd, lifespanRepeat)
			obj.lifespanStart = lifespanStart or 0
			obj.lifespanEnd = lifespanEnd or 0
			obj.lifespanRepeat = lifespanRepeat or 0
		end

		function obj:setDecayParams(decayStart, decayEnd, decayRepeat)
			obj.decayStart = decayStart or 0
			obj.decayEnd = decayEnd or 0
			obj.decayRepeat = decayRepeat or 0
		end

		function obj:setColorStart(red, green, blue, alpha)
			obj.redStart = red or 255
			obj.greenStart = green or 255
			obj.blueStart = blue or 255
			obj.alphaStart = alpha or 255
		end

		function obj:setColorMid(red, green, blue, alpha)
			obj.redMid = red or 127
			obj.greenMid = green or 127
			obj.blueMid = blue or 127
			obj.alphaMid = alpha or 127
		end

		function obj:setColorEnd(red, green, blue, alpha)
			obj.redEnd = red or 0
			obj.greenEnd = green or 0
			obj.blueEnd = blue or 0
			obj.alphaEnd = alpha or 0
		end

		function obj:setSound(val)
			if (val == 'NULL') then
				val = nil
			end

			obj.sound = val
		end

		return obj
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		require 'slkLib'

		local slk = slkLib.create()

		slk:addField('Name')

		slk:addField('comment')

		slk:addField('Dir')
		slk:addField('file')

		slk:addField('Rows')
		slk:addField('Columns')

		slk:addField('BlendMode')
		slk:addField('Scale')

		slk:addField('Decay')
		slk:addField('Lifespan')

		slk:addField('UVDecayStart')
		slk:addField('UVDecayEnd')
		slk:addField('DecayRepeat')

		slk:addField('UVLifespanStart')
		slk:addField('UVLifespanEnd')
		slk:addField('LifespanRepeat')

		slk:addField('StartR')
		slk:addField('StartG')
		slk:addField('StartB')
		slk:addField('StartA')

		slk:addField('MiddleR')
		slk:addField('MiddleG')
		slk:addField('MiddleB')
		slk:addField('MiddleA')

		slk:addField('EndR')
		slk:addField('EndG')
		slk:addField('EndB')
		slk:addField('EndA')

		slk:addField('Water')
		slk:addField('Sound')

		for i = 1, #this.objs, 1 do
			local obj = this.objs[i]

			local id = obj.id

			local slkObj = slk:addObj(id)

			slkObj:set('Dir', getFolder(obj.texPath))
			slkObj:set('file', getFileName(obj.texPath, true))

			slkObj:set('Rows', obj.rows)
			slkObj:set('Columns', obj.columns)

			slkObj:set('BlendMode', obj.blendMode)
			slkObj:set('Scale', obj.scale)

			slkObj:set('Lifespan', obj.lifespan)
			slkObj:set('Decay', obj.decay)

			slkObj:set('UVLifespanStart', obj.lifespanStart)
			slkObj:set('UVLifespanEnd', obj.lifespanEnd)
			slkObj:set('LifespanRepeat', obj.lifespanRepeat)

			slkObj:set('UVDecayStart', obj.decayStart)
			slkObj:set('UVDecayEnd', obj.decayEnd)
			slkObj:set('DecayRepeat', obj.decayRepeat)

			slkObj:set('StartR', obj.redStart)
			slkObj:set('StartG', obj.greenStart)
			slkObj:set('StartB', obj.blueStart)
			slkObj:set('StartA', obj.alphaStart)

			slkObj:set('MiddleR', obj.redMid)
			slkObj:set('MiddleG', obj.greenMid)
			slkObj:set('MiddleB', obj.blueMid)
			slkObj:set('MiddleA', obj.alphaMid)

			slkObj:set('EndR', obj.redEnd)
			slkObj:set('EndG', obj.greenEnd)
			slkObj:set('EndB', obj.blueEnd)
			slkObj:set('EndA', obj.alphaEnd)

			slkObj:set('Water', obj.water)

			if (obj.sound == nil) then
				slkObj:set('Sound', 'NULL')
			else
				slkObj:set('Sound', obj.sound)
			end
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

			local texDir = objData.vals['Dir'] or ''
			local texFileName = objData.vals['file'] or ''

			local texPath = texDir..texFileName

			if (texPath ~= '') then
				obj:setTexPath(texPath)
			end

			this:setRows(objData.vals['Rows'])
			this:setColumns(objData.vals['Columns'])

			this:setBlendMode(objData.vals['BlendMode'])
			this:setScale(objData.vals['Scale'])

			this:setLifespan(objData.vals['Lifespan'])
			this:setDecay(objData.vals['Decay'])
			this:setLifespanParams(objData.vals['UVLifespanStart'], objData.vals['UVLifespanEnd'], objData.vals['LifespanRepeat'])
			this:setDecayParams(objData.vals['UVDecayStart'], objData.vals['UVDecayEnd'], objData.vals['DecayRepeat'])

			this:setColorStart(objData.vals['StartR'], objData.vals['StartG'], objData.vals['StartB'], objData.vals['StartA'])
			this:setColorMid(objData.vals['MiddleR'], objData.vals['MiddleG'], objData.vals['MiddleB'], objData.vals['MiddleA'])
			this:setColorEnd(objData.vals['EndR'], objData.vals['EndG'], objData.vals['EndB'], objData.vals['EndA'])

			this:setWater(objData.vals['Water'])
			this:setSound(objData.vals['Sound'])
		end
	end

	return this
end

expose('wc3splat', t)