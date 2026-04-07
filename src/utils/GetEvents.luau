--!strict

-- Services:
local RunService = game:GetService("RunService")

-- Constants:
local NAMES = {
	REMOTE_EVENT = "Event",
	REMOTE_FUNCTION = "Function",
}

return function(namespaceFolder: Folder)
	local remoteEvent: RemoteEvent, remoteFunction: RemoteFunction

	if RunService:IsServer() then
		remoteEvent = namespaceFolder:FindFirstChild("RemoteEvent") :: RemoteEvent? or Instance.new("RemoteEvent")
		remoteEvent.Name = NAMES.REMOTE_EVENT
		remoteEvent.Parent = namespaceFolder

		remoteFunction = namespaceFolder:FindFirstChild("RemoteFunction") :: RemoteFunction?
			or Instance.new("RemoteFunction")
		remoteFunction.Name = NAMES.REMOTE_FUNCTION
		remoteFunction.Parent = namespaceFolder
	else
		remoteEvent = namespaceFolder:WaitForChild(NAMES.REMOTE_EVENT) :: RemoteEvent
		remoteFunction = namespaceFolder:WaitForChild(NAMES.REMOTE_FUNCTION) :: RemoteFunction
	end

	return remoteEvent, remoteFunction
end
