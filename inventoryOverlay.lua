local composer = require( "composer" )
local menu = require("menu")
local scene = composer.newScene()
local theseItems = require("setupItems")
local gStore = require("gameStore")


-- include Corona's "widget" library
local widget = require "widget"

-- Local Variables
local centerX = display.contentCenterX -- grab center of X values
local centerY = display.contentCenterY -- grab center of Y values
local width = display.contentWidth -- scale the x-size of the shown overlay
local height = display.contentHeight  -- scale the y-size of the shown overlay
local user
local i1,i2,i3 = nil, nil, nil
local in1, in2, in3 = nil, nil, nil

local overlayOptions ={
	isModal = false,
	effect = "fade",
	time = 1000,
	height = 80,
	width = 80
}

_G.userDecision = nil -- use this to pass into game scene, will hold the image file

function getUsersChoice(event)
	_G.userDecision = nil
end

local function btnTap(event)
	event.target.xScale = 0.95
	event.target.yScale = 0.95
	composer.gotoScene(event.target.destination, overlayOptions)
	return true
end

local function hideOverlay(event)
	_G.gamePaused = false
	_G.physicsIsPaused = false
	_G.gameHasStarted = true
	physics.start()
	composer.hideOverlay("fade", 800)
end 

function catchBackgroundOverlay(event)
	return true
end


function scene:create( event )
	local sceneGroup = self.view
	local Overlay = display.newRect(sceneGroup, centerX, centerY, width/1.5, height/1.5, 12 )
	Overlay:setFillColor(0.9)
	Overlay.alpha = 0.9
	Overlay.isHitTestable = true
	Overlay:addEventListener("tap", catchBackgroundOverlay)
	Overlay:addEventListener("touch", catchBackgroundOverlay)
	-- Create the button used to minimize the overlay on click
	local minimizeBtn = widget.newButton {
			label = "hide",
			labelColor = { default={0.27}, over={1} },
			font = "FuturaLT",
			color = black,
			height = 30,
			width = 30,
	}
	minimizeBtn.x = width * 0.22
	minimizeBtn.y = height * 0.22
	minimizeBtn:addEventListener ("tap", hideOverlay)
	sceneGroup:insert(minimizeBtn)
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newText( "Your Items", 264, 42, "FuturaLT", 20 )
	titleLogo.x = display.contentWidth * 0.5
	titleLogo.y = 110
	titleLogo:setFillColor(0.27)
	sceneGroup:insert(titleLogo)

	local itemText = theseItems.init({
		filename = "itemFile.txt"
	})
	theseItems.load()


-- function that will take in users items and 
local function showItems(input1, input2, input3)
		if input1 ~= nil then
			in1 = widget.newButton{
				defaultFile = tostring(input1),
				fillColor = { over={0.24} },
			}
			in1.x = display.contentCenterX
			in1.y = display.contentCenterY
			in1.xScale = 0.23
			in1.yScale = 0.23
			--in1.addEventListener("tap", getUsersChoice)
			sceneGroup:insert(in1)
		else 
			print("this item does not exist")
		end
		if input2 ~= nil then
			in2 = display.newImageRect(tostring(input2), 250, 80)
		end
		if input3 ~= nil then
			in3 = display.newImageRect(tostring(input3), 250, 136)
		else
			print("no items to show")
		end
	end

	


	-- Call function from our setupItems.lua file to print the items to a table to pass through for use
	theseItems.itemsToTable()
	-- Store image files from global tables into locals to be displayed
	local function getUsersItems()
		if _G.userCurrItems[1] ~= nil then
			i1 = "HotAirBalloon.png"
			print(i1)
		end
		if _G.userCurrItems[2] ~= nil then
			i2 = "ToyHeli.png"
			print(i2)
		end
		if _G.userCurrItems[3] ~= nil then
			i3 = "Biplane.png"
		else
			print("no items")
		end
	end

	getUsersItems()
	showItems(i1, i2, i3)
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