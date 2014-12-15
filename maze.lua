require 'set'
require 'stack'
require 'map2d'
local console = require 'console'

function table.find(t, test)
	local out = {}
	if type(test)=='function' then
		for i,v in ipairs(t) do
			if test(v) then
				table.insert(out, i)
			end
		end
	elseif type(test)=='table' then
		for i,v in ipairs(t) do
			for j, v2 in ipairs(test) do
				if v == v2 then
					table.insert(out, i)
					break
				end
			end
		end
	else
		for i,v in ipairs(t) do
			if v==test then
				table.insert(out, i)
			end
		end
	end
	return out
end

local maze = {
	width = 31,
	height = 31,
	map = utils.map2D(0),
	entry = {x = 2, y = 2},
	exit = {x = 30, y = 4},
}

-- prepare a maze
do
	local map = maze.map

	local sx, sy = maze.entry.x, maze.entry.y
	local fx, fy = maze.exit.x, maze.exit.y
	
	--[[
	Direction

		1
	2		3
		4

	Cells
	0 - not visited
	1 - visited empty
	2 - visited wall
	3 - start
	4 - exit
	]]--

	map[{maze.entry.x, maze.entry.y}] = 3
	map[{maze.exit.x, maze.exit.y}] = 4

	local x, y = sx, sy
	local lastDirection = 3

	local function chooseOne(set)
		local r = r or {}
		local t1 = {1, 2, 3, 4}
		local t2 = removeElements(t1, r)
		if #t2>1 then
			return t2[math.random(1, #t2)]
		elseif #t2 == 1 then
			return t2[1]
		else
			return false
		end
	end

	local positionStack = utils.stack()

	local setMap = function(p, v)
		local old = map[p]
		if old == 0 then
			map[p] = v
		end
	end

	local function chooseDirection()
   		local forbidden = utils.set()
   		-- have a look around
   		local v = {
			map[{x, y - 2}],
			map[{x - 2, y}],
			map[{x + 2, y}],
			map[{x, y + 2}]
		}

		-- map dimension limitation
   		if x<=2 then
   			forbidden.insert(2)
   		elseif x>=maze.width-1 then
   			forbidden.insert(3)
   		end
   		
   		if y<=2 then
   			forbidden.insert(1)
   		elseif y>=maze.height-1 then
   			forbidden.insert(4)
   		end

   		-- don't visit already visited cells
		forbidden.insert(table.find(v, function(value)
			return (value ~= 0) and (value ~= 4)
		end))

		local directions = utils.set({1,2,3,4})
		directions.remove(forbidden)

		if #directions > 1 then
			return (directions.get())[math.random(1, #directions)]
		elseif #directions == 1 then
			return (directions.get())[1]
		else
			return false
		end
	end

	local genMaze = coroutine.wrap(function()
		while true do
			local newDirection = chooseDirection()
			
			-- can we move?
			if newDirection then
				positionStack.push({x,y})

				-- connect cells with path and move	
				if newDirection == 1 then
					map[{x, y-1}] = 1
					y = y - 2
				elseif newDirection == 2 then
					map[{x-1, y}] = 1
					x = x - 2
				elseif newDirection == 3 then
					map[{x+1, y}] = 1
					x = x + 2
				elseif newDirection == 4 then
					map[{x, y+1}] = 1
					y = y + 2
				end

				map[{x, y}] = 1
			
				lastDirection = newDirection
			-- if there's no way to go, let's get back
		    elseif not positionStack.empty() then
		    	local pos = positionStack.pop()
		    	x, y = pos[1], pos[2]
				coroutine.yield(2)
		    -- if there's no way to go and there is no solution for this path
			else
				coroutine.yield(2)
		    end

			if x == fx and y == fy then
				break
			end
			coroutine.yield(0)
		end
   		coroutine.yield(1)
	end)

	--[[
	***************** MAIN ***************
	--]]

	math.randomseed(os.time())

	local tt = {
		[0] = {string.char(219),0x0002},
		[1] = {string.char(219),0x0001},
		[2] = {'#',0x0007},
		[3] = {'@',0x000C},
		[4] = {string.char(1),0x000A},
	}

	local con = console.prepare()
	os.execute( "cls" )

	local function drawMaze()
		for y=maze.height,1,-1 do
			for x=1,maze.width do
				local cell = map[{x, y}]
				con.write(x, y, tt[cell][1], tt[cell][2])
			end
		end
	end

	map[{maze.entry.x, maze.entry.y}] = 3
	map[{maze.exit.x, maze.exit.y}] = 4
	for i=1,1000 do
		local result = genMaze()
		if result == 1 then
			break
		elseif result ~= 2 then
			drawMaze()
		end
	end

	map[{maze.entry.x, maze.entry.y}] = 3
	map[{maze.exit.x, maze.exit.y}] = 4

	drawMaze()
end
