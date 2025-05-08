local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Interface
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "FlyGui"

-- Botão Fly
local flyButton = Instance.new("TextButton", screenGui)
flyButton.Size = UDim2.new(0, 120, 0, 40)
flyButton.Position = UDim2.new(0, 20, 0, 100)
flyButton.Text = "Ativar Fly"
flyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
flyButton.TextColor3 = Color3.new(1, 1, 1)
flyButton.Font = Enum.Font.SourceSansBold
flyButton.TextSize = 18

-- Barra de velocidade
local sliderFrame = Instance.new("Frame", screenGui)
sliderFrame.Size = UDim2.new(0, 120, 0, 30)
sliderFrame.Position = UDim2.new(0, 20, 0, 150)
sliderFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sliderFrame.BorderSizePixel = 0

local slider = Instance.new("Frame", sliderFrame)
slider.Size = UDim2.new(0.5, 0, 1, 0) -- valor inicial (50%)
slider.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
slider.BorderSizePixel = 0

local dragging = false
local maxSpeed = 200
local speed = 80 -- valor inicial

-- Função para atualizar a velocidade baseada na posição do slider
local function updateSlider(inputX)
	local relative = math.clamp((inputX - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
	slider.Size = UDim2.new(relative, 0, 1, 0)
	speed = math.floor(relative * maxSpeed)
end

-- Detectar movimento do mouse ou dedo no slider
sliderFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		updateSlider(input.Position.X)
	end
end)

sliderFrame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

RunService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateSlider(input.Position.X)
	end
end)

-- Fly lógica
local flying = false
local bodyGyro, bodyVelocity

local function startFlying()
	if flying then return end
	flying = true

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.P = 1e4
	bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bodyGyro.CFrame = rootPart.CFrame
	bodyGyro.Parent = rootPart

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bodyVelocity.P = 1e4
	bodyVelocity.Parent = rootPart

	humanoid.PlatformStand = true
	flyButton.Text = "Desativar Fly"
end

local function stopFlying()
	flying = false
	if bodyGyro then bodyGyro:Destroy() end
	if bodyVelocity then bodyVelocity:Destroy() end
	humanoid.PlatformStand = false
	flyButton.Text = "Ativar Fly"
end

flyButton.MouseButton1Click:Connect(function()
	if flying then
		stopFlying()
	else
		startFlying()
	end
end)

-- Movimento baseado na câmera e slider
RunService.RenderStepped:Connect(function()
	if flying and bodyVelocity and bodyGyro then
		local cam = workspace.CurrentCamera
		local lookVector = cam.CFrame.LookVector
		local moveDir = humanoid.MoveDirection

		local inputMagnitude = moveDir.Magnitude
		local flyVector = lookVector.Unit * inputMagnitude * speed

		bodyVelocity.Velocity = flyVector
		bodyGyro.CFrame = cam.CFrame
	end
end)
