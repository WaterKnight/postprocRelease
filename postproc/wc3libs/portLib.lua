require 'waterlua'

local configPath = io.toAbsPath('portLib.conf', io.local_dir())

local config = configParser.create()

config:readFromFile(configPath)

assert(config, 'cannot open '..tostring(configPath))

local mpqeditorPath = config.assignments['mpqeditorPath']

assert(mpqeditorPath, 'no mpqeditorPath in '..tostring(configPath))

mpqeditorPath = io.toAbsPath(mpqeditorPath, io.local_dir())

local scriptPath = io.toAbsPath('portDataScript.txt', io.local_dir())

local tempDir = io.toFolderPath(io.local_dir()..'temp')

local getSizeDir = tempDir..[[_getSize\]]

io.createDir(tempDir)

local t = {}

local function exec(lines)
	local f = io.open(scriptPath, 'w+')

	for k, v in pairs(lines) do
		lines[k] = tostring(v):gsub([[\\]], [[\]])
	end

	table.write(f, lines)

	f:close()

	local ret, errorMsg, outMsg

	if (osLib.runProg('java -version2', '')) then
		ret, errorMsg, outMsg = osLib.runProg('java -jar', io.toAbsPath('jmpq.jar', io.local_dir()), {scriptPath})
	else
		ret, errorMsg, outMsg = osLib.runProg(nil, mpqeditorPath, {scriptPath}, {'console'})
	end

	if not ret then
		if (errorMsg ~= nil) then
			error('could not run '..tostring(mpqeditorPath)..': '..errorMsg)
		end

		error(errorMsg)
	end
end

local function mpqGetSize(mpqPath)
	assert(mpqPath, 'no mpqPath')

	io.removeDir(getSizeDir)
	io.createDir(getSizeDir)

	local lines = {}

	lines[#lines + 1] = [[e %s * ]]..getSizeDir:quote()..[[ /fp]]

	for i = 1, #lines, 1 do
		lines[i] = string.format(lines[i], mpqPath:quote())
	end

	exec(lines)

	return #io.getFiles(getSizeDir, '*')
end

t.mpqGetSize = mpqGetSize

local function createMpqPort()
	local this = {}

	this.deletes = {}
	this.listfiles = {}
	this.listedFiles = {}
	this.listfilePath = (io.local_dir()..[[listfile.txt]])
	this.extracts = {}
	this.imports = {}

	function this:addLine(line)
		this.lines[#this.lines + 1] = line
	end

	function this:addDelete(path)
		assert(path, 'no path')

		this.deletes = {path = path}
	end

	function this:addImport(sourcePath, targetPath)
		assert(sourcePath, 'source path')
		assert(targetPath, 'target path')

		sourcePath = io.toAbsPath(sourcePath)

		this.imports[#this.imports + 1] = {sourcePath = sourcePath, targetPath = targetPath}
	end

	function this:addExtract(sourcePaths, targetPath)
		assert(sourcePaths, 'no sourcePaths')
		assert(targetPath, 'no targetPath')

		targetPath = io.toAbsPath(targetPath)

		local targetFolder = getFolder(targetPath)

		sourcePaths = totable(sourcePaths)

		for i = 1, #sourcePaths, 1 do
			local sourcePath = sourcePaths[i]

			this.listedFiles[#this.listedFiles + 1] = sourcePath

			this.extracts[#this.extracts + 1] = {sourcePath = sourcePath, targetFolder = targetFolder, targetPath = targetFolder..sourcePath, actualTargetPath = targetPath}
		end
	end

	function this:addListfile(path)
		this.listfiles[#this.listfiles + 1] = path
	end

	function this:commit(mpqPaths)
		assert(mpqPaths, 'no paths')

		mpqPaths = totable(mpqPaths)

		if ((#this.deletes > 0) or (#this.imports > 0)) then
			local lines = {}

			for i = 1, #this.deletes, 1 do
				local delPath = io.local_dir()..[[del.txt]]

				lines[#lines + 1] = string.format([[n %s]], delPath:quote())
				lines[#lines + 1] = string.format([[a %s %s]], '%s', delPath:quote(), path:quote())
				lines[#lines + 1] = string.format([[d %s]], path:quote())
			end

			for i = 1, #this.imports, 1 do
				local imp = this.imports[i]

				lines[#lines + 1] = string.format([[a %s %s %s]], '%s', imp.sourcePath:quote(), imp.targetPath:quote())
			end

			local size = math.log(mpqGetSize(mpqPaths[1])) / math.log(2)

			if (size > math.floor(size)) then
				size = size + 1
			end

			size = math.pow(2, math.floor(size))

			if (size < 0x4) then
				size = 0x4
			end

			local sizeHex = string.format('0x%x', size)

			lines[#lines + 1] = [[htsize %s ]]..sizeHex
			lines[#lines + 1] = [[compact %s]]

			if io.pathIsLocked(mpqPaths[1]) then
				local tempPath = tempDir..getFileName(mpqPaths[1])

				io.copyFileIfNewer(mpqPaths[1], tempPath)

				mpqPaths[1] = tempPath
			end

			for i = 1, #lines, 1 do
				lines[i] = string.format(lines[i], mpqPaths[1]:quote())
			end

			exec(lines)
		end

		local function getRemainingExtractions(source)
			local t = {}

			for i = 1, #source, 1 do
				local ext = source[i]

				--if not io.pathExists(ext.targetPath) then
				if not io.pathExists(tempDir..ext.sourcePath) then
					t[#t + 1] = ext
				end
			end

			return t
		end

		local openLine = [[o %s]]

		if (#this.listedFiles > 0) then
			openLine = string.format([[o %s %s]], '%s', this.listfilePath:quote())

			local listfile = io.open(this.listfilePath, "w+")

			listfile:write(table.concat(this.listedFiles, '\n'))

			for _, path in pairs(this.listfiles) do
				local f = io.open(path, 'rb')

				if f then
					listfile:write('\n', f:read('*a'), '\n')

					f:close()
				end
			end

			listfile:close()
		end

		for i = 1, #this.extracts, 1 do
			io.createDir(this.extracts[i].targetFolder)
		end

		local c = 1
		local remainingExtractions = this.extracts

		while ((c <= #mpqPaths) and (#remainingExtractions > 0)) do
			local lines = {}

			lines[#lines + 1] = openLine

			for i = 1, #remainingExtractions, 1 do
				local ext = remainingExtractions[i]

				lines[#lines + 1] = [[e %s ]]..ext.sourcePath:quote()..[[ ]]..tempDir:quote()..[[ /fp]]
			end

			if io.pathIsLocked(mpqPaths[c]) then
				local tempPath = tempDir..getFileName(mpqPaths[c])

				io.copyFileIfNewer(mpqPaths[c], tempPath)

				mpqPaths[c] = tempPath
			end

			for i = 1, #lines, 1 do
				lines[i] = string.format(lines[i], mpqPaths[c]:quote())
			end

			exec(lines)

			remainingExtractions = getRemainingExtractions(remainingExtractions)

			c = c + 1
		end

		for i = 1, #this.extracts, 1 do
			local ext = this.extracts[i]

			--io.moveFile(ext.targetFolder..ext.sourcePath, ext.actualTargetPath)
			io.moveFile(tempDir..ext.sourcePath, ext.actualTargetPath)
		end
	end

	return this
end

t.createMpqPort = createMpqPort

local function mpqExtract(mpqPaths, sourcePaths, targetPath)
	assert(mpqPaths, 'no mpqPaths')
	assert(sourcePaths, 'no sourcePaths')
	assert(targetPath, 'no targetPath')

	local newPort = createMpqPort()

	newPort:addExtract(sourcePaths, targetPath)

	newPort:commit(mpqPaths)
end

t.mpqExtract = mpqExtract

local function mpqImport(mpqPaths, sourcePaths, targetPath)
	assert(mpqPaths, 'no mpqPaths')
	assert(sourcePaths, 'no sourcePaths')
	assert(targetPath, 'no targetPath')

	local newPort = createMpqPort()

	newPort:addImport(sourcePaths, targetPath)

	newPort:commit(mpqPaths)
end

t.mpqImport = mpqImport

local function mpqGetWc3Paths(wc3path)
	assert(wc3path, 'no wc3path')

	wc3path = io.toFolderPath(wc3path)

	return wc3path..'War3Patch.mpq', wc3path..'War3x.mpq', wc3path..'war3.mpq'
end

t.mpqGetWc3Paths = mpqGetWc3Paths

local function mpqExtractLatest(mpqPath, sourcePath, targetPath, wc3path)
	mpqPath = mpqPath or {}

	assert(sourcePath, 'no sourcePath')
	assert(targetPath, 'no targetPath')

	mpqPath = totable(mpqPath)

	--local wc3path = io.getGlobal('wc3path')

	assert(wc3path, 'no wc3path')

	wc3path = io.toFolderPath(wc3path)

	mpqGetWc3Paths(wc3path)

	for _, path in pairs({mpqGetWc3Paths(wc3path)}) do
		table.insert(mpqPath, path)
	end

	mpqExtract(mpqPath, sourcePath, targetPath)
end

t.mpqExtractLatest = mpqExtractLatest

local function mpqExtractAll(mpqPath, targetPath)
	assert(mpqPath, 'no mpqPath')
	assert(targetPath, 'no targetPath')

	targetPath = io.toFolderPath(targetPath)

	mpqExtract(mpqPath, '(listfile)', tempDir)

	local listfileTargetPath = tempDir..'(listfile)'

	local f = io.open(listfileTargetPath)

	assert(f, 'could not open '..listfileTargetPath)

	local paths = {}

	for line in f:lines() do
		if line:match('.+') then
			paths[#paths + 1] = line
		end
	end

	f:close()

	local port = createMpqPort()

	for i = 1, #paths, 1 do
		port:addExtract(paths[i], targetPath..paths[i])
	end

	port:commit(mpqPath)
end

t.mpqExtractAll = mpqExtractAll

local function mpqImportAll(mpqPath, sourcePath)
	assert(mpqPath, 'no mpqPath')
	assert(sourcePath, 'no sourcePath')

	sourcePath = io.toFolderPath(sourcePath)

	local paths = io.getFiles(sourcePath)

	local port = createMpqPort()

	for i = 1, #paths, 1 do
		port:addImport(paths[i], paths[i]:sub(sourcePath:len() + 1))
	end

	port:commit(mpqPath)
end

t.mpqImportAll = mpqImportAll

expose('portLib', t)