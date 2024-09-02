--[[ 
    Description: 
    This script demonstrates the usage of all functions provided by the Atlas module.
    It includes creating new objects, loading modules, retrieving and tagging objects, 
    and applying settings. For more detailed documentation, visit: https://scpfbluesky.github.io/AtlasFramework/api/Atlas/

    Author: @SCPF_RedSky
    Date: 9/2/24
]]
--!nonstrict
--!native
local Atlas = require(game.ReplicatedStorage.Atlas)  -- Import the Atlas module

-- Example 1: Creating a new part with atlas
local NewPart = Atlas:New("Part")  
if NewPart then
	NewPart.Name = "MyPart"
	NewPart.Size = Vector3.new(5, 1, 5)  
	NewPart.Position = Vector3.new(0, 10, 0)  
	NewPart.Parent = workspace 
end

-- Example 2: Load a library module
local MyModule = Atlas:LoadLibrary("MyModule")  -- Load a module named "MyModule" from the Atlas library
-- Ensure the module has a "FrameworkModule Tag" for Atlas to locate it

-- Example 3: Retrieve an object by its name
local RetrievedPart = Atlas:GetObject("MyPart")
--[[
 	If the part isnt created with Atlas, then you must manually tag the object
 	With "Framework"
 	However if the part is created with atlas (in this case it is) we do not need
 	to add the framework tag, as it creates for you with Atlas:New()

]]

-- Example 4: Bind a function to a tag
Atlas:BindToTag("MyTag", function(instance)
end)

-- Example 6: Apply settings to an object
local SamplePart = RetrievedPart 
if SamplePart then
	Atlas:ApplySettings(SamplePart, {
		Color = Color3.new(1, 0, 0),  
		Transparency = 0.5,  
		Size = Vector3.new(10, 2, 10)  
	})
end

-- Example 7: Generate a unique ID

local UniqueId = Atlas:GenerateUniqueId()  -- Generate a unique identifier using Atlas
print(UniqueId)

-- Example 8: Log an operation

Atlas:LogOperation("TestOperation", {
	Detail1 = "Value1",  -- Example detail for the operation
	Detail2 = "Value2"   -- Another example detail for the operation
})
-- This logs an operation with the name "TestOperation" and associated details

-- Example 9: Deep clone an object
local ClonedPart = Atlas:DeepClone(SamplePart) 
if ClonedPart then
	ClonedPart.Position = ClonedPart.Position + Vector3.new(0, 10, 0)  
	ClonedPart.Parent = workspace 
end

-- Example 10: Tag an object
if SamplePart then
	Atlas:TagObject(SamplePart, "TaggedSample")  
end

-- Example 11: Remove a tag from an object
if SamplePart then
	Atlas:RemoveTag(SamplePart, "TaggedSample")  -- Remove the "TaggedSample" tag from the part
end

-- Example 12: Get objects with a specific tag
local TaggedObjectsWithSampleTag = Atlas:GetObjectWithTag("TaggedSample")  -- Retrieves all object with the "TaggedSample"
for _, obj in ipairs(TaggedObjectsWithSampleTag) do
	obj.BrickColor = BrickColor.new("Bright blue") 
end
