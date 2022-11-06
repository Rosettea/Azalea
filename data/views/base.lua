local tt = require 'tt'
local Object = require 'object'

local BaseView = Object:extend()

function BaseView:new()
	self.size = {
		w = 0,
		h = 0
	}
	self.pos = {
		x = 0,
		y = 0
	}
end

function BaseView:onKeyInput(key, mod)
end

function BaseView:onTextInput(char, mod)
end

function BaseView:draw()
end

function BaseView:update()
end

function BaseView:paintBackground(color)
	tt.drawRect {
		x1 = self.pos.x, x2 = self.size.w,
		y1 = self.pos.y, y2 = self.size.h,
		color = color
	}
end

return BaseView
