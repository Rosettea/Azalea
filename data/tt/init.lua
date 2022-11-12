local lowkey = require 'lowkey'
local tt = {}

function tt.drawRect(opts)
	for row = opts.y, opts.y + opts.h do
		for col = opts.x, opts.x + opts.w do
			lowkey.paint(col, row, ' ', {
				fg = opts.color,
				bg = opts.color
			})
		end
	end
end

return tt
