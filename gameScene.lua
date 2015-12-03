-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local theseCoins = require("setupCoins")
local testItems = require("setupItems") -- testing the items that are available for use
-- include Corona's "widget" library
local widget = require "widget"

local scene = composer.newScene()

-- include Corona's "physics" library
local physics = require "physics"
physics.start(); physics.pause()


_G.gameCoins = 0
--------------------------------------------

-- forward declarations and other locals
local screenW = display.contentWidth
local screenH = display.contentHeight
local halfW = display.contentWidth * 0.5
local drKripp
local helicopter
local questionCrates
_G.physicsPaused = false
local score
local firstTouch
local thisCrate -- store the crate that has already been collided with
_G.gameHasStarted = false
_G.gamePaused = false
local firstTouch = true

local scrollingForeground1 = display.newImageRect( "ground.png", screenW+5, 82 )
local scrollingForeground2 = display.newImageRect( "ground.png", screenW+5, 82 )
local coinTable = {} -- use a table to store instances of the coins
local overlayOptions ={
	isModal = false,
	effect = "fade",
	time = 1000,
	height = 80,
	width = 80
	}

	local spriteSheetOptions = {
		width = 100,
		height = 100,
		numFrames = 10
	}
		
	coinShowing = false
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
	
	-- function that will spawn the coin based on a number input that will index the table
	

function scene:create( event )
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
	local sceneGroup = self.view
	local writeText = theseCoins.init({
		filename = "coinFile.txt"
	})

	theseCoins.save()
	local itemText = testItems.init({
		filename = "itemsFile.txt"
	})

	print(testItems.load())
	userTutorialHeli = testItems.load -- store the heli the user has decided to choose into a variable which will be passed into rendering.
	
	--initialize questionCrates
	questionCrates = {}
	score = 0

	function spawnTheseCoins()
		local thisCoin = display.newSprite(coin_sheet, coin_sequences)
		thisCoin.y = display.contentHeight * 0.6
		thisCoin.x = display.contentWidth
		thisCoin.xScale = 0.30
		thisCoin.yScale = 0.30
		thisCoin.name = "coin"
		thisCoin:play()

		-- add physics to the coin
		physics.addBody( thisCoin, {radius = 5, density=1.0, friction=0.3, bounce=0.3 } )
		thisCoin.gravityScale = 0
		table.insert(coinTable, thisCoin)
		sceneGroup:insert(thisCoin)
	end

	-- create a grey rectangle as the backdrop
	local background1 = display.newImageRect( "bg3.png", screenW*2, screenH )
	background1.anchorY = 0
	background1.x, background1.y = 0, 0
	background1.name = "background"
	sceneGroup:insert(background1)

	local background2 = display.newImageRect( "bg3.png", screenW*2, screenH )
	background2.anchorY = 0
	background2.x, background2.y = screenW*2, 0
	background2.name = "background"
	sceneGroup:insert(background2)
	
	amountOfCoins = display.newText(tostring(_G.gameCoins), 264, 42, "FuturaLT", 20)
	amountOfCoins.y = display.contentHeight * 0.1
	amountOfCoins.x = display.contentWidth * 0.1
	amountOfCoins:setFillColor(0.26)
	
	scoreLabel = display.newText(score, 264, 42, "FuturaLT", 20)
	scoreLabel.y = display.contentHeight * 0.1
	scoreLabel.x = display.contentWidth * 0.9
	scoreLabel:setFillColor(0.26)
	
	drKripp = display.newImage("kripplol.png")

	local function onInventoryRelease(event)
		pauseMainGame()
		composer.showOverlay("inventoryOverlay", overlayOptions)
		return true
	end

	-- Inventory Button Settings --
	local itemBtn = widget.newButton{
	defaultFile = "bakpack.png"
	}
	itemBtn.destination = "inventoryOverlay"
	itemBtn:addEventListener("tap", onInventoryRelease)

	itemBtn.x = display.contentWidth * 0.05
	itemBtn.y = display.contentHeight * 0.93
	itemBtn.xScale = 0.37
	itemBtn.yScale = 0.37

	function pauseMainGame()
		gamePaused = true
		firstTouch = true
		gamePaused = true
		physics.pause()
		gameHasStarted = false
		physicsPaused = true
	end

	--background:setFillColor( .5 )
	
    -- Function to detect collision (helicopter, event such as foreground collision)
	local function helicopterCollision(self, event)
		-- want to know when the collision starts:
		if event.phase == "began" then
			print(self.name)
			print(event.other.name)
			-- this section will need to be updated
			if event.other.name == "crate" then
				--event.other:removeSelf()
				currCrate = event.other
				currCrate.yScale = 0
				currCrate.xScale = 0
				event.other = nil;
				pauseMainGame()
				showGameQuestion()
				firstTouch = true
				
			elseif event.other.name == "coin" then -- check if tutorialHelicopter is colliding with a coin
				media.playSound("coinCollide.wav") -- play a coin sound on collision
				coinShowing = false
				local currentCoin = event.other
				currentCoin.alpha = 0
				currentCoin:toBack()
				--currentCoin.name = 'collectedCoin' -- remove the coin from the screen
				local currentCoinAmount = theseCoins.load() -- load the users current amount of coins from the text file
				theseCoins.add(currentCoinAmount + 1) -- add current coints + 1 to the text file
				theseCoins.save() -- save the text file
				_G.gameCoins = _G.gameCoins + 1
				amountOfCoins.text = tostring(_G.gameCoins) -- update the amount of coins and display onscreen
				--print("im not a crate!! mwah ah ha ha!!")
			elseif event.other.name == "collectedCoin" then
				event.other:toBack()
			elseif event.other.name == nil then
				print("Collided with something with no assigned name")
			else
				print("i am colliding") 
				
				-- called when an parse is queried for an object
				local function onGetObjects( event )
					-- if there are no errors and your deviceID is already in the system
					if not event.error then
						-- update User.highScore if they have broken their previous record.
						if event.response.results[1].highScore < tonumber( scoreLabel.text ) then
							local updateDataTable = { ["highScore"] = tonumber( scoreLabel.text ) }
							parse:updateObject( "User", event.response.results[1].objectId, updateDataTable, onUpdateObject )
						end
					end 
		
				end
	
				-- called when a parse object is updated
				local function onUpdateObject( event )
					if not event.error then
				    	print( event.response.createdAt )
				 	end
				end
				-- SELECT deviceId FROM User WHERE deviceId = system.getInfo("deviceID");
				local queryTable = { 
				  ["where"] = { ["deviceId"] = system.getInfo("deviceID") }
				}
				parse:getObjects( "User", queryTable, onGetObjects )
				Runtime:removeEventListener( "enterFrame", frameUpdate )
				firstTouch = true
				score = 0
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
		print("Spawn question crate called.")

		local newCrate = display.newImageRect( "crate.png", 20, 20 )
		newCrate.name = "crate"
	
		if drKripp.y >= screenH/2 then
			newCrate.x, newCrate.y = screenW + screenW/5, drKripp.y - screenH/3
		else
			newCrate.x, newCrate.y = screenW + screenW/5, drKripp.y + screenH/3
		end
	
		-- set up crate collision listeners to pass into helicopterCollision(self,event)
		--gameCrate.collision = helicopterCollision
		--gameCrate:addEventListener("collision", gameCrate)

		-- add physics to the helicopter

		physics.addBody( newCrate, {radius = 5, density=1.0, friction=0.3, bounce=0.3 } )
		newCrate.gravityScale = 0
	
		table.insert( questionCrates, newCrate )
		
		sceneGroup:insert(newCrate)
	end

	scrollingForeground1.type = "gameOver"
	-- make a helicopter (off-screen), position it, and rotate slightly
	helicopter = display.newImageRect( "helicopter2.png", 216, 113 )
	helicopter.name = "helicopter"
	helicopter.xScale = 0.62
	helicopter.yScale = 0.62
	helicopter.x, helicopter.y = screenW - screenW * 0.85, screenH/2
	helicopter.rotation = 0
	
	-- set up helicopter collision listeners to pass into helicopterCollision(self,event)
	helicopter.collision = helicopterCollision
	helicopter:addEventListener("collision", helicopter)

	-- add physics to the helicopter
	physics.addBody( helicopter, {radius = 15, density=1.0, friction=0.3, bounce=0.3 } )
	
	-- move the helicopter while press and hold
	local function flyHelicopter()
	      helicopter:setLinearVelocity(0, -100)
	end
	
	local firstTouch = true
	local function myTapListener( event )
		-- start physics on first touch

		print(firstTouch)
		if firstTouch and gamePaused == false then
			score = 0
			physics.start()
			firstTouch = false
			gameHasStarted = true
			scoreLabel.alpha = 1
		elseif gamePaused == true then
			physics.pause()
			helicopter:setLinearVelocity(0,0)
			gameHasStarted = false
		end
		if event.phase == "began" then
			-- resume physics after transition from question
			if scoreLabel.alpha == 0 then
				scoreLabel.alpha = 1
			end
			if physicsIsPaused then
				physics.start()
				physicsIsPaused = false
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

	sceneGroup:addEventListener( "touch", myTapListener )  --add a "tap" listener to the object
	
	
	-- create a floor object and add physics (with custom shape)
	scrollingForeground1.anchorX = 0
	scrollingForeground1.anchorY = 1
	scrollingForeground1.x, scrollingForeground1.y = 0, display.contentHeight+display.contentHeight/6
	scrollingForeground1.name = "Ground"
	-- define a shape that's slightly shorter than image bounds (set draw mode to "hybrid" or "debug" to see)
	local scrollingForegroundShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
	physics.addBody( scrollingForeground1, "static", { friction=0.3, shape=scrollingForegroundShape } )

	scrollingForeground2.anchorX = 0
	scrollingForeground2.anchorY = 1
	scrollingForeground2.x, scrollingForeground2.y = display.contentWidth, display.contentHeight+display.contentHeight/6
	scrollingForeground2.name = "Ground"
	physics.addBody( scrollingForeground2, "static", { friction=0.3, shape=scrollingForegroundShape } )
	

	-- all display objects must be inserted into group
	sceneGroup:insert( background1 )
	sceneGroup:insert( background2 )
	sceneGroup:insert( scrollingForeground1 )
	sceneGroup:insert( scrollingForeground2 )
	sceneGroup:insert( helicopter )
	sceneGroup:insert(scoreLabel)
	sceneGroup:insert(amountOfCoins)
	sceneGroup:insert(itemBtn)
	spawnTheseCoins()
	timer.performWithDelay(10000, spawnTheseCoins())


	
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
		if physicsPaused == false then
			score = score + 1
		end
		
		if score % 10 == 0 and physicsPaused == false then
			scoreLabel.text = tostring(score/10)
		end

	   -- Delta Time value
	   local dt = getDeltaTime()
	   -- This needs work.. change position to alter up and down

	   -- Move the foreground 1 pixel with delta compensation (makes it a bit smoother)
	   -- We can use this to scroll the background at a slower pace than the foreground
	   -- it'll look neat.
	   if(gameHasStarted and gamePaused == false) then
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
	   
	   		-- if any crates have been spawned scroll them too
	   		if next(questionCrates) ~= nil then
		   		for _, item in ipairs(questionCrates) do
			   		item:translate( -1*dt, 0 )
		   		end
	   		end
	   		if next(coinTable) ~= nil then
	   			for _, coin in ipairs(coinTable) do
	   				coin:translate(-1*dt, 0)
	   			end
	   		end
	end	end
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

function showGameQuestion()
	composer.showOverlay("questionOverlay", overlayOptions)
	return true
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	firstTouch = true
	print(firstTouch)
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
		print("My Crates")
		print(tostring(questionCrates[1]))
		helicopter.y = display.contentHeight/2
		scoreLabel.alpha = 0
		setupKripp()
		Runtime:addEventListener( "enterFrame", handleKrippMovement )
		spawnQuestionCrate()
		
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		firstTouch = true
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
	composer.removeScene( "gameScene" )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-----------------------------------------------------------------------------------------

return scene