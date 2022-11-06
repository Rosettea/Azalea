local lowkey = require 'lowkey'
local tt = {}

function tt.drawRect(opts)
	for row = opts.y1, opts.y2 do
		for col = opts.x1, opts.x2 do
			lowkey.paint(col, row, ' ', {
				fg = opts.color,
				bg = opts.color
			})
		end
	end
end

return tt
