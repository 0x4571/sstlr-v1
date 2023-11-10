	local Mode = "Normal" 

	local TableSpoof = {}
	local Sources = {}

	local GroupToPublishToID = nil
	local UserToPublishToID = nil

	local CheckEachAnimationID = true
	local NumbersToCheck = 5
	local SpecificChecks = {}

	for _,v in game:GetDescendants() do if v:IsA("PackageLink") then v:Destroy() end end

	local MarketplaceService = game:GetService("MarketplaceService")

	local function SendPOST(ids: {any})
		local success, result = pcall(function()
			return game:GetService("HttpService"):PostAsync("http://127.0.0.1:6969/", game:GetService("HttpService"):JSONEncode({["ids"]=ids, ["groupID"] = GroupToPublishToID and GroupToPublishToID or nil, ["sourcesToSpoof"] = Sources and Sources or nil}), Enum.HttpContentType.ApplicationJson, 99999)
		end)

		print(success, result)
	end

	local function GetAsync()
		local response = nil

		while not response do
			local success, result = pcall(function()
				return game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync("http://127.0.0.1:6969/"))
			end)
			if success then
				response = result
			end
			task.wait(2)
		end

		return response
	end

	local function BeginReupload(ids: {any})
		game:GetService("HttpService"):PostAsync("http://127.0.0.1:6970/", game:GetService("HttpService"):JSONEncode({["ids"]=ids, ["groupID"] = GroupToPublishToID and GroupToPublishToID or nil}))

		task.wait(1)

		local response

		while not response and task.wait(4) do
			response = game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync("http://127.0.0.1:6970/"))
		end

		local newID = response 

		for _,v in newID do
			if v then
				newID = v
			end
		end

		return newID
	end

	local Modes = {
		Help = "Returns this help guide!",
		Normal = "Begins stealing all animations with no filter whatsoever.",
		["Explorer Selection"] = "Only steals animations that are selected in the Roblox Studio's Explorer.",
		["Table Spoof"] = "Only steals animations IDs that you put in the \"TableSpoof\" variable",
		["Table Spoof and Return 1"] = "Only steals animations IDs that you put in the \"TableSpoof\" variable, and returns a table with the IDs without actually changing them in-game (DOESN'T return with rbxassetid://)",
		["Table Spoof and Return 2"] = "Only steals animations IDs that you put in the \"TableSpoof\" variable, and returns a table with the IDs without actually changing them in-game (DOES return with rbxassetid://)",
	}

	game:GetService("HttpService").HttpEnabled = true

	local function ReturnUUID(): {any}
		return tostring(game:GetService("HttpService"):GenerateGUID())
	end

	local CorrectNumbers 
	local CorrectLength

	local ids = {}

	local function GetCorrectNumbers(anim)
		local success, err = pcall(function()
			return MarketplaceService:GetProductInfo(anim.AnimationId:match("%d+"), Enum.InfoType.Asset)
		end)
		
		if not success then return end

		local mpsInfo = MarketplaceService:GetProductInfo(anim.AnimationId:match("%d+"), Enum.InfoType.Asset)

		if mpsInfo.AssetTypeId ~= Enum.AssetType.Animation.Value then return end

		local newID

		if Mode == "Table Spoof and Return 1" or Mode == "Table Spoof and Return 2" then
			newID = BeginReupload({[index] = anim.AnimationId:match("%d+")}) 
		else
			newID = BeginReupload({[anim.Name..ReturnUUID()] = anim.AnimationId:match("%d+")})
		end

		if not newID or type(newID) ~= "string" then return end

		CorrectNumbers = string.sub(string.match(newID, "%d+"), 1, NumbersToCheck)
		CorrectLength = string.len(string.match(newID, "%d+"))
	end

	local function SpoofTable(Table)
		local i = 0

		for index,v in Table do
			local anim = v

			if type(v) == "number" or type(v) == "string" then
				anim = {AnimationId = tostring(v), Name = index}
			elseif anim.ClassName then
				if not anim:IsA("Animation") then
					continue
				end
			end

			if not anim or tonumber(anim.AnimationId:match("%d+")) == nil or string.len(anim.AnimationId:match("%d+")) <= 6 then continue end

			local foundAnimInTable = false

			for _,x in ids do
				if x == anim.AnimationId:match("%d+") then
					foundAnimInTable = true
				end
			end	

			if foundAnimInTable == true or anim.AnimationId:match("%d+") == "125750702" then continue end

			i += 1

			if not CorrectNumbers then
				GetCorrectNumbers(anim)
				continue
			end
			
			if CheckEachAnimationID == true and (CorrectNumbers and string.sub(anim.AnimationId:match("%d+"), 1, NumbersToCheck) == CorrectNumbers) then continue end

			local Skip = false

			for _,num in SpecificChecks do
				if string.sub(anim.AnimationId:match("%d+"), 1, string.len(num)) == num then
					Skip = true
				end
			end

			if Skip == true  then continue end

			if Mode == "Table Spoof and Return 1" or Mode == "Table Spoof and Return 2" then
				ids[index] = anim.AnimationId:match("%d+")
			else
				ids[anim.Name..ReturnUUID()] = anim.AnimationId:match("%d+")
			end
		end

		return ids
	end

	local function GenerateIDList(): {any}
		local ids = {}

		if Mode == "Normal" then
			ids = SpoofTable(ScriptDirectoryToGoThrough:GetDescendants())

		elseif Mode == "Explorer Selection" then
			ids = SpoofTable(game.Selection:Get())

		elseif Mode == "Table Spoof" then
			if not TableSpoof then warn("TableSpoof doesn't exist") return end

			ids = SpoofTable(TableSpoof)

		elseif Mode == "Table Spoof and Return 1" then
			if not TableSpoof then warn("TableSpoof doesn't exist") return end

			ids = SpoofTable(TableSpoof)

		elseif Mode == "Table Spoof and Return 2" then
			if not TableSpoof then warn("TableSpoof doesn't exist") return end

			ids = SpoofTable(TableSpoof)
		end

		return ids
	end

	if Mode == "Help" then
		for mod,desc in Modes do
			print(mod.." - "..desc)
		end

		return
	end

	local idsToGet = GenerateIDList()
	SendPOST(idsToGet)

	local newIDList = GetAsync()

	if Mode == "Table Spoof and Return 2" then
		for i,v in newIDList do
			newIDList[i] = "rbxassetid://"..v
		end
	end

	if Mode == "Table Spoof and Return 1" or Mode == "Table Spoof and Return 2" then
		print(newIDList)
		return
	end

	print("CHANGING ANIMATIONS IN ROBLOX...")

	
	for _,thing in game:GetDescendants() do
		if not thing:IsA("Animation") or not string.match(thing.AnimationId, "%d+") then continue end
		    local foundAnimation 
			local thisAnimid = string.match(thing.AnimationId, "%d+")

			for oldId, newId in newIDList do
				if tostring(oldId) == thisAnimid then
					foundAnimation = tostring(newId)
					break
				end
			end

			thing.AnimationId = foundAnimation and "rbxassetid://"..foundAnimation or thing.AnimationId

		task.wait()
	end


	print("FINISHED CHANGING ANIMATIONS IN ROBLOX!")