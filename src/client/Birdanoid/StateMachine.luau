local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new(controller)
	local self = setmetatable({}, StateMachine)
	self.controller = controller
	
	self.state = "Grounded"
	self.lastGroundedTime = 0
	
	self.coyoteTime = 0.15
	
	return self
end

function StateMachine:Step(_, ctx)
		--[[ expects: {
		upPressed = bool,
		upHeld = bool,
		boostHeld = bool,
		tilt = num,
		forwardIntent = num,
		moveDir = num,
		
		groundDist = num,
		groundNormal = vec3,
		groundPos = vec3,
		grounded = bool
	}]]
		
	local grounded = ctx.grounded
	if grounded then
		self.lastGroundedTime = os.clock()
	end
	
	local canJump = (os.clock() - self.lastGroundedTime) <= self.coyoteTime
	local newState

	if ctx.grounded then
		newState = "Grounded"
	else
		newState = "Air"
	end

	-- jump override
	if ctx.upPressed and canJump then
		newState = "Air"
	end

	-- flight override
	if (ctx.upPressed or ctx.upHeld) and not ctx.grounded then
		newState = "Flying"
	end
	
	print(newState)
	
	self.state = newState
	ctx.state = newState
end

return StateMachine