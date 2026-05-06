--[[
    DELTA EXECUTOR - LAG & BOOSTER [FIX NETWORK ATTACK]
    Fitur: 
    1. Lag Mode (SERANG JARINGAN/LATENCY player lain pake RemoteSpam + Network flood)
    2. Booster (RINGAN + BURAM, BUKAN FULL HITAM)
    3. Monitor FPS + PING
    by Dyvillexz/Codex 🔥
]]

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- // VARIABLES
local lagEnabled = false
local boostEnabled = false
local currentFPS = 60
local currentPing = 0
local myUsername = "kilo9582"

-- // Fungsi Monitor FPS + PING
local function startMonitors()
    spawn(function()
        while true do
            local start = tick()
            pcall(function()
                HttpService:GetAsync("https://www.google.com", true)
                currentPing = math.floor((tick() - start) * 1000)
            end)
            updateStatsUI()
            task.wait(1)
        end
    end)
    
    local lastTime = tick()
    local frameCount = 0
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastTime >= 1 then
            currentFPS = frameCount
            frameCount = 0
            lastTime = currentTime
            updateStatsUI()
        end
    end)
end

local function updateStatsUI()
    for _, v in pairs(screenGui:GetDescendants()) do
        if v.Name == "StatsLabel" and v:IsA("TextLabel") then
            v.Text = "FPS: " .. currentFPS .. " | PING: " .. currentPing .. "ms"
        end
    end
end

-- // FUNGSI LAG MODE (SERANG JARINGAN/LATENCY player lain)
local lagRemotes = {}
local lagConnections = {}

local function createLagRemote()
    local remote = Instance.new("RemoteEvent")
    remote.Name = "LagAttack_" .. math.random(1, 99999)
    remote.Parent = ReplicatedStorage
    table.insert(lagRemotes, remote)
    return remote
end

local function enableLag()
    if boostEnabled then
        enableBoost(false)
    end
    
    lagEnabled = true
    
    -- SERANGAN 1: SPAM REMOTE EVENT (Bikin network overload)
    local remoteSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Name ~= myUsername then
                for i = 1, 5 do
                    local remote = createLagRemote()
                    pcall(function()
                        remote:FireClient(plr)
                        remote:FireServer("lag_payload_" .. math.random(1, 999999))
                    end)
                    task.wait(0.01)
                end
            end
        end
    end)
    table.insert(lagConnections, remoteSpam)
    
    -- SERANGAN 2: SPAM REMOTE FUNCTION (Bikin server/client hang)
    local funcSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Name ~= myUsername then
                pcall(function()
                    local rf = Instance.new("RemoteFunction")
                    rf.Name = "LagFunc_" .. math.random(1, 99999)
                    rf.Parent = ReplicatedStorage
                    rf:InvokeClient(plr)
                    task.delay(0.1, function()
                        pcall(function() rf:Destroy() end)
                    end)
                end)
            end
        end
    end)
    table.insert(lagConnections, funcSpam)
    
    -- SERANGAN 3: FAKE PACKET FLOOD (Kirim data besar ke client)
    local dataSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        
        local bigData = {}
        for i = 1, 1000 do
            bigData[i] = math.random(1, 999999)
        end
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Name ~= myUsername then
                for _, remote in pairs(ReplicatedStorage:GetChildren()) do
                    if remote:IsA("RemoteEvent") then
                        pcall(function()
                            remote:FireClient(plr, bigData)
                        end)
                    end
                end
            end
        end
    end)
    table.insert(lagConnections, dataSpam)
    
    -- SERANGAN 4: BUAT ULANG REMOTE TERUS MENERUS
    local recycleSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        
        for i = 1, 10 do
            local r = createLagRemote()
            task.delay(0.5, function()
                pcall(function() r:Destroy() end)
            end)
        end
    end)
    table.insert(lagConnections, recycleSpam)
    
    -- SERANGAN 5: SPAM JOIN/LEAVE SIMULATION
    local joinSpam = RunService.RenderStepped:Connect(function()
        if not lagEnabled then return end
        
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Name ~= myUsername then
                pcall(function()
                    local fakeJoin = Instance.new("BoolValue")
                    fakeJoin.Name = "PlayerAdded_" .. math.random(1, 9999)
                    fakeJoin.Parent = game
                    task.delay(0.1, function()
                        fakeJoin:Destroy()
                    end)
                end)
            end
        end
    end)
    table.insert(lagConnections, joinSpam)
end

local function disableLag()
    lagEnabled = false
    for _, conn in pairs(lagConnections) do
        pcall(function() conn:Disconnect() end)
    end
    lagConnections = {}
    for _, remote in pairs(lagRemotes) do
        pcall(function() remote:Destroy() end)
    end
    lagRemotes = {}
end

-- // FUNGSI BOOSTER (RINGAN + BURAM, BUKAN FULL HITAM)
local boostConnections = {}

local function enableBoost(state)
    if state then
        if lagEnabled then
            disableLag()
            lagEnabled = false
            if lagToggle then
                lagToggle.Text = "OFF"
                lagToggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            end
        end
        
        boostEnabled = true
        
        -- SETTING PALING RENDAH + BURAM (bukan hitam)
        pcall(function()
            local settings = UserSettings()
            local gameSettings = settings.GameSettings
            if gameSettings then
                gameSettings.RenderQuality = Enum.RenderQuality.QualityLevel01
                gameSettings.MaterialQuality = Enum.MaterialQuality.Low
            end
        end)
        
        -- LIGHTING: BURAM (kek buram, bukan hitam total)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 30
        Lighting.FogStart = 10
        Lighting.Brightness = 0.8
        Lighting.Ambient = Color3.fromRGB(80, 80, 80)
        Lighting.ClockTime = 12
        Lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 80)
        
        -- Matiin semua efek berat (TAPI WARNA TETAP KELIHATAN)
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
                if v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                    v.Enabled = false
                end
                if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") then
                    v.Enabled = false
                end
                -- Decal & Texture di transparency-in dikit biar ringan tapi masih keliatan
                if v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 0.5
                end
            end
        end)
        table.insert(boostConnections, cleanupConn)
        
        -- Matiin water effect
        local terrain = Workspace.Terrain
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterReflectance = 0
            terrain.WaterRefraction = 0
        end
        
        -- Kurangin view distance dikit
        local viewDistance = RunService.RenderStepped:Connect(function()
            if not boostEnabled then return end
            if Camera then
                Camera.FieldOfView = 70
            end
        end)
        table.insert(boostConnections, viewDistance)
        
        task.wait(0.1)
        
    else
        boostEnabled = false
        for _, conn in pairs(boostConnections) do
            pcall(function() conn:Disconnect() end)
        end
        boostConnections = {}
        
        -- Restore (sedikit terang)
        Lighting.Brightness = 1.5
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.ClockTime = 14
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.FogEnd = 1000
        Lighting.FogStart = 0
        
        pcall(function()
            local settings = UserSettings()
            local gameSettings = settings.GameSettings
            if gameSettings then
                gameSettings.RenderQuality = Enum.RenderQuality.Automatic
            end
        end)
    end
end

-- // UI UTAMA
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FPSBoosterLagHub"
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

local lagFrame = Instance.new("Frame", mainFrame)
lagFrame.Size = UDim2.new(1, -20, 0, 25)
lagFrame.Position = UDim2.new(0, 10, 0, 45)
lagFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
lagFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", lagFrame).CornerRadius = UDim.new(0, 6)

local lagLabel = Instance.new("TextLabel", lagFrame)
lagLabel.Size = UDim2.new(0.6, 0, 1, 0)
lagLabel.Text = "💀 Lag Mode (Network)"
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

local boostFrame = Instance.new("Frame", mainFrame)
boostFrame.Size = UDim2.new(1, -20, 0, 25)
boostFrame.Position = UDim2.new(0, 10, 0, 80)
boostFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
boostFrame.BackgroundTransparency = 0.3
Instance.new("UICorner", boostFrame).CornerRadius = UDim.new(0, 6)

local boostLabel = Instance.new("TextLabel", boostFrame)
boostLabel.Size = UDim2.new(0.6, 0, 1, 0)
boostLabel.Text = "⚡ Booster (Buram)"
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

-- Tombol L
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

-- Start
startMonitors()

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
notif.Text = "✅ LAG MODE: SERANG JARINGAN PLAYER LAIN | " .. myUsername .. " AMAN"
notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
notif.BackgroundTransparency = 0.3
notif.TextColor3 = Color3.fromRGB(0, 255, 0)
notif.Font = Enum.Font.GothamBold
notif.TextSize = 11
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
task.wait(3)
notif:Destroy()

print("🔥 FINAL FIX LOADED!")
print("✅ Lag Mode: Spam RemoteEvent/RemoteFunction - SERANG NETWORK/LATENCY player lain")
print("✅ Booster: RINGAN + BURAM (bukan full hitam)")

-- // LOADSTRING
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Dyvillexz/Delta-Scripts/main/FPS_CTRL_Network.lua"))()
