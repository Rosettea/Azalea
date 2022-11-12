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
		x = self.position.x, w = math.ceil(self.size.x),
		y = self.position.y, h = math.ceil(self.size.y),
		color = color
	}
end

return View
