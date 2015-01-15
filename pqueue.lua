local ti = table.insert
local tr = table.remove

local tr2 = function(t, v)
	for i=1,#t do
		if t[i]==v then
			tr(t, i)
			break
		end
	end
end

return function ()
	local t = {}

	local set = {}
	local r_set = {}
	local keys = {}

	local function addKV(k, v)
       	set[k] = v
		if not r_set[v] then
			ti(keys, v)
			table.sort(keys)
			local k0 = {k}
			r_set[v] = k0
			setmetatable(k0, {
				__mode = 'v'
			})
		else
			ti(r_set[v], k)
		end
	end

	local remove = function(k)
       	local oldV = set[k]
       	local oldRset = r_set[oldV]
       	tr2(oldRset, k)
       	if #oldRset < 1 then
       		tr2(keys, oldV)
			r_set[oldV] = nil
			table.sort(keys)
			set[k] = nil
       	end
	end; t.remove = remove

	t.min = function()
		return r_set[keys[1]] or {}
	end

	t.max = function()
		return r_set[keys[#keys]] or {}
	end

	t.empty = function()
		return #keys < 1
	end

	setmetatable(t, {
		__index = function(t, k)
			local v = set[k]
			if v then
				return v
			else
				return false
			end
		end,
		__newindex = function(t, k, v)
			if not set[k] then
				-- new item
				addKV(k, v)
			else
	        	-- existing item
	        	remove(k)
				addKV(k, v)
			end
		end,
	})

	return t
end
