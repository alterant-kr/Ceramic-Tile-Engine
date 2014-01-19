--------------------------------------------------------------------------------
--[[
Dusk Engine Component: Tile Layer

Builds a tile layer from data.
--]]
--------------------------------------------------------------------------------

local tilelayer = {}

--------------------------------------------------------------------------------
-- Localize
--------------------------------------------------------------------------------
local require = require

local tprint = require("Dusk.dusk_core.misc.tprint")
local screen = require("Dusk.dusk_core.misc.screen")
local lib_twindex = require("Dusk.dusk_core.misc.twindex")
local lib_settings = require("Dusk.dusk_core.misc.settings")
local lib_functions = require("Dusk.dusk_core.misc.functions")

local display_remove = display.remove
local display_newSprite = display.newSprite
local display_newGroup = display.newGroup
local math_abs = math.abs
local math_max = math.max
local math_ceil = math.ceil
local table_maxn = table.maxn
local table_insert = table.insert
local string_len = string.len
local tonumber = tonumber
local pairs = pairs
local unpack = unpack
local type = type
local physics_addBody; if physics and type(physics) == "table" and physics.addBody then physics_addBody = physics.addBody else physics_addBody = function() tprint.error("Physics library was not found on Dusk Engine startup") end end
local fnn = lib_functions.fnn
local spliceTable = lib_functions.spliceTable
local getProperties = lib_functions.getProperties
local addProperties = lib_functions.addProperties
local getXY = lib_functions.getXY
local physicsKeys = {radius = true, isSensor = true, bounce = true, friction = true, density = true, shape = true}

--------------------------------------------------------------------------------
-- Create Layer
--------------------------------------------------------------------------------
function tilelayer.createLayer(mapData, data, dataIndex, tileIndex, imageSheets, imageSheetConfig, tileProperties)
	local props = getProperties(data.properties or {}, "tiles", true)
	local layerName = "Layer #" .. dataIndex .. " - \"" .. data.name .. "\""

	if ( mapData.orientation == "isometric" ) then
		for key,value in pairs(mapData) do print("isometic mapData: ", key,value) end
		for key,value in pairs(data) do print("isometic data: ", key,value) end
		for key,value in pairs(tileProperties) do print("isometic tileProperties: ", key,value) end
		for key,value in pairs(lib_twindex) do print("isometic lib_twindex: ", key,value) end
	end

	local layer = display_newGroup()
	local twindex = lib_twindex.buildTwindex(lib_settings.get("enableTwindex"))
	twindex.loadMatrix(mapData.width, mapData.height, data.data)

	layer._tile = {}
	layer.props = {}

	function layer.tile(x, y) if layer._tile[x] ~= nil and layer._tile[x][y] ~= nil then return layer._tile[x][y] else return nil end end

	------------------------------------------------------------------------------
	-- Draw a Single Tile to the Screen
	------------------------------------------------------------------------------
	function layer._drawTile(x, y)
		tprint.add("Draw Tile (" .. layerName .. ")")
		
		if layer.tile(x, y) == nil then
			local id = ((y - 1) * mapData.width) + x
			local gid = data.data[id]

			tprint.assert(gid <= mapData.highestGID and gid >= 0, "Invalid GID at position [" .. x .. "," .. y .."] (index #" .. id ..") - expected [0 <= GID <= " .. mapData.highestGID .. "] but got " .. gid .. " instead.")
			if gid == 0 then return true end -- Don't draw if the GID is 0 (signifying an empty tile)

			--------------------------------------------------------------------------
			-- Create Tile
			--------------------------------------------------------------------------
			local tileData = tileIndex[gid]
			local sheetIndex = tileData.tilesetIndex
			local tileGID = tileData.gid

			local tile = display_newSprite(imageSheets[sheetIndex], imageSheetConfig[sheetIndex])
				tile:setFrame(tileGID)

				-- Isometric has to be drawed with little tweak from normal by neoroman@alterant.kr on 19/1/2014
				if ( mapData.orientation == "orthogonal" ) then
					tile.x, tile.y = mapData.stats.tileWidth * (x - 0.5), mapData.stats.tileHeight * (y - 0.5)
				elseif ( mapData.orientation == "isometric" ) then
					tile.x, tile.y = mapData.stats.tileWidth * (x * 0.5 - 0.5)
									 + (mapData.stats.width * 0.5) - (y * mapData.stats.tileWidth * 0.5), 
									 mapData.stats.tileHeight * (y * 0.5 - 0.5) 
									 + ( x * mapData.stats.tileHeight * 0.5 );
					print("isometic tilemap: x,y=("..x..","..y..")", tile.x, tile.y)
				end
				tile.xScale, tile.yScale = screen.zoomX, screen.zoomY
			local tileProps

			if tileProperties[sheetIndex][tileGID] then
				tileProps = tileProperties[sheetIndex][tileGID]
			else
				tileProps = {options={nodot={},usedot={}},physics={},object={},props={}}
			end

			--------------------------------------------------------------------------
			-- Add Physics to Tile
			--------------------------------------------------------------------------
			if fnn(tileProps.options.physicsExistent, props.options.physicsExistent) then
				local physicsParameters = {}
				local physicsBodyCount = props.options.physicsBodyCount
				local tpPhysicsBodyCount = fnn(tileProps.options.physicsBodyCount, physicsBodyCount)

				physicsBodyCount = math_max(physicsBodyCount, tpPhysicsBodyCount)

				for i = 1, physicsBodyCount do
					physicsParameters[i] = spliceTable(physicsKeys, tileProps.physics[i] or {}, props.physics[i] or {})
				end

				if physicsBodyCount == 1 then -- Weed out any extra slowdown due to unpack()
					physics_addBody(tile, physicsParameters[1])
				else
					physics_addBody(tile, unpack(physicsParameters))
				end
			end

			--------------------------------------------------------------------------
			-- Add Properties and Add Tile to Layer
			--------------------------------------------------------------------------
			tile.props = {}
		
			addProperties(props, "object", tile)
			addProperties(tileProps, "object", tile)
			addProperties(tileProps, "props", tile.props)

			tile.tileX, tile.tileY = x, y
			if not layer._tile[x] then layer._tile[x] = {} end
			layer._tile[x][y] = tile
			layer:insert(tile)
			if ( mapData.orientation == "orthogonal" ) then
				tile:toBack()
			else
				--local position = "{".. x .. ", ".. y .."}"
				--local aLabel = display.newText(layer, position, tile.x, tile.y, "Arial", 14)
				tile:toFront()
				--aLabel:toFront()
			end
		elseif lib_settings.get("redrawOnTileExistent") then
			layer._eraseTile(x, y)
			layer._drawTile(x, y)
		end

		tprint.remove()
	end

	------------------------------------------------------------------------------
	-- Erase a Single Tile from the Screen
	------------------------------------------------------------------------------
	function layer._eraseTile(x, y)
		if layer.tile(x, y) then
			display_remove(layer._tile[x][y])
			layer._tile[x][y] = nil

			if table_maxn(layer._tile[x]) == 0 then
				layer._tile[x] = nil -- Clear row if no tiles in the row
			end
		end
	end

	------------------------------------------------------------------------------
	-- Redraw a Tile
	------------------------------------------------------------------------------
	function layer._redrawTile(x, y)
		layer._eraseTile(x, y)
		layer._drawTile(x, y)
	end

	------------------------------------------------------------------------------
	-- Edit Section
	------------------------------------------------------------------------------
	function layer._edit(x1, x2, y1, y2, mode)
		local mode = mode or "d"
		local x1 = x1 or 0
		local x2 = x2 or x1
		local y1 = y1 or 0
		local y2 = y2 or y1

		-- "Shortcuts" for cutting down time
		if x1 > x2 then x1, x2 = x2, x1 end; if y1 > y2 then y1, y2 = y2, y1 end
		if x2 < 1 or x1 > mapData.stats.mapWidth then return true end; if y2 < 1 or y1 > mapData.stats.mapHeight then return true end
		if x1 < 1 then x1 = 1 end; if y1 < 1 then y1 = 1 end
		if x2 > mapData.stats.mapWidth then x2 = mapData.stats.mapWidth end; if y2 > mapData.stats.mapHeight then y2 = mapData.stats.mapHeight end

		local distX = math_abs(x2 - x1)
		local distY = math_abs(y2 - y1)
		local func = "seekX"
					
		-- If the Y-distance is over the X-distance, seek in the Y-axis (the longer axis will have more speed gain with a Twindex)
		if distY > distX then func = "seekY" end

		-- Function associated with edit mode
		local layerFunc = "_eraseTile"
		if mode == "d" then layerFunc = "_drawTile" end

		-- Isometric has to be drawed lower first by neoroman@alterant.kr on 19/1/2014
		local oldSeekAlgorithm = lib_twindex.seekAlgorithm
		if ( mapData.orientation == "isometric" ) then
			lib_twindex.seekAlgorithm = "fromLow"
		end

		if func == "seekX" then
			for x = x1, x2 do
				twindex.seekY(x, y1, y2, layer[layerFunc])
			end -- for x = x1, x2
		elseif func == "seekY" then
			for y = y1, y2 do
				twindex.seekX(y, x1, x2, layer[layerFunc])
			end
		end

		-- Isometric has to be drawed lower first by neoroman@alterant.kr on 19/1/2014
		if ( mapData.orientation == "isometric" ) then
			lib_twindex.seekAlgorithm = oldSeekAlgorithm
		end
	end

	------------------------------------------------------------------------------
	-- Draw Section (shortcut)
	------------------------------------------------------------------------------
	function layer.draw(x1, x2, y1, y2)
		return layer._edit(x1, x2, y1, y2, "d")
	end

	------------------------------------------------------------------------------
	-- Erase Section (shortcut)
	------------------------------------------------------------------------------
	function layer.erase(x1, x2, y1, y2)
		return layer._edit(x1, x2, y1, y2, "e")
	end

	------------------------------------------------------------------------------
	-- Tiles to Pixels Conversion
	------------------------------------------------------------------------------
	function layer.tilesToPixels(x, y)
		tprint.add("Convert Tiles to Pixels (" .. layerName .. ")")
		local x, y = getXY(x, y)

		tprint.assert((x ~= nil) and (y ~= nil), "Missing argument(s).")

		x, y = x - 0.5, y - 0.5
		x, y = (x * mapData.stats.tileWidth), (y * mapData.stats.tileHeight)

		tprint.remove()
		return x, y
	end

	------------------------------------------------------------------------------
	-- Pixels to Tiles Conversion
	------------------------------------------------------------------------------
	function layer.pixelsToTiles(x, y)
		tprint.add("Convert Pixels to Tiles (" .. layerName .. ")")
		local x, y = getXY(x, y)

		tprint.assert((x ~= nil) and (y ~= nil), "Missing argument(s).")	--tprint.assert((type(x) == "number") and (type(y) == "number"), "Wrong argument type(s).")
		
		tprint.remove()
		return math_ceil(x / mapData.stats.tileWidth), math_ceil(y / mapData.stats.tileHeight)
	end

	------------------------------------------------------------------------------
	-- Tile by Pixels
	------------------------------------------------------------------------------
	function layer.tileByPixels(x, y)
		local x, y = layer.pixelsToTiles(x, y)
		return layer.tile(x, y)
	end

	------------------------------------------------------------------------------
	-- Get Tiles in Range
	------------------------------------------------------------------------------
	function layer._getTilesInRange(x, y, w, h)
		local t = {}
		for xPos = x, x + w do
			for yPos = y, y + h do
				local tile = layer.tile(xPos, yPos)
				if tile then
					table_insert(t, tile)
				end
			end
		end

		return t
	end

	------------------------------------------------------------------------------
	-- Tile Iterators
	------------------------------------------------------------------------------
	function layer.tilesInRange(x, y, w, h)
		tprint.add("Tiles in Range Iterator")
		tprint.assert((x ~= nil) and (y ~= nil) and (w ~= nil) and (h ~= nil), "Missing argument(s).")
		tprint.remove()

		local tiles = layer._getTilesInRange(x, y, w, h)
		
		local i = 0
		return function()
			i = i + 1
			if tiles[i] then return tiles[i] else return nil end
		end
	end

	function layer.tilesInRect(x, y, w, h)
		tprint.add("Tiles in Range Iterator")
		tprint.assert((x ~= nil) and (y ~= nil) and (w ~= nil) and (h ~= nil), "Missing argument(s).")
		tprint.remove()

		local tiles = layer._getTilesInRange(x - w, y - h, w * 2, h * 2)

		local i = 0
		return function()
			i = i + 1
			if tiles[i] then return tiles[i] else return nil end
		end
	end

	------------------------------------------------------------------------------
	-- Destroy Layer
	------------------------------------------------------------------------------
	function layer.destroy()
		twindex = nil
		display.remove(layer)
		layer = nil
	end

	------------------------------------------------------------------------------
	-- Finish Up
	------------------------------------------------------------------------------
	addProperties(props, "props", layer.props)
	addProperties(props, "layer", layer)

	return layer
end

return tilelayer