--[[
    REMINDER: ALL OBJECTS\MODULES NAMES MUST BE UNIQUE!
    Writer: @SCPF_RedSky (most of the time)
    Name : Atlas.Lua
    Date : 8/23/24
    ClassName : ModuleScript
    RunTime: Shared
    Description: 
    Heavily inspired by devSparkle's Overture module.
    The Atlas module is designed to make roblox devloper's life more easier with plenty of features
    like
    GetObjects
    LoadLibrary
    New
    BindToTag
    and more!
    
    For more information and useage documentation please visit : https://github.com/SCPFBluesky/Atlas-Framework/tree/main
]]

--!nocheck
--!native

warn("This game uses Atlas framework, for more information please vist https://github.com/SCPFBluesky/Atlas-Framework/tree/main")
-- remove if u hate credits ^


local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ObjectCache = {}
local RunService = game:GetService("RunService")

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

local Framework = {}
Framework.__index = Framework

local function SanitizeName(Name: any): string
	if typeof(Name) ~= "string" or Name == "" then
		error("Invalid Name provided", 2)
	end
	return Name:lower()
end

local function TagObject(Object: Instance, Tag: string)
	if not CollectionService:HasTag(Object, Tag) then
		CollectionService:AddTag(Object, Tag)
	end
end

function Framework:LoadLibrary(ModuleName: string): any?
	ModuleName = SanitizeName(ModuleName)

	local Modules = CollectionService:GetTagged("FrameworkModule")

	for _, Module in ipairs(Modules) do
		if Module:IsA("ModuleScript") and Module.Name:lower() == ModuleName then
			local Success, Result = pcall(function()
				return require(Module)
			end)
			if Success then
				return Result
			else
				warn("Failed to load Module '" .. ModuleName .. "': " .. tostring(Result))
				return nil
			end
		end
	end

	warn("Module '" .. ModuleName .. "' not found!")
	return nil
end

function Framework:GetObject(ObjectName: string, Timeout: number?): Instance?
	ObjectName = SanitizeName(ObjectName)
	local StartTime = tick()
	local Tries = 40
	local Attempt = 0

	if ObjectCache[ObjectName] then
		return ObjectCache[ObjectName]
	end

	repeat
		Attempt = Attempt + 1
		local Objects = CollectionService:GetTagged("Framework")
		local FoundObject = false

		if #Objects == 0 then
			warn("Attempt " .. Attempt .. ": No objects found with the 'Framework' tag.")
		else
			for _, Obj in ipairs(Objects) do
				if Obj.Name:lower() == ObjectName then
					ObjectCache[ObjectName] = Obj
					return Obj
				end
			end

			if not FoundObject then
				warn("Attempt " .. Attempt .. ": No object found with the name '" .. ObjectName .. "'.")
			end
		end

		if Timeout and (tick() - StartTime) >= Timeout then
			warn("Timeout reached after " .. Attempt .. " attempts.")
			break
		end

		RunService.Heartbeat:Wait(Attempt * 0.2)
	until Attempt >= Tries

	warn("Object '" .. ObjectName .. "' not found after " .. Tries .. " attempts.")
	return nil
end


function Framework:New(ClassName: string): Instance?
	local Success, NewObject = pcall(function()
		return Instance.new(ClassName)
	end)

	if Success and NewObject then
		TagObject(NewObject, "Framework")
		return NewObject
	else
		warn("Invalid ClassName: '" .. ClassName .. "'")
		return nil
	end
end

function Framework:BindToTag(Tag: string, Callback: (Instance: Instance) -> ()): RBXScriptConnection
	if typeof(Tag) ~= "string" or typeof(Callback) ~= "function" then
		error("Invalid arguments for BindToTag", 2)
	end

	for _, Instance in ipairs(CollectionService:GetTagged(Tag)) do
		task.spawn(Callback, Instance)
	end

	return CollectionService:GetInstanceAddedSignal(Tag):Connect(function(Instance)
		task.spawn(Callback, Instance)
	end)
end

function Framework:GetObjects(Tag: string): {Instance}
	if typeof(Tag) ~= "string" then
		error("Invalid Tag name", 2)
	end

	local Objects = CollectionService:GetTagged(Tag)

	if #Objects == 0 then
		warn("No objects found with Tag '" .. Tag .. "'")
	end
	return Objects
end

function Framework:ApplySettings(Object: Instance, Settings: {[string]: any})
	if typeof(Object) ~= "Instance" or typeof(Settings) ~= "table" then
		error("Invalid arguments for ApplySettings", 2)
	end

	for Property, Value in pairs(Settings) do
		local Success = pcall(function()
			Object[Property] = Value
		end)
		if not Success then
			warn("Failed to apply setting '" .. Property .. "' on Object '" .. Object.Name .. "'")
		end
	end
end

function Framework:GenerateUniqueId(): string
	local Id = HttpService:GenerateGUID(false)
	return Id
end

type DetailsType = {[string]: any}

function Framework:LogOperation(Operation: string, Details: DetailsType)
	Operation = SanitizeName(Operation)

	Details = Details or {}
	for Key, Value in pairs(Details) do
	end
end

function Framework:DeepClone(Object: Instance): Instance
	if not Object then
		error("No Object provided for cloning", 2)
	end

	local ClonedObject = Object:Clone()

	for _, Descendant in ipairs(ClonedObject:GetDescendants()) do
		TagObject(Descendant, "Framework")
	end

	return ClonedObject
end

function Framework:TagObject(Object: Instance, Tag: string)
	Tag = SanitizeName(Tag)
	if typeof(Object) ~= "Instance" then
		error("Invalid Object for tagging", 2)
	end

	TagObject(Object, Tag)
end

function Framework:RemoveTag(Object: Instance, Tag: string)
	Tag = SanitizeName(Tag)
	if typeof(Object) ~= "Instance" then
		error("Invalid Object for untagging", 2)
	end

	CollectionService:RemoveTag(Object, Tag)
end

function Framework:GetObjectWithTag(Tag: string): {Instance}
	Tag = SanitizeName(Tag)
	if typeof(Tag) ~= "string" then
		error("Invalid Tag name", 2)
	end

	local Objects = CollectionService:GetTagged(Tag)

	if #Objects == 0 then
		warn("No objects found with Tag '" .. Tag .. "'")
	end

	return Objects
end

return Framework
