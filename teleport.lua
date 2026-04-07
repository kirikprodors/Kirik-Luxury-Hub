-- Создаем простое окошко
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TextBox = Instance.new("TextBox")
local TPButton = Instance.new("TextButton")

ScreenGui.Parent = game:GetService("CoreGui")

-- Настройки окна
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true -- Можно перетаскивать по экрану
MainFrame.Parent = ScreenGui

-- Поле для ввода ника игрока
TextBox.Size = UDim2.new(0, 180, 0, 40)
TextBox.Position = UDim2.new(0, 10, 0, 20)
TextBox.PlaceholderText = "Ник игрока..."
TextBox.Text = ""
TextBox.Parent = MainFrame

-- Кнопка телепорта
TPButton.Size = UDim2.new(0, 180, 0, 50)
TPButton.Position = UDim2.new(0, 10, 0, 80)
TPButton.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
TPButton.Text = "ТЕЛЕПОРТ!"
TPButton.TextColor3 = Color3.new(1, 1, 1)
TPButton.Parent = MainFrame

-- Сама функция телепорта
TPButton.MouseButton1Click:Connect(function()
    local targetName = TextBox.Text
    local players = game:GetService("Players")
    local targetPlayer = nil
    
    -- Ищем игрока (можно писать даже часть ника)
    for _, v in pairs(players:GetPlayers()) do
        if string.sub(string.lower(v.Name), 1, string.len(targetName)) == string.lower(targetName) then
            targetPlayer = v
            break
        end
    end
    
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        -- Мгновенно переносим тебя к нему
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame
    end
end)
