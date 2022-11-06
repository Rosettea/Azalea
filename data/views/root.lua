local lowkey = require 'lowkey'
local tt = require 'tt'
local Base = require 'views.base'

local Root = Base:extend()

function Root:new()
	Root.super.new(self)
end

function Root:draw()
	tt.drawRect {
		x1 = self.pos.x,
		x2 = self.size.width,
		y1 = self.pos.y,
		y2 = self.size.height,
		color = {r = 0, g = 0, b = 255}
	}
	self.update()
end

function Root:update()	
	lowkey.update()
end

return Root
