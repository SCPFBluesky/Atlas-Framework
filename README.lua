--[[# Atlas-Framework
Inspired by devSparkle's Overture module, Atlas is crafted to simplify the development of Roblox games, with this module with plenty of features.

# API
    REMINDER: ALL OBJECTS\MODULES NAMES MUST BE UNIQUE!
  The Atlas Framework module provides a set of utility functions designed to simplify common tasks in Roblox development. Below are some key functions and how to use them:
  LoadLibrary: Easily load and require tagged ModuleScripts (With tag FrameworkModule)
  GetObject: Retrieve objects by name with automatic retry and optional timeout. (With tag Framework)
  New : Creates an object with the class name, when the object gets created it automaticly has the tag framework
  BindToTag : Directly taken from overture, Binds a callback function to all objects tagged with the specified tag. The callback will also trigger for any future objects added with the same tag.
  ApplySettings: Quickly apply multiple settings to an object
  GenerateUniqueID : Generates a unique identifier string.
  DeepClone: Creates a deep clone of an object, tagging all descendants with Framework.
  TagObject -- Tags an object with a specific tag
  RemoveTag -- Removes an object with a specific tag
  GetObjectWithTag: Retrieves all objects with the specified tag.
  Examples will be listed below: ]]
local Atlas = require(game.ReplicatedStorage.Atlas)
local Example = Atlas:LoadLibrary("Example")
-- Atlas.New()
local NewPart = Atlas:New("Part") -- you can change the part to anything aslong as its a vaild classname

--Atlas:GetObject()
local Door = Atlas:GetObject("DoorInWorkspace") -- GetObject will allow you to retrive any object no matter the directory, aslong as it has the Framework tag

--Atlas:BindToTag()
local Connection = Framework:BindToTag("MyTag", function(instance)  --Directly taken from overture, Binds a callback function to all objects tagged with the specified tag. The callback will also trigger for any future objects added with the same tag.
end)

--Atlas:ApplySettings()
Atlas:ApplySettings(Object, {    Size = Vector3.new(4, 4, 4),    Color = Color3.fromRGB(255, 0, 0)}) --Quickly apply multiple settings to an object.

--Atlas:GenerateUniqueId()
local UniqueId = Atlas:GenerateUniqueId() --Generates a unique identifier string.

--Atlas:DeepClone()
local ClonedObject = Atlas:DeepClone(Object)

--Atlas:TagObject, RemoveTag
Atlas:TagObject(Object, "MyTag")
Atlas:RemoveTag(Object, "MyTag")
--Tag or untag objects with a specified tag.

--GetObjectWithTag
local TaggedObjects = Atlas:GetObjectWithTag("MyTag") --Retrieves all objects with the specified tag.

