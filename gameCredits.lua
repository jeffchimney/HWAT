-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

-- Local Variables
local centerX = display.contentCenterX -- grab center of X values
local centerY = display.contentCenterY -- grab center of Y values
local width = display.contentWidth * 0.75 -- scale the x-size of the shown overlay
local height = display.contentHeight * 0.75 -- scale the y-size of the shown overlay




function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- create/position logo/title image on upper-half of the screen
	--local titleLogo = display.newImageRect( "logo.png", 264, 42 )
	--titleLogo.x = display.contentWidth * 0.5
	--titleLogo.y = 100
	
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	local parent = event.parent -- reference to the menu screen (parent)
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	Overlay = display.newRoundedRect( centerX, centerY, width, height, 12 )
	Overlay:setFillColor(0.9)
	Overlay.alpha = 0.7	

	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
	end	
end


function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase
	local parent = event.phase

	
	if event.phase == "will" then
		
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end



function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene