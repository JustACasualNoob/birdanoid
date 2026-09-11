local InputSolver = {}
InputSolver.__index = InputSolver

local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera


local function isHeld(key: Enum.KeyCode): boolean
	return UserInputService:IsKeyDown(key)
end

local function resolveIntent(): (number, number)
	local tilt = 0
	local intent = 0

	if isHeld(Enum.KeyCode.A) then tilt -= 1 end
	if isHeld(Enum.KeyCode.D) then tilt += 1 end

	if isHeld(Enum.KeyCode.W) then intent += 1 end
	if isHeld(Enum.KeyCode.S) then intent -= 1 end

	return tilt, intent
end

function InputSolver.new(controller)
	local self = setmetatable({}, InputSolver)
	self.controller = controller
	
	self.jumpRequested = false
	
	UserInputService.InputBegan:Connect(function(inp, proc)
		if proc then return end
		if inp.KeyCode == Enum.KeyCode.Space then
			self.jumpRequested = true
			self.lastJumpPressed = os.clock()
		end
	end)
	
	return self
end

function InputSolver:Step(_, ctx)
	ctx.upPressed = self.jumpRequested
	ctx.lastJumpPressed = self.lastJumpPressed
	self.jumpRequested = false
	
	ctx.upHeld = isHeld(Enum.KeyCode.Space)
	ctx.boostHeld = isHeld(Enum.KeyCode.LeftShift)
	
	ctx.tilt, ctx.forwardIntent = resolveIntent()
	
	local look = Camera.CFrame.LookVector
	local right = Camera.CFrame.RightVector
	ctx.moveDir = look.Magnitude > 0 and look.Unit or Vector3.zero
	ctx.rightDir = right.Magnitude > 0 and right.Unit or Vector3.zero
end

return InputSolver