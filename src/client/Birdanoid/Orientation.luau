local Orientation = {}
Orientation.__index = Orientation

local BASE_MAX_SPEED = 300 -- validated on server as well

function Orientation.new(controller)
	local self = setmetatable({}, Orientation)
	self.controller = controller
	self.root = self.controller:GetRoot()
	
	local attachment = Instance.new("Attachment")
    attachment.Parent = self.root

	local align = Instance.new("AlignOrientation")
	align.Attachment0 = attachment
	align.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align.Responsiveness = 15
	align.MaxTorque = math.huge
	align.Parent = self.root

	self.align = align
	
	self.maxBankAngle = math.pi/4 -- 45 degrees
	self.autoTiltStrength = 15
	
	return self
end

function Orientation:HandleAir(ctx)
	local forward = ctx.velocityDir
	local lastDir = self.lastVelocityDir or forward

	-- rotate
	local worldUp = Vector3.new(0, 1, 0)
	local right = forward:Cross(worldUp)

	if right.Magnitude < 0.01 then
		right = Vector3.new(1, 0, 0) -- fallback
	else
		right = right.Unit
	end
	local up = right:Cross(forward).Unit

	-- compute auto tilt
	local turnAxis = lastDir:Cross(forward)
	local turnAmount = turnAxis.Magnitude

	local turnSign = math.sign(turnAxis.Y)
	local autoTilt = turnAmount * turnSign

	local speed = ctx.speed or 0
	local speedFactor = math.clamp(speed / BASE_MAX_SPEED, 0, 1)

	autoTilt *= speedFactor

	-- mix with manual tilt
	local finalTilt = ctx.tilt + autoTilt * self.autoTiltStrength
	local bankAngle = finalTilt * self.maxBankAngle
	local bankedUp = (CFrame.fromAxisAngle(forward, bankAngle):VectorToWorldSpace(up))

	local target = CFrame.fromMatrix(self.root.Position, right, bankedUp)
	self.align.CFrame = target
	
	self.lastVelocityDir = forward
end

function Orientation:HandleGrounded(ctx)
	local moveDir = ctx.velocityDir
	local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z)

	if flatDir.Magnitude <= 0 then return end
	flatDir = flatDir.Unit

	local pos = self.root.Position

	local target = CFrame.lookAt(
		pos,
		pos + flatDir,
		Vector3.new(0, 1, 0)
	)

	self.align.CFrame = target
end

function Orientation:Step(_, ctx)
	if ctx.state == "Grounded" then
		self:HandleGrounded(ctx)
	else
		self:HandleAir(ctx)
	end
end

return Orientation