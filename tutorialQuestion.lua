local composer = require( "composer" )
local tutorial = require("tutorialGame")
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

-- Local Variables
local centerX = display.contentCenterX -- grab center of X values
local centerY = display.contentCenterY -- grab center of Y values
local width = display.contentWidth -- scale the x-size of the shown overlay
local height = display.contentHeight  -- scale the y-size of the shown overlay

local overlayOptions ={
	isModal = false,
	effect = "fade",
	time = 1000,
	height = 80,
	width = 80
}

_G.questionAnswered = false -- global to determine if the user has answered the question.
							-- This will be used in the tutorialScene so we know to begin the timer again.

local function btnTap(event)
	event.target.xScale = 0.95
	event.target.yScale = 0.95
	composer.gotoScene(event.target.destination, overlayOptions)
	return true
end

local function hideOverlay(event)
	_G.tutorialPaused = false
	_G.physicsTutorialPaused = false
	_G.tutorialHasStarted = true
	_G.questionAnswered = true
	_G.tutorialBoost = true
	timer.resume(_G.coinTimer)
	physics.start()
	composer.hideOverlay("fade", 800)
end 

function catchBackgroundOverlay(event)
	return true
end


function scene:create( event )
	local sceneGroup = self.view
	local Overlay = display.newRect(sceneGroup, centerX, centerY, width, height, 12 )
	Overlay:setFillColor(0.9)
	Overlay.alpha = 0.9
	Overlay.isHitTestable = true
	Overlay:addEventListener("tap", catchBackgroundOverlay)
	Overlay:addEventListener("touch", catchBackgroundOverlay)

	-- Create the button used to minimize the overlay on click
	-- Play Button Settings --
	local trueBtn = widget.newButton{
	    label="",
	    font = "FuturaLT",
	    fontSize = 20,
	    labelColor = { default={0.27}, over={1} },
    	strokeColor = { default={0.27}, over={0.27} },
    	strokeWidth = 3,
    	shape = "roundedRect",
		width=154, height=40,
		onRelease = onPlayBtnRelease
	}
	trueBtn.x = display.contentWidth*0.5
	trueBtn.y = display.contentHeight - 80
	trueBtn:setLabel("If you say so.")

	trueBtn:addEventListener ("tap", hideOverlay)
	sceneGroup:insert(trueBtn)
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newText( "This is where a question will be displayed.\n Answer correctly and you'll be closer to catching evil Kripp!\nSlip back into those pilot pants and we'll continue!", 264, 42, "FuturaLT", 15 )
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