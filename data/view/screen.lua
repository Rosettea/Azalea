local codes = require 'codes'
local lowkey = require 'lowkey'
local tt = require 'tt'
local Empty = require 'view.empty'
local Node = require 'node'
local Object = require 'object'

local Screen = Object:extend()

function Screen:new()
	self.node = Node()
	self.size = {
		w = 0,
		h = 0
	}
end

function Screen:getActiveView()
	return activeView
end

function Screen:activeNode()
	local node = self.node:getNodeFromView(activeView)
	return node or self.node
end

function Screen:update()
	self.node.size.x = self.size.w
	self.node.size.y = self.size.h
	self.node:update()
	self.node:updateLayout()
end

function Screen:draw()
	self:update()
	self.node:draw()
	lowkey.update()
end

function Screen:handleEvent()
	local typ, a, b = lowkey.pollEvent()
	if typ == 'key' then
		if a == 3 then -- ctrl c
			lowkey.cleanup()
			os.exit()
		end
		if a == codes.keyboard.rune then
			activeView:onTextInput(b)
		else
			activeView:onKeyInput(a)
		end
	end
end

return Screen
