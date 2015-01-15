package.path = '../?.lua;tests/?.lua;'..package.path
local mapGenerator = require 'map'
local mapSolver = require 'mapSolver'
local console = require 'console'
local bit = require 'bit'

do
	local generateMap = true

	local map
	math.randomseed(os.time())

	local tt = {
		[0] = {string.char(219),0x0057},	-- a wall
		[1] = {string.char(177),0x0001},	-- an empty cell
		[2] = {string.char(178),0x000A},	-- an empty cell
	}

	local con = console.prepare()
	os.execute( "cls" )

	local function drawCell(x, y, cellType)
		if tt[cellType] then
			con.write(x, y, tt[cellType][1], tt[cellType][2])
			con.write(x+1, y, tt[cellType][1], tt[cellType][2])
		end
	end

	local function drawMap()
		for position, cell in map.iterator() do
			local cellType = cell or 0
			local dx, dy = position[1], position[2]
			drawCell(dx*2, dy, cellType)
		end
	end

	local function loadMap(fname)
		local f = io.open(fname, 'rb')
		if f then
			local data = f:read('*a')
			f:close()
			map.load(data)
		end
	end

	local function saveMap(fname)
		local f = io.open(fname, 'wb')
		if f then
			f:write(map.save())
			f:close()
		end
	end

	local blindAttempts = 0

    map = mapGenerator {
		width = 25,
		height = 25,
		entry = {x = 15, y = 7},
		exit = {x = 23, y = 10},
		finishOnExit = false,
	}

	if not generateMap then
		loadMap('map.bin')
    else
    	for i=1,10000 do
    		local result = map.generate()
    		if result == 1 then
   				break
   			else
    		end
    	end
		saveMap('map.bin')
	end
	--drawMap()

	local stepsTaken = 0
	local solver = mapSolver(map)
	local solve = solver.solve()
	local validPath

	--local f = io.open('debug.log','w')

	for i=1,10000 do
		local result, p0, p1 = solve()
		if result then
			validPath = p0
			break
		elseif type(p0)=='table' then
			--f:write(("%s [%d, %d]\n"):format(tostring(p1), p0[1], p0[2]))
			--[[
			local cell = maze.map[p0]
			if type(cell)=='table' then
				if cell.type == 3 then
					cell.type = 4
				elseif cell.type == 4 then
				else
					cell.type = 8
				end
			end
			drawMaze()
			]]--
		end
	end

	local mapCells = map.map

	for _, p in ipairs(validPath) do
		mapCells[p] = 2
	end
	
	drawMap()

	print('Steps', #validPath)
end
