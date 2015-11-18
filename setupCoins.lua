-- Read and Write to file module
-- Use this file to control the amount of coins a user has
-- Coins will be saved and retrieved via a text file

local myCoins = {} -- a table to hold the amount of coins a user has
myCoins.amount = 0 -- amount of coins, set initially to 0

function myCoins.init(options)
	myCoins.filename = "coinFile.txt"
end

function myCoins.set(value)
	myCoins.amount = value
end

function myCoins.get()
	return myCoins.amount
end

function myCoins.add(amount)
	myCoins.amount = myCoins.amount + amount
end

function myCoins.save()
	local path = system.pathForFile(myCoins.filename, system.DocumentsDirectory)
	local file = io.open(path, "w")
	if(file)then
		local content = tostring(myCoins.amount)
		file:write(content)
		io.close(file)
		return true
	else
		print("Cannot read file")
		return false
	end
end

function myCoins.load()
	local path = system.pathForFile(myCoins.filename, system.DocumentsDirectory)
	local content = ""
	local file = io.open(path, "r")
	if(file)then
		local contents = file:read("*a")
		local amount = tonumber(contents)
		io.close(file)
		return amount
	else
		print("Error cant read file")
	end
	return nil
end
return myCoins