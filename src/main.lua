require("data/goods")
require("data/productions")
require("util/table")
local inspect = require('lib/inspect')

-- Format for a table entry.
--|-
--|<name>
--|<volume>
--|<price>
--|<sold by>
--|<bought by>
--|<illegal?>
--|<dangerous?>

-- Creates a comma separated string of wiki links 
-- based on the names in the argument list.
local function wikifyNameList(list)
  if list == nil then return "" end
  if next(list) == nil then return "" end

  local str = "[[" .. list[1] .. "]]"
  for k, v in pairs(list) do
    if k ~= 1 then
      str = str .. ", [[" .. v .. "]]"
    end 
  end
  
  return str
end

-- Pulls the factories from the productions file and organizes them by name.
local function extractFactories()
  local factories = {}
  for key, production in pairs(productions) do
    -- We don't want to organize per size, since the size doesn't matter for the input and output goods.
    if (production.factory:find(" ${size}")) then
      production.factory = production.factory:gsub(" ${size}", "")
    end
    
    -- Some factories have a ${good} template that needs to be filled. Luckily, 
    -- almost all factories only produce one good.
    -- TODO: The Ammunition Factory has two names (from two entries in the productions file): 
    --       Ammunition Factory and Ammunition Factory S. We need to reduce this to Ammunition Factory.
    if (production.factory:find("${good}")) then
      production.factory = production.factory:gsub("${good}", production.results[1].name)
    end
    
    local value = {input=production.ingredients, output=production.results, waste=production.garbages}
    createAndInsert(factories, production.factory, {name=production.factory}, value)
  end
  return factories
end

local function printGoodsList(factories)
  local boughtByFactory = {}
  local soldByFactory = {}
  for k1, f in pairs(factories) do
    for k2, v in pairs(f) do
      if k2 ~= "name" then
        for k3, input in pairs(v.input) do
          createAndInsert(boughtByFactory, input.name, {}, f.name)
        end
        for k3, output in pairs(v.output) do
          createAndInsert(soldByFactory, output.name, {}, f.name)
        end
        -- We currently treat the waste as a sold good, since it is basically sold by a station.
        for k3, waste in pairs(v.waste) do
          createAndInsert(soldByFactory, waste.name, {}, f.name)
        end
      end 
    end
  end
  
  local function sortAndClean(t) 
    for k, list in pairs(t) do
      table.sort(list, function(a, b) return a < b end)
      t[k] = removeDuplicates(list)
    end
  end
  
  sortAndClean(boughtByFactory)
  sortAndClean(soldByFactory)

  --print(inspect(boughtByFactory))
  --print(inspect(soldByFactory))
  
  for key, good in sortedPairs(goods) do
    print("|-")
    print("|" .. good.name)
    print("|" .. good.size)
    print("|" .. good.price)
    print("|" .. wikifyNameList(soldByFactory[good.name]))
    print("|" .. wikifyNameList(boughtByFactory[good.name]))
    
    if (good.illegal) then
      print("|yes")
    else 
      print("|no")
    end
    
    if (good.dangerous) then
      print("|yes")
    else 
      print("|no")
    end
  end
end

local function main()
  local factories = extractFactories()
  --print(inspect(factories))
  printGoodsList(factories)
end
main()
