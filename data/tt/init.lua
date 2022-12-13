local lowkey = require 'lowkey'
local tt = {}

function tt.drawRect(opts)
	local color = opts.color
	for row = opts.y, opts.y + opts.h do
		for col = opts.x, opts.x + opts.w do
			lowkey.paint(col, row, ' ', {
				fg = opts.color,
				bg = opts.color
			})
		end
	end
end

function tt.write(x, y, text, color)
	for i = 1, #text do
		local c = text:sub(i, i)
		lowkey.paint(x + i - 1, y, c, {
			fg = color.fg,
			bg = color.bg 
		})
	end
end
return tt
