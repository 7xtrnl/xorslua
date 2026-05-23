-- visuals.lua - Pure ESP Logic Module
-- No UI logic, only ESP functionality
 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
 
-- Module export
local Visuals = {}
 
-- ================= ESP CONFIG =================
getgenv().Config = {
    Box = { 
        Filled = { 
            Enable = true, 
            GradientRotationSpeed = 25, 
            Transparency = { Start = 0.55, End = 0.88 } 
        }, 
        Outline = { 
            Enable = true, 
            Thickness = 1.5 
        } 
    },
    Name = { 
        Enable = true, 
        Color = Color3.new(1,1,1), 
        Size = 18,
        ShowDisplayName = true,
        ShowUsername = false
    },
    HealthText = { 
        Enable = true,
        Color = Color3.new(1, 1, 1)
    },
    Distance = { 
        Enable = true,
        Color = Color3.fromRGB(200, 200, 200),
        ShowStuds = false
    },
    Skeleton = {
        Enable = false,
        Color = Color3.new(1, 1, 1),
        Thickness = 1
    },
    Tracer = {
        Enable = false,
        Color = Color3.new(1, 1, 1),
        Thickness = 1,
        Origin = "Bottom"
    },
    HealthBar = {
        Enable = true,
        ShowPercentage = true
    },
    RemoveDisplayName = false
}
 
-- ================= FORCEFIELD CONFIG =================
getgenv().ForceFieldConfig = {
    Enabled = false,
    Color = Color3.fromRGB(35, 35, 50),
    Transparency = 0.35,
    Reflectance = 0.65,
    ExcludeHead = false
}
 
-- ================= CACHES =================
local cache = {}
local skeletonCache = {}
local tracerCache = {}
local isLoaded = false
local deadPlayers = {}
local OriginalPartProperties = {}
 
-- ================= UTILITY FUNCTIONS =================
local function getBodyParts(character)
    local parts = {
        character:FindFirstChild("Head"),
        character:FindFirstChild("HumanoidRootPart"),
    }
    
    if character:FindFirstChild("UpperTorso") then
        table.insert(parts, character:FindFirstChild("UpperTorso"))
        table.insert(parts, character:FindFirstChild("LowerTorso"))
        table.insert(parts, character:FindFirstChild("LeftUpperArm"))
        table.insert(parts, character:FindFirstChild("LeftLowerArm"))
        table.insert(parts, character:FindFirstChild("LeftHand"))
        table.insert(parts, character:FindFirstChild("RightUpperArm"))
        table.insert(parts, character:FindFirstChild("RightLowerArm"))
        table.insert(parts, character:FindFirstChild("RightHand"))
        table.insert(parts, character:FindFirstChild("LeftUpperLeg"))
        table.insert(parts, character:FindFirstChild("LeftLowerLeg"))
        table.insert(parts, character:FindFirstChild("LeftFoot"))
        table.insert(parts, character:FindFirstChild("RightUpperLeg"))
        table.insert(parts, character:FindFirstChild("RightLowerLeg"))
        table.insert(parts, character:FindFirstChild("RightFoot"))
    else
        table.insert(parts, character:FindFirstChild("Torso"))
        table.insert(parts, character:FindFirstChild("Left Arm"))
        table.insert(parts, character:FindFirstChild("Right Arm"))
        table.insert(parts, character:FindFirstChild("Left Leg"))
        table.insert(parts, character:FindFirstChild("Right Leg"))
    end
    
    return parts
end
 
local function getPerfectBoundingBox(character)
    local parts = getBodyParts(character)
    local points2D = {}
    
    for _, part in ipairs(parts) do
        if part and part.Parent then
            local cf, size = part.CFrame, part.Size
            local half = size / 2
            local corners = {
                cf * CFrame.new(-half.X,  half.Y, -half.Z),
                cf * CFrame.new( half.X,  half.Y, -half.Z),
                cf * CFrame.new( half.X, -half.Y, -half.Z),
                cf * CFrame.new(-half.X, -half.Y, -half.Z),
                cf * CFrame.new(-half.X,  half.Y,  half.Z),
                cf * CFrame.new( half.X,  half.Y,  half.Z),
                cf * CFrame.new( half.X, -half.Y,  half.Z),
                cf * CFrame.new(-half.X, -half.Y,  half.Z),
            }
            for _, corner in ipairs(corners) do
                local pos, onScreen = Camera:WorldToViewportPoint(corner.Position)
                if onScreen then
                    table.insert(points2D, Vector2.new(pos.X, pos.Y))
                end
            end
        end
    end
    
    if #points2D < 4 then
        local root = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        if root and head then
            local rootPos = Camera:WorldToViewportPoint(root.Position)
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.5, 0))
            local footEst = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 4.5, 0))
            if rootPos.Z > 0 and headPos.Z > 0 and footEst.Z > 0 then
                points2D = {Vector2.new(headPos.X, headPos.Y), Vector2.new(footEst.X, footEst.Y)}
            end
        end
        if #points2D < 2 then return nil end
    end
    
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    
    for _, pt in ipairs(points2D) do
        minX = math.min(minX, pt.X)
        maxX = math.max(maxX, pt.X)
        minY = math.min(minY, pt.Y)
        maxY = math.max(maxY, pt.Y)
    end
    
    local width = maxX - minX
    local height = maxY - minY
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        local dist = (root.Position - Camera.CFrame.Position).Magnitude
        if dist > 500 then
            width = width * (1 + (dist - 500) / 1200)
        end
    end
    
    if width < 1 or height < 1 then return nil end
    
    return Vector2.new(math.floor(minX + 0.5), math.floor(minY + 0.5)),
           Vector2.new(math.floor(width + 0.5), math.floor(height + 0.5))
end
 
local function formatDistance(studs)
    if Config.Distance.ShowStuds then
        return "[" .. math.floor(studs) .. " studs]"
    else
        local meters = math.floor(studs / 3)
        if meters < 1000 then
            return "[" .. meters .. "m]"
        else
            return "[" .. string.format("%.1f", meters / 1000) .. "km]"
        end
    end
end
 
local function calculateTextSize(distance)
    local baseSize = Config.Name.Size
    if distance < 100 then return baseSize + 2
    elseif distance < 500 then return math.floor(baseSize * 1.1)
    elseif distance < 1000 then return math.floor(baseSize * 0.95)
    elseif distance < 2000 then return math.floor(baseSize * 0.8)
    else return math.floor(baseSize * 0.65) end
end
 
local function newText()
    local t = Drawing.new("Text")
    t.Font = 2
    t.Outline = true
    t.OutlineColor = Color3.new(0, 0, 0)
    t.Center = true
    t.Size = 16
    t.Visible = false
    return t
end
 
-- ================= SKELETON SYSTEM =================
local function getSkeletonConnections(character)
    if character:FindFirstChild("UpperTorso") then
        return {
            {"Head", "UpperTorso"},
            {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"},
            {"UpperTorso", "RightUpperArm"},
            {"LeftUpperArm", "LeftLowerArm"},
            {"RightUpperArm", "RightLowerArm"},
            {"LowerTorso", "LeftUpperLeg"},
            {"LowerTorso", "RightUpperLeg"},
            {"LeftUpperLeg", "LeftLowerLeg"},
            {"RightUpperLeg", "RightLowerLeg"}
        }
    else
        return {
            {"Head", "Torso"},
            {"Torso", "Left Arm"},
            {"Torso", "Right Arm"},
            {"Torso", "Left Leg"},
            {"Torso", "Right Leg"}
        }
    end
end
 
local function createSkeleton(player)
    if not Config.Skeleton.Enable then return end
    if skeletonCache[player] then destroySkeleton(player) end
    
    local skeleton = {}
    local character = player.Character
    if not character then return end
    
    local connections = getSkeletonConnections(character)
    
    for _, conn in ipairs(connections) do
        local line = Drawing.new("Line")
        line.Thickness = Config.Skeleton.Thickness
        line.Color = Config.Skeleton.Color
        line.Visible = false
        table.insert(skeleton, {line = line, from = conn[1], to = conn[2]})
    end
    
    skeletonCache[player] = skeleton
end
 
local function updateSkeleton(player)
    if not Config.Skeleton.Enable then return end
    local skeleton = skeletonCache[player]
    if not skeleton then return end
    
    local character = player.Character
    if not character then return end
    
    for _, bone in ipairs(skeleton) do
        local fromPart = character:FindFirstChild(bone.from)
        local toPart = character:FindFirstChild(bone.to)
        
        if fromPart and toPart then
            local fromPos, fromVis = Camera:WorldToViewportPoint(fromPart.Position)
            local toPos, toVis = Camera:WorldToViewportPoint(toPart.Position)
            
            if fromVis and toVis then
                bone.line.From = Vector2.new(fromPos.X, fromPos.Y)
                bone.line.To = Vector2.new(toPos.X, toPos.Y)
                bone.line.Visible = true
            else
                bone.line.Visible = false
            end
        else
            bone.line.Visible = false
        end
    end
end
 
function destroySkeleton(player)
    local skeleton = skeletonCache[player]
    if skeleton then
        for _, bone in ipairs(skeleton) do
            if bone.line then
                bone.line:Remove()
            end
        end
        skeletonCache[player] = nil
    end
end
 
-- ================= TRACER SYSTEM =================
local function createTracer(player)
    if not Config.Tracer.Enable then return end
    if tracerCache[player] then destroyTracer(player) end
    
    local line = Drawing.new("Line")
    line.Thickness = Config.Tracer.Thickness
    line.Color = Config.Tracer.Color
    line.Visible = false
    
    tracerCache[player] = line
end
 
local function updateTracer(player)
    if not Config.Tracer.Enable then return end
    local tracer = tracerCache[player]
    if not tracer then return end
    
    local character = player.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen then
        tracer.Visible = false
        return
    end
    
    local origin
    if Config.Tracer.Origin == "Top" then
        origin = Vector2.new(Camera.ViewportSize.X / 2, 0)
    elseif Config.Tracer.Origin == "Middle" then
        origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    else
        origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    end
    
    tracer.From = origin
    tracer.To = Vector2.new(rootPos.X, rootPos.Y)
    tracer.Visible = true
end
 
function destroyTracer(player)
    local tracer = tracerCache[player]
    if tracer then
        tracer:Remove()
        tracerCache[player] = nil
    end
end
 
-- ================= FORCEFIELD SYSTEM =================
local function applyDarkForceMaterial(character)
    if not ForceFieldConfig.Enabled then return end
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if ForceFieldConfig.ExcludeHead and part.Name == "Head" then
                continue
            end
            
            if not OriginalPartProperties[character] then
                OriginalPartProperties[character] = {}
            end
            
            if not OriginalPartProperties[character][part] then
                OriginalPartProperties[character][part] = {
                    Color = part.Color,
                    Material = part.Material,
                    Transparency = part.Transparency,
                    Reflectance = part.Reflectance
                }
            end
            
            part.Color = ForceFieldConfig.Color
            part.Material = Enum.Material.ForceField
            part.Transparency = ForceFieldConfig.Transparency
            part.Reflectance = ForceFieldConfig.Reflectance
        end
    end
end
 
local function removeForceFieldMaterial(character)
    if OriginalPartProperties[character] then
        for part, props in pairs(OriginalPartProperties[character]) do
            if part and part.Parent then
                part.Color = props.Color
                part.Material = props.Material
                part.Transparency = props.Transparency
                part.Reflectance = props.Reflectance
            end
        end
        OriginalPartProperties[character] = nil
    end
end
 
-- ================= NAMETAG REMOVER =================
local function updateNametagRemover()
    if Config.RemoveDisplayName then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    for _, child in ipairs(head:GetChildren()) do
                        if child:IsA("BillboardGui") and child.Name ~= "HealthDisplay" then
                            child.Enabled = false
                        end
                    end
                end
            end
        end
    end
end
 
-- ================= ESP CORE =================
function createESP(player)
    if player == LocalPlayer then return end
    if cache[player] then destroyESP(player) end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    local esp = {
        Box = {},
        Text = {},
        UI = {},
        Gradient = {
            Rotation = 0,
            ColorTable = {
                Color3.fromRGB(255, 0, 127),
                Color3.fromRGB(0, 255, 255),
                Color3.fromRGB(255, 255, 0),
                Color3.fromRGB(0, 255, 127)
            }
        }
    }
    
    -- Box Filled
    if Config.Box.Filled.Enable then
        local filled = Drawing.new("Square")
        filled.Filled = true
        filled.Transparency = Config.Box.Filled.Transparency.Start
        filled.Color = esp.Gradient.ColorTable[1]
        filled.Visible = false
        esp.Box.Filled = filled
    end
    
    -- Box Outline
    if Config.Box.Outline.Enable then
        local outline = Drawing.new("Square")
        outline.Filled = false
        outline.Thickness = Config.Box.Outline.Thickness
        outline.Color = Color3.new(0, 0, 0)
        outline.Visible = false
        esp.Box.Outline = outline
    end
    
    -- Name Text
    if Config.Name.Enable then
        esp.Text.Name = newText()
        esp.Text.Name.Color = Config.Name.Color
        esp.Text.Name.Size = Config.Name.Size
    end
    
    -- Health Text
    if Config.HealthText.Enable then
        esp.Text.Health = newText()
        esp.Text.Health.Color = Config.HealthText.Color
    end
    
    -- Distance Text
    if Config.Distance.Enable then
        esp.Text.Distance = newText()
        esp.Text.Distance.Color = Config.Distance.Color
    end
    
    -- Health Bar
    if Config.HealthBar.Enable then
        local container = Drawing.new("Square")
        container.Filled = false
        container.Thickness = 1
        container.Color = Color3.new(0, 0, 0)
        container.Visible = false
        esp.UI.HealthMainContainer = container
        
        local bar = Drawing.new("Square")
        bar.Filled = true
        bar.Color = Color3.fromRGB(0, 255, 0)
        bar.Visible = false
        esp.UI.HealthBar = bar
    end
    
    cache[player] = esp
    
    -- Create skeleton and tracer
    if Config.Skeleton.Enable then
        createSkeleton(player)
    end
    
    if Config.Tracer.Enable then
        createTracer(player)
    end
    
    -- Apply ForceField if enabled
    if ForceFieldConfig.Enabled then
        applyDarkForceMaterial(character)
    end
end
 
function updateESP(player)
    local esp = cache[player]
    if not esp then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not root or humanoid.Health <= 0 then
        if esp.Box.Filled then esp.Box.Filled.Visible = false end
        if esp.Box.Outline then esp.Box.Outline.Visible = false end
        if esp.Text.Name then esp.Text.Name.Visible = false end
        if esp.Text.Health then esp.Text.Health.Visible = false end
        if esp.Text.Distance then esp.Text.Distance.Visible = false end
        if esp.UI.HealthMainContainer then esp.UI.HealthMainContainer.Visible = false end
        if esp.UI.HealthBar then esp.UI.HealthBar.Visible = false end
        
        if Config.Skeleton.Enable then updateSkeleton(player) end
        if Config.Tracer.Enable then updateTracer(player) end
        return
    end
    
    local box, size = getPerfectBoundingBox(character)
    if not box or not size then
        if esp.Box.Filled then esp.Box.Filled.Visible = false end
        if esp.Box.Outline then esp.Box.Outline.Visible = false end
        if esp.Text.Name then esp.Text.Name.Visible = false end
        if esp.Text.Health then esp.Text.Health.Visible = false end
        if esp.Text.Distance then esp.Text.Distance.Visible = false end
        if esp.UI.HealthMainContainer then esp.UI.HealthMainContainer.Visible = false end
        if esp.UI.HealthBar then esp.UI.HealthBar.Visible = false end
        return
    end
    
    local distance = (root.Position - Camera.CFrame.Position).Magnitude
    
    -- Gradient rotation
    esp.Gradient.Rotation = (esp.Gradient.Rotation + Config.Box.Filled.GradientRotationSpeed / 60) % (#esp.Gradient.ColorTable)
    local index = math.floor(esp.Gradient.Rotation) + 1
    local nextIndex = (index % #esp.Gradient.ColorTable) + 1
    local alpha = esp.Gradient.Rotation - math.floor(esp.Gradient.Rotation)
    local currentColor = esp.Gradient.ColorTable[index]:Lerp(esp.Gradient.ColorTable[nextIndex], alpha)
    
    -- Update Box
    if esp.Box.Filled and Config.Box.Filled.Enable then
        esp.Box.Filled.Size = size
        esp.Box.Filled.Position = box
        esp.Box.Filled.Color = currentColor
        local maxDist = 1500
        local distanceFactor = math.clamp(distance / maxDist, 0, 1)
        esp.Box.Filled.Transparency = Config.Box.Filled.Transparency.Start + 
            (Config.Box.Filled.Transparency.End - Config.Box.Filled.Transparency.Start) * distanceFactor
        esp.Box.Filled.Visible = true
    end
    
    if esp.Box.Outline and Config.Box.Outline.Enable then
        esp.Box.Outline.Size = size
        esp.Box.Outline.Position = box
        esp.Box.Outline.Visible = true
    end
    
    -- Update Name
    if esp.Text.Name and Config.Name.Enable then
        local displayText = ""
        if Config.Name.ShowDisplayName then
            displayText = player.DisplayName
        end
        if Config.Name.ShowUsername then
            if displayText ~= "" then
                displayText = displayText .. " (@" .. player.Name .. ")"
            else
                displayText = player.Name
            end
        end
        
        esp.Text.Name.Text = displayText
        esp.Text.Name.Size = calculateTextSize(distance)
        esp.Text.Name.Position = Vector2.new(box.X + size.X / 2, box.Y - 20)
        esp.Text.Name.Visible = true
    end
    
    -- Health Bar
    local healthBarWidth = 4
    local healthBarX = box.X - healthBarWidth - 5
    
    if esp.UI.HealthMainContainer and Config.HealthBar.Enable then
        esp.UI.HealthMainContainer.Size = Vector2.new(healthBarWidth, size.Y)
        esp.UI.HealthMainContainer.Position = Vector2.new(healthBarX, box.Y)
        esp.UI.HealthMainContainer.Visible = true
        
        if esp.UI.HealthBar then
            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local barHeight = size.Y * healthPercent
            local barY = box.Y + (size.Y - barHeight)
            
            esp.UI.HealthBar.Size = Vector2.new(healthBarWidth, barHeight)
            esp.UI.HealthBar.Position = Vector2.new(healthBarX, barY)
            
            if healthPercent > 0.6 then
                esp.UI.HealthBar.Color = Color3.fromRGB(0, 255, 0)
            elseif healthPercent > 0.3 then
                esp.UI.HealthBar.Color = Color3.fromRGB(255, 255, 0)
            else
                esp.UI.HealthBar.Color = Color3.fromRGB(255, 0, 0)
            end
            
            esp.UI.HealthBar.Visible = true
        end
    end
    
    -- Health Text (positioned ABOVE health bar)
    if esp.Text.Health and Config.HealthText.Enable then
        local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        local healthText = ""
        
        if Config.HealthBar.ShowPercentage then
            healthText = tostring(math.floor(healthPercent * 100)) .. "%"
        else
            healthText = tostring(math.floor(humanoid.Health))
        end
        
        esp.Text.Health.Text = healthText
        esp.Text.Health.Size = calculateTextSize(distance) - 2
        esp.Text.Health.Position = Vector2.new(healthBarX + healthBarWidth / 2, box.Y - 15)
        esp.Text.Health.Visible = true
    end
    
    -- Distance
    if esp.Text.Distance and Config.Distance.Enable then
        esp.Text.Distance.Text = formatDistance(distance)
        esp.Text.Distance.Size = calculateTextSize(distance) - 2
        esp.Text.Distance.Position = Vector2.new(box.X + size.X / 2, box.Y + size.Y + 5)
        esp.Text.Distance.Visible = true
    end
    
    -- Update Skeleton
    if Config.Skeleton.Enable then
        updateSkeleton(player)
    end
    
    -- Update Tracer
    if Config.Tracer.Enable then
        updateTracer(player)
    end
end
 
function destroyESP(player)
    local esp = cache[player]
    if esp then
        if esp.Box.Filled then esp.Box.Filled:Remove() end
        if esp.Box.Outline then esp.Box.Outline:Remove() end
        if esp.Text.Name then esp.Text.Name:Remove() end
        if esp.Text.Health then esp.Text.Health:Remove() end
        if esp.Text.Distance then esp.Text.Distance:Remove() end
        if esp.UI.HealthMainContainer then esp.UI.HealthMainContainer:Remove() end
        if esp.UI.HealthBar then esp.UI.HealthBar:Remove() end
        cache[player] = nil
    end
    
    destroySkeleton(player)
    destroyTracer(player)
    
    local character = player.Character
    if character and OriginalPartProperties[character] then
        removeForceFieldMaterial(character)
    end
end
 
-- ================= INITIALIZATION =================
function Visuals.Init()
    if isLoaded then return end
    isLoaded = true
    
    -- Clear all caches first
    for player, _ in pairs(cache) do 
        destroyESP(player) 
    end
    
    for player, _ in pairs(skeletonCache) do
        destroySkeleton(player)
    end
    
    for player, _ in pairs(tracerCache) do
        destroyTracer(player)
    end
    
    -- Initialize players
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if player.Character then
                task.spawn(function()
                    task.wait(0.1)
                    createESP(player)
                end)
            end
            player.CharacterAdded:Connect(function()
                deadPlayers[player] = nil
                task.wait(0.3)
                createESP(player)
            end)
            player.CharacterRemoving:Connect(function()
                destroyESP(player)
            end)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        if player == LocalPlayer then return end
        player.CharacterAdded:Connect(function()
            deadPlayers[player] = nil
            task.wait(0.3)
            createESP(player)
        end)
        player.CharacterRemoving:Connect(function()
            destroyESP(player)
        end)
        if player.Character then
            task.spawn(function()
                task.wait(0.1)
                createESP(player)
            end)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        destroyESP(player)
    end)
    
    -- Main update loop
    RunService.Heartbeat:Connect(function()
        for player, esp in pairs(cache) do
            if not player or not player.Parent or not player:IsDescendantOf(Players) then
                destroyESP(player)
            end
        end
        
        for player, esp in pairs(cache) do
            if player and player.Parent then
                pcall(updateESP, player)
            end
        end
        
        updateNametagRemover()
    end)
    
    -- Initialize ForceField
    if ForceFieldConfig.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                applyDarkForceMaterial(player.Character)
            end
            player.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                applyDarkForceMaterial(char)
            end)
        end
    end
    
    print("✅ Visuals Module Loaded!")
end
 
-- Cleanup function
function Visuals.Unload()
    for player, _ in pairs(cache) do
        destroyESP(player)
    end
    for character, _ in pairs(OriginalPartProperties) do
        if character and character.Parent then
            removeForceFieldMaterial(character)
        end
    end
    print("✅ Visuals Module Unloaded!")
end
 
-- Export functions for UI control
Visuals.ApplyForceField = function()
    if ForceFieldConfig.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                applyDarkForceMaterial(player.Character)
            end
        end
    else
        for character, _ in pairs(OriginalPartProperties) do
            if character and character.Parent then
                removeForceFieldMaterial(character)
            end
        end
    end
end
 
Visuals.UpdateTracers = function()
    if not Config.Tracer.Enable then
        for player, _ in pairs(tracerCache) do
            destroyTracer(player)
        end
    else
        for player, _ in pairs(cache) do
            if player and player.Character then
                createTracer(player)
            end
        end
    end
end
 
return Visualss