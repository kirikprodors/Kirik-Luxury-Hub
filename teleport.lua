local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- МИКРО-ОКНО (Уменьшено почти в 3 раза по сравнению с прошлым)
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -60, 0.5, -100) -- Центрирование маленького окна
MainFrame.Size = UDim2.new(0, 140, 0, 240) -- Ширина всего 140 пикселей
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(0, 255, 255)

-- РУЧКА ПЕРЕТАСКИВАНИЯ
local DragHandle = Instance.new("Frame")
DragHandle.Size = UDim2.new(1, 0, 0, 25)
DragHandle.BackgroundTransparency = 1
DragHandle.Parent = MainFrame

local dragging, dragStart, startPos
DragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
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

-- МИНИ-КНОПКИ УПРАВЛЕНИЯ
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -22, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Text = "-"
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Position = UDim2.new(1, -44, 0, 3)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 10
MinimizeBtn.Parent = MainFrame
Instance.new("UICorner", MinimizeBtn)

local Title = Instance.new("TextLabel")
Title.Text = "KIRIK HUB V5"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 10
Title.Size = UDim2.new(1, -50, 0, 25)
Title.BackgroundTransparency = 1
Title.Parent = Content

-- VISUALS (ESP)
local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.9, 0, 0, 22)
EspBtn.Position = UDim2.new(0.05, 0, 0, 30)
EspBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
EspBtn.Text = "ESP: OFF"
EspBtn.TextColor3 = Color3.new(1, 1, 1)
EspBtn.Font = Enum.Font.GothamBold
EspBtn.TextSize = 9
EspBtn.Parent = Content
Instance.new("UICorner", EspBtn)

-- TELEPORT LIST (Микро-список)
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(0.9, 0, 0, 90)
PlayerList.Position = UDim2.new(0.05, 0, 0, 58)
PlayerList.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.ScrollBarThickness = 2
PlayerList.Parent = Content
local ListLayout = Instance.new("UIListLayout", PlayerList)
ListLayout.Padding = UDim.new(0, 3)

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.9, 0, 0, 18)
RefreshBtn.Position = UDim2.new(0.05, 0, 0, 152)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
RefreshBtn.Text = "REFRESH"
RefreshBtn.TextColor3 = Color3.new(1, 1, 1)
RefreshBtn.Font = Enum.Font.SourceSans
RefreshBtn.TextSize = 10
RefreshBtn.Parent = Content
Instance.new("UICorner", RefreshBtn)

-- SAFETY (STABILIZE & FREEZE)
local AntiFlingBtn = Instance.new("TextButton")
AntiFlingBtn.Size = UDim2.new(0.42, 0, 0, 30)
AntiFlingBtn.Position = UDim2.new(0.05, 0, 0, 175)
AntiFlingBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
AntiFlingBtn.Text = "STAB"
AntiFlingBtn.TextColor3 = Color3.new(1, 1, 1)
AntiFlingBtn.Font = Enum.Font.GothamBold
AntiFlingBtn.TextSize = 9
AntiFlingBtn.Parent = Content
Instance.new("UICorner", AntiFlingBtn)

local FreezeBtn = Instance.new("TextButton")
FreezeBtn.Size = UDim2.new(0.42, 0, 0, 30)
FreezeBtn.Position = UDim2.new(0.53, 0, 0, 175)
FreezeBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
FreezeBtn.Text = "FREEZE"
FreezeBtn.TextColor3 = Color3.new(1, 1, 1)
FreezeBtn.Font = Enum.Font.GothamBold
FreezeBtn.TextSize = 9
FreezeBtn.Parent = Content
Instance.new("UICorner", FreezeBtn)

local SafeLabel = Instance.new("TextLabel")
SafeLabel.Text = "--- SAFETY ---"
SafeLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
SafeLabel.Size = UDim2.new(1, 0, 0, 15)
SafeLabel.Position = UDim2.new(0, 0, 0, 210)
SafeLabel.TextSize = 8
SafeLabel.BackgroundTransparency = 1
SafeLabel.Parent = Content

-- ЛОГИКА
local function updateList()
    for _, child in pairs(PlayerList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 20)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.Text = player.DisplayName
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.TextSize = 9
            btn.Parent = PlayerList
            Instance.new("UICorner", btn)
            btn.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                end
            end)
        end
    end
end

local espActive = false
EspBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    if espActive then
        for _, p in pairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer and p.Character then
                local hl = Instance.new("Highlight", p.Character)
                hl.Name = "LuxuryESP"
                hl.FillColor = Color3.fromRGB(0, 255, 255)
            end
        end
        EspBtn.Text = "ESP: ON"
    else
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("LuxuryESP") then p.Character.LuxuryESP:Destroy() end
        end
        EspBtn.Text = "ESP: OFF"
    end
end)

AntiFlingBtn.MouseButton1Click:Connect(function()
    local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Velocity, hrp.RotVelocity = Vector3.new(0,0,0), Vector3.new(0,0,0)
        hrp.Anchored = true
        task.wait(0.5)
        hrp.Anchored = false
    end
end)

local isFrozen = false
FreezeBtn.MouseButton1Click:Connect(function()
    isFrozen = not isFrozen
    local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = isFrozen
        hrp.Velocity = Vector3.new(0,0,0)
        FreezeBtn.Text = isFrozen and "FROZEN" or "FREEZE"
    end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    local min = MinimizeBtn.Text == "-"
    Content.Visible = not min
    MainFrame:TweenSize(min and UDim2.new(0, 70, 0, 25) or UDim2.new(0, 140, 0, 240), "Out", "Quad", 0.3, true)
    MinimizeBtn.Text = min and "+" or "-"
    MinimizeBtn.Position = min and UDim2.new(0, 25, 0, 2) or UDim2.new(1, -44, 0, 3)
    CloseBtn.Position = min and UDim2.new(0, 3, 0, 2) or UDim2.new(1, -22, 0, 3)
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
RefreshBtn.MouseButton1Click:Connect(updateList)
updateList()
