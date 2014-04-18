--------------------------------------------------------------------------------
--[[
Dusk Plugin: MapCutter

Allows you to load specific layers as a map, instead of the whole thing.
--]]
--------------------------------------------------------------------------------

local mapcutter = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local dusk = require("Dusk.Dusk")

local table_insert = table.insert

--------------------------------------------------------------------------------
-- Build Map from Layers
--------------------------------------------------------------------------------
function dusk.buildMapFromLayers(filename, layers, base)
	local data = dusk.loadMap(filename, base)

	local newLayers = {}

	for i = 1, #layers do
		table_insert(newLayers, data.layers[i])
	end

	data.layers = newLayers

	return dusk.buildMap(data)
end

return mapcutter