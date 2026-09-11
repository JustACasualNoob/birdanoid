local Controller = {}
Controller.__index = Controller

local RunService = game:GetService("RunService")

function Controller.new(model)
	local self = setmetatable({}, Controller)
	self.model = model
		
	-- Must be in this order
	self.input = require(script:WaitForChild("InputSolver")).new(self)
	self.ground = require(script:WaitForChild("GroundSensor")).new(self)
	self.state = require(script:WaitForChild("StateMachine")).new(self)
	self.movement = require(script:WaitForChild("Movement")).new(self)
	self.orientation = require(script:WaitForChild("Orientation")).new(self)
	
	self:Start()
	
	return self
end

function Controller:Start()
	if self.loop then self.loop:Disconnect() end
	self.loop = RunService.RenderStepped:Connect(function(dt)
		
		local ctx = {}
		
		-- order is important
		self.input:Step(dt, ctx)
		self.ground:Step(dt, ctx)
		self.state:Step(dt, ctx)
		self.movement:Step(dt, ctx)
		self.orientation:Step(dt, ctx)
		self.visuals:Step(dt, ctx)		
	end)
end

function Controller:Stop()
	if self.loop then
		self.loop:Disconnect()
		self.loop = nil
	end
end

function Controller:GetModel()
	return self.model
end

function Controller:GetRoot()
	--return self.model:FindFirstChild("Root")
    return self.model -- only in this specific case, where model <=> part <=> root
end

return Controller