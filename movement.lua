-- movement.lua - Movement Enhancement Module
-- No UI logic, only movement functionality

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Module export
local Movement = {}

-- ================= MOVEMENT CONFIG =================
getgenv().MovementConfig = {
    Speed = {
        Enabled = false,
        Value = 16,
        Default = 16
    },
    JumpPower = {
        Enabled = false,
        Value = 50,
        Default = 50
    },
    Fly = {
        Enabled = false,
        Speed = 50,
        VerticalSpeed = 50
    },
    Noclip = {
        Enabled = false
    },
    InfiniteJump = {
        Enabled = false
    }
}

-- ================= STORAGE =================
local flyConnection
local noclipConnection
local infiniteJumpConnection
local originalValues = {}

-- ================= UTILITY FUNCTIONS =================
local function getHumanoid()
    if LocalPlayer.Character then
        return LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local function getRootPart()
    if LocalPlayer.Character then
        return LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

-- ================= SPEED SYSTEM =================
local function updateSpeed()
    local humanoid = getHumanoid()
    if not humanoid then return end
    
    if MovementConfig.Speed.Enabled then
        if not originalValues.WalkSpeed then
            originalValues.WalkSpeed = humanoid.WalkSpeed
        end
        humanoid.WalkSpeed = MovementConfig.Speed.Value
    else
        if originalValues.WalkSpeed then
            humanoid.WalkSpeed = originalValues.WalkSpeed
            originalValues.WalkSpeed = nil
        end
    end
end

-- ================= JUMP POWER SYSTEM =================
local function updateJumpPower()
    local humanoid = getHumanoid()
    if not humanoid then return end
    
    if MovementConfig.JumpPower.Enabled then
        if not originalValues.JumpPower then
            originalValues.JumpPower = humanoid.JumpPower
        end
        humanoid.JumpPower = MovementConfig.JumpPower.Value
    else
        if originalValues.JumpPower then
            humanoid.JumpPower = originalValues.JumpPower
            originalValues.JumpPower = nil
        end
    end
end

-- ================= FLY SYSTEM =================
local function startFly()
    if flyConnection then return end
    
    local root = getRootPart()
    local humanoid = getHumanoid()
    if not root or not humanoid then return end
    
    -- Create BodyVelocity for smooth flight
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = root
    
    -- Create BodyGyro for orientation
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
    bodyGyro.P = 10000
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root
    
    flyConnection = RunService.Heartbeat:Connect(function()
        if not MovementConfig.Fly.Enabled then
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            if flyConnection then flyConnection:Disconnect() end
            flyConnection = nil
            return
        end
        
        local camera = workspace.CurrentCamera
        local moveDirection = Vector3.new(0, 0, 0)
        
        -- Forward/Backward
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + camera.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - camera.CFrame.LookVector
        end
        
        -- Left/Right
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - camera.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + camera.CFrame.RightVector
        end
        
        -- Up/Down
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or 
           UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        -- Normalize and apply speed
        if moveDirection.Magnitude > 0 then
            moveDirection = moveDirection.Unit
            bodyVelocity.Velocity = moveDirection * MovementConfig.Fly.Speed
        else
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        
        -- Update orientation to face camera direction
        bodyGyro.CFrame = camera.CFrame
    end)
end

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    
    local root = getRootPart()
    if root then
        for _, obj in ipairs(root:GetChildren()) do
            if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro") then
                obj:Destroy()
            end
        end
    end
end

-- ================= NOCLIP SYSTEM =================
local function startNoclip()
    if noclipConnection then return end
    
    noclipConnection = RunService.Stepped:Connect(function()
        if not MovementConfig.Noclip.Enabled then
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            return
        end
        
        if LocalPlayer.Character then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

-- ================= INFINITE JUMP SYSTEM =================
local function startInfiniteJump()
    if infiniteJumpConnection then return end
    
    infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if not MovementConfig.InfiniteJump.Enabled then
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
            return
        end
        
        local humanoid = getHumanoid()
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function stopInfiniteJump()
    if infiniteJumpConnection then
        infiniteJumpConnection:Disconnect()
        infiniteJumpConnection = nil
    end
end

-- ================= CHARACTER HANDLING =================
local function setupCharacter()
    updateSpeed()
    updateJumpPower()
    
    if MovementConfig.Fly.Enabled then
        stopFly()
        task.wait(0.1)
        startFly()
    end
    
    if MovementConfig.Noclip.Enabled then
        stopNoclip()
        startNoclip()
    end
    
    if MovementConfig.InfiniteJump.Enabled then
        stopInfiniteJump()
        startInfiniteJump()
    end
end

-- ================= INITIALIZATION =================
function Movement.Init()
    -- Setup for current character
    if LocalPlayer.Character then
        setupCharacter()
    end
    
    -- Setup for future characters
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        setupCharacter()
    end)
    
    print("✅ Movement Module Loaded!")
end

-- ================= EXPORT FUNCTIONS =================
function Movement.ToggleSpeed(enabled)
    MovementConfig.Speed.Enabled = enabled
    updateSpeed()
end

function Movement.SetSpeed(value)
    MovementConfig.Speed.Value = value
    if MovementConfig.Speed.Enabled then
        updateSpeed()
    end
end

function Movement.ToggleJumpPower(enabled)
    MovementConfig.JumpPower.Enabled = enabled
    updateJumpPower()
end

function Movement.SetJumpPower(value)
    MovementConfig.JumpPower.Value = value
    if MovementConfig.JumpPower.Enabled then
        updateJumpPower()
    end
end

function Movement.ToggleFly(enabled)
    MovementConfig.Fly.Enabled = enabled
    if enabled then
        startFly()
    else
        stopFly()
    end
end

function Movement.SetFlySpeed(value)
    MovementConfig.Fly.Speed = value
end

function Movement.ToggleNoclip(enabled)
    MovementConfig.Noclip.Enabled = enabled
    if enabled then
        startNoclip()
    else
        stopNoclip()
    end
end

function Movement.ToggleInfiniteJump(enabled)
    MovementConfig.InfiniteJump.Enabled = enabled
    if enabled then
        startInfiniteJump()
    else
        stopInfiniteJump()
    end
end

function Movement.Unload()
    -- Restore original values
    local humanoid = getHumanoid()
    if humanoid then
        if originalValues.WalkSpeed then
            humanoid.WalkSpeed = originalValues.WalkSpeed
        end
        if originalValues.JumpPower then
            humanoid.JumpPower = originalValues.JumpPower
        end
    end
    
    -- Stop all features
    stopFly()
    stopNoclip()
    stopInfiniteJump()
    
    print("✅ Movement Module Unloaded!")
end

return Movement