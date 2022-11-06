local View = require 'view'

local Empty = View:extend()

function Empty:onTextInput()
	self.no = true
	self:paintBackground {r = 255, b = 0, g = 0}
end

function Empty:draw()
	if self.no then return end
	self:paintBackground {r = 0, b = 0, g = 255}
end

return Empty
