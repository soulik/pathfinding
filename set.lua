﻿return function(defaultValue)
	local t = {}

	--[[
	Cantor pairing function
	\pi(k_1,k_2) := \frac{1}{2}(k_1 + k_2)(k_1 + k_2 + 1)+k_2.
	--]]
	local function primitiveCantorPair(k1, k2)
		return 0.5 * (k1 + k2) * ((k1 + k2) + 1) + k2
	end

	local function generalizedCantorPair(arg)
		if #arg == 2 then
			return primitiveCantorPair(arg[1], arg[2])
		elseif #arg > 2 then
			return primitiveCantorPair(generalizedCantorPair(arg), table.remove(arg))
		else
			error('Cantor pairing function need at least 2 arguments!')
		end
	end

	local function cantorPair(...)
		return generalizedCantorPair({...})
	end

	setmetatable(t, {
		__index = function(_, k)
   			if type(k)=="table" then
   				local i = rawget(t, cantorPair(k[1] or 1, k[2] or 1))
   				return i or defaultValue
   			end
   		end,
   		__newindex = function(_, k, v)
   			if type(k)=="table" then
				rawset(t, cantorPair(k[1] or 1, k[2] or 1), v)
			else
				rawset(t, k, v)
   			end
   		end,
   	})

	return t
end
