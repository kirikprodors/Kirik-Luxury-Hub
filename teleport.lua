local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- МИКРО-ОКНО
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -70, 0.5, -110)
MainFrame.Size = UDim2.new(0, 140, 0, 220)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 255, 255)

local DragHandle = Instance.new("Frame")
DragHandle.Size = UDim2.new(1, 0, 0, 25)
DragHandle.BackgroundTransparency = 1
DragHandle.Parent = MainFrame

-- ЛОГИКА ПЕРЕМЕЩЕНИЯ
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
Title.Text = "KIRIK HUB V8"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 10
Title.Size = UDim2.new(1, -30, 0, 25)
Title.BackgroundTransparency = 1
Title.Parent = Content

-- КНОПКИ УПРАВЛЕНИЯ
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -22, 0, 3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn)

-- ESP & MODE
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
ModeBtn.Text = "LIST MODE: TP"
ModeBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 80)
ModeBtn.TextColor3 = Color3.new(1, 1, 1)
ModeBtn.TextSize = 9
ModeBtn.Parent = Content
Instance.new("UICorner", ModeBtn)

-- PLAYER LIST (Увеличен)
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(0.9, 0, 0, 92)
PlayerList.Position = UDim2.new(0.05, 0, 0, 76)
PlayerList.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.ScrollBarThickness = 2
PlayerList.Parent = Content
Instance.new("UIListLayout", PlayerList).Padding = UDim.new(0, 3)

-- ГЛАВНЫЕ ФУНКЦИИ
local AntiFlingBtn = Instance.new("TextButton")
AntiFlingBtn.Size = UDim2.new(0.9, 0, 0, 25)
AntiFlingBtn.Position = UDim2.new(0.05, 0, 0, 172)
AntiFlingBtn.Text = "STABILIZE (STAB)"
AntiFlingBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
AntiFlingBtn.TextColor3 = Color3.new(1, 1, 1)
AntiFlingBtn.Font = Enum.Font.GothamBold
AntiFlingBtn.TextSize = 9
AntiFlingBtn.Parent = Content
Instance.new("UICorner", AntiFlingBtn)

local UnviewBtn = Instance.new("TextButton")
UnviewBtn.Size = UDim2.new(0.9, 0, 0, 18)
UnviewBtn.Position = UDim2.new(0.05, 0, 0, 200)
UnviewBtn.Text = "RESET CAMERA (UNVIEW)"
UnviewBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
UnviewBtn.TextColor3 = Color3.new(1, 1, 1)
UnviewBtn.TextSize = 8
UnviewBtn.Parent = Content
Instance.new("UICorner", UnviewBtn)

-- ЛОГИКА
local listMode = "TP"
ModeBtn.MouseButton1Click:Connect(function()
    listMode = (listMode == "TP") and "VIEW" or "TP"
    ModeBtn.Text = "LIST MODE: " .. listMode
end)

local function updateList()
    for _, child in pairs(PlayerList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -5, 0, 20)
            btn.Text = player.DisplayName
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.TextSize = 9
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

-- АВТО-ОБНОВЛЕНИЕ СПИСКА ИГРОКОВ
game.Players.PlayerAdded:Connect(updateList)
game.Players.PlayerRemoving:Connect(updateList)

local espActive = false
EspBtn.MouseButton1Click:Connect(function()
    espActive = not espActive
    EspBtn.Text = "ESP: " .. (espActive and "ON" or "OFF")
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            if espActive then
                local hl = Instance.new("Highlight", p.Character)
                hl.Name = "LuxuryESP"
                hl.FillColor = Color3.fromRGB(0, 255, 255)
            elseif p.Character:FindFirstChild("LuxuryESP") then
                p.Character.LuxuryESP:Destroy()
            end
        end
    end
end)

AntiFlingBtn.MouseButton1Click:Connect(function()
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    hrp.Velocity = Vector3.new(0,0,0)
    hrp.RotVelocity = Vector3.new(0,0,0)
    hrp.Anchored = true
    task.wait(0.2)
    hrp.Anchored = false
end)

UnviewBtn.MouseButton1Click:Connect(function()
    workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
end)

CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
updateList()
