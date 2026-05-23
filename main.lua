<<<<<<< HEAD
-- main.lua - AETHERIUS Main Entry Point
-- All UI logic is here, modules contain only functionality
 
print("🌟 AETHERIUS Loading...")
 
-- ================= LOAD LIBRARY =================
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
 
-- ================= CREATE WINDOW =================
local Window = Library:CreateWindow({
    Title = 'AETHERIUS | ESP + Movement',
    Center = true,
    AutoShow = true,
})
 
-- ================= SETUP TABS =================
local Tabs = {
    Visuals = Window:AddTab('Visuals'),
    Movement = Window:AddTab('Movement'),
    Settings = Window:AddTab('UI Settings'),
}
 
-- ================= LOAD MODULES =================
local Visuals = loadstring(game:HttpGet("https://raw.githubusercontent.com/7xtrnl/xorslua/master/visuals.lua"))()
local Movement = loadstring(game:HttpGet("https://raw.githubusercontent.com/7xtrnl/xorslua/master/movement.lua"))()
 
-- Initialize modules
Visuals.Init()
Movement.Init()
 
-- ================= VISUALS TAB UI =================
local VisualsBox = Tabs.Visuals:AddLeftGroupbox('ESP Box')
 
-- Box Settings
VisualsBox:AddToggle('BoxFilledToggle', {
    Text = 'Box Filled',
    Default = Config.Box.Filled.Enable,
    Tooltip = 'Show filled ESP box with gradient'
})
 
VisualsBox:AddSlider('GradientSpeedSlider', {
    Text = 'Gradient Speed',
    Default = Config.Box.Filled.GradientRotationSpeed,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = false,
})
 
VisualsBox:AddSlider('TransparencyStartSlider', {
    Text = 'Transparency (Close)',
    Default = Config.Box.Filled.Transparency.Start,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})
 
VisualsBox:AddSlider('TransparencyEndSlider', {
    Text = 'Transparency (Far)',
    Default = Config.Box.Filled.Transparency.End,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})
 
VisualsBox:AddToggle('BoxOutlineToggle', {
    Text = 'Box Outline',
    Default = Config.Box.Outline.Enable,
    Tooltip = 'Show black outline around box'
})
 
VisualsBox:AddSlider('OutlineThicknessSlider', {
    Text = 'Outline Thickness',
    Default = Config.Box.Outline.Thickness,
    Min = 1,
    Max = 5,
    Rounding = 1,
    Compact = false,
})
 
-- Name Settings
local VisualsText = Tabs.Visuals:AddRightGroupbox('ESP Text')
 
VisualsText:AddToggle('NameToggle', {
    Text = 'Player Name',
    Default = Config.Name.Enable,
    Tooltip = 'Show player names above ESP box'
})
 
VisualsText:AddToggle('DisplayNameToggle', {
    Text = 'Show Display Name',
    Default = Config.Name.ShowDisplayName,
    Tooltip = 'Show display name'
})
 
VisualsText:AddToggle('UsernameToggle', {
    Text = 'Show Username',
    Default = Config.Name.ShowUsername,
    Tooltip = 'Show @username'
})
 
VisualsText:AddLabel('Name Color'):AddColorPicker('NameColorPicker', {
    Default = Config.Name.Color,
    Title = 'Name Color',
})
 
VisualsText:AddSlider('NameSizeSlider', {
    Text = 'Name Size',
    Default = Config.Name.Size,
    Min = 10,
    Max = 30,
    Rounding = 0,
    Compact = false,
})
 
-- Health Settings
local VisualsHealth = Tabs.Visuals:AddLeftGroupbox('Health')
 
VisualsHealth:AddToggle('HealthBarToggle', {
    Text = 'Health Bar',
    Default = Config.HealthBar.Enable,
    Tooltip = 'Show health bar on left side'
})
 
VisualsHealth:AddToggle('PercentageToggle', {
    Text = 'Show Percentage',
    Default = Config.HealthBar.ShowPercentage,
    Tooltip = 'Show health as percentage instead of number'
})
 
VisualsHealth:AddToggle('HealthTextToggle', {
    Text = 'Health Text',
    Default = Config.HealthText.Enable,
    Tooltip = 'Show health text above health bar'
})
 
VisualsHealth:AddLabel('Health Text Color'):AddColorPicker('HealthTextColorPicker', {
    Default = Config.HealthText.Color,
    Title = 'Health Text Color',
})
 
-- Distance Settings
local VisualsDistance = Tabs.Visuals:AddRightGroupbox('Distance')
 
VisualsDistance:AddToggle('DistanceToggle', {
    Text = 'Show Distance',
    Default = Config.Distance.Enable,
    Tooltip = 'Show distance below ESP box'
})
 
VisualsDistance:AddToggle('StudsToggle', {
    Text = 'Use Studs',
    Default = Config.Distance.ShowStuds,
    Tooltip = 'Show in studs instead of meters'
})
 
VisualsDistance:AddLabel('Distance Color'):AddColorPicker('DistanceColorPicker', {
    Default = Config.Distance.Color,
    Title = 'Distance Color',
})
 
-- Skeleton Settings
local VisualsSkeleton = Tabs.Visuals:AddLeftGroupbox('Skeleton')
 
VisualsSkeleton:AddToggle('SkeletonToggle', {
    Text = 'Enable Skeleton',
    Default = Config.Skeleton.Enable,
    Tooltip = 'Show skeleton ESP'
})
 
VisualsSkeleton:AddLabel('Skeleton Color'):AddColorPicker('SkeletonColorPicker', {
    Default = Config.Skeleton.Color,
    Title = 'Skeleton Color',
})
 
VisualsSkeleton:AddSlider('SkeletonThicknessSlider', {
    Text = 'Thickness',
    Default = Config.Skeleton.Thickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Compact = false,
})
 
-- Tracer Settings
local VisualsTracer = Tabs.Visuals:AddRightGroupbox('Tracers')
 
VisualsTracer:AddToggle('TracerToggle', {
    Text = 'Enable Tracers',
    Default = Config.Tracer.Enable,
    Tooltip = 'Show lines to players'
})
 
VisualsTracer:AddLabel('Tracer Color'):AddColorPicker('TracerColorPicker', {
    Default = Config.Tracer.Color,
    Title = 'Tracer Color',
})
 
VisualsTracer:AddSlider('TracerThicknessSlider', {
    Text = 'Thickness',
    Default = Config.Tracer.Thickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Compact = false,
})
 
VisualsTracer:AddDropdown('TracerOriginDropdown', {
    Values = {'Top', 'Middle', 'Bottom'},
    Default = 3,
    Multi = false,
    Text = 'Tracer Origin',
})
 
-- ForceField Settings
local VisualsForceField = Tabs.Visuals:AddLeftGroupbox('ForceField Chams')
 
VisualsForceField:AddToggle('ForceFieldToggle', {
    Text = 'Enable ForceField',
    Default = ForceFieldConfig.Enabled,
    Tooltip = 'Apply dark forcefield material to all players'
})
 
VisualsForceField:AddLabel('ForceField Color'):AddColorPicker('ForceFieldColorPicker', {
    Default = ForceFieldConfig.Color,
    Title = 'ForceField Color',
})
 
VisualsForceField:AddSlider('TransparencySlider', {
    Text = 'Transparency',
    Default = ForceFieldConfig.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})
 
VisualsForceField:AddSlider('ReflectanceSlider', {
    Text = 'Reflectance',
    Default = ForceFieldConfig.Reflectance,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Compact = false,
})
 
VisualsForceField:AddToggle('ExcludeHeadToggle', {
    Text = 'Exclude Head',
    Default = ForceFieldConfig.ExcludeHead,
    Tooltip = 'Do not apply forcefield to heads'
})
 
-- Misc Settings
local VisualsMisc = Tabs.Visuals:AddRightGroupbox('Misc')
 
VisualsMisc:AddToggle('RemoveNametagToggle', {
    Text = 'Remove Nametags',
    Default = Config.RemoveDisplayName,
    Tooltip = 'Hide default Roblox nametags'
})
 
-- ================= MOVEMENT TAB UI =================
local MovementSpeed = Tabs.Movement:AddLeftGroupbox('Speed')
 
MovementSpeed:AddToggle('SpeedToggle', {
    Text = 'Enable Speed',
    Default = MovementConfig.Speed.Enabled,
    Tooltip = 'Modify walk speed'
})
 
MovementSpeed:AddSlider('SpeedSlider', {
    Text = 'Speed Value',
    Default = MovementConfig.Speed.Value,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Compact = false,
})
 
-- Jump Settings
local MovementJump = Tabs.Movement:AddLeftGroupbox('Jump')
 
MovementJump:AddToggle('JumpPowerToggle', {
    Text = 'Enable Jump Power',
    Default = MovementConfig.JumpPower.Enabled,
    Tooltip = 'Modify jump power'
})
 
MovementJump:AddSlider('JumpPowerSlider', {
    Text = 'Jump Power',
    Default = MovementConfig.JumpPower.Value,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Compact = false,
})
 
MovementJump:AddToggle('InfiniteJumpToggle', {
    Text = 'Infinite Jump',
    Default = MovementConfig.InfiniteJump.Enabled,
    Tooltip = 'Jump infinitely in the air'
})
 
-- Fly Settings
local MovementFly = Tabs.Movement:AddRightGroupbox('Fly')
 
MovementFly:AddToggle('FlyToggle', {
    Text = 'Enable Fly',
    Default = MovementConfig.Fly.Enabled,
    Tooltip = 'Fly around the map'
})
 
MovementFly:AddSlider('FlySpeedSlider', {
    Text = 'Fly Speed',
    Default = MovementConfig.Fly.Speed,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Compact = false,
})
 
MovementFly:AddLabel('Controls:')
MovementFly:AddLabel('W/A/S/D - Move')
MovementFly:AddLabel('Space - Up')
MovementFly:AddLabel('Shift/Ctrl - Down')
 
-- Noclip Settings
local MovementNoclip = Tabs.Movement:AddRightGroupbox('Noclip')
 
MovementNoclip:AddToggle('NoclipToggle', {
    Text = 'Enable Noclip',
    Default = MovementConfig.Noclip.Enabled,
    Tooltip = 'Walk through walls'
})
 
-- ================= UI CALLBACKS =================
 
-- Box callbacks
Toggles.BoxFilledToggle:OnChanged(function(value)
    Config.Box.Filled.Enable = value
end)
 
Options.GradientSpeedSlider:OnChanged(function(value)
    Config.Box.Filled.GradientRotationSpeed = value
end)
 
Options.TransparencyStartSlider:OnChanged(function(value)
    Config.Box.Filled.Transparency.Start = value
end)
 
Options.TransparencyEndSlider:OnChanged(function(value)
    Config.Box.Filled.Transparency.End = value
end)
 
Toggles.BoxOutlineToggle:OnChanged(function(value)
    Config.Box.Outline.Enable = value
end)
 
Options.OutlineThicknessSlider:OnChanged(function(value)
    Config.Box.Outline.Thickness = value
end)
 
-- Name callbacks
Toggles.NameToggle:OnChanged(function(value)
    Config.Name.Enable = value
end)
 
Toggles.DisplayNameToggle:OnChanged(function(value)
    Config.Name.ShowDisplayName = value
end)
 
Toggles.UsernameToggle:OnChanged(function(value)
    Config.Name.ShowUsername = value
end)
 
Options.NameColorPicker:OnChanged(function(value)
    Config.Name.Color = value
end)
 
Options.NameSizeSlider:OnChanged(function(value)
    Config.Name.Size = value
end)
 
-- Health callbacks
Toggles.HealthBarToggle:OnChanged(function(value)
    Config.HealthBar.Enable = value
end)
 
Toggles.PercentageToggle:OnChanged(function(value)
    Config.HealthBar.ShowPercentage = value
end)
 
Toggles.HealthTextToggle:OnChanged(function(value)
    Config.HealthText.Enable = value
end)
 
Options.HealthTextColorPicker:OnChanged(function(value)
    Config.HealthText.Color = value
end)
 
-- Distance callbacks
Toggles.DistanceToggle:OnChanged(function(value)
    Config.Distance.Enable = value
end)
 
Toggles.StudsToggle:OnChanged(function(value)
    Config.Distance.ShowStuds = value
end)
 
Options.DistanceColorPicker:OnChanged(function(value)
    Config.Distance.Color = value
end)
 
-- Skeleton callbacks
Toggles.SkeletonToggle:OnChanged(function(value)
    Config.Skeleton.Enable = value
end)
 
Options.SkeletonColorPicker:OnChanged(function(value)
    Config.Skeleton.Color = value
end)
 
Options.SkeletonThicknessSlider:OnChanged(function(value)
    Config.Skeleton.Thickness = value
end)
 
-- Tracer callbacks
Toggles.TracerToggle:OnChanged(function(value)
    Config.Tracer.Enable = value
    Visuals.UpdateTracers()
end)
 
Options.TracerColorPicker:OnChanged(function(value)
    Config.Tracer.Color = value
end)
 
Options.TracerThicknessSlider:OnChanged(function(value)
    Config.Tracer.Thickness = value
end)
 
Options.TracerOriginDropdown:OnChanged(function(value)
    Config.Tracer.Origin = value
end)
 
-- ForceField callbacks
Toggles.ForceFieldToggle:OnChanged(function(value)
    ForceFieldConfig.Enabled = value
    Visuals.ApplyForceField()
end)
 
Options.ForceFieldColorPicker:OnChanged(function(value)
    ForceFieldConfig.Color = value
    if ForceFieldConfig.Enabled then
        Visuals.ApplyForceField()
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
 
-- Misc callbacks
Toggles.RemoveNametagToggle:OnChanged(function(value)
    Config.RemoveDisplayName = value
end)
 
-- Movement callbacks
Toggles.SpeedToggle:OnChanged(function(value)
    Movement.ToggleSpeed(value)
end)
 
Options.SpeedSlider:OnChanged(function(value)
    Movement.SetSpeed(value)
end)
 
Toggles.JumpPowerToggle:OnChanged(function(value)
    Movement.ToggleJumpPower(value)
end)
 
Options.JumpPowerSlider:OnChanged(function(value)
    Movement.SetJumpPower(value)
end)
 
Toggles.InfiniteJumpToggle:OnChanged(function(value)
    Movement.ToggleInfiniteJump(value)
end)
 
Toggles.FlyToggle:OnChanged(function(value)
    Movement.ToggleFly(value)
end)
 
Options.FlySpeedSlider:OnChanged(function(value)
    Movement.SetFlySpeed(value)
end)
 
Toggles.NoclipToggle:OnChanged(function(value)
    Movement.ToggleNoclip(value)
end)
 
-- ================= SETTINGS TAB =================
local MenuGroup = Tabs.Settings:AddLeftGroupbox('Menu')
 
MenuGroup:AddButton('Unload', function() 
    Library:Unload()
    Visuals.Unload()
    Movement.Unload()
    print('✅ AETHERIUS Unloaded!')
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
 
ThemeManager:SetFolder('AETHERIUS')
SaveManager:SetFolder('AETHERIUS/' .. game.PlaceId)
 
SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:LoadAutoloadConfig()
 
-- Watermark
Library:SetWatermarkVisibility(true)
Library:SetWatermark('AETHERIUS v1.0 | ESP + Movement | github.com/7xtrnl')
 
print("✅ AETHERIUS Loaded Successfully!")
print("🎯 Visuals: ESP, Skeleton, Tracers, ForceField Chams")
print("⚡ Movement: Speed, Jump, Fly, Noclip, Infinite Jump")
print("🔧 Press 'End' to toggle menu")
=======
print("AETHERIUS Loading...")

local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = "AETHERIUS | ESP + Movement",
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Visuals = Window:AddTab("Visuals"),
    Movement = Window:AddTab("Movement"),
    Settings = Window:AddTab("UI Settings"),
}

loadstring(game:HttpGet("https://raw.githubusercontent.com/7xtrnl/xorslua/master/visuals.lua"))()

local MoveBox = Tabs.Movement:AddLeftGroupbox("Movement")

MoveBox:AddSlider("WalkSpeedSlider", {
    Text = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end
})

MoveBox:AddToggle("FlyToggle", {
    Text = "Enable Fly",
    Default = false,
    Callback = function(Value)
        print("Fly:", Value)
    end
})

MoveBox:AddSlider("FlySpeedSlider", {
    Text = "Fly Speed",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        print("Fly Speed:", Value)
    end
})

print("AETHERIUS Loaded!")
>>>>>>> 73656835583eed1caa01dae04d1aa7a65068b8fe
