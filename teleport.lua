local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryHub"
ScreenGui.Parent = game:GetService("CoreGui")

-- Основное окно (Gaming Dark Style)
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
MainFrame.Size = UDim2.new(0, 250, 0, 380)
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Неоновая обводка (Neon Glow Effect)
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 255, 255) -- Циановый неон
UIStroke.Parent = MainFrame

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Text = "KIRIK LUXURY HUB V2"
Title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Золото
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

--- РАЗДЕЛ 1: ESP ---
local EspTitle = Instance.new("TextLabel")
EspTitle.Text = "[ SECTION: ESP ]"
EspTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
EspTitle.Font = Enum.Font.GothamBold
EspTitle.TextSize = 12
EspTitle.Position = UDim2.new(0, 0, 0, 45)
EspTitle.Size = UDim2.new(1, 0, 0, 20)
EspTitle.BackgroundTransparency = 1
EspTitle.Parent = MainFrame

local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0.9, 0, 0, 35)
EspBtn.Position = UDim2.new(0.05, 0, 0, 70)
EspBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
EspBtn.Text = "ACTIVATE NEON ESP"
EspBtn.TextColor3 = Color3.new(1, 1, 1)
EspBtn.Font = Enum.Font.GothamBold
EspBtn.Parent = MainFrame
Instance.new("UICorner", EspBtn).CornerRadius = UDim.new(0, 6)

--- РАЗДЕЛ 2: TELEPORT ---
local TpTitle = Instance.new("TextLabel")
TpTitle.Text = "[ SECTION: TELEPORT ]"
TpTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
TpTitle.Font = Enum.Font.GothamBold
TpTitle.TextSize = 12
TpTitle.Position = UDim2.new(0, 0, 0, 115)
TpTitle.Size = UDim2.new(1, 0, 0, 20)
TpTitle.BackgroundTransparency = 1
TpTitle.Parent = MainFrame

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(0.9, 0, 0, 180)
PlayerList.Position = UDim2.new(0.05, 0, 0, 140)
PlayerList.BackgroundTransparency = 0.9
PlayerList.BackgroundColor3 = Color3.fromRGB(0,0,0)
PlayerList.CanvasSize = UDim2.new(0, 0, 5, 0)
PlayerList.ScrollBarThickness = 2
PlayerList.Parent = MainFrame
local ListLayout = Instance.new("UIListLayout", PlayerList)
ListLayout.Padding = UDim.new(0, 5)

-- Функция ESP (Highlight)
EspBtn.MouseButton1Click:Connect(function()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            local highlight = Instance.new("Highlight")
            highlight.Parent = player.Character
            highlight.FillColor = Color3.fromRGB(0, 255, 255)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
        end
    end
    EspBtn.Text = "ESP ACTIVE ✅"
    EspBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
end)

-- Функция списка игроков
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
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 12
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
RefreshBtn.Parent = MainFrame
Instance.new("UICorner", RefreshBtn)
RefreshBtn.MouseButton1Click:Connect(updateList)

updateList()
