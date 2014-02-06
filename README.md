## Dusk Engine ##

##### Read the quickstart guide [here](http://github.com/GymbylCoding/Dusk-Engine/wiki/Quickstart) #####

The Dusk Engine is a fully featured game engine for [Corona SDK](http://www.coronalabs.com). It's designed to help you "weed out" extra code for level creation and let you focus on the game mechanics, instead of the level makeup.  

It's written on a powerful base, but interfaced with simple, intuitive commands that are easy to learn (when they even exist!). Adding Dusk to your project barely makes a ripple on your code. You can keep all the normal Corona function calls you're used to: `map:scale()`, `layer:insert()`, and the such; you don't have to use separate engine functions to do normal task. Dusk is meant to incorporate seamlessly into your project's flow.

### New in this Version ###

* You can now use `!eval!` in the properties dialog to specify values as math equations: `width    =    !eval! 55 + 6 / (mapWidth * 4)`.
The equation solving algorithm used comes from Syfer, an extensible string math solver written in Lua, with a complete implementation of the [Shunting-Yard algorithm](en.wikipedia.org/wiki/Shunting-yard_algorithm).
	- This is an early version of this feature, and supports a number of variables, but not all that may come. You can currently use these variables in your equations:
    	- `mapWidth`: The width of the map in tiles
        - `mapHeight`: The height of the map in tiles
        - `pixelWidth`: The width of the map in pixels
        - `pixelHeight`: The height of the map in pixels
        - `screenWidth`: The width of the screen
        - `screenHeight`: The height of the screen
        - `tileWidth`: The width of each tile in the map, scaled automatically
        - `tileHeight`: The height of each tile in the map, scaled automatically
        - `rawTileWidth`: The width of each tile in the map, unscaled
        - `rawTileHeight`: The height of each tile in the map, unscaled
        - `scaledTileWidth`: Equivalent to `tileWidth`
        - `scaledTileHeight`: Equivalent to `tileHeight`
* The camera tracking algorithm has been improved for better stability
* Various modifications to improve the engine in speed or other ways have been done
* A new plugin, MapCutter, allows you to only load certain layers of a map
* You can now provide a map in the form of a table to `dusk.buildMap()` to load a map in table format, rather than only maps written to a file (file-based maps are, of course, still supported, and you can build them as usual)
* You can now load a map without actually creating the map object via `dusk.loadMap(filename, base)` - this means you can now load a map from a file, make adjustments to the data itself, and send the data to `dusk.buildMap()` as a table

### What's Here ###

This folder (download the ZIP and unpack) includes...
* The Dusk Engine itself (`Dusk/*`)
* A folder of engine tests (`tests/*`)
* A folder of engine demos (`Demos/*`)
* A tileset I packed from the set by www.kenney.nl (`tilesets/tileset.png` with corresponding @2x version, plus all the tilesets in the `tests` folder)
* A demo map that uses most every feature of Dusk (`everything`, both the JSON and TMX versions)
* A list of things left to be done (`TODO.txt`)
* A folder that will hold plugins (`Plugins/*`)
* Corona/Lua files to run the sample (`main.lua`, `config.lua`, `build.settings`)

### Install ###

The engine itself is found (strangely enough!) in the folder named "Dusk". It's what you'll use for your personal projects. To use Dusk in your project, copy the folder into your project's **root** directory and `require` it like so:
```Lua
local dusk = require("Dusk.Dusk")
```
You won't have to worry about any other files in the Dusk folder, unless you want to take a peek at the code. They're all used internally by the engine itself.