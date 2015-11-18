
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
_G.physicsTutorialPaused = false
local helicopter
-- use this to determine whether or not the game has started
_G.tutorialHasStarted = false;
_G.tutorialPaused = false -- used to show whether or not the entire game is paused
_G.tutorialCoins = 0 -- store the amount of coins a user has in the game
local crateShowing
local questionCrates -- table to store the crates into
local coins -- table to store coins into
local coinShowing
local newCrate
local seconds = 0 -- used to keep track of amount of seconds player will boost for
local maxTime = 5 -- 5 seconds maximum boost time
local spriteSheetOptions = {
	width = 100,
	height = 100,
	numFrames = 10
}
-- Options used for the tutorial question overlay
overlayOptions ={
	isModal = false,
	effect = "fade",
	time = 1000,
	height = 80,
	width = 80
}

_G.tutorialBoost = false -- this will store whether or not a user has a boost that can be used.  (Will be true if they answer the question correctly)


-- 'onRelease' event listener for playBtn, take them to the main game
local function onPlayBtnRelease()
	composer.gotoScene( "gameScene", "fade", 500 )	
	return true	-- indicates successful touch
end

local function onHomeRelease(event)
	composer.gotoScene(event.target.destination, "fade", 500)
end 

--------------------------------Begin main scene create ---------------------------------------------------
function scene:create( event )
	local sceneGroup = self.view
	physicsTutorialPaused = false -- pause the physics when initially starting the game
	questionCrates = {} -- initialize the question crate table
	coins = {} -- initialize the coin table

	-- create a grey rectangle as the backdrop
	local background1 = display.newImageRect( "bg3.png", screenW*2, screenH )
	background1.anchorY = 0
	background1.x, background1.y = 0, 0
	sceneGroup:insert(background1)

	local background2 = display.newImageRect( "bg3.png", screenW*2, screenH )
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

	local coinText = display.newText( "Collect coins to spend in store.", 264, 42, "FuturaLT", 15 )
	coinText.x = display.contentWidth * 0.7
	coinText.y = 150
	coinText:setFillColor(0.26)
	coinText.alpha = 0
	sceneGroup:insert(coinText)

	amountOfCoins = display.newText(tostring(_G.tutorialCoins), 264, 42, "FuturaLT", 20)
	amountOfCoins.y = display.contentHeight * 0.1
	amountOfCoins.x = display.contentWidth * 0.1
	amountOfCoins:setFillColor(0.26)
	sceneGroup:insert(amountOfCoins)

	---------------------- Section to create the helicopter ------------------------------
	-- make a helicopter (off-screen), position it, and rotate slightly
	helicopter = display.newImageRect( "helicopter2.png", 216, 113 )
	helicopter.name = "helicopter"
	helicopter.xScale = 0.62
	helicopter.yScale = 0.62
	helicopter.x, helicopter.y = screenW - screenW * 0.85, screenH/2
	helicopter.rotation = 0
	
	-- add physics to the helicopter
	-- provide a radius of 50 to tighten the bounds of collision
	physics.addBody( helicopter, {radius = 40, density=1.0, friction=0.3, bounce=0.3 } )
	sceneGroup:insert(helicopter)


	---------------------------- Placement of scrolling forgrounds -----------------------------------------------
	local scrollingForeground1 = display.newImageRect( "ground.png", screenW+5, 82 )
    local scrollingForeground2 = display.newImageRect( "ground.png", screenW+5, 82 )

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

	function pauseTutorial()
		tutorialPaused = true
		tutorialFirstTouch = true
		physics.pause()
		tutorialHasStarted = false
		physicsTutorialPaused = true
	end

	-- function used to show Kripp flying up and down
	function handleKrippMovement()
		if tutorialKripp.y <= 50 then
			tutorialKripp:setLinearVelocity(0, 100)
		elseif tutorialKripp.y >= screenH - screenH/5 then
			tutorialKripp:setLinearVelocity(0, -100)
		elseif tutorialFirstTouch then
			tutorialKripp:setLinearVelocity(0, -100)
			tutorialFirstTouch = false
		end
		--print(drKripp.y)
	end

	

	-- function used to set up Dr.Kripp
	function setupKripp()
		local xPos = display.contentWidth * 0.80
		tutorialKripp = display.newImage("kripplol.png")
		physics.addBody(tutorialKripp, "dynamic")
		tutorialKripp.gravityScale = 0
		tutorialKripp.isSensor = true
		tutorialKripp.x = xPos
		tutorialKripp.y = screenH/2
		tutorialKripp.width = 80
		tutorialKripp.height = 80
		sceneGroup:insert(tutorialKripp)
	end

	-- function to be called to spawn kripp later on in the tutorial
	function spawnKripp()
		local krippText = display.newText( "Uh Oh, here comes Dr. Kripp.\nDon't worry, we're closer to catching him.\nKeep answering those questions and\nhe'll be ours in no time.", 264, 42, "FuturaLT", 15 )
		krippText.x = display.contentWidth * 0.7
		krippText.y = 150
		krippText:setFillColor(0.26)
		transition.fadeOut(krippText, {time = 8000})
		sceneGroup:insert(krippText)
		setupKripp()
		Runtime:addEventListener("enterFrame", handleKrippMovement)
		timer.performWithDelay(12000, readyToPlay, 1)
	end



	-- function that be called to spawn a spinning coin, this can be altered to change the position once we include collisions
	function createCoins()
		coinShowing = true
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
		spinningCoin.y = display.contentHeight * 0.6
		spinningCoin.x = display.contentWidth
		spinningCoin.xScale = 0.30
		spinningCoin.yScale = 0.30
		spinningCoin.name = "coin"
		spinningCoin:play()
		-- add physics to the coin
		physics.addBody( spinningCoin, {radius = 5, density=1.0, friction=0.3, bounce=0.3 } )
		spinningCoin.gravityScale = 0

		sceneGroup:insert(spinningCoin)
		table.insert( coins, spinningCoin ) -- store the coins into a table for later use
	end

	-- function used to detect if anything is colliding with the helicopter
	local function helicopterCollision(self, event)
		if event.phase == "began" then
			if event.other.name == "crate" then
				crateShowing = false
				local currentCrate = event.other  -- store the current crate being collided with into a local
				currentCrate.alpha = 0 -- hide the crate on collision
				currentCrate:removeSelf() -- remove the current crate showing from the screen
				tutorialPaused = true
				tutorialFirstTouch = true
				physics.pause()
				tutorialHasStarted = false
				physicsTutorialPaused = true
				showQuestion()
				_G.coinTimer = timer.performWithDelay(7000, createCoins, 1)
				timer.pause(_G.coinTimer) -- pause this after colliding to avoid a coin appearing away, this will resume once the user answers the question
			
			elseif event.other.name == "coin" then -- check if helicopter is colliding with a coin
				media.playSound("coinCollide.wav") -- play a coin sound on collision
				coinShowing = false
				local currentCoin = event.other
				currentCoin.alpha = 0
				currentCoin:removeSelf() -- remove the coin from the screen
				_G.tutorialCoins = _G.tutorialCoins + 1
				amountOfCoins.text = tostring(_G.tutorialCoins) -- update the amount of coins and display onscreen
				timer.performWithDelay(transition.to(amountOfCoins, {time = 1000, xScale=1.3, yScale = 1.3, iterations = 4}))
				timer.performWithDelay(7000, spawnKripp, 1)
				--print("im not a crate!! mwah ah ha ha!!")
			end
		end
	end


	-- set up helicopter collision listeners to pass into helicopterCollision(self,event)
	helicopter.collision = helicopterCollision
	helicopter:addEventListener("collision", helicopter)


	function showQuestion()
		composer.showOverlay("tutorialQuestion", overlayOptions)
		return true
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

	function showCrates()

		-- Show some text before displaying a crate
		local text = display.newText( "You're a natural!", 264, 42, "FuturaLT", 15 )
		text.x = display.contentWidth * 0.7
		text.y = 150
		text:setFillColor(0.26)
		sceneGroup:insert(text)
		transition.fadeOut(text, {time=2500})

		crateShowing = true -- boolean to determine whether a crate is showing or not
		newCrate = display.newImageRect( "crate.png", 20, 20 )
		newCrate.name = "crate"
		newCrate.x = display.contentWidth
		newCrate.y = display.contentCenterY * 0.5
		-- add physics to the crate
		physics.addBody( newCrate, {radius = 25, density=1.0, friction=0.3, bounce=0.3 } )
		newCrate.gravityScale = 0
		sceneGroup:insert(newCrate)
		-- store the crate into a table to be used later
		table.insert( questionCrates, newCrate )
		-- after 3 seconds have passed, pause the game and explain to user what the crate is
		timer.performWithDelay(3000, pauseGame, 1)
	end 

	
	-- function called to warn user of boundaries
	local function warnBoundaries()
		local boundariesText = display.newText( "Great Job!\nBut don't get too rambunctious...\nWatch out for those boundaries!", 264, 42, "FuturaLT", 15 )
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
		-- redirect to showCrates to perform the next portion of the tutorial
		timer.performWithDelay(13000, showCrates, 1)
	end

	function setAlpha(this)
		this.alpha = 1
	end


	-- use this function to increment seconds 
	local function updateTime()
		seconds = seconds + 1
	end

	-- provide the helicopter to boost in the x-direction for a short amount of time
	function boostHelicopter()
		timer.performWithDelay(6000, setAlpha(coinText), 1) -- allow for the coin text to appear
		transition.fadeOut(coinText, {time = 6000})
		_G.tutorialBoost = false -- set the boost to false as it is being used currently
		local boostTime = timer.performWithDelay(1000, updateTime, maxTime)
		if seconds ~= maxTime then
			print(seconds)
			helicopter:setLinearVelocity(50, -50)
		elseif seconds == maxTime then
			helicopter:setLinearVelocity(0, -100) -- return back to normal speed after boost
		    Runtime:removeEventListener( "enterFrame", boostHelicopter )
		end
	end 

	-- use this function to provide a button that takes the user to the main game once the tutorial is finished
	function readyToPlay()
		pauseTutorial()


		local Overlay = display.newRoundedRect(sceneGroup, centerX, centerY, width/1.4, height/1.4, 12 )
		Overlay:setFillColor(0.9)
		Overlay.alpha = 0.9
		Overlay.isHitTestable = true

		local readyText = display.newText( "You're getting the hang of this.\nNow let's catch Dr. Kripp before he gets away!", 264, 42, "FuturaLT", 16)
		readyText.x = display.contentWidth * 0.5
		readyText.y = 120
		readyText:setFillColor(0.26)
		sceneGroup:insert(readyText)

		-- Play Button Settings --
		local playBtn = widget.newButton{
	    	label="",
	    	font = "FuturaLT",
	    	fontSize = 20,
	    	labelColor = { default={0.27}, over={1} },
			fillColor = { default={ 1, 1, 1, 1 }, over={0.27} },
    		strokeColor = { default={0.27}, over={0.27} },
    		strokeWidth = 3,
    		shape = "roundedRect",
			width=154, height=40,
			onRelease = onPlayBtnRelease
		}
		playBtn.x = display.contentWidth*0.5
		playBtn.y = display.contentHeight - 140
		playBtn:setLabel("Play")
		sceneGroup:insert(playBtn)
		--transition.fadeOut(readyText, {time=2500})
	end



	-- method for platform scrolling
	function platformScroll()
		local dt = getDeltaTime()

		if (tutorialHasStarted and tutorialPaused == false) then
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
			-- if a crate is showing, then scroll it as well
			if (crateShowing) then
				if next(questionCrates) ~= nil then
					for _, item in ipairs(questionCrates) do
						item:translate(-1*dt, 0)
						timer.performWithDelay(transition.to(item, {time = 1000, xScale=1.4, yScale = 1.4, iterations = 10}))
					end
				end  
			end
			if (coinShowing) then
				if next(coins) ~= nil then
					for _, thisCoin in ipairs(coins) do
						thisCoin:translate(-1*dt, 0)
					end					
			end	end
		end 
	end

	Runtime:addEventListener("enterFrame", platformScroll)

	-- move the helicopter while press and hold
	local function flyHelicopter()
		 helicopter:setLinearVelocity(0,-100)
	end


	-- method to detect whether or not the user has started flying
	local tutorialFirstTouch = true
	local function isFlying( event )
		-- start physics on first touch
		if tutorialFirstTouch and tutorialPaused == false then
			physics.start()
			timer.performWithDelay(5000, warnBoundaries, 1)
			tutorialFirstTouch = false
			transition.fadeOut(instructions, {time=800})
			tutorialHasStarted = true
		elseif tutorialPaused == true then
			physics.pause()
			helicopter:setLinearVelocity(0, 0)
			tutorialHasStarted = false
		end 
		if event.phase == "began" then
			-- resume physics after transition from question
			if physicsIsPaused then
				physics.start()
				physicsTutorialPaused = false
			end
			if _G.tutorialBoost then
				Runtime:addEventListener("enterFrame", boostHelicopter)
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


	if phase == "will" then

	elseif phase == "did" then
		-- function used to resume the game
	function resumeGame()
		tutorialPaused = false
		physicsTutorialPaused = false
		tutorialHasStarted = true
		physics.start()
	end

	-- function will be used to pause all of the physics in the game to explain game aspects
	function pauseGame()
		tutorialPaused = true
		tutorialFirstTouch = true
		physics.pause()
		tutorialHasStarted = false
		physicsTutorialPaused = true
		local onPauseText = display.newText( "Look ahead, here comes a crate!\nCollide with, and answer questions to gain a boost.\nGive it a shot!", 264, 42, "FuturaLT", 15 )
		onPauseText.x = display.contentWidth * 0.65
		onPauseText.y = 150
		onPauseText:setFillColor(0.26)
		sceneGroup:insert(onPauseText)
		transition.fadeOut(onPauseText, {time = 6000})
		timer.performWithDelay(6500, resumeGame, 1)
	end
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
	local sceneGroup = self.view
	composer.removeScene("tutorialGame")
	
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