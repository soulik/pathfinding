A* pathfinding algorithm in Lua
==============

General usage:
--------------

```lua
local mapGenerator = require 'map'
local mapSolver = require 'mapSolver'

local map = mapGenerator {
	width = 25,
	height = 25,
	entry = {x = 15, y = 7},
	exit = {x = 23, y = 11},
}

-- generate a map
map.generate()

-- prepare map pathfinding solver
local solver = mapSolver(map)
local solve = solver.solve()
local validPath

local solver = mapSolver(map)
local solve = solver.solve()

for i=1,10000 do
	local result, p0 = solve()
	if result then
		validPath = p0
		break
	end
end

-- validPath will contain points of path from entry to exit point
```

Tests:
------

Run a test with (Win32 environment only due console handler):

```
luajit tests/test.lua
```

Screenshots:
------------
![alt text](https://github.com/soulik/pathfinding/raw/master/doc/pathfinding0.png "Sample map with pathfinding")