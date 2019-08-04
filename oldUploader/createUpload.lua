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

local t = {}

local req = {
	host = server,
	user = user,
	password = pw,
	command = string.format('NLST -lR %s*', remoteDir),
	sink = ltn12.sink.table(t)
}

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
				local path

				if (curDir ~= nil) then
					path = curDir..'/'..file
				else
					path = file
				end

				paths[#paths + 1] = path:match('^'..remotePrefix..'(.+)$') or path
			end
		end
	end
end

for _, path in pairs(paths) do
	defFile(path)
end

--collect remote checksums
local t = {}

local req = {
	host = server,
	user = user,
	password = pw,
	path = 'postproc/updater/checksums.txt',
	sink = ltn12.sink.table(t),
	type = 'i'
}

local ret, errMsg = ftp.get(req)

--assert((ret ~= nil), string.format('could not retrieve remote checksums.txt (%s)', errMsg))

if (ret ~= nil) then
	local s = table.concat(t)

	local t = s:split('\n')

	local paths = {}

	for _, line in pairs(t) do
		local checksum, path = line:match('([^%s]+)%s(.+)')

		if ((checksum ~= nil) and (path ~= nil)) then
			local file = defFile(path)

			file.remoteChecksum = checksum
		end
	end
end

--collect local checksums
local localDir = (io.local_dir()..'postproc/')

local localPrefix = localDir:gsub('\\', '/')

local f = io.open(localDir..'updater\\checksums.txt', 'r')

local s = f:read('*a')

f:close()

local t = s:split('\n')

local paths = {}

for _, line in pairs(t) do
	local checksum, path = line:match('([^%s]+)%s(.+)')

	if ((checksum ~= nil) and (path ~= nil)) then
		local file = defFile(path)

		file.localChecksum = checksum
	end
end

--defFile('updater/checksums.txt')

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
		addLine('binary', '\n')
	end
end

addLine(string.format('open %s', server), '\n')
addLine(string.format('user %s %s', user, pw), '\n')
addLine('binary', '\n')

local function removeDir(dir)
	for name, subDir in pairs(dir.dirs) do
		removeDir(subDir)
	end

	for _, file in pairs(dir.files) do
		if (file.localChecksum == nil) then
			print('remove', file.path)
			addLine(string.format('delete %s', string.quote(remotePrefix..file.path)))
			addLine(string.format('rmdir %s', string.quote(remotePrefix..file.path)))
		end
	end

	if (dir.path ~= '') then
		addLine(string.format('rmdir %s', string.quote(remotePrefix..dir.path)))
	end
end

removeDir(root)

local function addDir(dir)
	if (dir.path ~= '') then
		addLine(string.format('mkdir %s', string.quote(remotePrefix..dir.path)))
	end

	for name, subDir in pairs(dir.dirs) do
		addDir(subDir)
	end

	for _, file in pairs(dir.files) do
		if ((file.localChecksum ~= nil) and (file.localChecksum ~= file.remoteChecksum)) then
			print('add', file.path, file.localChecksum, file.remoteChecksum)
			addLine(string.format('put %s %s', string.quote(localPrefix..file.path), string.quote(remotePrefix..file.path)))
		end
	end

	if (dir.path ~= '') then
		addLine(string.format('rmdir %s', string.quote(remotePrefix..dir.path)))
	end
end

addDir(root)

addLine(string.format('put %s %s', string.quote(localPrefix..'updater/checksums.txt'), string.quote(remotePrefix..'updater/checksums.txt')))

addLine('quit')

out:close()

--os.execute(io.local_dir()..'execUploadScript.bat')