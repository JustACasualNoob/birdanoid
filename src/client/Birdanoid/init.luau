local Birdanoid = {}
Birdanoid.__index = Birdanoid

local RunService = game:GetService("RunService")

function Birdanoid.new(model)
	local self = setmetatable({}, Birdanoid)
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

function Birdanoid:Start()
	if self.loop then self.loop:Disconnect() end
	self.loop = RunService.RenderStepped:Connect(function(dt)
		
		local ctx = {}
		
		-- must be in the same order as init
		self.input:Step(dt, ctx)
		self.ground:Step(dt, ctx)
		self.state:Step(dt, ctx)
		self.movement:Step(dt, ctx)
		self.orientation:Step(dt, ctx)
	end)
end

function Birdanoid:Stop()
	if self.loop then
		self.loop:Disconnect()
		self.loop = nil
	end
end

function Birdanoid:GetModel()
	return self.model
end

function Birdanoid:GetRoot()
	--return self.model:FindFirstChild("Root")
    return self.model -- only in this specific case, where model <=> part <=> root
end

return Birdanoid