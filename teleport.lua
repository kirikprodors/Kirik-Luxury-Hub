local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local TweenService = game:GetService("TweenService")

-- МИКРО-ОКНО (Luxury Style)
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -70, 0.5, -115)
MainFrame.Size = UDim2.new(0, 140, 0, 260)
MainFrame.Active = true
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(0, 255, 255)

local DragHandle = Instance.new("Frame")
DragHandle.Size = UDim2.new(1, 0, 0, 25)
DragHandle.BackgroundTransparency = 1
DragHandle.Parent = MainFrame

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
Title.Text = "KIRIK HUB V20"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 10
Title.Size = UDim2.new(1, -30, 0, 25)
Title.BackgroundTransparency = 1
Title.Parent = Content

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

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(0.9, 0, 0, 75)
PlayerList.Position = UDim2.new(0.05, 0, 0, 76)
PlayerList.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.ScrollBarThickness = 2
PlayerList.Parent = Content
Instance.new("UIListLayout", PlayerList).Padding = UDim.new(0, 3)

local AntiFlingBtn = Instance.new("TextButton")
AntiFlingBtn.Size = UDim2.new(0.43, 0, 0, 25)
AntiFlingBtn.Position = UDim2.new(0.05, 0, 0, 155)
AntiFlingBtn.Text = "STAB"
AntiFlingBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
AntiFlingBtn.TextColor3 = Color3.new(1, 1, 1)
AntiFlingBtn.TextSize = 9
AntiFlingBtn.Parent = Content
Instance.new("UICorner", AntiFlingBtn)

local InfStabBtn = Instance.new("TextButton")
InfStabBtn.Size = UDim2.new(0.43, 0, 0, 25)
InfStabBtn.Position = UDim2.new(0.52, 0, 0, 155)
InfStabBtn.Text = "CHAOS LAG"
InfStabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
InfStabBtn.TextColor3 = Color3.new(1, 1, 1)
InfStabBtn.TextSize = 8
InfStabBtn.Parent = Content
Instance.new("UICorner", InfStabBtn)

local CrushBtn = Instance.new("TextButton")
CrushBtn.Size = UDim2.new(0.9, 0, 0, 25)
CrushBtn.Position = UDim2.new(0.05, 0, 0, 185)
CrushBtn.Text = "SMOOTH CRUSH (SELECT)"
CrushBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
CrushBtn.TextColor3 = Color3.new(1, 1, 1)
CrushBtn.TextSize = 8
CrushBtn.Parent = Content
Instance.new("UICorner", CrushBtn)

local UnviewBtn = Instance.new("TextButton")
UnviewBtn.Size = UDim2.new(0.9, 0, 0, 18)
UnviewBtn.Position = UDim2.new(0.05, 0, 0, 215)
UnviewBtn.Text = "RESET CAMERA (UNVIEW)"
UnviewBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
UnviewBtn.TextColor3 = Color3.new(1, 1, 1)
UnviewBtn.TextSize = 8
UnviewBtn.Parent = Content
Instance.new("UICorner", UnviewBtn)

-- ЛОГИКА
local listMode = "TP"
local selectedPlayer = nil

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
                selectedPlayer = player
                CrushBtn.Text = "CRUSH: " .. player.DisplayName
                if listMode == "TP" then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame
                else
                    workspace.CurrentCamera.CameraSubject = player.Character.Humanoid
                end
            end)
        end
    end
end

-- ПРОСТРАНСТВЕННЫЙ ПОИСК БЛИЖАЙШИХ ОБЪЕКТОВ (V20)
CrushBtn.MouseButton1Click:Connect(function()
    if not selectedPlayer or not selectedPlayer.Character then return end
    local targetHrp = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myChar = game.Players.LocalPlayer.Character
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    
    if targetHrp and myHrp then
        local originalCFrame = myHrp.CFrame
        local foundObjects = {}
        local maxDistance = 100 -- Максимальный радиус поиска в стадах
        
        -- Сбор всех потенциальных объектов
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Anchored and v.Size.Magnitude > 2 and v.Size.Magnitude < 30 then
                local name = v.Name:lower()
                -- Базовый фильтр декора
                if not name:find("ufo") and not name:find("saucer") and not name:find("wall") and not name:find("floor") and not name:find("base") and not name:find("house") then
                    if not v:IsDescendantOf(myChar) and v:GetRootPart() == v then
                        local dist = (v.Position - myHrp.Position).Magnitude
                        -- Запись объекта, если он находится в пределах радиуса
                        if dist <= maxDistance then
                            table.insert(foundObjects, {part = v, distance = dist})
                        end
                    end
                end
            end
        end
        
        -- Сортировка объектов по дистанции (ближайшие первыми)
        table.sort(foundObjects, function(a, b)
            return a.distance < b.distance
        end)
        
        -- Выбор до 5 ближайших объектов
        local objectsToDrop = {}
        for i = 1, math.min(5, #foundObjects) do
            table.insert(objectsToDrop, foundObjects[i].part)
        end
        
        -- Выполнение атаки
        for _, obj in pairs(objectsToDrop) do
            -- 1. ТП К ПРЕДМЕТУ
            myHrp.CFrame = obj.CFrame * CFrame.new(0, 2, 0)
            task.wait(0.12)
            
            -- 2. КИДАЕМ ПРЕДМЕТ
            if targetHrp.Parent then
                obj.CFrame = targetHrp.CFrame * CFrame.new(0, 30, 0)
                obj.AssemblyLinearVelocity = Vector3.new(0, -600, 0)
            end
            
            -- 3. ПЛАВНЫЙ ВОЗВРАТ
            local tween = TweenService:Create(myHrp, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = originalCFrame})
            tween:Play()
            tween.Completed:Wait() 
            task.wait(0.1)
        end
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
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= game.Players.LocalPlayer and p.Character then
            if espActive then applyESP(p.Character)
            elseif p.Character:FindFirstChild("LuxuryESP") then p.Character.LuxuryESP:Destroy() end
        end
    end
end)

game.Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(applyESP) updateList() end)
game.Players.PlayerRemoving:Connect(updateList)
for _, p in pairs(game.Players:GetPlayers()) do p.CharacterAdded:Connect(applyESP) end

-- STAB & LAG
AntiFlingBtn.MouseButton1Click:Connect(function()
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
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
            local char = game.Players.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero
                hrp.Anchored = true task.wait(0.3) hrp.Anchored = false
                task.wait(0.2)
            else task.wait(0.2) end
        else task.wait(0.2) end
    end
end)

UnviewBtn.MouseButton1Click:Connect(function() workspace.CurrentCamera.CameraSubject = game.Players.LocalPlayer.Character.Humanoid end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
updateList()
