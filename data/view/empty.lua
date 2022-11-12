local View = require 'view'

local Empty = View:extend()

function Empty:draw()
	self:paintBackground {r = 0, b = 0, g = 255}
end

return Empty
