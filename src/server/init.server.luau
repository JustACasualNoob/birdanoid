local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local MAX_SPEED = 300

local tracked = {}

local function spawnBird(player)
	local bird = Instance.new("Part")
	bird.Parent = workspace
	bird.Name = player.UserId
	bird.Position = Vector3.yAxis * 1
	bird.CanCollide = false

	bird.Size = Vector3.new(2, 1, 4)
	bird:SetNetworkOwner(player)

	tracked[player] = bird
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(char)
		local hum = char:FindFirstChild("Humanoid")
		if hum then
			hum.EvaluateStateMachine = false
		end

		spawnBird(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	tracked[player]:Destroy()
	tracked[player] = nil
end)

-- speed validation loop
RunService.Heartbeat:Connect(function(dt)
	for player, part in pairs(tracked) do
		if part.AssemblyLinearVelocity.Magnitude > MAX_SPEED then
			warn("Suspicious activity detected for:", player)
			part.AssemblyLinearVelocity = Vector3.zero -- simply set to zero in this case; other ways of countering it may be applied
		end
	end
end)
