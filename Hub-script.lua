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

local function ApplyToggleStyle(btn, state, defColor)
    ApplyStyle(btn, state and Color3.fromRGB(0, 255, 0) or defColor)
end

-- BASE64 ENCODER/DECODER FOR SAVE SYSTEM
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

-- STATS (FPS/PING) HUD OVERLAY
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

-- DRAG LOGIC
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

-- TAB SYSTEM
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 110, 1, -35)
Sidebar.Position = UDim2.new(0, 5, 0, 30)
Sidebar.BackgroundTransparency = 1
local SideLayout = Instance.new("UIListLayout", Sidebar)
SideLayout.Padding = UDim.new(0, 5)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- SEARCH BOX
local SearchBox = Instance.new("TextBox", Sidebar)
SearchBox.Size = UDim2.new(1, 0, 0, 25)
SearchBox.PlaceholderText = "SEARCH..."
SearchBox.LayoutOrder = -1 -- Always on top of tabs
ApplyStyle(SearchBox, Color3.fromRGB(255, 255, 255), Color3.fromRGB(20, 20, 30))

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
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Sidebar.Visible = not minimized
    TabContainer.Visible = not minimized
    MinBtn.Text = minimized and "+" or "-"
    MainFrame.Size = minimized and UDim2.new(0, 450, 0, 25) or UDim2.new(0, 450, 0, 300)
end)

-- GLOBAL STATES
local espActive, ultraRunActive, noclipActive = false, false, false
local invisActive, undieActive, platActive, unvoidActive = false, false, false, false
local flying, infStabActive, cfSpeedActive, spinActive = false, false, false, false
local fpsActive, pingActive = false, false

-- STATE SETTERS
local ToggleInvis, TogglePlatform, SetFly, SetUltraRun, SetNoclip
local ApplyShrink
local updateLagList, updatePlayerList, updateNpcList
local PerformSearch

-- ==================== TABS CREATION ====================

-- 1. HOME TAB
local HomeTab = MakeTab("HOME", true)
local WelcomeText = Instance.new("TextLabel", HomeTab)
WelcomeText.Size = UDim2.new(1, 0, 1, 0)
WelcomeText.Text = "KIRIK HUB V49\n\n[ NEW FEATURES ]\n- Global Live Search (Top Left)\n- FPS & PING Overlay HUD\n- Direct Save to Clipboard\n- UN-DIE: Auto-Ghost on low health\n- UN-VOID: Auto-Platform if falling\n- Ghost Invisibility, INF TP, Chaos Lag"
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

local UndieBtn = Instance.new("TextButton", MakeRow(CharScroll))
UndieBtn.Size = UDim2.new(1, 0, 1, 0)
UndieBtn.Text = "UN-DIE: OFF"
ApplyStyle(UndieBtn, Color3.fromRGB(200, 50, 50))

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

local UnvoidBtn = Instance.new("TextButton", MakeRow(FlyScroll))
UnvoidBtn.Size = UDim2.new(1, 0, 1, 0)
UnvoidBtn.Text = "UN-VOID: OFF"
ApplyStyle(UnvoidBtn, Color3.fromRGB(50, 50, 255))

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

-- 7. SETTINGS TAB (Combined with Save)
local SettingsTab = MakeTab("SETTINGS", false)
local SettingsScroll, _ = MakeScrollArea(SettingsTab)

local ShrinkRow = MakeRow(SettingsScroll) ShrinkRow.LayoutOrder = 1
local ShrinkLbl = Instance.new("TextLabel", ShrinkRow)
ShrinkLbl.Size = UDim2.new(0.65, 0, 1, 0)
ShrinkLbl.Text = "SHRINK UI (Ex: 2 = 2x smaller)"
ApplyStyle(ShrinkLbl, Color3.fromRGB(255, 255, 0))
local ShrinkBox = Instance.new("TextBox", ShrinkRow)
ShrinkBox.Size = UDim2.new(0.33, 0, 1, 0)
ShrinkBox.Position = UDim2.new(0.67, 0, 0, 0)
ShrinkBox.Text = "1"
ApplyStyle(ShrinkBox, Color3.fromRGB(255, 255, 0))

local AfkRow = MakeRow(SettingsScroll) AfkRow.LayoutOrder = 2
local AfkLbl = Instance.new("TextLabel", AfkRow)
AfkLbl.Size = UDim2.new(0.65, 0, 1, 0)
AfkLbl.Text = "AFK TIMEOUT (SEC)"
ApplyStyle(AfkLbl, Color3.fromRGB(150, 150, 150))
local AfkBox = Instance.new("TextBox", AfkRow)
AfkBox.Size = UDim2.new(0.33, 0, 1, 0)
AfkBox.Position = UDim2.new(0.67, 0, 0, 0)
AfkBox.Text = "30"
ApplyStyle(AfkBox, Color3.fromRGB(150, 150, 150))

local FpsBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) FpsBtn.Parent.LayoutOrder = 3
FpsBtn.Size = UDim2.new(1, 0, 1, 0) FpsBtn.Text = "FPS HUD: OFF" ApplyStyle(FpsBtn, Color3.fromRGB(0, 255, 100))

local PingBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) PingBtn.Parent.LayoutOrder = 4
PingBtn.Size = UDim2.new(1, 0, 1, 0) PingBtn.Text = "PING HUD: OFF" ApplyStyle(PingBtn, Color3.fromRGB(255, 150, 0))

local ThemeLblRow = MakeRow(SettingsScroll) ThemeLblRow.LayoutOrder = 5
local ThemeLbl = Instance.new("TextLabel", ThemeLblRow)
ThemeLbl.Size = UDim2.new(1, 0, 1, 0) ThemeLbl.Text = "--- THEMES ---" ApplyStyle(ThemeLbl, Color3.fromRGB(0, 255, 255))

local NeonBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) NeonBtn.Parent.LayoutOrder = 6
NeonBtn.Size = UDim2.new(1, 0, 1, 0) NeonBtn.Text = "NEON (DEFAULT)" ApplyStyle(NeonBtn, Color3.fromRGB(255, 0, 255))

local HackerBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) HackerBtn.Parent.LayoutOrder = 7
HackerBtn.Size = UDim2.new(1, 0, 1, 0) HackerBtn.Text = "HACKER (GREEN)" ApplyStyle(HackerBtn, Color3.fromRGB(0, 255, 0))

local BWBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) BWBtn.Parent.LayoutOrder = 8
BWBtn.Size = UDim2.new(1, 0, 1, 0) BWBtn.Text = "BLACK & WHITE" ApplyStyle(BWBtn, Color3.fromRGB(255, 255, 255))

NeonBtn.MouseButton1Click:Connect(function() SetTheme("NEON") end)
HackerBtn.MouseButton1Click:Connect(function() SetTheme("HACKER") end)
BWBtn.MouseButton1Click:Connect(function() SetTheme("B&W") end)

local SaveHeaderRow = MakeRow(SettingsScroll) SaveHeaderRow.LayoutOrder = 9
local SaveHeaderLbl = Instance.new("TextLabel", SaveHeaderRow)
SaveHeaderLbl.Size = UDim2.new(1, 0, 1, 0) SaveHeaderLbl.Text = "--- SAVE SYSTEM ---" ApplyStyle(SaveHeaderLbl, Color3.fromRGB(0, 255, 150))

local GenSaveBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) GenSaveBtn.Parent.LayoutOrder = 10
GenSaveBtn.Size = UDim2.new(1, 0, 1, 0) GenSaveBtn.Text = "GENERATE SAVE CODE (COPIES)" ApplyStyle(GenSaveBtn, Color3.fromRGB(0, 255, 0))

local ImportBoxRow = MakeRow(SettingsScroll) ImportBoxRow.LayoutOrder = 11
local ImportBox = Instance.new("TextBox", ImportBoxRow)
ImportBox.Size = UDim2.new(1, 0, 1, 0) ImportBox.PlaceholderText = "PASTE HUB-Save-... CODE HERE" ImportBox.ClearTextOnFocus = false ApplyStyle(ImportBox, Color3.fromRGB(255, 150, 0))

local LoadSaveBtn = Instance.new("TextButton", MakeRow(SettingsScroll)) LoadSaveBtn.Parent.LayoutOrder = 12
LoadSaveBtn.Size = UDim2.new(1, 0, 1, 0) LoadSaveBtn.Text = "LOAD SAVE CODE" ApplyStyle(LoadSaveBtn, Color3.fromRGB(255, 0, 0))

local TabOrderLblRow = MakeRow(SettingsScroll) TabOrderLblRow.LayoutOrder = 13
local TabOrderLbl = Instance.new("TextLabel", TabOrderLblRow)
TabOrderLbl.Size = UDim2.new(1, 0, 1, 0) TabOrderLbl.Text = "--- TAB ORDER (NUMERIC) ---" ApplyStyle(TabOrderLbl, Color3.fromRGB(0, 255, 255))

local OrderBoxes = {}
for i, tBtn in ipairs(tabBtns) do
    local row = MakeRow(SettingsScroll)
    row.LayoutOrder = 20 + i
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.65, 0, 1, 0)
    lbl.Text = "TAB: " .. tBtn.Text
    ApplyStyle(lbl, Color3.fromRGB(255, 100, 0))
    local box = Instance.new("TextBox", row)
    box.Size = UDim2.new(0.33, 0, 1, 0)
    box.Position = UDim2.new(0.67, 0, 0, 0)
    box.Text = tostring(tBtn.LayoutOrder)
    ApplyStyle(box, Color3.fromRGB(255, 100, 0))
    table.insert(OrderBoxes, {btn = tBtn, box = box, row = row})
end

local ApplyOrderRow = MakeRow(SettingsScroll) ApplyOrderRow.LayoutOrder = 100
local ApplyOrderBtn = Instance.new("TextButton", ApplyOrderRow)
ApplyOrderBtn.Size = UDim2.new(1, 0, 1, 0)
ApplyOrderBtn.Text = "APPLY TAB ORDER"
ApplyStyle(ApplyOrderBtn, Color3.fromRGB(0, 255, 0))

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

        if not scroll then
            local lbl = tabObj:FindFirstChildOfClass("TextLabel")
            if lbl and string.find(string.lower(lbl.Text), q) then hasVisibleRow = true end
        else
            for _, row in ipairs(scroll:GetChildren()) do
                if row:IsA("Frame") then
                    if q == "" or tabMatches then
                        row.Visible = true
                        hasVisibleRow = true
                    else
                        local rowMatches = false
                        for _, el in ipairs(row:GetDescendants()) do
                            if (el:IsA("TextLabel") or el:IsA("TextButton") or el:IsA("TextBox")) and el.Text ~= "" then
                                if string.find(string.lower(el.Text), q) then
                                    rowMatches = true
                                    break
                                end
                            end
                        end
                        row.Visible = rowMatches
                        if rowMatches then hasVisibleRow = true end
                    end
                end
            end
        end

        if q == "" or tabMatches or hasVisibleRow then
            tBtn.Visible = true
            anyTabVisible = true
            if not firstVisibleTab then firstVisibleTab = i end
        else
            tBtn.Visible = false
        end
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
SearchBox:GetPropertyChangedSignal("Text"):Connect(PerformSearch)

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

ApplyShrink = function()
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
end
ShrinkBox.FocusLost:Connect(ApplyShrink)

local function ShowFailsafeMessage()
    local msg = Instance.new("TextLabel", ScreenGui)
    msg.Size = UDim2.new(1, 0, 0, 50)
    msg.Position = UDim2.new(0, 0, 0.5, -25)
    msg.BackgroundTransparency = 1
    msg.Text = "Sorry, we were trying to keep you from falling."
    msg.TextColor3 = Color3.fromRGB(255, 50, 50)
    msg.Font = Enum.Font.GothamBold
    msg.TextScaled = true
    msg.ZIndex = 1000
    local stroke = Instance.new("UIStroke", msg)
    stroke.Thickness = 2
    stroke.Color = Color3.new(0, 0, 0)
    task.spawn(function()
        task.wait(3)
        for i = 0, 1, 0.1 do msg.TextTransparency = i stroke.Transparency = i task.wait(0.05) end
        msg:Destroy()
    end)
end

-- ==================== STATE HELPERS & OVERLAY LOGIC ====================
local function SetFPS(state)
    fpsActive = state
    ApplyToggleStyle(FpsBtn, fpsActive, Color3.fromRGB(0, 255, 100))
    FpsBtn.Text = "FPS HUD: " .. (fpsActive and "ON" or "OFF")
    FpsLbl.Visible = fpsActive
    StatsFrame.Visible = fpsActive or pingActive
end
FpsBtn.MouseButton1Click:Connect(function() SetFPS(not fpsActive) end)

local function SetPing(state)
    pingActive = state
    ApplyToggleStyle(PingBtn, pingActive, Color3.fromRGB(255, 150, 0))
    PingBtn.Text = "PING HUD: " .. (pingActive and "ON" or "OFF")
    PingLbl.Visible = pingActive
    StatsFrame.Visible = fpsActive or pingActive
end
PingBtn.MouseButton1Click:Connect(function() SetPing(not pingActive) end)

local fpsTimer, frames = 0, 0
RunService.RenderStepped:Connect(function(dt)
    frames = frames + 1
    fpsTimer = fpsTimer + dt
    if fpsTimer >= 1 then
        if fpsActive then FpsLbl.Text = "FPS: " .. frames end
        frames, fpsTimer = 0, 0
    end
    if pingActive then
        PingLbl.Text = "PING: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. " ms"
    end
end)

local function SetESP(state)
    espActive = state
    ApplyToggleStyle(EspBtn, espActive, Color3.fromRGB(0, 255, 100))
    EspBtn.Text = "ESP: " .. (espActive and "ON" or "OFF")
    if not state then for _, p in pairs(Players:GetPlayers()) do if p.Character and p.Character:FindFirstChild("LuxuryESP") then p.Character.LuxuryESP:Destroy() end end end
end

local function SetUltraRun(state)
    ultraRunActive = state
    ApplyToggleStyle(UltraRunBtn, ultraRunActive, Color3.fromRGB(255, 80, 0))
    UltraRunBtn.Text = "ULTRA RUN: " .. (ultraRunActive and "ON" or "OFF")
    if not state then local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if hum then for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(1) end end end
end

local function SetNoclip(state)
    noclipActive = state
    ApplyToggleStyle(NoclipBtn, noclipActive, Color3.fromRGB(0, 255, 200))
    NoclipBtn.Text = "NOCLIP: " .. (noclipActive and "ON" or "OFF")
end

local function SetUndie(state)
    undieActive = state
    ApplyToggleStyle(UndieBtn, undieActive, Color3.fromRGB(200, 50, 50))
    UndieBtn.Text = "UN-DIE: " .. (undieActive and "ON" or "OFF")
end

local function SetUnvoid(state)
    unvoidActive = state
    ApplyToggleStyle(UnvoidBtn, unvoidActive, Color3.fromRGB(50, 50, 255))
    UnvoidBtn.Text = "UN-VOID: " .. (unvoidActive and "ON" or "OFF")
end

local function SetChaosLag(state)
    infStabActive = state
    ApplyToggleStyle(InfStabBtn, infStabActive, Color3.fromRGB(255, 150, 0))
    InfStabBtn.Text = "CHAOS LAG: " .. (infStabActive and "ON" or "OFF")
    if not state then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = false hrp.Velocity = Vector3.zero end
    end
end

local function SetCFSpeed(state)
    cfSpeedActive = state
    ApplyToggleStyle(CFrameSpeedBtn, cfSpeedActive, Color3.fromRGB(255, 100, 0))
    CFrameSpeedBtn.Text = "CF SPD: " .. (cfSpeedActive and "ON" or "OFF")
end

local function SetSpin(state)
    spinActive = state
    ApplyToggleStyle(SpinBtn, spinActive, Color3.fromRGB(0, 255, 50))
    SpinBtn.Text = "SPIN: " .. (spinActive and "ON" or "OFF")
end

local function applyWS() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if h then h.WalkSpeed = tonumber(WsBox.Text) or 16 end end
local function applyJP() local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") if h then h.UseJumpPower = true h.JumpPower = tonumber(JpBox.Text) or 50 end end
local function applyGrav() workspace.Gravity = tonumber(GravBox.Text) or 196.2 end

-- ==================== SAVE / LOAD LOGIC ====================
local lagChain = {{anchor = 0.2, free = 0.1}}

GenSaveBtn.MouseButton1Click:Connect(function()
    local tgs = string.format("%d%d%d%d%d%d%d%d%d%d%d%d%d",
        espActive and 1 or 0, ultraRunActive and 1 or 0, noclipActive and 1 or 0,
        invisActive and 1 or 0, undieActive and 1 or 0, flying and 1 or 0,
        platActive and 1 or 0, unvoidActive and 1 or 0, infStabActive and 1 or 0,
        cfSpeedActive and 1 or 0, spinActive and 1 or 0, fpsActive and 1 or 0, pingActive and 1 or 0
    )
    local tabsOrderStr = ""
    for i, ob in ipairs(OrderBoxes) do tabsOrderStr = tabsOrderStr .. tostring(ob.btn.LayoutOrder) .. (i == #OrderBoxes and "" or ",") end
    
    local lagStr = ""
    for i, l in ipairs(lagChain) do lagStr = lagStr .. tostring(l.anchor) .. ":" .. tostring(l.free) .. (i == #lagChain and "" or ",") end

    local rawStr = string.format("%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s",
        currentTheme, ShrinkBox.Text, AfkBox.Text, WsBox.Text, JpBox.Text, GravBox.Text,
        CFrameSpeedBox.Text, SpinBox.Text, tgs, tabsOrderStr, lagStr
    )
    local saveCode = "HUB-Save-" .. B64Encode(rawStr)
    
    local success = pcall(function() setclipboard(saveCode) end)
    if success then GenSaveBtn.Text = "COPIED TO CLIPBOARD!" else GenSaveBtn.Text = "ERROR: CLIPBOARD UNSUPPORTED" end
    task.delay(2, function() GenSaveBtn.Text = "GENERATE SAVE CODE (COPIES)" end)
end)

LoadSaveBtn.MouseButton1Click:Connect(function()
    local str = ImportBox.Text
    if not str:match("^HUB%-Save%-") then return end
    local b64 = str:sub(10)
    local dec = B64Decode(b64)
    local p = string.split(dec, "|")
    if #p >= 11 then
        SetTheme(p[1])
        ShrinkBox.Text = p[2] ApplyShrink()
        AfkBox.Text = p[3]
        WsBox.Text = p[4] applyWS()
        JpBox.Text = p[5] applyJP()
        GravBox.Text = p[6] applyGrav()
        CFrameSpeedBox.Text = p[7]
        SpinBox.Text = p[8]

        local t = p[9]
        SetESP(t:sub(1,1)=="1")
        SetUltraRun(t:sub(2,2)=="1")
        SetNoclip(t:sub(3,3)=="1")
        ToggleInvis(t:sub(4,4)=="1")
        SetUndie(t:sub(5,5)=="1")
        SetFly(t:sub(6,6)=="1")
        TogglePlatform(t:sub(7,7)=="1")
        SetUnvoid(t:sub(8,8)=="1")
        SetChaosLag(t:sub(9,9)=="1")
        SetCFSpeed(t:sub(10,10)=="1")
        SetSpin(t:sub(11,11)=="1")
        SetFPS(t:sub(12,12)=="1")
        SetPing(t:sub(13,13)=="1")

        local tOrd = string.split(p[10], ",")
        for i, v in ipairs(tOrd) do if OrderBoxes[i] then OrderBoxes[i].box.Text = v end end
        ApplyTabOrders()

        lagChain = {}
        if p[11] ~= "" then
            local pairs = string.split(p[11], ",")
            for _, pr in ipairs(pairs) do
                local vals = string.split(pr, ":")
                table.insert(lagChain, {anchor=tonumber(vals[1]) or 0.2, free=tonumber(vals[2]) or 0.1})
            end
        else
            lagChain = {{anchor=0.2, free=0.1}}
        end
        updateLagList()
        ImportBox.Text = ""
        ImportBox.PlaceholderText = "SUCCESSFULLY LOADED!"
        task.delay(2, function() ImportBox.PlaceholderText = "PASTE HUB-Save-... CODE HERE" end)
    end
end)

-- ==================== INVISIBILITY & PLATFORM ENCAPSULATION ====================
local realChar, fakeChar = nil, nil
local isStriking = false
local platPart, platConn = nil, nil
local platFails, platFailTime = 0, 0

ToggleInvis = function(state)
    if invisActive == state then return end
    invisActive = state
    ApplyToggleStyle(InvisBtn, invisActive, Color3.fromRGB(200, 0, 255))
    InvisBtn.Text = "INVISIBILITY (GHOST): " .. (invisActive and "ON" or "OFF")
    
    if invisActive then
        realChar = LocalPlayer.Character
        if realChar then
            realChar.Archivable = true
            fakeChar = realChar:Clone()
            fakeChar.Name = realChar.Name 
            fakeChar.Parent = workspace
            LocalPlayer.Character = fakeChar
            workspace.CurrentCamera.CameraSubject = fakeChar:FindFirstChild("Humanoid")
            
            local fAnim = fakeChar:FindFirstChild("Animate")
            if fAnim then fAnim.Disabled = true task.delay(0.1, function() fAnim.Disabled = false end) end
            local rHrp = realChar:FindFirstChild("HumanoidRootPart")
            if rHrp then rHrp.Anchored = false end
            
            local fHum = fakeChar:FindFirstChild("Humanoid")
            if fHum then
                fHum.Died:Connect(function()
                    ToggleInvis(false)
                    LocalPlayer.Character = realChar
                    if realChar:FindFirstChild("Humanoid") then realChar.Humanoid.Health = 0 end
                end)
            end
        else
            ToggleInvis(false)
        end
    else
        if fakeChar and realChar then
            isStriking = false
            local fHrp = fakeChar:FindFirstChild("HumanoidRootPart")
            local rHrp = realChar:FindFirstChild("HumanoidRootPart")
            if rHrp and fHrp then rHrp.CFrame = fHrp.CFrame end
            LocalPlayer.Character = realChar
            workspace.CurrentCamera.CameraSubject = realChar:FindFirstChild("Humanoid")
            fakeChar:Destroy()
            fakeChar = nil
        end
    end
end
InvisBtn.MouseButton1Click:Connect(function() ToggleInvis(not invisActive) end)

TogglePlatform = function(state)
    if platActive == state then return end
    platActive = state
    ApplyToggleStyle(PlatformBtn, platActive, Color3.fromRGB(0, 150, 255))
    PlatformBtn.Text = "PLATFORM: " .. (platActive and "ON" or "OFF")
    PlatUI.Visible = platActive
    platFails = 0

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
            
            local diff = currentY - (cHrp.Position.Y - 3.5)
            if diff > 1.5 and not (platDownPressed or UIS:IsKeyDown(Enum.KeyCode.LeftControl)) then
                cHrp.Velocity = Vector3.new(cHrp.Velocity.X, 0, cHrp.Velocity.Z)
                cHrp.CFrame = CFrame.new(cHrp.Position.X, currentY + 3.5, cHrp.Position.Z)
                local now = tick()
                if now - platFailTime < 1.5 then platFails = platFails + 1 else platFails = 1 end
                platFailTime = now
                if platFails > 8 then TogglePlatform(false) ShowFailsafeMessage() end
            end
        end)
    else
        if platPart then platPart:Destroy() end
        if platConn then platConn:Disconnect() end
    end
end
PlatformBtn.MouseButton1Click:Connect(function() TogglePlatform(not platActive) end)

SetFly = function(state)
    flying = state
    ApplyToggleStyle(FlyBtn, flying, Color3.fromRGB(255, 0, 255))
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
end
FlyBtn.MouseButton1Click:Connect(function() SetFly(not flying) end)

-- UI CONNECTIONS
EspBtn.MouseButton1Click:Connect(function() SetESP(not espActive) end)
UltraRunBtn.MouseButton1Click:Connect(function() SetUltraRun(not ultraRunActive) end)
NoclipBtn.MouseButton1Click:Connect(function() SetNoclip(not noclipActive) end)
UndieBtn.MouseButton1Click:Connect(function() SetUndie(not undieActive) end)
UnvoidBtn.MouseButton1Click:Connect(function() SetUnvoid(not unvoidActive) end)
InfStabBtn.MouseButton1Click:Connect(function() SetChaosLag(not infStabActive) end)
CFrameSpeedBtn.MouseButton1Click:Connect(function() SetCFSpeed(not cfSpeedActive) end)
SpinBtn.MouseButton1Click:Connect(function() SetSpin(not spinActive) end)
WsBtn.MouseButton1Click:Connect(applyWS)
JpBtn.MouseButton1Click:Connect(applyJP)
GravBtn.MouseButton1Click:Connect(applyGrav)

-- ==================== LOGIC & SYSTEMS ====================

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
                    if tHrp and tHum and tHum.Health > 0 then targetCFrame = tHrp.CFrame * CFrame.new(0, 0, 3) isValid = true end
                end
            elseif currentInfTpTarget:IsA("Model") then
                if currentInfTpTarget.Parent then
                    local tHrp = currentInfTpTarget:FindFirstChild("HumanoidRootPart")
                    local tHum = currentInfTpTarget:FindFirstChildOfClass("Humanoid")
                    if tHrp and tHum and tHum.Health > 0 then targetCFrame = tHrp.CFrame * CFrame.new(0, 0, 3) isValid = true end
                end
            end
        elseif type(currentInfTpTarget) == "table" then
            if currentInfTpTarget.part and currentInfTpTarget.part.Parent then targetCFrame = currentInfTpTarget.part.CFrame * CFrame.new(0, 3, 0) isValid = true
            else targetCFrame = CFrame.new(currentInfTpTarget.pos + Vector3.new(0, 3, 0)) isValid = true end
        end
        if isValid and targetCFrame then
            local mChar = LocalPlayer.Character
            local mHrp = mChar and mChar:FindFirstChild("HumanoidRootPart")
            if mHrp then mHrp.CFrame = targetCFrame end
        else stopInfTp() if updatePlayerList then updatePlayerList() end if updateNpcList then updateNpcList() end end
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
                btn.Text = player.DisplayName .. (isActive and " [ON]" or "[OFF]")
                ApplyStyle(btn, isActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
            else
                btn.Text = player.DisplayName ApplyStyle(btn, Color3.fromRGB(0, 200, 255))
            end
            btn.MouseButton1Click:Connect(function()
                if listMode == "TP" then
                    local pChar = player.Character if pChar and pChar:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = pChar.HumanoidRootPart.CFrame end
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
            local row = MakeRow(PlayerList)
            local tpBtn = Instance.new("TextButton", row)
            tpBtn.Size = UDim2.new(0.75, 0, 1, 0)
            if listMode == "INF TP" then
                local isActive = (currentInfTpTarget == spot)
                tpBtn.Text = spot.name .. (isActive and " [ON]" or " [OFF]") ApplyStyle(tpBtn, isActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
            else tpBtn.Text = spot.name ApplyStyle(tpBtn, Color3.fromRGB(0, 255, 100)) end
            local delBtn = Instance.new("TextButton", row)
            delBtn.Size = UDim2.new(0.2, 0, 1, 0) delBtn.Position = UDim2.new(0.8, 0, 0, 0) delBtn.Text = "X" ApplyStyle(delBtn, Color3.fromRGB(255, 0, 0))
            tpBtn.MouseButton1Click:Connect(function()
                if listMode == "TP" then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then if spot.part and spot.part.Parent then hrp.CFrame = spot.part.CFrame * CFrame.new(0, 3, 0) else hrp.CFrame = CFrame.new(spot.pos + Vector3.new(0, 3, 0)) end end
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
            local row = MakeRow(NpcList)
            local btn = Instance.new("TextButton", row)
            btn.Size = UDim2.new(1, 0, 1, 0)
            if npcListMode == "INF TP" then
                local isActive = (currentInfTpTarget == npc)
                btn.Text = npc.Name .. (isActive and " [ON]" or "[OFF]") ApplyStyle(btn, isActive and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0))
            else btn.Text = npc.Name ApplyStyle(btn, Color3.fromRGB(255, 100, 0)) end
            btn.MouseButton1Click:Connect(function()
                if npcListMode == "TP" then
                    local hrp = npc:FindFirstChild("HumanoidRootPart") if hrp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 3) end
                elseif npcListMode == "VIEW" then local hum = npc:FindFirstChildOfClass("Humanoid") if hum then workspace.CurrentCamera.CameraSubject = hum end
                elseif npcListMode == "INF TP" then if currentInfTpTarget == npc then stopInfTp() else startInfTp(npc) end updateNpcList() updatePlayerList() end
            end)
        end
    end
    PerformSearch()
end

local function refreshNPCs()
    cachedNPCs = {} NpcRefreshBtn.Text = "SCANNING..." task.wait(0.1)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= LocalPlayer.Character then
            if obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
                if not Players:GetPlayerFromCharacter(obj) then table.insert(cachedNPCs, obj) end
            end
        end
    end
    NpcRefreshBtn.Text = "REFRESH NPCs" updateNpcList()
end

ModeBtn.MouseButton1Click:Connect(function()
    if listMode == "TP" then listMode = "VIEW" elseif listMode == "VIEW" then listMode = "INF TP" else listMode = "TP" end
    ModeBtn.Text = "LIST MODE: " .. listMode updatePlayerList()
end)

NpcModeBtn.MouseButton1Click:Connect(function()
    if npcListMode == "TP" then npcListMode = "VIEW" elseif npcListMode == "VIEW" then npcListMode = "INF TP" else npcListMode = "TP" end
    NpcModeBtn.Text = "LIST MODE: " .. npcListMode updateNpcList()
end)

NpcRefreshBtn.MouseButton1Click:Connect(refreshNPCs)

local waitingForClick = false
local mouse = LocalPlayer:GetMouse()
AddTpBtn.MouseButton1Click:Connect(function() waitingForClick = true AddTpBtn.Text = "CLICK SCREEN..." end)
mouse.Button1Down:Connect(function()
    if waitingForClick then
        waitingForClick = false AddTpBtn.Text = "ADD CUSTOM TP PART" spotCount = spotCount + 1
        local hitPart = mouse.Target local hitPos = mouse.Hit.Position
        local name = hitPart and ("[" .. hitPart.Name .. "]") or ("SPOT " .. spotCount)
        table.insert(savedSpots, {name = name, part = hitPart, pos = hitPos}) updatePlayerList()
    end
end)
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- GHOST STRIKE SYNC & REAL CHAR POSITIONING
RunService.Stepped:Connect(function()
    if invisActive and realChar and fakeChar then
        local rHrp = realChar:FindFirstChild("HumanoidRootPart")
        local fHrp = fakeChar:FindFirstChild("HumanoidRootPart")
        if rHrp and fHrp then if not isStriking then rHrp.CFrame = fHrp.CFrame * CFrame.new(0, 500, 0) rHrp.Velocity = Vector3.zero rHrp.RotVelocity = Vector3.zero end end
        local fakeTool = fakeChar:FindFirstChildOfClass("Tool")
        local realHum = realChar:FindFirstChildOfClass("Humanoid")
        if fakeTool and realHum then local realTool = LocalPlayer.Backpack:FindFirstChild(fakeTool.Name) if realTool then realHum:EquipTool(realTool) end
        elseif not fakeTool and realHum then realHum:UnequipTools() end
    end
end)

UIS.InputBegan:Connect(function(input, gpe)
    if invisActive and realChar and fakeChar and input.UserInputType == Enum.UserInputType.MouseButton1 and not gpe then
        isStriking = true
        local rHrp = realChar:FindFirstChild("HumanoidRootPart")
        local fHrp = fakeChar:FindFirstChild("HumanoidRootPart")
        if rHrp and fHrp then rHrp.CFrame = fHrp.CFrame end
        task.delay(0.1, function() isStriking = false end)
    end
end)

updateLagList = function()
    for _, c in pairs(LagList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    for i, preset in ipairs(lagChain) do
        local row = MakeRow(LagList)
        local anchorBox = Instance.new("TextBox", row)
        anchorBox.Size = UDim2.new(0.38, 0, 1, 0) anchorBox.Text = tostring(preset.anchor) ApplyStyle(anchorBox, Color3.fromRGB(255, 0, 150))
        local freeBox = Instance.new("TextBox", row)
        freeBox.Size = UDim2.new(0.38, 0, 1, 0) freeBox.Position = UDim2.new(0.42, 0, 0, 0) freeBox.Text = tostring(preset.free) ApplyStyle(freeBox, Color3.fromRGB(0, 255, 150))
        local delBtn = Instance.new("TextButton", row)
        delBtn.Size = UDim2.new(0.16, 0, 1, 0) delBtn.Position = UDim2.new(0.84, 0, 0, 0) delBtn.Text = "-" ApplyStyle(delBtn, Color3.fromRGB(255, 0, 0))
        
        anchorBox.FocusLost:Connect(function() preset.anchor = math.max(0, tonumber(anchorBox.Text) or preset.anchor) anchorBox.Text = tostring(preset.anchor) end)
        freeBox.FocusLost:Connect(function() preset.free = math.max(0, tonumber(freeBox.Text) or preset.free) freeBox.Text = tostring(preset.free) end)
        delBtn.MouseButton1Click:Connect(function() table.remove(lagChain, i) updateLagList() end)
    end
    PerformSearch()
end

AddLagBtn.MouseButton1Click:Connect(function() table.insert(lagChain, {anchor = 0.2, free = 0.1}) updateLagList() end)

RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if undieActive and not invisActive and hum and hum.Health > 0 and hum.Health <= (hum.MaxHealth * 0.25) then ToggleInvis(true) end
    if unvoidActive and not platActive and hrp then if hrp.Position.Y < (workspace.FallenPartsDestroyHeight + 100) then TogglePlatform(true) hrp.Velocity = Vector3.new(0, 50, 0) end end
    
    if not infStabActive then return end
    if not hrp or not hum or hum.Health <= 0 then lagState = "FREE" lagTimer = 0 return end

    local currentItem = (#lagChain > 0) and lagChain[lagIndex > #lagChain and 1 or lagIndex] or {anchor = 0.2, free = 0.1}
    if lagIndex > #lagChain then lagIndex = 1 end

    lagTimer = lagTimer - dt
    if lagTimer <= 0 then
        if lagState == "FREE" then lagState = "LAG" lagTimer = currentItem.anchor hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero hrp.Anchored = true
        else lagState = "FREE" lagTimer = currentItem.free hrp.Anchored = false lagIndex = lagIndex + 1 end
    else
        if lagState == "LAG" then hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero hrp.Anchored = true else hrp.Anchored = false end
    end
end)

AntiFlingBtn.MouseButton1Click:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Velocity = Vector3.zero hrp.RotVelocity = Vector3.zero hrp.Anchored = true task.wait(0.5) if hrp then hrp.Anchored = false end end
end)

-- ESP
local function applyESP(char)
    if espActive then
        task.wait(0.5)
        if not char:FindFirstChild("LuxuryESP") then
            local hl = Instance.new("Highlight", char) hl.Name = "LuxuryESP" hl.FillColor = Color3.fromRGB(0, 255, 255) hl.OutlineColor = Color3.fromRGB(255, 0, 255)
        end
    end
end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(applyESP) end)
for _, p in pairs(Players:GetPlayers()) do p.CharacterAdded:Connect(applyESP) end

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
    SetESP(false) SetUltraRun(false) SetNoclip(false) SetChaosLag(false) SetSpin(false) SetCFSpeed(false) SetFly(false) TogglePlatform(false) ToggleInvis(false)
    undieActive, unvoidActive = false, false
    FlyUI.Visible, PlatUI.Visible = false, false
    stopInfTp() workspace.Gravity = 196.2
    local char = LocalPlayer.Character local hum = char and char:FindFirstChild("Humanoid") local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then if hrp:FindFirstChild("FlyBV") then hrp.FlyBV:Destroy() end if hrp:FindFirstChild("FlyBG") then hrp.FlyBG:Destroy() end hrp.Anchored = false end
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
