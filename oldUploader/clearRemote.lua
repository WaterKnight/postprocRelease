local function script_path()
	local str = debug.getinfo(2, "S").source:sub(2)

	str = str:gsub('/', '\\')

	local dir = str:match("(.*\\)")

	if (dir == nil) then
		return ''
	end

	return dir
end

package.path = script_path()..'postproc\\updater\\?.lua'..';'..package.path

require 'orient'

local configPath = orient.toAbsPath(script_path())..'postproc\\postproc_getconfigs.lua'

local config = dofile(configPath)

local waterluaPath = orient.toAbsPath(config.assignments['waterlua'], orient.getFolder(configPath))

assert(waterluaPath, 'no waterlua path found')

orient.addPackagePath(waterluaPath)

orient.requireDir(waterluaPath)

require 'configParser'

local loginConfig = configParser.create()

loginConfig:readFromFile(io.local_dir()..'server.txt')

local server = loginConfig.assignments['server']
local user = loginConfig.assignments['user']
local pw = loginConfig.assignments['pw']

print(server, user, pw)

package.path = [[C:\Users\Win7F\Documents\GitHub\postprocAndFriends\postproc\waterlua\luaSocket\lua\socket\?.lua]]..';'..package.path

local root = {}

root.dirs = {}
root.files = {}
root.path = ''

local files = {}

local function defFile(path)
	path = path:gsub('%c', '')

	path = path:gsub('\\', '/')

	if (files[path] ~= nil) then
		return files[path]
	end

	local file = {}

	files[path] = file

	file.path = path

	local dir = io.getFolder(path)

	local curBranch = root

	if (dir ~= nil) then
		dir = dir:match('(.+)[\\/]+$') or dir

		dir = dir:gsub('\\', '/')

		for _, dir in pairs(dir:split('/')) do
			if (dir ~= '.') then
				branch = curBranch.dirs[dir]

				if (branch == nil) then
					branch = {}

					curBranch.dirs[dir] = branch

					branch.dirs = {}
					branch.files = {}

					if (curBranch.path ~= '') then
						branch.path = curBranch.path..'/'..dir
					else
						branch.path = dir
					end
				end

				curBranch = branch
			end
		end
	end

	curBranch.files[#curBranch.files + 1] = file

	return file
end

--collect remote
local remoteDir = 'postproc'

local remotePrefix = remoteDir..'/'

local ftp = require 'socket.ftp'

--local url = 'ftp://inwcfunmap:blubby7@inwcfunmap.bplaced.net'

local searchedDirs = {}

--[[local url = require 'socket.url'

function nlst(u)
    local t = {}
    local p = {}--url.parse(u)
	p.host = 'inwcfunmap.bplaced.net'
	p.user = user
	p.password = pw
    p.command = "nlst"
    p.sink = ltn12.sink.table(t)
	p.path='postproc'
    local r, e = ftp.get(p)
    return r and table.concat(t), e
end

print(nlst(""))]]

local function searchDir(dir)
	if (dir ~= nil) then
		if searchedDirs[dir] then
			return
		end

		searchedDirs[dir] = true
	end

	local t = {}

print('saerch', dir)
	local req = {
		host = server,
		user = user,
		password = pw,
		command = 'NLST',
		path = 'postproc',
		sink = ltn12.sink.table(t)
	}

	if (dir ~= nil) then
		req.path = req.path..'/'..dir
	end

	ftp.get(req)

	local t = table.concat(t):split('\n')

	local curDir
	local paths = {}

	for _, line in pairs(t) do
		line = line:gsub('%c', '')

		if (line ~= nil) then
			local newDir = line:match('^'..remotePrefix..'(.+)%:$')

			if (newDir ~= nil) then
				newDir = newDir:gsub('%.%/', '')

				curDir = newDir
			else
				local pos = line:find('%s.')

				while (pos ~= nil) do
					line = line:sub(pos + 1, line:len())

					pos = line:find('%s.')
				end

				local file = line

				if ((file ~= nil) and file:find('[^%p]')) then
					local path = file

					local longPath = path:match('^'..remotePrefix..'(.+)$')

					if (longPath ~= nil) then
						path = longPath
					else
						if (dir ~= nil) then
							path = dir..'/'..path
						end
					end

					paths[#paths + 1] = longPath or path
--print(line, '->', path, '->', paths[#paths])
				end
			end
		end
	end

	for _, path in pairs(paths) do
		if (dir == nil) then
			defFile(path)

			searchDir(path)
		else
			if (io.getFileName(dir) ~= path) then
			print(path)
				defFile(path)

				if (io.getFileExtension(path) == nil) then
					searchDir(path)
				end
			end
		end
	end
end

searchDir(nil)

--output upload script
local out = io.open(io.local_dir()..'uploadScript.txt', 'w+')

local linesC = 0

local function addLine(...)
	out:write(..., '\n')

	linesC = linesC + 1

	if ((linesC % 250) == 0) then
		addLine('disconnect', '\n')
		addLine(string.format('open %s', server), '\n')
		addLine(string.format('user %s %s', user, pw), '\n')
	end
end

addLine(string.format('open %s', server), '\n')
addLine(string.format('user %s %s', user, pw), '\n')

local function removeDir(dir)
	for name, subDir in pairs(dir.dirs) do
		removeDir(subDir)
	end

	for _, file in pairs(dir.files) do
		addLine(string.format('delete %s', string.quote(remotePrefix..file.path)))
		addLine(string.format('rmdir %s', string.quote(remotePrefix..file.path)))
	end

	if (dir.path ~= '') then
		addLine(string.format('rmdir %s', string.quote(remotePrefix..dir.path)))
	end
end

removeDir(root)

addLine('quit')

out:close()

os.execute(io.local_dir()..'execUploadScript.bat')