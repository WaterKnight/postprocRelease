require 'waterlua'

local t = {}

t.create = function()
	local this = {}

	this.objs = {}

	function this:addObj(id)
		assert(id, 'no id')

		local obj = {}

		this.objs[id] = obj

		function obj:setHeight(val)
			obj.height = val or 0
		end

		function obj:setImpassable(val)
			obj.impassable = val or 0
		end

		function obj:setTexFile(val)
			obj.texFile = val
		end

		function obj:setMinimapColor(red, green, blue, alpha)
			obj.mmRed = red or 0
			obj.mmGreen = green or 0
			obj.mmBlue = blue or 0
			obj.mmAlpha = alpha or 0
		end

		function obj:setNumTex(val)
			obj.numTum = val or 0
		end

		function obj:setTexOffset(val)
			obj.texOffset = val or 0
		end

		function obj:setTexRate(val)
			obj.texRate = val or 0
		end

		function obj:setAlphaMode(val)
			obj.alphaMode = val or 0
		end

		function obj:setLighting(val)
			obj.lighting = val or 0
		end

		function obj:setCells(val)
			obj.cells = val or 0
		end

		function obj:setMinExtents(x, y, z)
			obj.minX = x or 0
			obj.minY = y or 0
			obj.minZ = z or 0
		end

		function obj:setMaxExtents(x, y, z)
			obj.maxX = x or 0
			obj.maxY = y or 0
			obj.maxZ = z or 0
		end

		function obj:setRate(x, y, z)
			obj.rateX = x
			obj.rateY = y
			obj.rateZ = z
		end

		function obj:setRev(x, y)
			obj.revX = x or 0
			obj.revX = y or 0
		end

		function obj:setShoreInFog(val)
			obj.shoreInFog = val
		end

		function obj:setShoreDir(val)
			obj.shoreDir = val
		end

		function obj:setShoreSFile(val)
			obj.shoreSFile = val
		end

		function obj:setShoreSVar(val)
			obj.shoreSVar = val
		end

		function obj:setShoreOCFile(val)
			obj.shoreOCFile = val
		end

		function obj:setShoreOCVar(val)
			obj.shoreOCVar = val
		end

		function obj:setShoreICFile(val)
			obj.shoreICFile = val
		end

		function obj:setShoreICVar(val)
			obj.shoreICVar = val
		end



		function obj:setSMinColor(red, green, blue, alpha)
			obj.sMinRed = red or 0
			obj.sMinGreen = green or 0
			obj.sMinBlue = blue or 0
			obj.sMinAlpha = alpha or 0
		end

		function obj:setSMaxColor(red, green, blue, alpha)
			obj.sMaxRed = red or 0
			obj.sMaxGreen = green or 0
			obj.sMaxBlue = blue or 0
			obj.sMaxAlpha = alpha or 0
		end

		function obj:setDMinColor(red, green, blue, alpha)
			obj.dMinRed = red or 0
			obj.dMinGreen = green or 0
			obj.dMinBlue = blue or 0
			obj.dMinAlpha = alpha or 0
		end

		function obj:setDMaxColor(red, green, blue, alpha)
			obj.dMaxRed = red or 0
			obj.dMaxGreen = green or 0
			obj.dMaxBlue = blue or 0
			obj.dMaxAlpha = alpha or 0
		end

		return obj
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		require 'slkLib'

		local slk = slkLib.create()

		slk:addField('waterID')

		slk:addField('height')
		slk:addField('impassable')
		slk:addField('texFile')

		slk:addField('mmAlpha')
		slk:addField('mmRed')
		slk:addField('mmGreen')
		slk:addField('mmBlue')

		slk:addField('numTex')
		slk:addField('texRate')
		slk:addField('texOffset')

		slk:addField('alphaMode')
		slk:addField('lighting')
		slk:addField('cells')

		slk:addField('minX')
		slk:addField('minY')
		slk:addField('minZ')
		slk:addField('maxX')
		slk:addField('maxY')
		slk:addField('maxZ')

		slk:addField('rateX')
		slk:addField('rateY')
		slk:addField('rateZ')

		slk:addField('revX')
		slk:addField('revY')

		slk:addField('shoreInFog')
		slk:addField('shoreDir')
		slk:addField('shoreSFile')
		slk:addField('shoreSVar')
		slk:addField('shoreOCFile')
		slk:addField('shoreOCVar')
		slk:addField('shoreICFile')
		slk:addField('shoreICVar')

		slk:addField('Smin_A')
		slk:addField('Smin_R')
		slk:addField('Smin_G')
		slk:addField('Smin_B')

		slk:addField('Smax_A')
		slk:addField('Smax_R')
		slk:addField('Smax_G')
		slk:addField('Smax_B')

		slk:addField('Dmin_A')
		slk:addField('Dmin_R')
		slk:addField('Dmin_G')
		slk:addField('Dmin_B')

		slk:addField('Dmax_A')
		slk:addField('Dmax_R')
		slk:addField('Dmax_G')
		slk:addField('Dmax_B')

		for i = 1, #this.objs, 1 do
			local obj = this.objs[i]

			local id = obj.id

			local slkObj = slk:addObj(id)

			slkObj:set('height', obj.height)
			slkObj:set('impassable', obj.impassable)
			slkObj:set('texFile', obj.texFile)

			slkObj:set('mmAlpha', obj.mmAlpha)
			slkObj:set('mmRed', obj.mmRed)
			slkObj:set('mmGreen', obj.mmGreen)
			slkObj:set('mmBlue', obj.mmBlue)

			slkObj:set('numTex', obj.numTex)
			slkObj:set('texRate', obj.texRate)
			slkObj:set('texOffset', obj.texOffset)

			slkObj:set('alphaMode', obj.alphaMode)
			slkObj:set('lighting', obj.lighting)
			slkObj:set('cells', obj.cells)

			slkObj:set('minX', obj.minX)
			slkObj:set('minY', obj.minY)
			slkObj:set('minZ', obj.minZ)
			slkObj:set('maxX', obj.maxX)
			slkObj:set('maxY', obj.maxY)
			slkObj:set('maxZ', obj.maxZ)

			slkObj:set('rateX', obj.rateX)
			slkObj:set('rateY', obj.rateY)
			slkObj:set('rateZ', obj.rateZ)

			slkObj:set('revX', obj.revX)
			slkObj:set('revY', obj.revY)

			slkObj:set('shoreInFog', obj.shoreInFog)
			slkObj:set('shoreDir', obj.shoreDir)
			slkObj:set('shoreSFile', obj.shoreSFile)
			slkObj:set('shoreSVar', obj.shoreSVar)
			slkObj:set('shoreOCFile', obj.shoreOCFile)
			slkObj:set('shoreOCVar', obj.shoreOCVar)
			slkObj:set('shoreICFile', obj.shoreICFile)
			slkObj:set('shoreICVar', obj.shoreICVar)

			slkObj:set('SminA', obj.sMinAlpha)
			slkObj:set('SminR', obj.sMinRed)
			slkObj:set('SminG', obj.sMinGreen)
			slkObj:set('SminB', obj.sMinBlue)

			slkObj:set('SmaxA', obj.sMaxAlpha)
			slkObj:set('SmaxR', obj.sMaxRed)
			slkObj:set('SmaxG', obj.sMaxGreen)
			slkObj:set('SmaxB', obj.sMaxBlue)

			slkObj:set('DminA', obj.dMinAlpha)
			slkObj:set('DminR', obj.dMinRed)
			slkObj:set('DminG', obj.dMinGreen)
			slkObj:set('DminB', obj.dMinBlue)

			slkObj:set('DmaxA', obj.dMaxAlpha)
			slkObj:set('DmaxR', obj.dMaxRed)
			slkObj:set('DmaxG', obj.dMaxGreen)
			slkObj:set('DmaxB', obj.dMaxBlue)
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

			obj:setHeight(obj.vals['height'])
			obj:setImpassable(obj.vals['impassable'])
			obj:setTexFile(obj.vals['texFile'])

			obj:setMinimapColor(obj.vals['mmRed'], obj.vals['mmGreen'], obj.vals['mmBlue'], obj.vals['mmAlpha'])

			obj:setNumTex(obj.vals['numTex'])
			obj:setTexRate(obj.vals['texRate'])
			obj:setTexOffset(obj.vals['texOffset'])

			obj:setAlphaMode(obj.vals['alphaMode'])
			obj:setLighting(obj.vals['lighting'])
			obj:setCells(obj.vals['cells'])

			obj:setMinExtents(obj.vals['minX'], obj.vals['minY'], obj.vals['minZ'])
			obj:setMaxExtents(obj.vals['maxX'], obj.vals['maxY'], obj.vals['maxZ'])

			obj:setRate(obj.vals['rateX'], obj.vals['rateY'], obj.vals['rateZ'])

			obj:setRev(obj.vals['revX'], obj.vals['revY'])

			obj:setShoreInFog(obj.vals['shoreInFog'], obj.vals['shoreInFog'])
			obj:setShoreDir(obj.vals['shoreDir'], obj.vals['shoreDir'])
			obj:setShoreSFile(obj.vals['shoreSFile'], obj.vals['shoreSFile'])
			obj:setShoreSVar(obj.vals['shoreSVar'], obj.vals['shoreSVar'])
			obj:setShoreOCFile(obj.vals['shoreOCFile'], obj.vals['shoreOCFile'])
			obj:setShoreOCVar(obj.vals['shoreOCVar'], obj.vals['shoreOCVar'])
			obj:setShoreICFile(obj.vals['shoreICFile'], obj.vals['shoreICFile'])
			obj:setShoreICVar(obj.vals['shoreICVar'], obj.vals['shoreICVar'])

			obj:setSMinColor(obj.vals['SminR'], obj.vals['SminG'], obj.vals['SminB'], obj.vals['SminA'])
			obj:setSMaxColor(obj.vals['SmaxR'], obj.vals['SmaxG'], obj.vals['SmaxB'], obj.vals['SmaxA'])

			obj:setDMinColor(obj.vals['DminR'], obj.vals['DminG'], obj.vals['DminB'], obj.vals['DminA'])
			obj:setDMaxColor(obj.vals['DmaxR'], obj.vals['DmaxG'], obj.vals['DmaxB'], obj.vals['DmaxA'])
		end
	end

	return this
end

expose('wc3water', t)