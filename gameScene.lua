-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()

--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5
local drKripp
local helicopter
local questionCrates
local physicsIsPaused
local 

local scrollingForeground1 = display.newImageRect( "grass.png", screenW+5, 82 )
local scrollingForeground2 = display.newImageRect( "grass.png", screenW+5, 82 )

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view
	
	--initialize questionCrates
	questionCrates = {}
	physicsIsPaused = false
	
	-- create a grey rectangle as the backdrop
	local background1 = display.newImageRect( "scrollingBackground.png", screenW*2, screenH )
	background1.anchorY = 0
	background1.x, background1.y = 0, 0

	local background2 = display.newImageRect( "scrollingBackground.png", screenW*2, screenH )
	background2.anchorY = 0
	background2.x, background2.y = screenW*2, 0
	
	drKripp = display.newImage("kripplol.png")

	--background:setFillColor( .5 )
	
    -- Function to detect collision (helicopter, event such as foreground collision)
	local function helicopterCollision(self, event)
		-- want to know when the collision starts:
		if event.phase == "began" then
			if event.other.name == "crate" then
				print("Collided with crate")
				-- pull up question screen
				physics.pause()
				physicsIsPaused = true
				showQuestion()
			else 
				print("i am colliding") 
				composer.gotoScene("gameOver")
			end
			--Change functions of this later once we have added in score variables and such:
			--Include game over message/scoreboard
			--Stop incrementing score
			--define types of different collision, ex: with coins, questions
			--Change appearance of helicopter maybe on !!FIRE!! or spinning out of control or dropping off screen
		end
	end

	-- Function to set set up Dr.Kripp
	function setupKripp()
		local xPos = display.contentWidth * 0.80
		physics.addBody(drKripp, "dynamic")
		drKripp.gravityScale = 0
		drKripp.isSensor = true
		drKripp.x = xPos
		drKripp.y = screenH/2
		drKripp.width = 80
		drKripp.height = 80
		sceneGroup:insert(drKripp)
	end
	
	function spawnQuestionCrate()
		local newCrate = display.newImageRect( "crate.png", 10, 10 )
		newCrate.name = "crate"
	
		if drKripp.y >= screenH/2 then
			newCrate.x, newCrate.y = screenW + screenW/5, drKripp.y - screenH/3
		else
			newCrate.x, newCrate.y = screenW + screenW/5, drKripp.y + screenH/3
		end
	
		-- set up crate collision listeners to pass into helicopterCollision(self,event)
		--newCrate.collision = helicopterCollision
		--newCrate:addEventListener("collision", newCrate)

		-- add physics to the helicopter
		physics.addBody( newCrate, { density=1.0, friction=0.3, bounce=0.3 } )
		newCrate.gravityScale = 0
	
		table.insert( questionCrates, newCrate )
		
		sceneGroup:insert(newCrate)
	end
	spawnQuestionCrate()

	scrollingForeground1.type = "gameOver"
	-- make a helicopter (off-screen), position it, and rotate slightly
	helicopter = display.newImageRect( "helicopter.png", 90, 90 )
	helicopter.name = "helicopter"
	helicopter.x, helicopter.y = screenW - screenW * 0.85, screenH/2
	helicopter.rotation = 0
	
	-- set up helicopter collision listeners to pass into helicopterCollision(self,event)
	helicopter.collision = helicopterCollision
	helicopter:addEventListener("collision", helicopter)
	
	-- add physics to the helicopter
	physics.addBody( helicopter, { density=1.0, friction=0.3, bounce=0.3 } )
	
	-- move the helicopter while press and hold
	local function flyHelicopter()
	      helicopter:setLinearVelocity(0, -100)
	end
	
	local firstTouch = true
	local function myTapListener( event )
		-- start physics on first touch
		if firstTouch then
			physics.start()
			firstTouch = false
		end
		if event.phase == "began" then
			-- resume physics after transition from question
			if physicsIsPaused then
				physics.start()
				physicsIsPaused = false
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

	sceneGroup:addEventListener( "touch", myTapListener )  --add a "tap" listener to the object
	
	
	-- create a floor object and add physics (with custom shape)
	scrollingForeground1.anchorX = 0
	scrollingForeground1.anchorY = 1
	scrollingForeground1.x, scrollingForeground1.y = 0, display.contentHeight+display.contentHeight/6
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local scrollingForegroundShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( scrollingForeground1, "static", { friction=0.3, shape=scrollingForegroundShape } )

	scrollingForeground2.anchorX = 0
	scrollingForeground2.anchorY = 1
	scrollingForeground2.x, scrollingForeground2.y = display.contentWidth, display.contentHeight+display.contentHeight/6
	physics.addBody( scrollingForeground2, "static", { friction=0.3, shape=scrollingForegroundShape } )
	

	-- all display objects must be inserted into group
	sceneGroup:insert( background1 )
	sceneGroup:insert( background2 )
	sceneGroup:insert( scrollingForeground1 )
	sceneGroup:insert( scrollingForeground2 )
	sceneGroup:insert( helicopter )
	
	--  start scrolling background, will rearrange backgrounds once one is off screen
	local runtime = 0

	local function getDeltaTime()
	    local temp = system.getTimer()  -- Get current game time in ms
	    local dt = (temp-runtime) / (1000/60)  -- 60 fps or 30 fps as base
	    runtime = temp  -- Store game time
	    return dt
	end
	
	-- Frame update function
	local function frameUpdate()
		

	   -- Delta Time value
	   local dt = getDeltaTime()
	   -- This needs work.. change position to alter up and down

	   -- Move the foreground 1 pixel with delta compensation (makes it a bit smoother)
	   -- We can use this to scroll the background at a slower pace than the foreground
	   -- it'll look neat.
	   scrollingForeground1:translate( -1*dt, 0 )
	   scrollingForeground2:translate( -1*dt, 0 )
	   background1:translate( -0.25*dt, 0 )
	   background2:translate( -0.25*dt, 0 )
	   
	   if scrollingForeground1.x <= -display.contentWidth then
		   scrollingForeground1.x = 0
		   scrollingForeground2.x = display.contentWidth
	   end
	   
	   if background1.x <= -display.contentWidth*2 then
		   background1.x = 0
		   background2.x = display.contentWidth*2
	   end
	   
	   -- if any crates have been spawned scroll them too.
	   if next(questionCrates) ~= nil then
		   for _, item in ipairs(questionCrates) do
			   item:translate( -1*dt, 0 )
		   end
	   end
	end
	-- Frame update listener
	Runtime:addEventListener( "enterFrame", frameUpdate )
end

local overlayOptions ={
	isModal = false,
	effect = "fade",
	time = 1000,
	height = 80,
	width = 80
}

function showQuestion()
	composer.showOverlay("questionOverlay", overlayOptions)
	return true
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	firstTouch = true
	local function handleKrippMovement()
		if drKripp.y <= 50 then
			drKripp:setLinearVelocity(0, 100)
		elseif drKripp.y >= screenH - screenH/5 then
			drKripp:setLinearVelocity(0, -100)
		elseif firstTouch then
			drKripp:setLinearVelocity(0, -100)
			firstTouch = false
		end
		--print(drKripp.y)
	end
	
	if phase == "will" then
		setupKripp()
		spawnQuestionCrate()
		Runtime:addEventListener( "enterFrame", handleKrippMovement )
		
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then

		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		--physics.start()
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
		physics.stop()
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view

	-- THIS NEEDS WORK ------------------------------------------------------------------
	-- On re-entering the scene if a player chooses to play again, the helicopter should
	-- start at the original position upon first playing the game + restarted score etc
	-------------------------------------------------------------------------------------
	scene:removeEventListener("touch", myTapListener)
	scene:removeEventListener("enterFrame", frameUpdate)
	helicopter:removeEventListener("collision", helicopter) 
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-----------------------------------------------------------------------------------------

return scene