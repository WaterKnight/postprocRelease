local t = {}

t.create = function()
	local this = {}

	this.objs = {}

	function this:addObj(id)
		local obj = {}

		function obj:setTexPath(path)
			obj.texPath = path
		end

		function obj:setBlendMode(val)
			obj.blendMode = val
		end

		function obj:setScale(val)
			obj.scale = val
		end

		function obj:setBirthTime(val)
			obj.birthTime = val
		end

		function obj:setPauseTime(val)
			obj.pauseTime = val
		end

		function obj:setDecay(val)
			obj.decay = val
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

		slk:addField('BlendMode')
		slk:addField('Scale')
		slk:addField('BirthTime')
		slk:addField('PauseTime')
		slk:addField('Decay')

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

		slk:addField('Sound')

		for i = 1, #this.objs, 1 do
			local obj = this.objs[i]

			local id = obj.id

			local slkObj = slk:addObj(id)

			slkObj:set('Dir', getFolder(obj.texPath))
			slkObj:set('file', getFileName(obj.texPath, true))

			slkObj:set('BlendMode', obj.blendMode)
			slkObj:set('Scale', obj.scale)
			slkObj:set('BirthTime', obj.birthTime)
			slkObj:set('PauseTime', obj.pauseTime)
			slkObj:set('Decay', obj.decay)

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

			this:setBlendMode(objData.vals['BlendMode'])
			this:setScale(objData.vals['Scale'])
			this:setBirthTime(objData.vals['BirthTime'])
			this:setPauseTime(objData.vals['PauseTime'])
			this:setDecay(objData.vals['Decay'])

			this:setColorStart(objData.vals['StartR'], objData.vals['StartG'], objData.vals['StartB'], objData.vals['StartA'])
			this:setColorMid(objData.vals['MiddleR'], objData.vals['MiddleG'], objData.vals['MiddleB'], objData.vals['MiddleA'])
			this:setColorEnd(objData.vals['EndR'], objData.vals['EndG'], objData.vals['EndB'], objData.vals['EndA'])

			this:setSound(objData.vals['Sound'])
		end
	end

	return this
end

expose('wc3ubersplat', t)