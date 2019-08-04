require 'waterlua'

osLib.clearScreen()

local params={...}

io.local_require('wc3binaryFile')
io.local_require('wc3binaryMaskFuncs')

root = wc3binaryFile.create()

root:readFromFile(params[1], infoFileMaskFunc)

root:print("print.txt")