--!strict

-- Services:
local RunService = game:GetService("RunService")

return function(namespace: string, remotesFolder: Folder)
	local namespaceFolder: Folder

	if RunService:IsServer() then
		if remotesFolder:FindFirstChild(namespace) then
			namespaceFolder = remotesFolder:FindFirstChild(namespace) :: Folder
		else
			namespaceFolder = Instance.new("Folder")
			namespaceFolder.Name = namespace
			namespaceFolder.Parent = remotesFolder
		end
	else
		namespaceFolder = remotesFolder:WaitForChild(namespace) :: Folder
	end

	return namespaceFolder
end
