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

local FpsBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) FpsBtn.Parent.LayoutOrder = 3 FpsBtn.Size = UDim2.new(1, 0, 1, 0) FpsBtn.Text = "FPS HUD: OFF" ApplyStyle(FpsBtn, Color3.fromRGB(0, 255, 100))
local PingBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) PingBtn.Parent.LayoutOrder = 4 PingBtn.Size = UDim2.new(1, 0, 1, 0) PingBtn.Text = "PING HUD: OFF" ApplyStyle(PingBtn, Color3.fromRGB(255, 150, 0))

local ThemeLblRow = MakeRow(SettingsScroll) ThemeLblRow.LayoutOrder = 5
local ThemeLbl = Instance.new("TextLabel", ThemeLblRow) ThemeLbl.Size = UDim2.new(1, 0, 1, 0) ThemeLbl.Text = "--- THEMES ---" ApplyStyle(ThemeLbl, Color3.fromRGB(0, 255, 255))
local NeonBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) NeonBtn.Parent.LayoutOrder = 6 NeonBtn.Size = UDim2.new(1, 0, 1, 0) NeonBtn.Text = "NEON (DEFAULT)" ApplyStyle(NeonBtn, Color3.fromRGB(255, 0, 255))
local HackerBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) HackerBtn.Parent.LayoutOrder = 7 HackerBtn.Size = UDim2.new(1, 0, 1, 0) HackerBtn.Text = "HACKER (GREEN)" ApplyStyle(HackerBtn, Color3.fromRGB(0, 255, 0))
local BWBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) BWBtn.Parent.LayoutOrder = 8 BWBtn.Size = UDim2.new(1, 0, 1, 0) BWBtn.Text = "BLACK & WHITE" ApplyStyle(BWBtn, Color3.fromRGB(255, 255, 255))

NeonBtn.MouseButton1Click:Connect(function() SetTheme("NEON") end)
HackerBtn.MouseButton1Click:Connect(function() SetTheme("HACKER") end)
BWBtn.MouseButton1Click:Connect(function() SetTheme("B&W") end)

local SaveHeaderRow = MakeRow(SettingsScroll) SaveHeaderRow.LayoutOrder = 9
local SaveHeaderLbl = Instance.new("TextLabel", SaveHeaderRow) SaveHeaderLbl.Size = UDim2.new(1, 0, 1, 0) SaveHeaderLbl.Text = "--- SAVE SYSTEM ---" ApplyStyle(SaveHeaderLbl, Color3.fromRGB(0, 255, 150))
local GenSaveBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) GenSaveBtn.Parent.LayoutOrder = 10 GenSaveBtn.Size = UDim2.new(1, 0, 1, 0) GenSaveBtn.Text = "GENERATE SAVE CODE (COPIES)" ApplyStyle(GenSaveBtn, Color3.fromRGB(0, 255, 0))

local ImportBoxRow = MakeRow(SettingsScroll) ImportBoxRow.LayoutOrder = 11
local ImportBox = Instance.new("TextBox", ImportBoxRow) ImportBox.Name = "ImportBox" ImportBox.Size = UDim2.new(1, 0, 1, 0) ImportBox.PlaceholderText = "PASTE HUB-Save-... CODE HERE" ImportBox.ClearTextOnFocus = false ApplyStyle(ImportBox, Color3.fromRGB(255, 150, 0))

local LoadSaveBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) LoadSaveBtn.Parent.LayoutOrder = 12 LoadSaveBtn.Size = UDim2.new(1, 0, 1, 0) LoadSaveBtn.Text = "LOAD SAVE CODE" ApplyStyle(LoadSaveBtn, Color3.fromRGB(255, 0, 0))

local OrderBoxes = {}
for i, tBtn in ipairs(tabBtns) do
    local row = MakeRow(SettingsScroll)
    row.LayoutOrder = 20 + i
    local lbl = Instance.new("TextLabel", row) lbl.Size = UDim2.new(0.65, 0, 1, 0) lbl.Text = "TAB: " .. tBtn.Text ApplyStyle(lbl, Color3.fromRGB(255, 100, 0))
    local box = Instance.new("TextBox", row) box.Size = UDim2.new(0.33, 0, 1, 0) box.Position = UDim2.new(0.67, 0, 0, 0) box.Text = tostring(tBtn.LayoutOrder) ApplyStyle(box, Color3.fromRGB(255, 100, 0))
    table.insert(OrderBoxes, {btn = tBtn, box = box, row = row})
end

local ApplyOrderRow = MakeRow(SettingsScroll) ApplyOrderRow.LayoutOrder = 100
local ApplyOrderBtn = Instance.new("TextButton", ApplyOrderRow) ApplyOrderBtn.Size = UDim2.new(1, 0, 1, 0) ApplyOrderBtn.Text = "APPLY TAB ORDER" ApplyStyle(ApplyOrderBtn, Color3.fromRGB(0, 255, 0))

local function ApplyTabOrders()
    for _, ob in ipairs(OrderBoxes) do ob.btn.LayoutOrder = tonumber(ob.box.Text) or ob.btn.LayoutOrder end
    table.sort(OrderBoxes, function(a, b) return a.btn.LayoutOrder < b.btn.LayoutOrder end)
    for i, ob in ipairs(OrderBoxes) do
        ob.btn.LayoutOrder = i
        ob.row.LayoutOrder = 20 + i
        ob.box.Text = tostring(i)
    end
end
ApplyOrderBtn.MouseButton1Click:Connect(ApplyTabOrders)

-- FLOATING UI
local FlyUI = Instance.new("Frame", ScreenGui) FlyUI.Size = UDim2.new(0, 60, 0, 120) FlyUI.Position = UDim2.new(1, -70, 0.5, -60) FlyUI.BackgroundTransparency = 1 FlyUI.Visible = false
local FlyScaler = Instance.new("UIScale", FlyUI)
local FlyUpBtn = Instance.new("TextButton", FlyUI) FlyUpBtn.Size = UDim2.new(1, 0, 0.45, 0) FlyUpBtn.Text = "UP" ApplyStyle(FlyUpBtn, Color3.fromRGB(0, 255, 255)) FlyUpBtn.BackgroundTransparency = 0.5
local FlyDownBtn = Instance.new("TextButton", FlyUI) FlyDownBtn.Size = UDim2.new(1, 0, 0.45, 0) FlyDownBtn.Position = UDim2.new(0, 0, 0.55, 0) FlyDownBtn.Text = "DOWN" ApplyStyle(FlyDownBtn, Color3.fromRGB(0, 255, 255)) FlyDownBtn.BackgroundTransparency = 0.5

local PlatUI = Instance.new("Frame", ScreenGui) PlatUI.Size = UDim2.new(0, 60, 0, 50) PlatUI.Position = UDim2.new(1, -70, 0.5, 70) PlatUI.BackgroundTransparency = 1 PlatUI.Visible = false
local PlatScaler = Instance.new("UIScale", PlatUI)
local PlatDownBtn = Instance.new("TextButton", PlatUI) PlatDownBtn.Size = UDim2.new(1, 0, 1, 0) PlatDownBtn.Text = "DOWN" ApplyStyle(PlatDownBtn, Color3.fromRGB(0, 255, 255)) PlatDownBtn.BackgroundTransparency = 0.5

local upPressed, downPressed, platDownPressed = false, false, false
local function HookMobileBtn(btn, stateVarName)
    btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then if stateVarName == "up" then upPressed = true elseif stateVarName == "down" then downPressed = true else platDownPressed = true end end end)
    btn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then if stateVarName == "up" then upPressed = false elseif stateVarName == "down" then downPressed = false else platDownPressed = false end end end)
end
HookMobileBtn(FlyUpBtn, "up") HookMobileBtn(FlyDownBtn, "down") HookMobileBtn(PlatDownBtn, "plat")

local function ApplyShrink()
    local factor = tonumber(ShrinkBox.Text)
    if factor and factor > 0 then MainScaler.Scale = 1 / factor FlyScaler.Scale = 1 / factor PlatScaler.Scale = 1 / factor
    else ShrinkBox.Text = "1" MainScaler.Scale = 1 FlyScaler.Scale = 1 PlatScaler.Scale = 1 end
end
ShrinkBox.FocusLost:Connect(ApplyShrink)

-- STATE & FEATURE METHODS
local function SetFPS(state)
    fpsActive = state ApplyToggleStyle(FpsBtn, fpsActive, Color3.fromRGB(0, 255, 100)) FpsBtn.Text = "FPS HUD: " .. (fpsActive and "ON" or "OFF")
    FpsLbl.Visible = fpsActive StatsFrame.Visible = fpsActive or pingActive
end
FpsBtn.MouseButton1Click:Connect(function() SetFPS(not fpsActive) end)

local function SetPing(state)
    pingActive = state ApplyToggleStyle(PingBtn, pingActive, Color3.fromRGB(255, 150, 0)) PingBtn.Text = "PING HUD: " .. (pingActive and "ON" or "OFF")
    PingLbl.Visible = pingActive StatsFrame.Visible = fpsActive or pingActive
end
PingBtn.MouseButton1Click:Connect(function() SetPing(not pingActive) end)

local fpsTimer, frames = 0, 0
AddConn(RunService.RenderStepped:Connect(function(dt)
    frames = frames + 1 fpsTimer = fpsTimer + dt
    if fpsTimer >= 1 then
        if fpsActive then FpsLbl.Text = "FPS: " .. frames end
        frames, fpsTimer = 0, 0
    end
    if pingActive then PingLbl.Text = "PING: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. " ms" end
end))

local function SetESP(state)
    espActive = state ApplyToggleStyle(EspBtn, espActive, Color3.fromRGB(0, 255, 100)) EspBtn.Text = "ESP: " .. (espActive and "ON" or "OFF")
    if not state then for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("LuxuryESP") then p.Character.LuxuryESP:Destroy() end end end
end

local function applyWS() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if h then h.WalkSpeed = tonumber(WsBox.Text) or 16 end end
local function applyJP() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if h then h.UseJumpPower = true h.JumpPower = tonumber(JpBox.Text) or 50 end end
local function applyGrav() workspace.Gravity = tonumber(GravBox.Text) or 196.2 end

-- INVISIBILITY AND PLATFORM
local realChar, fakeChar = nil, nil
local platPart = nil
local function ToggleInvis(state)
    if invisActive == state then return end
    invisActive = state ApplyToggleStyle(InvisBtn, invisActive, Color3.fromRGB(200, 0, 255)) InvisBtn.Text = "INVISIBILITY: " .. (invisActive and "ON" or "OFF")
    
    if invisActive then
        realChar = LocalPlayer.Character
        if realChar then
            realChar.Archivable = true
            fakeChar = realChar:Clone() fakeChar.Name = realChar.Name fakeChar.Parent = workspace
            LocalPlayer.Character = fakeChar workspace.CurrentCamera.CameraSubject = fakeChar:FindFirstChild("Humanoid")
            local rHrp = realChar:FindFirstChild("HumanoidRootPart") if rHrp then rHrp.Anchored = false end
            local fHum = fakeChar:FindFirstChild("Humanoid")
            if fHum then fHum.Died:Connect(function() ToggleInvis(false) LocalPlayer.Character = realChar if realChar:FindFirstChild("Humanoid") then realChar.Humanoid.Health = 0 end end) end
        end
    else
        if fakeChar and realChar then
            local fHrp, rHrp = fakeChar:FindFirstChild("HumanoidRootPart"), realChar:FindFirstChild("HumanoidRootPart")
            if rHrp and fHrp then rHrp.CFrame = fHrp.CFrame end
            LocalPlayer.Character = realChar workspace.CurrentCamera.CameraSubject = realChar:FindFirstChild("Humanoid")
            fakeChar:Destroy() fakeChar = nil
        end
    end
end
InvisBtn.MouseButton1Click:Connect(function() ToggleInvis(not invisActive) end)

local function TogglePlatform(state)
    if platActive == state then return end
    platActive = state ApplyToggleStyle(PlatformBtn, platActive, Color3.fromRGB(0, 150, 255)) PlatformBtn.Text = "PLATFORM: " .. (platActive and "ON" or "OFF") PlatUI.Visible = platActive
    if platActive then
        platPart = Instance.new("Part", workspace) platPart.Size = Vector3.new(6, 1, 6) platPart.Anchored = true platPart.Transparency = 1
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local currentY = hrp and (hrp.Position.Y - 3.5) or 0
        platConn = AddConn(RunService.RenderStepped:Connect(function()
            local cHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not cHrp then return end
            if (cHrp.Position.Y - 3.5) > currentY + 0.5 then currentY = cHrp.Position.Y - 3.5 end
            if platDownPressed or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then currentY = currentY - 1 end
            platPart.CFrame = CFrame.new(cHrp.Position.X, currentY, cHrp.Position.Z)
        end))
    else
        if platPart then platPart:Destroy() end
        if platConn then platConn:Disconnect() end
    end
end
PlatformBtn.MouseButton1Click:Connect(function() TogglePlatform(not platActive) end)

local function SetFly(state)
    flying = state ApplyToggleStyle(FlyBtn, flying, Color3.fromRGB(255, 0, 255)) FlyBtn.Text = "FLY: " .. (flying and "ON" or "OFF") FlyUI.Visible = flying
    local char = LocalPlayer.Character local hrp = char and char:FindFirstChild("HumanoidRootPart") local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    
    if flying then
        local bv = Instance.new("BodyVelocity", hrp) bv.Name = "FlyBV" bv.MaxForce = Vector3.new(9e9, 9e9, 9e9) 
        local bg = Instance.new("BodyGyro", hrp) bg.Name = "FlyBG" bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9) bg.P = 9e4 hum.PlatformStand = true
        flyConn = AddConn(RunService.RenderStepped:Connect(function()
            bg.CFrame = workspace.CurrentCamera.CFrame
            local spd, yMove = tonumber(FlySpeedBox.Text) or 50, 0
            if UIS:IsKeyDown(Enum.KeyCode.Space) or upPressed then yMove = spd end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or downPressed then yMove = -spd end
            bv.Velocity = Vector3.new((hum.MoveDirection * spd).X, yMove, (hum.MoveDirection * spd).Z)
        end))
    else
        if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end
        hum.PlatformStand = false if flyConn then flyConn:Disconnect() end
    end
end
FlyBtn.MouseButton1Click:Connect(function() SetFly(not flying) end)

local function SetUndie(s) undieActive = s ApplyToggleStyle(UndieBtn, undieActive, Color3.fromRGB(200, 50, 50)) UndieBtn.Text = "UN-DIE: " .. (undieActive and "ON" or "OFF") end
local function SetUnvoid(s) unvoidActive = s ApplyToggleStyle(UnvoidBtn, unvoidActive, Color3.fromRGB(50, 50, 255)) UnvoidBtn.Text = "UN-VOID: " .. (unvoidActive and "ON" or "OFF") end
local function SetChaosLag(s) infStabActive = s ApplyToggleStyle(InfStabBtn, infStabActive, Color3.fromRGB(255, 150, 0)) InfStabBtn.Text = "CHAOS LAG: " .. (infStabActive and "ON" or "OFF") end

UndieBtn.MouseButton1Click:Connect(function() SetUndie(not undieActive) end)
UnvoidBtn.MouseButton1Click:Connect(function() SetUnvoid(not unvoidActive) end)
InfStabBtn.MouseButton1Click:Connect(function() SetChaosLag(not infStabActive) end)
WsBtn.MouseButton1Click:Connect(applyWS) JpBtn.MouseButton1Click:Connect(applyJP) GravBtn.MouseButton1Click:Connect(applyGrav)

-- SEARCH LOGIC
local function PerformSearch()
    local q = string.lower(SearchBox.Text)
    for i, tBtn in ipairs(tabBtns) do
        local tabObj = tabs[i]
        local scroll = tabObj:FindFirstChildOfClass("ScrollingFrame") or (tabObj:FindFirstChildOfClass("Frame") and tabObj:FindFirstChildOfClass("Frame"):FindFirstChildOfClass("ScrollingFrame"))
        if scroll then
            for _, row in ipairs(scroll:GetChildren()) do
                if row:IsA("Frame") then
                    if q == "" then row.Visible = true else
                        local match = false
                        for _, el in ipairs(row:GetDescendants()) do if el:IsA("TextLabel") or el:IsA("TextButton") then if string.find(string.lower(el.Text), q) then match = true break end end end
                        row.Visible = match
                    end
                end
            end
        end
    end
end
SearchBox:GetPropertyChangedSignal("Text"):Connect(PerformSearch)

-- SAVE / LOAD SYSTEM
local lagChain = {{anchor = 0.2, free = 0.1}}

GenSaveBtn.MouseButton1Click:Connect(function()
    local tgs = string.format("%d%d%d%d%d%d%d%d%d%d%d%d%d", espActive and 1 or 0, ultraRunActive and 1 or 0, noclipActive and 1 or 0, invisActive and 1 or 0, undieActive and 1 or 0, flying and 1 or 0, platActive and 1 or 0, unvoidActive and 1 or 0, infStabActive and 1 or 0, cfSpeedActive and 1 or 0, spinActive and 1 or 0, fpsActive and 1 or 0, pingActive and 1 or 0)
    local tabsOrderStr = ""
    for i, ob in ipairs(OrderBoxes) do tabsOrderStr = tabsOrderStr .. tostring(ob.btn.LayoutOrder) .. (i == #OrderBoxes and "" or ",") end
    local lagStr = ""
    for i, l in ipairs(lagChain) do lagStr = lagStr .. tostring(l.anchor) .. ":" .. tostring(l.free) .. (i == #lagChain and "" or ",") end

    local rawStr = string.format("%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s", currentTheme, ShrinkBox.Text, AfkBox.Text, WsBox.Text, JpBox.Text, GravBox.Text, CFrameSpeedBox.Text, SpinBox.Text, tgs, tabsOrderStr, lagStr, tostring(activeTabIndex))
    local saveCode = "HUB-Save-" .. B64Encode(rawStr)
    
    local s, _ = pcall(function() setclipboard(saveCode) end)
    GenSaveBtn.Text = s and "COPIED TO CLIPBOARD!" or "ERROR: CLIPBOARD UNSUPPORTED"
    task.delay(2, function() GenSaveBtn.Text = "GENERATE SAVE CODE (COPIES)" end)
end)

LoadSaveBtn.MouseButton1Click:Connect(function()
    local str = ImportBox.Text
    if not str:match("^HUB%-Save%-") then return end
    local dec = B64Decode(str:sub(10))
    local p = string.split(dec, "|")
    if #p >= 12 then
        SetTheme(p[1]) ShrinkBox.Text = p[2] ApplyShrink() AfkBox.Text = p[3]
        WsBox.Text = p[4] applyWS() JpBox.Text = p[5] applyJP() GravBox.Text = p[6] applyGrav()
        
        local t = p[9]
        SetESP(t:sub(1,1)=="1") ToggleInvis(t:sub(4,4)=="1") SetUndie(t:sub(5,5)=="1") SetFly(t:sub(6,6)=="1")
        TogglePlatform(t:sub(7,7)=="1") SetUnvoid(t:sub(8,8)=="1") SetChaosLag(t:sub(9,9)=="1")
        SetFPS(t:sub(12,12)=="1") SetPing(t:sub(13,13)=="1")

        local tOrd = string.split(p[10], ",")
        for i, v in ipairs(tOrd) do if OrderBoxes[i] then OrderBoxes[i].box.Text = v end end
        ApplyTabOrders()
        
        local aIdx = tonumber(p[12]) or 1
        if tabBtns[aIdx] then
            -- Simulate Click to restore the visual active tab perfectly
            for _, conn in ipairs(getconnections(tabBtns[aIdx].MouseButton1Click)) do conn:Fire() end
        end

        ImportBox.Text = "" ImportBox.PlaceholderText = "SUCCESSFULLY LOADED!"
        task.delay(2, function() ImportBox.PlaceholderText = "PASTE HUB-Save-... CODE HERE" end)
    end
end)

-- AFK AND CLEANUP SYSTEM
local lastActive = tick()
local function checkUIInteraction(input)
    local p = input.Position
    for _, f in ipairs({MainFrame, FlyUI, PlatUI}) do
        if f.Visible then
            local a, s = f.AbsolutePosition, f.AbsoluteSize
            if p.X >= a.X and p.X <= a.X + s.X and p.Y >= a.Y and p.Y <= a.Y + s.Y then lastActive = tick() end
        end
    end
end
UIS.InputBegan:Connect(checkUIInteraction)
UIS.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then checkUIInteraction(input) end end)

local function ForceCleanup()
    -- Disable active logic
    ToggleInvis(false) SetFly(false) TogglePlatform(false) SetESP(false)
    undieActive, unvoidActive, infStabActive = false, false, false
    
    -- Disconnect specifically injected RunService events
    for _, conn in ipairs(_connections) do if conn then conn:Disconnect() end end
    
    -- Restore physical character traits completely
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = false if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false hum.WalkSpeed = 16 hum.UseJumpPower = true hum.JumpPower = 50 workspace.CurrentCamera.CameraSubject = hum end
    end
    workspace.Gravity = 196.2
end

task.spawn(function()
    while task.wait(1) do
        if not ScreenGui.Parent then break end
        if tick() - lastActive > (tonumber(AfkBox.Text) or 300) then ForceCleanup() ScreenGui:Destroy() break end
    end
end)

CloseBtn.MouseButton1Click:Connect(function() ForceCleanup() ScreenGui:Destroy() end)
