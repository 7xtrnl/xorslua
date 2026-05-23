-- main.lua
print("🌟 AETHERIUS Loading...")

-- Load Config
loadstring(readfile("AETHERIUS/config.lua"))()

-- Load Modules
local Visuals   = loadstring(readfile("AETHERIUS/visuals.lua"))()
local Movement  = loadstring(readfile("AETHERIUS/movement.lua"))()
local Misc      = loadstring(readfile("AETHERIUS/misc.lua"))()

print("✅ AETHERIUS Loaded Successfully!")
print("🎮 Press END to open menu")

getgenv().Aetherius = {
    Visuals = Visuals,
    Movement = Movement,
    Misc = Misc
}