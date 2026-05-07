--[=[
    KIRIK LUXURY HUB V49 (ANIMATED & OPTIMIZED EDITION)
    DEVELOPER: Professional AI Lua Engineer
    FRAMEWORK: Roblox UI, TweenService, Base64 System
]=]

local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- CLEANUP SYSTEM
local _connections = {}
local function AddConn(conn)
    table.insert(_connections, conn)
    return conn
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryHub"
ScreenGui.Parent = (RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui)
ScreenGui.ResetOnSpawn = false

-- GLOBAL STATES
local currentTheme = "NEON"
local activeTabIndex = 1
local espActive, ultraRunActive, noclipActive = false, false, false
local invisActive, undieActive, platActive, unvoidActive = false, false, false, false
local flying, infStabActive, cfSpeedActive, spinActive = false, false, false, false
local fpsActive, pingActive = false, false

local cachedNPCs, savedSpots = {}, {}
local listMode, npcListMode = "TP", "TP"
local spotCount = 0
local currentInfTpTarget = nil
local infTpConn, flyConn, platConn = nil, nil, nil

-- ANIMATION HELPER
local function Tween(obj, props, duration)
    duration = duration or 0.3
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()
    return tween
end

-- THEME SYSTEM
local function UpdateInstanceTheme(inst, animated)
    if not inst:GetAttribute("NeonStroke") then return end
    local stroke = inst:FindFirstChildWhichIsA("UIStroke")
    
    local targetBg, targetText, targetStroke
    if currentTheme == "NEON" then
        targetBg = inst:GetAttribute("NeonBg")
        targetStroke = inst:GetAttribute("NeonStroke")
        targetText = inst:GetAttribute("NeonText")
    elseif currentTheme == "HACKER" then
        targetBg = Color3.fromRGB(5, 10, 5)
        targetStroke = Color3.fromRGB(0, 255, 0)
        targetText = Color3.fromRGB(0, 255, 0)
    elseif currentTheme == "B&W" then
        targetBg = Color3.fromRGB(15, 15, 15)
        targetStroke = Color3.fromRGB(255, 255, 255)
        targetText = Color3.fromRGB(255, 255, 255)
    end
    
    if animated then
        Tween(inst, {BackgroundColor3 = targetBg}, 0.3)
        if stroke then Tween(stroke, {Color = targetStroke}, 0.3) end
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            Tween(inst, {TextColor3 = targetText}, 0.3)
        end
    else
        inst.BackgroundColor3 = targetBg
        if stroke then stroke.Color = targetStroke end
        if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
            inst.TextColor3 = targetText
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
        inst.Text = "" -- Prevents default "TextBox" label bugs
    end
    
    local corner = Instance.new("UICorner", inst)
    corner.CornerRadius = UDim.new(0, 4)
    
    local stroke = Instance.new("UIStroke", inst)
    stroke.Thickness = inst:IsA("TextLabel") and 1 or 1.5 
    stroke.ApplyStrokeMode = inst:IsA("TextLabel") and Enum.ApplyStrokeMode.Contextual or Enum.ApplyStrokeMode.Border

    if inst:IsA("TextButton") then
        inst.MouseEnter:Connect(function() Tween(inst, {BackgroundTransparency = 0.2}, 0.2) end)
        inst.MouseLeave:Connect(function() Tween(inst, {BackgroundTransparency = 0}, 0.2) end)
    end

    UpdateInstanceTheme(inst, false)
end

local function SetTheme(themeName)
    currentTheme = themeName
    for _, inst in pairs(ScreenGui:GetDescendants()) do 
        if inst:GetAttribute("NeonStroke") then UpdateInstanceTheme(inst, true) end
    end
end

local function ApplyToggleStyle(btn, state, defColor)
    btn:SetAttribute("NeonStroke", state and Color3.fromRGB(0, 255, 0) or defColor)
    UpdateInstanceTheme(btn, true)
end

-- BASE64 ENCODER/DECODER
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
local function B64Encode(data)
    return ((data:gsub('.', function(x)
        local r, b = '', x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2^i - b % 2^(i-1) > 0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i,i) == '1' and 2^(6-i) or 0) end
        return b64chars:sub(c+1, c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
local function B64Decode(data)
    data = string.gsub(data, '[^'..b64chars..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (b64chars:find(x)-1)
        for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i,i) == '1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- MAIN UI CREATION
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.Size = UDim2.new(0, 450, 0, 300) 
MainFrame.Active = true
MainFrame.ClipsDescendants = true
ApplyStyle(MainFrame, Color3.fromRGB(255, 0, 255), Color3.fromRGB(10, 5, 15))

local MainScaler = Instance.new("UIScale", MainFrame)
MainScaler.Scale = 1

local DragHandle = Instance.new("Frame", MainFrame)
DragHandle.Size = UDim2.new(1, -50, 0, 25)
DragHandle.BackgroundTransparency = 1

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

local Title = Instance.new("TextLabel", MainFrame)
Title.Text = "KIRIK HUB V49"
Title.Size = UDim2.new(1, -60, 0, 25)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextTruncate = Enum.TextTruncate.AtEnd
ApplyStyle(Title, Color3.fromRGB(255, 0, 255))
Title.BackgroundTransparency = 1

local MinBtn = Instance.new("TextButton", MainFrame)
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Position = UDim2.new(1, -30, 0, 2)
MinBtn.AnchorPoint = Vector2.new(1, 0)
ApplyStyle(MinBtn, Color3.fromRGB(255, 255, 0))

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -5, 0, 2)
CloseBtn.AnchorPoint = Vector2.new(1, 0)
ApplyStyle(CloseBtn, Color3.fromRGB(255, 0, 0))

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 110, 1, -35)
Sidebar.Position = UDim2.new(0, 5, 0, 30)
Sidebar.BackgroundTransparency = 1
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SearchBox = Instance.new("TextBox", Sidebar)
SearchBox.Name = "SearchBox"
SearchBox.Size = UDim2.new(1, 0, 0, 25)
SearchBox.PlaceholderText = "SEARCH..."
SearchBox.LayoutOrder = -1 
SearchBox.ClearTextOnFocus = false
ApplyStyle(SearchBox, Color3.fromRGB(255, 255, 255), Color3.fromRGB(20, 20, 30))

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, -125, 1, -35)
TabContainer.Position = UDim2.new(0, 120, 0, 30)
TabContainer.BackgroundTransparency = 1

local tabs, tabBtns = {}, {}
local function MakeTab(name, isDefault)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Text = name
    btn.LayoutOrder = #tabBtns + 1
    ApplyStyle(btn, Color3.fromRGB(0, 150, 255), Color3.fromRGB(15, 15, 20))
    
    local page = Instance.new("Frame", TabContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = isDefault
    
    local tabIdx = #tabBtns + 1
    table.insert(tabs, page)
    table.insert(tabBtns, btn)
    
    btn.MouseButton1Click:Connect(function()
        activeTabIndex = tabIdx
        for _, t in ipairs(tabs) do t.Visible = false end
        for _, b in ipairs(tabBtns) do 
            b:SetAttribute("NeonStroke", Color3.fromRGB(0, 150, 255))
            b:SetAttribute("NeonBg", Color3.fromRGB(15, 15, 20))
            UpdateInstanceTheme(b, true)
        end
        page.Visible = true
        btn:SetAttribute("NeonStroke", Color3.fromRGB(255, 0, 255))
        btn:SetAttribute("NeonBg", Color3.fromRGB(30, 20, 40))
        UpdateInstanceTheme(btn, true)
    end)
    
    if isDefault then 
        btn:SetAttribute("NeonStroke", Color3.fromRGB(255, 0, 255))
        btn:SetAttribute("NeonBg", Color3.fromRGB(30, 20, 40))
        UpdateInstanceTheme(btn, false)
        activeTabIndex = tabIdx
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
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    return scroll, layout
end

local function MakeRow(parent, height)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -5, 0, height or 25)
    row.BackgroundTransparency = 1
    return row
end

-- ANIMATED MINIMIZE
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    MinBtn.Text = minimized and "+" or "-"
    if minimized then
        Tween(MainFrame, {Size = UDim2.new(0, 150, 0, 25)}, 0.35)
    else
        Tween(MainFrame, {Size = UDim2.new(0, 450, 0, 300)}, 0.35)
    end
end)

-- STATS HUD
local StatsFrame = Instance.new("Frame", ScreenGui)
StatsFrame.Position = UDim2.new(1, -120, 0, 10)
StatsFrame.Size = UDim2.new(0, 110, 0, 50)
StatsFrame.Visible = false
ApplyStyle(StatsFrame, Color3.fromRGB(0, 255, 255), Color3.fromRGB(10, 5, 15))

local StatsLayout = Instance.new("UIListLayout", StatsFrame)
StatsLayout.Padding = UDim.new(0, 4)
StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
StatsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local PingLbl = Instance.new("TextLabel", StatsFrame)
PingLbl.Size = UDim2.new(1, -10, 0.45, 0)
PingLbl.Text = "PING: 0 ms"
PingLbl.BackgroundTransparency = 1
PingLbl.Visible = false
ApplyStyle(PingLbl, Color3.fromRGB(255, 150, 0))

local FpsLbl = Instance.new("TextLabel", StatsFrame)
FpsLbl.Size = UDim2.new(1, -10, 0.45, 0)
FpsLbl.Text = "FPS: 0"
FpsLbl.BackgroundTransparency = 1
FpsLbl.Visible = false
ApplyStyle(FpsLbl, Color3.fromRGB(0, 255, 100))

-- ==================== TABS SETUP ====================

local HomeTab = MakeTab("HOME", true)
local WelcomeText = Instance.new("TextLabel", HomeTab)
WelcomeText.Size = UDim2.new(1, 0, 1, 0)
WelcomeText.Text = "KIRIK HUB V49\n\n[ FULLY ANIMATED ]\n- Auto-Save UI Orders & Active Tab\n- Memory Leak Free Cleanup\n- Drag & Drop Smart Minimize\n- Unvoid / Undie System Enabled\n- ESP & Live Search Included"
WelcomeText.TextWrapped = true
WelcomeText.TextYAlignment = Enum.TextYAlignment.Top
ApplyStyle(WelcomeText, Color3.fromRGB(0, 255, 255), Color3.fromRGB(15, 15, 20))

local PlayersTab = MakeTab("PLAYERS", false)
local PTopLayout = Instance.new("UIListLayout", PlayersTab) PTopLayout.Padding = UDim.new(0, 5)
local EspBtn = Instance.new("TextButton", MakeRow(PlayersTab)) EspBtn.Size = UDim2.new(1, 0, 1, 0) EspBtn.Text = "ESP: OFF" ApplyStyle(EspBtn, Color3.fromRGB(0, 255, 100))
local ModeBtn = Instance.new("TextButton", MakeRow(PlayersTab)) ModeBtn.Size = UDim2.new(1, 0, 1, 0) ModeBtn.Text = "LIST MODE: TP" ApplyStyle(ModeBtn, Color3.fromRGB(255, 0, 255))
local AddTpBtn = Instance.new("TextButton", MakeRow(PlayersTab)) AddTpBtn.Size = UDim2.new(1, 0, 1, 0) AddTpBtn.Text = "ADD CUSTOM TP PART" ApplyStyle(AddTpBtn, Color3.fromRGB(0, 150, 255))
local PlayerListWrapper = Instance.new("Frame", PlayersTab) PlayerListWrapper.Size = UDim2.new(1, 0, 1, -95) PlayerListWrapper.BackgroundTransparency = 1
local PlayerList, _ = MakeScrollArea(PlayerListWrapper)

local NpcsTab = MakeTab("NPCs", false)
local NTopLayout = Instance.new("UIListLayout", NpcsTab) NTopLayout.Padding = UDim.new(0, 5)
local NpcModeBtn = Instance.new("TextButton", MakeRow(NpcsTab)) NpcModeBtn.Size = UDim2.new(1, 0, 1, 0) NpcModeBtn.Text = "LIST MODE: TP" ApplyStyle(NpcModeBtn, Color3.fromRGB(255, 0, 255))
local NpcRefreshBtn = Instance.new("TextButton", MakeRow(NpcsTab)) NpcRefreshBtn.Size = UDim2.new(1, 0, 1, 0) NpcRefreshBtn.Text = "REFRESH NPCs" ApplyStyle(NpcRefreshBtn, Color3.fromRGB(0, 255, 100))
local NpcListWrapper = Instance.new("Frame", NpcsTab) NpcListWrapper.Size = UDim2.new(1, 0, 1, -65) NpcListWrapper.BackgroundTransparency = 1
local NpcList, _ = MakeScrollArea(NpcListWrapper)

local CharTab = MakeTab("CHARACTER", false)
local CharScroll, _ = MakeScrollArea(CharTab)
local InvisBtn = Instance.new("TextButton", MakeRow(CharScroll)) InvisBtn.Size = UDim2.new(1, 0, 1, 0) InvisBtn.Text = "INVISIBILITY (GHOST): OFF" ApplyStyle(InvisBtn, Color3.fromRGB(200, 0, 255))
local UndieBtn = Instance.new("TextButton", MakeRow(CharScroll)) UndieBtn.Size = UDim2.new(1, 0, 1, 0) UndieBtn.Text = "UN-DIE: OFF" ApplyStyle(UndieBtn, Color3.fromRGB(200, 50, 50))

local function MakeCharStat(name, defaultVal, placeholder)
    local row = MakeRow(CharScroll)
    local btn = Instance.new("TextButton", row) btn.Size = UDim2.new(0.65, 0, 1, 0) btn.Text = "SET " .. name ApplyStyle(btn, Color3.fromRGB(255, 255, 0))
    local box = Instance.new("TextBox", row) box.Size = UDim2.new(0.33, 0, 1, 0) box.Position = UDim2.new(0.67, 0, 0, 0) box.PlaceholderText = placeholder box.Text = tostring(defaultVal) ApplyStyle(box, Color3.fromRGB(255, 255, 0))
    return btn, box
end
local WsBtn, WsBox = MakeCharStat("SPEED", 16, "WS")
local JpBtn, JpBox = MakeCharStat("JUMP", 50, "JP")
local GravBtn, GravBox = MakeCharStat("GRAVITY", 196.2, "GR")
local CFrameSpeedBtn, CFrameSpeedBox = MakeCharStat("CF SPEED", 2, "Spd")
local SpinBtn, SpinBox = MakeCharStat("SPIN", 50, "Spd")

local UltraRunBtn = Instance.new("TextButton", MakeRow(CharScroll)) UltraRunBtn.Size = UDim2.new(1, 0, 1, 0) UltraRunBtn.Text = "ULTRA RUN: OFF" ApplyStyle(UltraRunBtn, Color3.fromRGB(255, 80, 0))
local NoclipBtn = Instance.new("TextButton", MakeRow(CharScroll)) NoclipBtn.Size = UDim2.new(1, 0, 1, 0) NoclipBtn.Text = "NOCLIP: OFF" ApplyStyle(NoclipBtn, Color3.fromRGB(0, 255, 200))
local UnviewBtn = Instance.new("TextButton", MakeRow(CharScroll)) UnviewBtn.Size = UDim2.new(1, 0, 1, 0) UnviewBtn.Text = "RESET CAMERA" ApplyStyle(UnviewBtn, Color3.fromRGB(150, 150, 255))

local FlyTab = MakeTab("FLIGHT", false)
local FlyScroll, _ = MakeScrollArea(FlyTab)
local FlyRow = MakeRow(FlyScroll)
local FlyBtn = Instance.new("TextButton", FlyRow) FlyBtn.Size = UDim2.new(0.65, 0, 1, 0) FlyBtn.Text = "FLY: OFF" ApplyStyle(FlyBtn, Color3.fromRGB(255, 0, 255))
local FlySpeedBox = Instance.new("TextBox", FlyRow) FlySpeedBox.Size = UDim2.new(0.33, 0, 1, 0) FlySpeedBox.Position = UDim2.new(0.67, 0, 0, 0) FlySpeedBox.Text = "50" ApplyStyle(FlySpeedBox, Color3.fromRGB(255, 0, 255))
local PlatformBtn = Instance.new("TextButton", MakeRow(FlyScroll)) PlatformBtn.Size = UDim2.new(1, 0, 1, 0) PlatformBtn.Text = "PLATFORM: OFF" ApplyStyle(PlatformBtn, Color3.fromRGB(0, 150, 255))
local UnvoidBtn = Instance.new("TextButton", MakeRow(FlyScroll)) UnvoidBtn.Size = UDim2.new(1, 0, 1, 0) UnvoidBtn.Text = "UN-VOID: OFF" ApplyStyle(UnvoidBtn, Color3.fromRGB(50, 50, 255))

local LagTab = MakeTab("LAG", false)
local LagTopLayout = Instance.new("UIListLayout", LagTab) LagTopLayout.Padding = UDim.new(0, 5)
local AntiFlingBtn = Instance.new("TextButton", MakeRow(LagTab)) AntiFlingBtn.Size = UDim2.new(1, 0, 1, 0) AntiFlingBtn.Text = "STAB (QUICK ANCHOR)" ApplyStyle(AntiFlingBtn, Color3.fromRGB(255, 50, 50))
local InfStabBtn = Instance.new("TextButton", MakeRow(LagTab)) InfStabBtn.Size = UDim2.new(1, 0, 1, 0) InfStabBtn.Text = "CHAOS LAG: OFF" ApplyStyle(InfStabBtn, Color3.fromRGB(255, 150, 0))
local AddLagBtn = Instance.new("TextButton", MakeRow(LagTab)) AddLagBtn.Size = UDim2.new(1, 0, 1, 0) AddLagBtn.Text = "+ ADD NEW LAG TO CHAIN" ApplyStyle(AddLagBtn, Color3.fromRGB(0, 255, 0))
local LagListWrapper = Instance.new("Frame", LagTab) LagListWrapper.Size = UDim2.new(1, 0, 1, -95) LagListWrapper.BackgroundTransparency = 1
local LagList, _ = MakeScrollArea(LagListWrapper)

local SettingsTab = MakeTab("SETTINGS", false)
local SettingsScroll, _ = MakeScrollArea(SettingsTab)

local ShrinkRow = MakeRow(SettingsScroll) ShrinkRow.LayoutOrder = 1
local ShrinkLbl = Instance.new("TextLabel", ShrinkRow) ShrinkLbl.Size = UDim2.new(0.65, 0, 1, 0) ShrinkLbl.Text = "SHRINK UI" ApplyStyle(ShrinkLbl, Color3.fromRGB(255, 255, 0))
local ShrinkBox = Instance.new("TextBox", ShrinkRow) ShrinkBox.Size = UDim2.new(0.33, 0, 1, 0) ShrinkBox.Position = UDim2.new(0.67, 0, 0, 0) ShrinkBox.Text = "1" ApplyStyle(ShrinkBox, Color3.fromRGB(255, 255, 0))

local AfkRow = MakeRow(SettingsScroll) AfkRow.LayoutOrder = 2
local AfkLbl = Instance.new("TextLabel", AfkRow) AfkLbl.Size = UDim2.new(0.65, 0, 1, 0) AfkLbl.Text = "AFK TIMEOUT" ApplyStyle(AfkLbl, Color3.fromRGB(150, 150, 150))
local AfkBox = Instance.new("TextBox", AfkRow) AfkBox.Size = UDim2.new(0.33, 0, 1, 0) AfkBox.Position = UDim2.new(0.67, 0, 0, 0) AfkBox.Text = "300" ApplyStyle(AfkBox, Color3.fromRGB(150, 150, 150))

local FpsBtn = Instance.new("TextButton", MakeRow(Set
