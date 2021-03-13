local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Transform = require(ReplicatedStorage.transform)

local function PlayerAdded(player)
	player.Chatted:Connect(function(message)
		if string.sub(message, 1, 1) == "/" then
			local rigType = Transform:ValidateRigType(string.upper(string.sub(message, 2, string.len(message))))
			
			if rigType then
				local transform = Transform.new(player)
				transform:ChangeRigType(rigType)				
			end
		end
	end)
end

for _, player in next, Players:GetPlayers() do
	PlayerAdded(player)
end

Players.PlayerAdded:Connect(PlayerAdded)

while wait(1) do
	for _, player in next, Players:GetPlayers() do
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			
			if humanoid then
				pcall(function()
					Transform.new(player):ChangeRigType(humanoid.RigType.Name == "R6" and "R15" or "R6")
				end)
			end
		end
	end
end