
-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"
local screenW, screenH, halfW = display.contentWidth, display.contentHeight, display.contentWidth*0.5

--------------------------------------------

-- forward declarations and other locals
local playBtn

-- Options to be used for each button
local options = {
	    label="",
	    font = "FuturaLT",
	    fontSize = 20,
	    labelColor = { default={0.24}, over={1} },
		fillColor = { default={ 1, 1, 1, 1 }, over={0.24} },
    	strokeColor = { default={0.24}, over={0.24} },
    	strokeWidth = 2,
    	shape = "Rect",
		width=160, height=40
}

local overlayOptions ={
	isModal = false,
	effect = "fade",
	time = 1000,
	height = 80,
	width = 80
}

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	--if DEVICE_ID == ID_DATA[1] then
	--composer.gotoScene( "gameScene", "fade", 500 )
--else -- else the user will be taken to a practice screen to show how the game works
	local function onGetObjects( event )
		if not event.error and #event.response.results > 0 then
			-- if you have already completed the tutorial
			if event.response.results[1].completedTutorial == true then
				-- go straight to gameplay
				print("Go to Game Scene")
				composer.gotoScene( "gameScene", "fade", 500 )
			else
				-- go to tutorial
				print("Go to Tutorial Scene")
				composer.gotoScene( "tutorialGame", "fade", 500 )
			end
		end 
	end
	
	-- SELECT deviceId FROM User WHERE deviceId = system.getInfo("deviceID");
	local queryTable = { 
	  ["where"] = { ["deviceId"] = system.getInfo("deviceID") }
	}
	parse:getObjects( "User", queryTable, onGetObjects )
	
	composer.gotoScene( "tutorialGame", "fade", 500 )
--end
	
	return true	-- indicates successful touch
end

--<<<<<<< Local Changes
--<<<<<<< Local Changes
--local function onCreditRelease()
--	composer.showOverlay("gameCredits", overlayOptions)
--=======
--local function onTutorialRelease()
--	composer.gotoScene("Tutorial", "fade", 500)
--end

--local function onCreditRelease(event)
--	composer.showOverlay("gameCredits", overlayOptions)
--	return true
-->>>>>>> External Changes
--=======
local function onStoreRelease()
	composer.gotoScene("gameStore", "fade", 500)
end

local function onCreditRelease(event)
	composer.showOverlay("gameCredits", overlayOptions)
	return true
end






function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background color
	display.setDefault("background", 1, 1, 1)
	
	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newText( "Title", 264, 42, "FuturaLT", 29 )
	titleLogo.x = display.contentWidth * 0.5
	titleLogo.y = 100
	titleLogo:setFillColor(0.26)

	-- create a grey rectangle as the backdrop
	local menuBG1 = display.newImageRect( "menuBG1.jpg", screenW*2, screenH )
	menuBG1.anchorY = 0
	menuBG1.x, menuBG1.y = 0, 0
	menuBG1.alpha = 0.4
	sceneGroup:insert(menuBG1)

	local menuBG2 = display.newImageRect( "menuBG2.jpg", screenW*2, screenH )
	menuBG2.anchorY = 0
	menuBG2.x, menuBG2.y = screenW*2, 0
	menuBG2.alpha = 0.4
	sceneGroup:insert(menuBG2)
	

	-- Play Button Settings --
	playBtn = widget.newButton{
	    label="",
	    font = "FuturaLT",
	    fontSize = 20,
	    labelColor = { default={0.24}, over={1} },
		fillColor = { default={ 1, 1, 1, 1 }, over={0.24} },
    	strokeColor = { default={0.24}, over={0.24} },
    	strokeWidth = 2,
    	shape = "Rect",
		width=160, height=40,
		onRelease = onPlayBtnRelease
	}
	playBtn.x = display.contentWidth*0.5
	playBtn.y = display.contentHeight - 140
	playBtn:setLabel("Play")


	-- Tutorial Button Settings --
	tutorialBtn = widget.newButton(options)
	tutorialBtn.x = display.contentWidth*0.5
	tutorialBtn.y = display.contentHeight - 90
	tutorialBtn:setLabel("Store")
	tutorialBtn:addEventListener("tap", onStoreRelease)


	-- Credit Button Settings --
	creditBtn = widget.newButton{
	defaultFile = "creditButton.png",
	width = 30,
	height = 30,

	}
	creditBtn.destination = "gameCredits"
	creditBtn:addEventListener("tap", onCreditRelease)

	creditBtn.x = display.contentWidth * 0.05
	creditBtn.y = display.contentHeight * 0.93


	--Sound Button--
	local soundBtn = widget.newButton{
	defaultFile = "soundOn.png",
	overFile = "soundOff.png",
	width = 30,
	height = 30,

	}

	soundBtn.x = display.contentWidth * 0.95
	soundBtn.y = display.contentHeight * 0.93

	local runtime = 0
	local function getDeltaTime()
		local temp = system.getTimer()
		local dt = (temp-runtime) / (1000/60)
		runtime = temp
		return dt
	end

	function scrollMenuScreen()
		local dt = getDeltaTime()
		menuBG1:translate(-0.25*dt, 0)
		menuBG2:translate(-0.25*dt, 0)

		if menuBG1.x <= -display.contentWidth*2 then
			menuBG1.x = 0
			menuBG2.x = display.contentWidth*2
		end

	end 

	Runtime:addEventListener("enterFrame", scrollMenuScreen)

	
	-- all display objects must be inserted into group
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( playBtn )
	sceneGroup:insert( tutorialBtn )
	sceneGroup:insert( creditBtn )
	sceneGroup:insert( soundBtn )

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
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene
