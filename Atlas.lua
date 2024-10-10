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
--!strict
--!native
local ObjectManager = require(script.ObjectManager)
local TagManager = require(script.TagManager)
local EventManager = require(script.EventManager)
local Utility = require(script.Utility)

local Atlas = {}

@native function Atlas:LoadLibrary(ModuleName)
	return ObjectManager:LoadModule(ModuleName)
end

@native function Atlas:New(ClassName)
	return ObjectManager:CreateObject(ClassName)
end

@native function Atlas:GetObject(ObjectName, Timeout)
	return ObjectManager:GetObject(ObjectName, Timeout)
end

@native function Atlas:ApplySettings(Object, Settings)
	ObjectManager:ApplySettings(Object, Settings)
end

@native function Atlas:TagObject(Object, Tag)
	TagManager:TagObject(Object, Tag)
end

@native function Atlas:RemoveTag(Object, Tag)
	TagManager:RemoveTag(Object, Tag)
end

@native function Atlas:BindToTag(Tag, Callback)
	return EventManager:BindToTag(Tag, Callback)
end

@native function Atlas:GetObjectsWithTag(Tag)
	return TagManager:GetObjectsWithTag(Tag)
end

@native function Atlas:ReloadModules()
	return ObjectManager:ReloadModules()
end
@native function Atlas:ClearFrameworkTag(Tag)
	return ObjectManager:ClearFrameworkTag()
end
@native function Atlas:LogOperation(Operation, Details)
	Utility:LogOperation(Operation, Details)
end

@native function Atlas:GenerateUniqueId()
	return Utility:GenerateUniqueId()
end

return Atlas
