--[[
    DELTA EXECUTOR - FPS BOOSTER & LAG MACHINE
    Fitur: 
    1. Lag Server (bikin patah-patah/FPS drop) - ON/OFF
    2. Booster (bikin game ringan + HD sedikit) - ON/OFF + Monitor FPS
    UI kecil + simple, ada ❌ close, tekan L buka lagi
    by Dyvillexz/Codex 🔥
]]

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // Variables
local lagEnabled = false
local boostEnabled = false
local currentFPS = 60
local fpsMonitor = nil

-- // Original Settings (buat restore)
local originalSettings = {
    Brightness = Lighting.Brightness,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    Technology = Lighting.Technology,
    MaterialService = {
        UsePartMaterial = false
    }
}

-- // Fungsi Monitor FPS
local function startFPSMonitor()
    if fpsMonitor then return end
    local lastTime = tick()
    local frameCount = 0
    
    fpsMonitor = RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastTime >= 1 then
            currentFPS = frameCount
            frameCount = 0
            lastTime = currentTime
            
            -- Update display di UI kalo ada
            for _, v in pairs(screenGui:GetDescendants()) do
                if v.Name == "FPSLabel" and v:IsA("TextLabel") then
                    v.Text = "FPS: " .. currentFPS .. " | " .. (boostEnabled and "⚡BOOST ON" or "💀LAG OFF")
                end
            end
        end
    end)
end

-- // FUNGSI LAG MACHINE (bikin game patah-patah)
local lagConnections = {}
local function enableLag()
    -- Matiin booster dulu kalo nyala
    if boostEnabled then
        enableBoost(false)
    end
    
    -- Method 1: Spam part creation
    local spamParts = {}
    local partSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        for i = 1, 5 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(1, 1, 1)
            part.Position = Vector3.new(math.random(-100, 100), math.random(-50, 50), math.random(-100, 100))
            part.Anchored = true
            part.Transparency = 1
            part.CanCollide = false
            part.Parent = Workspace
            table.insert(spamParts, part)
            
            -- Hapus setelah 0.5 detik
            task.delay(0.5, function()
                pcall(function() part:Destroy() end)
            end)
        end
    end)
    table.insert(lagConnections, partSpam)
    
    -- Method 2: Set low graphics setiap frame
    local graphicsSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        pcall(function()
            -- Force render setiap frame biar berat
            local settings = UserSettings()
            local gameSettings = settings.GameSettings
            if gameSettings then
                gameSettings.RenderQuality = Enum.RenderQuality.Automatic
            end
        end)
    end)
    table.insert(lagConnections, graphicsSpam)
    
    -- Method 3: Spam remote event (kalo ada)
    local remoteSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        pcall(function()
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    pcall(function() v:FireServer() end)
                end
            end
        end)
    end)
    table.insert(lagConnections, remoteSpam)
    
    -- Method 4: Bikin banyak particle
    local particleSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local att = Instance.new("Attachment")
            att.Parent = LocalPlayer.Character.HumanoidRootPart
            local particle = Instance.new("ParticleEmitter")
            particle.Parent = att
            particle.Rate = 500
            particle.Lifetime = NumberRange.new(0.1)
            particle.SpreadAngle = Vector2.new(360, 360)
            task.delay(0.3, function()
                pcall(function() 
                    particle:Destroy() 
                    att:Destroy() 
                end)
            end)
        end
    end)
    table.insert(lagConnections, particleSpam)
    
    -- Method 5: Kurangin FPS limit
    local fpsLimit = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        task.wait(0.03) -- Force delay
    end)
    table.insert(lagConnections, fpsLimit)
end

local function disableLag()
    lagEnabled = false
    for _, conn in pairs(lagConnections) do
        pcall(function() conn:Disconnect() end)
    end
    lagConnections = {}
end

-- // FUNGSI BOOSTER (bikin ringan + HD dikit)
local boostConnections = {}
local function enableBoost(state)
    if state then
        -- Matiin lag dulu kalo nyala
        if lagEnabled then
            disableLag()
            lagEnabled = false
        end
        
        boostEnabled = true
        
        -- Setting graphics ke rendah biar ringan
        pcall(function()
            local settings = UserSettings()
            local gameSettings = settings.GameSettings
            if gameSettings then
                gameSettings.RenderQuality = Enum.RenderQuality.QualityLevel01
            end
        end)
        
        -- Matiin efek berat
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100
        Lighting.Brightness = 1.5
        
        -- Bersihin particle & effect berat
        local cleanupConn = RunService.RenderStepped:Connect(function()
            if not boostEnabled then return end
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
                if v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                end
            end
        end)
        table.insert(boostConnections, cleanupConn)
        
        -- Kurangin view distance
        local viewDistance = RunService.RenderStepped:Connect(function()
            if not boostEnabled then return end
            Workspace.CurrentCamera.ViewportSize = Vector2.new(800, 600)
        end)
        table.insert(boostConnections, viewDistance)
        
        -- Setting HD dikit (biar ga terlalu jelek)
        local hdSettings = RunService.RenderStepped:Connect(function()
            if not boostEnabled then return end
            local colorCorrection = Lighting:FindFirstChild("ColorCorrection")
            if not colorCorrection and boostEnabled then
                local cc = Instance.new("ColorCorrection")
                cc.Name = "ColorCorrection"
                cc.Contrast = 1.1
                cc.Saturation = 1.05
                cc.Brightness = 0.05
                cc.Parent = Lighting
            end
        end)
        table.insert(boostConnections, hdSettings)
        
    else
        boostEnabled = false
        for _, conn in pairs(boostConnections) do
            pcall(function() conn:Disconnect() end)
        end
        boostConnections = {}
        
        -- Restore original settings
        Lighting.GlobalShadows = originalSettings.GlobalShadows
        Lighting.FogEnd = originalSettings.FogEnd
        Lighting.Brightness = originalSettings.Brightness
        
        -- Hapus color correction
        local cc = Lighting:FindFirstChild("ColorCorrection")
        if cc then cc:Destroy() end
    end
end

-- // UI KECIL + SIMPEL
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSBoosterLagHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame (kecil)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 130)
mainFrame.Position = UDim2.new(0.5, -110, 0.5, -65)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 1.5

-- Title bar
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
titleBar.BackgroundTransparency = 0.5
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "🌀 FPS CTRL"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left

-- Tombol Close ❌
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -28, 0.5, -12.5)
closeBtn.Text = "❌"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.BackgroundTransparency = 1
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
end)

-- FPS Display
local fpsLabel = Instance.new("TextLabel", mainFrame)
fpsLabel.Name = "FPSLabel"
fpsLabel.Size = UDim2.new(1, -20, 0, 20)
fpsLabel.Position = UDim2.new(0, 10, 0, 38)
fpsLabel.Text = "FPS: -- | ⚡OFF"
fpsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextSize = 10
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Lag
local lagFrame = Instance.new("Frame", mainFrame)
lagFrame.Size = UDim2.new(1, -20, 0, 25)
lagFrame.Position = UDim2.new(0, 10, 0, 62)
lagFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
lagFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", lagFrame).CornerRadius = UDim.new(0, 6)

local lagLabel = Instance.new("TextLabel", lagFrame)
lagLabel.Size = UDim2.new(0.6, 0, 1, 0)
lagLabel.Text = "💀 Lag Mode"
lagLabel.BackgroundTransparency = 1
lagLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
lagLabel.Font = Enum.Font.Gotham
lagLabel.TextSize = 10
lagLabel.TextXAlignment = Enum.TextXAlignment.Left

local lagToggle = Instance.new("TextButton", lagFrame)
lagToggle.Size = UDim2.new(0, 40, 0, 19)
lagToggle.Position = UDim2.new(1, -48, 0.5, -9.5)
lagToggle.Text = "OFF"
lagToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
lagToggle.Font = Enum.Font.GothamBold
lagToggle.TextSize = 9
Instance.new("UICorner", lagToggle).CornerRadius = UDim.new(0, 4)

lagToggle.MouseButton1Click:Connect(function()
    if not lagEnabled then
        lagEnabled = true
        lagToggle.Text = "ON"
        lagToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        enableLag()
        -- Matiin booster kalo nyala
        if boostEnabled then
            enableBoost(false)
            boostToggle.Text = "OFF"
            boostToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    else
        lagEnabled = false
        lagToggle.Text = "OFF"
        lagToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        disableLag()
    end
end)

-- Toggle Boost
local boostFrame = Instance.new("Frame", mainFrame)
boostFrame.Size = UDim2.new(1, -20, 0, 25)
boostFrame.Position = UDim2.new(0, 10, 0, 92)
boostFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
boostFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", boostFrame).CornerRadius = UDim.new(0, 6)

local boostLabel = Instance.new("TextLabel", boostFrame)
boostLabel.Size = UDim2.new(0.6, 0, 1, 0)
boostLabel.Text = "⚡ Booster (Ringan+HD)"
boostLabel.BackgroundTransparency = 1
boostLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
boostLabel.Font = Enum.Font.Gotham
boostLabel.TextSize = 10
boostLabel.TextXAlignment = Enum.TextXAlignment.Left

local boostToggle = Instance.new("TextButton", boostFrame)
boostToggle.Size = UDim2.new(0, 40, 0, 19)
boostToggle.Position = UDim2.new(1, -48, 0.5, -9.5)
boostToggle.Text = "OFF"
boostToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
boostToggle.Font = Enum.Font.GothamBold
boostToggle.TextSize = 9
Instance.new("UICorner", boostToggle).CornerRadius = UDim.new(0, 4)

boostToggle.MouseButton1Click:Connect(function()
    if not boostEnabled then
        boostEnabled = true
        boostToggle.Text = "ON"
        boostToggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        enableBoost(true)
        -- Matiin lag kalo nyala
        if lagEnabled then
            lagEnabled = false
            lagToggle.Text = "OFF"
            lagToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            disableLag()
        end
    else
        boostEnabled = false
        boostToggle.Text = "OFF"
        boostToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        enableBoost(false)
    end
end)

-- Tombol L (toggle UI)
local lButton = Instance.new("TextButton", screenGui)
lButton.Size = UDim2.new(0, 40, 0, 40)
lButton.Position = UDim2.new(0, 10, 1, -55)
lButton.Text = "L"
lButton.TextColor3 = Color3.fromRGB(0, 255, 255)
lButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
lButton.BackgroundTransparency = 0.3
lButton.Font = Enum.Font.GothamBold
lButton.TextSize = 24
Instance.new("UICorner", lButton).CornerRadius = UDim.new(1, 0)
local lStroke = Instance.new("UIStroke", lButton)
lStroke.Color = Color3.fromRGB(0, 255, 255)
lStroke.Thickness = 1.5

lButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- Start FPS Monitor
startFPSMonitor()

-- Auto matiin lag/boost kalo character mati
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if lagEnabled then
        -- restart lag
        disableLag()
        enableLag()
    end
    if boostEnabled then
        enableBoost(true)
    end
end)

-- Notifikasi ready
local notif = Instance.new("TextLabel", screenGui)
notif.Size = UDim2.new(0, 250, 0, 30)
notif.Position = UDim2.new(0.5, -125, 0, 50)
notif.Text = "✅ FPS CTRL ACTIVE | Tekan L"
notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notif.BackgroundTransparency = 0.3
notif.TextColor3 = Color3.fromRGB(0, 255, 0)
notif.Font = Enum.Font.GothamBold
notif.TextSize = 11
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
task.wait(2)
notif:Destroy()

print("🔥 FPS Booster & Lag Machine Loaded!")

-- // ========== GITHUB & LOADSTRING ========== //
-- [[ 
--    NAMA FILE DI GITHUB: 
--    "FPS_CTRL_Delta.lua" 
--    atau "LagBoosterV1.lua"
--    
--    REPO NAME SARAN:
--    "Delta-Executor-Scripts" atau "Roblox-FPS-Tools"
--
--    LOADSTRING GAME:
--    loadstring(game:HttpGet("https://raw.githubusercontent.com/[USERNAME]/[REPO]/main/FPS_CTRL_Delta.lua"))()
--    
--    Contoh (ganti USERNAME dan REPO sesuai punya lu):
--    loadstring(game:HttpGet("https://raw.githubusercontent.com/Dyvillexz/Delta-Scripts/main/FPS_CTRL_Delta.lua"))()
-- ]]

print([[
========================================
📁 SCRIPT SIAP UPLOAD KE GITHUB
========================================
Nama file: FPS_CTRL_Delta.lua

Loadstring buat user:
loadstring(game:HttpGet("https://raw.githubusercontent.com/[USERNAME]/[REPO]/main/FPS_CTRL_Delta.lua"))()

Ganti [USERNAME] dan [REPO] sesuai punya lu!

Fitur:
✅ Lag Mode (bikin patah-patah/FPS drop)
✅ Booster Mode (bikin ringan + HD dikit)
✅ Monitor FPS real-time
✅ UI kecil + ❌ close + L toggle
========================================
]])
