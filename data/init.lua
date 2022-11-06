local lowkey = require 'lowkey'
local threads = {}
local fps = 30
local framestart

dofile 'azalea.lua'

local t = os.clock()
function time()
	return (os.clock() - t)
end

function try(fn, ...)
	local err
	local ok, res = xpcall(fn, function(msg)
		err = msg
	end, ...)
	if ok then
		return true, res
	end
	return false, err
end

function write(...)
  io.stderr:write '\r'
	local va = {...}
	for i = 1, #va do
		io.stderr:write(va[i])
		io.stderr:write ',\t'
	end
	io.stderr:write '\n'
end

function thread(f, weak_ref, ...)
	local key = weak_ref or #threads + 1
	local args = {...}
	local fn = function() return try(f, table.unpack(args)) end
	threads[key] = { cr = coroutine.create(fn), wake = 0 }
end

-- hey lua can we get threads
-- we have threads
-- threads in lua:
local runThreads = coroutine.wrap(function()
  while true do
	local maxTime = 1 / fps - 0.004
	local overtime = false

	for k, thread in pairs(threads) do
	  -- run thread
	  if thread.wake < time() then
		local _, wait = assert(coroutine.resume(thread.cr))
		if coroutine.status(thread.cr) == 'dead' then
		  if type(k) == 'number' then
			table.remove(threads, k)
		  else
			threads[k] = nil
		  end
		elseif wait then
		  thread.wake = time() + wait
		else
		  overtime = true
		end
	  end

	  -- stop running threads if we're about to hit the end of frame
	  if time() - framestart > maxTime then
		coroutine.yield(true)
	  end
	end

	if not overtime then coroutine.yield(false) end
  end
end)

thread(function()
	while true do
		local typ, a, b, c = lowkey.pollEvent()
		write(typ, a, b, c)
		if b then write(string.char(b)) end
		if a == 0x03 then
			lowkey.cleanup()
			os.exit()
		end
	end
end)

function uiLoop()
  while true do
	framestart = time()
	local need_more_work = runThreads()
	local elapsed = time() - framestart
	sleep(math.max(0, 1 / fps - elapsed))
  end
end

uiLoop()
