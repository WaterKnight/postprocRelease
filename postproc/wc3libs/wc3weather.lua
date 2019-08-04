require 'waterlua'

local t = {}

t.create = function()
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

		function obj:setAlphaMode(val)
			this.alphaMode = val or 1
		end

		function obj:setUseFog(val)
			this.useFog = val or 1
		end

		function obj:setHeight(val)
			this.height = val or 100
		end

		function obj:setAng(x, y)
			this.angx = x or -50
			this.angy = y or 50
		end

		function obj:setEmissionRate(val)
			this.emissionRate = val or 10
		end

		function obj:setLifespan(val)
			this.lifespan = val or 5
		end

		function obj:setParticles(val)
			this.particles = val or 1000
		end

		function obj:setSpeed(speed, accel)
			this.speed = speed or -100
			this.accel = accel or 0
		end

		function obj:setVariance(val)
			this.variance = val or 0.05
		end

		function obj:setTexC(val)
			this.texc = val or 10
		end

		function obj:setTexR(val)
			this.texr = val or 10
		end

		function obj:setHead(val)
			this.head = val or 1
		end

		function obj:setTail(val)
			this.tail = val or 0
		end

		function obj:setTailLen(val)
			this.tailLen = val or 1
		end

		function obj:setLatitude(val)
			this.latitude = val or 2.5
		end

		function obj:setLongitude(val)
			this.longitude = val or 180
		end

		function obj:setMidTime(val)
			this.midTime = val or 0.5
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

		function obj:setScale(scaleStart, scaleMid, scaleEnd)
			obj.scaleStart = scaleStart or 100
			obj.scaleMid = scaleMid or 100
			obj.scaleEnd = scaleEnd or 100
		end

		function obj:setHUV(hUVStart, hUVMid, hUVEnd)
			obj.hUVStart = hUVStart or 0
			obj.hUVMid = hUVMid or 0
			obj.hUVEnd = hUVEnd or 0
		end

		function obj:setTUV(tUVStart, tUVMid, tUVEnd)
			obj.tUVStart = tUVStart or 0
			obj.tUVMid = tUVMid or 0
			obj.tUVEnd = tUVEnd or 0
		end

		function obj:setSound(val)
			this.sound = val
		end

		return obj
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		require 'slkLib'

		local slk = slkLib.create()

		slk:addField('effectID')

		slk:addField('name')

		slk:addField('texDir')
		slk:addField('texFile')

		slk:addField('alphaMode')

		slk:addField('useFog')
		slk:addField('height')

		slk:addField('angx')
		slk:addField('angy')

		slk:addField('emrate')
		slk:addField('lifespan')
		slk:addField('particles')

		slk:addField('veloc')
		slk:addField('accel')

		slk:addField('var')

		slk:addField('texr')
		slk:addField('texc')

		slk:addField('head')
		slk:addField('tail')
		slk:addField('taillen')

		slk:addField('lati')
		slk:addField('long')

		slk:addField('midTime')

		slk:addField('redStart')
		slk:addField('greenStart')
		slk:addField('blueStart')

		slk:addField('redMid')
		slk:addField('greenMid')
		slk:addField('blueMid')

		slk:addField('redEnd')
		slk:addField('greenEnd')
		slk:addField('blueEnd')

		slk:addField('alphaStart')
		slk:addField('alphaMid')
		slk:addField('alphaEnd')

		slk:addField('scaleStart')
		slk:addField('scaleMid')
		slk:addField('scaleEnd')

		slk:addField('hUVStart')
		slk:addField('hUVMid')
		slk:addField('hUVEnd')

		slk:addField('tUVStart')
		slk:addField('tUVMid')
		slk:addField('tUVEnd')

		slk:addField('AmbientSound')

		slk:addField('version')

		for i = 1, #this.objs, 1 do
			local obj = this.objs[i]

			local id = obj.id

			local slkObj = slk:addObj(id)

			slkObj:set('texDir', getFolder(obj.texPath))
			slkObj:set('texFile', getFileName(obj.texPath, true))

			slkObj:set('alphaMode', obj.alphaMode)
			slkObj:set('useFog', obj.useFog)
			slkObj:set('height', obj.height)
			slkObj:set('angx', obj.angx)
			slkObj:set('angy', obj.angy)
			slkObj:set('emrate', obj.emissionRate)
			slkObj:set('lifespan', obj.lifespan)
			slkObj:set('particles', obj.particles)
			slkObj:set('veloc', obj.speed)
			slkObj:set('accel', obj.accel)
			slkObj:set('var', obj.variance)
			slkObj:set('texr', obj.texr)
			slkObj:set('texc', obj.texc)
			slkObj:set('head', obj.head)
			slkObj:set('tail', obj.tail)
			slkObj:set('taillen', obj.tailLen)
			slkObj:set('lati', obj.latitude)
			slkObj:set('long', obj.longitude)

			slkObj:set('midTime', obj.midTime)

			slkObj:set('redStart', obj.redStart)
			slkObj:set('greenStart', obj.greenStart)
			slkObj:set('blueStart', obj.blueStart)
			slkObj:set('alphaStart', obj.alphaStart)

			slkObj:set('redMid', obj.redMid)
			slkObj:set('greenMid', obj.greenMid)
			slkObj:set('blueMid', obj.blueMid)
			slkObj:set('alphaMid', obj.alphaMid)

			slkObj:set('redEnd', obj.redEnd)
			slkObj:set('greenEnd', obj.greenEnd)
			slkObj:set('blueEnd', obj.blueEnd)
			slkObj:set('alphaEnd', obj.alphaEnd)

			slkObj:set('scaleStart', obj.scaleStart)
			slkObj:set('scaleMid', obj.scaleMid)
			slkObj:set('scaleEnd', obj.scaleEnd)

			slkObj:set('hUVStart', obj.hUVStart)
			slkObj:set('hUVMid', obj.hUVMid)
			slkObj:set('hUVEnd', obj.hUVEnd)

			slkObj:set('tUVStart', obj.tUVStart)
			slkObj:set('tUVMid', obj.tUVMid)
			slkObj:set('tUVEnd', obj.tUVEnd)

			if (obj.sound == nil) then
				slkObj:set('AmbientSound', '-')
			else
				slkObj:set('AmbientSound', obj.sound)
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

			obj:setAlphaMode(objData.vals['alphaMode'])
			obj:setUseFog(objData.vals['useFog'])
			obj:setHeight(objData.vals['height'])
			obj:setAng(objData.vals['angx'], objData.vals['angy'])
			obj:setEmissionRate(objData.vals['emrate'])
			
			obj:setLifespan(objData.vals['lifespan'])
			obj:setParticles(objData.vals['particles'])
			obj:setSpeed(objData.vals['veloc'])
			obj:setAcc(objData.vals['accel'])
			obj:setVar(objData.vals['var'])
			obj:setTexR(objData.vals['texr'])
			obj:setTexC(objData.vals['texc'])
			obj:setHead(objData.vals['head'])
			obj:setTail(objData.vals['tail'])
			obj:setTailLen(objData.vals['tailLen'])
			obj:setLatitude(objData.vals['lati'])
			obj:setLongitude(objData.vals['long'])
			
			obj:setMidTime(objData.vals['midTime'])
			
			obj:setColorStart(objData.vals['redStart'], objData.vals['greenStart'], objData.vals['blueStart'], objData.vals['alphaStart'])
			obj:setColorMid(objData.vals['redMid'], objData.vals['greenMid'], objData.vals['blueMid'], objData.vals['alphaMid'])
			obj:setColorEnd(objData.vals['redEnd'], objData.vals['greenEnd'], objData.vals['blueEnd'], objData.vals['alphaEnd'])

			obj:setScale(objData.vals['scaleStart'], objData.vals['scaleMid'], objData.vals['scaleEnd'])

			obj:setHUV(objData.vals['hUVStart'], objData.vals['hUVMid'], objData.vals['hUVEnd'])
			obj:setTUV(objData.vals['tUVStart'], objData.vals['tUVMid'], objData.vals['tUVEnd'])

			local sound = objData.vals['AmbientSound']

			if (sound ~= '-') then
				obj:setAlphaMode(sound)
			end
		end
	end

	return this
end

expose('wc3weather', t)