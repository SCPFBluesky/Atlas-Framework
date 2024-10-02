--[[ 
    Description: 
    This script demonstrates the usage of all functions provided by the Atlas module.
    It includes creating new objects, loading modules, retrieving and tagging objects, 
    and applying settings. For more detailed documentation, visit: https://scpfbluesky.github.io/AtlasFramework/api/Atlas/

    Author: @SCPF_RedSky
    Date: 10/1/24
]]
--!nonstrict
--!native
local Atlas = require(game.ReplicatedStorage.Atlas) -- Require the Atlas module


-- Create an Object with the "Framework" tag
local NewPart = Atlas:New("Part")
if NewPart then
	NewPart.Name = "SpecialPart"
	NewPart.Parent = workspace
	NewPart.Position = Vector3.new(0, 10, 0)
	NewPart.Size = Vector3.new(5, 5, 5)
	NewPart.BrickColor = BrickColor.new("Bright red")
end

-- Generate a unique ID
local UniqueId = Atlas:GenerateUniqueId()
Atlas:LogOperation("GeneratedUniqueId", { Id = UniqueId }) -- Log an operation with details

local FrameworkConnection = Atlas:BindToTag("Framework", function(Instance)
	print("Object with 'Framework' tag detected: " .. Instance.Name)
end)

local NewTaggedPart = Instance.new("Part")
NewTaggedPart.Name = "SpecialPart"
NewTaggedPart.Parent = workspace
Atlas:TagObject(NewTaggedPart, "SpecialTag") -- Tags the new part with SpecialTag

Atlas:RemoveTag(NewTaggedPart, "SpecialTag")

local Settings = {
	Transparency = 0.5,
	Anchored = true
}
Atlas:ApplySettings(NewPart, Settings) 

Atlas:ReloadModules()

local RetrievedObject = Atlas:GetObject("SpecialPart")  -- Gets an object with a specific name, if you want to add a timeout just do GetObject("Part", 5) 5 is 5 seconds timeout
if RetrievedObject then
	print("Successfully found object: " .. RetrievedObject.Name)
else
	print("Failed to find object within the timeout")
end

Atlas:ClearFrameworkTag("Framework")

FrameworkConnection:Disconnect()
