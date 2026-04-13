local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ОКНО УВЕЛИЧЕНО ПОД НОВУЮ КНОПКУ
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -47, 0.5, -90)
MainFrame.Size = UDim2.new(0, 95, 0, 293) 
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 4)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(0, 255, 255)
Stroke.Thickness = 1

-- DRAG
local DragHandle = Instance.new("Frame")
DragHandle.Size = UDim2.new(1, -30, 0, 20)
DragHandle.BackgroundTransparency = 1
DragHandle.Parent = MainFrame

local dragging, dragInput, dragStart, startPos
DragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
DragHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, 0)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "KIRIK HUB V34"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 8
Title.Size = UDim2.new(1, -33, 0, 20)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.TextSize = 12
MinBtn.Size = UDim2.new(0, 14, 0, 14)
MinBtn.Position = UDim2.new(1, -32, 0, 3)
MinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
MinBtn.TextColor3 = Color3.new(1, 1, 1)
MinBtn.Parent = MainFrame
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 3)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.TextSize = 12
CloseBtn.Size = UDim2.new(0, 14, 0, 14)
CloseBtn.Position = UDim2.new(1, -16, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 3)

-- СВОРАЧИВАНИЕ
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    MinBtn.Text = minimized and "+" or "-"
    Title.Text = minimized and "Cheat Hub" or "KIRIK HUB V34"
    MainFrame.Size = minimized and UDim2.new(0, 95, 0, 20) or UDim2.new(0, 95, 0, 293)
end)

-- ESP & MODE
local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.9, 0, 0, 12)
EspBtn.Position = UDim2.new(0.05, 0, 0, 21)
EspBtn.Text = "ESP: OFF"
EspBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
EspBtn.TextColor3 = Color3.new(1, 1, 1)
EspBtn.TextScaled = true
EspBtn.Parent = Content
Instance.new("UICorner", EspBtn)

local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(0.9, 0, 0, 12)
ModeBtn.Position = UDim2.new(0.05, 0, 0, 35)
ModeBtn.Text = "LIST MODE: TP"
ModeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 80)
ModeBtn.TextColor3 = Color3.new(1, 1, 1)
ModeBtn.TextScaled = true
ModeBtn.Parent = Content
Instance.new("UICorner", ModeBtn)

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(0.9, 0, 0, 45)
PlayerList.Position = UDim2.new(0.05, 0, 0, 48)
PlayerList.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.ScrollBarThickness = 2
PlayerList.Parent = Content
Instance.new("UIListLayout", PlayerList).Padding = UDim.new(0, 2)

-- CUSTOM TP
local AddTpBtn = Instance.new("TextButton")
AddTpBtn.Size = UDim2.new(0.9, 0, 0, 12)
AddTpBtn.Position = UDim2.new(0.05, 0, 0, 95)
AddTpBtn.Text = "ADD TP PART"
AddTpBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
AddTpBtn.TextColor3 = Color3.new(1, 1, 1)
AddTpBtn.TextScaled = true
AddTpBtn.Parent = Content
Instance.new("UICorner", AddTpBtn)

-- STAB & LAG
local AntiFlingBtn = Instance.new("TextButton")
AntiFlingBtn.Size = UDim2.new(0.43, 0, 0, 14)
AntiFlingBtn.Position = UDim2.new(0.05, 0, 0, 108)
AntiFlingBtn.Text = "STAB"
AntiFlingBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
AntiFlingBtn.TextColor3 = Color3.new(1, 1, 1)
AntiFlingBtn.TextScaled = true
AntiFlingBtn.Parent = Content
Instance.new("UICorner", AntiFlingBtn)

local InfStabBtn = Instance.new("TextButton")
InfStabBtn.Size = UDim2.new(0.43, 0, 0, 14)
InfStabBtn.Position = UDim2.new(0.52, 0, 0, 108)
InfStabBtn.Text = "CHAOS LAG"
InfStabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
InfStabBtn.TextColor3 = Color3.new(1, 1, 1)
InfStabBtn.TextScaled = true
InfStabBtn.Parent = Content
Instance.new("UICorner", InfStabBtn)

-- ULTRA RUN & NOCLIP
local UltraRunBtn = Instance.new("TextButton")
UltraRunBtn.Size = UDim2.new(0.9, 0, 0, 14)
UltraRunBtn.Position = UDim2.new(0.05, 0, 0, 123)
UltraRunBtn.Text = "ULTRA RUN: OFF"
UltraRunBtn.BackgroundColor3 = Color3.fromRGB(180, 80, 0)
UltraRunBtn.TextColor3 = Color3.new(1, 1, 1)
UltraRunBtn.TextScaled = true
UltraRunBtn.Parent = Content
Instance.new("UICorner", UltraRunBtn)

local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(0.9, 0, 0, 14)
NoclipBtn.Position = UDim2.new(0.05, 0, 0, 138)
NoclipBtn.Text = "NOCLIP: OFF"
NoclipBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 100)
NoclipBtn.TextColor3 = Color3.new(1, 1, 1)
NoclipBtn.TextScaled = true
NoclipBtn.Parent = Content
Instance.new("UICorner", NoclipBtn)

local UnviewBtn = Instance.new("TextButton")
UnviewBtn.Size = UDim2.new(0.9, 0, 0, 12)
UnviewBtn.Position = UDim2.new(0.05, 0, 0, 153)
UnviewBtn.Text = "RESET CAMERA"
UnviewBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
UnviewBtn.TextColor3 = Color3.new(1, 1, 1)
UnviewBtn.TextScaled = true
UnviewBtn.Parent = Content
Instance.new("UICorner", UnviewBtn)

-- FLY
local FlyBtn = Instance.new("TextButton")
FlyBtn.Size = UDim2.new(0.55, 0, 0, 12)
FlyBtn.Position = UDim2.new(0.05, 0, 0, 168)
FlyBtn.Text = "FLY: OFF"
FlyBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 120)
FlyBtn.TextColor3 = Color3.new(1, 1, 1)
FlyBtn.TextScaled = true
FlyBtn.Parent = Content
Instance.new("UICorner", FlyBtn)

local FlySpeedBox = Instance.new("TextBox")
FlySpeedBox.Size = UDim2.new(0.3, 0, 0, 12)
FlySpeedBox.Position = UDim2.new(0.65, 0, 0, 168)
FlySpeedBox.Text = "50"
FlySpeedBox.PlaceholderText = "Spd"
FlySpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
FlySpeedBox.TextColor3 = Color3.new(1, 1, 1)
FlySpeedBox.TextScaled = true
FlySpeedBox.Parent = Content
Instance.new("UICorner", FlySpeedBox)

-- МОБИЛЬНЫЕ КНОПКИ ДЛЯ FLY
local FlyUI = Instance.new("Frame")
FlyUI.Size = UDim2.new(0, 45, 0, 98)
FlyUI.Position = UDim2.new(1, -60, 0.5, -48)
FlyUI.BackgroundTransparency = 1
FlyUI.Visible = false
FlyUI.Parent = ScreenGui

local FlyUpBtn = Instance.new("TextButton")
FlyUpBtn.Size = UDim2.new(1, 0, 0.45, 0)
FlyUpBtn.Text = "UP"
FlyUpBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
FlyUpBtn.BackgroundTransparency = 0.5
FlyUpBtn.TextColor3 = Color3.new(1, 1, 1)
FlyUpBtn.TextScaled = true
FlyUpBtn.Font = Enum.Font.GothamBold
FlyUpBtn.Parent = FlyUI
Instance.new("UICorner", FlyUpBtn)

local FlyDownBtn = Instance.new("TextButton")
FlyDownBtn.Size = UDim2.new(1, 0, 0.45, 0)
FlyDownBtn.Position = UDim2.new(0, 0, 0.55, 0)
FlyDownBtn.Text = "DOWN"
FlyDownBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
FlyDownBtn.BackgroundTransparency = 0.5
FlyDownBtn.TextColor3 = Color3.new(1, 1, 1)
FlyDownBtn.TextScaled = true
FlyDownBtn.Font = Enum.Font.GothamBold
FlyDownBtn.Parent = FlyUI
Instance.new("UICorner", FlyDownBtn)

local upPressed, downPressed = false, false
FlyUpBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then upPressed = true end end)
FlyUpBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then upPressed = false end end)
FlyDownBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then downPressed = true end end)
FlyDownBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then downPressed = false end end)

-- SPIN BOT
local SpinBtn = Instance.new("TextButton")
SpinBtn.Size = UDim2.new(0.55, 0, 0, 12)
SpinBtn.Position = UDim2.new(0.05, 0, 0, 183)
SpinBtn.Text = "SPIN: OFF"
SpinBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
SpinBtn.TextColor3 = Color3.new(1, 1, 1)
SpinBtn.TextScaled = true
SpinBtn.Parent = Content
Instance.new("UICorner", SpinBtn)

local SpinBox = Instance.new("TextBox")
SpinBox.Size = UDim2.new(0.3, 0, 0, 12)
SpinBox.Position = UDim2.new(0.65, 0, 0, 183)
SpinBox.Text = "50"
SpinBox.PlaceholderText = "Spd"
SpinBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpinBox.TextColor3 = Color3.new(1, 1, 1)
SpinBox.TextScaled = true
SpinBox.Parent = Content
Instance.new("UICorner", SpinBox)

-- CFRAME SPEED 
local CFrameSpeedBtn = Instance.new("TextButton")
CFrameSpeedBtn.Size = UDim2.new(0.55, 0, 0, 12)
CFrameSpeedBtn.Position = UDim2.new(0.05, 0, 0, 198)
CFrameSpeedBtn.Text = "CF SPD: OFF"
CFrameSpeedBtn.BackgroundColor3 = Color3.fromRGB(150, 80, 0)
CFrameSpeedBtn.TextColor3 = Color3.new(1, 1, 1)
CFrameSpeedBtn.TextScaled = true
CFrameSpeedBtn.Parent = Content
Instance.new("UICorner", CFrameSpeedBtn)

local CFrameSpeedBox = Instance.new("TextBox")
CFrameSpeedBox.Size = UDim2.new(0.3, 0, 0, 12)
CFrameSpeedBox.Position = UDim2.new(0.65, 0, 0, 198)
CFrameSpeedBox.Text = "2"
CFrameSpeedBox.PlaceholderText = "Spd"
CFrameSpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CFrameSpeedBox.TextColor3 = Color3.new(1, 1, 1)
CFrameSpeedBox.TextScaled = true
CFrameSpeedBox.Parent = Content
Instance.new("UICorner", CFrameSpeedBox)

-- ПЛАТФОРМА (AIR WALK)
local PlatformBtn = Instance.new("TextButton")
PlatformBtn.Size = UDim2.new(0.9, 0, 0, 12)
PlatformBtn.Position = UDim2.new(0.05, 0, 0, 213)
PlatformBtn.Text = "PLATFORM: OFF"
PlatformBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 120)
PlatformBtn.TextColor3 = Color3.new(1, 1, 1)
PlatformBtn.TextScaled = true
PlatformBtn.Parent = Content
Instance.new("UICorner", PlatformBtn)

-- AFK ТАЙМЕР
local AfkBox = Instance.new("TextBox")
AfkBox.Size = UDim2.new(0.9, 0, 0, 12)
AfkBox.Position = UDim2.new(0.05, 0, 0, 228)
AfkBox.Text = "30"
AfkBox.PlaceholderText = "AFK Time"
AfkBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
AfkBox.TextColor3 = Color3.new(1, 1, 1)
AfkBox.TextScaled = true
AfkBox.Parent = Content
Instance.new("UICorner", AfkBox)

-- СКОРОСТЬ БЕГА (WALKSPEED)
local WsBtn = Instance.new("TextButton")
WsBtn.Size = UDim2.new(0.55, 0, 0, 12)
WsBtn.Position = UDim2.new(0.05, 0, 0, 243)
WsBtn.Text = "SET SPEED"
WsBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 50)
WsBtn.TextColor3 = Color3.new(1, 1, 1)
WsBtn.TextScaled = true
WsBtn.Parent = Content
Instance.new("UICorner", WsBtn)

local WsBox = Instance.new("TextBox")
WsBox.Size = UDim2.new(0.3, 0, 0, 12)
WsBox.Position = UDim2.new(0.65, 0, 0, 243)
WsBox.Text = "16"
WsBox.PlaceholderText = "WS"
WsBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
WsBox.TextColor3 = Color3.new(1, 1, 1)
WsBox.TextScaled = true
WsBox.Parent = Content
Instance.new("UICorner", WsBox)

-- СИЛА ПРЫЖКА (JUMPPOWER)
local JpBtn = Instance.new("TextButton")
JpBtn.Size = UDim2.new(0.55, 0, 0, 12)
JpBtn.Position = UDim2.new(0.05, 0, 0, 258)
JpBtn.Text = "SET JUMP"
JpBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
JpBtn.TextColor3 = Color3.new(1, 1, 1)
JpBtn.TextScaled = true
JpBtn.Parent = Content
Instance.new("UICorner", JpBtn)

local JpBox = Instance.new("TextBox")
JpBox.Size = UDim2.new(0.3, 0, 0, 12)
JpBox.Position = UDim2.new(0.65, 0, 0, 258)
JpBox.Text = "50"
JpBox.PlaceholderText = "JP"
JpBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
JpBox.TextColor3 = Color3.new(1, 1, 1)
JpBox.TextScaled = true
JpBox.Parent = Content
Instance.new("UICorner", JpBox)

-- ГРАВИТАЦИЯ (GRAVITY SWITCH)
local GravBtn = Instance.new("TextButton")
GravBtn.Size = UDim2.new(0.55, 0, 0, 12)
GravBtn.Position = UDim2.new(0.05, 0, 0, 273)
GravBtn.Text = "SET GRAV"
GravBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
GravBtn.TextColor3 = Color3.new(1, 1, 1)
GravBtn.TextScaled = true
GravBtn.Parent = Content
Instance.new("UICorner", GravBtn)

local GravBox = Instance.new("TextBox")
GravBox.Size = UDim2.new(0.3, 0, 0, 12)
GravBox.Position = UDim2.new(0.65, 0, 0, 273)
GravBox.Text = "50"
GravBox.PlaceholderText = "GR"
GravBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
GravBox.TextColor3 = Color3.new(1, 1, 1)
GravBox.TextScaled = true
GravBox.Parent = Content
Instance.new("UICorner", GravBox)

-- UI ДЛЯ ПЛАТФОРМЫ
local PlatUI = Instance.new("Frame")
PlatUI.Size = UDim2.new(0, 45, 0, 45)
PlatUI.Position = UDim2.new(1, -60, 0.5, 0)
PlatUI.BackgroundTransparency = 1
PlatUI.Visible = false
PlatUI.Parent = ScreenGui

local PlatDownBtn = Instance.new("TextButton")
PlatDownBtn.Size = UDim2.new(1, 0, 1, 0)
PlatDownBtn.Text = "DOWN"
PlatDownBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
PlatDownBtn.BackgroundTransparency = 0.5
PlatDownBtn.TextColor3 = Color3.new(1, 1, 1)
PlatDownBtn.TextScaled = true
PlatDownBtn.Font = Enum.Font.GothamBold
PlatDownBtn.Parent = PlatUI
Instance.new("UICorner", PlatDownBtn)

local platDownPressed = false
PlatDownBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then platDownPressed = true end end)
PlatDownBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then platDownPressed = false end end)

-- ЛОГИКА СПИСКОВ & TP PART
local listMode = "TP"
local savedSpots = {}
local spotCount = 0

ModeBtn.MouseButton1Click:Connect(function()
    listMode = (listMode == "TP") and "VIEW" or "TP"
    ModeBtn.Text = "LIST MODE: " .. listMode
end)

local function updateList()
    for _, child in pairs(PlayerList:GetChildren()) do if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 12)
            btn.Text = player.DisplayName
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.TextScaled = true
            btn.Parent = PlayerList
            Instance.new("UICorner", btn)
            btn.MouseButton1Click:Connect(function()
                if listMode == "TP" then
                    local pChar = player.Character
                    if pChar and pChar:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = pChar.HumanoidRootPart.CFrame
                    end
                else
                    if player.Character and player.Character:FindFirstChild("Humanoid") then
                        workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
                    end
                end
            end)
        end
    end
    
    for i, spot in ipairs(savedSpots) do
        local spotFrame = Instance.new("Frame")
        spotFrame.Size = UDim2.new(1, -5, 0, 12)
        spotFrame.BackgroundTransparency = 1
        spotFrame.Parent = PlayerList
        
        local tpBtn = Instance.new("TextButton")
        tpBtn.Size = UDim2.new(0.75, 0, 1, 0)
        tpBtn.Text = spot.name
        tpBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        tpBtn.TextColor3 = Color3.new(1, 1, 1)
        tpBtn.TextScaled = true
        tpBtn.Parent = spotFrame
        Instance.new("UICorner", tpBtn)
        
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0.2, 0, 1, 0)
        delBtn.Position = UDim2.new(0.8, 0, 0, 0)
        delBtn.Text = "X"
        delBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        delBtn.TextColor3 = Color3.new(1, 1, 1)
        delBtn.TextScaled = true
        delBtn.Parent = spotFrame
        Instance.new("UICorner", delBtn)
        
        tpBtn.MouseButton1Click:Connect(function()
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(spot.pos + Vector3.new(0, 3, 0)) end
        end)
        
        delBtn.MouseButton1Click:Connect(function()
            table.remove(savedSpots, i)
            updateList()
        end)
    end
end

-- ЛОГИКА КЛИКА ДЛЯ TP
local waitingForClick = false
local mouse = LocalPlayer:GetMouse()

AddTpBtn.MouseButton1Click:Connect(function()
    waitingForClick = true
    AddTpBtn.Text = "CLICK SCREEN..."
    AddTpBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 0)
end)

mouse.Button1Down:Connect(function()
    if waitingForClick then
        waitingForClick = false
        AddTpBtn.Text = "ADD TP PART"
        AddTpBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
        spotCount = spotCount + 1
        table.insert(savedSpots, {name = "SPOT " .. spotCount, pos = mouse.Hit.Position})
        updateList()
    end
end)

-- ESP
local espActive = false
local function applyESP(char)
    if espActive then
        task.wait(0.5)
        if not char:FindFirstChild("LuxuryESP") then
            local hl = Instance.new("Highlight", char)
            hl.Name = "LuxuryESP"
            hl.FillColor = Color3.fromRGB(0, 255, 255)
        end
    end
end

EspBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    EspBtn.Text = "ESP: " .. (espActive and "ON" or "OFF")
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if espActive then applyESP(p.Character)
            elseif p.Character:FindFirstChild("LuxuryESP") then p.Character.LuxuryESP:Destroy() end
        end
    end
end)

Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(applyESP) updateList() end)
Players.PlayerRemoving:Connect(updateList)
for _, p in pairs(Players:GetPlayers()) do p.CharacterAdded:Connect(applyESP) end

-- STAB & LAG
AntiFlingBtn.MouseButton1Click:Connect(function()
    local hrp = LocalPlayer.Character.HumanoidRootPart
    hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero
    hrp.Anchored = true task.wait(0.5) hrp.Anchored = false
end)

local infStabActive = false
InfStabBtn.MouseButton1Click:Connect(function()
    infStabActive = not infStabActive
    InfStabBtn.Text = infStabActive and "LAG: ON" or "CHAOS LAG"
    InfStabBtn.BackgroundColor3 = infStabActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(50, 50, 50)
end)

task.spawn(function()
    while true do
        if infStabActive then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero
                hrp.Anchored = true task.wait(0.2) hrp.Anchored = false
                task.wait(0.1)
            else task.wait(0.2) end
        else task.wait(0.2) end
    end
end)

-- ФУНКЦИОНАЛ FLY
local flying = false
local flyConn

FlyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    FlyBtn.Text = flying and "FLY: ON" or "FLY: OFF"
    FlyBtn.BackgroundColor3 = flying and Color3.fromRGB(180, 0, 180) or Color3.fromRGB(120, 0, 120)
    FlyUI.Visible = flying
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if not hrp or not hum then return end
    
    if flying then
        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "FlyBV"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9) 
        
        local bg = Instance.new("BodyGyro", hrp)
        bg.Name = "FlyBG"
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9) 
        bg.P = 9e4
        
        hum.PlatformStand = true
        
        flyConn = RunService.RenderStepped:Connect(function()
            local cam = workspace.CurrentCamera
            bg.CFrame = cam.CFrame
            
            local currentFlySpeed = tonumber(FlySpeedBox.Text) or 50
            local moveVector = hum.MoveDirection
            local v = moveVector * currentFlySpeed
            
            local yMove = 0
            if UIS:IsKeyDown(Enum.KeyCode.Space) or upPressed then yMove = yMove + currentFlySpeed end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or downPressed then yMove = yMove - currentFlySpeed end
            
            bv.Velocity = Vector3.new(v.X, yMove, v.Z)
        end)
    else
        if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
        if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end
        hum.PlatformStand = false
        if flyConn then flyConn:Disconnect() end
    end
end)

-- SPIN BOT ЛОГИКА
local spinActive = false
SpinBtn.MouseButton1Click:Connect(function()
    spinActive = not spinActive
    SpinBtn.Text = spinActive and "SPIN: ON" or "SPIN: OFF"
    SpinBtn.BackgroundColor3 = spinActive and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(0, 150, 80)
end)

RunService.Heartbeat:Connect(function()
    if spinActive then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local speed = tonumber(SpinBox.Text) or 50
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(speed), 0)
        end
    end
end)

-- CFRAME SPEED ЛОГИКА
local cfSpeedActive = false
CFrameSpeedBtn.MouseButton1Click:Connect(function()
    cfSpeedActive = not cfSpeedActive
    CFrameSpeedBtn.Text = cfSpeedActive and "CF SPD: ON" or "CF SPD: OFF"
    CFrameSpeedBtn.BackgroundColor3 = cfSpeedActive and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(150, 80, 0)
end)

RunService.RenderStepped:Connect(function()
    if cfSpeedActive then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if hrp and hum and hum.MoveDirection.Magnitude > 0 then
            local speed = tonumber(CFrameSpeedBox.Text) or 2
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * speed)
        end
    end
end)

-- ЛОГИКА ПЛАТФОРМЫ
local platActive = false
local platPart = nil
local platConn = nil

PlatformBtn.MouseButton1Click:Connect(function()
    platActive = not platActive
    PlatformBtn.Text = platActive and "PLATFORM: ON" or "PLATFORM: OFF"
    PlatformBtn.BackgroundColor3 = platActive and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(0, 80, 120)
    PlatUI.Visible = platActive

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if platActive and hrp then
        platPart = Instance.new("Part")
        platPart.Size = Vector3.new(6, 1, 6)
        platPart.Anchored = true
        platPart.CanCollide = true
        platPart.Transparency = 1 
        platPart.Parent = workspace

        local currentY = hrp.Position.Y - 3.5
        
        platConn = RunService.RenderStepped:Connect(function()
            local cChar = LocalPlayer.Character
            local cHrp = cChar and cChar:FindFirstChild("HumanoidRootPart")
            if not cHrp then return end
            
            if (cHrp.Position.Y - 3.5) > currentY + 0.5 then
                currentY = cHrp.Position.Y - 3.5
            end
            
            if platDownPressed or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                currentY = currentY - 1
            end
            
            platPart.CFrame = CFrame.new(cHrp.Position.X, currentY, cHrp.Position.Z)
        end)
    else
        if platPart then platPart:Destroy() end
        if platConn then platConn:Disconnect() end
    end
end)

-- ULTRA RUN & NOCLIP
local ultraRunActive = false
UltraRunBtn.MouseButton1Click:Connect(function()
    ultraRunActive = not ultraRunActive
    UltraRunBtn.Text = ultraRunActive and "ULTRA RUN: ON" or "ULTRA RUN: OFF"
    UltraRunBtn.BackgroundColor3 = ultraRunActive and Color3.fromRGB(255, 120, 0) or Color3.fromRGB(180, 80, 0)
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum and not ultraRunActive then for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:AdjustSpeed(1) end end
end)

local noclipActive = false
NoclipBtn.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    NoclipBtn.Text = noclipActive and "NOCLIP: ON" or "NOCLIP: OFF"
    NoclipBtn.BackgroundColor3 = noclipActive and Color3.fromRGB(0, 180, 180) or Color3.fromRGB(0, 100, 100)
end)

RunService.Stepped:Connect(function()
    if noclipActive then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
            end
        end
    end
    if ultraRunActive then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                if hum.MoveDirection.Magnitude > 0 then track:AdjustSpeed(50) else track:AdjustSpeed(1) end
            end
        end
    end
end)

-- ЛОГИКА СКОРОСТИ И ПРЫЖКА
WsBtn.MouseButton1Click:Connect(function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        hum.WalkSpeed = tonumber(WsBox.Text) or 16
    end
end)

JpBtn.MouseButton1Click:Connect(function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = tonumber(JpBox.Text) or 50
    end
end)

-- ЛОГИКА ГРАВИТАЦИИ
local gravActive = false
local defaultGravity = workspace.Gravity

GravBtn.MouseButton1Click:Connect(function()
    gravActive = not gravActive
    GravBtn.Text = gravActive and "GRAV: ON" or "SET GRAV"
    GravBtn.BackgroundColor3 = gravActive and Color3.fromRGB(150, 0, 200) or Color3.fromRGB(100, 0, 150)
    
    if gravActive then
        workspace.Gravity = tonumber(GravBox.Text) or 196.2
    else
        workspace.Gravity = defaultGravity
    end
end)

GravBox.FocusLost:Connect(function()
    if gravActive then
        workspace.Gravity = tonumber(GravBox.Text) or 196.2
    end
end)

-- УНИВЕРСАЛЬНАЯ ОЧИСТКА ВСЕХ ФУНКЦИЙ
local function ForceCleanup()
    espActive = false
    ultraRunActive = false
    noclipActive = false
    infStabActive = false
    spinActive = false
    cfSpeedActive = false
    flying = false
    platActive = false
    gravActive = false
    
    FlyUI.Visible = false
    PlatUI.Visible = false
    
    -- Сброс гравитации
    workspace.Gravity = 196.2
    
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("LuxuryESP") then 
            p.Character.LuxuryESP:Destroy() 
        end
    end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
        if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end
    end
    
    if flyConn then flyConn:Disconnect() end
    if platPart then platPart:Destroy() end
    if platConn then platConn:Disconnect() end
    
    if hum then 
        hum.PlatformStand = false
        hum.WalkSpeed = 16
        hum.UseJumpPower = true
        hum.JumpPower = 50
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:AdjustSpeed(1) end 
        workspace.CurrentCamera.CameraSubject = hum
    end
end

-- AFK ЗАЩИТА ТОЛЬКО ПО ВЗАИМОДЕЙСТВИЮ С ХАБОМ
local lastActive = tick()

local function checkUIInteraction(input)
    local pos = input.Position
    local framesToCheck = {MainFrame}
    if FlyUI.Visible then table.insert(framesToCheck, FlyUI) end
    if PlatUI.Visible then table.insert(framesToCheck, PlatUI) end
    
    for _, frame in ipairs(framesToCheck) do
        local ax = frame.AbsolutePosition.X
        local ay = frame.AbsolutePosition.Y
        local sx = frame.AbsoluteSize.X
        local sy = frame.AbsoluteSize.Y
        if pos.X >= ax and pos.X <= ax + sx and pos.Y >= ay and pos.Y <= ay + sy then
            lastActive = tick()
        end
    end
end

UIS.InputBegan:Connect(checkUIInteraction)
UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        checkUIInteraction(input)
    end
end)

task.spawn(function()
    while task.wait(1) do
        if not ScreenGui.Parent then break end
        local afkTime = tonumber(AfkBox.Text) or 30 
        
        if tick() - lastActive > afkTime then
            ForceCleanup()
            ScreenGui:Destroy()
            break
        end
    end
end)

UnviewBtn.MouseButton1Click:Connect(function() 
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then workspace.CurrentCamera.CameraSubject = hum end 
end)

CloseBtn.MouseButton1Click:Connect(function() 
    ForceCleanup()
    ScreenGui:Destroy() 
end)

updateList()
