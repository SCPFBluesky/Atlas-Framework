--[[
	Writer: @SCPF_RedSky
	Name : ObjectManager.lua
	Date : 10/1/24
	ClassName : ModuleScript
	RunTime: Shared
	Description: 
	ObjectManager for Atlas Framework
--]]
--!native
--!nonstrict
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local ObjectManager = {}
ObjectManager.__index = ObjectManager

-- Cache for loaded modules to prevent tons of requires
local ModuleCache = {}
local ObjectCache = {}

-- load ObjectManager with settings
@native function ObjectManager:new()
	local instance = setmetatable({}, self)
	return instance
end;

-- Create an object with the "Framework" tag for simple stuf
@native function ObjectManager:CreateObject(ClassName)
	assert(type(ClassName) == "string", "ClassName must be a string")

	local success, newObject = pcall(function()
		return Instance.new(ClassName)
	end);

	if success and newObject then
		CollectionService:AddTag(newObject, "Framework")
		return newObject
	else
		warn(string.format("[Atlas/ObjectManager] Failed to create object of class '%s'", ClassName))
		return nil
	end;
end;

-- Load the module
@native function ObjectManager:LoadModule(ModuleName)
	assert(type(ModuleName) == "string", "ModuleName must be a string")

	-- Check the cache first
	if ModuleCache[ModuleName:lower()] then
		return ModuleCache[ModuleName:lower()]
	end

	local modules = CollectionService:GetTagged("FrameworkModule")
	for _, module in ipairs(modules) do
		if module:IsA("ModuleScript") and module.Name:lower() == ModuleName:lower() then
			local success, result = pcall(function()
				return require(module)
			end);
			if success then
				ModuleCache[ModuleName:lower()] = result
				return result
			else
				warn(string.format("[Atlas/ObjectManager] Failed to load module '%s': %s", ModuleName, result))
				return nil
			end;
		end;
	end;
	warn(string.format("[Atlas/ObjectManager] Module '%s' not found", ModuleName))
	return nil
end;

@native function ObjectManager:GetObject(ObjectName, Timeout)
	assert(type(ObjectName) == "string", "ObjectName must be a string")
	assert(Timeout == nil or type(Timeout) == "number", "Timeout must be a number or nil")
	local startTime = tick()
	local objectFound = nil
	local searchCompleted = false
	local connection
	if ObjectCache[ObjectName] then
		return ObjectCache[ObjectName]
	end;

	

	@native local function handleObjectFound(object)
		if object.Name == ObjectName then
			ObjectCache[ObjectName] = object
			objectFound = object
			searchCompleted = true
			warn(string.format("[Atlas/ObjectManager] Object '%s' was found after %.2f seconds.", ObjectName, tick() - startTime))
		end;
	end;

	connection = CollectionService:GetInstanceAddedSignal("Framework"):Connect(function(object)
		handleObjectFound(object)
	end);

	 local objects = CollectionService:GetTagged("Framework")
	for _, object in ipairs(objects) do
		handleObjectFound(object)
		if objectFound then
			connection:Disconnect() 
			return objectFound
		end;
	end;

	while not searchCompleted do
		if Timeout and (tick() - startTime) >= Timeout then
			warn(string.format("[Atlas/ObjectManager] Timeout reached while searching for object '%s' after %.2f seconds", ObjectName, Timeout))
			connection:Disconnect()
			return nil
		end;

		task.wait()

		if ObjectCache[ObjectName] then
			connection:Disconnect()
			warn(string.format("[Atlas/ObjectManager] Object '%s' was found after %.2f seconds.", ObjectName, tick() - startTime))
			return ObjectCache[ObjectName]
		end;
	end;

	connection:Disconnect()

	if not objectFound then
		warn(string.format("[Atlas/ObjectManager] Object '%s' was not found after %.2f seconds.", ObjectName, tick() - startTime))
	end;

	return objectFound
end;

@native function ObjectManager:ApplySettings(Object, Settings)
	assert(typeof(Object) == "Instance", "Object must be an Instance")
	assert(type(Settings) == "table", "Settings must be a table")

	for property, value in pairs(Settings) do
		if Object:FindFirstChild(property) or Object[property] ~= nil then
			local success, errorMessage = pcall(function()
				Object[property] = value
			end);
			if not success then
				warn(string.format("[Atlas/ObjectManager] Failed to apply setting '%s' on object '%s': %s", property, Object.Name, errorMessage))
			end;
		else
			warn(string.format("[Atlas/ObjectManager] Property '%s' does not exist on object '%s'", property, Object.Name))
		end;
	end;
end;

@native function ObjectManager:ClearFrameworkTag()
	local objects = CollectionService:GetTagged("Framework")
	for _, object in ipairs(objects) do
		CollectionService:RemoveTag(object, "Framework")
	end;
end;

@native function ObjectManager:ReloadModules()
	ObjectCache = {}
	local modules = CollectionService:GetTagged("FrameworkModule")
	for _, module in ipairs(modules) do
		if module:IsA("ModuleScript") then
			local moduleName = module.Name:lower()
			local success, result = pcall(function()
				return require(module)
			end);
			if success then
				ModuleCache[moduleName] = result
			else
				warn(string.format("[Atlas/ObjectManager] Failed to reload module '%s': %s", module.Name, result))
			end;
		end;
	end;
end;

return ObjectManager
