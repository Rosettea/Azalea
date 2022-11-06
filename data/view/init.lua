local tt = require 'tt'
local Object = require 'object'

local View = Object:extend()

function View:new()
	self.size = {
		w = 0,
		h = 0
	}
	self.pos = {
		x = 0,
		y = 0
	}
end

function View:onKeyInput(key, mod)
end

function View:onTextInput(char, mod)
end

function View:draw()
end

function View:update()
end

function View:paintBackground(color)
	tt.drawRect {
		x1 = self.pos.x, x2 = self.size.w,
		y1 = self.pos.y, y2 = self.size.h,
		color = color
	}
end

return View
