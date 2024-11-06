--!nocheck
--!native
-- This Moudle was Written for Atlas-Framework : https://github.com/SCPFBluesky/Atlas-Framework
local HttpService = game:GetService("HttpService")
local Utility = {}

@native function Utility:GenerateUniqueId()
	return HttpService:GenerateGUID(false)
end;

@native function Utility:LogOperation(Operation, Details)
	print("Operation: " .. Operation .. ", Details: " .. (Details and HttpService:JSONEncode(Details) or "None"))
end;

return Utility
