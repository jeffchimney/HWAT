-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "composer" module
local composer = require "composer"

-- load menu screen
composer.gotoScene( "menu" )

-- retrieve the ID of the device being used
_G.DEVICE_ID = system.getInfo("deviceID") 

-- Store the users device id temporarily, set to global to be used across scenes
_G.ID_DATA = {}

-- Set the first index to the device_id
ID_DATA[1] = DEVICE_ID

print ("Testing ID retrieve:")
print(ID_DATA[1])

-- how to remove an entire prior scene:
-- remove previous scene's view
		--composer.removeScene( "prevScene")
