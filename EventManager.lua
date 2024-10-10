--!strict
--!native
-- This Moudle was Written for Atlas-Framework : https://github.com/SCPFBluesky/Atlas-Framework
local CollectionService = game:GetService("CollectionService")
local EventManager = {}

@native function EventManager:BindToTag(Tag, Callback)
	for _, instance in ipairs(CollectionService:GetTagged(Tag)) do
		task.spawn(Callback, instance)
	end
	return CollectionService:GetInstanceAddedSignal(Tag):Connect(function(instance)
		task.spawn(Callback, instance)
	end);
end;

return EventManager
