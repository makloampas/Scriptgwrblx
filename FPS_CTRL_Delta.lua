--[[
    DELTA EXECUTOR - FPS BOOSTER & LAG MACHINE [UPGRADE]
    Fitur: 
    1. Lag Server (bikin patah-patah/FPS drop) - KHUSUS PLAYER LAIN, GW AMAN
    2. Booster (bikin RINGAN BANGET + NO HD, FPS STABIL)
    UI kecil + simple (TETAP SAMA, GAK DIUBAH)
    by Dyvillexz/Codex 🔥
]]

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // VARIABLES
local lagEnabled = false
local boostEnabled = false
local currentFPS = 60
local fpsMonitor = nil
local myUsername = "kilo9582" -- GW AMAN DARI LAG

-- // Original Settings (buat restore booster)
local originalSettings = {
    Brightness = Lighting.Brightness,
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    Technology = Lighting.Technology,
    Ambient = Lighting.Ambient,
    ClockTime = Lighting.ClockTime
}

-- // Fungsi Monitor FPS (Cuma angka, gak pake HD)
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
            
            -- Update display di UI
            for _, v in pairs(screenGui:GetDescendants()) do
                if v.Name == "FPSLabel" and v:IsA("TextLabel") then
                    if boostEnabled then
                        v.Text = "📊 FPS: " .. currentFPS .. " | ⚡BOOST ON"
                    elseif lagEnabled then
                        v.Text = "📊 FPS: " .. currentFPS .. " | 💀LAG ON (Org lain)"
                    else
                        v.Text = "📊 FPS: " .. currentFPS .. " | ⚪Normal"
                    end
                end
            end
        end
    end)
end

-- // FUNGSI LAG MACHINE (KHUSUS PLAYER LAIN, GW AMAN)
local lagConnections = {}
local function enableLag()
    if boostEnabled then
        enableBoost(false)
    end
    
    lagEnabled = true
    
    -- Method 1: Spam part di sekitar player lain (bukan gw)
    local partSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Name ~= myUsername then
                local char = plr.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    for i = 1, 10 do
                        local part = Instance.new("Part")
                        part.Size = Vector3.new(2, 2, 2)
                        part.Position = char.HumanoidRootPart.Position + Vector3.new(math.random(-20, 20), math.random(-10, 10), math.random(-20, 20))
                        part.Anchored = true
                        part.Transparency = 1
                        part.CanCollide = false
                        part.Parent = Workspace
                        
                        task.delay(0.3, function()
                            pcall(function() part:Destroy() end)
                        end)
                    end
                end
            end
        end
    end)
    table.insert(lagConnections, partSpam)
    
    -- Method 2: Spam remote event ke player lain
    local remoteSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        pcall(function()
            for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                    for _, plr in pairs(Players:GetPlayers()) do
                        if plr ~= LocalPlayer and plr.Name ~= myUsername then
                            pcall(function() 
                                v:FireClient(plr) 
                            end)
                        end
                    end
                end
            end
        end)
    end)
    table.insert(lagConnections, remoteSpam)
    
    -- Method 3: Spam particle di sekitar player lain
    local particleSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Name ~= myUsername and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local att = Instance.new("Attachment")
                att.Parent = plr.Character.HumanoidRootPart
                local particle = Instance.new("ParticleEmitter")
                particle.Parent = att
                particle.Rate = 1000
                particle.Lifetime = NumberRange.new(0.5)
                particle.SpreadAngle = Vector2.new(360, 360)
                particle.Speed = NumberRange.new(50)
                particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
                
                task.delay(0.5, function()
                    pcall(function() 
                        particle:Destroy() 
                        att:Destroy() 
                    end)
                end)
            end
        end
    end)
    table.insert(lagConnections, particleSpam)
    
    -- Method 4: Spam light di sekitar player lain
    local lightSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Name ~= myUsername and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local light = Instance.new("PointLight")
                light.Parent = plr.Character.HumanoidRootPart
                light.Range = 30
                light.Brightness = 5
                light.Color = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
                
                task.delay(0.3, function()
                    pcall(function() light:Destroy() end)
                end)
            end
        end
    end)
    table.insert(lagConnections, lightSpam)
    
    -- Method 5: Force client-side lag (buat player lain)
    local clientLag = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Name ~= myUsername then
                pcall(function()
                    local remote = Instance.new("RemoteEvent")
                    remote.Parent = ReplicatedStorage
                    remote.Name = "ForceLag_" .. math.random(1, 9999)
                    remote:FireClient(plr)
                    task.delay(0.2, function()
                        remote:Destroy()
                    end)
                end)
            end
        end
    end)
    table.insert(lagConnections, clientLag)
end

local function disableLag()
    lagEnabled = false
    for _, conn in pairs(lagConnections) do
        pcall(function() conn:Disconnect() end)
    end
    lagConnections = {}
end

-- // FUNGSI BOOSTER (RINGAN BANGET, NO HD, FPS STABIL)
local boostConnections = {}
local function enableBoost(state)
    if state then
        if lagEnabled then
            disableLag()
            lagEnabled = false
            -- Update toggle UI
            if lagToggle then
                lagToggle.Text = "OFF"
                lagToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
        end
        
        boostEnabled = true
        
        -- SETTING GRAPHICS PALING RENDAH
        pcall(function()
            local settings = UserSettings()
            local gameSettings = settings.GameSettings
            if gameSettings then
                gameSettings.RenderQuality = Enum.RenderQuality.QualityLevel01
                gameSettings.MaterialQuality = Enum.MaterialQuality.Low
            end
        end)
        
        -- Matiin semua efek visual berat
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1
        Lighting.FogStart = 0
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.ClockTime = 14
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        
        -- Matiin semua efek partikel di workspace
        local cleanupConn = RunService.RenderStepped:Connect(function()
            if not boostEnabled then return end
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") then
                    v.Enabled = false
                    v.Rate = 0
                end
                if v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
                if v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                end
                if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                    v.Enabled = false
                end
            end
        end)
        table.insert(boostConnections, cleanupConn)
        
        -- Force low quality terrain
        local terrain = Workspace.Terrain
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterReflectance = 0
            terrain.WaterRefraction = 0
            terrain.WaterTransparency = 0
        end
        
        -- Kurangin view distance & resolution
        local viewDistance = RunService.RenderStepped:Connect(function()
            if not boostEnabled then return end
            if Camera then
                Camera.ViewportSize = Vector2.new(800, 600)
            end
            Workspace.CurrentCamera.FieldOfView = 70
        end)
        table.insert(boostConnections, viewDistance)
        
        -- Hapus semua color correction (NO HD!)
        local cc = Lighting:FindFirstChild("ColorCorrection")
        if cc then cc:Destroy() end
        
        -- Force refresh biar efek langsung kerasa
        task.wait(0.1)
        
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
        Lighting.Ambient = originalSettings.Ambient
        Lighting.ClockTime = originalSettings.ClockTime
        Lighting.OutdoorAmbient = originalSettings.Ambient
        
        pcall(function()
            local settings = UserSettings()
            local gameSettings = settings.GameSettings
            if gameSettings then
                gameSettings.RenderQuality = Enum.RenderQuality.Automatic
            end
        end)
    end
end

-- // UI KECIL + SIMPEL (TETAP SAMA, GAK DIUBAH)
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
fpsLabel.Text = "📊 FPS: -- | ⚪Normal"
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
lagLabel.Text = "💀 Lag Mode (Org lain)"
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
boostLabel.Text = "⚡ Booster (Ringan + FPS)"
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
        disableLag()
        enableLag()
    end
    if boostEnabled then
        enableBoost(true)
    end
end)

-- Notifikasi ready
local notif = Instance.new("TextLabel", screenGui)
notif.Size = UDim2.new(0, 280, 0, 30)
notif.Position = UDim2.new(0.5, -140, 0, 50)
notif.Text = "✅ FPS CTRL ACTIVE | " .. myUsername .. " AMAN DARI LAG"
notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notif.BackgroundTransparency = 0.3
notif.TextColor3 = Color3.fromRGB(0, 255, 0)
notif.Font = Enum.Font.GothamBold
notif.TextSize = 11
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
task.wait(3)
notif:Destroy()

print("🔥 FPS Booster & Lag Machine Loaded!")
print("✅ Username " .. myUsername .. " AMAN dari efek lag!")
print("📊 FPS Monitor aktif, Booster bikin ringan + NO HD!")

-- // ========== GITHUB & LOADSTRING ========== //
--[[ 
    NAMA FILE DI GITHUB: "FPS_CTRL_Delta_V2.lua"
    
    LOADSTRING:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/[USERNAME]/[REPO]/main/FPS_CTRL_Delta_V2.lua"))()
    
    Contoh:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Dyvillexz/Delta-Scripts/main/FPS_CTRL_Delta_V2.lua"))()
]]
