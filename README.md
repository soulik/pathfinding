Maze Generator
==============

Simple maze generator for LuaJIT with Win32 console output.

General usage:
--------------

```lua
local mazeGenerator = require 'maze'
local maze = mazeGenerator {
	width = 50,
	height = 25,
	entry = {x = 2, y = 2},
	exit = {x = 30, y = 4},
	finishOnExit = false,
}

-- iterate over each step of maze generator so you can observe how it's created
for i=1,10000 do
	local result = maze.generate()
	if result == 1 then
		break
	end
end

-- access map cell with {x, y} table
local x,y = 1, 2
local cell = maze.map[{x, y}]

-- unvisited cells return false
local cellType = (type(cell)=='table' and cell.type) or 0

```

Tests:
------

Run a test with (Win32 environment only due console handler):

```
luajit tests/test.lua
```

Screenshots:
------------
![alt text](https://github.com/soulik/maze_generator/raw/master/doc/maze001.png "Sample maze")