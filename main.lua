--------------------------------------------------------------------------------
--[[
Dusk Engine
--]]
--------------------------------------------------------------------------------

display.setStatusBar(display.HiddenStatusBar)

local textureFilter = "nearest"
display.setDefault("minTextureFilter", textureFilter)
display.setDefault("magTextureFilter", textureFilter)

require("physics")
physics.start()

local dusk = require("Dusk.Dusk")
require("Plugins.mapcutter")

local map = dusk.buildMapFromLayers("everything.json", {1,2})

map.setTrackingLevel(0.3)

function map.drag(event)
	local viewX, viewY = map.getViewpoint()
	if "began" == event.phase then
		display.getCurrentStage():setFocus(map)
		map.isFocus = true
		map._x, map._y = event.x + viewX, event.y + viewY
	elseif map.isFocus then
		if "moved" == event.phase then
			map.setViewpoint(map._x - event.x, map._y - event.y)
			map.updateView() -- Update the map's camera and culling directly after changing position
		elseif "ended" == event.phase then
			display.getCurrentStage():setFocus(nil)
			map.isFocus = false
		end
	end
end

map:addEventListener("touch", map.drag)
Runtime:addEventListener("enterFrame", map.updateView)

--native.showAlert("Dusk", "Welcome to the Dusk Engine. Check out the demos inside the Demos/ folder. The map loaded on the screen is a very basic map to test various Dusk capabilities.", {"Got it!"})