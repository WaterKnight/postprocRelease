local floor = math.floor
local format = string.format
local rep = string.rep
local printRaw = io.write
local log10 = math.log10
local max = math.max
local min = math.min

nerror = error
ntype = type

function error2(s, continue)
	if continue then
		print('error: '..tostring(s))
	else
		nerror('error: '..tostring(s))
	end
end

function limit(val, low, high)
	return max(low, min(val, high))
end

function createLoadPercDisplay(max, title)
	local this = {}

	local curPerc
	local curVal = 0
	local revert = 0

	printRaw(title)

	function this:inc()
		curVal = curVal + 1

		if (curVal >= max) then
			revert = revert + title:len()

			printRaw(rep('\b', revert))
			printRaw(rep(' ', revert))
			printRaw(rep('\b', revert))

			curPerc = nil
			curVal = nil
			revert = nil
		else
			local newPerc = floor(curVal / max * 100)

			if (newPerc ~= curPerc) then
				if curPerc then
					printRaw(rep('\b', revert)..newPerc..'%')
				else
					printRaw(newPerc..'%')
				end

				curPerc = newPerc
				if (newPerc == 0) then
					revert = 2
				else
					revert = floor(log10(newPerc)) + 2
				end
			end
		end
	end

	return this
end