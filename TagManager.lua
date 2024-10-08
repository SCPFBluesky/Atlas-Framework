--!strict
--!native
-- This Moudle was Written for Atlas-Framework : https://github.com/SCPFBluesky/Atlas-Framework
local CollectionService = game:GetService("CollectionService")
local TagManager = {}

@native function TagManager:TagObject(Object, Tag)
	if not CollectionService:HasTag(Object, Tag) then
		CollectionService:AddTag(Object, Tag)
	end;
end;

@native function TagManager:RemoveTag(Object, Tag)
	if CollectionService:HasTag(Object, Tag) then
		CollectionService:RemoveTag(Object, Tag)
	end;
end;

@native function TagManager:GetObjectsWithTag(Tag)
	return CollectionService:GetTagged(Tag)
end;

return TagManager
