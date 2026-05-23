-- main.lua
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

-- Load modules
local Visuals = loadstring(game:HttpGet("https://raw.githubusercontent.com/7xtrnl/xorslua/master/visuals.lua"))()
local Movement = loadstring(game:HttpGet("https://raw.githubusercontent.com/7xtrnl/xorslua/master/movement.lua"))()

print("✅ AETHERIUS Loaded Successfully!")
