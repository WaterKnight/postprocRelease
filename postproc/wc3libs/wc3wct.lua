require 'waterlua'

local t = {}

local function create()
	local this = {}

	function this:setHeaderComment(text)
		this.headerComment = text
	end

	function this:setHeaderText(text)
		this.headerText = text
	end

	function this:addTrig()
		local trig = {}

		function trig:setText(text)
			trig.text = text
		end

		return trig
	end

	--format 0
	local function wctMaskFunc_0(root)
		wc3binaryFile.checkFormatVer('wctMaskFunc', 0, root:getVal('format'))

		root:add('trigsCount', 'int')

		for i = 1, root:getVal('trigsCount'), 1 do
			local trig = root:addNode('trig'..i)

			trig:add('size', 'int')

			if (trig:getVal('size') > 0) then
				trig:add('text', 'string')
			end
		end
	end

	--format 1
	local function maskFunc_1(root)
		wc3binaryFile.checkFormatVer('wctMaskFunc', 1, root:getVal('format'))

		root:add('headComment', 'string')

		local trig = root:addNode('headTrig')

		trig:add('size', 'int')

		if (trig:getVal('size') > 0) then
			trig:add('text', 'string')
		end

		root:add('trigsCount', 'int')

		for i = 1, root:getVal('trigsCount'), 1 do
			local trig = root:addNode('trig'..i)

			trig:add('size', 'int')

			if (trig:getVal('size') > 0) then
				trig:add('text', 'string')
			end
		end
	end

	local function maskFunc(root)
		root:add('format', 'int')

		local t = {}

		t[0] = maskFunc_0
		t[1] = maskFunc_1

		local format = root:getVal('format')

		assert(t[format], string.format('unknown format %s', format))

		t[format](root)
	end

	function this:writeToFile(path)
		assert(path, 'no path')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		root:setVal('format', 1)

		root:setVal('headComment', this.headerComment)

		local headTrigNode = this:addNode('headTrig')

		if (this.headerText ~= nil) then
			headTrigNode:setVal('size', this.headerText:len())
			headTrigNode:setVal('text', this.headerText)
		else
			headTrigNode:setVal('size', 0)
		end

		for i = 1, #this.trigs, 1 do
			local trigNode = root:addNode('trig'..i)

			local text = trig.text

			if (text ~= nil) then
				trigNode:setVal('size', text:len())
				trigNode:setVal('text', text)
			else
				trigNode:setVal('size', 0)
			end
		end

		root:writeToFile(path, maskFunc)
	end

	function this:readFromFile(path)
		assert(path, 'no path')

		io.local_require([[wc3binaryFile]])

		local root = wc3binaryFile.create()

		root:readFromFile(path, maskFunc)

		local headTrig = root:getSub('headTrig', true)

		this:setHeaderComment(root:getVal('headerComment', true))
		if (headTrig ~= nil) then
			this:setHeaderText(headTrig:getVal('text', true))
		else
			this:setHeaderText(nil)
		end

		local trigsCount = root:getVal('trigsCount')

		for i = 1, trigsCount, 1 do
			local trigNode = root:getSub('trig'..i)

			local trig = this:addTrig()

			trig:setText(trigNode:getVal('text', true))
		end
	end

	return this
end

t.create = create

expose('wc3wct', t)