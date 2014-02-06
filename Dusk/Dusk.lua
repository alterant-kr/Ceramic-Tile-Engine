--------------------------------------------------------------------------------
--[[
Dusk Engine

The main Dusk library.
--]]
--------------------------------------------------------------------------------

local dusk = {}

--------------------------------------------------------------------------------
-- Include Libraries and Localize
--------------------------------------------------------------------------------
local require = require

local dusk_core = require("Dusk.dusk_core.core")
local tprint = require("Dusk.dusk_core.misc.tprint")
local screen = require("Dusk.dusk_core.misc.screen")
local lib_settings = require("Dusk.dusk_core.misc.settings")

local type = type
local tprint_add = tprint.add
local tprint_remove = tprint.remove

--------------------------------------------------------------------------------
-- Set/Get Preferences
--------------------------------------------------------------------------------
dusk.setPreference = lib_settings.set
dusk.getPreference = lib_settings.get
dusk.setEvalVariable = lib_settings.setEvalVariable
dusk.removeEvalVariable = lib_settings.removeEvalVariable

--------------------------------------------------------------------------------
-- Load Map
--------------------------------------------------------------------------------
dusk.loadMap = dusk_core.loadMap

--------------------------------------------------------------------------------
-- Build Map
--------------------------------------------------------------------------------
function dusk.buildMap(filename, base)
	tprint_add("Build Map")

	local map
	if type(filename) == "string" then
		local data = dusk_core.loadMap(filename, base)
		map = dusk_core.buildMap(data)
	elseif type(filename) == "table" then
		map = dusk_core.buildMap(filename)
	end
	map.updateView()

	tprint_remove()
	tprint_add("Run Map")

	return map
end

return dusk