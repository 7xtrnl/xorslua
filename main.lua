-- main.lua (With Movement Tab Controls)
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

-- Load ESP
loadstring(game:HttpGet("https://raw.githubusercontent.com/7xtrnl/xorslua/master/visuals.lua"))()

-- ================= MOVEMENT TAB =================
local MoveBox = Tabs.Movement:AddLeftGroupbox('Movement')

-- WalkSpeed
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

-- Fly Toggle
MoveBox:AddToggle('FlyToggle', {
    Text = 'Enable Fly',
    Default = false,
    Callback = function(Value)
        -- Fly logic will be added here
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

print("✅ AETHERIUS Loaded with Movement Controls!")
