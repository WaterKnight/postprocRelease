require 'waterlua'

local t = {}

local function create(wtsPath)
	local wtsTable

	local this = {}

	function this:setWts(t)
		wtsTable = t
	end

	if (wtsPath ~= nil) then
		io.local_require([[wtsParser]])

		this:setWts(wtsParser.parse(wtsPath))
	end

	this.objs = {}

	function this:getObj(id)
		assert(id, 'no id')

		return this.objs[id]
	end

	function this:addObj(id)
		assert((id ~= nil), 'no id')

		local obj = this.objs[id]

		assert((obj == nil), 'obj '..tostring(id)..' already used')

		obj = {}

		this.objs[id] = obj

		obj.vals = {}

		function obj:deleteVal(field, index)
			assert(field, 'no field')

			local fieldData = obj.fields[field]

			assert(fieldData, 'field '..tostring(field)..' not available')

			if (index == nil) then
				index = 0
			end

			fieldData[index] = nil

			if (table.getSize(fieldData) == 0) then
				obj.fields[field] = nil
			end
		end

		function obj:set(field, val, index)
			assert(field, 'no field')

			local fieldData = obj.vals[field]

			if (fieldData == nil) then
				fieldData = {}

				obj.vals[field] = fieldData
			end

			if (index == nil) then
				index = 0
			end

			fieldData[index] = val
		end

		function obj:addVal(field, val)
			assert(field, 'no field')

			local fieldData = obj.vals[field]

			local index = 0

			if (fieldData ~= nil) then
				while (fieldData[index] ~= nil) do
					index = index + 1
				end
			end

			obj:set(field, val, index)
		end

		function obj:merge(otherObj)
			assert(otherObj, 'no otherObj')

			for field, fieldData in pairs(otherObj.vals) do
				for index, val in pairs(fieldData) do
					obj:set(field, val, index)
				end
			end
		end

		function obj:remove()
			this.objs[obj.id] = nil
		end

		return obj
	end

	function this:merge(otherProfile)
		assert(otherProfile, 'no other profile')

		for objId, otherObj in pairs(otherProfile.objs) do
			local obj = this.objs[objId]

			if (obj == nil) then
				obj = this:addObj(objId)
			end

			obj:merge(otherObj)
		end
	end

	function this:print()
		for objId, obj in pairs(this.objs) do
			print(string.format('[%s]', objId))

			for field, fieldData in pairs(obj.vals) do
				for index, val in ipairs(fieldData) do
					print(string.format('%s=%s', field, val))
				end
			end
		end
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		assert(io.pathIsWritable(path), 'cannot open file '..tostring(path))

		local lines = {}

		local function addLine(line)
			line = line or ''

			lines[#lines + 1] = line
		end

		local ignoredFields = {
			'EditorSuffix'
		}

		for i = 1, #ignoredFields, 1 do
			local field = ignoredFields[i]

			ignoredFields[field] = true
		end

		for objId, obj in pairs(this.objs) do
			if (table.getSize(obj.vals) > 0) then
				local foundRelevantField = false

				for field, fieldData in pairs(obj.vals) do
					if not ignoredFields[field] then
						foundRelevantField = true
					end
				end

				if foundRelevantField then
					addLine(string.format('[%s]', objId))

					for field, fieldData in pairs(obj.vals) do
						if not ignoredFields[field] then
							for index, val in ipairs(fieldData) do
								if ((wtsTable ~= nil) and (type(val) == 'string')) then
									val = wtsParser.translateString(wtsTable, val)
								end

								addLine(string.format('%s=%s', field, val))
							end
						end
					end

					addLine('')
				end
			end
		end

		local f = io.open(path, 'w+')

		assert(f, 'could not open file '..tostring(path))

		table.write(f, lines)

		f:close()
	end

	function this:readFromFile(path)
		assert(path, 'no path')

		local f = io.open(path, 'r')

		assert(f, 'could not open file '..tostring(path))

		local lines = {}

		for line in f:lines() do
			local pos, posEnd = line:find('//', 1, true)
	
			if pos then
				line = line:sub(1, pos - 1)
			end

			lines[#lines + 1] = line
		end

		f:close()

		tmpProfile = create()

		local curObj

		for i = 1, #lines, 1 do
			local line = lines[i]
	
			local pos, posEnd, objId = line:gsub('%s', ''):find('^%s*%[(....)%]%s*$')
	
			if (pos ~= 1) then
				objId = nil
			end
	
			if (objId ~= nil) then
				local obj = tmpProfile.objs[objId]

				if (obj == nil) then
					obj = tmpProfile:addObj(objId)
				end

				curObj = obj
			end
	
			if (curObj ~= nil) then
				local field, valLine = line:match('%s*([%w]*)%=(.*)')

				if (field ~= nil) then
					local startPos = 1

					while (startPos <= valLine:len()) do
						if (valLine:sub(startPos, startPos) == [["]]) then
							local endPos = valLine:find([["]], startPos + 1, true)

							if (endPos == nil) then
								endPos = valLine:len()
							end

							local val = valLine:sub(startPos, endPos):dequote()

							if (tonumber(val) ~= nil) then
								val = tonumber(val)
							end
--print('add', '<'..val..'>')
							curObj:addVal(field, val)

							startPos = endPos + 1

							if (valLine:sub(startPos, startPos) == [[,]]) then
								startPos = startPos + 1
							end
						else
							local endPos = valLine:find([[,]], startPos, true)

							if (endPos == nil) then
								endPos = valLine:len()
							else
								endPos = endPos - 1
							end

							local val

							if (endPos < startPos) then
								val = ''
							else
								val = valLine:sub(startPos, endPos)
							end

							if (tonumber(val) ~= nil) then
								val = tonumber(val)
							end
--print('add', '<'..val..'>')
							curObj:addVal(field, val)

							startPos = endPos + 2
						end
					end
				end
			end
		end

		this:merge(tmpProfile)
	end

	return this
end

t.create = create

expose('wc3profile', t)