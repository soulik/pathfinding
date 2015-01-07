local bit = require 'bit'
local stack = require 'stack'
local map2D = require 'map2d'

return function(maze)
	local solver = {}
	local map = maze.map

	local solve = function(startingPoint)
		local startingPoint = startingPoint or {maze.entry.x, maze.entry.y}
		local exitPoint = {maze.exit.x, maze.exit.y}
		local currentPosition = startingPoint
		local visitedCells = map2D(false)

		local neighbordLocations = {
			[0] = {0, 1},
			[1] = {1, 0},
			[2] = {0, -1},
			[3] = {-1, 0},
		}

		local function neighbours(position0, fn)
			local neighbours = {}
			local currentCell = map[position0]
			if type(currentCell)=='table' then
				local connections = currentCell.connections
				if type(fn)=="function" then
					for i=0,3 do
						if bit.band(connections, 2^i) >= 1 then
							local neighbourLocation = neighbordLocations[i] 
							local position1 = {position0[1] + neighbourLocation[1], position0[2] + neighbourLocation[2]}
							if (position1[1]>=1 and position1[1] <= maze.width and position1[2]>=1 and position1[2] <= maze.height) then
								local cell = map[position1]
								if fn(cell, position1) then
									table.insert(neighbours, position1)
								end
							end
						end
					end
				end
			else
				print(position0[1], position0[2], currentCell)
			end
			return neighbours
		end

		visitedCells[startingPoint] = true

		return coroutine.wrap(function()
			local path = stack()

			local function checkCell(currentPosition)
				visitedCells[currentPosition] = true
				-- is this an exit?
				if currentPosition[1] == exitPoint[1] and currentPosition[2] == exitPoint[2] then
					--path.push(currentPosition)
					return true, currentPosition
				else
					local possiblePaths = neighbours(currentPosition, function(cell, position)
						return (cell.type >= 1) and (not visitedCells[position])
					end)

					-- is this a dead end?
					if #possiblePaths>0 then
						for _, localPosition in ipairs(possiblePaths) do
							coroutine.yield(false, localPosition)
							local result, possiblePosition = checkCell(localPosition)
							if result then
								path.push(possiblePosition)
								return true, currentPosition
							end
						end
					else
						coroutine.yield(false, 0)
						return false
					end
		    	end
		    end
		    
		    xpcall(checkCell, function(msg)
				print(msg)
				print(debug.traceback())
		    end,currentPosition)

			coroutine.yield(true, path)
		end)
	end


	solver.solve = solve
	return solver
end