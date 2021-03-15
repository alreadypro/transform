local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local R6 = Enum.HumanoidRigType.R6
local R15 = Enum.HumanoidRigType.R15
local INVALID_ENTRY_RIGTYPE = "Invalid entry for RigType"

local function IsServer()
	return RunService:IsServer()
end

local function IsClient()
	return RunService:IsClient()
end

local Transform = {}
Transform.__index = Transform

if IsServer() then
	TransformStorage = {}
end

function Transform.new(player)
	assert(IsServer())
	assert(typeof(player) == "Instance" and player.Parent == Players, "Player must be a Player")
	
	local transformInstance = TransformStorage[player]
	
	if not transformInstance then
		TransformStorage[player] = setmetatable({Player = player}, Transform)
	end
	
	return TransformStorage[player]
end

-- Server

function Transform:R6()
	assert(IsServer())
	
	return self:ChangeRigType(R6)
end

function Transform:R15()
	assert(IsServer())
	
	return self:ChangeRigType(R15)
end

function Transform:ValidateRigType(rigType)
	local typecheck = typeof(rigType)
	
	if typecheck == "string" then
		local success, rigType = pcall(function() return Enum.HumanoidRigType[string.upper(rigType)] end)
		if not success then return false end
		
		rigType = rigType
	elseif typecheck == "EnumItem" then
		local name = rigType.Name
		
		return name == R6.Name or name == R15.Name
	else
		return false
	end
	
	return rigType
end

function Transform:ChangeRigType(rigType)
	assert(IsServer())
	
	local player = self.Player
	assert(player, "Player does not exist")
	
	local character, humanoid = self:_CanTransform()
	
	assert(character and humanoid, "Cannot change RigType for " .. player.Name)
	
	local rigType = self:ValidateRigType(rigType)
	
	if rigType then
		local description = humanoid:GetAppliedDescription()
		
		local rig = Players:CreateHumanoidModelFromDescription(description, rigType)
		description:Destroy()
		
		rig.Name = player.Name
		rig.Humanoid.DisplayName = player.DisplayName
		rig:SetPrimaryPartCFrame(character:GetPrimaryPartCFrame())
		rig:SetAttribute("Transform", true)
		
		player:SetAttribute("Rig", math.random())
		player.Character:Destroy()
		player.Character = rig
		
		rig.Parent = workspace
	end
end

-- Internal

function Transform:_CanTransform()
	local player = self.Player
	if not player then return false end
	
	local character = player.Character
	
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		
		if humanoid and humanoid.Health > 0 then
			return character, humanoid
		end
	end
	
	return false
end

if IsClient() then
	local player = Players.LocalPlayer
	local cameraCFrame = CFrame.new()
	
	player:GetAttributeChangedSignal("Rig"):Connect(function()
		local currentCamera = workspace.CurrentCamera
		cameraCFrame = currentCamera:GetRenderCFrame()
	end)

	return workspace.ChildAdded:Connect(function(rig)
		if rig:GetAttribute("Transform") and rig.Name == player.Name then
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
			
			local currentCamera = workspace.CurrentCamera
			
			currentCamera.CameraType = Enum.CameraType.Scriptable
			currentCamera.CFrame = cameraCFrame
			
			local humanoid = rig:WaitForChild("Humanoid")
			currentCamera.CameraType = Enum.CameraType.Custom
			currentCamera.CameraSubject = humanoid
			
			
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, true)
		end
	end)
end

if IsServer() then
	Players.PlayerRemoving:Connect(function(player)
		local transformInstance = TransformStorage[player]
		
		if transformInstance then
			TransformStorage[player] = nil
		end
	end)
end

return Transform
