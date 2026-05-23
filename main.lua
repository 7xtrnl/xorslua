print("🌟 AETHERIUS Loading...")

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'AETHERIUS | ESP + Movement',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Visuals = Window:AddTab('Visuals'),
    Movement = Window:AddTab('Movement'),
    Settings = Window:AddTab('UI Settings'),
}

-- Load modules (logic only)
loadstring(game:HttpGet("https://raw.githubusercontent.com/7xtrnl/xorslua/master/visuals.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/7xtrnl/xorslua/master/movement.lua"))()

-- ================= VISUALS TAB (All UI here) =================
local VisualsBox = Tabs.Visuals:AddLeftGroupbox('ESP Box')

VisualsBox:AddToggle('BoxFilledToggle', {
    Text = 'Box Filled',
    Default = true,
})

VisualsBox:AddToggle('BoxOutlineToggle', {
    Text = 'Box Outline',
    Default = true,
})

VisualsBox:AddSlider('OutlineThicknessSlider', {
    Text = 'Outline Thickness',
    Default = 1.5,
    Min = 1,
    Max = 5,
    Rounding = 1,
})

-- Add more toggles here if you want...

-- ================= MOVEMENT TAB =================
local MoveBox = Tabs.Movement:AddLeftGroupbox('Movement')

MoveBox:AddSlider('WalkSpeedSlider', {
    Text = 'Walk Speed',
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end
})

MoveBox:AddToggle('FlyToggle', {
    Text = 'Enable Fly',
    Default = false,
    Callback = function(Value)
        print("Fly:", Value)
    end
})

MoveBox:AddSlider('FlySpeedSlider', {
    Text = 'Fly Speed',
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        print("Fly Speed:", Value)
    end
})

print("✅ AETHERIUS Loaded!")
