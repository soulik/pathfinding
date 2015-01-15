local bit = require 'bit'
local stack = require 'stack'
local set = require 'set'
local pqueue = require 'pqueue'
local map2D = require 'map2d'

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
            --[[
			function A*(start,goal)
			    closedset := the empty set    // The set of nodes already evaluated.
			    openset := {start}    // The set of tentative nodes to be evaluated, initially containing the start node
			    came_from := the empty map    // The map of navigated nodes.

			    g_score[start] := 0    // Cost from start along best known path.
			    // Estimated total cost from start to goal through y.
			    f_score[start] := g_score[start] + heuristic_cost_estimate(start, goal)

			    while openset is not empty
			        current := the node in openset having the lowest f_score[] value
			        if current = goal
			            return reconstruct_path(came_from, goal)
				
					remove current from openset
			        add current to closedset
			        for each neighbor in neighbor_nodes(current)
			            if neighbor in closedset
			                continue
		    	        tentative_g_score := g_score[current] + dist_between(current,neighbor)

        				if neighbor not in openset or tentative_g_score < g_score[neighbor] 
		            	    came_from[neighbor] := current
		                	g_score[neighbor] := tentative_g_score
			                f_score[neighbor] := g_score[neighbor] + heuristic_cost_estimate(neighbor, goal)
			                if neighbor not in openset
			                    add neighbor to openset
				return failure

			function reconstruct_path(came_from,current)
			    total_path := [current]
			    while current in came_from:
			        current := came_from[current]
			        total_path.append(current)
			    return total_path
            --]]

            --[[
inline int heuristic(SquareGrid::Location a, SquareGrid::Location b) {
  int x1, y1, x2, y2;
  tie (x1, y1) = a;
  tie (x2, y2) = b;
  return abs(x1 - x2) + abs(y1 - y2);
}

template<typename Graph>
void a_star_search
  (Graph graph,
   typename Graph::Location start,
   typename Graph::Location goal,
   unordered_map<typename Graph::Location, typename Graph::Location>& came_from,
   unordered_map<typename Graph::Location, int>& cost_so_far)
{
  typedef typename Graph::Location Location;
  PriorityQueue<Location> frontier;
  frontier.put(start, 0);

  came_from[start] = start;
  cost_so_far[start] = 0;
  
  while (!frontier.empty()) {
    auto current = frontier.get();

    if (current == goal) {
      break;
    }

    for (auto next : graph.neighbors(current)) {
      int new_cost = cost_so_far[current] + graph.cost(current, next);
      if (!cost_so_far.count(next) || new_cost < cost_so_far[next]) {
        cost_so_far[next] = new_cost;
        int priority = new_cost + heuristic(next, goal);
        frontier.put(next, priority);
        came_from[next] = current;
      }
    }
  }
}            
            --]]

            local pEq = function(p0, p1)
            	return (p0[1] == p1[1]) and (p0[2] == p1[2])
            end

            local function distance(p0, p1)
            	local a,b = p1[1]-p0[1], p1[2]-p0[2]
            	return math.sqrt(a*a + b*b)
            end

            local function heuristicCostEstimate(p0, p1)
            	local dist = distance(p0, p1)
            	local dx, dy = (p1[1] - p0[1]), (p1[2] - p0[2])
            	local c = dy/dx
            	local deltaErr = math.abs(c) 
            	local cost = dist
            	local y = p0[2]

            	for x = math.min(p0[1], p1[1]), math.max(p0[1],p1[1]) do
            		y = math.floor(c*x)
            		local p2 = {x, y}
            		local cell = mapCells[p2]

            		if cell then
            			if cell == 0 then
            				cost = cost + 10000
            			end
            		else
            			cost = math.huge
            		end
	       			dprint((">>> [%d, %d] = %d"):format(p2[1], p2[2], tonumber(cell)))
            	end
       			dprint(("([%d, %d] - [%d, %d])(%0.4f, %0.4f) = %0.4f %0.4f"):format(p0[1], p0[2], p1[1], p1[2], a, b, cost, dist))

            	return cost
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

            local function reconstructPath(cameFrom, goal)
			    local totalPath = {current}

			    local current = cameFrom[goal]
			    while current do
			        table.insert(totalPath, current)
			        current = cameFrom[current]
			    end
			    return totalPath
            end

            local function tFn(p)
            	local cell = mapCells[p]
				return cell == 0
            end

			local function findPath()
				local closedSet = set()
				local openSet = pqueue()
				local gScore = {
					[start] = 0,
				}
				openSet[start] = gScore[start] + heuristicCostEstimate(start, goal)
				storeCell(start, goal)

				local cameFrom = {}

				while not openSet.empty() do
					local current = (openSet.min())[1]
					assert(current)

					if pEq(current, goal) then
						local path = reconstructPath(cameFrom, goal)
						coroutine.yield(true, path)
						return path
					end
					openSet.remove(current)
					closedSet[current] = true

					for neighbour in neighbours(current) do
						if closedSet[neighbour] then
							goto continue
						end
						local tentativeGScore = gScore[current] + heuristicCostEstimate(current, neighbour)
						local gScoreNeighbour =  gScore[neighbour]
						local osN = openSet[neighbour]

						if not osN or (tentativeGScore < gScoreNeighbour) then
							dprint(("[%d, %d] - [%d, %d] = %0.4f %0.4f %s %s"):format(current[1], current[2], neighbour[1], neighbour[2], tentativeGScore, gScoreNeighbour or -1, tostring(openSet[neighbour]), tostring(osN)))
							cameFrom[neighbour] = current
							gScore[neighbour] = tentativeGScore
							openSet[neighbour] = tentativeGScore + heuristicCostEstimate(neighbour, goal)
						end
					end
					::continue::
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