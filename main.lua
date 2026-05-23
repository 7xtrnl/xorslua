-- main.lua (Fixed for GitHub)
print("🌟 AETHERIUS Loading...")

-- Load from GitHub (works in executor)
loadstring(game:HttpGet("https://raw.githubusercontent.com/7xtrnl/xorslua/master/config.lua"))()

local Visuals  = loadstring(game:HttpGet("https://raw.githubusercontent.com/7xtrnl/xorslua/master/visuals.lua"))()
local Movement = loadstring(game:HttpGet("https://raw.githubusercontent.com/7xtrnl/xorslua/master/movement.lua"))()
local Misc     = loadstring(game:HttpGet("https://raw.githubusercontent.com/7xtrnl/xorslua/master/misc.lua"))()

print("✅ AETHERIUS Loaded Successfully!")
print("🎮 Press END to open menu")

getgenv().Aetherius = {
    Visuals = Visuals,
    Movement = Movement,
    Misc = Misc
}
