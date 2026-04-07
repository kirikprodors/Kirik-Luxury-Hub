local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- ОСНОВНОЕ ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -180)
MainFrame.Size = UDim2.new(0, 250, 0, 360)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 255, 255)

-- РУЧКА ДЛЯ ПЕРЕТАСКИВАНИЯ (Верхняя панель)
local DragHandle = Instance.new("Frame")
DragHandle.Size = UDim2.new(1, 0, 0, 40)
DragHandle.BackgroundTransparency = 1
DragHandle.Parent = MainFrame

local dragging, dragInput, dragStart, startPos
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

-- УПРАВЛЕНИЕ
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Text = "-"
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MinimizeBtn.TextColor3 = Color3.new(1, 1, 1)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = MainFrame
Instance.new("UICorner", MinimizeBtn)

local Title = Instance.new("TextLabel")
Title.Text = "KIRIK LUXURY HUB V4"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.Size = UDim2.new(1, -80, 0, 40)
Title.BackgroundTransparency = 1
Title.Parent = Content

-- VISUALS
local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.9, 0, 0, 35)
EspBtn.Position = UDim2.new(0.05, 0, 0, 50)
EspBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
EspBtn.Text = "NEON ESP: OFF"
EspBtn.TextColor3 = Color3.new(1, 1, 1)
EspBtn.Font = Enum.Font.GothamBold
EspBtn.Parent = Content
Instance.new("UICorner", EspBtn)

-- TELEPORT
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(0.9, 0, 0, 150)
PlayerList.Position = UDim2.new(0.05, 0, 0, 95)
PlayerList.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.Parent = Content
Instance.new("UIListLayout", PlayerList).Padding = UDim.new(0, 5)

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.9, 0, 0, 25)
RefreshBtn.Position = UDim2.new(0.05, 0, 0, 255)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
RefreshBtn.Text = "RELOAD LIST"
RefreshBtn.TextColor3 = Color3.new(1, 1, 1)
RefreshBtn.Parent = Content
Instance.new("UICorner", RefreshBtn)

-- SAFETY
local AntiFlingBtn = Instance.new("TextButton")
AntiFlingBtn.Size = UDim2.new(0.9, 0, 0, 50)
AntiFlingBtn.Position = UDim2.new(0.05, 0, 0, 295)
AntiFlingBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
AntiFlingBtn.Text = "STABILIZE (ANTI-FLING)"
AntiFlingBtn.TextColor3 = Color3.new(1, 1, 1)
AntiFlingBtn.Font = Enum.Font.GothamBold
AntiFlingBtn.Parent = Content
Instance.new("UICorner", AntiFlingBtn)

-- LOGIC
local function updateList()
    for _, child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.Text = " TO: " .. player.DisplayName
            btn.TextColor3 = Color3.new(1, 1, 1)
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
        EspBtn.Text = "ESP: ON ✅"
    else
        for _, p in pairs(game.Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("LuxuryESP") then p.Character.LuxuryESP:Destroy() end
        end
        EspBtn.Text = "NEON ESP: OFF"
    end
end)

AntiFlingBtn.MouseButton1Click:Connect(function()
    local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Velocity, hrp.RotVelocity = Vector3.new(0,0,0), Vector3.new(0,0,0)
        hrp.Anchored = true
        task.wait(0.6)
        hrp.Anchored = false
    end
end)

MinimizeBtn.MouseButton1Click:Connect(function()
    local minimized = MinimizeBtn.Text == "-"
    Content.Visible = not minimized
    MainFrame:TweenSize(minimized and UDim2.new(0, 110, 0, 40) or UDim2.new(0, 250, 0, 360), "Out", "Quad", 0.3, true)
    MinimizeBtn.Text = minimized and "+" or "-"
    MinimizeBtn.Position = minimized and UDim2.new(0, 40, 0, 5) or UDim2.new(1, -70, 0, 5)
    CloseBtn.Position = minimized and UDim2.new(0, 5, 0, 5) or UDim2.new(1, -35, 0, 5)
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
RefreshBtn.MouseButton1Click:Connect(updateList)
updateList()
