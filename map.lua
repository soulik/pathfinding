local serpent = require 'serpent'
local bit = require 'bit'
local stack = require 'stack'
local map2D = require 'map2d'

return function(def)
	local map = def or {}
	map.width = def.width or 31
	map.height = def.height or 31
	map.map = map2D(1)
	map.entry = def.entry or {x = 2, y = 2}
	map.exit = def.exit or {x = 30, y = 4}
	map.finishOnExit = def.finishOnExit or false

	local mapCells = map.map
	local sx, sy = map.entry.x, map.entry.y
	local fx, fy = map.exit.x, map.exit.y

	local positionStack = stack()

	local shapes = {
		['c'] = {
			w = 8, h = 12,
			data = {
				0,0,0,0,0,0,1,1,
				1,1,1,1,0,0,0,1,
				1,1,1,1,1,0,0,0,
				1,1,1,1,1,1,0,0,
				1,1,1,1,1,1,0,0,
				1,1,1,1,1,1,0,0,
				1,1,1,1,1,1,0,0,
				1,1,1,1,1,1,0,0,
				1,1,1,1,1,1,0,0,
				1,1,1,1,1,0,0,0,
				0,0,1,1,0,0,0,1,
				1,0,0,0,0,0,1,1,
			}
		}
	}

	local genMap = coroutine.wrap(function()
		local shape =  shapes['c']
		local data = shape.data
		local offset = {x=12, y=4}

		for y=0,shape.h-1 do
			for x=0,shape.w-1 do
				local pos = {offset.x + x, offset.y + y}
				local v = data[x + y*shape.w + 1]
				mapCells[pos] = v
			end
		end
		coroutine.yield(1)
	end)

	map.iterator = function()
		local co = coroutine.create(function()
			for y=1,map.height do
				for x=1,map.width do
					local position = {x, y}
					coroutine.yield(position, mapCells[position])
				end
			end
			coroutine.yield()
		end)
		return function()
			local code, pos, cell = coroutine.resume(co)
			return pos, cell
		end
	end

	map.load = function(data)
		local r, t =  serpent.load(data)
		if r then
			map.width = t.width
			map.height = t.height
			map.entry = t.entry
			map.exit = t.exit
			map.finishOnExit = t.finishOnExit
			map.map.load(t.map)
		end
	end

	map.save = function()
		return serpent.dump({
			map = map.map.save(),
			width = map.width,
			height = map.height,
			entry = map.entry,
			exit = map.exit,
			finishOnExit = map.finishOnExit,
		})
	end

	map.generate = genMap
	return map
end