local codes = require 'codes'
local lowkey = require 'lowkey'
local tt = require 'tt'
local Object = require 'object'
local Empty = require 'view.empty'

local Screen = Object:extend()

function Screen:new()
	self.activeView = nil
	self.views = {}

	self:addView(Empty())
end

function Screen:handleEvent()
	local typ, a, b = lowkey.pollEvent()
	if typ == 'key' then
		if a == 3 then -- ctrl c
			lowkey.cleanup()
			os.exit()
		end
		if a == codes.keyboard.rune then
			self.activeView:onTextInput(b)
		else
			self.activeView:onKeyInput(a)
		end
	end
end

function Screen:setActiveView(v)
	self.activeView = v
end

function Screen:addView(v)
	table.insert(self.views, #self.views + 1, v)
	self:setActiveView(v)
end

function Screen:draw()
	self:update()
	for i = 1, #self.views do
		self.views[i]:draw()
	end
	lowkey.update()
end

function Screen:update()
	for i = 1, #self.views do
		self.views[i]:update()
	end
end

return Screen
