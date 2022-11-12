-- almost entirely copied from lite

local tt = require 'tt'
local Empty = require 'view.empty'
local Object = require 'object'

local Node = Object:extend()

function Node:new(type)
	self.type = type or 'leaf'
	self.position = {
		x = 0,
		y = 0
	}
	self.size = {
		x = 0,
		y = 0
	}
	self.views = {}
	if self.type == 'leaf' then
		self:addView(Empty())
	end
end

function Node:propagate(fn, ...)
	self.a[fn](self.a, ...)
	self.b[fn](self.b, ...)
end

function Node:consume(node)
	for k, _ in pairs(self) do self[k] = nil end
	for k, v in pairs(node) do self[k] = v   end
end

local directionMap = {
	up = 'vsplit',
	down = 'vsplit',
	left = 'hsplit',
	right = 'hsplit'
}

function Node:split(dir, view, locked)
	assert(self.type == 'leaf', 'tried to split non-leaf node')
	local type = assert(directionMap[dir], 'invalid direction')
	local child = Node()
	child:consume(self)
	self:consume(Node(type))
	self.a = child
	self.b = Node()
	self.b.locked = locked
	if view then self.b:addView(view) end
	if not self.b.activeView.focusable then
		self.a:setActiveView(self.a.activeView)
	end
	if dir == 'up' or dir == 'left' then
		self.a, self.b = self.b, self.a
	end
	return child
end

function Node:closeActiveView(root)
	if not self.activeView:canClose() then return end
	if #self.views > 1 then
		local idx = self:viewIndex(self.activeView)
		table.remove(self.views, idx)
		self:setActiveView(self.views[idx] or self.views[#self.views])
	else
		local parent = self:getParentNode(root)
		local other = parent[parent.a == self and 'b' or 'a']
		if other:getLockedSize() then
			self.views = {}
			self:addView(Empty())
		else
			parent:consume(other)
			parent:setActiveView(parent.activeView)
		end
	end
end

function Node:addView(view)
	assert(self.type == 'leaf', 'tried to add view to non-leaf node')
	if self.views[1] and self.views[1]:is(Empty) then
		table.remove(self.views)
	end
	table.insert(self.views, view)
	self:setActiveView(view)
end

function Node:setActiveView(v)
	self.activeView = v
	setActiveView(v)
end

function Node:viewIndex(view)
	for i, v in ipairs(self.views) do
		if v == view then return i end
	end
end

function Node:getNodeFromView(view)
	for _, v in ipairs(self.views) do
		if v == view then return self end
	end
	if self.type ~= 'leaf' then
		return self.a:getNodeFromView(view) or self.b:getNodeFromView(view)
	end
end

function Node:getParentNode(root)
	if root.a == self or root.b == self then
		return root
	elseif root.type ~= 'leaf' then
		return self:getParentNode(root.a) or self:getParentNode(root.b)
	end
end

function Node:children(t)
	t = t or {}
	for _, view in ipairs(self.views) do
		table.insert(t, view)
	end
	if self.a then self.a:children(t) end
	if self.b then self.b:children(t) end
	return t
end

function Node:get_child_overlapping_point(x, y)
	local child
	if self.type == 'leaf' then
		return self
	elseif self.type == 'hsplit' then
		child = (x < self.b.position.x) and self.a or self.b
	elseif self.type == 'vsplit' then
		child = (y < self.b.position.y) and self.a or self.b
	end
	return child:get_child_overlapping_point(x, y)
end

function Node:getLockedSize()
	if self.type == 'leaf' then
		if self.locked then
			local size = self.activeView.size
			return size.x, size.y
		end
	else
		local x1, y1 = self.a:getLockedSize()
		local x2, y2 = self.b:getLockedSize()
		if x1 and x2 then
			return x1 + x2, y1 + y2
		end
	end
end

local function copyPosAndSize(dst, src)
	dst.position.x, dst.position.y = src.position.x, src.position.y
	dst.size.x, dst.size.y = src.size.x, src.size.y
end

-- calculating the sizes is the same for hsplits and vsplits, except the x/y
-- axis are swapped; this function lets us use the same code for both
local function calculateSplits(self, x, y, x1, x2)
	local n
	local ds = (x1 == 0 or x2 == 0) and 0 or 1
	if x1 then
		n = math.floor(x1 + ds)
	elseif x2 then
		n = math.floor(self.size[x] - x2)
	else
		n = math.floor(self.size[x])
	end
	self.a.position[x] = self.position[x]
	self.a.position[y] = self.position[y]
	self.a.size[x] = n - ds
	self.a.size[y] = self.size[y]
	self.b.position[x] = self.position[x] + n
	self.b.position[y] = self.position[y]
	self.b.size[x] = self.size[x] - n
	self.b.size[y] = self.size[y]
end

function Node:updateLayout()
	if self.type == 'leaf' then
		local av = self.activeView
		copyPosAndSize(av, self)
	else
		local x1, y1 = self.a:getLockedSize()
		local x2, y2 = self.b:getLockedSize()
		if self.type == 'hsplit' then
			calculateSplits(self, 'x', 'y', x1, x2)
		elseif self.type == 'vsplit' then
			calculateSplits(self, 'y', 'x', y1, y2)
		end
		self.a:updateLayout()
		self.b:updateLayout()
	end
end

function Node:update()
	if self.type == 'leaf' then
		for _, view in ipairs(self.views) do view:update() end
	else
		self.a:update()
		self.b:update()
	end
end

function Node:draw()
	if self.type == 'leaf' then
		self.activeView:draw()
	else
		self:propagate('draw')
	end
end

return Node
