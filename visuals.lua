-- ================= YOUR PERFECT ESP + LINORIALIB UI =================
-- KEEPING YOUR EXACT ESP CODE, ADDING UI CONTROLS

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

-- Create Window
local Window = Library:CreateWindow({
    Title = 'Perfect ESP',
    Center = true,
    AutoShow = true,
})

-- Setup Tabs
local Tabs = {
    Visuals = Window:AddTab('Visuals'),
    Settings = Window:AddTab('UI Settings'),
}

-- ================= YOUR EXACT ESP CONFIG =================
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

-- ================= YOUR EXACT ESP CODE STARTS HERE =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local cache = {}
local skeletonCache = {}
local tracerCache = {}
local isLoaded = false
local deadPlayers = {}

-- Store original humanoid settings
local originalHumanoidSettings = {}

-- OPTIMIZED: Key body parts for BOTH R6 and R15
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
    local baseSize = Config.Name.Size  -- 18
    if distance < 100 then return baseSize + 2
    elseif distance < 500 then return math.floor(baseSize * 1.1)
    elseif distance < 1000 then return math.floor(baseSize * 0.95)
    elseif distance < 2000 then return math.floor(baseSize * 0.8)
    else return math.floor(baseSize * 0.65) end
end

-- BIGGER CLEANER FONTS (anti-pixelated)
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
    if skeletonCache[player] then
        for _, line in pairs(skeletonCache[player]) do
            if line then pcall(line.Remove, line) end
        end
    end
    
    skeletonCache[player] = {}
    for i = 1, 10 do
        local line = Drawing.new("Line")
        line.Thickness = Config.Skeleton.Thickness
        line.Color = Config.Skeleton.Color
        line.Visible = false
        skeletonCache[player][i] = line
    end
end

local function destroySkeleton(player)
    if skeletonCache[player] then
        for _, line in pairs(skeletonCache[player]) do
            if line and line.Remove then
                pcall(line.Remove, line)
            end
        end
        skeletonCache[player] = nil
    end
end

local function updateSkeleton(player, character)
    if not Config.Skeleton.Enable or not character then
        destroySkeleton(player)
        return
    end
    
    if not skeletonCache[player] then
        createSkeleton(player)
    end
    
    local connections = getSkeletonConnections(character)
    local lines = skeletonCache[player]
    
    for i, connection in ipairs(connections) do
        if i > #lines then break end
        
        local line = lines[i]
        local part1 = character:FindFirstChild(connection[1])
        local part2 = character:FindFirstChild(connection[2])
        
        if part1 and part2 and line then
            local pos1, vis1 = Camera:WorldToViewportPoint(part1.Position)
            local pos2, vis2 = Camera:WorldToViewportPoint(part2.Position)
            
            if vis1 and vis2 and pos1.Z > 0 and pos2.Z > 0 then
                line.From = Vector2.new(pos1.X, pos1.Y)
                line.To = Vector2.new(pos2.X, pos2.Y)
                line.Color = Config.Skeleton.Color
                line.Thickness = Config.Skeleton.Thickness
                line.Visible = true
            else
                line.Visible = false
            end
        elseif line then
            line.Visible = false
        end
    end
end

-- ================= TRACER SYSTEM =================
local function createTracer(player)
    if tracerCache[player] then
        pcall(tracerCache[player].Remove, tracerCache[player])
    end
    
    local tracer = Drawing.new("Line")
    tracer.Thickness = Config.Tracer.Thickness
    tracer.Color = Config.Tracer.Color
    tracer.Visible = false
    tracerCache[player] = tracer
end

local function destroyTracer(player)
    if tracerCache[player] then
        pcall(tracerCache[player].Remove, tracerCache[player])
        tracerCache[player] = nil
    end
end

local function updateTracer(player, character)
    if not Config.Tracer.Enable or not character then
        if tracerCache[player] then
            tracerCache[player].Visible = false
        end
        return
    end
    
    if not tracerCache[player] then
        createTracer(player)
    end
    
    local tracer = tracerCache[player]
    local root = character:FindFirstChild("HumanoidRootPart")
    
    if not root then
        tracer.Visible = false
        return
    end
    
    local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen then
        tracer.Visible = false
        return
    end
    
    local originY
    if Config.Tracer.Origin == "Bottom" then
        originY = Camera.ViewportSize.Y
    elseif Config.Tracer.Origin == "Middle" then
        originY = Camera.ViewportSize.Y / 2
    else
        originY = 0
    end
    
    tracer.From = Vector2.new(Camera.ViewportSize.X / 2, originY)
    tracer.To = Vector2.new(rootPos.X, rootPos.Y)
    tracer.Visible = true
end

-- ================= YOUR EXACT ESP CREATION =================
local function createESP(player)
    if cache[player] then 
        pcall(function() 
            if cache[player].UI.Gui then cache[player].UI.Gui:Destroy() end
            if cache[player].Text.Name then cache[player].Text.Name:Remove() end
            if cache[player].Text.Distance then cache[player].Text.Distance:Remove() end
            if cache[player].Text.Health then cache[player].Text.Health:Remove() end
        end)
        cache[player] = nil 
    end
    
    deadPlayers[player] = nil
    
    local esp = {Text = {}, UI = {}}
    cache[player] = esp
    
    local gui = Instance.new("ScreenGui")
    gui.Name = player.Name .. "_ESP"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Enabled = true
    gui.Parent = game.CoreGui
    esp.UI.Gui = gui
    
    local GRADIENT = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(170, 170, 170)),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(70, 70, 70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    })
    
    if Config.Box.Filled.Enable then
        local fillContainer = Instance.new("Frame")
        fillContainer.BackgroundTransparency = 1
        fillContainer.ZIndex = 3
        fillContainer.Visible = false
        fillContainer.Parent = gui
        local fill = Instance.new("Frame")
        fill.BackgroundTransparency = 0
        fill.Size = UDim2.fromScale(1,1)
        fill.ZIndex = 4
        fill.Parent = fillContainer
        local fillGradient = Instance.new("UIGradient")
        fillGradient.Color = GRADIENT
        fillGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, Config.Box.Filled.Transparency.Start),
            NumberSequenceKeypoint.new(1, Config.Box.Filled.Transparency.End)
        })
        fillGradient.Parent = fill
        esp.UI.FillContainer = fillContainer
        esp.UI.FillGradient = fillGradient
    end
    
    if Config.Box.Outline.Enable then
        local outlineContainer = Instance.new("Frame")
        outlineContainer.BackgroundTransparency = 1
        outlineContainer.BorderSizePixel = 0
        outlineContainer.ZIndex = 10
        outlineContainer.Visible = false
        outlineContainer.Parent = gui
        local uiStroke = Instance.new("UIStroke")
        uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        uiStroke.Color = Color3.new(1,1,1)
        uiStroke.Thickness = Config.Box.Outline.Thickness
        uiStroke.LineJoinMode = Enum.LineJoinMode.Miter
        uiStroke.Parent = outlineContainer
        local strokeGradient = Instance.new("UIGradient")
        strokeGradient.Color = GRADIENT
        strokeGradient.Parent = uiStroke
        esp.UI.OutlineContainer = outlineContainer
        esp.UI.OutlineStroke = uiStroke
        esp.UI.OutlineGradient = strokeGradient
    end
    
    local healthMainContainer = Instance.new("Frame")
    healthMainContainer.BackgroundTransparency = 1
    healthMainContainer.ZIndex = 5
    healthMainContainer.Visible = false
    healthMainContainer.Parent = gui
    esp.UI.HealthMainContainer = healthMainContainer
    
    local healthOutlineContainer = Instance.new("Frame")
    healthOutlineContainer.BackgroundTransparency = 1
    healthOutlineContainer.BorderSizePixel = 0
    healthOutlineContainer.ZIndex = 6
    healthOutlineContainer.Visible = false
    healthOutlineContainer.Parent = healthMainContainer
    esp.UI.HealthOutlineContainer = healthOutlineContainer
    
    local healthOutlineStroke = Instance.new("UIStroke")
    healthOutlineStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    healthOutlineStroke.Color = Color3.new(1,1,1)
    healthOutlineStroke.Thickness = 1.8
    healthOutlineStroke.LineJoinMode = Enum.LineJoinMode.Miter
    healthOutlineStroke.Parent = healthOutlineContainer
    esp.UI.HealthOutlineStroke = healthOutlineStroke
    
    local healthOutlineGradient = Instance.new("UIGradient")
    healthOutlineGradient.Color = GRADIENT
    healthOutlineGradient.Parent = healthOutlineStroke
    esp.UI.HealthOutlineGradient = healthOutlineGradient
    
    local healthBack = Instance.new("Frame")
    healthBack.Size = UDim2.new(1,0,1,0)
    healthBack.BackgroundColor3 = Color3.fromRGB(20,20,20)
    healthBack.BorderSizePixel = 0
    healthBack.ZIndex = 7
    healthBack.Parent = healthOutlineContainer
    esp.UI.HealthBack = healthBack
    
    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(1,0,1,0)
    healthFill.BorderSizePixel = 0
    healthFill.ZIndex = 8
    healthFill.Parent = healthBack
    esp.UI.HealthFill = healthFill
    
    local healthGradient = Instance.new("UIGradient")
    healthGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220,40,40))
    })
    healthGradient.Rotation = 90
    healthGradient.Parent = healthFill
    esp.UI.HealthGradient = healthGradient
    
    esp.Text.Health = newText()
    esp.Text.Health.Color = Config.HealthText.Color
    esp.Text.Name = newText()
    esp.Text.Name.Color = Config.Name.Color
    esp.Text.Distance = newText()
    esp.Text.Distance.Color = Config.Distance.Color
    
    -- Create skeleton and tracer
    if Config.Skeleton.Enable then
        createSkeleton(player)
    end
    if Config.Tracer.Enable then
        createTracer(player)
    end
end

local function destroyESP(player)
    if not player then return end
    local esp = cache[player]
    if esp then
        pcall(function()
            if esp.UI.Gui then esp.UI.Gui:Destroy() end
            if esp.Text.Name then esp.Text.Name:Remove() end
            if esp.Text.Distance then esp.Text.Distance:Remove() end
            if esp.Text.Health then esp.Text.Health:Remove() end
        end)
        cache[player] = nil
        deadPlayers[player] = nil
    end
    destroySkeleton(player)
    destroyTracer(player)
end

-- ================= SIMPLE ESP UPDATE (NO SMOOTHING) =================
local function updateESP(player)
    local esp = cache[player]
    if not esp or not player.Parent then 
        destroyESP(player)
        return 
    end
    
    local char = player.Character
    if not char or not char.Parent or deadPlayers[player] then 
        destroyESP(player)
        return 
    end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then
        deadPlayers[player] = true
        destroyESP(player)
        return
    end
    
    local dist = (root.Position - Camera.CFrame.Position).Magnitude
    local rootScreenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
    if not onScreen then
        for _, txt in pairs(esp.Text) do 
            if txt then txt.Visible = false end 
        end
        if esp.UI.FillContainer then esp.UI.FillContainer.Visible = false end
        if esp.UI.OutlineContainer then esp.UI.OutlineContainer.Visible = false end
        if esp.UI.HealthMainContainer then esp.UI.HealthMainContainer.Visible = false end
        -- Hide skeleton and tracer when off screen
        if skeletonCache[player] then
            for _, line in pairs(skeletonCache[player]) do
                if line then line.Visible = false end
            end
        end
        if tracerCache[player] then
            tracerCache[player].Visible = false
        end
        return
    end
    
    local pos, size = getPerfectBoundingBox(char)
    
    if not pos or not size then
        local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
        if not rootOnScreen then return end
        local baseSize = math.max(5, 500 / dist)
        local distanceScale = 1 + (dist / 1000)
        local boxSize = baseSize * distanceScale
        pos = Vector2.new(rootPos.X - boxSize/2, rootPos.Y - boxSize/2)
        size = Vector2.new(boxSize, boxSize * 2)
    end
    
    size = Vector2.new(math.max(1, size.X), math.max(1, size.Y))
    local rotation = (tick() * Config.Box.Filled.GradientRotationSpeed) % 360
    
    -- BOX ELEMENTS
    if esp.UI.FillContainer then
        esp.UI.FillContainer.Position = UDim2.fromOffset(pos.X, pos.Y)
        esp.UI.FillContainer.Size = UDim2.fromOffset(size.X, size.Y)
        esp.UI.FillContainer.Visible = Config.Box.Filled.Enable
        esp.UI.FillGradient.Rotation = rotation
    end
    
    if esp.UI.OutlineContainer then
        esp.UI.OutlineContainer.Position = UDim2.fromOffset(pos.X, pos.Y)
        esp.UI.OutlineContainer.Size = UDim2.fromOffset(size.X, size.Y)
        esp.UI.OutlineContainer.Visible = Config.Box.Outline.Enable
        if esp.UI.OutlineStroke then 
            esp.UI.OutlineStroke.Thickness = Config.Box.Outline.Thickness 
        end
        if esp.UI.OutlineGradient then 
            esp.UI.OutlineGradient.Rotation = rotation 
        end
    end
    
    -- HEALTH BAR
    local BAR_WIDTH = 0
    local barHeight = 0
    
    if Config.HealthBar.Enable and dist < 1000 then
        local hp = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        BAR_WIDTH = dist < 100 and 4 or dist < 300 and 5 or dist < 600 and 6 or 7
        barHeight = dist < 100 and math.max(size.Y * 0.7, 25) or dist < 300 and math.max(size.Y * 0.6, 20) or dist < 600 and math.max(size.Y * 0.5, 15) or math.max(size.Y * 0.4, 10)
        
        esp.UI.HealthMainContainer.Position = UDim2.fromOffset(pos.X - BAR_WIDTH - 8, pos.Y + (size.Y - barHeight)/2)
        esp.UI.HealthMainContainer.Size = UDim2.fromOffset(BAR_WIDTH, barHeight)
        esp.UI.HealthMainContainer.Visible = true
        
        esp.UI.HealthOutlineContainer.Size = UDim2.fromOffset(BAR_WIDTH, barHeight)
        esp.UI.HealthOutlineContainer.Visible = true
        
        if esp.UI.HealthOutlineGradient then
            esp.UI.HealthOutlineGradient.Rotation = rotation
        end
        
        esp.UI.HealthFill.Size = UDim2.new(1,0, hp, 0)
        esp.UI.HealthFill.Position = UDim2.new(0,0,1-hp,0)
    else
        esp.UI.HealthMainContainer.Visible = false
    end
    
    -- BIGGER CLEANER TEXT WITH NEW POSITIONS
    local textSize = calculateTextSize(dist)
    local healthTextSize = math.max(14, textSize * 1.25)
    local distanceTextSize = math.max(12, textSize * 0.9)
    
    -- HEALTH TEXT - POSITIONED ABOVE HEALTH BAR
    if Config.HealthText.Enable and esp.Text.Health then
        if dist < 1500 then
            esp.Text.Health.Size = healthTextSize
            esp.Text.Health.Text = Config.HealthBar.ShowPercentage and (math.floor((hum.Health / hum.MaxHealth) * 100) .. "%") or (math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth))
            
            if Config.HealthBar.Enable and BAR_WIDTH > 0 then
                -- Position health text above health bar
                local barX = pos.X - BAR_WIDTH - 8
                local barY = pos.Y + (size.Y - barHeight)/2
                esp.Text.Health.Position = Vector2.new(barX + BAR_WIDTH/2, barY - healthTextSize - 2)
            else
                -- Position health text above name (when no health bar)
                esp.Text.Health.Position = Vector2.new(pos.X + size.X / 2, pos.Y - healthTextSize - 25)
            end
            esp.Text.Health.Visible = true
        else
            esp.Text.Health.Visible = false
        end
    elseif esp.Text.Health then
        esp.Text.Health.Visible = false
    end
    
    -- NAME TEXT
    if Config.Name.Enable and esp.Text.Name then
        if dist < 3000 then
            esp.Text.Name.Size = textSize
            esp.Text.Name.Text = Config.Name.ShowDisplayName and (player.DisplayName or player.Name) or player.Name
            
            -- Adjust name position based on health text visibility
            if Config.HealthText.Enable and esp.Text.Health and esp.Text.Health.Visible and not Config.HealthBar.Enable then
                esp.Text.Name.Position = Vector2.new(pos.X + size.X / 2, pos.Y - textSize - 12)
            else
                esp.Text.Name.Position = Vector2.new(pos.X + size.X / 2, pos.Y - textSize - 12)
            end
            esp.Text.Name.Visible = true
        else
            esp.Text.Name.Visible = false
        end
    elseif esp.Text.Name then
        esp.Text.Name.Visible = false
    end
    
    -- DISTANCE TEXT
    if Config.Distance.Enable and esp.Text.Distance then
        if dist < 2500 then
            esp.Text.Distance.Size = distanceTextSize
            esp.Text.Distance.Text = formatDistance(dist)
            esp.Text.Distance.Position = Vector2.new(pos.X + size.X / 2, pos.Y + size.Y + 3)
            esp.Text.Distance.Visible = true
        else
            esp.Text.Distance.Visible = false
        end
    elseif esp.Text.Distance then
        esp.Text.Distance.Visible = false
    end
    
    -- Update skeleton and tracer
    updateSkeleton(player, char)
    updateTracer(player, char)
end

-- ================= FORCEFIELD SYSTEM =================
local OriginalPartProperties = {}

local function applyDarkForceMaterial(character)
    if not ForceFieldConfig.Enabled or not character then return end
    
    task.wait(0.5)
    
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
    
    for _, obj in ipairs(character:GetChildren()) do
        if obj:IsA("ForceField") then
            obj:Destroy()
        end
    end
    
    if OriginalPartProperties[character] then
        for part, props in pairs(OriginalPartProperties[character]) do
            if part and part.Parent then
                pcall(function()
                    part.Material = props.Material
                    part.Color = props.Color
                    part.Transparency = props.Transparency
                    part.Reflectance = props.Reflectance
                end)
            end
        end
    end
    
    OriginalPartProperties[character] = {}
    
    for _, part in ipairs(character:GetDescendants()) do
        if (part:IsA("BasePart") or part:IsA("MeshPart")) and part.Name ~= "HumanoidRootPart" then
            if ForceFieldConfig.ExcludeHead and part.Name == "Head" then continue end
            
            OriginalPartProperties[character][part] = {
                Material = part.Material,
                Color = part.Color,
                Transparency = part.Transparency,
                Reflectance = part.Reflectance
            }
            
            part.Material = Enum.Material.ForceField
            part.Color = ForceFieldConfig.Color
            part.Transparency = ForceFieldConfig.Transparency
            part.Reflectance = ForceFieldConfig.Reflectance
        end
    end
end

local function removeForceFieldMaterial(character)
    if not character or not OriginalPartProperties[character] then return end
    
    for part, props in pairs(OriginalPartProperties[character]) do
        if part and part.Parent then
            pcall(function()
                part.Material = props.Material
                part.Color = props.Color
                part.Transparency = props.Transparency
                part.Reflectance = props.Reflectance
            end)
        end
    end
    
    OriginalPartProperties[character] = nil
end

-- ================= NAMETAG REMOVER =================
local function updateNametagRemover()
    if Config.RemoveDisplayName then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    pcall(function()
                        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
                    end)
                end
            end
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    pcall(function()
                        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
                        humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOn
                    end)
                end
            end
        end
    end
end

-- ================= UI SETUP =================
local ESPBox = Tabs.Visuals:AddLeftGroupbox('ESP Settings')

-- Box ESP
ESPBox:AddToggle('BoxFilledToggle', {
    Text = 'Box Filled',
    Default = Config.Box.Filled.Enable,
    Tooltip = 'Your gradient filled box'
})

ESPBox:AddToggle('BoxOutlineToggle', {
    Text = 'Box Outline',
    Default = Config.Box.Outline.Enable,
    Tooltip = 'Your gradient box outline'
})

ESPBox:AddSlider('BoxThicknessSlider', {
    Text = 'Outline Thickness',
    Default = Config.Box.Outline.Thickness,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Compact = true
})

ESPBox:AddSlider('GradientSpeedSlider', {
    Text = 'Gradient Rotation Speed',
    Default = Config.Box.Filled.GradientRotationSpeed,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = true
})

-- Skeleton ESP
ESPBox:AddToggle('SkeletonToggle', {
    Text = 'Skeleton ESP',
    Default = Config.Skeleton.Enable,
    Tooltip = 'Show skeleton lines'
})

local SkeletonColorPicker = ESPBox:AddLabel('Skeleton Color'):AddColorPicker('SkeletonColorPicker', {
    Default = Config.Skeleton.Color,
    Title = 'Skeleton Color'
})

ESPBox:AddSlider('SkeletonThicknessSlider', {
    Text = 'Skeleton Thickness',
    Default = Config.Skeleton.Thickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Compact = true
})

-- Name ESP
local NameBox = Tabs.Visuals:AddRightGroupbox('Player Info')

NameBox:AddToggle('NameToggle', {
    Text = 'Name ESP',
    Default = Config.Name.Enable,
    Tooltip = 'Show player names'
})

local NameColorPicker = NameBox:AddLabel('Name Color'):AddColorPicker('NameColorPicker', {
    Default = Config.Name.Color,
    Title = 'Name Color'
})

NameBox:AddSlider('NameSizeSlider', {
    Text = 'Name Size',
    Default = Config.Name.Size,
    Min = 10,
    Max = 30,
    Rounding = 0,
    Compact = true
})

NameBox:AddDropdown('NameTypeDropdown', {
    Values = {'Display Name', 'Username'},
    Default = 1,
    Text = 'Name Type',
    Tooltip = 'Which name to show'
})

NameBox:AddToggle('RemoveDisplayNameToggle', {
    Text = 'Remove Display Name',
    Default = Config.RemoveDisplayName,
    Tooltip = 'Remove default Roblox nametags'
})

NameBox:AddToggle('HealthTextToggle', {
    Text = 'Health Text',
    Default = Config.HealthText.Enable,
    Tooltip = 'Show health text'
})

local HealthColorPicker = NameBox:AddLabel('Health Color'):AddColorPicker('HealthColorPicker', {
    Default = Config.HealthText.Color,
    Title = 'Health Color'
})

NameBox:AddToggle('HealthBarToggle', {
    Text = 'Health Bar',
    Default = Config.HealthBar.Enable,
    Tooltip = 'Show gradient health bar'
})

NameBox:AddToggle('PercentageToggle', {
    Text = 'Show Percentage',
    Default = Config.HealthBar.ShowPercentage,
    Tooltip = 'Show health as percentage'
})

NameBox:AddToggle('DistanceToggle', {
    Text = 'Distance',
    Default = Config.Distance.Enable,
    Tooltip = 'Show distance to players'
})

local DistanceColorPicker = NameBox:AddLabel('Distance Color'):AddColorPicker('DistanceColorPicker', {
    Default = Config.Distance.Color,
    Title = 'Distance Color'
})

NameBox:AddToggle('StudsToggle', {
    Text = 'Show in Studs',
    Default = Config.Distance.ShowStuds,
    Tooltip = 'Show distance in studs'
})

-- Tracer ESP
local TracerBox = Tabs.Visuals:AddLeftGroupbox('Tracer')

TracerBox:AddToggle('TracerToggle', {
    Text = 'Tracer ESP',
    Default = Config.Tracer.Enable,
    Tooltip = 'Show tracer lines to players'
})

local TracerColorPicker = TracerBox:AddLabel('Tracer Color'):AddColorPicker('TracerColorPicker', {
    Default = Config.Tracer.Color,
    Title = 'Tracer Color'
})

TracerBox:AddSlider('TracerThicknessSlider', {
    Text = 'Tracer Thickness',
    Default = Config.Tracer.Thickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Compact = true
})

TracerBox:AddDropdown('TracerOriginDropdown', {
    Values = {'Bottom', 'Middle', 'Top'},
    Default = 1,
    Text = 'Tracer Origin',
    Tooltip = 'Where the tracer starts from'
})

-- Force Field
local ForceFieldBox = Tabs.Visuals:AddRightGroupbox('Force Field')

ForceFieldBox:AddToggle('ForceFieldToggle', {
    Text = 'Enable Force Field',
    Default = ForceFieldConfig.Enabled,
    Tooltip = 'Enable force field effect'
})

local ForceFieldColorPicker = ForceFieldBox:AddLabel('Force Field Color'):AddColorPicker('ForceFieldColorPicker', {
    Default = ForceFieldConfig.Color,
    Title = 'Force Field Color'
})

ForceFieldBox:AddSlider('TransparencySlider', {
    Text = 'Transparency',
    Default = ForceFieldConfig.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false
})

ForceFieldBox:AddSlider('ReflectanceSlider', {
    Text = 'Reflectance',
    Default = ForceFieldConfig.Reflectance,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false
})

ForceFieldBox:AddToggle('ExcludeHeadToggle', {
    Text = 'Exclude Head',
    Default = ForceFieldConfig.ExcludeHead,
    Tooltip = 'Don\'t apply to head'
})

-- Presets
ForceFieldBox:AddDivider()
ForceFieldBox:AddLabel('Presets')

local PresetButton = ForceFieldBox:AddButton({
    Text = 'Dark Blue',
    Func = function()
        ForceFieldColorPicker:SetValueRGB(Color3.fromRGB(35, 35, 50))
        Options.TransparencySlider:SetValue(0.35)
        Options.ReflectanceSlider:SetValue(0.65)
    end
})

PresetButton:AddButton({
    Text = 'Purple',
    Func = function()
        ForceFieldColorPicker:SetValueRGB(Color3.fromRGB(45, 30, 70))
        Options.TransparencySlider:SetValue(0.3)
        Options.ReflectanceSlider:SetValue(0.7)
    end
})

-- ================= EVENT HANDLERS =================
Toggles.BoxFilledToggle:OnChanged(function(value)
    Config.Box.Filled.Enable = value
end)

Toggles.BoxOutlineToggle:OnChanged(function(value)
    Config.Box.Outline.Enable = value
end)

Options.BoxThicknessSlider:OnChanged(function(value)
    Config.Box.Outline.Thickness = value
end)

Options.GradientSpeedSlider:OnChanged(function(value)
    Config.Box.Filled.GradientRotationSpeed = value
end)

Toggles.SkeletonToggle:OnChanged(function(value)
    Config.Skeleton.Enable = value
    if not value then
        for player, _ in pairs(skeletonCache) do
            destroySkeleton(player)
        end
    else
        -- Recreate skeletons for existing players
        for player, _ in pairs(cache) do
            if player and player.Character then
                createSkeleton(player)
            end
        end
    end
end)

Options.SkeletonColorPicker:OnChanged(function(value)
    Config.Skeleton.Color = value
    for player, lines in pairs(skeletonCache) do
        if lines then
            for _, line in pairs(lines) do
                if line then
                    line.Color = value
                end
            end
        end
    end
end)

Options.SkeletonThicknessSlider:OnChanged(function(value)
    Config.Skeleton.Thickness = value
    for player, lines in pairs(skeletonCache) do
        if lines then
            for _, line in pairs(lines) do
                if line then
                    line.Thickness = value
                end
            end
        end
    end
end)

Toggles.NameToggle:OnChanged(function(value)
    Config.Name.Enable = value
end)

Options.NameColorPicker:OnChanged(function(value)
    Config.Name.Color = value
    for _, esp in pairs(cache) do
        if esp.Text.Name then
            esp.Text.Name.Color = value
        end
    end
end)

Options.NameSizeSlider:OnChanged(function(value)
    Config.Name.Size = value
end)

Options.NameTypeDropdown:OnChanged(function(value)
    Config.Name.ShowDisplayName = value == "Display Name"
    Config.Name.ShowUsername = value == "Username"
end)

Toggles.RemoveDisplayNameToggle:OnChanged(function(value)
    Config.RemoveDisplayName = value
    updateNametagRemover()
end)

Toggles.HealthTextToggle:OnChanged(function(value)
    Config.HealthText.Enable = value
end)

Options.HealthColorPicker:OnChanged(function(value)
    Config.HealthText.Color = value
    for _, esp in pairs(cache) do
        if esp.Text.Health then
            esp.Text.Health.Color = value
        end
    end
end)

Toggles.HealthBarToggle:OnChanged(function(value)
    Config.HealthBar.Enable = value
    -- Force update all ESP elements
    for player, esp in pairs(cache) do
        if esp.UI.HealthMainContainer then
            esp.UI.HealthMainContainer.Visible = value
        end
    end
end)

Toggles.PercentageToggle:OnChanged(function(value)
    Config.HealthBar.ShowPercentage = value
end)

Toggles.DistanceToggle:OnChanged(function(value)
    Config.Distance.Enable = value
end)

Options.DistanceColorPicker:OnChanged(function(value)
    Config.Distance.Color = value
    for _, esp in pairs(cache) do
        if esp.Text.Distance then
            esp.Text.Distance.Color = value
        end
    end
end)

Toggles.StudsToggle:OnChanged(function(value)
    Config.Distance.ShowStuds = value
end)

Toggles.TracerToggle:OnChanged(function(value)
    Config.Tracer.Enable = value
    if not value then
        for player, _ in pairs(tracerCache) do
            destroyTracer(player)
        end
    else
        -- Recreate tracers for existing players
        for player, _ in pairs(cache) do
            if player and player.Character then
                createTracer(player)
            end
        end
    end
end)

Options.TracerColorPicker:OnChanged(function(value)
    Config.Tracer.Color = value
    for _, tracer in pairs(tracerCache) do
        if tracer then
            tracer.Color = value
        end
    end
end)

Options.TracerThicknessSlider:OnChanged(function(value)
    Config.Tracer.Thickness = value
    for _, tracer in pairs(tracerCache) do
        if tracer then
            tracer.Thickness = value
        end
    end
end)

Options.TracerOriginDropdown:OnChanged(function(value)
    Config.Tracer.Origin = value
end)

Toggles.ForceFieldToggle:OnChanged(function(value)
    ForceFieldConfig.Enabled = value
    if value then
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
end)

Options.ForceFieldColorPicker:OnChanged(function(value)
    ForceFieldConfig.Color = value
    if ForceFieldConfig.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                applyDarkForceMaterial(player.Character)
            end
        end
    end
end)

Options.TransparencySlider:OnChanged(function(value)
    ForceFieldConfig.Transparency = value
end)

Options.ReflectanceSlider:OnChanged(function(value)
    ForceFieldConfig.Reflectance = value
end)

Toggles.ExcludeHeadToggle:OnChanged(function(value)
    ForceFieldConfig.ExcludeHead = value
end)

-- ================= ESP INITIALIZATION =================
if not isLoaded then
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
    
    -- SIMPLE HEARTBEAT LOOP - NO SMOOTHING, NO LAG
    RunService.Heartbeat:Connect(function()
        -- Clean up invalid entries first
        for player, esp in pairs(cache) do
            if not player or not player.Parent or not player:IsDescendantOf(Players) then
                destroyESP(player)
            end
        end
        
        -- Update all ESP
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
    
    print("✅ YOUR PERFECT ESP LOADED - WITH UI CONTROLS! 🎉")
    print("🎯 Health text now positioned ABOVE health bar")
    print("⚡ Simple & Fast - No smoothing, no lag")
    print("➕ Added: Skeleton ESP, Tracer, Force Field, Nametag Remover")
end

-- ================= SETTINGS TAB =================
local MenuGroup = Tabs.Settings:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() 
    Library:Unload() 
    for player, _ in pairs(cache) do
        destroyESP(player)
    end
    for character, _ in pairs(OriginalPartProperties) do
        if character and character.Parent then
            removeForceFieldMaterial(character)
        end
    end
    print('✅ YOUR ESP Unloaded!')
end)

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { 
    Default = 'End', 
    NoUI = true, 
    Text = 'Menu keybind' 
})

Library.ToggleKeybind = Options.MenuKeybind

-- Initialize managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('PerfectESP')
SaveManager:SetFolder('PerfectESP/' .. game.PlaceId)

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

-- Watermark
Library:SetWatermarkVisibility(true)
Library:SetWatermark('Perfect ESP v3.0 | Health Text Over Bar | No Lag')