local t = {}

local function create()
	local mdx = {}

	mdx.texs = {}

	local curPos = 1
	local input
	local inputString

	local function fetchId()
		local res = inputString:sub(curPos, curPos + 3)

		curPos = curPos + 4

		return res
	end

	local function fetchUInt32()
		local res = input[curPos + 3] * 256^3 + input[curPos + 2] * 256^2 + input[curPos + 1] * 256^1 + input[curPos] * 256^0

		curPos = curPos + 4

		return res
	end

	local function fetchString(len)
		local res = inputString:sub(curPos, curPos + len - 1)

		curPos = curPos + len

		return res
	end

	local function forward(len)
		curPos = curPos + len
	end

	local function readTexs(size)
		for i = 1, size / 268, 1 do
			local tex = {}

			mdx.texs[#mdx.texs + 1] = tex

			tex.repId = fetchUInt32()
			tex.path = fetchString(260):match('([%w\\%.]+)')
			tex.flags = fetchUInt32()

			tex.hasPath = (tex.path ~= nil)
		end
	end

	function mdx:readFromFile(path)
		assert(path, 'no path')

		local f = io.open(path, 'rb')

		inputString = f:read('*a')

		f:close()

		local inputLen = inputString:len()

		if (inputLen > 0) then
			local packSize = 7997

			input = {inputString:byte(1, math.min(packSize, inputLen))}

			for i = 2, inputLen / packSize + 1, 1 do
				for k,v in pairs({inputString:byte((i - 1) * packSize + 1, math.min(i * packSize, inputLen))}) do
					input[((i - 1) * packSize) + k] = v
				end
			end
		else
			input = {}
		end

		if (fetchId() ~= 'MDLX') then
			error(path..' is not an mdx')
		end

		local c = 1

		while (curPos < inputLen) do
			local tag = fetchId()

			print(string.format("chunk %i: %s", c, tag))

			local size = fetchUInt32()

			if (tag == 'TEXS') then
				readTexs(size)
			else
				forward(size)
			end

			c = c + 1
		end
	end

	return mdx
end

t.create = create

expose('mdxLib', t)