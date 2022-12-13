local View = require 'view'

local Progress = View:extend()

function Progress:new()
	Progress.super:new()
	self.size.y = 2
end

function Progress:draw()
	self:paintBackground {
		r = 224, g = 224, b = 224
	}
end

return Progress
