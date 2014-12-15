if type(utils)~='table' then
	utils = {}
end

utils.stack = function(initialData)
	local t = {}

	local out = {
		push = function(v)
			table.insert(t, v)
		end,
		pop = function()
			return table.remove(t)
		end,
		empty = function()
			return not (#t > 0)
		end,
	}
	if type(initialData)=='table' then
		for _,v in ipairs(initialData) do
			out.push(v)
		end
	elseif type(initialData)~='nil' then
		out.push(initialData)
	end

	return out
end
