--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Settings

Controls and keeps track of user preferences for various engine aspects.
--]]
--------------------------------------------------------------------------------

local settings = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local tprint = require("Dusk.dusk_core.misc.tprint")
local screen = require("Dusk.dusk_core.misc.screen")

local type = type
local tprint_add = tprint.add
local tprint_assert = tprint.assert
local tprint_error = tprint.error

--------------------------------------------------------------------------------
-- Data
--------------------------------------------------------------------------------
local data = {
	dotImpliesTable = true,
	detectMapPath = true,
	
	redrawOnTileExistent = false, -- WARNING: Lowers performance by a large amount!
	enableTwindex = true,
	
	ellipseRadiusMode = "min",
	objTypeRectPointSquare = true,

	spaceAfterEscapedPrefix = false,

	virtualObjectsVisible = true,
	autoGenerateObjectShapes = true,

	enableCamera = true,
	defaultCameraTrackingLevel = 1,
	scaleCameraBoundsToScreen = true,

	enableTileCulling = true,

	-- On object creation
	onPointBased = function(p) p.strokeWidth = 5 p:setStrokeColor(1, 1, 1, 0.5) end,
	onEllipse = function(e) e:setFillColor(0, 0, 0, 0) e.strokeWidth = 5 e:setStrokeColor(1, 1, 1, 0.5) end,
	onImageObj = function(t) end,
	onRect = function(r) r:setFillColor(0, 0, 0, 0) r.strokeWidth = 5 r:setStrokeColor(1, 1, 1, 0.5) end,
	onObj = function(o) end,

	evalVariables = {
		screenWidth = screen.width,
		screenHeight = screen.height
	}
}

local config = {
	dotImpliesTable = "boolean",
	detectMapPath = "boolean",
	redrawOnTileExistent = "boolean",
	enableTwindex = "boolean",
	ellipseRadiusMode = "string",
	objTypeRectPointSquare = "boolean",
	spaceAfterEscapedPrefix = "boolean",
	virtualObjectsVisible = "boolean",
	enableCamera = "boolean",
	defaultCameraTrackingLevel = "number",
	scaleCameraBoundsToScreen = "boolean",
	enableTileCulling = true,
	onPointBased = "function",
	onEllipse = "function",
	onImageObj = "function",
	onRect = "function",
	onObj = "function"
}

--------------------------------------------------------------------------------
-- Set Preference
--------------------------------------------------------------------------------
function settings.set(preferenceName, value)
	tprint_add("Set Preference")

	if not preferenceName or value == nil then tprint_error("Missing one or more arguments to set preference.") end
	if not config[preferenceName] then tprint_error("Unrecognized setting \"" .. preferenceName .. "\".") end
	--local value_type = type(value) if config[preferenceName] ~= value_type then tprint_error("Wrong type for setting \"" .. preferenceName .. "\" (expected " .. config[preferenceName] .. " but got " .. value_type .." instead)") end
	
	data[preferenceName] = value

	tprint_remove()
end

--------------------------------------------------------------------------------
-- Get Preference
--------------------------------------------------------------------------------
function settings.get(preferenceName)
	tprint_assert(preferenceName ~= nil, "No argument passed to get setting.")
	return data[preferenceName] or nil
end

--------------------------------------------------------------------------------
-- Add/Remove Evaluation Variable
--------------------------------------------------------------------------------
function settings.setEvalVariable(varName, value)
	data.evalVariables[varName] = value
end

function settings.removeEvalVariable(varName)
	data.evalVariables[varName] = nil
end

return settings