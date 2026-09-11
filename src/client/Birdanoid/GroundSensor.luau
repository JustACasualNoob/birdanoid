local GroundSensor = {}
GroundSensor.__index = GroundSensor

function GroundSensor.new(controller)
	local self = setmetatable({}, GroundSensor)
	self.controller = controller
	
	self.rayLength = 2
	self.groundedThreshold = 1
	
	self.rayParams = RaycastParams.new()
	self.rayParams.FilterType = Enum.RaycastFilterType.Exclude
	self.rayParams.FilterDescendantsInstances = {self.controller:GetModel()}
	
	return self
end

function GroundSensor:Step(_, ctx)
	--[[ expects: {
		requestJump = bool,
		requestFlap = bool,
		requestBoost = bool,
		tilt = num,
		forwardIntent = num,
		moveDir = num
	}]]
	
	local root = self.controller:GetRoot()
	if not root then return end
	
	local origin = root.Position
	local dir = Vector3.new(0, -self.rayLength, 0)
	
	local result = workspace:Raycast(origin, dir, self.rayParams)
	
	if result then
		local dist = (result.Position - origin).Magnitude
		local justPressedUp = (os.clock() - (ctx.lastJumpPressed or 0)) < 0.1
		
		ctx.groundDist = dist
		ctx.groundPos = result.Position
		ctx.groundNormal = result.Normal
		ctx.grounded = dist < self.groundedThreshold and not justPressedUp
	else
		ctx.groundDist = math.huge
		ctx.groundPos = nil
		ctx.groundNormal = nil
		ctx.grounded = false
	end
end

return GroundSensor