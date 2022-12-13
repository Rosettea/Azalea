local codes = require 'codes'
local tt = require 'tt'
local View = require 'view'

local List = View:extend()

function List:new()
	List.super:new()
	self.items = {}
	self.selectedIdx = 1
end

function List:addItem(name, callback)
	table.insert(self.items, {
		name = name,
		cb = callback
	})
end

function List:onKeyInput(k)
	if k == codes.keyboard.down then
		self.selectedIdx = math.min(self.selectedIdx + 1, #self.items)
	elseif k == codes.keyboard.up then
		self.selectedIdx = math.max(self.selectedIdx - 1, 1)
	elseif k == codes.keyboard.enter then
		local itm = self.items[self.selectedIdx]
		local cb = itm.cb
		if type(cb) == 'function' then
			cb(itm)
		end
	end
end

function List:draw()
	local yLimit = self.position.y + self.size.y
	local y = self.position.y

	for i = 1, #self.items do
		local itm = self.items[i]

		local name = itm.name
		if #name > self.size.x - 5 then -- account for ellipses with -4
			name = name:sub(0, self.size.x - 5) .. '...'
		end

		tt.write(self.position.x, y, (' '):rep(self.size.x), {})
		tt.write(self.position.x, y, name, {})

		if self.selectedIdx == i then
			tt.write(self.position.x + #name, y, ' <-', {})
		end
		y = y + 1
	end
end

return List
