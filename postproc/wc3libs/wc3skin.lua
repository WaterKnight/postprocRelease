require 'waterlua'

local t = {}

local function create()
	io.local_require([[wc3profile]])

	local profile = module_wc3profile.create()

	return profile
end

t.create = create

expose('wc3skin', t)