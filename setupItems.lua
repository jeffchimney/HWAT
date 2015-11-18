-- Read and Write to file module
-- Use this file to keep track of the items that a user has
-- Items will be saved and retrieved from a text file 
_G.userHasThese = false
local myItems = {} -- a table to hold the amount of items a user has
myItems.item = "none" -- amount of items, set initially to 0

function myItems.init(options)
	myItems.filename = "itemFile.txt"
end

function myItems.set(value)
	myItems.item = value
end

function myItems.get()
	return myItems.amount
end

function myItems.add(thisItem)
	myItems.item = thisItem.."\n"
end

function myItems.save()
	local path = system.pathForFile(myItems.filename, system.DocumentsDirectory)
	local file = io.open(path, "w")
	if(file)then
		local content = tostring(myItems.item)
		file:write(content)
		io.close(file)
		return true
	else
		print("Cannot read file")
		return false
	end
end

function myItems.load()
	local path = system.pathForFile(myItems.filename, system.DocumentsDirectory)
	local content = ""
	local file = io.open(path, "r")
	if(file)then
		local contents = file:read("*a")
		io.close(file)
		return contents
	else
		print("Error cant read file")
	end
	return nil
end

-- method will take in an itemId and compare to what is in the file.  Return a global
-- as false or true depending on if they have an item or not.
function myItems.checkForDoubles(itemId)
	local path = system.pathForFile(myItems.filename, system.DocumentsDirectory)
	local file = io.open(path, "r")
	for lines in file:lines() do
		if tostring(lines) == tostring(itemId) then
			_G.UserHasThese = true
			print(_G.UserHasThese)
		elseif tostring(lines) ~= tostring(itemId) then
			_G.UserHasThese = false
		end
	end
	io.close(file)
	return _G.UserHasThese
end
return myItems