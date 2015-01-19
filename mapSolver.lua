local bit = require 'bit'
local pqueue = require 'pqueue'

local function dprint(fmt, ...)
	local f = io.open('debug.log','a')
	if f then
		if #({...}) > 0 then
			f:write(fmt:format(...))
		else
			f:write(fmt)
		end 
		f:write("\n")
		f:close()
	end
end

return function(map)
	local solver = {}
	local mapCells = map.map

	local solve = function(startingPoint, exitPoint)
		local start = startingPoint or {map.entry.x, map.entry.y}
		local goal = exitPoint or {map.exit.x, map.exit.y}

		return coroutine.wrap(function()
            local pEq = function(p0, p1)
            	return (p0[1] == p1[1]) and (p0[2] == p1[2])
            end

			local function cantorPair(k1, k2)
				return 0.5 * (k1 + k2) * ((k1 + k2) + 1) + k2
			end

			local cellCache = {}

			local function queryCell(p)
				local cp = cantorPair(p[1], p[2])
				local cell = cellCache[cp]
				if not cell then
					cell = p
					cellCache[cp] = cell
				end
				return cell
			end

			local function storeCell(...)
				for _, elm in ipairs {...} do
					cellCache[cantorPair(elm[1], elm[2])] = elm
				end
			end

			local directionSet = {
				{0, 1},
				{1, 1},
				{1, 0},
				{1, -1},
				{0, -1},
				{-1, -1},
				{-1, 0},
				{-1, 1},
			}

            local neighbours = function(p0, testFn)
            	return coroutine.wrap(function()
	            	local list = {}
    	        	for _, direction in ipairs(directionSet) do
        	    		local _p1 = {p0[1] + direction[1], p0[2] + direction[2]}
            			if type(testFn)=='function' then
	            			if testFn(_p1) then
			    				coroutine.yield(queryCell(_p1))
	        	    		end
	                	else
		    				coroutine.yield(queryCell(_p1))
	                	end
	            	end
    				coroutine.yield()
        	    end)
        	end

            local function heuristicCostEstimate(p0, p1)
				return math.abs(p0[1] - p1[1]) + math.abs(p0[2] - p1[2])
            end

            local function cost(p0, p1)
				local cell = mapCells[p1]

				if cell == 0 then
					-- wall cost
					return 100
				else
					-- normal step cost
					return 1
				end
            end

            local function reconstructPath(cameFrom, goal)
			    local totalPath = {current}

			    local current = cameFrom[goal]
			    while current do
			        table.insert(totalPath, current)
			        current = cameFrom[current]
			    end
			    return totalPath
            end

			local function findPath()
				local frontier = pqueue()
				local cameFrom = {}
				local costSoFar = {
					[start] = 0,
				}
				frontier[start] = 0
				storeCell(start, goal)

				while not frontier.empty() do
					local current = assert((frontier.min())[1])
					-- current == goal?
					if pEq(current, goal) then
						local path = reconstructPath(cameFrom, goal)
						coroutine.yield(true, path)
						return path
					end
					frontier.remove(current)

					for neighbour in neighbours(current) do
						local newCost = costSoFar[current] + cost(current, neighbour)

						if not costSoFar[neighbour] or (newCost < costSoFar[neighbour]) then
							--dprint(("[%d, %d] - [%d, %d] = %0.4f %0.4f %s"):format(current[1], current[2], neighbour[1], neighbour[2], newCost, costSoFar[neighbour] or -1, tostring(frontier[neighbour])))
							costSoFar[neighbour] = newCost
							frontier[neighbour] = newCost + heuristicCostEstimate(goal, neighbour)
							cameFrom[neighbour] = current
						end
					end
					coroutine.yield(false, current)
				end
				coroutine.yield(true, {})
			end

		    xpcall(findPath, function(msg)
				print(msg)
				print(debug.traceback())
		    end)

			coroutine.yield(true, path)
		end)
	end


	solver.solve = solve
	return solver
end