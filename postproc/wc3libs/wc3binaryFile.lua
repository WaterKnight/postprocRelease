--wc3binaryFile.lua

require 'waterlua'

io.local_require('miscLib')

local nilTo0 = function(val)
	if (val == nil) then
		return 0
	end

	return val
end

local char = string.char
local floor = math.floor
local min = math.min
local format = string.format
local ntype = type
local rep = string.rep

local function errorEx(s, continue)
	if continue then
		print('error: '..tostring(s))
	else
		error('error: '..tostring(s))
	end
end

local t = {}

t.checkFormatVer = function(sender, shouldBe, got)
	local okay

	if (type(shouldBe) == 'table') then
		for k, v in pairs(shouldBe) do
			if (v == got) then
				okay = true
			end
		end
	else
		okay = (got == shouldBe)
	end

	if not okay then
		if (type(shouldBe) == 'table') then
			local s

			for k, v in pairs(shouldBe) do
				if s then
					s = s..','..v
				else
					s = v
				end
			end

			s = '{'..s..'}'

			--error(sender..': warning: wrong format version, got '..got..' instead of '..s, true)
			error(string.format('%s: wrong format version, got %s instead of %s', sender, got, s))
		else
			--error(sender..': warning: wrong format version, got '..got..' instead of '..shouldBe, true)
			error(string.format('%s: wrong format version, got %s instead of %s', sender, got, shouldBe))
		end
	end
end

t.create = function()
	local this = {}

	local MODE_READING = {
		name = 'reading'
	}

	local MODE_WRITING = {
		name = 'writing'
	}

	local curMode

	local types = {}
	local typeByName = {}

	local function createType(name, size, defVal)
		local this = {
			name = name,
			size = size,
			sizeBit = size * 8,
			defVal = defVal
		}

		types[this] = this
		typeByName[name] = this

		return this
	end

	local function getTypeByName(name)
		return typeByName[name]
	end

	this.getTypeByName = function(name)
		return getTypeByName(name)
	end

	local curStream

	local function createStream()
		local this = {}

		this.pos = 1

		this.bytes = {}
		this.bytesString = nil

		function this:getAbs(pos)
			return this.bytes[pos]
		end

		function this:setAbs(pos, val)
			this.bytes[pos] = val
		end

		function this:set(pos, val)
			this:setAbs(this.pos + pos, val)
		end

		function this:add(val)
			this.bytes[this.pos] = val

			this.pos = this.pos + 1
		end

		function this:addString(val)
			for i = 1, val:len(), 1 do
				this:add(string.byte(val:sub(i, i)))
			end
		end

		function this:get(offset)
			return this.bytes[this.pos + offset]
		end

		function this:getAsString(startOffset, endOffset)
			return this.bytesString:sub(this.pos + startOffset, this.pos + endOffset)
		end

		function this:write(type, val)
			assert(type, 'no type')

			if (ntype(type) == 'string') then
				type = getTypeByName(type)
			end

			local writeFunc = type.writeFunc
			--local val

			assert(writeFunc, 'no writeFunc')

			writeFunc(this, val)
			--[[val, posInc = writeFunc(this)

			if (val == nil) then
				errorEx('cannot write '..type.name..' at pos '..(this.pos - 1)..' (0x'..format('%X', this.pos - 1)..')', true)
			end

			if posInc then
				this.pos = this.pos + posInc
			else
				this.pos = this.pos + type.size
			end]]
		end

		function this:read(type)
			assert(type, 'no type')

			if (ntype(type) == 'string') then
				type = getTypeByName(type)
			end

			local readFunc = type.readFunc
			local val

			assert(readFunc, 'no readFunc')

			val, posInc = readFunc(this)

			if (val == nil) then
				errorEx('no '..type.name..' at pos '..(this.pos - 1)..' (0x'..format('%X', this.pos - 1)..')', true)
			end

			if posInc then
				this.pos = this.pos + posInc
			else
				this.pos = this.pos + type.size
			end

			return val
		end

		return this
	end

	local function byteHasBit(num, bit)
		assert(num, 'no num')
		assert(bit, 'no bit')

		return ((floor(num / math.pow2(bit - 1)) % 2) == 1)
	end

	local function byteGetBit(num, bit)
		assert(num, 'no num')
		assert(bit, 'no bit')

		if byteHasBit(num, bit) then
			return 1
		end

		return 0
	end

	local function byteEraseBit(num, bit)
		assert(num, 'no num')
		assert(bit, 'no bit')

		if byteHasBit(num, bit) then
			return (num - math.pow2(bit - 1))
		end

		return num
	end

	local function byteAddBit(num, bit)
		assert(num, 'no num')
		assert(bit, 'no bit')

		if byteHasBit(num, bit) then
			return num
		end

		return (num + math.pow2(bit - 1))
	end

	local function byteSetBit(num, bit, val)
		assert(num, 'no num')
		assert(bit, 'no bit')
		assert(val, 'no val')

		if (nilTo0(val) ~= 0) then
			return byteAddBit(num, bit)
		else
			return byteEraseBit(num, bit)
		end
	end

	local function paramsToString(...)
		local arg = {...}
		local result
		local n = select('#', ...)

		for c = 1, n, 1 do
			local v = arg[c]

			if result then
				result = result..', '
			else
				result = ''
			end

			if (ntype(v) == 'string') then
				result = result..tostring(v):quote()
			else
				result = result..tostring(v)
			end
		end

		return '('..result..')'
	end

	local function checkMethodCaller(self)
		if (ntype(self) == 'table') then
			return
		end

		errorEx(debug.getinfo(2).name..': tried to call without a subject, check if you used the "." operator instead of ":"')
	end

	function this:getFullPath()
		checkMethodCaller(self)

		local string result = self.name

		local parent = self.parent

		while parent do
			result = parent.name..'\\'..result

			parent = parent.parent
		end

		return result
	end

	function this:getSub(name, ignoreIfMissing)
		checkMethodCaller(self)

		if (name == nil) then
			errorEx('try to access field with nil name')

			return nil
		end

		local sub = self.subsByName[name]

		if (sub == nil) then
			if not ignoreIfMissing then
				errorEx('field '..name:quote()..' does not exist under node '..self:getFullPath():quote())
			end

			return nil
		end

		return sub
	end

	function this:getVal()
		checkMethodCaller(self)

		return self.val
	end

	function this:getValFromNode(name, ignoreIfMissing)
		checkMethodCaller(self)

		local sub = self:getSub(name, ignoreIfMissing)

		if (sub == nil) then
			if not ignoreIfMissing then
				errorEx('getValFromNode - there is no field '..name:quote()..' under node '..self:getFullPath():quote())
			end

			return nil
		end

		local result = sub:getVal()

		return result
	end

	function this:setVal(val)
		checkMethodCaller(self)

		local type = self.type

		if type then
			local setFunc = type.setFunc

			if setFunc then
				local inputVal = val

				val = setFunc(val)

				if (val == nil) then
					errorEx('cannot set field '..self:getFullPath():quote()..' to <'..tostring(inputVal)..'> ('..type.name..')')

					return
				end
			end
		end

		self.val = val
	end

	function this:setValFromNode(name, val)
		checkMethodCaller(self)

		local sub = self:getSub(name)

		if (sub == nil) then
			errorEx('setValFromNode - there is no field '..name:quote()..' under node '..self:getFullPath():quote())

			return
		end

		sub:setVal(val)
	end

	function this:clear()
		checkMethodCaller(self)

		self.subs = {}
		self.subsCount = 0
		self.subsByName = {}
	end

	local function addBits(field, bits)
		local node = field.parent
		local type = field.type

		local size = type.sizeBit

		field.bits = {}

		local maxBit = 0

		for bit in pairs(bits) do
			if (bit > maxBit) then
				maxBit = bit
			end
		end

		for bit = 1, maxBit, 1 do
			local name = bits[bit]

			if name then
				bit = tonumber(bit)

				if ((bit == nil) or (bit ~= floor(bit))) then
					errorEx('addBits - '..tostring(bit):quote()..' is not a valid flag index (must be integer)')

					return
				end

				if ((bit < 1) or (bit > size)) then
					errorEx('addBits - index '..bit..' is out of bounds for type '..type.name..' (should be within 1-'..size..')')

					return
				end

				if (ntype(name) ~= 'string') then
					errorEx('addBits - '..tostring(name)..' is no string')

					return
				end

				local sub = node.subsByName[name]

				if sub then
					if (sub.posVals == nil) then
						errorEx('addBits - try to redeclare field '..sub:getFullPath():quote())

						return
					end

					sub.posValsCount = sub.posValsCount + 1
					sub.posVals[bit] = sub.posValsCount
				else
					sub = {
						name = name,
						posValsCount = 1,
						posVals = {[bit] = 1},
						val = 0,

						getFullPath = this.getFullPath,
						getVal = this.getVal,
						setVal = this.setVal
					}

					node.subsCount = node.subsCount + 1
					node.subs[node.subsCount] = sub
					node.subsByName[name] = sub
				end

				field.bits[bit] = sub
			end
		end
	end

	local function addData(parent, name, type, bits)
		if ((name == nil) or (type == nil)) then
			errorEx('no name/type passed to add '..paramsToString(name, type))

			return
		end

		if (types[type] == nil) then
			errorEx('try to add with invalid type '..paramsToString(name, type))

			return
		end

		local sub = {
			name = name,
			parent = parent,
			type = type,

			getFullPath = this.getFullPath,
			getVal = this.getVal,
			setVal = this.setVal,

			rename = this.rename
		}

		parent.subsCount = parent.subsCount + 1
		parent.subs[parent.subsCount] = sub
		parent.subsByName[name] = sub

		if bits then
			addBits(sub, bits)
		end

		return sub
	end

	local function readBits(stream, field, fillFrom)
		local bits = field.bits

		for bit, name in pairs(bits) do
			bits[bit].val = bits[bit].val + byteGetBit(stream:getAbs(fillFrom + floor((bit - 1) / 8)), (bit - 1) % 8 + 1) * math.pow2(bits[bit].posVals[bit] - 1)
		end
	end

	local function read(stream, field)
		if (field == nil) then
			errorEx('no field passed to read '..paramsToString(field))

			return
		end

		local type = field.type

		local readFunc = type.readFunc
		local val

		if readFunc then
			local bits = field.bits

			if bits then
				local size = type.size

				if (size > 0) then
					for bit, name in pairs(bits) do
						local byteIndex = stream.pos + floor((bit - 1) / 8)

						bits[bit].val = bits[bit].val + byteGetBit(stream:getAbs(byteIndex), (bit - 1) % 8 + 1) * math.pow2(bits[bit].posVals[bit] - 1)

						stream:setAbs(byteIndex, byteEraseBit(stream:getAbs(byteIndex), (bit - 1) % 8 + 1))
					end
				end
			end

			val = curStream:read(type)

			if (val == nil) then
				field.val = type.defVal
			else
				field.val = val
			end
		end
	end

	local function writeBits(stream, field, pos)
		local bits = field.bits

		for bit, name in pairs(bits) do
			local byteIndex = floor((bit - 1) / 8) + 1
--error(tostring(stream:get(byteIndex))..';'..byteIndex..';'..#stream.bytes..';'..pos+byteIndex)
			local val = stream:getAbs(pos + byteIndex)

			stream:set(byteIndex, char(byteSetBit(val, (bit - 1) % 8 + 1, byteGetBit(val, bit) + byteGetBit(bits[bit].val, bits[bit].posVals[bit]))))
		end
	end

	local function write(stream, field)
		if (field == nil) then
			errorEx('no field passed to write '..paramsToString(field))

			return
		end

		local type = field.type

		local writeFunc = type.writeFunc

		if writeFunc then
			local val = field.val

			if (val == nil) then
				errorEx(string.format('warning: %s has no value to write', field:getFullPath():quote()), true)
			end

			local pos = stream.pos

			writeFunc(stream, val)

			if field.bits then
				writeBits(stream, field, pos)
			end
		end

		return field
	end

	function this:add(name, type, bits, noStreaming)
		checkMethodCaller(self)

		local result

		if (types[type] == nil) then
			local typeName = typeByName[type]

			if (typeName == nil) then
				errorEx('cannot add incorrect type '..paramsToString(name, type))

				return
			else
				type = typeName
			end
		end

		if (noStreaming == true) then
			result = addData(self, name, type, bits)
		else
			if (curMode == MODE_READING) then
				result = addData(self, name, type, bits)

				read(curStream, result)
			elseif (curMode == MODE_WRITING) then
				result = self:getSub(name)

				write(curStream, result)
			else
				result = addData(self, name, type, bits)
			end
		end

		return result
	end

	function this:addNode(name)
		checkMethodCaller(self)

		if (name == nil) then
			errorEx('addNode - no name passed')

			return
		end

		if (curMode == MODE_WRITING) then
			local result = self:getSub(name)

			return result
		end

		local parent = self
		local sub = {
			name = name,
			parent = parent,

			add = this.add,
			addNode = this.addNode,
			clear = this.clear,
			rename = this.rename,
			getSub = this.getSub,
			getVal = this.getValFromNode,
			setVal = this.setValFromNode,
			getFullPath = this.getFullPath,
			print = this.print,
			readFromFile = this.readFromFile,
			writeToFile = this.writeToFile,

			subs = {},
			subsCount = 0,
			subsByName = {}
		}

		parent.subsCount = parent.subsCount + 1
		parent.subs[parent.subsCount] = sub
		parent.subsByName[name] = sub

		return sub
	end

	function this:rename(name)
		checkMethodCaller(self)

		if (name == nil) then
			errorEx('rename - no name passed')

			return
		end

		local parent = self.parent

		if (parent == nil) then
			self.name = name

			return
		end

		parent.subsByName[self.name] = nil

		parent.subsByName[name] = self

		self.name = name
	end

	function this:print(firstArg)
		checkMethodCaller(self)

		if ((firstArg == nil) or isInt(firstArg)) then
			local maxBeforePause = firstArg
			local maxBeforePauseC = 1

			local function printSubs(parent, nestDepth)
				local function writeLine(s)
					print(rep('\t', nestDepth)..s)
				end

				if parent.subs then
					for i = 1, parent.subsCount, 1 do
						local sub = parent.subs[i]

						if (maxBeforePauseC == maxBeforePause) then
							maxBeforePauseC = 1
							osLib.pause()
							osLib.clearScreen()
						else
							maxBeforePauseC = maxBeforePauseC + 1
						end

						if sub.val then
							writeLine(sub.name..' --> '..tostring(sub.val))
						else
							writeLine(sub.name)
						end

						printSubs(sub, nestDepth + 1)
					end
				end
			end

			printSubs(self, 0)
		elseif (ntype(firstArg) == 'string') then
			local f = io.open(firstArg, 'w+')

			if (f == nil) then
				errorEx('print - could not write to path '..firstArg:quote())

				return
			end

			local c = 0

			local function countSubs(parent)
				if parent.subs then
					for i = 1, parent.subsCount, 1 do
						c = c + 1

						countSubs(parent.subs[i])
					end
				end
			end

			countSubs(self)

			local loadDisplay = createLoadPercDisplay(c + 1, 'printing values...')
			local t = osLib.createTimer()

			local tmp = {}
			local tmpCount = 0

			local function printSubs(parent, nestDepth)
				local function writeLine(s)
					tmpCount = tmpCount + 1
					tmp[tmpCount] = rep('\t', nestDepth)..s..'\n'
				end

				if parent.subs then
					for i = 1, parent.subsCount, 1 do
						local sub = parent.subs[i]

						if sub.val then
							writeLine(sub.name..' --> '..tostring(sub.val))
						else
							writeLine(sub.name)
						end

						loadDisplay:inc()

						printSubs(sub, nestDepth + 1)
					end
				end
			end

			printSubs(self, 0)

			if (tmpCount > 0) then
				local packSize = 7500

				for i = 1, tmpCount / packSize + 1, 1 do
					f:write(unpack(tmp, (i - 1) * packSize + 1, min(i * packSize, tmpCount)))
				end
			end

			f:close()

			loadDisplay:inc()

			print('printed '..firstArg:quote()..' in '..math.cutFloat(t:getElapsed())..' seconds')
		else
			errorEx('print - first argument must be either integer or string')
		end
	end

	function this:readFromFile(path, maskFunc)
		checkMethodCaller(self)

		self:clear()

		local t = osLib.createTimer()

		if (ntype(maskFunc) ~= 'function') then
			errorEx('reading from file needs a valid mask function '..paramsToString(path, maskFunc))

			return
		end

		local f = io.open(path, 'rb')

		if (f == nil) then
			errorEx(string.format('%s could not be read', path:quote()))

			return
		end

		local stream = createStream()

		curStream = stream

		local inputString = f:read('*a')

		stream.bytesString = inputString

		local inputCount = inputString:len()

		if (inputCount > 0) then
			local packSize = 7997

			stream.bytes = {inputString:byte(1, min(packSize, inputCount))}

			for i = 2, inputCount / packSize + 1, 1 do
				for k,v in pairs({inputString:byte((i - 1) * packSize + 1, min(i * packSize, inputCount))}) do
					stream.bytes[((i - 1) * packSize) + k] = v
				end
			end
		end

		f:close()

		curMode = MODE_READING

		maskFunc(self, curMode.name, stream)

		curMode = nil

		print(string.format('read %s in %s seconds', path:quote(), math.cutFloat(t:getElapsed())))
	end

	function this:writeToFile(path, maskFunc)
		checkMethodCaller(self)

		local t = osLib.createTimer()

		if (ntype(maskFunc) ~= 'function') then
			errorEx('writing to file needs valid mask function '..paramsToString(path, maskFunc))

			return
		end

		local stream = createStream()

		curStream = stream

		curMode = MODE_WRITING

		maskFunc(self, curMode.name, stream)

		curMode = nil

		local f = io.open(path, 'wb+')

		if (f == nil) then
			errorEx('cannot write to '..path:quote())

			return
		end

		local outputCount = stream.pos - 1

		if (outputCount > 0) then
			local packSize = 7500

			for i = 1, outputCount / packSize + 1, 1 do
				f:write(string.char(unpack(stream.bytes, (i - 1) * packSize + 1, min(i * packSize, outputCount))))
			end
		end

		f:close()

		print(string.format('wrote %s in %s seconds', path:quote(), math.cutFloat(t:getElapsed())))
	end

	local function include(path)
		local child = io.local_loadfile(path..'.lua')

		if (child == nil) then
			local lookupPaths = package.path:split(";")

			local c = 1

			while ((child == nil) and lookupPaths[c]) do
				print(getFolder(lookupPaths[c])..path..'.lua')
				child = io.local_loadfile(getFolder(lookupPaths[c])..path..'.lua')

				c = c + 1
			end
		end

		assert(child, "cannot include "..path)

		local env = getfenv(child)

		for name, val in pairs(env) do
			env._G[name] = val
		end

		local i = 1

		while true do
			local name, val = debug.getlocal(2, i)

			if (name == nil) then
				break
			end

			if (name:find('(', 1, true) ~= 1) then
				env._G[name] = val
			end

			i = i + 1
		end

		child()

		return child
	end

	include('typeDefinitions')

	local root = {
		scope = this,

		name = 'root',

		add = this.add,
		addNode = this.addNode,
		clear = this.clear,
		getFullPath = this.getFullPath,
		getSub = this.getSub,
		getVal = this.getValFromNode,
		setVal = this.setValFromNode,
		print = this.print,
		readFromFile = this.readFromFile,
		writeToFile = this.writeToFile,

		subs = {},
		subsCount = 0,
		subsByName = {}
	}

	return root, this
end

expose('wc3binaryFile', t)