local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local flying = false
local noclipping = false
local flySpeed = 100


local bv, bg = nil, nil
local noclipConnection = nil


local function startFly()
    if flying then return end
    flying = true
    humanoid.PlatformStand = true
    
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = root
    
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bg.P = 12500
    bg.Parent = root
    
    print("Fly ВКЛ | E — выключить")
end

local function stopFly()
    if not flying then return end
    flying = false
    humanoid.PlatformStand = false
    
    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
    
    print("Fly ВЫКЛ")
end

-- ====================== NOCLIP ======================
local function startNoclip()
    if noclipping then return end
    noclipping = true
    
    noclipConnection = RunService.RenderStepped:Connect(function()
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
    
    print("Noclip ВКЛ | Q — выключить")
end

local function stopNoclip()
    if not noclipping then return end
    noclipping = false
    
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
    
    print("Noclip ВЫКЛ")
end


RunService.Heartbeat:Connect(function()
    if not flying or not bv or not bg then return end
    
    local cam = workspace.CurrentCamera
    local moveDir = Vector3.new(0, 0, 0)
    
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
    
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit * flySpeed
    end
    
    bv.Velocity = moveDir
    bg.CFrame = cam.CFrame
end)


UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.E then
        if flying then stopFly() else startFly() end
    elseif input.KeyCode == Enum.KeyCode.Q then
        if noclipping then stopNoclip() else startNoclip() end
    end
end)


player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    root = newChar:WaitForChild("HumanoidRootPart")
    
    task.wait(0.6)
    if flying then
        flying = false
        startFly()
    end
    if noclipping then
        noclipping = false
        startNoclip()
    end
end)
