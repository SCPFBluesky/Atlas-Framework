--!strict
--!native
-- This Moudle was Written for Atlas-Framework : https://github.com/SCPFBluesky/Atlas-Framework
local HttpService = game:GetService("HttpService")
local Utility = {}

function Utility:GenerateUniqueId()
	return HttpService:GenerateGUID(false)
end

function Utility:LogOperation(Operation, Details)
	print("Operation: " .. Operation .. ", Details: " .. (Details and HttpService:JSONEncode(Details) or "None"))
end

return Utility
