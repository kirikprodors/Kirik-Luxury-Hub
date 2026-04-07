local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryHub"
ScreenGui.Parent = game:GetService("CoreGui")

-- Основное окно
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.Size = UDim2.new(0, 250, 0, 380)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 255, 255)

-- Контейнер для всего содержимого (чтобы не пропадало)
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, 0)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

-- КНОПКИ УПРАВЛЕНИЯ
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

-- ЛОГИКА СКРЫТИЯ
local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Content.Visible = false
        MainFrame:TweenSize(UDim2.new(0, 110, 0, 40), "Out", "Quad", 0.3, true)
        MinimizeBtn.Position = UDim2.new(0, 40, 0, 5)
        CloseBtn.Position = UDim2.new(0, 5, 0, 5)
        MinimizeBtn.Text = "+"
    else
        MainFrame:TweenSize(UDim2.new(0, 250, 0, 380), "Out", "Quad", 0.3, true)
        task.wait(0.3)
        Content.Visible = true
        MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
        CloseBtn.Position = UDim2.new(1, -35, 0, 5)
        MinimizeBtn.Text = "-"
    end
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- КОНТЕНТ ВНУТРИ ХАБА
local Title = Instance.new("TextLabel")
Title.Text = "KIRIK LUXURY HUB V2"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Size = UDim2.new(1, -80, 0, 40)
Title.BackgroundTransparency = 1
Title.Parent = Content

local EspTitle = Instance.new("TextLabel")
EspTitle.Text = "[ SECTION: ESP ]"
EspTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
EspTitle.Font = Enum.Font.GothamBold
EspTitle.Position = UDim2.new(0, 0, 0, 45)
EspTitle.Size = UDim2.new(1, 0, 0, 20)
EspTitle.BackgroundTransparency = 1
EspTitle.Parent = Content

local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.9, 0, 0, 35)
EspBtn.Position = UDim2.new(0.05, 0, 0, 70)
EspBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
EspBtn.Text = "ACTIVATE NEON ESP"
EspBtn.TextColor3 = Color3.new(1, 1, 1)
EspBtn.Font = Enum.Font.GothamBold
EspBtn.Parent = Content
Instance.new("UICorner", EspBtn)

local TpTitle = Instance.new("TextLabel")
TpTitle.Text = "[ SECTION: TELEPORT ]"
TpTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
TpTitle.Font = Enum.Font.GothamBold
TpTitle.Position = UDim2.new(0, 0, 0, 115)
TpTitle.Size = UDim2.new(1, 0, 0, 20)
TpTitle.BackgroundTransparency = 1
TpTitle.Parent = Content

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(0.9, 0, 0, 180)
PlayerList.Position = UDim2.new(0.05, 0, 0, 140)
PlayerList.BackgroundTransparency = 0.9
PlayerList.BackgroundColor3 = Color3.fromRGB(0,0,0)
PlayerList.CanvasSize = UDim2.new(0, 0, 5, 0)
PlayerList.Parent = Content
Instance.new("UIListLayout", PlayerList).Padding = UDim.new(0, 5)

-- ИСПРАВЛЕННЫЙ ESP С ВЫКЛЮЧЕНИЕМ
local espActive = false
EspBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    if espActive then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                local hl = Instance.new("Highlight")
                hl.Name = "LuxuryESP"
                hl.FillColor = Color3.fromRGB(0, 255, 255)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Parent = player.Character
            end
        end
        EspBtn.Text = "ESP: ON ✅"
        EspBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    else
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("LuxuryESP") then
                player.Character.LuxuryESP:Destroy()
            end
        end
        EspBtn.Text = "ACTIVATE NEON ESP"
        EspBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    end
end)

local function updateList()
    for _, child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.Text = " TARGET: " .. player.DisplayName
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.Gotham
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

local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.9, 0, 0, 30)
RefreshBtn.Position = UDim2.new(0.05, 0, 0, 335)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
RefreshBtn.Text = "RELOAD PLAYERS"
RefreshBtn.TextColor3 = Color3.new(1, 1, 1)
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.Parent = Content
Instance.new("UICorner", RefreshBtn)
RefreshBtn.MouseButton1Click:Connect(updateList)
updateList()
