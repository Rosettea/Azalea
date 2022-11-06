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

return BaseView
