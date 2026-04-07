--!strict

-- Services:
local RunService = game:GetService("RunService")

return function()
	local remotesFolder: Folder

	local found = script.Parent:FindFirstChild("_remotes") :: Folder?

	-- found could be nil after the first check
	if not found and RunService:IsServer() then
		local _remotesFolder = Instance.new("Folder")
		_remotesFolder.Name = "_remotes"
		_remotesFolder.Parent = script.Parent
		remotesFolder = _remotesFolder
	else
		-- remotesFolder cannot be nil after WaitForChild, if nil then something went wrong
		remotesFolder = script.Parent:WaitForChild("_remotes") :: Folder
	end

	return remotesFolder
end
