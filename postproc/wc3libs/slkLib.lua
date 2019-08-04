require 'waterlua'

local t = {}

t.create = function(path)
	local this = {}

	if path then
		if (io.getFileExtension(path) == nil) then
			path = path..'.slk'
		end
	end

	this.path = path

	this.fields = {}

	function this:containsField(field)
		assert(field, 'no field')

		return (this.fields[field] ~= nil)
	end

	function this:addField(field, defVal)
		local fieldData = this.fields[field]

		if (fieldData ~= nil) then
			this.fields[field].defVal = defVal

			return
		end

		--assert((fieldData == nil), 'field '..tostring(field)..' already used')

		fieldData = {}

		if (this.pivotField == nil) then
			this.pivotField = field
		end

		this.fields[field] = fieldData

		this.fields[field].defVal = defVal
	end

	this.objs = {}

	function this:getObj(id)
		assert(id, 'no id')

		return this.objs[id]
	end

	function this:addObj(id)
		assert(id, 'no id')

		local obj = this.objs[id]

		assert((obj == nil), 'obj '..tostring(id)..' already used')

		obj = {}

		this.objs[id] = obj

		obj.vals = {}

		function obj:getVal(field, ignoreError)
			assert((field ~= nil), 'no field')

			if not ignoreError then
				assert((this.fields[field] ~= nil), 'field '..tostring(field)..' not available')
			end

			return obj.vals[field]
		end

		function obj:set(field, val)
			assert((field ~= nil), 'no field')

			assert((this.fields[field] ~= nil), 'field '..tostring(field)..' not available')

			obj.vals[field] = val
		end

		function obj:merge(otherObj, overwrite)
			assert(otherObj, 'no otherObj')

			for field, val in pairs(otherObj.vals) do
				if (overwrite or (obj:getVal(field, true) == nil)) then
					if not this:containsField(field) then
						this:addField(field)
					end

					obj:set(field, val)
				end
			end
		end

		return obj
	end

	function this:merge(otherSlk, overwrite)
		assert(otherSlk, 'no other slk')

		if (this.pivotField == nil) then
			this.pivotField = otherSlk.pivotField
		end

		for field, fieldData in pairs(otherSlk.fields) do
			this:addField(field, fieldData.defVal)
		end

		for objId, otherObj in pairs(otherSlk.objs) do
			local obj = this:getObj(objId)

			if (obj == nil) then
				obj = this:addObj(objId)
			end

			obj:merge(otherObj, overwrite)
		end
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		if (io.getFileExtension(path) == nil) then
			path = path..'.slk'
		end

		io.createDir(getFolder(path))

		local file = io.open(path, 'w+')

		if (file == nil) then
			print('writeSlk: cannot create file at '..path)

			return
		end

		file:write('ID;PWXL;N;E')

		file:write('\n'..'B;Y'..(table.getSize(this.objs) + 1)..';X'..table.getSize(this.fields)..';D0')

		local c = 1
		local fieldX = {}

		local fieldsByX = {}

		local function addField(field)
			fieldsByX[c] = field
			fieldX[field] = c

			c = c + 1
		end

		assert(this.pivotField, 'no pivotField')

		addField(this.pivotField)

		for field in pairs(this.fields) do
			if (field ~= this.pivotField) then
				addField(field)
			end
		end

		local y = 1

		local slkCurX = 0
		local slkCurY = 0

		local function writeCell(x, y, val)
			if val then
				if (type(val) == 'boolean') then
					if val then
						val = 1
					else
						val = 0
					end
				elseif (type(val) == 'string') then
					val = val:quote()
				end
			else
				val = [["-"]]
			end

			if ((val == false) or (val == 0) or (val == '') or (val == [[""]]) or (val == [["0"]]) or (val == [["-"]])) then
				return
			end

			local t = {'C'}

			if (x ~= slkCurX) then
				t[#t + 1] = 'X'..x

				slkCurX = x
			end

			if (y ~= slkCurY) then
				t[#t + 1] = 'Y'..y

				slkCurY = y
			end

			t[#t + 1] = 'K'..val

			file:write('\n'..table.concat(t, ';'))
		end

		for x = 1, #fieldsByX, 1 do
			local field = fieldsByX[x]

			writeCell(x, 1, field)
		end

		for objId, obj in pairs(this.objs) do
			y = y + 1

			writeCell(1, y, objId)

			for x = 2, #fieldsByX, 1 do
				local field = fieldsByX[x]

				local val = obj.vals[field]

				if (val == nil) then
					local defVal = this.fields[field].defVal

					if (defVal ~= nil) then
						writeCell(x, y, defVal)
					end
				else
					writeCell(x, y, val)
				end
			end
		end

		file:write('\n'..'E')

		file:close()
	end

	function this:readFromFile(path, onlyHeader)
		assert(path, 'no path')

		if (io.getFileExtension(path) == nil) then
			path = path..'.slk'
		end

		local data = {}
		local file = io.open(path, 'r')

		local curX = 0
		local curY = 0
		local maxX = 0
		local maxY = 0

		if (file == nil) then
			printTrace('readSlk: could not open '..path)

			return
		end

		for line in file:lines() do
			line = line:split(';')

			if (line[1] == 'C') then
				local c = 1
				local val
				local x
				local y

				while (line[c] ~= nil) do
					local symbole = line[c]:sub(1, 1)

					if (symbole == 'X') then
						x = tonumber(line[c]:sub(2, line[c]:len()))
					end
					if (symbole == 'Y') then
						y = tonumber(line[c]:sub(2, line[c]:len()))
					end
					if (symbole == 'K') then
						val = line[c]:sub(2, line[c]:len())

						if (val:sub(1, 1) == [["]]) then
							val = val:sub(2, val:len() - 1)
						elseif tonumber(val) then
							val = tonumber(val)
						end
					end

					c = c + 1
				end

				if (x == nil) then
					x = curX
				end
				if (y == nil) then
					y = curY
				end

				if (data[y] == nil) then
					data[y] = {}
				end

				if (x > maxX) then
					maxX = x
				end
				if (y > maxY) then
					maxY = y
				end
				data[y][x] = val

				curX = x
				curY = y
			end
		end

		for x, val in pairs(data[1]) do
			this:addField(val)
		end

		this.pivotField = data[1][1]

		if onlyHeader then
			return
		end

		local c = 2

		while data[c] do
			local objId = data[c][1]

			if objId then
				for x, val in pairs(data[c]) do
					local field = data[1][x]

					if field then
						local obj = this.objs[objId]

						if (obj == nil) then
							obj = this:addObj(objId)
						end

						obj:set(field, val)
					end
				end
			end

			c = c + 1
		end
	end

	return this
end

expose('slkLib', t)