local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryHub"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ==================== GLOBAL REGISTRY ====================
local ServiceConnections = {}
local function AddServiceConn(conn)
    table.insert(ServiceConnections, conn)
    return conn
end

-- ==================== THEME SYSTEM ====================
local currentTheme = "NEON"

local function UpdateInstanceTheme(inst)
    if not inst:GetAttribute("NeonStroke") then return end
    local targetBg = inst:GetAttribute("NeonBg")
    local targetStroke = inst:GetAttribute("NeonStroke")
    local targetText = inst:GetAttribute("NeonText")
    
    if currentTheme == "HACKER" then
        targetBg = Color3.fromRGB(5, 10, 5)
        targetStroke = Color3.fromRGB(0, 255, 0)
        targetText = Color3.fromRGB(0, 255, 0)
    elseif currentTheme == "B&W" then
        targetBg = Color3.fromRGB(15, 15, 15)
        targetStroke = Color3.fromRGB(255, 255, 255)
        targetText = Color3.fromRGB(255, 255, 255)
    end

    TS:Create(inst, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {BackgroundColor3 = targetBg}):Play()
    
    local stroke = inst:FindFirstChildWhichIsA("UIStroke")
    if stroke then 
        TS:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {Color = targetStroke}):Play() 
    end
    
    if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
        TS:Create(inst, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {TextColor3 = targetText}):Play()
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
        if inst:IsA("TextBox") then inst.Text = "" end -- Fix core TextBox default bug
    end
    
    local corner = inst:FindFirstChild("UICorner") or Instance.new("UICorner", inst)
    corner.CornerRadius = UDim.new(0, 4)
    
    local stroke = inst:FindFirstChild("UIStroke") or Instance.new("UIStroke", inst)
    stroke.Thickness = inst:IsA("TextLabel") and 1 or 1.5 
    stroke.ApplyStrokeMode = inst:IsA("TextLabel") and Enum.ApplyStrokeMode.Contextual or Enum.ApplyStrokeMode.Border

    if inst:IsA("TextButton") and not inst:GetAttribute("HoverHooked") then
        inst:SetAttribute("HoverHooked", true)
        inst.MouseEnter:Connect(function()
            TS:Create(inst, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play()
            TS:Create(stroke, TweenInfo.new(0.2), {Thickness = 2.5}):Play()
        end)
        inst.MouseLeave:Connect(function()
            TS:Create(inst, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TS:Create(stroke, TweenInfo.new(0.2), {Thickness = 1.5}):Play()
        end)
    end

    UpdateInstanceTheme(inst)
end

local function SetTheme(themeName)
    currentTheme = themeName
    for _, inst in pairs(ScreenGui:GetDescendants()) do UpdateInstanceTheme(inst) end
    UpdateInstanceTheme(ScreenGui)
end

local function ApplyToggleStyle(btn, state, defColor)
    btn:SetAttribute("NeonStroke", state and Color3.fromRGB(0, 255, 0) or defColor)
    UpdateInstanceTheme(btn)
end

-- ==================== BASE64 SYSTEM ====================
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

-- ==================== GUI INITIALIZATION ====================
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.Size = UDim2.new(0, 450, 0, 300) 
MainFrame.Active = true
MainFrame.ClipsDescendants = true
ApplyStyle(MainFrame, Color3.fromRGB(255, 0, 255), Color3.fromRGB(10, 5, 15))

local MainScaler = Instance.new("UIScale", MainFrame)
MainScaler.Scale = 1

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

-- Dragging Logic
local DragHandle = Instance.new("Frame")
DragHandle.Size = UDim2.new(1, -50, 0, 25)
DragHandle.BackgroundTransparency = 1
DragHandle.Parent = MainFrame

local dragging, dragInput, dragStart, startPos
AddServiceConn(DragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end))
AddServiceConn(DragHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end))
AddServiceConn(UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (delta.X / MainScaler.Scale), startPos.Y.Scale, startPos.Y.Offset + (delta.Y / MainScaler.Scale))
    end
end))

local Title = Instance.new("TextLabel")
Title.Text = "KIRIK HUB V49"
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

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 110, 1, -35)
Sidebar.Position = UDim2.new(0, 5, 0, 30)
Sidebar.BackgroundTransparency = 1
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

local SearchBox = Instance.new("TextBox", Sidebar)
SearchBox.Size = UDim2.new(1, 0, 0, 25)
SearchBox.PlaceholderText = "SEARCH..."
SearchBox.LayoutOrder = -1
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
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    return scroll, layout
end

local function MakeRow(parent, height)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -5, 0, height or 25)
    row.BackgroundTransparency = 1
    return row
end

local minimized = false
local isAnimating = false
MinBtn.MouseButton1Click:Connect(function()
    if isAnimating then return end
    isAnimating = true
    minimized = not minimized
    MinBtn.Text = minimized and "+" or "-"
    local targetSize = minimized and UDim2.new(0, 150, 0, 25) or UDim2.new(0, 450, 0, 300)
    
    if minimized then
        Sidebar.Visible = false
        TabContainer.Visible = false
    end
    
    local tw = TS:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize})
    tw:Play()
    tw.Completed:Connect(function()
        if not minimized then
            Sidebar.Visible = true
            TabContainer.Visible = true
        end
        isAnimating = false
    end)
end)

-- ==================== SYSTEM GLOBALS & LOGIC ====================
local espActive, ultraRunActive, noclipActive = false, false, false
local invisActive, undieActive, platActive, unvoidActive = false, false, false, false
local flying, infStabActive, cfSpeedActive, spinActive = false, false, false, false
local fpsActive, pingActive = false, false
local aimbotActive, antiAfkActive = false, false

local listMode, npcListMode = "TP", "TP"
local cachedNPCs, savedSpots = {}, {}
local spotCount = 0
local lagState, lagTimer, lagIndex = "FREE", 0, 1
local currentInfTpTarget, infTpConn, flyConn, platConn = nil, nil, nil, nil

local ToggleInvis, TogglePlatform, SetFly, SetUltraRun, SetNoclip, SetUndie, SetUnvoid
local SetChaosLag, SetCFSpeed, SetSpin, SetESP, SetAimbot, SetAntiAfk
local ApplyShrink
local updateLagList, updatePlayerList, updateNpcList
local PerformSearch
local GetClosestPlayerToCursor

-- ==================== UI CONSTRUCTION ====================
local HomeTab = MakeTab("HOME", true)
local WelcomeText = Instance.new("TextLabel", HomeTab)
WelcomeText.Size = UDim2.new(1, 0, 1, 0)
WelcomeText.Text = "KIRIK HUB V49\n\n[ NEW FEATURES ]\n- Aimbot (Hold RMB)\n- Anti-AFK (Bypass Kicks)\n- Fully Animated Themes\n- Ghost Invisibility & Chaos Lag"
WelcomeText.TextWrapped = true
WelcomeText.TextYAlignment = Enum.TextYAlignment.Top
ApplyStyle(WelcomeText, Color3.fromRGB(0, 255, 255), Color3.fromRGB(15, 15, 20))

local PlayersTab = MakeTab("PLAYERS", false)
local PTopLayout = Instance.new("UIListLayout", PlayersTab)
PTopLayout.Padding = UDim.new(0, 5)
local AimbotBtn = Instance.new("TextButton", MakeRow(PlayersTab)) AimbotBtn.Size = UDim2.new(1, 0, 1, 0) AimbotBtn.Text = "AIMBOT: OFF (HOLD RMB)" ApplyStyle(AimbotBtn, Color3.fromRGB(255, 50, 50))
local EspBtn = Instance.new("TextButton", MakeRow(PlayersTab)) EspBtn.Size = UDim2.new(1, 0, 1, 0) EspBtn.Text = "ESP: OFF" ApplyStyle(EspBtn, Color3.fromRGB(0, 255, 100))
local ModeBtn = Instance.new("TextButton", MakeRow(PlayersTab)) ModeBtn.Size = UDim2.new(1, 0, 1, 0) ModeBtn.Text = "LIST MODE: TP" ApplyStyle(ModeBtn, Color3.fromRGB(255, 0, 255))
local AddTpBtn = Instance.new("TextButton", MakeRow(PlayersTab)) AddTpBtn.Size = UDim2.new(1, 0, 1, 0) AddTpBtn.Text = "ADD CUSTOM TP PART" ApplyStyle(AddTpBtn, Color3.fromRGB(0, 150, 255))
local PlayerListWrapper = Instance.new("Frame", PlayersTab) PlayerListWrapper.Size = UDim2.new(1, 0, 1, -125) PlayerListWrapper.BackgroundTransparency = 1
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
    local box = Instance.new("TextBox", row) box.Size = UDim2.new(0.33, 0, 1, 0) box.Position = UDim2.new(0.67, 0, 0, 0) box.Text = tostring(defaultVal) box.PlaceholderText = placeholder ApplyStyle(box, Color3.fromRGB(255, 255, 0))
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
local ShrinkLbl = Instance.new("TextLabel", ShrinkRow) ShrinkLbl.Size = UDim2.new(0.65, 0, 1, 0) ShrinkLbl.Text = "SHRINK UI (Ex: 2 = 2x smaller)" ApplyStyle(ShrinkLbl, Color3.fromRGB(255, 255, 0))
local ShrinkBox = Instance.new("TextBox", ShrinkRow) ShrinkBox.Size = UDim2.new(0.33, 0, 1, 0) ShrinkBox.Position = UDim2.new(0.67, 0, 0, 0) ShrinkBox.Text = "1" ApplyStyle(ShrinkBox, Color3.fromRGB(255, 255, 0))

local AfkRow = MakeRow(SettingsScroll) AfkRow.LayoutOrder = 2
local AfkLbl = Instance.new("TextLabel", AfkRow) AfkLbl.Size = UDim2.new(0.65, 0, 1, 0) AfkLbl.Text = "UI AUTOCLOSE (SEC)" ApplyStyle(AfkLbl, Color3.fromRGB(150, 150, 150))
local AfkBox = Instance.new("TextBox", AfkRow) AfkBox.Size = UDim2.new(0.33, 0, 1, 0) AfkBox.Position = UDim2.new(0.67, 0, 0, 0) AfkBox.Text = "9999" ApplyStyle(AfkBox, Color3.fromRGB(150, 150, 150))

local AntiAfkBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) AntiAfkBtn.Parent.LayoutOrder = 3 AntiAfkBtn.Size = UDim2.new(1, 0, 1, 0) AntiAfkBtn.Text = "ROBLOX ANTI-AFK: OFF" ApplyStyle(AntiAfkBtn, Color3.fromRGB(0, 200, 255))
local FpsBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) FpsBtn.Parent.LayoutOrder = 4 FpsBtn.Size = UDim2.new(1, 0, 1, 0) FpsBtn.Text = "FPS HUD: OFF" ApplyStyle(FpsBtn, Color3.fromRGB(0, 255, 100))
local PingBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) PingBtn.Parent.LayoutOrder = 5 PingBtn.Size = UDim2.new(1, 0, 1, 0) PingBtn.Text = "PING HUD: OFF" ApplyStyle(PingBtn, Color3.fromRGB(255, 150, 0))

local ThemeLblRow = MakeRow(SettingsScroll) ThemeLblRow.LayoutOrder = 6
local ThemeLbl = Instance.new("TextLabel", ThemeLblRow) ThemeLbl.Size = UDim2.new(1, 0, 1, 0) ThemeLbl.Text = "--- THEMES ---" ApplyStyle(ThemeLbl, Color3.fromRGB(0, 255, 255))
local NeonBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) NeonBtn.Parent.LayoutOrder = 7 NeonBtn.Size = UDim2.new(1, 0, 1, 0) NeonBtn.Text = "NEON (DEFAULT)" ApplyStyle(NeonBtn, Color3.fromRGB(255, 0, 255))
local HackerBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) HackerBtn.Parent.LayoutOrder = 8 HackerBtn.Size = UDim2.new(1, 0, 1, 0) HackerBtn.Text = "HACKER (GREEN)" ApplyStyle(HackerBtn, Color3.fromRGB(0, 255, 0))
local BWBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) BWBtn.Parent.LayoutOrder = 9 BWBtn.Size = UDim2.new(1, 0, 1, 0) BWBtn.Text = "BLACK & WHITE" ApplyStyle(BWBtn, Color3.fromRGB(255, 255, 255))

NeonBtn.MouseButton1Click:Connect(function() SetTheme("NEON") end)
HackerBtn.MouseButton1Click:Connect(function() SetTheme("HACKER") end)
BWBtn.MouseButton1Click:Connect(function() SetTheme("B&W") end)

local SaveHeaderRow = MakeRow(SettingsScroll) SaveHeaderRow.LayoutOrder = 10
local SaveHeaderLbl = Instance.new("TextLabel", SaveHeaderRow) SaveHeaderLbl.Size = UDim2.new(1, 0, 1, 0) SaveHeaderLbl.Text = "--- SAVE SYSTEM ---" ApplyStyle(SaveHeaderLbl, Color3.fromRGB(0, 255, 150))
local GenSaveBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) GenSaveBtn.Parent.LayoutOrder = 11 GenSaveBtn.Size = UDim2.new(1, 0, 1, 0) GenSaveBtn.Text = "GENERATE SAVE CODE" ApplyStyle(GenSaveBtn, Color3.fromRGB(0, 255, 0))
local ImportBoxRow = MakeRow(SettingsScroll) ImportBoxRow.LayoutOrder = 12
local ImportBox = Instance.new("TextBox", ImportBoxRow) ImportBox.Size = UDim2.new(1, 0, 1, 0) ImportBox.PlaceholderText = "PASTE HUB-Save-... CODE HERE" ImportBox.ClearTextOnFocus = false ApplyStyle(ImportBox, Color3.fromRGB(255, 150, 0))
local LoadSaveBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) LoadSaveBtn.Parent.LayoutOrder = 13 LoadSaveBtn.Size = UDim2.new(1, 0, 1, 0) LoadSaveBtn.Text = "LOAD SAVE CODE" ApplyStyle(LoadSaveBtn, Color3.fromRGB(255, 0, 0))

local TabOrderLblRow = MakeRow(SettingsScroll) TabOrderLblRow.LayoutOrder = 14
local TabOrderLbl = Instance.new("TextLabel", TabOrderLblRow) TabOrderLbl.Size = UDim2.new(1, 0, 1, 0) TabOrderLbl.Text = "--- TAB ORDER ---" ApplyStyle(TabOrderLbl, Color3.fromRGB(0, 255, 255))

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
    local temp = {}
    for i, ob in ipairs(OrderBoxes) do 
        local lo = tonumber(ob.box.Text) or ob.btn.LayoutOrder
        table.insert(temp, {index = i, val = lo})
    end
    table.sort(temp, function(a, b) return a.val < b.val end)
    for newPos, data in ipairs(temp) do
        local ob = OrderBoxes[data.index]
        ob.btn.LayoutOrder = newPos
        ob.row.LayoutOrder = 20 + newPos
        ob.box.Text = tostring(newPos)
    end
end
ApplyOrderBtn.MouseButton1Click:Connect(ApplyTabOrders)

-- ==================== LIVE SEARCH SYSTEM ====================
PerformSearch = function()
    local q = string.lower(SearchBox.Text)
    local firstVisibleTab = nil
    local anyTabVisible = false

    for i, tBtn in ipairs(tabBtns) do
        local tabObj = tabs[i]
        local tabMatches = string.find(string.lower(tBtn.Text), q) ~= nil
        local hasVisibleRow = false

        local scroll = tabObj:FindFirstChildOfClass("ScrollingFrame")
        if not scroll then
            local wrapper = tabObj:FindFirstChildOfClass("Frame")
            if wrapper then scroll = wrapper:FindFirstChildOfClass("ScrollingFrame") end
        end

        if scroll then
            for _, row in ipairs(scroll:GetChildren()) do
                if row:IsA("Frame") then
                    if q == "" or tabMatches then
                        row.Visible = true hasVisibleRow = true
                    else
                        local rowMatches = false
                        for _, el in ipairs(row:GetDescendants()) do
                            if (el:IsA("TextLabel") or el:IsA("TextButton") or el:IsA("TextBox")) and el.Text ~= "" then
                                if string.find(string.lower(el.Text), q) then rowMatches = true break end
                            end
                        end
                        row.Visible = rowMatches
                        if rowMatches then hasVisibleRow = true end
                    end
                end
            end
        else hasVisibleRow = true end

        if q == "" or tabMatches or hasVisibleRow then
            tBtn.Visible = true anyTabVisible = true
            if not firstVisibleTab then firstVisibleTab = i end
        else tBtn.Visible = false end
    end

    if anyTabVisible then
        local currentIsVisible = false
        for i, t in ipairs(tabs) do if t.Visible and tabBtns[i].Visible then currentIsVisible = true break end end
        if not currentIsVisible and firstVisibleTab then
            for _, t in ipairs(tabs) do t.Visible = false end
            for _, b in ipairs(tabBtns) do 
                b:SetAttribute("NeonStroke", Color3.fromRGB(0, 150, 255))
                b:SetAttribute("NeonBg", Color3.fromRGB(15, 15, 20))
                UpdateInstanceTheme(b)
            end
            tabs[firstVisibleTab].Visible = true
            local fBtn = tabBtns[firstVisibleTab]
            fBtn:SetAttribute("NeonStroke", Color3.fromRGB(255, 0, 255))
            fBtn:SetAttribute("NeonBg", Color3.fromRGB(30, 20, 40))
            UpdateInstanceTheme(fBtn)
        end
    end
end
AddServiceConn(SearchBox:GetPropertyChangedSignal("Text"):Connect(PerformSearch))

-- ==================== FLOATING MOBILE UI ====================
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

ApplyShrink = function()
    local factor = tonumber(ShrinkBox.Text)
    if factor and factor > 0 then MainScaler.Scale = 1/factor FlyScaler.Scale = 1/factor PlatScaler.Scale = 1/factor
    else ShrinkBox.Text = "1" MainScaler.Scale = 1 FlyScaler.Scale = 1 PlatScaler.Scale = 1 end
end
ShrinkBox.FocusLost:Connect(ApplyShrink)

-- ==================== STATE SETTERS ====================
SetAimbot = function(state) aimbotActive = state ApplyToggleStyle(AimbotBtn, aimbotActive, Color3.fromRGB(255, 50, 50)) AimbotBtn.Text = "AIMBOT: " .. (aimbotActive and "ON (HOLD RMB)" or "OFF") end
SetAntiAfk = function(state) antiAfkActive = state ApplyToggleStyle(AntiAfkBtn, antiAfkActive, Color3.fromRGB(0, 200, 255)) AntiAfkBtn.Text = "ROBLOX ANTI-AFK: " .. (antiAfkActive and "ON" or "OFF") end
local function SetFPS(state) fpsActive = state ApplyToggleStyle(FpsBtn, fpsActive, Color3.fromRGB(0, 255, 100)) FpsBtn.Text = "FPS HUD: " .. (fpsActive and "ON" or "OFF") FpsLbl.Visible = fpsActive StatsFrame.Visible = fpsActive or pingActive end
local function SetPing(state) pingActive = state ApplyToggleStyle(PingBtn, pingActive, Color3.fromRGB(255, 150, 0)) PingBtn.Text = "PING HUD: " .. (pingActive and "ON" or "OFF") PingLbl.Visible = pingActive StatsFrame.Visible = fpsActive or pingActive end

SetESP = function(state)
    if espActive == state then return end
    espActive = state ApplyToggleStyle(EspBtn, espActive, Color3.fromRGB(0, 255, 100)) EspBtn.Text = "ESP: " .. (espActive and "ON" or "OFF")
    if not state then for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("LuxuryESP") then p.Character.LuxuryESP:Destroy() end end end
end
SetUltraRun = function(state) if ultraRunActive == state then return end ultraRunActive = state ApplyToggleStyle(UltraRunBtn, ultraRunActive, Color3.fromRGB(255, 80, 0)) UltraRunBtn.Text = "ULTRA RUN: " .. (ultraRunActive and "ON" or "OFF") if not state then local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if hum then for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(1) end end end end
SetNoclip = function(state) if noclipActive == state then return end noclipActive = state ApplyToggleStyle(NoclipBtn, noclipActive, Color3.fromRGB(0, 255, 200)) NoclipBtn.Text = "NOCLIP: " .. (noclipActive and "ON" or "OFF") end
SetUndie = function(state) if undieActive == state then return end undieActive = state ApplyToggleStyle(UndieBtn, undieActive, Color3.fromRGB(200, 50, 50)) UndieBtn.Text = "UN-DIE: " .. (undieActive and "ON" or "OFF") end
SetUnvoid = function(state) if unvoidActive == state then return end unvoidActive = state ApplyToggleStyle(UnvoidBtn, unvoidActive, Color3.fromRGB(50, 50, 255)) UnvoidBtn.Text = "UN-VOID: " .. (unvoidActive and "ON" or "OFF") end
SetChaosLag = function(state) if infStabActive == state then return end infStabActive = state ApplyToggleStyle(InfStabBtn, infStabActive, Color3.fromRGB(255, 150, 0)) InfStabBtn.Text = "CHAOS LAG: " .. (infStabActive and "ON" or "OFF") if not state then local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.Anchored = false hrp.Velocity = Vector3.zero end end end
SetCFSpeed = function(state) if cfSpeedActive == state then return end cfSpeedActive = state ApplyToggleStyle(CFrameSpeedBtn, cfSpeedActive, Color3.fromRGB(255, 100, 0)) CFrameSpeedBtn.Text = "CF SPD: " .. (cfSpeedActive and "ON" or "OFF") end
SetSpin = function(state) if spinActive == state then return end spinActive = state ApplyToggleStyle(SpinBtn, spinActive, Color3.fromRGB(0, 255, 50)) SpinBtn.Text = "SPIN: " .. (spinActive and "ON" or "OFF") end

local function applyWS() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if h then h.WalkSpeed = tonumber(WsBox.Text) or 16 end end
local function applyJP() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if h then h.UseJumpPower = true h.JumpPower = tonumber(JpBox.Text) or 50 end end
local function applyGrav() workspace.Gravity = tonumber(GravBox.Text) or 196.2 end

AimbotBtn.MouseButton1Click:Connect(function() SetAimbot(not aimbotActive) end)
AntiAfkBtn.MouseButton1Click:Connect(function() SetAntiAfk(not antiAfkActive) end)
FpsBtn.MouseButton1Click:Connect(function() SetFPS(not fpsActive) end)
PingBtn.MouseButton1Click:Connect(function() SetPing(not pingActive) end)
EspBtn.MouseButton1Click:Connect(function() SetESP(not espActive) end)
UltraRunBtn.MouseButton1Click:Connect(function() SetUltraRun(not ultraRunActive) end)
NoclipBtn.MouseButton1Click:Connect(function() SetNoclip(not noclipActive) end)
UndieBtn.MouseButton1Click:Connect(function() SetUndie(not undieActive) end)
UnvoidBtn.MouseButton1Click:Connect(function() SetUnvoid(not unvoidActive) end)
InfStabBtn.MouseButton1Click:Connect(function() SetChaosLag(not infStabActive) end)
CFrameSpeedBtn.MouseButton1Click:Connect(function() SetCFSpeed(not cfSpeedActive) end)
SpinBtn.MouseButton1Click:Connect(function() SetSpin(not spinActive) end)
WsBtn.MouseButton1Click:Connect(applyWS) JpBtn.MouseButton1Click:Connect(applyJP) GravBtn.MouseButton1Click:Connect(applyGrav)

-- ==================== SAVE / LOAD LOGIC ====================
local lagChain = {{anchor = 0.2, free = 0.1}}

GenSaveBtn.MouseButton1Click:Connect(function()
    local tgs = string.format("%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d", espActive and 1 or 0, ultraRunActive and 1 or 0, noclipActive and 1 or 0, invisActive and 1 or 0, undieActive and 1 or 0, flying and 1 or 0, platActive and 1 or 0, unvoidActive and 1 or 0, infStabActive and 1 or 0, cfSpeedActive and 1 or 0, spinActive and 1 or 0, fpsActive and 1 or 0, pingActive and 1 or 0, aimbotActive and 1 or 0, antiAfkActive and 1 or 0)
    local orderData = {} for i, ob in ipairs(OrderBoxes) do table.insert(orderData, tostring(ob.btn.LayoutOrder)) end
    local tabsOrderStr = table.concat(orderData, ",")
    local lagStr = "" for i, l in ipairs(lagChain) do lagStr = lagStr .. tostring(l.anchor) .. ":" .. tostring(l.free) .. (i == #lagChain and "" or ",") end
    local rawStr = string.format("%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s", currentTheme, ShrinkBox.Text, AfkBox.Text, WsBox.Text, JpBox.Text, GravBox.Text, CFrameSpeedBox.Text, SpinBox.Text, tgs, tabsOrderStr, lagStr)
    local saveCode = "HUB-Save-" .. B64Encode(rawStr)
    local success = pcall(function() setclipboard(saveCode) end)
    if success then GenSaveBtn.Text = "COPIED TO CLIPBOARD!" else GenSaveBtn.Text = "ERROR: CLIPBOARD UNSUPPORTED" end
    task.delay(2, function() GenSaveBtn.Text = "GENERATE SAVE CODE" end)
end)

LoadSaveBtn.MouseButton1Click:Connect(function()
    local str = ImportBox.Text if not str:match("^HUB%-Save%-") then return end
    local p = string.split(B64Decode(str:sub(10)), "|")
    if #p >= 11 then
        SetTheme(p[1]) ShrinkBox.Text = p[2] ApplyShrink() AfkBox.Text = p[3] WsBox.Text = p[4] applyWS() JpBox.Text = p[5] applyJP() GravBox.Text = p[6] applyGrav() CFrameSpeedBox.Text = p[7] SpinBox.Text = p[8]
        local t = p[9]
        SetESP(t:sub(1,1)=="1") SetUltraRun(t:sub(2,2)=="1") SetNoclip(t:sub(3,3)=="1") ToggleInvis(t:sub(4,4)=="1") SetUndie(t:sub(5,5)=="1") SetFly(t:sub(6,6)=="1") TogglePlatform(t:sub(7,7)=="1") SetUnvoid(t:sub(8,8)=="1") SetChaosLag(t:sub(9,9)=="1") SetCFSpeed(t:sub(10,10)=="1") SetSpin(t:sub(11,11)=="1") SetFPS(t:sub(12,12)=="1") SetPing(t:sub(13,13)=="1")
        if #t >= 15 then SetAimbot(t:sub(14,14)=="1") SetAntiAfk(t:sub(15,15)=="1") end
        local tOrd = string.split(p[10], ",") for i, v in ipairs(tOrd) do if OrderBoxes[i] then OrderBoxes[i].box.Text = v end end ApplyTabOrders()
        lagChain = {} if p[11] ~= "" then for _, pr in ipairs(string.split(p[11], ",")) do local vals = string.split(pr, ":") table.insert(lagChain, {anchor=tonumber(vals[1]) or 0.2, free=tonumber(vals[2]) or 0.1}) end else lagChain = {{anchor=0.2, free=0.1}} end
        updateLagList() ImportBox.Text = "" ImportBox.PlaceholderText = "SUCCESSFULLY LOADED!" task.delay(2, function() ImportBox.PlaceholderText = "PASTE HUB-Save-... CODE HERE" end)
    end
end)

-- ==================== ANTI AFK HOOK ====================
AddServiceConn(LocalPlayer.Idled:Connect(function()
    if antiAfkActive then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end))

-- ==================== INVISIBILITY & PLATFORM & FLY ====================
local realChar, fakeChar, isStriking, platPart, platFails, platFailTime = nil, nil, false, nil, 0, 0

ToggleInvis = function(state)
    if invisActive == state then return end invisActive = state
    ApplyToggleStyle(InvisBtn, invisActive, Color3.fromRGB(200, 0, 255)) InvisBtn.Text = "INVISIBILITY (GHOST): " .. (invisActive and "ON" or "OFF")
    if invisActive then
        realChar = LocalPlayer.Character
        if realChar then
            realChar.Archivable = true fakeChar = realChar:Clone() fakeChar.Name = realChar.Name fakeChar.Parent = workspace LocalPlayer.Character = fakeChar workspace.CurrentCamera.CameraSubject = fakeChar:FindFirstChild("Humanoid")
            local fAnim = fakeChar:FindFirstChild("Animate") if fAnim then fAnim.Disabled = true task.delay(0.1, function() fAnim.Disabled = false end) end
            local rHrp = realChar:FindFirstChild("HumanoidRootPart") if rHrp then rHrp.Anchored = false end
            local fHum = fakeChar:FindFirstChild("Humanoid") if fHum then fHum.Died:Connect(function() ToggleInvis(false) LocalPlayer.Character = realChar if realChar:FindFirstChild("Humanoid") then realChar.Humanoid.Health = 0 end end) end
        else ToggleInvis(false) end
    else
        if fakeChar and realChar then
            isStriking = false local fHrp, rHrp = fakeChar:FindFirstChild("HumanoidRootPart"), realChar:FindFirstChild("HumanoidRootPart")
            if rHrp and fHrp then rHrp.CFrame = fHrp.CFrame end
            LocalPlayer.Character = realChar workspace.CurrentCamera.CameraSubject = realChar:FindFirstChild("Humanoid") fakeChar:Destroy() fakeChar = nil
        end
    end
end
InvisBtn.MouseButton1Click:Connect(function() ToggleInvis(not invisActive) end)

TogglePlatform = function(state)
    if platActive == state then return end platActive = state
    ApplyToggleStyle(PlatformBtn, platActive, Color3.fromRGB(0, 150, 255)) PlatformBtn.Text = "PLATFORM: " .. (platActive and "ON" or "OFF") PlatUI.Visible = platActive platFails = 0
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if platActive and hrp then
        platPart = Instance.new("Part") platPart.Size = Vector3.new(6, 1, 6) platPart.Anchored = true platPart.Transparency = 1 platPart.Parent = workspace
        local currentY = hrp.Position.Y - 3.5
        platConn = RunService.RenderStepped:Connect(function()
            local cHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if not cHrp then return end
            if (cHrp.Position.Y - 3.5) > currentY + 0.5 then currentY = cHrp.Position.Y - 3.5 end
            if platDownPressed or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then currentY = currentY - 1 end
            platPart.CFrame = CFrame.new(cHrp.Position.X, currentY, cHrp.Position.Z)
            local diff = currentY - (cHrp.Position.Y - 3.5)
            if diff > 1.5 and not (platDownPressed or UIS:IsKeyDown(Enum.KeyCode.LeftControl)) then
                cHrp.Velocity = Vector3.new(cHrp.Velocity.X, 0, cHrp.Velocity.Z) cHrp.CFrame = CFrame.new(cHrp.Position.X, currentY + 3.5, cHrp.Position.Z)
                local now = tick() if now - platFailTime < 1.5 then platFails = platFails + 1 else platFails = 1 end
                platFailTime = now if platFails > 8 then TogglePlatform(false) end
            end
        end)
    else
        if platPart then platPart:Destroy() end if platConn then platConn:Disconnect() end
    end
end
PlatformBtn.MouseButton1Click:Connect(function() TogglePlatform(not platActive) end)

SetFly = function(state)
    if flying == state then return end flying = state
    ApplyToggleStyle(FlyBtn, flying, Color3.fromRGB(255, 0, 255)) FlyBtn.Text = "FLY: " .. (flying and "ON" or "OFF") FlyUI.Visible = flying
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    if flying then
        local bv = Instance.new("BodyVelocity", hrp) bv.Name = "FlyBV" bv.MaxForce = Vector3.new(9e9, 9e9, 9e9) 
        local bg = Instance.new("BodyGyro", hrp) bg.Name = "FlyBG" bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9) bg.P = 9e4
        hum.PlatformStand = true
        flyConn = RunService.RenderStepped:Connect(function()
            if not hum.Parent or not hrp.Parent then return end
            bg.CFrame = workspace.CurrentCamera.CFrame
            local spd, yMove = tonumber(FlySpeedBox.Text) or 50, 0
            if UIS:IsKeyDown(Enum.KeyCode.Space) or upPressed then yMove = spd end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or downPressed then yMove = -spd end
            bv.Velocity = Vector3.new((hum.MoveDirection * spd).X, yMove, (hum.MoveDirection * spd).Z)
        end)
    else
        if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end
        hum.PlatformStand = false if flyConn then flyConn:Disconnect() end
    end
end
FlyBtn.MouseButton1Click:Connect(function() SetFly(not flying) end)

-- ==================== TARGETING & LOGIC LOOPS ====================
GetClosestPlayerToCursor = function()
    local closestDist = math.huge
    local closestPart = nil
    local mousePos = UIS:GetMouseLocation()
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local targetPart = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if targetPart and hum and hum.Health > 0 then
                local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPart = targetPart
                    end
                end
            end
        end
    end
    return closestPart
end

local function stopInfTp() if infTpConn then infTpConn:Disconnect() infTpConn = nil end currentInfTpTarget = nil end
local function startInfTp(target)
    stopInfTp() currentInfTpTarget = target
    infTpConn = RunService.Heartbeat:Connect(function()
        if not currentInfTpTarget then stopInfTp() return end
        local tCF, valid = nil, false
        if typeof(currentInfTpTarget) == "Instance" then
            local charObj = currentInfTpTarget:IsA("Player") and currentInfTpTarget.Character or currentInfTpTarget
            if charObj and charObj.Parent then
                local tH, tHu = charObj:FindFirstChild("HumanoidRootPart"), charObj:FindFirstChildOfClass("Humanoid")
                if tH and tHu and tHu.Health > 0 then tCF = tH.CFrame * CFrame.new(0, 0, 3) valid = true end
            end
        elseif type(currentInfTpTarget) == "table" then
            if currentInfTpTarget.part and currentInfTpTarget.part.Parent then tCF = currentInfTpTarget.part.CFrame * CFrame.new(0, 3, 0) valid = true
            else tCF = CFrame.new(currentInfTpTarget.pos + Vector3.new(0, 3, 0)) valid = true end
        end
        if valid and tCF then local mH = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if mH then mH.CFrame = tCF end
        else stopInfTp() updatePlayerList() updateNpcList() end
    end)
end

updatePlayerList = function()
    for _, c in pairs(PlayerList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local row = MakeRow(PlayerList) local btn = Instance.new("TextButton", row) btn.Size = UDim2.new(1, 0, 1, 0)
            if listMode == "INF TP" then local act = (currentInfTpTarget == player) btn.Text = player.DisplayName .. (act and " [ON]" or "[OFF]") ApplyStyle(btn, act and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
            else btn.Text = player.DisplayName ApplyStyle(btn, Color3.fromRGB(0, 200, 255)) end
            btn.MouseButton1Click:Connect(function()
                if listMode == "TP" then local pH = player.Character and player.Character:FindFirstChild("HumanoidRootPart") if pH and LocalPlayer.Character.HumanoidRootPart then LocalPlayer.Character.HumanoidRootPart.CFrame = pH.CFrame end
                elseif listMode == "VIEW" then if player.Character and player.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = player.Character.Humanoid end
                elseif listMode == "INF TP" then if currentInfTpTarget == player then stopInfTp() else startInfTp(player) end updatePlayerList() updateNpcList() end
            end)
        end
    end
    if listMode == "TP" or listMode == "VIEW" or listMode == "INF TP" then
        for i, spot in ipairs(savedSpots) do
            local row = MakeRow(PlayerList) local tpBtn = Instance.new("TextButton", row) tpBtn.Size = UDim2.new(0.75, 0, 1, 0)
            local act = (currentInfTpTarget == spot) tpBtn.Text = spot.name .. (act and " [ON]" or " [OFF]") ApplyStyle(tpBtn, act and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 255, 100))
            local delBtn = Instance.new("TextButton", row) delBtn.Size = UDim2.new(0.2, 0, 1, 0) delBtn.Position = UDim2.new(0.8, 0, 0, 0) delBtn.Text = "X" ApplyStyle(delBtn, Color3.fromRGB(255, 0, 0))
            tpBtn.MouseButton1Click:Connect(function()
                if listMode == "TP" then local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.CFrame = spot.part and spot.part.Parent and (spot.part.CFrame * CFrame.new(0, 3, 0)) or CFrame.new(spot.pos + Vector3.new(0, 3, 0)) end
                elseif listMode == "VIEW" then if spot.part and spot.part.Parent then workspace.CurrentCamera.CameraSubject = spot.part end
                elseif listMode == "INF TP" then if currentInfTpTarget == spot then stopInfTp() else startInfTp(spot) end updatePlayerList() end
            end)
            delBtn.MouseButton1Click:Connect(function() if currentInfTpTarget == spot then stopInfTp() end table.remove(savedSpots, i) updatePlayerList() end)
        end
    end
    PerformSearch()
end

updateNpcList = function()
    for _, c in pairs(NpcList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for _, npc in ipairs(cachedNPCs) do
        if npc and npc.Parent then
            local row = MakeRow(NpcList) local btn = Instance.new("TextButton", row) btn.Size = UDim2.new(1, 0, 1, 0)
            local act = (currentInfTpTarget == npc) btn.Text = npc.Name .. (act and " [ON]" or "[OFF]") ApplyStyle(btn, act and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 0))
            btn.MouseButton1Click:Connect(function()
                if npcListMode == "TP" then local hrp = npc:FindFirstChild("HumanoidRootPart") if hrp and LocalPlayer.Character.HumanoidRootPart then LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3) end
                elseif npcListMode == "VIEW" then local hum = npc:FindFirstChildOfClass("Humanoid") if hum then workspace.CurrentCamera.CameraSubject = hum end
                elseif npcListMode == "INF TP" then if currentInfTpTarget == npc then stopInfTp() else startInfTp(npc) end updateNpcList() updatePlayerList() end
            end)
        end
    end
    PerformSearch()
end

ModeBtn.MouseButton1Click:Connect(function() listMode = (listMode == "TP" and "VIEW" or (listMode == "VIEW" and "INF TP" or "TP")) ModeBtn.Text = "LIST MODE: " .. listMode updatePlayerList() end)
NpcModeBtn.MouseButton1Click:Connect(function() npcListMode = (npcListMode == "TP" and "VIEW" or (npcListMode == "VIEW" and "INF TP" or "TP")) NpcModeBtn.Text = "LIST MODE: " .. npcListMode updateNpcList() end)
NpcRefreshBtn.MouseButton1Click:Connect(function() cachedNPCs = {} NpcRefreshBtn.Text = "SCANNING..." task.wait(0.1) for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("Model") and obj ~= LocalPlayer.Character and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then table.insert(cachedNPCs, obj) end end NpcRefreshBtn.Text = "REFRESH NPCs" updateNpcList() end)

local waitingForClick, mouse = false, LocalPlayer:GetMouse()
AddTpBtn.MouseButton1Click:Connect(function() waitingForClick = true AddTpBtn.Text = "CLICK SCREEN..." end)
AddServiceConn(mouse.Button1Down:Connect(function() if waitingForClick then waitingForClick = false AddTpBtn.Text = "ADD CUSTOM TP PART" spotCount = spotCount + 1 table.insert(savedSpots, {name = mouse.Target and ("[" .. mouse.Target.Name .. "]") or ("SPOT " .. spotCount), part = mouse.Target, pos = mouse.Hit.Position}) updatePlayerList() end end))

updateLagList = function()
    for _, c in pairs(LagList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for i, preset in ipairs(lagChain) do
        local row = MakeRow(LagList)
        local aBox = Instance.new("TextBox", row) aBox.Size = UDim2.new(0.38, 0, 1, 0) aBox.Text = tostring(preset.anchor) ApplyStyle(aBox, Color3.fromRGB(255, 0, 150))
        local fBox = Instance.new("TextBox", row) fBox.Size = UDim2.new(0.38, 0, 1, 0) fBox.Position = UDim2.new(0.42, 0, 0, 0) fBox.Text = tostring(preset.free) ApplyStyle(fBox, Color3.fromRGB(0, 255, 150))
        local dBtn = Instance.new("TextButton", row) dBtn.Size = UDim2.new(0.16, 0, 1, 0) dBtn.Position = UDim2.new(0.84, 0, 0, 0) dBtn.Text = "-" ApplyStyle(dBtn, Color3.fromRGB(255, 0, 0))
        aBox.FocusLost:Connect(function() preset.anchor = math.max(0, tonumber(aBox.Text) or preset.anchor) aBox.Text = tostring(preset.anchor) end)
        fBox.FocusLost:Connect(function() preset.free = math.max(0, tonumber(fBox.Text) or preset.free) fBox.Text = tostring(preset.free) end)
        dBtn.MouseButton1Click:Connect(function() table.remove(lagChain, i) updateLagList() end)
    end
    PerformSearch()
end
AddLagBtn.MouseButton1Click:Connect(function() table.insert(lagChain, {anchor = 0.2, free = 0.1}) updateLagList() end)

AntiFlingBtn.MouseButton1Click:Connect(function() local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero hrp.Anchored = true task.wait(0.5) if hrp then hrp.Anchored = false end end end)

-- ==================== CENTRALIZED LOOPS ====================
local fpsTimer, frames = 0, 0
AddServiceConn(RunService.Heartbeat:Connect(function(dt)
    frames = frames + 1 fpsTimer = fpsTimer + dt
    if fpsTimer >= 1 then if fpsActive then FpsLbl.Text = "FPS: " .. frames end frames, fpsTimer = 0, 0 end
    if pingActive then PingLbl.Text = "PING: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. " ms" end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if undieActive and not invisActive and hum and hum.Health > 0 and hum.Health <= (hum.MaxHealth * 0.25) then ToggleInvis(true) end
    if unvoidActive and not platActive and hrp then if hrp.Position.Y < (workspace.FallenPartsDestroyHeight + 100) then TogglePlatform(true) hrp.Velocity = Vector3.new(0, 50, 0) end end

    if hrp and hum and hum.Health > 0 then
        if cfSpeedActive and hum.MoveDirection.Magnitude > 0 then hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (tonumber(CFrameSpeedBox.Text) or 2) * dt * 60) end
        if spinActive then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad((tonumber(SpinBox.Text) or 50) * dt * 60), 0) end
    end

    if infStabActive and hrp and hum and hum.Health > 0 then
        local cur = (#lagChain > 0) and lagChain[lagIndex > #lagChain and 1 or lagIndex] or {anchor = 0.2, free = 0.1}
        if lagIndex > #lagChain then lagIndex = 1 end
        lagTimer = lagTimer - dt
        if lagTimer <= 0 then
            if lagState == "FREE" then lagState = "LAG" lagTimer = cur.anchor hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero hrp.Anchored = true
            else lagState = "FREE" lagTimer = cur.free hrp.Anchored = false lagIndex = lagIndex + 1 end
        else
            if lagState == "LAG" then hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero hrp.Anchored = true else hrp.Anchored = false end
        end
    end
end))

AddServiceConn(RunService.RenderStepped:Connect(function()
    -- Aimbot Camera Update Hook
    if aimbotActive and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetPart = GetClosestPlayerToCursor()
        if targetPart then
            workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, targetPart.Position)
        end
    end
end))

AddServiceConn(RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if ultraRunActive and hum then for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(2.5) end end
    if noclipActive and char then for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end end

    if invisActive and realChar and fakeChar then
        local rHrp, fHrp = realChar:FindFirstChild("HumanoidRootPart"), fakeChar:FindFirstChild("HumanoidRootPart")
        if rHrp and fHrp and not isStriking then rHrp.CFrame = fHrp.CFrame * CFrame.new(0, 500, 0) rHrp.Velocity = Vector3.zero rHrp.RotVelocity = Vector3.zero end
        local fTool, rHum = fakeChar:FindFirstChildOfClass("Tool"), realChar:FindFirstChildOfClass("Humanoid")
        if fTool and rHum then local rTool = LocalPlayer.Backpack:FindFirstChild(fTool.Name) if rTool then rHum:EquipTool(rTool) end elseif not fTool and rHum then rHum:UnequipTools() end
    end
end))

AddServiceConn(UIS.InputBegan:Connect(function(input, gpe)
    if invisActive and realChar and fakeChar and input.UserInputType == Enum.UserInputType.MouseButton1 and not gpe then
        isStriking = true local rHrp, fHrp = realChar:FindFirstChild("HumanoidRootPart"), fakeChar:FindFirstChild("HumanoidRootPart")
        if rHrp and fHrp then rHrp.CFrame = fHrp.CFrame end task.delay(0.1, function() isStriking = false end)
    end
end))

local function applyESP(char)
    if not espActive then return end task.wait(0.5)
    if char and char.Parent and not char:FindFirstChild("LuxuryESP") then local hl = Instance.new("Highlight", char) hl.Name = "LuxuryESP" hl.FillColor = Color3.fromRGB(0, 255, 255) hl.OutlineColor = Color3.fromRGB(255, 0, 255) end
end
AddServiceConn(Players.PlayerAdded:Connect(function(p) AddServiceConn(p.CharacterAdded:Connect(applyESP)) updatePlayerList() end))
AddServiceConn(Players.PlayerRemoving:Connect(updatePlayerList))
for _, p in pairs(Players:GetPlayers()) do AddServiceConn(p.CharacterAdded:Connect(applyESP)) end

local lastActive = tick()
local function checkUIInteraction(input)
    local pos = input.Position
    for _, frame in ipairs({MainFrame, FlyUI, PlatUI}) do
        if frame.Visible then
            local ax, ay, sx, sy = frame.AbsolutePosition.X, frame.AbsolutePosition.Y, frame.AbsoluteSize.X, frame.AbsoluteSize.Y
            if pos.X >= ax and pos.X <= ax + sx and pos.Y >= ay and pos.Y <= ay + sy then lastActive = tick() end
        end
    end
end
AddServiceConn(UIS.InputBegan:Connect(checkUIInteraction))
AddServiceConn(UIS.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then checkUIInteraction(input) end end))

local function ForceCleanup()
    SetESP(false) SetUltraRun(false) SetNoclip(false) SetChaosLag(false) SetSpin(false) SetCFSpeed(false) SetFly(false) TogglePlatform(false) ToggleInvis(false) SetAimbot(false) SetAntiAfk(false)
    undieActive, unvoidActive = false, false if FlyUI then FlyUI.Visible = false end if PlatUI then PlatUI.Visible = false end
    stopInfTp() workspace.Gravity = 196.2
    
    local char = LocalPlayer.Character local hum = char and char:FindFirstChild("Humanoid") local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end hrp.Anchored = false end
    if hum then hum.PlatformStand = false hum.WalkSpeed = 16 hum.UseJumpPower = true hum.JumpPower = 50 for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:AdjustSpeed(1) end workspace.CurrentCamera.CameraSubject = hum end
    
    for _, conn in ipairs(ServiceConnections) do if conn.Connected then conn:Disconnect() end end
    for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("LuxuryESP") then p.Character.LuxuryESP:Destroy() end end
end

task.spawn(function()
    while task.wait(1) do
        if not ScreenGui.Parent then break end
        if tick() - lastActive > (tonumber(AfkBox.Text) or 9999) then ForceCleanup() ScreenGui:Destroy() break end
    end
end)

UnviewBtn.MouseButton1Click:Connect(function() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if hum then workspace.CurrentCamera.CameraSubject = hum end end)
CloseBtn.MouseButton1Click:Connect(function() ForceCleanup() ScreenGui:Destroy() end)

updatePlayerList() updateLagList()
