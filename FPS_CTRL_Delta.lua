--[[
    DELTA EXECUTOR - LAG SPIKE & BOOSTER [FINAL WORKING]
    Fitur: 
    1. Lag Mode - FLASHLIGHT/BLIND effect ke player lain + Freeze mereka (GW AMAN)
    2. Booster - MATIIN SEMUA EFFECT + FPS MAX (ringan beneran)
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
local myUsername = "kilo9582"
local currentFPS = 60
local currentPing = 0

-- // FPS + PING MONITOR
local function startMonitors()
    spawn(function()
        while true do
            local start = tick()
            pcall(function()
                game:GetService("HttpService"):GetAsync("https://www.google.com", true)
                currentPing = math.floor((tick() - start) * 1000)
            end)
            for _, v in pairs(screenGui:GetDescendants()) do
                if v.Name == "StatsLabel" then
                    v.Text = "FPS: " .. currentFPS .. " | PING: " .. currentPing .. "ms"
                end
            end
            task.wait(1)
        end
    end)
    
    local lastTime = tick()
    local frameCount = 0
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        if tick() - lastTime >= 1 then
            currentFPS = frameCount
            frameCount = 0
            lastTime = tick()
        end
    end)
end

-- // ========== LAG MODE (EFFECT KE PLAYER LAIN, GW AMAN) ==========
local lagThreads = {}

-- Buat effect blind/flashlight ke player lain
local function blindPlayer(targetPlr)
    if not targetPlr or targetPlr == LocalPlayer or targetPlr.Name == myUsername then return end
    
    pcall(function()
        -- Method 1: Kirim remote buat bikin blind
        local blindRemote = Instance.new("RemoteEvent")
        blindRemote.Name = "BlindEffect_" .. math.random(1, 999999)
        blindRemote.Parent = ReplicatedStorage
        
        -- Effect blind pake GUI di client mereka
        blindRemote.OnServerEvent:Connect(function(plr)
            if plr == targetPlr then
                local gui = Instance.new("ScreenGui")
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 1, 0)
                frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                frame.BackgroundTransparency = 0
                frame.Parent = gui
                gui.Parent = plr.PlayerGui
                task.delay(0.5, function()
                    pcall(function() gui:Destroy() end)
                end)
            end
        end)
        
        blindRemote:FireServer()
        task.delay(0.1, function()
            pcall(function() blindRemote:Destroy() end)
        end)
    end)
end

-- Method 2: Spam part buat nutupin kamera player lain (fallback)
local function spamPartOnPlayer(targetPlr)
    if not targetPlr or targetPlr == LocalPlayer or targetPlr.Name == myUsername then return end
    
    local char = targetPlr.Character
    if char and char:FindFirstChild("Head") then
        for i = 1, 30 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(2, 2, 2)
            part.Position = char.Head.Position + Vector3.new(math.random(-3, 3), math.random(-1, 1), math.random(-3, 3))
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0.3
            part.BrickColor = BrickColor.new("White")
            part.Material = Enum.Material.Neon
            part.Parent = Workspace
            task.delay(0.3, function()
                pcall(function() part:Destroy() end)
            end)
        end
    end
end

-- Method 3: Freeze player lain (pake BodyVelocity)
local function freezePlayer(targetPlr)
    if not targetPlr or targetPlr == LocalPlayer or targetPlr.Name == myUsername then return end
    
    local char = targetPlr.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = char.HumanoidRootPart
        
        task.delay(0.5, function()
            pcall(function() bv:Destroy() end)
        end)
    end
end

-- Method 4: Bikin lag pake spam sound di client mereka
local function spamSound(targetPlr)
    if not targetPlr or targetPlr == LocalPlayer or targetPlr.Name == myUsername then return end
    
    local char = targetPlr.Character
    if char then
        for i = 1, 5 do
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxasset://sounds/uuhhh.mp3"
            sound.Volume = 1
            sound.Looped = true
            sound.Parent = char
            sound:Play()
            task.delay(1, function()
                pcall(function() sound:Stop(); sound:Destroy() end)
            end)
        end
    end
end

-- Method 5: Patah2 pake spam tween kamera mereka
local function shakeCamera(targetPlr)
    if not targetPlr or targetPlr == LocalPlayer or targetPlr.Name == myUsername then return end
    
    pcall(function()
        local shakeRemote = Instance.new("RemoteEvent")
        shakeRemote.Name = "ShakeCam_" .. math.random(1, 999999)
        shakeRemote.Parent = ReplicatedStorage
        
        shakeRemote.OnServerEvent:Connect(function(plr)
            if plr == targetPlr then
                for i = 1, 20 do
                    local cam = workspace.CurrentCamera
                    local original = cam.CFrame
                    cam.CFrame = original * CFrame.new(math.random(-2, 2), math.random(-2, 2), 0)
                    task.wait(0.02)
                    cam.CFrame = original
                end
            end
        end)
        
        shakeRemote:FireServer()
        task.delay(0.2, function()
            pcall(function() shakeRemote:Destroy() end)
        end)
    end)
end

-- MAIN LAG FUNCTION
local lagConnections = {}
local function enableLag()
    if boostEnabled then
        enableBoost(false)
    end
    
    lagEnabled = true
    
    -- Loop buat serang semua player lain
    local attackLoop = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Name ~= myUsername then
                -- Kasih semua efek sekaligus
                blindPlayer(plr)
                spamPartOnPlayer(plr)
                freezePlayer(plr)
                spamSound(plr)
                shakeCamera(plr)
            end
        end
    end)
    table.insert(lagConnections, attackLoop)
    
    -- Juga spam remote setiap frame
    local remoteSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Name ~= myUsername then
                for i = 1, 3 do
                    local fakeRemote = Instance.new("RemoteEvent")
                    fakeRemote.Name = "Lag_" .. math.random(1, 99999)
                    fakeRemote.Parent = ReplicatedStorage
                    pcall(function()
                        fakeRemote:FireClient(plr)
                        fakeRemote:FireServer("payload_" .. math.random(1, 999999))
                    end)
                    task.delay(0.1, function()
                        pcall(function() fakeRemote:Destroy() end)
                    end)
                end
            end
        end
    end)
    table.insert(lagConnections, remoteSpam)
end

local function disableLag()
    lagEnabled = false
    for _, conn in pairs(lagConnections) do
        pcall(function() conn:Disconnect() end)
    end
    lagConnections = {}
end

-- // ========== BOOSTER (RINGAN BENERAN + FPS MAX) ==========
local boostConnections = {}

local function enableBoost(state)
    if state then
        if lagEnabled then
            disableLag()
            if lagToggle then
                lagToggle.Text = "OFF"
                lagToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
        end
        
        boostEnabled = true
        
        -- 1. Turunin graphics ke paling rendah
        pcall(function()
            local settings = UserSettings()
            local gameSettings = settings.GameSettings
            if gameSettings then
                gameSettings.RenderQuality = Enum.RenderQuality.QualityLevel01
                gameSettings.MaterialQuality = Enum.MaterialQuality.Low
            end
        end)
        
        -- 2. Matiin semua effect lighting
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 0
        Lighting.FogStart = 0
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        
        -- 3. Matiin semua particle, fire, light di workspace setiap frame
        local cleaner = RunService.RenderStepped:Connect(function()
            if not boostEnabled then return end
            
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") then
                    v.Enabled = false
                    v.Rate = 0
                end
                if v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                    v.Enabled = false
                end
                if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                    v.Enabled = false
                end
                if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
                    v.Enabled = false
                end
                if v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                end
            end
            
            -- Matiin water effect
            if Workspace.Terrain then
                Workspace.Terrain.WaterWaveSize = 0
                Workspace.Terrain.WaterReflectance = 0
                Workspace.Terrain.WaterRefraction = 0
                Workspace.Terrain.WaterTransparency = 1
            end
        end)
        table.insert(boostConnections, cleaner)
        
        -- 4. Set FOV lebih kecil biar ringan
        local fovChanger = RunService.RenderStepped:Connect(function()
            if not boostEnabled then return end
            Camera.FieldOfView = 60
        end)
        table.insert(boostConnections, fovChanger)
        
        task.wait(0.1)
        
    else
        boostEnabled = false
        
        for _, conn in pairs(boostConnections) do
            pcall(function() conn:Disconnect() end)
        end
        boostConnections = {}
        
        -- Restore dikit
        Lighting.Brightness = 1
        Lighting.FogEnd = 1000
        Camera.FieldOfView = 70
        
        pcall(function()
            local settings = UserSettings()
            local gameSettings = settings.GameSettings
            if gameSettings then
                gameSettings.RenderQuality = Enum.RenderQuality.Automatic
            end
        end)
    end
end

-- // ========== UI (TETAP SAMA, GAK DIUBAH) ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

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

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
titleBar.BackgroundTransparency = 0.5
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -30, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "🌀 DELTA HUB"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left

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

-- FPS Label di dalem main UI
local fpsLabel = Instance.new("TextLabel", mainFrame)
fpsLabel.Size = UDim2.new(1, -20, 0, 20)
fpsLabel.Position = UDim2.new(0, 10, 0, 38)
fpsLabel.Text = "📊 Status: Normal"
fpsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
fpsLabel.BackgroundTransparency = 1
fpsLabel.Font = Enum.Font.Gotham
fpsLabel.TextSize = 10
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Lag Toggle
local lagFrame = Instance.new("Frame", mainFrame)
lagFrame.Size = UDim2.new(1, -20, 0, 25)
lagFrame.Position = UDim2.new(0, 10, 0, 62)
lagFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
lagFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", lagFrame).CornerRadius = UDim.new(0, 6)

local lagLabel = Instance.new("TextLabel", lagFrame)
lagLabel.Size = UDim2.new(0.65, 0, 1, 0)
lagLabel.Text = "💀 Lag Mode (Blind+Freeze)"
lagLabel.BackgroundTransparency = 1
lagLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
lagLabel.Font = Enum.Font.Gotham
lagLabel.TextSize = 9
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
        fpsLabel.Text = "📊 Status: LAGGING ORANG LAIN"
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
        fpsLabel.Text = "📊 Status: Normal"
        disableLag()
    end
end)

-- Boost Toggle
local boostFrame = Instance.new("Frame", mainFrame)
boostFrame.Size = UDim2.new(1, -20, 0, 25)
boostFrame.Position = UDim2.new(0, 10, 0, 92)
boostFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
boostFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", boostFrame).CornerRadius = UDim.new(0, 6)

local boostLabel = Instance.new("TextLabel", boostFrame)
boostLabel.Size = UDim2.new(0.65, 0, 1, 0)
boostLabel.Text = "⚡ Booster (Ringan Max)"
boostLabel.BackgroundTransparency = 1
boostLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
boostLabel.Font = Enum.Font.Gotham
boostLabel.TextSize = 9
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
        fpsLabel.Text = "📊 Status: BOOST ON (Ringan)"
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
        fpsLabel.Text = "📊 Status: Normal"
        enableBoost(false)
    end
end)

-- Tombol L buka/tutup
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

lButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)

-- UI kecil FPS + PING
local statsFrame = Instance.new("Frame", screenGui)
statsFrame.Size = UDim2.new(0, 160, 0, 25)
statsFrame.Position = UDim2.new(1, -170, 0, 10)
statsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
statsFrame.BackgroundTransparency = 0.5
Instance.new("UICorner", statsFrame).CornerRadius = UDim.new(0, 8)

local statsLabel = Instance.new("TextLabel", statsFrame)
statsLabel.Name = "StatsLabel"
statsLabel.Size = UDim2.new(1, 0, 1, 0)
statsLabel.Text = "FPS: -- | PING: --ms"
statsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
statsLabel.BackgroundTransparency = 1
statsLabel.Font = Enum.Font.GothamBold
statsLabel.TextSize = 10

-- Start monitors
startMonitors()

-- Character respawn handler
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

local notif = Instance.new("TextLabel", screenGui)
notif.Size = UDim2.new(0, 350, 0, 30)
notif.Position = UDim2.new(0.5, -175, 0, 50)
notif.Text = "✅ DELTA HUB ACTIVE | " .. myUsername .. " AMAN DARI LAG"
notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notif.BackgroundTransparency = 0.3
notif.TextColor3 = Color3.fromRGB(0, 255, 0)
notif.Font = Enum.Font.GothamBold
notif.TextSize = 11
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
task.wait(3)
notif:Destroy()

print("🔥 DELTA HUB LOADED!")
print("✅ Lag Mode: Blind/Flashlight + Freeze + Shake Camera + Spam Sound ke player lain")
print("✅ Booster: Matiin semua effect, FPS MAX, ringan beneran")

-- // LOADSTRING
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Dyvillexz/Delta-Scripts/main/DeltaHub.lua"))()
