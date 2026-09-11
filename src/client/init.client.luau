local Players = game:GetService("Players")

local Birdanoid = require(script:WaitForChild("Birdanoid"))

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local function link()
	local targetBird = workspace:FindFirstChild(player.UserId)
	if targetBird then
		camera.CameraSubject = targetBird
		local birdanoid = Birdanoid.new(targetBird)
	end
end

link()

