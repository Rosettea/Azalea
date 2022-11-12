local tt = require 'tt'
local Object = require 'object'

local View = Object:extend()

function View:new()
	self.size = {
		x = 0,
		y = 0
	}
	self.position = {
		x = 0,
		y = 0
	}
	self.focusable = true
	self.scrollable = false
end

function View:onKeyInput(key, mod)
end

function View:onTextInput(char, mod)
end

function View:draw()
end

function View:update()
end

function View:canClose()
	return true
end

function View:paintBackground(color)
	tt.drawRect {
		x = self.position.x, w = self.size.x,
		y = self.position.y, h = self.size.y,
		color = color
	}
end

return View
