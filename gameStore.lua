local composer = require( "composer" )
local menu = require("menu")
local scene = composer.newScene()
local theseCoins = require("setupCoins")
local theseItems = require("setupItems")

-- include Corona's "widget" library
local widget = require "widget"

-- Global variables
_G.helicopter1 = {}
_G.helicopter2 = {}
_G.helicopter3 = {}

-- Local Variables
local centerX = display.contentCenterX -- grab center of X values
local centerY = display.contentCenterY -- grab center of Y values
local width = display.contentWidth -- scale the x-size of the shown overlay
local height = display.contentHeight  -- scale the y-size of the shown overlay

local itemAmount = 0 -- a local to store the amount an item will cost
local item -- a local to store the items that are available
local itemsAvail -- table to store all of the items that will be available
local currItems -- a table within the itemsAvail table, this will store the name, image, and price of an item
local canPurchase = true -- boolean to store whether or not the user will be able to afford the item purchase
local currentCoins
local itemName -- used to store the name of the item upon instantiation
local userHas -- boolean to determine whether or not the user already has the item
local function btnTap(event)
	event.target.xScale = 0.95
	event.target.yScale = 0.95
	composer.gotoScene("menu", "fade", 500)
	return true
end

local buttonOptions = {
	label = "Buy",
	labelColor = {default = {0.27}, over={1}},
	font = "FuturaLT",
	fillColor = { default={0.72, 0.9, 0.16, 0.78}, over={0.27} },
    strokeColor = { default={0.27}, over={0.27} },
    strokeWidth = 2,
    shape = "Rect",
	height = 30,
	width = 45
}



function scene:create( event )
	local sceneGroup = self.view
	local background = display.newRect(sceneGroup, centerX, centerY, width, height, 12 )
	background:setFillColor(1)
		-- Called when the scene is still off screen and is about to move on screen
	helicopter1[1] = "HotAirBalloon.png"
	helicopter1[2] = 15
	helicopter1[3] = "Hot Air Balloon"
	helicopter1[4] = 1

	helicopter2[1] = "ToyHeli.png"
	helicopter2[2] = 45
	helicopter2[3] = "Toy Helicopter"
	helicopter2[4] = 2

	helicopter3[1] = "Biplane.png"
	helicopter3[2] = 70
	helicopter3[3] = "Biplane"
	helicopter3[4] = 3

	local firstItem = display.newImageRect(helicopter1[1], 136, 250)
	firstItem.x = display.contentCenterX/2
	firstItem.y = 100
	firstItem.xScale = 0.35
	firstItem.yScale = 0.35
	sceneGroup:insert(firstItem)


	local secondItem = display.newImageRect(helicopter2[1], 250, 80)
	secondItem.x = display.contentWidth/2
	secondItem.y = 100
	secondItem.xScale = 0.35
	secondItem.yScale = 0.35
	sceneGroup:insert(secondItem)


	local thirdItem = display.newImageRect(helicopter3[1], 250, 136)
	thirdItem.x = display.contentCenterX *3/2
	thirdItem.y = 100
	thirdItem.xScale = 0.35
	thirdItem.yScale = 0.35
	sceneGroup:insert(thirdItem)

	currItems = {} -- instantiate the currItems table
	local coinText = theseCoins.init({
			filename = "coinFile.txt"
	})

	theseCoins.set(15)
	theseCoins.save()


	local itemText = theseItems.init({
		filename = "itemFile.txt"
	})

	theseItems.save()


	-- Create the button used to minimize the overlay on click
	local homeBtn = widget.newButton {
			label = "Home",
			labelColor = { default={0.27}, over={1} },
			font = "FuturaLT",
			color = black,
			height = 30,
			width = 30,
	}
	homeBtn.x = width * 0.08
	homeBtn.y = height * 0.08
	homeBtn:addEventListener ("tap", btnTap)
	sceneGroup:insert(homeBtn)

	-- Function called if a user wants to buy a specific item, will call to check the purchase to see if it is possible
	function wantToBuy1()
		theseCoins.save()
		checkPurchase(helicopter1[2], tostring(helicopter1[1]),1) -- pass this variable into the checkPurchase method
	end

	function wantToBuy2()
		theseCoins.save()
		checkPurchase(helicopter2[2], tostring(helicopter2[1]),2)
	end 

	function wantToBuy3()
		theseCoins.save()
		checkPurchase(helicopter3[2], tostring(helicopter3[1]),3)
	end


		local purchaseBtn = widget.newButton(buttonOptions)
		local purchaseBtn2 = widget.newButton(buttonOptions)
		local purchaseBtn3 = widget.newButton(buttonOptions)
		local currentCoins = theseCoins.load()
		purchaseBtn.x = (display.contentWidth/2) * 0.5
		purchaseBtn.y = display.contentCenterY + 10
		purchaseBtn2.x = display.contentWidth/2
		purchaseBtn2.y = display.contentCenterY + 10
		purchaseBtn3.x = (display.contentWidth/2) * 3/2
		purchaseBtn3.y = display.contentCenterY + 10

		purchaseBtn:addEventListener("tap", wantToBuy1)
		purchaseBtn2:addEventListener("tap", wantToBuy2)
		purchaseBtn3:addEventListener('tap', wantToBuy3)
		sceneGroup:insert(purchaseBtn)
		sceneGroup:insert(purchaseBtn2)
		sceneGroup:insert(purchaseBtn3)

	-- This button will change appearance based on whether or not the user can afford to purchase items
	function checkButtons()
		local coinsAvail = theseCoins.load()
		if (coinsAvail < helicopter1[2]) then
			purchaseBtn:setEnabled(false)
			purchaseBtn:setFillColor( 1, 0.2, 0.2)
		end
		if(coinsAvail < helicopter2[2]) then
			purchaseBtn2:setFillColor(1, 0.2, 0.2)
			purchaseBtn2:setEnabled(false)
		end
		if(coinsAvail < helicopter3[2]) then
			purchaseBtn3:setFillColor(1, 0.2, 0.2)
			purchaseBtn3:setEnabled(false)
		end
	end

	-- function to check the current items a user has
	function checkUserItems(itemId)
		theseItems.checkForDoubles(itemId)
		if _G.UserHasThese == false then
			theseItems.add(itemId)
			theseItems.save()
			print("purchased")
		elseif _G.UserHasThese == true then
			print("you already have this item")
		end
	end



	-- Use this function to determine whether or not the user can afford to purchase these items based on their amount of coins
	function checkPurchase(itemPriceInput, inputImage, id)
		checkButtons() -- recheck the buttons to see if they can still afford other items

		if (theseCoins.load() >= itemPriceInput ) then
				checkUserItems(id)
				canPurchase = true
				theseCoins.set(theseCoins.load() - itemPriceInput) -- if the user decides the purchase, decrement the amount of coins in which they have by the item amount
				theseCoins.save()		
		elseif(theseCoins.load() < itemPriceInput) then
				canPurchase = false
				print("test not enough coins")
		end
	end

	function addToItems()
		if canPurchase then
		end
	end
	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
	checkButtons()
	theseItems.checkForDoubles(1)


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