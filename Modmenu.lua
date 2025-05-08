-- Fly Script funcional com botão de ativar/desativar (funciona com controles do Roblox)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Criar GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "FlyGui"

local flyButton = Instance.new("TextButton", screenGui)
flyButton.Size = UDim2.new(0, 120, 0, 40)
flyButton.Position = UDim2.new(0, 20, 0, 100)
flyButton.Text = "Ativar Fly"
flyButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
flyButton.TextColor3 = Color3.new(1, 1, 1)
flyButton.Font = Enum.Font.SourceSansBold
flyButton.TextSize = 18

-- Controle de voo
local flying = false
local speed = 80
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

-- Atualização do movimento com controles do jogo
RunService.RenderStepped:Connect(function()
	if flying and bodyVelocity and bodyGyro then
		local moveDir = humanoid.MoveDirection -- moveDir é normalizado automaticamente
		local cam = workspace.CurrentCamera

		bodyVelocity.Velocity = moveDir * speed + Vector3.new(0, 0.1, 0) -- leve impulso vertical para não cair
		bodyGyro.CFrame = cam.CFrame
	end
end)
