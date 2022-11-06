local lowkey = require 'lowkey'
local tt = require 'tt'
local Base = require 'object'

local Screen = Object:extend()

function Screen:new()
	self.activeView = nil
	self.views = {}
end

function Screen:handleEvent()
	local typ, a, b = lowkey.pollEvent()
	if a == 0x03 then -- ctrl c
		lowkey.cleanup()
		os.exit()
	end
end

function Screen:setActiveView(v)
	self.activeView = v
end

function Screen:draw()
	self.node:draw()
	self.update()
	lowkey.update()
end

function Screen:update()
	self.node:update()
end

return Screen
