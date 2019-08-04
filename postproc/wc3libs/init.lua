localDir = debug.getinfo(1, 'S').source:sub(2):match('(.*'..'\\'..')')

local function addPackagePath(path)
	assert(path, 'no path')

	local luaPath = path..'.lua'

	if not package.path:match(luaPath) then
		package.path = package.path..';'..luaPath
	end

	local dllPath = path..'.dll'

	if not package.path:match(dllPath) then
		package.cpath = package.cpath..';'..dllPath
	end
end

addPackagePath(localDir..'?')
addPackagePath(localDir..'?\\init')
addPackagePath(localDir..'?\\?')

require 'slkLib'
require 'portLib'
require 'wc3binaryFile'