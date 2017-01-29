-- Creates a parent[key] table if it doesn't exist using base as the value.
-- In any case, the value is inserted into parent[key].
function createAndInsert(parent, key, base, value)
  if not parent[key] then 
    parent[key] = base
  end
  table.insert(parent[key], value)
end

-- Removes duplicate entries from a list.
function removeDuplicates(t)
  local set = {}
  local new = {}
  for k, v in pairs(t) do
    if not set[v] then
      table.insert(new, v)
      set[v] = true
    end
  end
  return new
end

-- Sorts the pairs in the table by their key.
function sortedPairs(t)
  local keys = {}
  for k, v in pairs(t) do 
    table.insert(keys, k) 
  end
  
  -- Sort the keys.
  table.sort(keys)

  -- We return an iterator that iterates over the table entries in order.
  local i = 1
  return function()
    local k = keys[i]
    if k then
      local v = t[k]
      i = i + 1
      return k, v
    end
  end
end
