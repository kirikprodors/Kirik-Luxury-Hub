-- Wait for LocalPlayer to safely initialize (Crucial for mobile loadstring execution)
local Players = game:GetService("Players")
while not Players.LocalPlayer do
    task.wait()
end
local LocalPlayer = Players.LocalPlayer

local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TS = game:GetService("TweenService")

-- Safe VirtualUser fetch
local VirtualUser = nil
pcall(function()
    VirtualUser = game:GetService("VirtualUser")
end)

-- ==================== GLOBAL REGISTRY ====================
local ServiceConnections = {}
local function AddServiceConn(conn)
    table.insert(ServiceConnections, conn)
    return conn
end

-- ==================== OLD THREAD CLEANUP ====================
local function CleanOldInstances()
    pcall(function()
        local cg = game:GetService("CoreGui")
        local old = cg:FindFirstChild("KirikLuxuryHub")
        if old then old:Destroy() end
    end)
    pcall(function()
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then
            local old = pg:FindFirstChild("KirikLuxuryHub")
            if old then old:Destroy() end
        end
    end)
end
CleanOldInstances()

-- ==================== POLYMORPHIC CLIPBOARD WRAPPER ====================
local function setClipboardSafely(text)
    local setclip = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    if setclip then
        local success = pcall(function() setclip(text) end)
        return success and "copied" or "failed"
    else
        print("\n=== [KIRIK HUB SAVE CODE] ===")
        print(text)
        print("==============================\n")
        return "studio"
    end
end

-- ==================== INITIALIZE STATE VARIABLES ====================
local espActive, ultraRunActive, noclipActive = false, false, false
local invisActive, undieActive, platActive, unvoidActive = false, false, false, false
local flying, infStabActive, cfSpeedActive, spinActive = false, false, false, false
local fpsActive, pingActive = false, false
local aimbotActive, antiAfkActive = false, false
local infJumpActive, clickTpActive = false, false

local upPressed, downPressed, platDownPressed = false, false, false
local aimTarget = nil 
local isStriking = false
local currentTpTween = nil

local listMode, npcListMode = "TP", "TP"
local cachedNPCs, savedSpots = {}, {}
local spotCount = 0
local lagState, lagTimer, lagIndex = "FREE", 0, 1
local lagChain = {{anchor = 0.2, free = 0.1}}
local currentInfTpTarget, infTpConn, flyConn, platConn = nil, nil, nil, nil
local realChar, fakeChar, platPart = nil, nil, nil
local platFails, platFailTime = 0, 0

-- ==================== FORWARD DECLARATIONS (STRICT MODE SECURITY) ====================
local AimbotBtn, EspBtn, ModeBtn, AddTpBtn, PlayerListWrapper, PlayerList
local NpcModeBtn, NpcRefreshBtn, NpcListWrapper, NpcList
local InvisBtn, UndieBtn, InfJumpBtn, ClickTpBtn, WsBtn, WsBox, JpBtn, JpBox, GravBtn, GravBox
local CFrameSpeedBtn, CFrameSpeedBox, SpinBtn, SpinBox, UltraRunBtn, NoclipBtn, UnviewBtn
local FlyRow, FlyBtn, FlySpeedBox, PlatformBtn, UnvoidBtn
local AntiFlingBtn, InfStabBtn, AddLagBtn, LagListWrapper, LagList
local ShrinkRow, ShrinkLbl, ShrinkBox, AfkRow, AfkLbl, AfkBox
local AntiAfkBtn, FpsBtn, PingBtn, ThemeLblRow, ThemeLbl, NeonBtn, HackerBtn, BWBtn
local SaveHeaderRow, SaveHeaderLbl, GenSaveBtn, ImportBoxRow, ImportBox, LoadSaveBtn
local TabOrderLblRow, TabOrderLbl, ApplyOrderBtn
local FpsLbl, PingLbl, StatsFrame, StatsLayout, MainScaler, FlyScaler, PlatScaler, FlyUI, PlatUI
local FlyUpBtn, FlyDownBtn, PlatDownBtn
local MainFrame, Sidebar, TabContainer, SearchBox, SideLayout
local DragHandle, Title, MinBtn, CloseBtn, WelcomeText, HomeTab, PlayersTab, NpcsTab
local CharTab, CharScroll, FlyTab, FlyScroll, LagTab, SettingsTab, SettingsScroll
local PTopLayout, NTopLayout, LagTopLayout

local OrderBoxes = {}
local tabs, tabBtns = {}, {}

local ToggleInvis, TogglePlatform, SetFly, SetUltraRun, SetNoclip, SetUndie, SetUnvoid
local SetChaosLag, SetCFSpeed, SetSpin, SetESP, SetAimbot, SetAntiAfk
local SetInfJump, SetClickTp
local ApplyShrink, PerformSearch, GetClosestPlayerToCursor
local updateLagList, updatePlayerList, updateNpcList

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

-- ==================== THEME SYSTEM ====================
local currentTheme = "NEON"
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikLuxuryHub"
ScreenGui.ResetOnSpawn = false

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
    if stroke then TS:Create(stroke, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {Color = targetStroke}):Play() end
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
        if inst:IsA("TextBox") then
            if inst.Text == "TextBox" or inst.Text == "" then inst.Text = "" end
        end
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
    if not btn then return end
    btn:SetAttribute("NeonStroke", state and Color3.fromRGB(0, 255, 0) or defColor)
    UpdateInstanceTheme(btn)
end

-- ==================== UI HELPERS ====================
local function MakeRow(parent, height)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -5, 0, height or 25)
    row.BackgroundTransparency = 1
    return row
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

local function MakeCharStat(name, defaultVal, placeholder, parentContainer)
    local row = MakeRow(parentContainer)
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

local function HookMobileBtn(btn, stateVarName)
    btn.InputBegan:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then 
            if stateVarName == "up" then upPressed = true 
            elseif stateVarName == "down" then downPressed = true 
            else platDownPressed = true end 
        end 
    end)
    btn.InputEnded:Connect(function(i) 
        if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then 
            if stateVarName == "up" then upPressed = false 
            elseif stateVarName == "down" then downPressed = false 
            else platDownPressed = false end 
        end 
    end)
end

-- ==================== MAIN GUI CONSTRUCTION ====================
MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
MainFrame.Size = UDim2.new(0, 450, 0, 300) 
MainFrame.Active = true
MainFrame.ClipsDescendants = true
ApplyStyle(MainFrame, Color3.fromRGB(255, 0, 255), Color3.fromRGB(10, 5, 15))

MainScaler = Instance.new("UIScale", MainFrame)
MainScaler.Scale = 1

StatsFrame = Instance.new("Frame", ScreenGui)
StatsFrame.Position = UDim2.new(1, -120, 0, 10)
StatsFrame.Size = UDim2.new(0, 110, 0, 50)
StatsFrame.Visible = false
ApplyStyle(StatsFrame, Color3.fromRGB(0, 255, 255), Color3.fromRGB(10, 5, 15))

StatsLayout = Instance.new("UIListLayout", StatsFrame)
StatsLayout.Padding = UDim.new(0, 4)
StatsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
StatsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

PingLbl = Instance.new("TextLabel", StatsFrame)
PingLbl.Size = UDim2.new(1, -10, 0.45, 0)
PingLbl.Text = "PING: 0 ms"
PingLbl.BackgroundTransparency = 1
PingLbl.Visible = false
ApplyStyle(PingLbl, Color3.fromRGB(255, 150, 0))

FpsLbl = Instance.new("TextLabel", StatsFrame)
FpsLbl.Size = UDim2.new(1, -10, 0.45, 0)
FpsLbl.Text = "FPS: 0"
FpsLbl.BackgroundTransparency = 1
FpsLbl.Visible = false
ApplyStyle(FpsLbl, Color3.fromRGB(0, 255, 100))

-- Dragging Logic (Fixed reliable events for mobile)
DragHandle = Instance.new("Frame")
DragHandle.Size = UDim2.new(1, -50, 0, 25)
DragHandle.BackgroundTransparency = 1
DragHandle.Parent = MainFrame

local dragging = false
local dragInput, dragStart, startPos

AddServiceConn(DragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true 
        dragStart = input.Position 
        startPos = MainFrame.Position
    end
end))

AddServiceConn(UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end))

AddServiceConn(DragHandle.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
        dragInput = input 
    end
end))

AddServiceConn(UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (delta.X / MainScaler.Scale), startPos.Y.Scale, startPos.Y.Offset + (delta.Y / MainScaler.Scale))
    end
end))

Title = Instance.new("TextLabel")
Title.Text = "KIRIK HUB V51"
Title.Size = UDim2.new(1, -60, 0, 25)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.TextXAlignment = Enum.TextXAlignment.Left
ApplyStyle(Title, Color3.fromRGB(255, 0, 255))
Title.BackgroundTransparency = 1
Title.Parent = MainFrame

MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 20, 0, 20)
MinBtn.Position = UDim2.new(1, -50, 0, 3)
ApplyStyle(MinBtn, Color3.fromRGB(255, 255, 0))
MinBtn.Parent = MainFrame

CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -25, 0, 3)
ApplyStyle(CloseBtn, Color3.fromRGB(255, 0, 0))
CloseBtn.Parent = MainFrame

Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 110, 1, -35)
Sidebar.Position = UDim2.new(0, 5, 0, 30)
Sidebar.BackgroundTransparency = 1
SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

SearchBox = Instance.new("TextBox", Sidebar)
SearchBox.Size = UDim2.new(1, 0, 0, 25)
SearchBox.PlaceholderText = "SEARCH..."
SearchBox.Text = "" 
SearchBox.LayoutOrder = -1
ApplyStyle(SearchBox, Color3.fromRGB(255, 255, 255), Color3.fromRGB(20, 20, 30))

TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, -125, 1, -35)
TabContainer.Position = UDim2.new(0, 120, 0, 30)
TabContainer.BackgroundTransparency = 1

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

-- ==================== UI CONSTRUCTION (TABS) ====================
HomeTab = MakeTab("HOME", true)
WelcomeText = Instance.new("TextLabel", HomeTab)
WelcomeText.Size = UDim2.new(1, 0, 1, 0)
WelcomeText.Text = "KIRIK HUB V51\n\n[ V51 FEATURES ]\n- Infinite Jump & Animated Click-TP\n- Aimbot Toggle (Smooth Tracking)\n- Enhanced ESP (Live Stud Distance)\n- Anti-AFK & Extreme Lag Options"
WelcomeText.TextWrapped = true
WelcomeText.TextYAlignment = Enum.TextYAlignment.Top
ApplyStyle(WelcomeText, Color3.fromRGB(0, 255, 255), Color3.fromRGB(15, 15, 20))

PlayersTab = MakeTab("PLAYERS", false)
PTopLayout = Instance.new("UIListLayout", PlayersTab) PTopLayout.Padding = UDim.new(0, 5)
AimbotBtn = Instance.new("TextButton", MakeRow(PlayersTab)) AimbotBtn.Size = UDim2.new(1, 0, 1, 0) AimbotBtn.Text = "AIMBOT: OFF" ApplyStyle(AimbotBtn, Color3.fromRGB(255, 50, 50))
EspBtn = Instance.new("TextButton", MakeRow(PlayersTab)) EspBtn.Size = UDim2.new(1, 0, 1, 0) EspBtn.Text = "ESP: OFF" ApplyStyle(EspBtn, Color3.fromRGB(0, 255, 100))
ModeBtn = Instance.new("TextButton", MakeRow(PlayersTab)) ModeBtn.Size = UDim2.new(1, 0, 1, 0) ModeBtn.Text = "LIST MODE: TP" ApplyStyle(ModeBtn, Color3.fromRGB(255, 0, 255))
AddTpBtn = Instance.new("TextButton", MakeRow(PlayersTab)) AddTpBtn.Size = UDim2.new(1, 0, 1, 0) AddTpBtn.Text = "ADD CUSTOM TP PART" ApplyStyle(AddTpBtn, Color3.fromRGB(0, 150, 255))
PlayerListWrapper = Instance.new("Frame", PlayersTab) PlayerListWrapper.Size = UDim2.new(1, 0, 1, -125) PlayerListWrapper.BackgroundTransparency = 1
PlayerList, _ = MakeScrollArea(PlayerListWrapper)

NpcsTab = MakeTab("NPCs", false)
NTopLayout = Instance.new("UIListLayout", NpcsTab) NTopLayout.Padding = UDim.new(0, 5)
NpcModeBtn = Instance.new("TextButton", MakeRow(NpcsTab)) NpcModeBtn.Size = UDim2.new(1, 0, 1, 0) NpcModeBtn.Text = "LIST MODE: TP" ApplyStyle(NpcModeBtn, Color3.fromRGB(255, 0, 255))
NpcRefreshBtn = Instance.new("TextButton", MakeRow(NpcsTab)) NpcRefreshBtn.Size = UDim2.new(1, 0, 1, 0) NpcRefreshBtn.Text = "REFRESH NPCs" ApplyStyle(NpcRefreshBtn, Color3.fromRGB(0, 255, 100))
NpcListWrapper = Instance.new("Frame", NpcsTab) NpcListWrapper.Size = UDim2.new(1, 0, 1, -65) NpcListWrapper.BackgroundTransparency = 1
NpcList, _ = MakeScrollArea(NpcListWrapper)

CharTab = MakeTab("CHARACTER", false)
CharScroll, _ = MakeScrollArea(CharTab)
InvisBtn = Instance.new("TextButton", MakeRow(CharScroll)) InvisBtn.Size = UDim2.new(1, 0, 1, 0) InvisBtn.Text = "INVISIBILITY (GHOST): OFF" ApplyStyle(InvisBtn, Color3.fromRGB(200, 0, 255))
UndieBtn = Instance.new("TextButton", MakeRow(CharScroll)) UndieBtn.Size = UDim2.new(1, 0, 1, 0) UndieBtn.Text = "UN-DIE: OFF" ApplyStyle(UndieBtn, Color3.fromRGB(200, 50, 50))
InfJumpBtn = Instance.new("TextButton", MakeRow(CharScroll)) InfJumpBtn.Size = UDim2.new(1, 0, 1, 0) InfJumpBtn.Text = "INFINITE JUMP: OFF" ApplyStyle(InfJumpBtn, Color3.fromRGB(0, 255, 150))
ClickTpBtn = Instance.new("TextButton", MakeRow(CharScroll)) ClickTpBtn.Size = UDim2.new(1, 0, 1, 0) ClickTpBtn.Text = "CLICK TELEPORT: OFF" ApplyStyle(ClickTpBtn, Color3.fromRGB(255, 150, 0))

WsBtn, WsBox = MakeCharStat("SPEED", 16, "WS", CharScroll)
JpBtn, JpBox = MakeCharStat("JUMP", 50, "JP", CharScroll)
GravBtn, GravBox = MakeCharStat("GRAVITY", 196.2, "GR", CharScroll)
CFrameSpeedBtn, CFrameSpeedBox = MakeCharStat("CF SPEED", 2, "Spd", CharScroll)
SpinBtn, SpinBox = MakeCharStat("SPIN", 50, "Spd", CharScroll)

UltraRunBtn = Instance.new("TextButton", MakeRow(CharScroll)) UltraRunBtn.Size = UDim2.new(1, 0, 1, 0) UltraRunBtn.Text = "ULTRA RUN: OFF" ApplyStyle(UltraRunBtn, Color3.fromRGB(255, 80, 0))
NoclipBtn = Instance.new("TextButton", MakeRow(CharScroll)) NoclipBtn.Size = UDim2.new(1, 0, 1, 0) NoclipBtn.Text = "NOCLIP: OFF" ApplyStyle(NoclipBtn, Color3.fromRGB(0, 255, 200))
UnviewBtn = Instance.new("TextButton", MakeRow(CharScroll)) UnviewBtn.Size = UDim2.new(1, 0, 1, 0) UnviewBtn.Text = "RESET CAMERA" ApplyStyle(UnviewBtn, Color3.fromRGB(150, 150, 255))

FlyTab = MakeTab("FLIGHT", false)
FlyScroll, _ = MakeScrollArea(FlyTab)
FlyRow = MakeRow(FlyScroll)
FlyBtn = Instance.new("TextButton", FlyRow) FlyBtn.Size = UDim2.new(0.65, 0, 1, 0) FlyBtn.Text = "FLY: OFF" ApplyStyle(FlyBtn, Color3.fromRGB(255, 0, 255))
FlySpeedBox = Instance.new("TextBox", FlyRow) FlySpeedBox.Size = UDim2.new(0.33, 0, 1, 0) FlySpeedBox.Position = UDim2.new(0.67, 0, 0, 0) FlySpeedBox.Text = "50" ApplyStyle(FlySpeedBox, Color3.fromRGB(255, 0, 255))
PlatformBtn = Instance.new("TextButton", MakeRow(FlyScroll)) PlatformBtn.Size = UDim2.new(1, 0, 1, 0) PlatformBtn.Text = "PLATFORM: OFF" ApplyStyle(PlatformBtn, Color3.fromRGB(0, 150, 255))
UnvoidBtn = Instance.new("TextButton", MakeRow(FlyScroll)) UnvoidBtn.Size = UDim2.new(1, 0, 1, 0) UnvoidBtn.Text = "UN-VOID: OFF" ApplyStyle(UnvoidBtn, Color3.fromRGB(50, 50, 255))

LagTab = MakeTab("LAG", false)
LagTopLayout = Instance.new("UIListLayout", LagTab) LagTopLayout.Padding = UDim.new(0, 5)
AntiFlingBtn = Instance.new("TextButton", MakeRow(LagTab)) AntiFlingBtn.Size = UDim2.new(1, 0, 1, 0) AntiFlingBtn.Text = "STAB (QUICK ANCHOR)" ApplyStyle(AntiFlingBtn, Color3.fromRGB(255, 50, 50))
InfStabBtn = Instance.new("TextButton", MakeRow(LagTab)) InfStabBtn.Size = UDim2.new(1, 0, 1, 0) InfStabBtn.Text = "CHAOS LAG: OFF" ApplyStyle(InfStabBtn, Color3.fromRGB(255, 150, 0))
AddLagBtn = Instance.new("TextButton", MakeRow(LagTab)) AddLagBtn.Size = UDim2.new(1, 0, 1, 0) AddLagBtn.Text = "+ ADD NEW LAG TO CHAIN" ApplyStyle(AddLagBtn, Color3.fromRGB(0, 255, 0))
LagListWrapper = Instance.new("Frame", LagTab) LagListWrapper.Size = UDim2.new(1, 0, 1, -95) LagListWrapper.BackgroundTransparency = 1
LagList, _ = MakeScrollArea(LagListWrapper)

SettingsTab = MakeTab("SETTINGS", false)
SettingsScroll, _ = MakeScrollArea(SettingsTab)

ShrinkRow = MakeRow(SettingsScroll) ShrinkRow.LayoutOrder = 1
ShrinkLbl = Instance.new("TextLabel", ShrinkRow) ShrinkLbl.Size = UDim2.new(0.65, 0, 1, 0) ShrinkLbl.Text = "SHRINK UI (Ex: 2 = 2x smaller)" ApplyStyle(ShrinkLbl, Color3.fromRGB(255, 255, 0))
ShrinkBox = Instance.new("TextBox", ShrinkRow) ShrinkBox.Size = UDim2.new(0.33, 0, 1, 0) ShrinkBox.Position = UDim2.new(0.67, 0, 0, 0) ShrinkBox.Text = "1" ApplyStyle(ShrinkBox, Color3.fromRGB(255, 255, 0))

AfkRow = MakeRow(SettingsScroll) AfkRow.LayoutOrder = 2
AfkLbl = Instance.new("TextLabel", AfkRow) AfkLbl.Size = UDim2.new(0.65, 0, 1, 0) AfkLbl.Text = "UI AUTOCLOSE (SEC)" ApplyStyle(AfkLbl, Color3.fromRGB(150, 150, 150))
AfkBox = Instance.new("TextBox", AfkRow) AfkBox.Size = UDim2.new(0.33, 0, 1, 0) AfkBox.Position = UDim2.new(0.67, 0, 0, 0) AfkBox.Text = "9999" ApplyStyle(AfkBox, Color3.fromRGB(150, 150, 150))

AntiAfkBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) AntiAfkBtn.Parent.LayoutOrder = 3 AntiAfkBtn.Size = UDim2.new(1, 0, 1, 0) AntiAfkBtn.Text = "ROBLOX ANTI-AFK: OFF" ApplyStyle(AntiAfkBtn, Color3.fromRGB(0, 200, 255))
FpsBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) FpsBtn.Parent.LayoutOrder = 4 FpsBtn.Size = UDim2.new(1, 0, 1, 0) FpsBtn.Text = "FPS HUD: OFF" ApplyStyle(FpsBtn, Color3.fromRGB(0, 255, 100))
PingBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) PingBtn.Parent.LayoutOrder = 5 PingBtn.Size = UDim2.new(1, 0, 1, 0) PingBtn.Text = "PING HUD: OFF" ApplyStyle(PingBtn, Color3.fromRGB(255, 150, 0))

ThemeLblRow = MakeRow(SettingsScroll) ThemeLblRow.LayoutOrder = 6
ThemeLbl = Instance.new("TextLabel", ThemeLblRow) ThemeLbl.Size = UDim2.new(1, 0, 1, 0) ThemeLbl.Text = "--- THEMES ---" ApplyStyle(ThemeLbl, Color3.fromRGB(0, 255, 255))
NeonBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) NeonBtn.Parent.LayoutOrder = 7 NeonBtn.Size = UDim2.new(1, 0, 1, 0) NeonBtn.Text = "NEON (DEFAULT)" ApplyStyle(NeonBtn, Color3.fromRGB(255, 0, 255))
HackerBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) HackerBtn.Parent.LayoutOrder = 8 HackerBtn.Size = UDim2.new(1, 0, 1, 0) HackerBtn.Text = "HACKER (GREEN)" ApplyStyle(HackerBtn, Color3.fromRGB(0, 255, 0))
BWBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) BWBtn.Parent.LayoutOrder = 9 BWBtn.Size = UDim2.new(1, 0, 1, 0) BWBtn.Text = "BLACK & WHITE" ApplyStyle(BWBtn, Color3.fromRGB(255, 255, 255))

SaveHeaderRow = MakeRow(SettingsScroll) SaveHeaderRow.LayoutOrder = 10
SaveHeaderLbl = Instance.new("TextLabel", SaveHeaderRow) SaveHeaderLbl.Size = UDim2.new(1, 0, 1, 0) SaveHeaderLbl.Text = "--- SAVE SYSTEM ---" ApplyStyle(SaveHeaderLbl, Color3.fromRGB(0, 255, 150))
GenSaveBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) GenSaveBtn.Parent.LayoutOrder = 11 GenSaveBtn.Size = UDim2.new(1, 0, 1, 0) GenSaveBtn.Text = "GENERATE SAVE CODE" ApplyStyle(GenSaveBtn, Color3.fromRGB(0, 255, 0))
ImportBoxRow = MakeRow(SettingsScroll) ImportBoxRow.LayoutOrder = 12
ImportBox = Instance.new("TextBox", ImportBoxRow) ImportBox.Size = UDim2.new(1, 0, 1, 0) ImportBox.PlaceholderText = "PASTE HUB-Save-... CODE HERE" ImportBox.Text = "" ImportBox.ClearTextOnFocus = false ApplyStyle(ImportBox, Color3.fromRGB(255, 150, 0))
LoadSaveBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) LoadSaveBtn.Parent.LayoutOrder = 13 LoadSaveBtn.Size = UDim2.new(1, 0, 1, 0) LoadSaveBtn.Text = "LOAD SAVE CODE" ApplyStyle(LoadSaveBtn, Color3.fromRGB(255, 0, 0))

TabOrderLblRow = MakeRow(SettingsScroll) TabOrderLblRow.LayoutOrder = 14
TabOrderLbl = Instance.new("TextLabel", TabOrderLblRow) TabOrderLbl.Size = UDim2.new(1, 0, 1, 0) TabOrderLbl.Text = "--- TAB ORDER ---" ApplyStyle(TabOrderLbl, Color3.fromRGB(0, 255, 255))

for i, tBtn in ipairs(tabBtns) do
    local row = MakeRow(SettingsScroll)
    row.LayoutOrder = 20 + i
    local lbl = Instance.new("TextLabel", row) lbl.Size = UDim2.new(0.65, 0, 1, 0) lbl.Text = "TAB: " .. tBtn.Text ApplyStyle(lbl, Color3.fromRGB(255, 100, 0))
    local box = Instance.new("TextBox", row) box.Size = UDim2.new(0.33, 0, 1, 0) box.Position = UDim2.new(0.67, 0, 0, 0) box.Text = tostring(tBtn.LayoutOrder) ApplyStyle(box, Color3.fromRGB(255, 100, 0))
    table.insert(OrderBoxes, {btn = tBtn, box = box, row = row})
end

ApplyOrderBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) ApplyOrderBtn.Parent.LayoutOrder = 100 ApplyOrderBtn.Size = UDim2.new(1, 0, 1, 0) ApplyOrderBtn.Text = "APPLY TAB ORDER" ApplyStyle(ApplyOrderBtn, Color3.fromRGB(0, 255, 0))

-- ==================== FLOATING MOBILE UI ====================
FlyUI = Instance.new("Frame", ScreenGui) FlyUI.Size = UDim2.new(0, 60, 0, 120) FlyUI.Position = UDim2.new(1, -70, 0.5, -60) FlyUI.BackgroundTransparency = 1 FlyUI.Visible = false
FlyScaler = Instance.new("UIScale", FlyUI)
FlyUpBtn = Instance.new("TextButton", FlyUI) FlyUpBtn.Size = UDim2.new(1, 0, 0.45, 0) FlyUpBtn.Text = "UP" ApplyStyle(FlyUpBtn, Color3.fromRGB(0, 255, 255)) FlyUpBtn.BackgroundTransparency = 0.5
FlyDownBtn = Instance.new("TextButton", FlyUI) FlyDownBtn.Size = UDim2.new(1, 0, 0.45, 0) FlyDownBtn.Position = UDim2.new(0, 0, 0.55, 0) FlyDownBtn.Text = "DOWN" ApplyStyle(FlyDownBtn, Color3.fromRGB(0, 255, 255)) FlyDownBtn.BackgroundTransparency = 0.5

PlatUI = Instance.new("Frame", ScreenGui) PlatUI.Size = UDim2.new(0, 60, 0, 50) PlatUI.Position = UDim2.new(1, -70, 0.5, 70) PlatUI.BackgroundTransparency = 1 PlatUI.Visible = false
PlatScaler = Instance.new("UIScale", PlatUI)
PlatDownBtn = Instance.new("TextButton", PlatUI) PlatDownBtn.Size = UDim2.new(1, 0, 1, 0) PlatDownBtn.Text = "DOWN" ApplyStyle(PlatDownBtn, Color3.fromRGB(0, 255, 255)) PlatDownBtn.BackgroundTransparency = 0.5

HookMobileBtn(FlyUpBtn, "up") 
HookMobileBtn(FlyDownBtn, "down") 
HookMobileBtn(PlatDownBtn, "plat")

-- ==================== STATE SETTERS LOGIC IMPLEMENTATION ====================
SetAimbot = function(state) 
    aimbotActive = state 
    aimTarget = nil
    ApplyToggleStyle(AimbotBtn, aimbotActive, Color3.fromRGB(255, 50, 50)) 
    if AimbotBtn then AimbotBtn.Text = "AIMBOT: " .. (aimbotActive and "ON" or "OFF") end
end

SetInfJump = function(state) 
    infJumpActive = state 
    ApplyToggleStyle(InfJumpBtn, infJumpActive, Color3.fromRGB(0, 255, 150)) 
    if InfJumpBtn then InfJumpBtn.Text = "INFINITE JUMP: " .. (infJumpActive and "ON" or "OFF") end
end

SetClickTp = function(state) 
    clickTpActive = state 
    ApplyToggleStyle(ClickTpBtn, clickTpActive, Color3.fromRGB(255, 150, 0)) 
    if ClickTpBtn then ClickTpBtn.Text = "CLICK TELEPORT: " .. (clickTpActive and "ON" or "OFF") end
end

SetAntiAfk = function(state) 
    antiAfkActive = state 
    ApplyToggleStyle(AntiAfkBtn, antiAfkActive, Color3.fromRGB(0, 200, 255)) 
    if AntiAfkBtn then AntiAfkBtn.Text = "ROBLOX ANTI-AFK: " .. (antiAfkActive and "ON" or "OFF") end
end

local function SetFPS(state) 
    fpsActive = state 
    ApplyToggleStyle(FpsBtn, fpsActive, Color3.fromRGB(0, 255, 100)) 
    if FpsBtn then FpsBtn.Text = "FPS HUD: " .. (fpsActive and "ON" or "OFF") end
    if FpsLbl then FpsLbl.Visible = fpsActive end
    if StatsFrame then StatsFrame.Visible = fpsActive or pingActive end
end

local function SetPing(state) 
    pingActive = state 
    ApplyToggleStyle(PingBtn, pingActive, Color3.fromRGB(255, 150, 0)) 
    if PingBtn then PingBtn.Text = "PING HUD: " .. (pingActive and "ON" or "OFF") end
    if PingLbl then PingLbl.Visible = pingActive end
    if StatsFrame then StatsFrame.Visible = fpsActive or pingActive end
end

local function applyESPToPlayer(player)
    if not espActive then return end
    local char = player.Character
    if char and char.Parent then
        if not char:FindFirstChild("LuxuryESP") then 
            local hl = Instance.new("Highlight", char) 
            hl.Name = "LuxuryESP" 
            hl.FillColor = Color3.fromRGB(0, 255, 255) 
            hl.OutlineColor = Color3.fromRGB(255, 0, 255) 
        end
        local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
        if head and not head:FindFirstChild("LuxuryESP_Text") then
            local bgui = Instance.new("BillboardGui", head)
            bgui.Name = "LuxuryESP_Text"
            bgui.Size = UDim2.new(0, 200, 0, 50)
            bgui.StudsOffset = Vector3.new(0, 3, 0)
            bgui.AlwaysOnTop = true
            
            local txt = Instance.new("TextLabel", bgui)
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Text = player.DisplayName
            txt.TextColor3 = Color3.fromRGB(0, 255, 255)
            txt.TextStrokeTransparency = 0
            txt.TextStrokeColor3 = Color3.fromRGB(255, 0, 255)
            txt.Font = Enum.Font.GothamBold
            txt.TextScaled = false
            txt.TextSize = 14
        end
    end
end

SetESP = function(state)
    if espActive == state then return end
    espActive = state 
    ApplyToggleStyle(EspBtn, espActive, Color3.fromRGB(0, 255, 100)) 
    if EspBtn then EspBtn.Text = "ESP: " .. (espActive and "ON" or "OFF") end
    if state then
        for _, p in pairs(Players:GetPlayers()) do 
            if p ~= LocalPlayer then applyESPToPlayer(p) end 
        end 
    else 
        for _, p in pairs(Players:GetPlayers()) do 
            if p.Character then
                local hl = p.Character:FindFirstChild("LuxuryESP")
                if hl then hl:Destroy() end
                local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
                if head then
                    local bgui = head:FindFirstChild("LuxuryESP_Text")
                    if bgui then bgui:Destroy() end
                end
            end 
        end 
    end
end

SetUltraRun = function(state) 
    if ultraRunActive == state then return end 
    ultraRunActive = state 
    ApplyToggleStyle(UltraRunBtn, ultraRunActive, Color3.fromRGB(255, 80, 0)) 
    if UltraRunBtn then UltraRunBtn.Text = "ULTRA RUN: " .. (ultraRunActive and "ON" or "OFF") end
    if not state then 
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") 
        if hum then for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(1) end end 
    end 
end

SetNoclip = function(state) 
    if noclipActive == state then return end 
    noclipActive = state 
    ApplyToggleStyle(NoclipBtn, noclipActive, Color3.fromRGB(0, 255, 200)) 
    if NoclipBtn then NoclipBtn.Text = "NOCLIP: " .. (noclipActive and "ON" or "OFF") end
end

SetUndie = function(state) 
    if undieActive == state then return end 
    undieActive = state 
    ApplyToggleStyle(UndieBtn, undieActive, Color3.fromRGB(200, 50, 50)) 
    if UndieBtn then UndieBtn.Text = "UN-DIE: " .. (undieActive and "ON" or "OFF") end
end

SetUnvoid = function(state) 
    if unvoidActive == state then return end 
    unvoidActive = state 
    ApplyToggleStyle(UnvoidBtn, unvoidActive, Color3.fromRGB(50, 50, 255)) 
    if UnvoidBtn then UnvoidBtn.Text = "UN-VOID: " .. (unvoidActive and "ON" or "OFF") end
end

SetChaosLag = function(state) 
    if infStabActive == state then return end 
    infStabActive = state 
    ApplyToggleStyle(InfStabBtn, infStabActive, Color3.fromRGB(255, 150, 0)) 
    if InfStabBtn then InfStabBtn.Text = "CHAOS LAG: " .. (infStabActive and "ON" or "OFF") end
    if not state then 
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
        if hrp then hrp.Anchored = false hrp.Velocity = Vector3.zero end 
    end 
end

SetCFSpeed = function(state) 
    if cfSpeedActive == state then return end 
    cfSpeedActive = state 
    ApplyToggleStyle(CFrameSpeedBtn, cfSpeedActive, Color3.fromRGB(255, 100, 0)) 
    if CFrameSpeedBtn then CFrameSpeedBtn.Text = "CF SPD: " .. (cfSpeedActive and "ON" or "OFF") end
end

SetSpin = function(state) 
    if spinActive == state then return end 
    spinActive = state 
    ApplyToggleStyle(SpinBtn, spinActive, Color3.fromRGB(0, 255, 50)) 
    if SpinBtn then SpinBtn.Text = "SPIN: " .. (spinActive and "ON" or "OFF") end
end

local function applyWS() 
    if not WsBox then return end
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") 
    if h then h.WalkSpeed = tonumber(WsBox.Text) or 16 end 
end

local function applyJP() 
    if not JpBox then return end
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") 
    if h then h.UseJumpPower = true h.JumpPower = tonumber(JpBox.Text) or 50 end 
end

local function applyGrav() 
    if not GravBox then return end
    pcall(function() workspace.Gravity = tonumber(GravBox.Text) or 196.2 end) 
end

ToggleInvis = function(state)
    if invisActive == state then return end invisActive = state
    ApplyToggleStyle(InvisBtn, invisActive, Color3.fromRGB(200, 0, 255)) 
    if InvisBtn then InvisBtn.Text = "INVISIBILITY (GHOST): " .. (invisActive and "ON" or "OFF") end
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

TogglePlatform = function(state)
    if platActive == state then return end platActive = state
    ApplyToggleStyle(PlatformBtn, platActive, Color3.fromRGB(0, 150, 255)) 
    if PlatformBtn then PlatformBtn.Text = "PLATFORM: " .. (platActive and "ON" or "OFF") end
    if PlatUI then PlatUI.Visible = platActive end
    platFails = 0
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

SetFly = function(state)
    if flying == state then return end flying = state
    ApplyToggleStyle(FlyBtn, flying, Color3.fromRGB(255, 0, 255)) 
    if FlyBtn then FlyBtn.Text = "FLY: " .. (flying and "ON" or "OFF") end
    if FlyUI then FlyUI.Visible = flying end
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
            local spd, yMove = 50, 0
            if FlySpeedBox then spd = tonumber(FlySpeedBox.Text) or 50 end
            if UIS:IsKeyDown(Enum.KeyCode.Space) or upPressed then yMove = spd end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or downPressed then yMove = -spd end
            bv.Velocity = Vector3.new((hum.MoveDirection * spd).X, yMove, (hum.MoveDirection * spd).Z)
        end)
    else
        if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end
        hum.PlatformStand = false if flyConn then flyConn:Disconnect() end
    end
end

GetClosestPlayerToCursor = function()
    local closestDist = math.huge
    local closestPart = nil
    local mousePos = UIS:GetMouseLocation()
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    
    if mousePos == Vector2.new(0, 0) then mousePos = camera.ViewportSize / 2 end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local targetPart = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if targetPart and hum and hum.Health > 0 then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
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
        if valid and tCF then 
            local mChar = LocalPlayer.Character
            local mH = mChar and mChar:FindFirstChild("HumanoidRootPart") 
            if mH then mH.CFrame = tCF end
        else stopInfTp() updatePlayerList() updateNpcList() end
    end)
end

updatePlayerList = function()
    if not PlayerList then return end
    for _, c in pairs(PlayerList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local row = MakeRow(PlayerList) local btn = Instance.new("TextButton", row) btn.Size = UDim2.new(1, 0, 1, 0)
            if listMode == "INF TP" then local act = (currentInfTpTarget == player) btn.Text = player.DisplayName .. (act and " [ON]" or "[OFF]") ApplyStyle(btn, act and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
            else btn.Text = player.DisplayName ApplyStyle(btn, Color3.fromRGB(0, 200, 255)) end
            btn.MouseButton1Click:Connect(function()
                if listMode == "TP" then 
                    local pChar = player.Character
                    local pH = pChar and pChar:FindFirstChild("HumanoidRootPart") 
                    local mChar = LocalPlayer.Character
                    local mHrp = mChar and mChar:FindFirstChild("HumanoidRootPart")
                    if pH and mHrp then mHrp.CFrame = pH.CFrame end
                elseif listMode == "VIEW" then 
                    if player.Character and player.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = player.Character.Humanoid end
                elseif listMode == "INF TP" then 
                    if currentInfTpTarget == player then stopInfTp() else startInfTp(player) end updatePlayerList() updateNpcList() 
                end
            end)
        end
    end
    if listMode == "TP" or listMode == "VIEW" or listMode == "INF TP" then
        for i, spot in ipairs(savedSpots) do
            local row = MakeRow(PlayerList) local tpBtn = Instance.new("TextButton", row) tpBtn.Size = UDim2.new(0.75, 0, 1, 0)
            local act = (currentInfTpTarget == spot) tpBtn.Text = spot.name .. (act and " [ON]" or " [OFF]") ApplyStyle(tpBtn, act and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(0, 255, 100))
            local delBtn = Instance.new("TextButton", row) delBtn.Size = UDim2.new(0.2, 0, 1, 0) delBtn.Position = UDim2.new(0.8, 0, 0, 0) delBtn.Text = "X" ApplyStyle(delBtn, Color3.fromRGB(255, 0, 0))
            tpBtn.MouseButton1Click:Connect(function()
                if listMode == "TP" then 
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") 
                    if hrp then hrp.CFrame = spot.part and spot.part.Parent and (spot.part.CFrame * CFrame.new(0, 3, 0)) or CFrame.new(spot.pos + Vector3.new(0, 3, 0)) end
                elseif listMode == "VIEW" then 
                    if spot.part and spot.part.Parent then workspace.CurrentCamera.CameraSubject = spot.part end
                elseif listMode == "INF TP" then 
                    if currentInfTpTarget == spot then stopInfTp() else startInfTp(spot) end updatePlayerList() 
                end
            end)
            delBtn.MouseButton1Click:Connect(function() if currentInfTpTarget == spot then stopInfTp() end table.remove(savedSpots, i) updatePlayerList() end)
        end
    end
    PerformSearch()
end

updateNpcList = function()
    if not NpcList then return end
    for _, c in pairs(NpcList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for _, npc in ipairs(cachedNPCs) do
        if npc and npc.Parent then
            local row = MakeRow(NpcList) local btn = Instance.new("TextButton", row) btn.Size = UDim2.new(1, 0, 1, 0)
            local act = (currentInfTpTarget == npc) btn.Text = npc.Name .. (act and " [ON]" or "[OFF]") ApplyStyle(btn, act and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 0))
            btn.MouseButton1Click:Connect(function()
                if npcListMode == "TP" then 
                    local hrp = npc:FindFirstChild("HumanoidRootPart") 
                    local mChar = LocalPlayer.Character
                    local mHrp = mChar and mChar:FindFirstChild("HumanoidRootPart")
                    if hrp and mHrp then mHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 3) end
                elseif npcListMode == "VIEW" then 
                    local hum = npc:FindFirstChildOfClass("Humanoid") if hum then workspace.CurrentCamera.CameraSubject = hum end
                elseif npcListMode == "INF TP" then 
                    if currentInfTpTarget == npc then stopInfTp() else startInfTp(npc) end updateNpcList() updatePlayerList() 
                end
            end)
        end
    end
    PerformSearch()
end

updateLagList = function()
    if not LagList then return end
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

ApplyShrink = function()
    if not ShrinkBox or not MainScaler or not FlyScaler or not PlatScaler then return end
    local factor = tonumber(ShrinkBox.Text)
    if factor and factor > 0 then MainScaler.Scale = 1/factor FlyScaler.Scale = 1/factor PlatScaler.Scale = 1/factor
    else ShrinkBox.Text = "1" MainScaler.Scale = 1 FlyScaler.Scale = 1 PlatScaler.Scale = 1 end
end

PerformSearch = function()
    if not SearchBox then return end
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

-- ==================== CENTRAL EVENT BINDINGS ====================
AddServiceConn(SearchBox:GetPropertyChangedSignal("Text"):Connect(function() PerformSearch() end))
ShrinkBox.FocusLost:Connect(function() ApplyShrink() end)

NeonBtn.MouseButton1Click:Connect(function() SetTheme("NEON") end)
HackerBtn.MouseButton1Click:Connect(function() SetTheme("HACKER") end)
BWBtn.MouseButton1Click:Connect(function() SetTheme("B&W") end)

-- All Toggles
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
InvisBtn.MouseButton1Click:Connect(function() ToggleInvis(not invisActive) end)
FlyBtn.MouseButton1Click:Connect(function() SetFly(not flying) end)
PlatformBtn.MouseButton1Click:Connect(function() TogglePlatform(not platActive) end)
InfJumpBtn.MouseButton1Click:Connect(function() SetInfJump(not infJumpActive) end)
ClickTpBtn.MouseButton1Click:Connect(function() SetClickTp(not clickTpActive) end)

WsBtn.MouseButton1Click:Connect(function() applyWS() end) 
JpBtn.MouseButton1Click:Connect(function() applyJP() end) 
GravBtn.MouseButton1Click:Connect(function() applyGrav() end)

ModeBtn.MouseButton1Click:Connect(function() listMode = (listMode == "TP" and "VIEW" or (listMode == "VIEW" and "INF TP" or "TP")) ModeBtn.Text = "LIST MODE: " .. listMode updatePlayerList() end)
NpcModeBtn.MouseButton1Click:Connect(function() npcListMode = (npcListMode == "TP" and "VIEW" or (npcListMode == "VIEW" and "INF TP" or "TP")) NpcModeBtn.Text = "LIST MODE: " .. npcListMode updateNpcList() end)
NpcRefreshBtn.MouseButton1Click:Connect(function() cachedNPCs = {} NpcRefreshBtn.Text = "SCANNING..." task.wait(0.1) for _, obj in ipairs(workspace:GetDescendants()) do if obj:IsA("Model") and obj ~= LocalPlayer.Character and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(obj) then table.insert(cachedNPCs, obj) end end NpcRefreshBtn.Text = "REFRESH NPCs" updateNpcList() end)

local waitingForClick, mouse = false, LocalPlayer:GetMouse()
AddTpBtn.MouseButton1Click:Connect(function() waitingForClick = true AddTpBtn.Text = "CLICK SCREEN..." end)
AddServiceConn(mouse.Button1Down:Connect(function() if waitingForClick then waitingForClick = false AddTpBtn.Text = "ADD CUSTOM TP PART" spotCount = spotCount + 1 table.insert(savedSpots, {name = mouse.Target and ("[" .. mouse.Target.Name .. "]") or ("SPOT " .. spotCount), part = mouse.Target, pos = mouse.Hit.Position}) updatePlayerList() end end))

AddLagBtn.MouseButton1Click:Connect(function() table.insert(lagChain, {anchor = 0.2, free = 0.1}) updateLagList() end)
AntiFlingBtn.MouseButton1Click:Connect(function() local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") if hrp then hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero hrp.Anchored = true task.wait(0.5) if hrp then hrp.Anchored = false end end end)

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

GenSaveBtn.MouseButton1Click:Connect(function()
    local tgs = string.format("%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d", espActive and 1 or 0, ultraRunActive and 1 or 0, noclipActive and 1 or 0, invisActive and 1 or 0, undieActive and 1 or 0, flying and 1 or 0, platActive and 1 or 0, unvoidActive and 1 or 0, infStabActive and 1 or 0, cfSpeedActive and 1 or 0, spinActive and 1 or 0, fpsActive and 1 or 0, pingActive and 1 or 0, aimbotActive and 1 or 0, antiAfkActive and 1 or 0, infJumpActive and 1 or 0, clickTpActive and 1 or 0)
    local orderData = {} for i, ob in ipairs(OrderBoxes) do table.insert(orderData, tostring(ob.btn.LayoutOrder)) end
    local tabsOrderStr = table.concat(orderData, ",")
    local lagStr = "" for i, l in ipairs(lagChain) do lagStr = lagStr .. tostring(l.anchor) .. ":" .. tostring(l.free) .. (i == #lagChain and "" or ",") end
    local rawStr = string.format("%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s", currentTheme, ShrinkBox.Text, AfkBox.Text, WsBox.Text, JpBox.Text, GravBox.Text, CFrameSpeedBox.Text, SpinBox.Text, tgs, tabsOrderStr, lagStr)
    local saveCode = "HUB-Save-" .. B64Encode(rawStr)
    local success = setClipboardSafely(saveCode)
    if success == "studio" then 
        GenSaveBtn.Text = "PRINTED TO OUTPUT!" 
    elseif success == "copied" then 
        GenSaveBtn.Text = "COPIED TO CLIPBOARD!" 
    else 
        GenSaveBtn.Text = "ERROR: NO CLIPBOARD" 
    end
    task.delay(2.5, function() GenSaveBtn.Text = "GENERATE SAVE CODE" end)
end)

LoadSaveBtn.MouseButton1Click:Connect(function()
    local str = ImportBox.Text if not str:match("^HUB%-Save%-") then return end
    local pcallSuccess = pcall(function()
        local decoded = B64Decode(str:sub(10))
        local p = string.split(decoded, "|")
        if #p >= 11 then
            SetTheme(p[1]) ShrinkBox.Text = p[2] ApplyShrink() AfkBox.Text = p[3] WsBox.Text = p[4] applyWS() JpBox.Text = p[5] applyJP() GravBox.Text = p[6] applyGrav() CFrameSpeedBox.Text = p[7] SpinBox.Text = p[8]
            local t = p[9]
            SetESP(t:sub(1,1)=="1") SetUltraRun(t:sub(2,2)=="1") SetNoclip(t:sub(3,3)=="1") ToggleInvis(t:sub(4,4)=="1") SetUndie(t:sub(5,5)=="1") SetFly(t:sub(6,6)=="1") TogglePlatform(t:sub(7,7)=="1") SetUnvoid(t:sub(8,8)=="1") SetChaosLag(t:sub(9,9)=="1") SetCFSpeed(t:sub(10,10)=="1") SetSpin(t:sub(11,11)=="1") SetFPS(t:sub(12,12)=="1") SetPing(t:sub(13,13)=="1")
            if #t >= 15 then SetAimbot(t:sub(14,14)=="1") SetAntiAfk(t:sub(15,15)=="1") end
            if #t >= 17 then SetInfJump(t:sub(16,16)=="1") SetClickTp(t:sub(17,17)=="1") end
            local tOrd = string.split(p[10], ",") for i, v in ipairs(tOrd) do if OrderBoxes[i] then OrderBoxes[i].box.Text = v end end ApplyTabOrders()
            lagChain = {} if p[11] ~= "" then for _, pr in ipairs(string.split(p[11], ",")) do local vals = string.split(pr, ":") table.insert(lagChain, {anchor=tonumber(vals[1]) or 0.2, free=tonumber(vals[2]) or 0.1}) end else lagChain = {{anchor=0.2, free=0.1}} end
            updateLagList() ImportBox.Text = "" ImportBox.PlaceholderText = "SUCCESSFULLY LOADED!" task.delay(2, function() ImportBox.PlaceholderText = "PASTE HUB-Save-... CODE HERE" end)
        end
    end)
    if not pcallSuccess then
        ImportBox.Text = ""
        ImportBox.PlaceholderText = "ERROR PARSING DATA!"
        task.delay(2, function() ImportBox.PlaceholderText = "PASTE HUB-Save-... CODE HERE" end)
    end
end)

-- ==================== CENTRALIZED LOOPS ====================
AddServiceConn(LocalPlayer.Idled:Connect(function()
    if antiAfkActive and VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end
end))

AddServiceConn(UIS.JumpRequest:Connect(function()
    if infJumpActive then
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

local fpsTimer, frames = 0, 0
AddServiceConn(RunService.Heartbeat:Connect(function(dt)
    frames = frames + 1 fpsTimer = fpsTimer + dt
    if fpsTimer >= 1 then if fpsActive and FpsLbl then FpsLbl.Text = "FPS: " .. frames end frames, fpsTimer = 0, 0 end
    if pingActive and PingLbl then PingLbl.Text = "PING: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. " ms" end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if undieActive and not invisActive and hum and hum.Health > 0 and hum.Health <= (hum.MaxHealth * 0.25) then ToggleInvis(true) end
    if unvoidActive and not platActive and hrp then if hrp.Position.Y < (workspace.FallenPartsDestroyHeight + 100) then TogglePlatform(true) hrp.Velocity = Vector3.new(0, 50, 0) end end

    -- ESP Distance Updater
    if espActive and hrp then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tHead = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
                if tHead then
                    local bgui = tHead:FindFirstChild("LuxuryESP_Text")
                    if bgui then
                        local txt = bgui:FindFirstChildOfClass("TextLabel")
                        if txt then
                            local dist = math.floor((tHead.Position - hrp.Position).Magnitude)
                            txt.Text = string.format("%s\n[%d STUDS]", p.DisplayName, dist)
                        end
                    end
                end
            end
        end
    end

    if hrp and hum and hum.Health > 0 then
        if cfSpeedActive and hum.MoveDirection.Magnitude > 0 then 
            local mult = 2
            if CFrameSpeedBox then mult = tonumber(CFrameSpeedBox.Text) or 2 end
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * mult * dt * 60) 
        end
        if spinActive then 
            local mult = 50
            if SpinBox then mult = tonumber(SpinBox.Text) or 50 end
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(mult * dt * 60), 0) 
        end
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
    if aimbotActive then
        if not aimTarget or not aimTarget.Parent or not aimTarget:FindFirstChild("Humanoid") or aimTarget.Humanoid.Health <= 0 then
            aimTarget = GetClosestPlayerToCursor()
        end
        local camera = workspace.CurrentCamera
        if aimTarget and camera then
            local targetPos = aimTarget.Position
            local lookCFrame = CFrame.lookAt(camera.CFrame.Position, targetPos)
            camera.CFrame = camera.CFrame:Lerp(lookCFrame, 0.15)
        end
    else
        aimTarget = nil
    end
end))

AddServiceConn(RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if ultraRunActive and hum then for _, t in pairs(hum:GetPlayingAnimationTracks()) do pcall(function() t:AdjustSpeed(2.5) end) end end
    if noclipActive and char then for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end end

    if invisActive and realChar and fakeChar then
        local rHrp, fHrp = realChar:FindFirstChild("HumanoidRootPart"), fakeChar:FindFirstChild("HumanoidRootPart")
        if rHrp and fHrp and not isStriking then rHrp.CFrame = fHrp.CFrame * CFrame.new(0, 500, 0) rHrp.Velocity = Vector3.zero rHrp.RotVelocity = Vector3.zero end
        local fTool, rHum = fakeChar:FindFirstChildOfClass("Tool"), realChar:FindFirstChildOfClass("Humanoid")
        if fTool and rHum then local rTool = LocalPlayer.Backpack:FindFirstChild(fTool.Name) if rTool then rHum:EquipTool(rTool) end elseif not fTool and rHum then rHum:UnequipTools() end
    end
end))

AddServiceConn(UIS.InputBegan:Connect(function(input, gpe)
    if invisActive and realChar and fakeChar and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not gpe then
        isStriking = true local rHrp, fHrp = realChar:FindFirstChild("HumanoidRootPart"), fakeChar:FindFirstChild("HumanoidRootPart")
        if rHrp and fHrp then rHrp.CFrame = fHrp.CFrame end task.delay(0.1, function() isStriking = false end)
    end
    
    -- Click Teleport Animation Logic
    if clickTpActive and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not gpe then
        local camera = workspace.CurrentCamera
        local unitRay = camera:ViewportPointToRay(input.Position.X, input.Position.Y)
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, fakeChar, platPart, FlyUI, PlatUI, MainFrame}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, raycastParams)
        
        if result then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                if currentTpTween then currentTpTween:Cancel() end
                hrp.Anchored = true
                local dist = (hrp.Position - result.Position).Magnitude
                local duration = math.clamp(dist / 300, 0.15, 1.0)
                currentTpTween = TS:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.new(result.Position + Vector3.new(0, 3, 0))})
                currentTpTween:Play()
                currentTpTween.Completed:Connect(function()
                    if not infStabActive or lagState == "FREE" then hrp.Anchored = false end
                end)
            end
        end
    end
end))

local lastActive = tick()
local function checkUIInteraction(input)
    local pos = input.Position
    for _, frame in ipairs({MainFrame, FlyUI, PlatUI}) do
        if frame and frame.Visible then
            local ax, ay, sx, sy = frame.AbsolutePosition.X, frame.AbsolutePosition.Y, frame.AbsoluteSize.X, frame.AbsoluteSize.Y
            if pos.X >= ax and pos.X <= ax + sx and pos.Y >= ay and pos.Y <= ay + sy then lastActive = tick() end
        end
    end
end
AddServiceConn(UIS.InputBegan:Connect(checkUIInteraction))
AddServiceConn(UIS.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then checkUIInteraction(input) end end))

local function ForceCleanup()
    SetESP(false) SetUltraRun(false) SetNoclip(false) SetChaosLag(false) SetSpin(false) SetCFSpeed(false) SetFly(false) TogglePlatform(false) ToggleInvis(false) SetAimbot(false) SetAntiAfk(false) SetInfJump(false) SetClickTp(false)
    undieActive, unvoidActive = false, false if FlyUI then FlyUI.Visible = false end if PlatUI then PlatUI.Visible = false end
    stopInfTp() pcall(function() workspace.Gravity = 196.2 end)
    
    local char = LocalPlayer.Character local hum = char and char:FindFirstChild("Humanoid") local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end hrp.Anchored = false end
    if hum then hum.PlatformStand = false hum.WalkSpeed = 16 hum.UseJumpPower = true hum.JumpPower = 50 for _, track in pairs(hum:GetPlayingAnimationTracks()) do pcall(function() track:AdjustSpeed(1) end) end pcall(function() workspace.CurrentCamera.CameraSubject = hum end) end
    
    for _, conn in ipairs(ServiceConnections) do if conn.Connected then conn:Disconnect() end end
    for _, p in pairs(Players:GetPlayers()) do 
        if p.Character then 
            local hl = p.Character:FindFirstChild("LuxuryESP") if hl then hl:Destroy() end 
            local head = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            if head then local bgui = head:FindFirstChild("LuxuryESP_Text") if bgui then bgui:Destroy() end end
        end 
    end
end

task.spawn(function()
    while task.wait(1) do
        if not ScreenGui.Parent then break end
        local tbox = AfkBox and tonumber(AfkBox.Text) or 9999
        if tick() - lastActive > tbox then ForceCleanup() ScreenGui:Destroy() break end
    end
end)

UnviewBtn.MouseButton1Click:Connect(function() local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if hum then workspace.CurrentCamera.CameraSubject = hum end end)
CloseBtn.MouseButton1Click:Connect(function() ForceCleanup() ScreenGui:Destroy() end)

-- Initial UI Setup & Parenting
local function AssignParent()
    local success, _ = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    
    if not success or ScreenGui.Parent == nil then
        local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
        if PlayerGui then
            ScreenGui.Parent = PlayerGui
        else
            ScreenGui.Parent = LocalPlayer:FindFirstChild("PlayerScripts") or game:GetService("StarterGui")
        end
    end
end
AssignParent()

updatePlayerList() 
updateLagList()
