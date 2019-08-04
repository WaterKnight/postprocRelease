local t = {}

t.create = function()
	local this = {}

	this.objs = {}

	function this:addObj(id)
		assert(id, 'no id')

		local obj = {}

		this.objs[id] = obj

		function obj:setFileNames(val)
			obj.fileNames = val or ''
		end

		function obj:setDir(val)
			obj.dir = val or ''
		end

		function obj:setMaxDist(val)
			obj.maxDist = val or 0
		end

		function obj:setMinDist(val)
			obj.minDist = val or 0
		end

		function obj:setDistCut(val)
			obj.distCut = val or 0
		end

		function obj:setVolume(val)
			this.vol = val or 127
		end

		function obj:setPitch(pitch, pitchVar)
			obj.pitch = pitch or 0
			obj.pitchVar = pitchVar or 0
		end

		function obj:setPrio(val)
			obj.prio = val or 0
		end

		function obj:setChannel(val)
			obj.channel = val or 0
		end

		function obj:setFlags(val)
			obj.flags = val
		end

		function obj:setEAXFlags(val)
			obj.eaxFlags = val
		end

		return obj
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		require 'slkLib'

		local slk = slkLib.create()

		slk:addField('SoundName')

		slk:addField('FileNames')
		slk:addField('DirectyBase')

		slk:addField('MaxDistance')
		slk:addField('MinDistance')
		slk:addField('DistanceCutoff')

		slk:addField('Volume')
		slk:addField('Pitch')
		slk:addField('PitchVariance')
		slk:addField('Priority')
		slk:addField('Channel')
		slk:addField('Flags')
		slk:addField('EAXFlags')

		for i = 1, #this.objs, 1 do
			local obj = this.objs[i]

			local id = obj.id

			local slkObj = slk:addObj(id)

			slkObj:set('FileNames', obj.fileNames)
			slkObj:set('DirectoryBase', obj.dir)

			slkObj:set('MaxDistance', obj.maxDist)
			slkObj:set('MinDistance', obj.minDist)
			slkObj:set('DistanceCutoff', obj.distCut)

			slkObj:set('Volume', obj.vol)
			slkObj:set('Pitch', obj.pitch)
			slkObj:set('PitchVariance', obj.pitchVar)
			slkObj:set('Priority', obj.prio)
			slkObj:set('Channel', obj.channel)
			slkObj:set('Flags', obj.flags)
			slkObj:set('EAXFlags', obj.eaxFlags)
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

			obj:setFileNames(obj.vals['FileNames'])
			obj:setDirectoryBase(obj.vals['DirectoryBase'])

			obj:setMaxDist(obj.vals['MaxDistance'])
			obj:setMinDist(obj.vals['MinDistance'])
			obj:setDistCutoff(obj.vals['DistanceCutoff'])

			obj:setVolume(obj.vals['Volume'])
			obj:setPitch(obj.vals['Pitch'], obj.vals['PitchVariance'])
			obj:setPriority(obj.vals['Priority'])
			obj:setChannel(obj.vals['Channel'])
			obj:setFlags(obj.vals['Flags'])
			obj:setEAXFlags(obj.vals['EAXFlags'])

			--obj:setInsideAngle(obj.vals['InsideAngle'])
			--obj:setOutsideAngle(obj.vals['OutsideAngle'])
			--obj:setOutsideVolume(obj.vals['OutsideVolume'])
			--obj:setOrientation(obj.vals['OrientationX'], obj.vals['OrientationY'], obj.vals['OrientationZ'])
		end
	end

	return this
end

expose('wc3sound', t)