local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- NEON THEME HELPER
local function ApplyNeon(inst, strokeColor, bgColor)
    if bgColor then inst.BackgroundColor3 = bgColor else inst.BackgroundColor3 = Color3.fromRGB(15, 15, 20) end
    if inst:IsA("TextButton") or inst:IsA("TextBox") or inst:IsA("TextLabel") then
        inst.Font = Enum.Font.GothamBlack
        inst.TextColor3 = Color3.new(1, 1, 1)
    end
    local corner = Instance.new("UICorner", inst)
    corner.CornerRadius = UDim.new(0, 4)
    local stroke = Instance.new("UIStroke", inst)
    stroke.Color = strokeColor or Color3.fromRGB(0, 255, 255)
    stroke.Thickness = 1.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
end

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -47, 0.5, -100)
MainFrame.Size = UDim2.new(0, 95, 0, 293) 
MainFrame.Active = true
MainFrame.ClipsDescendants = true
ApplyNeon(MainFrame, Color3.fromRGB(255, 0, 255), Color3.fromRGB(10, 5, 15))

-- DRAG LOGIC
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
Title.Text = "KIRIK V37"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextSize = 10
Title.Size = UDim2.new(1, -33, 0, 20)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame
Title.Font = Enum.Font.GothamBlack
local TitleStroke = Instance.new("TextStroke", Title)
TitleStroke.Color = Color3.fromRGB(255, 0, 255)
TitleStroke.Transparency = 0.5

local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.TextSize = 12
MinBtn.Size = UDim2.new(0, 14, 0, 14)
MinBtn.Position = UDim2.new(1, -32, 0, 3)
ApplyNeon(MinBtn, Color3.fromRGB(255, 255, 0))
MinBtn.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.TextSize = 12
CloseBtn.Size = UDim2.new(0, 14, 0, 14)
CloseBtn.Position = UDim2.new(1, -16, 0, 3)
ApplyNeon(CloseBtn, Color3.fromRGB(255, 0, 0))
CloseBtn.Parent = MainFrame

-- MINIMIZE LOGIC
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Content.Visible = not minimized
    MinBtn.Text = minimized and "+" or "-"
    MainFrame.Size = minimized and UDim2.new(0, 95, 0, 20) or UDim2.new(0, 95, 0, 293)
end)

-- ESP & MODE
local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.9, 0, 0, 12)
EspBtn.Position = UDim2.new(0.05, 0, 0, 21)
EspBtn.Text = "ESP: OFF"
EspBtn.TextScaled = true
ApplyNeon(EspBtn, Color3.fromRGB(0, 255, 100))
EspBtn.Parent = Content

local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(0.9, 0, 0, 12)
ModeBtn.Position = UDim2.new(0.05, 0, 0, 35)
ModeBtn.Text = "LIST: TP"
ModeBtn.TextScaled = true
ApplyNeon(ModeBtn, Color3.fromRGB(255, 0, 255))
ModeBtn.Parent = Content

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(0.9, 0, 0, 45)
PlayerList.Position = UDim2.new(0.05, 0, 0, 48)
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.ScrollBarThickness = 2
ApplyNeon(PlayerList, Color3.fromRGB(0, 255, 255), Color3.fromRGB(5, 5, 10))
PlayerList.Parent = Content
Instance.new("UIListLayout", PlayerList).Padding = UDim.new(0, 2)

-- CUSTOM TP
local AddTpBtn = Instance.new("TextButton")
AddTpBtn.Size = UDim2.new(0.9, 0, 0, 12)
AddTpBtn.Position = UDim2.new(0.05, 0, 0, 95)
AddTpBtn.Text = "ADD TP PART"
AddTpBtn.TextScaled = true
ApplyNeon(AddTpBtn, Color3.fromRGB(0, 150, 255))
AddTpBtn.Parent = Content

-- STAB & LAG CORE
local AntiFlingBtn = Instance.new("TextButton")
AntiFlingBtn.Size = UDim2.new(0.43, 0, 0, 14)
AntiFlingBtn.Position = UDim2.new(0.05, 0, 0, 108)
AntiFlingBtn.Text = "STAB"
AntiFlingBtn.TextScaled = true
ApplyNeon(AntiFlingBtn, Color3.fromRGB(255, 50, 50))
AntiFlingBtn.Parent = Content

local InfStabBtn = Instance.new("TextButton")
InfStabBtn.Size = UDim2.new(0.43, 0, 0, 14)
InfStabBtn.Position = UDim2.new(0.52, 0, 0, 108)
InfStabBtn.Text = "LAG: OFF"
InfStabBtn.TextScaled = true
ApplyNeon(InfStabBtn, Color3.fromRGB(255, 150, 0))
InfStabBtn.Parent = Content

-- ULTRA RUN & NOCLIP
local UltraRunBtn = Instance.new("TextButton")
UltraRunBtn.Size = UDim2.new(0.9, 0, 0, 14)
UltraRunBtn.Position = UDim2.new(0.05, 0, 0, 123)
UltraRunBtn.Text = "ULTRA RUN: OFF"
UltraRunBtn.TextScaled = true
ApplyNeon(UltraRunBtn, Color3.fromRGB(255, 80, 0))
UltraRunBtn.Parent = Content

local NoclipBtn = Instance.new("TextButton")
NoclipBtn.Size = UDim2.new(0.9, 0, 0, 14)
NoclipBtn.Position = UDim2.new(0.05, 0, 0, 138)
NoclipBtn.Text = "NOCLIP: OFF"
NoclipBtn.TextScaled = true
ApplyNeon(NoclipBtn, Color3.fromRGB(0, 255, 200))
NoclipBtn.Parent = Content

local UnviewBtn = Instance.new("TextButton")
UnviewBtn.Size = UDim2.new(0.9, 0, 0, 12)
UnviewBtn.Position = UDim2.new(0.05, 0, 0, 153)
UnviewBtn.Text = "RESET CAMERA"
UnviewBtn.TextScaled = true
ApplyNeon(UnviewBtn, Color3.fromRGB(150, 150, 255))
UnviewBtn.Parent = Content

-- FLY
local FlyBtn = Instance.new("TextButton")
FlyBtn.Size = UDim2.new(0.55, 0, 0, 12)
FlyBtn.Position = UDim2.new(0.05, 0, 0, 168)
FlyBtn.Text = "FLY: OFF"
FlyBtn.TextScaled = true
ApplyNeon(FlyBtn, Color3.fromRGB(255, 0, 255))
FlyBtn.Parent = Content

local FlySpeedBox = Instance.new("TextBox")
FlySpeedBox.Size = UDim2.new(0.3, 0, 0, 12)
FlySpeedBox.Position = UDim2.new(0.65, 0, 0, 168)
FlySpeedBox.Text = "50"
FlySpeedBox.PlaceholderText = "Spd"
FlySpeedBox.TextScaled = true
ApplyNeon(FlySpeedBox, Color3.fromRGB(255, 0, 255))
FlySpeedBox.Parent = Content

-- MOBILE FLY UI
local FlyUI = Instance.new("Frame")
FlyUI.Size = UDim2.new(0, 45, 0, 98)
FlyUI.Position = UDim2.new(1, -60, 0.5, -48)
FlyUI.BackgroundTransparency = 1
FlyUI.Visible = false
FlyUI.Parent = ScreenGui

local FlyUpBtn = Instance.new("TextButton")
FlyUpBtn.Size = UDim2.new(1, 0, 0.45, 0)
FlyUpBtn.Text = "UP"
FlyUpBtn.TextScaled = true
ApplyNeon(FlyUpBtn, Color3.fromRGB(0, 255, 255))
FlyUpBtn.Parent = FlyUI

local FlyDownBtn = Instance.new("TextButton")
FlyDownBtn.Size = UDim2.new(1, 0, 0.45, 0)
FlyDownBtn.Position = UDim2.new(0, 0, 0.55, 0)
FlyDownBtn.Text = "DOWN"
FlyDownBtn.TextScaled = true
ApplyNeon(FlyDownBtn, Color3.fromRGB(0, 255, 255))
FlyDownBtn.Parent = FlyUI

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
SpinBtn.TextScaled = true
ApplyNeon(SpinBtn, Color3.fromRGB(0, 255, 50))
SpinBtn.Parent = Content

local SpinBox = Instance.new("TextBox")
SpinBox.Size = UDim2.new(0.3, 0, 0, 12)
SpinBox.Position = UDim2.new(0.65, 0, 0, 183)
SpinBox.Text = "50"
SpinBox.PlaceholderText = "Spd"
SpinBox.TextScaled = true
ApplyNeon(SpinBox, Color3.fromRGB(0, 255, 50))
SpinBox.Parent = Content

-- CFRAME SPEED 
local CFrameSpeedBtn = Instance.new("TextButton")
CFrameSpeedBtn.Size = UDim2.new(0.55, 0, 0, 12)
CFrameSpeedBtn.Position = UDim2.new(0.05, 0, 0, 198)
CFrameSpeedBtn.Text = "CF SPD: OFF"
CFrameSpeedBtn.TextScaled = true
ApplyNeon(CFrameSpeedBtn, Color3.fromRGB(255, 100, 0))
CFrameSpeedBtn.Parent = Content

local CFrameSpeedBox = Instance.new("TextBox")
CFrameSpeedBox.Size = UDim2.new(0.3, 0, 0, 12)
CFrameSpeedBox.Position = UDim2.new(0.65, 0, 0, 198)
CFrameSpeedBox.Text = "2"
CFrameSpeedBox.PlaceholderText = "Spd"
CFrameSpeedBox.TextScaled = true
ApplyNeon(CFrameSpeedBox, Color3.fromRGB(255, 100, 0))
CFrameSpeedBox.Parent = Content

-- AIR WALK
local PlatformBtn = Instance.new("TextButton")
PlatformBtn.Size = UDim2.new(0.9, 0, 0, 12)
PlatformBtn.Position = UDim2.new(0.05, 0, 0, 213)
PlatformBtn.Text = "PLATFORM: OFF"
PlatformBtn.TextScaled = true
ApplyNeon(PlatformBtn, Color3.fromRGB(0, 150, 255))
PlatformBtn.Parent = Content

-- AFK 
local AfkBox = Instance.new("TextBox")
AfkBox.Size = UDim2.new(0.9, 0, 0, 12)
AfkBox.Position = UDim2.new(0.05, 0, 0, 228)
AfkBox.Text = "30"
AfkBox.PlaceholderText = "AFK Time"
AfkBox.TextScaled = true
ApplyNeon(AfkBox, Color3.fromRGB(150, 150, 150))
AfkBox.Parent = Content

-- WALK SPEED
local WsBtn = Instance.new("TextButton")
WsBtn.Size = UDim2.new(0.55, 0, 0, 12)
WsBtn.Position = UDim2.new(0.05, 0, 0, 243)
WsBtn.Text = "SET SPEED"
WsBtn.TextScaled = true
ApplyNeon(WsBtn, Color3.fromRGB(50, 255, 50))
WsBtn.Parent = Content

local WsBox = Instance.new("TextBox")
WsBox.Size = UDim2.new(0.3, 0, 0, 12)
WsBox.Position = UDim2.new(0.65, 0, 0, 243)
WsBox.Text = "16"
WsBox.PlaceholderText = "WS"
WsBox.TextScaled = true
ApplyNeon(WsBox, Color3.fromRGB(50, 255, 50))
WsBox.Parent = Content

-- JUMP POWER
local JpBtn = Instance.new("TextButton")
JpBtn.Size = UDim2.new(0.55, 0, 0, 12)
JpBtn.Position = UDim2.new(0.05, 0, 0, 258)
JpBtn.Text = "SET JUMP"
JpBtn.TextScaled = true
ApplyNeon(JpBtn, Color3.fromRGB(255, 255, 0))
JpBtn.Parent = Content

local JpBox = Instance.new("TextBox")
JpBox.Size = UDim2.new(0.3, 0, 0, 12)
JpBox.Position = UDim2.new(0.65, 0, 0, 258)
JpBox.Text = "50"
JpBox.PlaceholderText = "JP"
JpBox.TextScaled = true
ApplyNeon(JpBox, Color3.fromRGB(255, 255, 0))
JpBox.Parent = Content

-- GRAVITY
local GravBtn = Instance.new("TextButton")
GravBtn.Size = UDim2.new(0.55, 0, 0, 12)
GravBtn.Position = UDim2.new(0.05, 0, 0, 273)
GravBtn.Text = "SET GRAV"
GravBtn.TextScaled = true
ApplyNeon(GravBtn, Color3.fromRGB(150, 0, 255))
GravBtn.Parent = Content

local GravBox = Instance.new("TextBox")
GravBox.Size = UDim2.new(0.3, 0, 0, 12)
GravBox.Position = UDim2.new(0.65, 0, 0, 273)
GravBox.Text = "50"
GravBox.PlaceholderText = "GR"
GravBox.TextScaled = true
ApplyNeon(GravBox, Color3.fromRGB(150, 0, 255))
GravBox.Parent = Content

-- PLATFORM MOBILE UI
local PlatUI = Instance.new("Frame")
PlatUI.Size = UDim2.new(0, 45, 0, 45)
PlatUI.Position = UDim2.new(1, -60, 0.5, 0)
PlatUI.BackgroundTransparency = 1
PlatUI.Visible = false
PlatUI.Parent = ScreenGui

local PlatDownBtn = Instance.new("TextButton")
PlatDownBtn.Size = UDim2.new(1, 0, 1, 0)
PlatDownBtn.Text = "DOWN"
PlatDownBtn.TextScaled = true
ApplyNeon(PlatDownBtn, Color3.fromRGB(0, 255, 255))
PlatDownBtn.Parent = PlatUI

local platDownPressed = false
PlatDownBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then platDownPressed = true end end)
PlatDownBtn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then platDownPressed = false end end)

-- VARIABLES FOR LIST & INF TP
local listMode = "TP" -- TP / VIEW / LAG / INF TP
local savedSpots = {}
local spotCount = 0
local lagChain = {{anchor = 0.2, free = 0.1}}

local currentInfTpTarget = nil
local infTpConn = nil

local function stopInfTp()
    if infTpConn then infTpConn:Disconnect() infTpConn = nil end
    currentInfTpTarget = nil
end

local function startInfTp(player)
    stopInfTp()
    currentInfTpTarget = player
    infTpConn = RunService.Heartbeat:Connect(function()
        if currentInfTpTarget and currentInfTpTarget.Character then
            local tHum = currentInfTpTarget.Character:FindFirstChild("Humanoid")
            local tHrp = currentInfTpTarget.Character:FindFirstChild("HumanoidRootPart")
            local mChar = LocalPlayer.Character
            local mHrp = mChar and mChar:FindFirstChild("HumanoidRootPart")
            if tHrp and mHrp and tHum and tHum.Health > 0 then
                mHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 3)
            end
        end
    end)
end

ModeBtn.MouseButton1Click:Connect(function()
    if listMode == "TP" then listMode = "VIEW"
    elseif listMode == "VIEW" then listMode = "LAG"
    elseif listMode == "LAG" then listMode = "INF TP"
    else listMode = "TP" end
    ModeBtn.Text = "LIST: " .. listMode
    updateList()
end)

function updateList()
    for _, child in pairs(PlayerList:GetChildren()) do 
        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end 
    end
    
    if listMode == "TP" or listMode == "VIEW" or listMode == "INF TP" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, -5, 0, 12)
                
                if listMode == "INF TP" then
                    local isActive = (currentInfTpTarget == player)
                    btn.Text = player.DisplayName .. (isActive and " [ON]" or " [OFF]")
                    ApplyNeon(btn, isActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
                else
                    btn.Text = player.DisplayName
                    ApplyNeon(btn, Color3.fromRGB(0, 200, 255))
                end
                
                btn.TextScaled = true
                btn.Parent = PlayerList
                
                btn.MouseButton1Click:Connect(function()
                    if listMode == "TP" then
                        local pChar = player.Character
                        if pChar and pChar:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = pChar.HumanoidRootPart.CFrame
                        end
                    elseif listMode == "VIEW" then
                        if player.Character and player.Character:FindFirstChild("Humanoid") then
                            workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
                        end
                    elseif listMode == "INF TP" then
                        if currentInfTpTarget == player then
                            stopInfTp()
                        else
                            startInfTp(player)
                        end
                        updateList()
                    end
                end)
            end
        end
        
        if listMode == "TP" then
            for i, spot in ipairs(savedSpots) do
                local spotFrame = Instance.new("Frame")
                spotFrame.Size = UDim2.new(1, -5, 0, 12)
                spotFrame.BackgroundTransparency = 1
                spotFrame.Parent = PlayerList
                
                local tpBtn = Instance.new("TextButton")
                tpBtn.Size = UDim2.new(0.75, 0, 1, 0)
                tpBtn.Text = spot.name
                tpBtn.TextScaled = true
                ApplyNeon(tpBtn, Color3.fromRGB(0, 255, 100))
                tpBtn.Parent = spotFrame
                
                local delBtn = Instance.new("TextButton")
                delBtn.Size = UDim2.new(0.2, 0, 1, 0)
                delBtn.Position = UDim2.new(0.8, 0, 0, 0)
                delBtn.Text = "X"
                delBtn.TextScaled = true
                ApplyNeon(delBtn, Color3.fromRGB(255, 0, 0))
                delBtn.Parent = spotFrame
                
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
        
    elseif listMode == "LAG" then
        for i, preset in ipairs(lagChain) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, -5, 0, 14)
            itemFrame.BackgroundTransparency = 1
            itemFrame.Parent = PlayerList
            
            local anchorBox = Instance.new("TextBox")
            anchorBox.Size = UDim2.new(0.38, 0, 1, 0)
            anchorBox.Text = tostring(preset.anchor)
            anchorBox.PlaceholderText = "Lag"
            anchorBox.TextScaled = true
            ApplyNeon(anchorBox, Color3.fromRGB(255, 0, 150))
            anchorBox.Parent = itemFrame
            
            local freeBox = Instance.new("TextBox")
            freeBox.Size = UDim2.new(0.38, 0, 1, 0)
            freeBox.Position = UDim2.new(0.42, 0, 0, 0)
            freeBox.Text = tostring(preset.free)
            freeBox.PlaceholderText = "Free"
            freeBox.TextScaled = true
            ApplyNeon(freeBox, Color3.fromRGB(0, 255, 150))
            freeBox.Parent = itemFrame
            
            local delBtn = Instance.new("TextButton")
            delBtn.Size = UDim2.new(0.16, 0, 1, 0)
            delBtn.Position = UDim2.new(0.84, 0, 0, 0)
            delBtn.Text = "-"
            delBtn.TextScaled = true
            ApplyNeon(delBtn, Color3.fromRGB(255, 0, 0))
            delBtn.Parent = itemFrame
            
            anchorBox.FocusLost:Connect(function()
                preset.anchor = math.max(0, tonumber(anchorBox.Text) or preset.anchor)
                anchorBox.Text = tostring(preset.anchor)
            end)
            
            freeBox.FocusLost:Connect(function()
                preset.free = math.max(0, tonumber(freeBox.Text) or preset.free)
                freeBox.Text = tostring(preset.free)
            end)
            
            delBtn.MouseButton1Click:Connect(function()
                table.remove(lagChain, i)
                updateList()
            end)
        end
        
        local addFrame = Instance.new("Frame")
        addFrame.Size = UDim2.new(1, -5, 0, 14)
        addFrame.BackgroundTransparency = 1
        addFrame.Parent = PlayerList
        
        local addBtn = Instance.new("TextButton")
        addBtn.Size = UDim2.new(1, 0, 1, 0)
        addBtn.Text = "+ NEW LAG"
        addBtn.TextScaled = true
        ApplyNeon(addBtn, Color3.fromRGB(0, 255, 0))
        addBtn.Parent = addFrame
        
        addBtn.MouseButton1Click:Connect(function()
            table.insert(lagChain, {anchor = 0.2, free = 0.1})
            updateList()
        end)
    end
end

-- CLICK TP LOGIC
local waitingForClick = false
local mouse = LocalPlayer:GetMouse()

AddTpBtn.MouseButton1Click:Connect(function()
    waitingForClick = true
    AddTpBtn.Text = "CLICK SCREEN..."
end)

mouse.Button1Down:Connect(function()
    if waitingForClick then
        waitingForClick = false
        AddTpBtn.Text = "ADD TP PART"
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
            hl.OutlineColor = Color3.fromRGB(255, 0, 255)
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

-- STAB 
AntiFlingBtn.MouseButton1Click:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero
        hrp.Anchored = true task.wait(0.5) 
        if hrp then hrp.Anchored = false end
    end
end)

-- CHAOS LAG (HEARTBEAT BASED)
local infStabActive = false
local lagState = "FREE"
local lagTimer = 0
local lagIndex = 1

InfStabBtn.MouseButton1Click:Connect(function()
    infStabActive = not infStabActive
    InfStabBtn.Text = infStabActive and "LAG: ON" or "LAG: OFF"
    
    if not infStabActive then
        lagState = "FREE"
        lagTimer = 0
        lagIndex = 1
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then 
            hrp.Anchored = false 
            hrp.Velocity = Vector3.zero
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if not hrp or not hum or hum.Health <= 0 then
        lagState = "FREE"
        lagTimer = 0
        return
    end

    if not infStabActive then return end

    local currentItem
    if #lagChain > 0 then
        if lagIndex > #lagChain then lagIndex = 1 end
        currentItem = lagChain[lagIndex]
    else
        currentItem = {anchor = 0.2, free = 0.1}
    end

    lagTimer = lagTimer - dt

    if lagTimer <= 0 then
        if lagState == "FREE" then
            lagState = "LAG"
            lagTimer = currentItem.anchor
            hrp.Velocity = Vector3.zero 
            hrp.RotVelocity = Vector3.zero
            hrp.Anchored = true
        else
            lagState = "FREE"
            lagTimer = currentItem.free
            hrp.Anchored = false
            lagIndex = lagIndex + 1
        end
    else
        if lagState == "LAG" then
            hrp.Velocity = Vector3.zero 
            hrp.RotVelocity = Vector3.zero
            hrp.Anchored = true
        else
            hrp.Anchored = false
        end
    end
end)

-- FLY
local flying = false
local flyConn

FlyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    FlyBtn.Text = flying and "FLY: ON" or "FLY: OFF"
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

-- SPIN BOT
local spinActive = false
SpinBtn.MouseButton1Click:Connect(function()
    spinActive = not spinActive
    SpinBtn.Text = spinActive and "SPIN: ON" or "SPIN: OFF"
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

-- CFRAME SPEED 
local cfSpeedActive = false
CFrameSpeedBtn.MouseButton1Click:Connect(function()
    cfSpeedActive = not cfSpeedActive
    CFrameSpeedBtn.Text = cfSpeedActive and "CF SPD: ON" or "CF SPD: OFF"
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

-- PLATFORM
local platActive = false
local platPart = nil
local platConn = nil

PlatformBtn.MouseButton1Click:Connect(function()
    platActive = not platActive
    PlatformBtn.Text = platActive and "PLATFORM: ON" or "PLATFORM: OFF"
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
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum and not ultraRunActive then for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:AdjustSpeed(1) end end
end)

local noclipActive = false
NoclipBtn.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    NoclipBtn.Text = noclipActive and "NOCLIP: ON" or "NOCLIP: OFF"
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

-- SPEED AND JUMP
WsBtn.MouseButton1Click:Connect(function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = tonumber(WsBox.Text) or 16 end
end)

JpBtn.MouseButton1Click:Connect(function()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = tonumber(JpBox.Text) or 50
    end
end)

-- GRAVITY
local gravActive = false
local defaultGravity = workspace.Gravity

GravBtn.MouseButton1Click:Connect(function()
    gravActive = not gravActive
    GravBtn.Text = gravActive and "GRAV: ON" or "SET GRAV"
    if gravActive then workspace.Gravity = tonumber(GravBox.Text) or 196.2 else workspace.Gravity = defaultGravity end
end)

GravBox.FocusLost:Connect(function()
    if gravActive then workspace.Gravity = tonumber(GravBox.Text) or 196.2 end
end)

-- FULL CLEANUP
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
    
    stopInfTp()
    
    workspace.Gravity = 196.2
    
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("LuxuryESP") then p.Character.LuxuryESP:Destroy() end
    end
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
        if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end
        hrp.Anchored = false
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

-- AFK DEFENSE
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
