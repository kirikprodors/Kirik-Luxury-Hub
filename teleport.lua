local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -70, 0.5, -125)
MainFrame.Size = UDim2.new(0, 140, 0, 250)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 255, 255)

local DragHandle = Instance.new("Frame")
DragHandle.Size = UDim2.new(1, 0, 0, 25)
DragHandle.BackgroundTransparency = 1
DragHandle.Parent = MainFrame

-- ЛОГИКА ПЕРЕМЕЩЕНИЯ (ДЛЯ ТЕЛЕФОНА)
local dragging, dragStart, startPos
DragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
    end
end)
DragHandle.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
game:GetService("UserInputService").InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, 0)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Text = "KIRIK HUB V6.1"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 10
Title.Size = UDim2.new(1, -50, 0, 25)
Title.BackgroundTransparency = 1
Title.Parent = Content

-- КНОПКИ
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -22, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn)

local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.9, 0, 0, 20)
EspBtn.Position = UDim2.new(0.05, 0, 0, 28)
EspBtn.Text = "ESP: OFF"
EspBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
EspBtn.TextColor3 = Color3.new(1, 1, 1)
EspBtn.TextSize = 9
EspBtn.Parent = Content
Instance.new("UICorner", EspBtn)

local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(0.9, 0, 0, 20)
ModeBtn.Position = UDim2.new(0.05, 0, 0, 52)
ModeBtn.Text = "LIST: TP"
ModeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 80)
ModeBtn.TextColor3 = Color3.new(1, 1, 1)
ModeBtn.TextSize = 9
ModeBtn.Parent = Content
Instance.new("UICorner", ModeBtn)

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(0.9, 0, 0, 75)
PlayerList.Position = UDim2.new(0.05, 0, 0, 75)
PlayerList.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.ScrollBarThickness = 2
PlayerList.Parent = Content
Instance.new("UIListLayout", PlayerList).Padding = UDim.new(0, 3)

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.9, 0, 0, 18)
RefreshBtn.Position = UDim2.new(0.05, 0, 0, 154)
RefreshBtn.Text = "REFRESH LIST"
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
RefreshBtn.TextColor3 = Color3.new(1, 1, 1)
RefreshBtn.TextSize = 9
RefreshBtn.Parent = Content
Instance.new("UICorner", RefreshBtn)

local AntiFlingBtn = Instance.new("TextButton")
AntiFlingBtn.Size = UDim2.new(0.42, 0, 0, 30)
AntiFlingBtn.Position = UDim2.new(0.05, 0, 0, 176)
AntiFlingBtn.Text = "STAB"
AntiFlingBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
AntiFlingBtn.TextColor3 = Color3.new(1, 1, 1)
AntiFlingBtn.TextSize = 9
AntiFlingBtn.Parent = Content
Instance.new("UICorner", AntiFlingBtn)

local FlingBtn = Instance.new("TextButton")
FlingBtn.Size = UDim2.new(0.42, 0, 0, 30)
FlingBtn.Position = UDim2.new(0.53, 0, 0, 176)
FlingBtn.Text = "FLING"
FlingBtn.BackgroundColor3 = Color3.fromRGB(200, 80, 0)
FlingBtn.TextColor3 = Color3.new(1, 1, 1)
FlingBtn.TextSize = 9
FlingBtn.Parent = Content
Instance.new("UICorner", FlingBtn)

local UnviewBtn = Instance.new("TextButton")
UnviewBtn.Size = UDim2.new(0.9, 0, 0, 20)
UnviewBtn.Position = UDim2.new(0.05, 0, 0, 210)
UnviewBtn.Text = "UNVIEW"
UnviewBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
UnviewBtn.TextColor3 = Color3.new(1, 1, 1)
UnviewBtn.TextSize = 9
UnviewBtn.Parent = Content
Instance.new("UICorner", UnviewBtn)

-- ЛОГИКА ФУНКЦИЙ
local listMode = "TP"
ModeBtn.MouseButton1Click:Connect(function()
    listMode = (listMode == "TP") and "VIEW" or "TP"
    ModeBtn.Text = "LIST: " .. listMode
end)

local function updateList()
    for _, child in pairs(PlayerList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 20)
            btn.Text = player.DisplayName
            btn.Parent = PlayerList
            Instance.new("UICorner", btn)
            btn.MouseButton1Click:Connect(function()
                if listMode == "TP" then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                else
                    workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
                end
            end)
        end
    end
end

local espActive = false
EspBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    EspBtn.Text = "ESP: " .. (espActive and "ON" or "OFF")
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            if espActive then Instance.new("Highlight", p.Character).Name = "LuxuryESP"
            elseif p.Character:FindFirstChild("LuxuryESP") then p.Character.LuxuryESP:Destroy() end
        end
    end
end)

AntiFlingBtn.MouseButton1Click:Connect(function()
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    hrp.Velocity = Vector3.new(0,0,0) hrp.RotVelocity = Vector3.new(0,0,0)
end)

-- УЛУЧШЕННЫЙ БЕЗОПАСНЫЙ ФЛИНГ
local isFlinging = false
local flingConn
FlingBtn.MouseButton1Click:Connect(function()
    isFlinging = not isFlinging
    FlingBtn.Text = isFlinging and "FLING: ON" or "FLING"
    FlingBtn.BackgroundColor3 = isFlinging and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(200, 80, 0)
    
    local char = game.Players.LocalPlayer.Character
    if isFlinging then
        flingConn = game:GetService("RunService").Heartbeat:Connect(function()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                -- Отключаем коллизии, чтобы не отлетать от пола
                for _, part in pairs(char:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                hrp.RotVelocity = Vector3.new(0, 50000, 0)
                hrp.Velocity = Vector3.new(0, 0, 0) -- Держимся на месте
            end
        end)
    else
        if flingConn then flingConn:Disconnect() end
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end)

UnviewBtn.MouseButton1Click:Connect(function()
    workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
end)

RefreshBtn.MouseButton1Click:Connect(updateList)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
updateList()
