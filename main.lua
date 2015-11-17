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

parse = require("mod_parse")
parse:init({
	appId = "1bSPpUiWAiMl3LvZXxFe74GjsurSoXJqmBjUFYCs",
	apiKey = "XzfRxdISunDXDiZAE6zaS99VBhe60zG2WyzsIvCz"
	})

parse.showStatus = true
parse:appOpened()

---- Add User to Parse if they are not already present, with tutorialCompleted set to false at first.--------

-- called when an parse is queried for an object
local function onGetObjects( event )
	-- if there are no errors and your deviceID is already in the system
	if not event.error and #event.response.results > 0 then
		-- pretty much do nothing 
	else -- if your device ID is not in the system yet
		-- add device id to a row in the User table
		local dataTable = { ["deviceId"] = system.getInfo("deviceID"), ["completedTutorial"] = false }
		parse:createObject( "User", dataTable, onCreateObject )
	end 
	
end

-- called when a parse object is created within a class
local function onCreateObject( event )
  if not event.error then
    --print( event.response.createdAt )
  end
end
-- SELECT deviceId FROM User WHERE deviceId = system.getInfo("deviceID");
local queryTable = { 
  ["where"] = { ["deviceId"] = system.getInfo("deviceID") }
}
parse:getObjects( "User", queryTable, onGetObjects )

-- how to remove an entire prior scene:
-- remove previous scene's view
		--composer.removeScene( "prevScene")