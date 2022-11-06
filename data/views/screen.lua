local lowkey = require 'lowkey'
local tt = require 'tt'
local Object = require 'object'
local Empty = require 'views.empty'

local Screen = Object:extend()

function Screen:new()
	self.activeView = nil
	self.views = {}
end

function Screen:handleEvent()
	local typ, a, b = lowkey.pollEvent()
	if typ == 'key' then
		if a == 3 then -- ctrl c
			lowkey.cleanup()
			os.exit()
		end
		if a == 256 then
			self.activeView:onTextInput(b)
		else
			self.activeView:onKeyInput(a)
		end
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
