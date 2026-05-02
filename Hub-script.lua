local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- THEME SYSTEM
local currentTheme = "NEON"

local function UpdateInstanceTheme(inst)
    if not inst:GetAttribute("NeonStroke") then return end
    local stroke = inst:FindFirstChildWhichIsA("UIStroke")
    
    if currentTheme == "NEON" then
        inst.BackgroundColor3 = inst:GetAttribute("NeonBg")
        if stroke then stroke.Color = inst:GetAttribute("NeonStroke") end
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            inst.TextColor3 = inst:GetAttribute("NeonText")
        end
    elseif currentTheme == "HACKER" then
        inst.BackgroundColor3 = Color3.fromRGB(5, 10, 5)
        if stroke then stroke.Color = Color3.fromRGB(0, 255, 0) end
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            inst.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    elseif currentTheme == "B&W" then
        inst.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        if stroke then stroke.Color = Color3.fromRGB(255, 255, 255) end
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            inst.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
end

local function ApplyStyle(inst, strokeColor, bgColor, textColor)
    inst:SetAttribute("NeonStroke", strokeColor or Color3.fromRGB(0, 255, 255))
    inst:SetAttribute("NeonBg", bgColor or Color3.fromRGB(15, 15, 20))
    inst:SetAttribute("NeonText", textColor or Color3.new(1, 1, 1))
    
    inst.BorderSizePixel = 0
    if inst:IsA("TextButton") or inst:IsA("TextBox") or inst:IsA("TextLabel") then
        inst.Font = Enum.Font.GothamBold
        inst.TextScaled = true
    end
    
    local corner = inst:FindFirstChild("UICorner") or Instance.new("UICorner", inst)
    corner.CornerRadius = UDim.new(0, 4)
    
    local stroke = inst:FindFirstChild("UIStroke") or Instance.new("UIStroke", inst)
    stroke.Thickness = inst:IsA("TextLabel") and 1 or 1.5 
    stroke.ApplyStrokeMode = inst:IsA("TextLabel") and Enum.ApplyStrokeMode.Contextual or Enum.ApplyStrokeMode.Border

    UpdateInstanceTheme(inst)
end

local function SetTheme(themeName)
    currentTheme = themeName
    for _, inst in pairs(ScreenGui:GetDescendants()) do UpdateInstanceTheme(inst) end
    UpdateInstanceTheme(ScreenGui)
end

-- MAIN FRAME & SCALERS
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.Size = UDim2.new(0, 450, 0, 300) 
MainFrame.Active = true
MainFrame.ClipsDescendants = true
ApplyStyle(MainFrame, Color3.fromRGB(255, 0, 255), Color3.fromRGB(10, 5, 15))

local MainScaler = Instance.new("UIScale", MainFrame)
MainScaler.Scale = 1

-- DRAG LOGIC (WITH UI SCALE SUPPORT)
local DragHandle = Instance.new("Frame")
DragHandle.Size = UDim2.new(1, -50, 0, 25)
DragHandle.BackgroundTransparency = 1
DragHandle.Parent = MainFrame

local dragging, dragInput, dragStart, startPos
DragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
DragHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (delta.X / MainScaler.Scale), startPos.Y.Scale, startPos.Y.Offset + (delta.Y / MainScaler.Scale))
    end
end)

local Title = Instance.new("TextLabel")
Title.Text = "KIRIK HUB V43"
Title.Size = UDim2.new(1, -60, 0, 25)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
ApplyStyle(Title, Color3.fromRGB(255, 0, 255))
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Position = UDim2.new(1, -50, 0, 3)
ApplyStyle(MinBtn, Color3.fromRGB(255, 255, 0))
MinBtn.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -25, 0, 3)
ApplyStyle(CloseBtn, Color3.fromRGB(255, 0, 0))
CloseBtn.Parent = MainFrame

-- TAB SYSTEM
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 110, 1, -35)
Sidebar.Position = UDim2.new(0, 5, 0, 30)
Sidebar.BackgroundTransparency = 1
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, -125, 1, -35)
TabContainer.Position = UDim2.new(0, 120, 0, 30)
TabContainer.BackgroundTransparency = 1

local tabs = {}
local tabBtns = {}

local function MakeTab(name, isDefault)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Text = name
    ApplyStyle(btn, Color3.fromRGB(0, 150, 255), Color3.fromRGB(15, 15, 20))
    
    local page = Instance.new("Frame", TabContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = isDefault
    
    table.insert(tabs, page)
    table.insert(tabBtns, btn)
    
    btn.MouseButton1Click:Connect(function()
        for _, t in ipairs(tabs) do t.Visible = false end
        for _, b in ipairs(tabBtns) do 
            b:SetAttribute("NeonStroke", Color3.fromRGB(0, 150, 255))
            b:SetAttribute("NeonBg", Color3.fromRGB(15, 15, 20))
            UpdateInstanceTheme(b)
        end
        page.Visible = true
        btn:SetAttribute("NeonStroke", Color3.fromRGB(255, 0, 255))
        btn:SetAttribute("NeonBg", Color3.fromRGB(30, 20, 40))
        UpdateInstanceTheme(btn)
    end)
    
    if isDefault then 
        btn:SetAttribute("NeonStroke", Color3.fromRGB(255, 0, 255))
        btn:SetAttribute("NeonBg", Color3.fromRGB(30, 20, 40))
        UpdateInstanceTheme(btn)
    end
    return page
end

local function MakeScrollArea(parent)
    local scroll = Instance.new("ScrollingFrame", parent)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 3
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 5)
    return scroll, layout
end

local function MakeRow(parent, height)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -5, 0, height or 25)
    row.BackgroundTransparency = 1
    return row
end

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Sidebar.Visible = not minimized
    TabContainer.Visible = not minimized
    MinBtn.Text = minimized and "+" or "-"
    MainFrame.Size = minimized and UDim2.new(0, 450, 0, 25) or UDim2.new(0, 450, 0, 300)
end)

-- ==================== TABS CREATION ====================

-- 1. HOME TAB
local HomeTab = MakeTab("HOME", true)
local WelcomeText = Instance.new("TextLabel", HomeTab)
WelcomeText.Size = UDim2.new(1, 0, 1, 0)
WelcomeText.Text = "KIRIK HUB V43\n\n[ FEATURE HIGHLIGHTS ]\n- Ghost Invisibility: FE Invis + Item Use\n- Custom Themes & UI Resizing\n- Players: ESP, INF TP, Dynamic Part Targets\n- NPCs: Scan & Interact with game bots\n- Character: Speed, Gravity, Noclip\n- Flight: Mobile Support, Air Walk\n- Lag: Custom Chaos Chain System"
WelcomeText.TextWrapped = true
WelcomeText.TextYAlignment = Enum.TextYAlignment.Top
ApplyStyle(WelcomeText, Color3.fromRGB(0, 255, 255), Color3.fromRGB(15, 15, 20))

-- 2. PLAYERS TAB
local PlayersTab = MakeTab("PLAYERS", false)
local PTopLayout = Instance.new("UIListLayout", PlayersTab)
PTopLayout.Padding = UDim.new(0, 5)

local EspBtn = Instance.new("TextButton", MakeRow(PlayersTab))
EspBtn.Size = UDim2.new(1, 0, 1, 0)
EspBtn.Text = "ESP: OFF"
ApplyStyle(EspBtn, Color3.fromRGB(0, 255, 100))

local ModeBtn = Instance.new("TextButton", MakeRow(PlayersTab))
ModeBtn.Size = UDim2.new(1, 0, 1, 0)
ModeBtn.Text = "LIST MODE: TP"
ApplyStyle(ModeBtn, Color3.fromRGB(255, 0, 255))

local AddTpBtn = Instance.new("TextButton", MakeRow(PlayersTab))
AddTpBtn.Size = UDim2.new(1, 0, 1, 0)
AddTpBtn.Text = "ADD CUSTOM TP PART"
ApplyStyle(AddTpBtn, Color3.fromRGB(0, 150, 255))

local PlayerListWrapper = Instance.new("Frame", PlayersTab)
PlayerListWrapper.Size = UDim2.new(1, 0, 1, -95)
PlayerListWrapper.BackgroundTransparency = 1
local PlayerList, _ = MakeScrollArea(PlayerListWrapper)

-- 3. NPCs TAB
local NpcsTab = MakeTab("NPCs", false)
local NTopLayout = Instance.new("UIListLayout", NpcsTab)
NTopLayout.Padding = UDim.new(0, 5)

local NpcModeBtn = Instance.new("TextButton", MakeRow(NpcsTab))
NpcModeBtn.Size = UDim2.new(1, 0, 1, 0)
NpcModeBtn.Text = "LIST MODE: TP"
ApplyStyle(NpcModeBtn, Color3.fromRGB(255, 0, 255))

local NpcRefreshBtn = Instance.new("TextButton", MakeRow(NpcsTab))
NpcRefreshBtn.Size = UDim2.new(1, 0, 1, 0)
NpcRefreshBtn.Text = "REFRESH NPCs"
ApplyStyle(NpcRefreshBtn, Color3.fromRGB(0, 255, 100))

local NpcListWrapper = Instance.new("Frame", NpcsTab)
NpcListWrapper.Size = UDim2.new(1, 0, 1, -65)
NpcListWrapper.BackgroundTransparency = 1
local NpcList, _ = MakeScrollArea(NpcListWrapper)

-- 4. CHARACTER TAB
local CharTab = MakeTab("CHARACTER", false)
local CharScroll, _ = MakeScrollArea(CharTab)

local InvisBtn = Instance.new("TextButton", MakeRow(CharScroll))
InvisBtn.Size = UDim2.new(1, 0, 1, 0)
InvisBtn.Text = "INVISIBILITY (GHOST): OFF"
ApplyStyle(InvisBtn, Color3.fromRGB(200, 0, 255))

local function MakeCharStat(name, defaultVal, placeholder)
    local row = MakeRow(CharScroll)
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0.65, 0, 1, 0)
    btn.Text = "SET " .. name
    ApplyStyle(btn, Color3.fromRGB(255, 255, 0))
    local box = Instance.new("TextBox", row)
    box.Size = UDim2.new(0.33, 0, 1, 0)
    box.Position = UDim2.new(0.67, 0, 0, 0)
    box.Text = tostring(defaultVal)
    box.PlaceholderText = placeholder
    ApplyStyle(box, Color3.fromRGB(255, 255, 0))
    return btn, box
end

local WsBtn, WsBox = MakeCharStat("SPEED", 16, "WS")
local JpBtn, JpBox = MakeCharStat("JUMP", 50, "JP")
local GravBtn, GravBox = MakeCharStat("GRAVITY", 196.2, "GR")
local CFrameSpeedBtn, CFrameSpeedBox = MakeCharStat("CF SPEED", 2, "Spd")
local SpinBtn, SpinBox = MakeCharStat("SPIN", 50, "Spd")

local UltraRunBtn = Instance.new("TextButton", MakeRow(CharScroll))
UltraRunBtn.Size = UDim2.new(1, 0, 1, 0)
UltraRunBtn.Text = "ULTRA RUN: OFF"
ApplyStyle(UltraRunBtn, Color3.fromRGB(255, 80, 0))

local NoclipBtn = Instance.new("TextButton", MakeRow(CharScroll))
NoclipBtn.Size = UDim2.new(1, 0, 1, 0)
NoclipBtn.Text = "NOCLIP: OFF"
ApplyStyle(NoclipBtn, Color3.fromRGB(0, 255, 200))

local UnviewBtn = Instance.new("TextButton", MakeRow(CharScroll))
UnviewBtn.Size = UDim2.new(1, 0, 1, 0)
UnviewBtn.Text = "RESET CAMERA"
ApplyStyle(UnviewBtn, Color3.fromRGB(150, 150, 255))

-- 5. FLIGHT TAB
local FlyTab = MakeTab("FLIGHT", false)
local FlyScroll, _ = MakeScrollArea(FlyTab)

local FlyRow = MakeRow(FlyScroll)
local FlyBtn = Instance.new("TextButton", FlyRow)
FlyBtn.Size = UDim2.new(0.65, 0, 1, 0)
FlyBtn.Text = "FLY: OFF"
ApplyStyle(FlyBtn, Color3.fromRGB(255, 0, 255))
local FlySpeedBox = Instance.new("TextBox", FlyRow)
FlySpeedBox.Size = UDim2.new(0.33, 0, 1, 0)
FlySpeedBox.Position = UDim2.new(0.67, 0, 0, 0)
FlySpeedBox.Text = "50"
ApplyStyle(FlySpeedBox, Color3.fromRGB(255, 0, 255))

local PlatformBtn = Instance.new("TextButton", MakeRow(FlyScroll))
PlatformBtn.Size = UDim2.new(1, 0, 1, 0)
PlatformBtn.Text = "PLATFORM: OFF"
ApplyStyle(PlatformBtn, Color3.fromRGB(0, 150, 255))

-- 6. LAG TAB
local LagTab = MakeTab("LAG", false)
local LagTopLayout = Instance.new("UIListLayout", LagTab)
LagTopLayout.Padding = UDim.new(0, 5)

local AntiFlingBtn = Instance.new("TextButton", MakeRow(LagTab))
AntiFlingBtn.Size = UDim2.new(1, 0, 1, 0)
AntiFlingBtn.Text = "STAB (QUICK ANCHOR)"
ApplyStyle(AntiFlingBtn, Color3.fromRGB(255, 50, 50))

local InfStabBtn = Instance.new("TextButton", MakeRow(LagTab))
InfStabBtn.Size = UDim2.new(1, 0, 1, 0)
InfStabBtn.Text = "CHAOS LAG: OFF"
ApplyStyle(InfStabBtn, Color3.fromRGB(255, 150, 0))

local AddLagBtn = Instance.new("TextButton", MakeRow(LagTab))
AddLagBtn.Size = UDim2.new(1, 0, 1, 0)
AddLagBtn.Text = "+ ADD NEW LAG TO CHAIN"
ApplyStyle(AddLagBtn, Color3.fromRGB(0, 255, 0))

local LagListWrapper = Instance.new("Frame", LagTab)
LagListWrapper.Size = UDim2.new(1, 0, 1, -95)
LagListWrapper.BackgroundTransparency = 1
local LagList, _ = MakeScrollArea(LagListWrapper)

-- 7. SETTINGS TAB
local SettingsTab = MakeTab("SETTINGS", false)
local SettingsScroll, _ = MakeScrollArea(SettingsTab)

local ShrinkRow = MakeRow(SettingsScroll)
local ShrinkLbl = Instance.new("TextLabel", ShrinkRow)
ShrinkLbl.Size = UDim2.new(0.65, 0, 1, 0)
ShrinkLbl.Text = "SHRINK UI (Ex: 2 = 2x smaller)"
ApplyStyle(ShrinkLbl, Color3.fromRGB(255, 255, 0))

local ShrinkBox = Instance.new("TextBox", ShrinkRow)
ShrinkBox.Size = UDim2.new(0.33, 0, 1, 0)
ShrinkBox.Position = UDim2.new(0.67, 0, 0, 0)
ShrinkBox.Text = "1"
ApplyStyle(ShrinkBox, Color3.fromRGB(255, 255, 0))

local AfkRow = MakeRow(SettingsScroll)
local AfkLbl = Instance.new("TextLabel", AfkRow)
AfkLbl.Size = UDim2.new(0.65, 0, 1, 0)
AfkLbl.Text = "AFK TIMEOUT (SEC)"
ApplyStyle(AfkLbl, Color3.fromRGB(150, 150, 150))

local AfkBox = Instance.new("TextBox", AfkRow)
AfkBox.Size = UDim2.new(0.33, 0, 1, 0)
AfkBox.Position = UDim2.new(0.67, 0, 0, 0)
AfkBox.Text = "30"
ApplyStyle(AfkBox, Color3.fromRGB(150, 150, 150))

local ThemeLbl = Instance.new("TextLabel", MakeRow(SettingsScroll))
ThemeLbl.Size = UDim2.new(1, 0, 1, 0)
ThemeLbl.Text = "--- THEMES ---"
ApplyStyle(ThemeLbl, Color3.fromRGB(0, 255, 255))

local NeonBtn = Instance.new("TextButton", MakeRow(SettingsScroll))
NeonBtn.Size = UDim2.new(1, 0, 1, 0)
NeonBtn.Text = "NEON (DEFAULT)"
ApplyStyle(NeonBtn, Color3.fromRGB(255, 0, 255))

local HackerBtn = Instance.new("TextButton", MakeRow(SettingsScroll))
HackerBtn.Size = UDim2.new(1, 0, 1, 0)
HackerBtn.Text = "HACKER (GREEN)"
ApplyStyle(HackerBtn, Color3.fromRGB(0, 255, 0))

local BWBtn = Instance.new("TextButton", MakeRow(SettingsScroll))
BWBtn.Size = UDim2.new(1, 0, 1, 0)
BWBtn.Text = "BLACK & WHITE"
ApplyStyle(BWBtn, Color3.fromRGB(255, 255, 255))

NeonBtn.MouseButton1Click:Connect(function() SetTheme("NEON") end)
HackerBtn.MouseButton1Click:Connect(function() SetTheme("HACKER") end)
BWBtn.MouseButton1Click:Connect(function() SetTheme("B&W") end)

-- ==================== FLOATING MOBILE UI ====================
local FlyUI = Instance.new("Frame", ScreenGui)
FlyUI.Size = UDim2.new(0, 60, 0, 120)
FlyUI.Position = UDim2.new(1, -70, 0.5, -60)
FlyUI.BackgroundTransparency = 1
FlyUI.Visible = false
local FlyScaler = Instance.new("UIScale", FlyUI)

local FlyUpBtn = Instance.new("TextButton", FlyUI)
FlyUpBtn.Size = UDim2.new(1, 0, 0.45, 0)
FlyUpBtn.Text = "UP"
ApplyStyle(FlyUpBtn, Color3.fromRGB(0, 255, 255))
FlyUpBtn.BackgroundTransparency = 0.5

local FlyDownBtn = Instance.new("TextButton", FlyUI)
FlyDownBtn.Size = UDim2.new(1, 0, 0.45, 0)
FlyDownBtn.Position = UDim2.new(0, 0, 0.55, 0)
FlyDownBtn.Text = "DOWN"
ApplyStyle(FlyDownBtn, Color3.fromRGB(0, 255, 255))
FlyDownBtn.BackgroundTransparency = 0.5

local PlatUI = Instance.new("Frame", ScreenGui)
PlatUI.Size = UDim2.new(0, 60, 0, 50)
PlatUI.Position = UDim2.new(1, -70, 0.5, 70)
PlatUI.BackgroundTransparency = 1
PlatUI.Visible = false
local PlatScaler = Instance.new("UIScale", PlatUI)

local PlatDownBtn = Instance.new("TextButton", PlatUI)
PlatDownBtn.Size = UDim2.new(1, 0, 1, 0)
PlatDownBtn.Text = "DOWN"
ApplyStyle(PlatDownBtn, Color3.fromRGB(0, 255, 255))
PlatDownBtn.BackgroundTransparency = 0.5

local upPressed, downPressed, platDownPressed = false, false, false
local function HookMobileBtn(btn, stateVarName)
    btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then if stateVarName == "up" then upPressed = true elseif stateVarName == "down" then downPressed = true else platDownPressed = true end end end)
    btn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then if stateVarName == "up" then upPressed = false elseif stateVarName == "down" then downPressed = false else platDownPressed = false end end end)
end
HookMobileBtn(FlyUpBtn, "up")
HookMobileBtn(FlyDownBtn, "down")
HookMobileBtn(PlatDownBtn, "plat")

ShrinkBox.FocusLost:Connect(function()
    local factor = tonumber(ShrinkBox.Text)
    if factor and factor > 0 then
        MainScaler.Scale = 1 / factor
        FlyScaler.Scale = 1 / factor
        PlatScaler.Scale = 1 / factor
    else
        ShrinkBox.Text = "1"
        MainScaler.Scale = 1
        FlyScaler.Scale = 1
        PlatScaler.Scale = 1
    end
end)

-- ==================== LOGIC & SYSTEMS ====================

local listMode = "TP"
local npcListMode = "TP"
local savedSpots = {}
local cachedNPCs = {}
local spotCount = 0

local currentInfTpTarget = nil
local infTpConn = nil

local updatePlayerList
local updateNpcList

local function stopInfTp()
    if infTpConn then infTpConn:Disconnect() infTpConn = nil end
    currentInfTpTarget = nil
end

local function startInfTp(target)
    stopInfTp()
    currentInfTpTarget = target
    infTpConn = RunService.Heartbeat:Connect(function()
        if not currentInfTpTarget then stopInfTp() return end
        
        local targetCFrame = nil
        local isValid = false
        
        if typeof(currentInfTpTarget) == "Instance" then
            if currentInfTpTarget:IsA("Player") then
                local tChar = currentInfTpTarget.Character
                if tChar and tChar.Parent then
                    local tHrp = tChar:FindFirstChild("HumanoidRootPart")
                    local tHum = tChar:FindFirstChildOfClass("Humanoid")
                    if tHrp and tHum and tHum.Health > 0 then
                        targetCFrame = tHrp.CFrame * CFrame.new(0, 0, 3)
                        isValid = true
                    end
                end
            elseif currentInfTpTarget:IsA("Model") then
                if currentInfTpTarget.Parent then
                    local tHrp = currentInfTpTarget:FindFirstChild("HumanoidRootPart")
                    local tHum = currentInfTpTarget:FindFirstChildOfClass("Humanoid")
                    if tHrp and tHum and tHum.Health > 0 then
                        targetCFrame = tHrp.CFrame * CFrame.new(0, 0, 3)
                        isValid = true
                    end
                end
            end
        elseif type(currentInfTpTarget) == "table" then
            if currentInfTpTarget.part and currentInfTpTarget.part.Parent then
                targetCFrame = currentInfTpTarget.part.CFrame * CFrame.new(0, 3, 0)
                isValid = true
            else
                targetCFrame = CFrame.new(currentInfTpTarget.pos + Vector3.new(0, 3, 0))
                isValid = true
            end
        end
        
        if isValid and targetCFrame then
            local mChar = LocalPlayer.Character
            local mHrp = mChar and mChar:FindFirstChild("HumanoidRootPart")
            if mHrp then
                mHrp.CFrame = targetCFrame
            end
        else
            stopInfTp()
            if updatePlayerList then updatePlayerList() end
            if updateNpcList then updateNpcList() end
        end
    end)
end

updatePlayerList = function()
    for _, c in pairs(PlayerList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local row = MakeRow(PlayerList)
            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(1, 0, 1, 0)
            
            if listMode == "INF TP" then
                local isActive = (currentInfTpTarget == player)
                btn.Text = player.DisplayName .. (isActive and " [ON]" or " [OFF]")
                ApplyStyle(btn, isActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
            else
                btn.Text = player.DisplayName
                ApplyStyle(btn, Color3.fromRGB(0, 200, 255))
            end
            
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
                    if currentInfTpTarget == player then stopInfTp() else startInfTp(player) end
                    updatePlayerList()
                    updateNpcList()
                end
            end)
        end
    end
    
    if listMode == "TP" or listMode == "VIEW" or listMode == "INF TP" then
        for i, spot in ipairs(savedSpots) do
            local row = MakeRow(PlayerList)
            local tpBtn = Instance.new("TextButton", row)
            tpBtn.Size = UDim2.new(0.75, 0, 1, 0)
            
            if listMode == "INF TP" then
                local isActive = (currentInfTpTarget == spot)
                tpBtn.Text = spot.name .. (isActive and " [ON]" or " [OFF]")
                ApplyStyle(tpBtn, isActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
            else
                tpBtn.Text = spot.name
                ApplyStyle(tpBtn, Color3.fromRGB(0, 255, 100))
            end
            
            local delBtn = Instance.new("TextButton", row)
            delBtn.Size = UDim2.new(0.2, 0, 1, 0)
            delBtn.Position = UDim2.new(0.8, 0, 0, 0)
            delBtn.Text = "X"
            ApplyStyle(delBtn, Color3.fromRGB(255, 0, 0))
            
            tpBtn.MouseButton1Click:Connect(function()
                if listMode == "TP" then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then 
                        if spot.part and spot.part.Parent then
                            hrp.CFrame = spot.part.CFrame * CFrame.new(0, 3, 0)
                        else
                            hrp.CFrame = CFrame.new(spot.pos + Vector3.new(0, 3, 0))
                        end
                    end
                elseif listMode == "VIEW" then
                    if spot.part and spot.part.Parent then
                        workspace.CurrentCamera.CameraSubject = spot.part
                    end
                elseif listMode == "INF TP" then
                    if currentInfTpTarget == spot then stopInfTp() else startInfTp(spot) end
                    updatePlayerList()
                end
            end)
            
            delBtn.MouseButton1Click:Connect(function()
                if currentInfTpTarget == spot then stopInfTp() end
                table.remove(savedSpots, i)
                updatePlayerList()
            end)
        end
    end
end

updateNpcList = function()
    for _, c in pairs(NpcList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    
    for _, npc in ipairs(cachedNPCs) do
        if npc and npc.Parent then
            local row = MakeRow(NpcList)
            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(1, 0, 1, 0)
            
            if npcListMode == "INF TP" then
                local isActive = (currentInfTpTarget == npc)
                btn.Text = npc.Name .. (isActive and " [ON]" or " [OFF]")
                ApplyStyle(btn, isActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
            else
                btn.Text = npc.Name
                ApplyStyle(btn, Color3.fromRGB(255, 100, 0))
            end
            
            btn.MouseButton1Click:Connect(function()
                if npcListMode == "TP" then
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    if hrp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3)
                    end
                elseif npcListMode == "VIEW" then
                    local hum = npc:FindFirstChildOfClass("Humanoid")
                    if hum then workspace.CurrentCamera.CameraSubject = hum end
                elseif npcListMode == "INF TP" then
                    if currentInfTpTarget == npc then stopInfTp() else startInfTp(npc) end
                    updateNpcList()
                    updatePlayerList()
                end
            end)
        end
    end
end

local function refreshNPCs()
    cachedNPCs = {}
    NpcRefreshBtn.Text = "SCANNING..."
    task.wait(0.1)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            if obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                if not Players:GetPlayerFromCharacter(obj) then
                    table.insert(cachedNPCs, obj)
                end
            end
        end
    end
    NpcRefreshBtn.Text = "REFRESH NPCs"
    updateNpcList()
end

ModeBtn.MouseButton1Click:Connect(function()
    if listMode == "TP" then listMode = "VIEW"
    elseif listMode == "VIEW" then listMode = "INF TP"
    else listMode = "TP" end
    ModeBtn.Text = "LIST MODE: " .. listMode
    updatePlayerList()
end)

NpcModeBtn.MouseButton1Click:Connect(function()
    if npcListMode == "TP" then npcListMode = "VIEW"
    elseif npcListMode == "VIEW" then npcListMode = "INF TP"
    else npcListMode = "TP" end
    NpcModeBtn.Text = "LIST MODE: " .. npcListMode
    updateNpcList()
end)

NpcRefreshBtn.MouseButton1Click:Connect(refreshNPCs)

local waitingForClick = false
local mouse = LocalPlayer:GetMouse()
AddTpBtn.MouseButton1Click:Connect(function()
    waitingForClick = true
    AddTpBtn.Text = "CLICK SCREEN..."
end)

mouse.Button1Down:Connect(function()
    if waitingForClick then
        waitingForClick = false
        AddTpBtn.Text = "ADD CUSTOM TP PART"
        spotCount = spotCount + 1
        
        local hitPart = mouse.Target
        local hitPos = mouse.Hit.Position
        local name = hitPart and ("[" .. hitPart.Name .. "]") or ("SPOT " .. spotCount)
        
        table.insert(savedSpots, {name = name, part = hitPart, pos = hitPos})
        updatePlayerList()
    end
end)

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- GHOST INVISIBILITY (FE INVIS + GHOST STRIKE)
local invisActive = false
local realChar = nil
local fakeChar = nil

InvisBtn.MouseButton1Click:Connect(function()
    invisActive = not invisActive
    InvisBtn.Text = "INVISIBILITY (GHOST): " .. (invisActive and "ON" or "OFF")
    ApplyStyle(InvisBtn, invisActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(200, 0, 255))
    
    if invisActive then
        realChar = LocalPlayer.Character
        if realChar then
            realChar.Archivable = true
            fakeChar = realChar:Clone()
            fakeChar.Name = LocalPlayer.Name .. "_FakeGhost"
            fakeChar.Parent = workspace
            
            local rHrp = realChar:FindFirstChild("HumanoidRootPart")
            if rHrp then
                rHrp.CFrame = rHrp.CFrame * CFrame.new(0, 500, 0)
                rHrp.Anchored = true
            end
            
            LocalPlayer.Character = fakeChar
            workspace.CurrentCamera.CameraSubject = fakeChar:FindFirstChild("Humanoid")
            
            local fHum = fakeChar:FindFirstChild("Humanoid")
            if fHum then
                fHum.Died:Connect(function()
                    if invisActive then InvisBtn.Text = "INVISIBILITY (GHOST): OFF" invisActive = false end
                    LocalPlayer.Character = realChar
                    if realChar:FindFirstChild("Humanoid") then realChar.Humanoid.Health = 0 end
                end)
            end
        else
            invisActive = false
            InvisBtn.Text = "INVISIBILITY (GHOST): OFF"
            ApplyStyle(InvisBtn, Color3.fromRGB(200, 0, 255))
        end
    else
        if fakeChar and realChar then
            local fHrp = fakeChar:FindFirstChild("HumanoidRootPart")
            local rHrp = realChar:FindFirstChild("HumanoidRootPart")
            if rHrp and fHrp then
                rHrp.Anchored = false
                rHrp.CFrame = fHrp.CFrame
            end
            LocalPlayer.Character = realChar
            workspace.CurrentCamera.CameraSubject = realChar:FindFirstChild("Humanoid")
            fakeChar:Destroy()
            fakeChar = nil
        end
    end
end)

-- GHOST STRIKE SYNC
RunService.RenderStepped:Connect(function()
    if invisActive and realChar and fakeChar then
        local fakeTool = fakeChar:FindFirstChildOfClass("Tool")
        local realHum = realChar:FindFirstChildOfClass("Humanoid")
        if fakeTool and realHum then
            local realTool = LocalPlayer.Backpack:FindFirstChild(fakeTool.Name)
            if realTool then realHum:EquipTool(realTool) end
        elseif not fakeTool and realHum then
            realHum:UnequipTools()
        end
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if invisActive and realChar and fakeChar and input.UserInputType == Enum.UserInputType.MouseButton1 and not gpe then
        local rHrp = realChar:FindFirstChild("HumanoidRootPart")
        local fHrp = fakeChar:FindFirstChild("HumanoidRootPart")
        if rHrp and fHrp then
            local skyPos = rHrp.CFrame
            rHrp.Anchored = false
            rHrp.CFrame = fHrp.CFrame
            task.delay(0.05, function()
                if invisActive and rHrp then
                    rHrp.CFrame = skyPos
                    rHrp.Anchored = true
                end
            end)
        end
    end
end)

-- LAG CHAIN LOGIC
local lagChain = {{anchor = 0.2, free = 0.1}}

local function updateLagList()
    for _, c in pairs(LagList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for i, preset in ipairs(lagChain) do
        local row = MakeRow(LagList)
        
        local anchorBox = Instance.new("TextBox", row)
        anchorBox.Size = UDim2.new(0.38, 0, 1, 0)
        anchorBox.Text = tostring(preset.anchor)
        anchorBox.PlaceholderText = "Lag"
        ApplyStyle(anchorBox, Color3.fromRGB(255, 0, 150))
        
        local freeBox = Instance.new("TextBox", row)
        freeBox.Size = UDim2.new(0.38, 0, 1, 0)
        freeBox.Position = UDim2.new(0.42, 0, 0, 0)
        freeBox.Text = tostring(preset.free)
        freeBox.PlaceholderText = "Free"
        ApplyStyle(freeBox, Color3.fromRGB(0, 255, 150))
        
        local delBtn = Instance.new("TextButton", row)
        delBtn.Size = UDim2.new(0.16, 0, 1, 0)
        delBtn.Position = UDim2.new(0.84, 0, 0, 0)
        delBtn.Text = "-"
        ApplyStyle(delBtn, Color3.fromRGB(255, 0, 0))
        
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
            updateLagList()
        end)
    end
end

AddLagBtn.MouseButton1Click:Connect(function()
    table.insert(lagChain, {anchor = 0.2, free = 0.1})
    updateLagList()
end)

local infStabActive = false
local lagState = "FREE"
local lagTimer = 0
local lagIndex = 1

InfStabBtn.MouseButton1Click:Connect(function()
    infStabActive = not infStabActive
    InfStabBtn.Text = "CHAOS LAG: " .. (infStabActive and "ON" or "OFF")
    
    if not infStabActive then
        lagState = "FREE" lagTimer = 0 lagIndex = 1
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = false hrp.Velocity = Vector3.zero end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if not infStabActive then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if not hrp or not hum or hum.Health <= 0 then lagState = "FREE" lagTimer = 0 return end

    local currentItem = (#lagChain > 0) and lagChain[lagIndex > #lagChain and 1 or lagIndex] or {anchor = 0.2, free = 0.1}
    if lagIndex > #lagChain then lagIndex = 1 end

    lagTimer = lagTimer - dt
    if lagTimer <= 0 then
        if lagState == "FREE" then
            lagState = "LAG" lagTimer = currentItem.anchor
            hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero hrp.Anchored = true
        else
            lagState = "FREE" lagTimer = currentItem.free
            hrp.Anchored = false lagIndex = lagIndex + 1
        end
    else
        if lagState == "LAG" then hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero hrp.Anchored = true else hrp.Anchored = false end
    end
end)

AntiFlingBtn.MouseButton1Click:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero hrp.Anchored = true task.wait(0.5) if hrp then hrp.Anchored = false end end
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
            if espActive then applyESP(p.Character) elseif p.Character:FindFirstChild("LuxuryESP") then p.Character.LuxuryESP:Destroy() end
        end
    end
end)
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(applyESP) end)
for _, p in pairs(Players:GetPlayers()) do p.CharacterAdded:Connect(applyESP) end

-- CHARACTER SCRIPTS
local ultraRunActive, noclipActive = false, false
UltraRunBtn.MouseButton1Click:Connect(function()
    ultraRunActive = not ultraRunActive
    UltraRunBtn.Text = "ULTRA RUN: " .. (ultraRunActive and "ON" or "OFF")
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum and not ultraRunActive then for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:AdjustSpeed(1) end end
end)

NoclipBtn.MouseButton1Click:Connect(function() noclipActive = not noclipActive NoclipBtn.Text = "NOCLIP: " .. (noclipActive and "ON" or "OFF") end)

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if noclipActive and char then
        for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end end
    end
    if ultraRunActive and char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:AdjustSpeed(hum.MoveDirection.Magnitude > 0 and 50 or 1) end
        end
    end
end)

WsBtn.MouseButton1Click:Connect(function() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if hum then hum.WalkSpeed = tonumber(WsBox.Text) or 16 end end)
JpBtn.MouseButton1Click:Connect(function() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if hum then hum.UseJumpPower = true hum.JumpPower = tonumber(JpBox.Text) or 50 end end)
local defaultGravity = workspace.Gravity
GravBtn.MouseButton1Click:Connect(function() workspace.Gravity = tonumber(GravBox.Text) or defaultGravity end)

local cfSpeedActive, spinActive = false, false
CFrameSpeedBtn.MouseButton1Click:Connect(function() cfSpeedActive = not cfSpeedActive CFrameSpeedBtn.Text = "CF SPD: " .. (cfSpeedActive and "ON" or "OFF") end)
SpinBtn.MouseButton1Click:Connect(function() spinActive = not spinActive SpinBtn.Text = "SPIN: " .. (spinActive and "ON" or "OFF") end)

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if cfSpeedActive and hrp and hum and hum.MoveDirection.Magnitude > 0 then hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (tonumber(CFrameSpeedBox.Text) or 2)) end
    if spinActive and hrp then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(tonumber(SpinBox.Text) or 50), 0) end
end)

-- FLIGHT SCRIPTS
local flying = false
local flyConn

FlyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    FlyBtn.Text = "FLY: " .. (flying and "ON" or "OFF")
    FlyUI.Visible = flying
    
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    if flying then
        local bv = Instance.new("BodyVelocity", hrp) bv.Name = "FlyBV" bv.MaxForce = Vector3.new(9e9, 9e9, 9e9) 
        local bg = Instance.new("BodyGyro", hrp) bg.Name = "FlyBG" bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9) bg.P = 9e4
        hum.PlatformStand = true
        
        flyConn = RunService.RenderStepped:Connect(function()
            bg.CFrame = workspace.CurrentCamera.CFrame
            local spd = tonumber(FlySpeedBox.Text) or 50
            local yMove = 0
            if UIS:IsKeyDown(Enum.KeyCode.Space) or upPressed then yMove = spd end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or downPressed then yMove = -spd end
            bv.Velocity = Vector3.new((hum.MoveDirection * spd).X, yMove, (hum.MoveDirection * spd).Z)
        end)
    else
        if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end
        if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end
        hum.PlatformStand = false
        if flyConn then flyConn:Disconnect() end
    end
end)

local platActive, platPart, platConn = false, nil, nil
PlatformBtn.MouseButton1Click:Connect(function()
    platActive = not platActive
    PlatformBtn.Text = "PLATFORM: " .. (platActive and "ON" or "OFF")
    PlatUI.Visible = platActive

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if platActive and hrp then
        platPart = Instance.new("Part") platPart.Size = Vector3.new(6, 1, 6) platPart.Anchored = true platPart.Transparency = 1 platPart.Parent = workspace
        local currentY = hrp.Position.Y - 3.5
        
        platConn = RunService.RenderStepped:Connect(function()
            local cHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not cHrp then return end
            if (cHrp.Position.Y - 3.5) > currentY + 0.5 then currentY = cHrp.Position.Y - 3.5 end
            if platDownPressed or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then currentY = currentY - 1 end
            platPart.CFrame = CFrame.new(cHrp.Position.X, currentY, cHrp.Position.Z)
        end)
    else
        if platPart then platPart:Destroy() end
        if platConn then platConn:Disconnect() end
    end
end)

-- AFK CLEANUP
local lastActive = tick()
local function checkUIInteraction(input)
    local pos = input.Position
    for _, frame in ipairs({MainFrame, FlyUI, PlatUI}) do
        if frame.Visible then
            local ax, ay = frame.AbsolutePosition.X, frame.AbsolutePosition.Y
            local sx, sy = frame.AbsoluteSize.X, frame.AbsoluteSize.Y
            if pos.X >= ax and pos.X <= ax + sx and pos.Y >= ay and pos.Y <= ay + sy then lastActive = tick() end
        end
    end
end
UIS.InputBegan:Connect(checkUIInteraction)
UIS.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then checkUIInteraction(input) end end)

local function ForceCleanup()
    espActive, ultraRunActive, noclipActive, infStabActive, spinActive, cfSpeedActive, flying, platActive = false, false, false, false, false, false, false, false
    FlyUI.Visible, PlatUI.Visible = false, false
    stopInfTp()
    workspace.Gravity = 196.2
    
    if invisActive then
        invisActive = false
        if fakeChar and realChar then
            local fHrp = fakeChar:FindFirstChild("HumanoidRootPart")
            local rHrp = realChar:FindFirstChild("HumanoidRootPart")
            if rHrp and fHrp then rHrp.Anchored = false rHrp.CFrame = fHrp.CFrame end
            LocalPlayer.Character = realChar
            workspace.CurrentCamera.CameraSubject = realChar:FindFirstChild("Humanoid")
            fakeChar:Destroy()
            fakeChar = nil
        end
    end
    
    for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("LuxuryESP") then p.Character.LuxuryESP:Destroy() end end
    local char = LocalPlayer.Character local hum = char and char:FindFirstChild("Humanoid") local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end hrp.Anchored = false end
    if flyConn then flyConn:Disconnect() end if platPart then platPart:Destroy() end if platConn then platConn:Disconnect() end
    if hum then hum.PlatformStand = false hum.WalkSpeed = 16 hum.UseJumpPower = true hum.JumpPower = 50 for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:AdjustSpeed(1) end workspace.CurrentCamera.CameraSubject = hum end
end

task.spawn(function()
    while task.wait(1) do
        if not ScreenGui.Parent then break end
        if tick() - lastActive > (tonumber(AfkBox.Text) or 30) then ForceCleanup() ScreenGui:Destroy() break end
    end
end)

UnviewBtn.MouseButton1Click:Connect(function() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if hum then workspace.CurrentCamera.CameraSubject = hum end end)
CloseBtn.MouseButton1Click:Connect(function() ForceCleanup() ScreenGui:Destroy() end)

updatePlayerList()
updateLagList()
