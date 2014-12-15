if type(utils)~='table' then
	utils = {}
end

utils.set = function(initialData)
	local t = {}
	local count = 0

	local out = {
		insert = function(v)
			if type(v)=='table' then
				if type(v.get)=='function' then
					for _, value in pairs(v.get()) do
						if type(t[value])=='nil' then
							t[value] = true
							count = count + 1
						end
					end
				else
					for _, value in pairs(v) do
						if type(t[value])=='nil' then
							t[value] = true
							count = count + 1
						end
					end
	        	end
			else
				t[v] = true
				count = count + 1
			end
		end,
		remove = function(v)
			if type(v)=='table' then
				if type(v.get)=='function' then
					for _, value in pairs(v.get()) do
						t[value] = nil
						count = count - 1
					end
				else
					for _, value in pairs(v) do
						t[value] = nil
						count = count - 1
					end
				end
			else
				t[v] = nil
				count = count - 1
			end
		end,
		get = function()
			local elements = {}
			for k, _ in pairs(t) do
				table.insert(elements, k)
			end
			return elements
		end,
	}
	setmetatable(out, {
		__len = function()
			return count
		end,
		__index = function()
		end,
		__newindex = function()
		end,
	})

	if type(initialData)~='nil' then
		out.insert(initialData)
	end

	return out
end
