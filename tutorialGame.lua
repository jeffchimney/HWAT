
local composer = require( "composer" )
local menu = require("menu")
local scene = composer.newScene()
local physics = require "physics"
physics.start(); physics.pause()

-- include Corona's "widget" library
local widget = require "widget"

-- Local Variables to make for easier access of dimensions
local centerX = display.contentCenterX 
local centerY = display.contentCenterY
local width = display.contentWidth 
local height = display.contentHeight 
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local physicsPaused
local helicopter
local spriteSheetOptions = {
	width = 100,
	height = 100,
	numFrames = 10
}

-- use this to determine whether or not the game has started
local gameHasStarted = false;


local function onHomeRelease(event)
	composer.gotoScene(event.target.destination, "fade", 500)
end 


function scene:create( event )
	local sceneGroup = self.view

	physicsPaused = false -- pause the physics when initially starting the game
	
	-- create a grey rectangle as the backdrop
	local background1 = display.newImageRect( "scrollingBackground.png", screenW*2, screenH )
	background1.anchorY = 0
	background1.x, background1.y = 0, 0
	sceneGroup:insert(background1)

	local background2 = display.newImageRect( "scrollingBackground.png", screenW*2, screenH )
	background2.anchorY = 0
	background2.x, background2.y = screenW*2, 0
	sceneGroup:insert(background2)

	---------- display an instructions image to show holding up to fly -------	
	local instructions = display.newImageRect("tapInstructions.png", 200,200)
	instructions.anchorX = 0.5
	instructions.anchorY = 0.5
	instructions:setFillColor(0.8)
	instructions.x = display.contentCenterX
	instructions.y = display.contentCenterY
	sceneGroup:insert(instructions)

	---------------------- Section to create the helicopter ------------------------------
	-- make a helicopter (off-screen), position it, and rotate slightly
	helicopter = display.newImageRect( "helicopter.png", 90, 90 )
	helicopter.name = "helicopter"
	helicopter.x, helicopter.y = screenW - screenW * 0.85, screenH/2
	helicopter.rotation = 0
	
	-- set up helicopter collision listeners to pass into helicopterCollision(self,event)
	--helicopter.collision = helicopterCollision
	--helicopter:addEventListener("collision", helicopter)
	
	-- add physics to the helicopter
	physics.addBody( helicopter, { density=1.0, friction=0.3, bounce=0.3 } )
	sceneGroup:insert(helicopter)


	---------------------------- Placement of scrolling forgrounds -----------------------------------------------
	local scrollingForeground1 = display.newImageRect( "grass.png", screenW+5, 82 )
    local scrollingForeground2 = display.newImageRect( "grass.png", screenW+5, 82 )

	scrollingForeground1.anchorX = 0
	scrollingForeground1.anchorY = 1
	scrollingForeground1.x, scrollingForeground1.y = 0, display.contentHeight+display.contentHeight/6
	local scrollingForegroundShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( scrollingForeground1, "static", { friction=0.3, shape=scrollingForegroundShape } )

	scrollingForeground2.anchorX = 0
	scrollingForeground2.anchorY = 1
	scrollingForeground2.x, scrollingForeground2.y = display.contentWidth, display.contentHeight+display.contentHeight/6
	physics.addBody( scrollingForeground2, "static", { friction=0.3, shape=scrollingForegroundShape } )
	
	sceneGroup:insert(scrollingForeground2)
	sceneGroup:insert(scrollingForeground1)

	-- function that be called to spawn a spinning coin, this can be altered to change the position once we include collisions
	local function createCoins()
		-- create a sprite sheet animation for a coin spinning
		local coin_sheet = graphics.newImageSheet("coin.png", spriteSheetOptions)
		-- create the sequence of animations from the coin sheet
		local coin_sequences = {
			name = "spin",
			start = 1,
			count = 10,
			time = 800,
			loopCount = 0,
			loopDirection = "forward"

		}

		local spinningCoin = display.newSprite(coin_sheet, coin_sequences)
		sceneGroup:insert(spinningCoin)
		spinningCoin.x = display.contentCenterX
		spinningCoin.y = display.contentHeight * 0.1
		spinningCoin.xScale = 0.30
		spinningCoin.yScale = 0.30
		spinningCoin:play()
		return spinningCoin
	end

	local function helicopterCollision(self, event)
		print('hello')
	end

	local runtime = 0
	local function getDeltaTime()
		local temp = system.getTimer()
		local dt = (temp-runtime) / (1000/60)
		runtime = temp
		return dt
	end


	-- function used to set the transparency of an object
	local alpha = function(obj)
		obj.alpha = 0
	end
	
	
	-- function called to warn user of boundaries
	local function warnBoundaries()
		local boundariesText = display.newText( "Great Job!\n But don't get too rambunctious...\n Watch out for those boundaries!", 264, 42, "FuturaLT", 15 )
		boundariesText.x = display.contentWidth * 0.7
		boundariesText.y = 150
		boundariesText:setFillColor(0.26)
		sceneGroup:insert(boundariesText)

		local upArrow = display.newImageRect("upArrow.png", 52, 55)
		upArrow.x = display.contentWidth * 0.7
		upArrow.y = display.contentCenterY * 0.35
		sceneGroup:insert(upArrow)

		local downArrow = display.newImageRect("downArrow.png", 52, 55)
		downArrow.x = display.contentWidth * 0.7
		downArrow.y = display.contentHeight * 0.8
		sceneGroup:insert(downArrow)
	
		timer.performWithDelay(transition.to(upArrow, {time = 1000, xScale=1.2, yScale = 1.2, iterations = 7, onComplete=alpha}))
		timer.performWithDelay(transition.to(downArrow, {time = 1000, xScale = 1.2, yScale = 1.2, iterations = 7, onComplete=alpha}))
		timer.performWithDelay(transition.fadeOut(boundariesText, {time=8000}))
	end



	-- method for platform scrolling
	function platformScroll()
		local dt = getDeltaTime()

		if (gameHasStarted) then
			scrollingForeground1:translate( -1*dt, 0 )
			scrollingForeground2:translate( -1*dt, 0 )
			background1:translate( -0.25*dt, 0 )
			background2:translate( -0.25*dt, 0 )
			-- after 5 seconds of flying, warn user to avoid boundaries

			if scrollingForeground1.x <= -display.contentWidth then
		   		scrollingForeground1.x = 0
		   		scrollingForeground2.x = display.contentWidth
			end
	   
			if background1.x <= -display.contentWidth*2 then
		   		background1.x = 0
		   		background2.x = display.contentWidth*2
			end
		end
	end

	Runtime:addEventListener("enterFrame", platformScroll)

	-- move the helicopter while press and hold
	local function flyHelicopter()
		 helicopter:setLinearVelocity(0, -100)
	end

	local firstTouch = true
	-- method to detect whether or not the user has started flying
	local firstTouch = true
	local function isFlying( event )
		-- start physics on first touch
		if firstTouch then
			createCoins()
			physics.start()
			timer.performWithDelay(5000, warnBoundaries, 1)
			firstTouch = false
			transition.fadeOut(instructions, {time=800})
			gameHasStarted = true
		end
		if event.phase == "began" then
			-- resume physics after transition from question
			if physicsIsPaused then
				physics.start()
				physicsPaused = false
			end
			
			helicopter.rotation = -7
			display.getCurrentStage():setFocus( helicopter )
	        helicopter.isFocus = true
			Runtime:addEventListener( "enterFrame", flyHelicopter )
		    elseif helicopter.isFocus then              
		    	if event.phase == "moved" then
		    	elseif event.phase == "ended" then
	        	Runtime:removeEventListener( "enterFrame", flyHelicopter )
            	display.getCurrentStage():setFocus( nil )
   			 	helicopter.isFocus = false
				helicopter.rotation = 2
		    end
		end
	end


	sceneGroup:addEventListener("touch", isFlying)
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	composer.removeScene("menu")
end


function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	

	
	if event.phase == "will" then
		
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.stop()
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