-----------------------------------------------------------------------------------------
--
-- gameCredits.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local menu = require("menu")
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

-- Local Variables to make for easier access of dimensions
local centerX = display.contentCenterX 
local centerY = display.contentCenterY
local width = display.contentWidth 
local height = display.contentHeight  


local function onHomeRelease(event)
	composer.gotoScene(event.target.destination, "fade", 500)
end 


function scene:create( event )
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, centerX, centerY, width, height, 12 )
	background:setFillColor(1)
	
	-- Credit Button Settings --
	homeBtn = widget.newButton{
	label = "home",
	labelColor = { default={0.27}, over={1} },
	font = "FuturaLT"

	}
	homeBtn.destination = "menu"
	homeBtn:addEventListener("tap", onHomeRelease)
	homeBtn.x = display.contentWidth * 0.07
	homeBtn.y = display.contentHeight * 0.93
	sceneGroup:insert(homeBtn)


	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newText( "TUTORIAL...", 264, 42, "FuturaLT", 20 )
	titleLogo.x = display.contentWidth * 0.5
	titleLogo.y = 145
	titleLogo:setFillColor(0.27)
	sceneGroup:insert(titleLogo)
	
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
		

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