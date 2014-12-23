package.path = '../?.lua;tests/?.lua;'..package.path
local mazeGenerator = require 'maze'
local console = require 'console'
local bit = require 'bit'

do
	local generateMaze = false

	local maze
	math.randomseed(os.time())

	local tt = {
		[0] = {string.char(176),0x0001},	-- a wall
		[1] = {string.char(178),0x0057},	-- an empty cell
		[2] = {'@',0x000C},					-- start point
		[3] = {string.char(1),0x000A},		-- exit point
		[4] = {'*',0x000A},					-- visited exit point
		[5] = {string.char(178),0x003C},	-- backtraced path cell
		[6] = {string.char(177), 0x005F},				-- vertical connection
		[7] = {string.char(177), 0x005F},				-- horizontal connection
	}

	local con = console.prepare()
	os.execute( "cls" )

	local function drawCell(x, y, cellType)
		con.write(x, y, tt[cellType][1], tt[cellType][2])
	end

	--[[
	Connections bit-mask values:
		1
	8	*	2
		4
	Note: Coordinate system starts at bottom-left corner of the screen

	--]]
	local function drawCellConnections(x, y, cell)
		local cellType = (type(cell)=='table' and cell.type) or 0

		if cellType >= 1 then
			local c = cell.connections or 0x00

   			if bit.band(c, 0x01) > 0 then
   				local cPos = {x = 0, y = 1}
   				drawCell(x + cPos.x, y + cPos.y, 6)
   			end
   			if bit.band(c, 0x02) > 0 then
   				local cPos = {x = 1, y = 0}
   				drawCell(x + cPos.x, y + cPos.y, 7)
   			end
   			if bit.band(c, 0x04) > 0 then
   				local cPos = {x = 0, y = -1}
   				drawCell(x + cPos.x, y + cPos.y, 6)
   			end
   			if bit.band(c, 0x08) > 0 then
   				local cPos = {x = -1, y = 0}
   				drawCell(x + cPos.x, y + cPos.y, 7)
 			end
		end
	end

	local function drawMaze()
		for position, cell in maze.iterator() do
			local cellType = (type(cell)=='table' and cell.type) or 0
			local dx, dy = position[1]*2, position[2]*2
			drawCell(dx, dy, cellType)
			drawCellConnections(dx, dy, cell)
		end
	end

	local function loadMaze(fname)
		local f = io.open(fname, 'rb')
		if f then
			local data = f:read('*a')
			f:close()
			maze.load(data)
		end
	end

	local function saveMaze(fname)
		local f = io.open(fname, 'wb')
		if f then
			f:write(maze.save())
			f:close()
		end
	end

	local blindAttempts = 0

    maze = mazeGenerator {
		width = 50,
		height = 25,
		entry = {x = 2, y = 2},
		exit = {x = 30, y = 4},
		finishOnExit = false,
	}

	if not generateMaze then
		loadMaze('maze.bin')
    else
    	for i=1,10000 do
    		local result = maze.generate()
    		if result == 0 then
    			blindAttempts = 0
    		elseif result == 1 then
    			break
    		elseif result == 2 then
    			drawMaze()
    		elseif result == 3 then
    			if blindAttempts>100 then
    				break
    			else
    				blindAttempts = blindAttempts + 1
    			end
    		end
    	end
		saveMaze('maze.bin')
	end
	drawMaze()
end
