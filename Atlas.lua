--[[ 
    REMINDER: All names in Atlas must be unquie
    Writer: @SCPF_RedSky (most of the time)
    Name: Atlas.Lua
    Date: 8/23/24
    ClassName: ModuleScript
    RunTime: Shared
    Description:
    This module is a part of the Atlas Framework, designed to simplify and enhance the development experience for Roblox developers.
    It provides various utilities that make managing objects, modules, and settings much more efficient. Key features include:
    - LoadLibrary : LOads and requires a module with the tag "FrameworkModule"
    - GetObject: Retrives an Object with the defined name, aslong as it has "Framework" Tag
    - New: Creates an instance with a defined class name and tags it with "Framework" so you can use GetObject to them
    - BindToTag: Attach a callback function that triggers when objects with a specific tag are added.
    - GetObjects: Retrieve all objects with a particular tag.
    - ApplySettings: Update properties of an object based on a settings table.
    - GenerateUniqueId: Generate a unique identifier using GUID.
    - LogOperation: Log operations for debugging and tracking purposes.
    - DeepClone: Clone an object along with its descendants and tag them.
    - TagObject: Add a tag to an object.
    - RemoveTag: Remove a tag from an object.
    
    For detailed usage and documentation, please visit: https://github.com/SCPFBluesky/Atlas-Framework/tree/main
]]

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

-- Define the FrameworkType, which serves as our blueprint. It specifies all the methods and their expected types.
-- This ensures that our implementation adheres to the expected structure and type conventions.
type FrameworkType = {
	LoadLibrary: (self: FrameworkType, ModuleName: string) -> any?,
	GetObject: (self: FrameworkType, ObjectName: string) -> Instance?,
	New: (self: FrameworkType, ClassName: string) -> Instance?,
	BindToTag: (self: FrameworkType, Tag: string, Callback: (Instance: Instance) -> ()) -> RBXScriptConnection,
	GetObjects: (self: FrameworkType, Tag: string) -> {Instance},
	ApplySettings: (self: FrameworkType, Object: Instance, Settings: {[string]: any}) -> (),
	GenerateUniqueId: (self: FrameworkType) -> string,
	LogOperation: (self: FrameworkType, Operation: string, Details: {[string]: any}?) -> (),
	DeepClone: (self: FrameworkType, Object: Instance) -> Instance,
	TagObject: (self: FrameworkType, Object: Instance, Tag: string) -> (),
	RemoveTag: (self: FrameworkType, Object: Instance, Tag: string) -> (),
	GetObjectWithTag: (self: FrameworkType, Tag: string) -> {Instance},
}

-- Create the main Framework object. This will be our central class where all the methods are defined.
-- Using metatables, we set up inheritance so that methods can be accessed properly.
local Framework = {}
Framework.__index = Framework

-- Helper function to sanitize names. This is crucial to avoid issues with invalid or empty names.
-- It converts the name to lowercase to ensure consistency and prevent case-sensitive mismatches.
local function SanitizeName(Name: any): string
	if typeof(Name) ~= "string" or Name == "" then
		error("Invalid Name provided", 2)
	end
	-- Convert the name to lowercase for consistent comparisons.
	return Name:lower()
end

-- Helper function to tag objects with a specific tag if they don't already have it.
-- Tagging objects helps us categorize and manage them more efficiently within the framework.
local function TagObject(Object: Instance, Tag: string)
	if not CollectionService:HasTag(Object, Tag) then
		CollectionService:AddTag(Object, Tag)
	end
end

-- Function to load a module by its name. It searches through tagged modules and tries to require the one that matches the name.
-- The use of `pcall` ensures that if the module fails to load, we catch the error and log it instead of crashing the script.
function Framework:LoadLibrary(ModuleName: string): any?
	-- Clean and validate the module name to ensure it's a proper string.
	ModuleName = SanitizeName(ModuleName)

	-- Retrieve all modules tagged as "FrameworkModule". These are our candidate modules for loading.
	local Modules = CollectionService:GetTagged("FrameworkModule")

	-- Iterate through the list of modules to find one that matches the requested name.
	for _, Module in ipairs(Modules) do
		if Module:IsA("ModuleScript") and Module.Name:lower() == ModuleName then
			-- Attempt to require the module safely, catching any errors that may occur.
			local Success, Result = pcall(function()
				return require(Module)
			end)
			if Success then
				return Result -- Return the successfully loaded module.
			else
				-- Log a warning if the module fails to load.
				warn("Failed to load Module '" .. ModuleName .. "': " .. tostring(Result))
				return nil
			end
		end
	end

	-- Log a warning if no module with the specified name was found.
	warn("Module '" .. ModuleName .. "' not found!")
	return nil
end

-- Function to create a new instance of a specified class and tag it with "Framework".
-- Tagging is done to facilitate easy management and tracking of these objects.
function Framework:New(ClassName: string): Instance?
	-- Use `pcall` to handle any potential errors when creating a new instance.
	local Success, NewObject = pcall(function()
		return Instance.new(ClassName)
	end)

	-- If creation is successful, tag the new object and return it.
	if Success and NewObject then
		TagObject(NewObject, "Framework")
		return NewObject
	else
		-- Log a warning if the class name provided is invalid.
		warn("Invalid ClassName: '" .. ClassName .. "'")
		return nil
	end
end

-- Function to retrieve an object by its name. This function can wait for the object to appear if it's not immediately found.
-- It's essentially a custom implementation of WaitForChild but tailored for objects with the "Framework" tag.
function Framework:GetObject(ObjectName: string, Timeout: number?): Instance?
	-- Clean and validate the object name to ensure it's a proper string.
	ObjectName = SanitizeName(ObjectName)
	local StartTime = tick() -- Record the start time for timeout handling.

	-- Continuously check for the object until it’s found or the timeout is reached.
	while true do
		-- Retrieve all objects tagged with "Framework".
		local Objects = CollectionService:GetTagged("Framework")

		-- Iterate through the objects to find one that matches the requested name.
		for _, Obj in ipairs(Objects) do
			if Obj.Name:lower() == ObjectName then
				return Obj -- Return the found object.
			end
		end

		-- If a timeout is defined, check if we’ve exceeded the allowed time to wait.
		if Timeout and (tick() - StartTime) >= Timeout then
			warn("Timeout reached while searching for object: '" .. ObjectName .. "'")
			return nil -- Return nil if the object was not found in the given time.
		end

		task.wait() -- Pause briefly before checking again.
	end
end

-- Function to bind a callback to objects with a specific tag. The callback is triggered whenever new objects with the tag are added.
-- This is useful for dynamically responding to objects as they become available in the game.
function Framework:BindToTag(Tag: string, Callback: (Instance: Instance) -> ()): RBXScriptConnection
	-- Validate the tag and callback to ensure they are of the correct types.
	if typeof(Tag) ~= "string" or typeof(Callback) ~= "function" then
		error("Invalid arguments for BindToTag", 2)
	end

	-- Call the callback for each existing instance that already has the specified tag.
	for _, Instance in ipairs(CollectionService:GetTagged(Tag)) do
		task.spawn(Callback, Instance)
	end

	-- Connect to the signal that fires when new instances with the tag are added.
	return CollectionService:GetInstanceAddedSignal(Tag):Connect(function(Instance)
		task.spawn(Callback, Instance)
	end)
end

-- Function to retrieve all objects with a given tag. If no objects are found, a warning is logged.
-- This is useful for retrieving and managing multiple objects that share the same tag.
function Framework:GetObjects(Tag: string): {Instance}
	-- Validate the tag to ensure it’s a string.
	if typeof(Tag) ~= "string" then
		error("Invalid Tag name", 2)
	end

	-- Retrieve all objects with the specified tag.
	local Objects = CollectionService:GetTagged(Tag)

	-- Log a warning if no objects were found with the given tag.
	if #Objects == 0 then
		warn("No objects found with Tag '" .. Tag .. "'")
	end
	return Objects
end

-- Function to apply multiple settings to an object. The settings are specified in a table where the keys are property names and the values are the new values.
-- This allows for bulk updates to an object’s properties in a flexible manner.
function Framework:ApplySettings(Object: Instance, Settings: {[string]: any})
	-- Validate the object and settings to ensure they are of the correct types.
	if typeof(Object) ~= "Instance" or typeof(Settings) ~= "table" then
		error("Invalid arguments for ApplySettings", 2)
	end

	-- Iterate through the settings table and apply each setting to the object.
	for Property, Value in pairs(Settings) do
		local Success = pcall(function()
			Object[Property] = Value
		end)
		if not Success then
			-- Log a warning if applying a specific setting fails.
			warn("Failed to apply setting '" .. Property .. "' on Object '" .. Object.Name .. "'")
		end
	end
end

-- Function to generate a unique ID using GUID. This ID is useful for uniquely identifying objects or entities within the framework.
function Framework:GenerateUniqueId(): string
	local Id = HttpService:GenerateGUID(false) -- Generate a new GUID.
	return Id -- Return the generated unique ID.
end

-- Function to log operations for tracking and debugging purposes. Details can be included to provide additional context.
-- This is useful for monitoring the framework's behavior and diagnosing issues.
function Framework:LogOperation(Operation: string, Details: {[string]: any}?)
	-- Clean and validate the operation name.
	Operation = SanitizeName(Operation)
	Details = Details or {} -- Default to an empty table if no details are provided.

	-- You could enhance logging here to include more details or integrate with external systems if needed.
	-- For now, we'll just log the operation name and any additional details.
end

-- Function to deep clone an object. This creates a new instance of the object and recursively clones all of its descendants,
-- tagging each cloned descendant to ensure they are included in the framework's management.
function Framework:DeepClone(Object: Instance): Instance
	-- Ensure the provided object is valid.
	if not Object then
		error("No Object provided for cloning", 2)
	end

	local ClonedObject = Object:Clone() -- Clone the object.
	-- Tag all descendants of the cloned object.
	for _, Descendant in ipairs(ClonedObject:GetDescendants()) do
		TagObject(Descendant, "Framework")
	end

	return ClonedObject -- Return the cloned object.
end

-- Function to tag an object with a specific tag. This is useful for categorizing and managing objects within the framework.
function Framework:TagObject(Object: Instance, Tag: string)
	-- Sanitize and validate the tag.
	Tag = SanitizeName(Tag)
	if typeof(Object) ~= "Instance" then
		error("Invalid Object for tagging", 2)
	end

	-- Call the helper function to add the tag to the object.
	TagObject(Object, Tag)
end

-- Function to remove a tag from an object. This is useful for managing and updating the tags on objects.
-- If the object has the tag, it will be removed.
function Framework:RemoveTag(Object: Instance, Tag: string)
	-- Sanitize and validate the tag.
	Tag = SanitizeName(Tag)
	if typeof(Object) ~= "Instance" then
		error("Invalid Object for untagging", 2)
	end

	-- Remove the tag if it exists.
	if CollectionService:HasTag(Object, Tag) then
		CollectionService:RemoveTag(Object, Tag)
	end
end
-- Return the Framework object so that it can be used in other scripts.
return Framework
