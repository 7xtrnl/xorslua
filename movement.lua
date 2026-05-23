-- movement.lua
local Movement = {}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local flyEnabled = false
local flySpeed = 50
local walkSpeed = 16

-- WalkSpeed
Movement.SetWalkSpeed = function(speed)
    walkSpeed = speed
    local char = lp.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = speed
        end
    end
end

-- Fly
Movement.ToggleFly = function(enabled)
    flyEnabled = enabled
    local char = lp.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if enabled then
        -- Enable Fly
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = root

        RunService.Heartbeat:Connect(function()
            if not flyEnabled or not root.Parent then return end
            local cam = workspace.CurrentCamera
            local moveDir = Vector3.new(0, 0, 0)
            
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            
            if moveDir.Magnitude > 0 then
                bv.Velocity = moveDir.Unit * flySpeed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        -- Disable Fly
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("BodyVelocity") then v:Destroy() end
        end
    end
end

return Movement
