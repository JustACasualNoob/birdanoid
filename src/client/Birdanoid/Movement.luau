local Movement = {}
Movement.__index = Movement

local function getLinearVel(parent): LinearVelocity
	local attachment = parent:FindFirstChild("RootAttachment")
		or Instance.new("Attachment", parent)

	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = attachment
	lv.RelativeTo = Enum.ActuatorRelativeTo.World
	lv.MaxForce = 1e6
	lv.Parent = parent

	return lv
end

function Movement.new(controller, birdData)
	local self = setmetatable({}, Movement)
	self.controller = controller
	
	self.root = self.controller:GetRoot()
	self.linearVel = getLinearVel(self.root)
	
    if not birdData then
        -- example data
        self.walkSpeed = 12
        self.airControl = 5
        self.jumpPower = 20
        self.flapPower = 12
        
        self.drag = 0.05
        self.tiltStrength = 0.5
        
        self.hipHeight = 1
        self.stiffness = 25
        self.gravity = 20
        
        self.flapCd = 1.2
    end
		
    self.nextAllowedFlap = 0

	return self
end

function Movement:HandleGround(ctx, dt) 
	local moveDir = ctx.moveDir 
	local intent = ctx.forwardIntent 
	
	local flatDir = Vector3.new(moveDir.X, 0, moveDir.Z) 
	if flatDir.Magnitude > 0 then 
		flatDir = flatDir.Unit 
	end 
	
	local current = self.linearVel.VectorVelocity 
	
	local targetHorizontal = flatDir * intent * self.walkSpeed 
	local currentHorizontal = Vector3.new(current.X, 0, current.Z) 
	local newHorizontal = currentHorizontal:Lerp(targetHorizontal, 10 * dt) 
	
	local rootY = self.root.Position.Y 
	local targetY = ctx.groundPos.Y + self.hipHeight 
	local diff = targetY - rootY 
	local vertical = diff * self.stiffness 
	
	self.linearVel.VectorVelocity = newHorizontal + Vector3.new(0, vertical, 0) 
	local new = self.linearVel.VectorVelocity 
	local mag = new.Magnitude
	ctx.velocityDir = mag > 0 and new.Unit or Vector3.zero 
	ctx.speed = mag
end

function Movement:HandleAir(ctx, dt)
	local vel = self.linearVel.VectorVelocity

	-- gravity (energy conversion)
	vel += Vector3.new(0, -self.gravity, 0) * dt

	-- steering (preserve speed)
	local speed = vel.Magnitude
	if speed > 0 then
		local currentDir = vel.Unit
		local targetDir = ctx.moveDir
		local rightDir = ctx.rightDir

		-- tilt influence (sideways steering bias)
		local tiltStrength = self.tiltStrength or 0.5
		local tiltOffset = rightDir * ctx.tilt * tiltStrength

		targetDir = (targetDir + tiltOffset)
		if targetDir.Magnitude > 0 then
			targetDir = targetDir.Unit
		end
		
		local newDir = currentDir:Lerp(targetDir, self.airControl * dt)
		vel = newDir.Unit * speed
	end

	-- drag (optional but recommended)
	vel *= (1 - self.drag * dt)
	self.linearVel.VectorVelocity = vel
	
	local mag = vel.Magnitude
	ctx.velocityDir = mag > 0 and vel.Unit or Vector3.zero 
	ctx.speed = mag
end

function Movement:Step(dt, ctx)
	--[[ expects: {
		upHeld = bool,
		upPressed = bool,
		boostHeld = bool,
		tilt = num,
		forwardIntent = num,
		moveDir = num,
		
		groundDist = num,
		groundNormal = vec3,
		groundPos = vec3,
		grounded = bool,
		
		state = string,
	}]]
			
	if ctx.state == "Grounded" then
		self:HandleGround(ctx, dt)
	else
		self:HandleAir(ctx, dt)
	end
	
	-- handle jumping/flapping
	if ctx.upPressed and ctx.grounded then
		self.linearVel.VectorVelocity += Vector3.new(0, self.jumpPower, 0)
	elseif (ctx.upHeld or ctx.upPressed) and ctx.state == "Flying" then
		if os.clock() < self.nextAllowedFlap then return end
		self.nextAllowedFlap = os.clock() + self.flapCd

		local diff = self.jumpPower - self.linearVel.VectorVelocity.Y
		local multiplier = diff > 0 and diff/10 or 1

		self.linearVel.VectorVelocity += Vector3.new(0, self.flapPower*multiplier, 0)
	end
end

return Movement