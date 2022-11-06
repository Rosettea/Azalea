local function iota(tbl, start)
	start = start or 0
	local ntb = {}

	for i = 1, #tbl do
		ntb[tbl[i]] = i + start - 1
	end

	return ntb
end

-- Contains a table of keyboard and mouse codes for use in input events.
local codes = {}

codes.keyboard = iota({
	'rune',
	'up',
	'down'
}, 256)
return codes
