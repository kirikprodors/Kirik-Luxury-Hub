-- =======================================================
--                KIRIK HUB V2.0 (Delta Android)
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

-- Safe VirtualUser Fetch
local VirtualUser
pcall(function()
    VirtualUser = game:GetService("VirtualUser")
end)

-- Safe LocalPlayer & Camera Loading (Prevents immediate nil crash)
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end

local Camera = workspace.CurrentCamera
while not Camera do
    task.wait(0.1)
    Camera = workspace.CurrentCamera
end

local Mouse = LocalPlayer:GetMouse()

-- Base Dimensions & Scaling
local BASE_WIDTH = 560
local BASE_HEIGHT = 385
local TOPBAR_HEIGHT = 44
local currentScale = 1.0
local isMinimized = false

-- Stored Defaults for Complete Reset
local defaultWalkSpeed = 16
local defaultJumpPower = 50
local defaultGravity = workspace.Gravity
local defaultFOV = (Camera and Camera.FieldOfView) or 70
local defaultBrightness = pcall(function() return Lighting.Brightness end) and Lighting.Brightness or 2
local defaultClockTime = pcall(function() return Lighting.ClockTime end) and Lighting.ClockTime or 14
local defaultFogEnd = pcall(function() return Lighting.FogEnd end) and Lighting.FogEnd or 100000
local defaultGlobalShadows = pcall(function() return Lighting.GlobalShadows end) and Lighting.GlobalShadows or false
local defaultAmbient = pcall(function() return Lighting.Ambient end) and Lighting.Ambient or Color3.fromRGB(128, 128, 128)

-- Active Hack States
local flyEnabled = false
local flySpeed = 50
local flyBV, flyBG

local cfSpeedEnabled = false
local cfSpeedMultiplier = 2

local speedEnabled = false
local customWalkSpeed = 16

local jumpEnabled = false
local customJumpPower = 50

local gravityEnabled = false
local customGravity = workspace.Gravity

local noclipEnabled = false
local noclipConn = nil

-- Air Platform State
local platformEnabled = false
local platformPart = nil
local platformHeight = 0
local platformStep = 3

local freezeEnabled = false
local antiVoidEnabled = false
local lastSafeCFrame = nil

local hitboxEnabled = false
local hitboxSize = 10

local infJumpEnabled = false
local fullBrightEnabled = false
local espEnabled = false
local antiAfkEnabled = false

local fovEnabled = false
local customFOV = 70

local spinEnabled = false
local spinSpeed = 15
local spinConn = nil

-- Unified Teleport State
local currentTpMode = "Player"
local selectedTarget = nil
local selectedTargetName = "None"

local loopTpActive = false
local loopTpConn = nil
local viewActive = false

local scannedNPCs = {}
local partSelectingMode = false
local partHighlight = nil

-- Waypoint Chain State
local waypointChain = {}
local tweenSpeed = 30
local isTweening = false
local activeTweenInstance = nil

-- Custom Dynamic Tabs Registry
local customTabsRegistry = {}
local activeConnections = {}

-- Safe Previous Instance Cleanup
pcall(function()
    if gethui then
        local old = gethui():FindFirstChild("KirikHubV2")
        if old then old:Destroy() end
    end
    if game:GetService("CoreGui"):FindFirstChild("KirikHubV2") then
        game:GetService("CoreGui"):FindFirstChild("KirikHubV2"):Destroy()
    end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("KirikHubV2") then
        LocalPlayer.PlayerGui:FindFirstChild("KirikHubV2"):Destroy()
    end
end)

-- ScreenGui Setup with Bulletproof Fallback
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KirikHubV2"
ScreenGui.ResetOnSpawn = false

local mounted = false
if gethui then
    pcall(function()
        ScreenGui.Parent = gethui()
        mounted = true
    end)
end

if not mounted and syn and syn.protect_gui then
    pcall(function()
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = game:GetService("CoreGui")
        mounted = true
    end)
end

if not mounted then
    pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
        mounted = true
    end)
end

if not mounted or not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Forward Declarations
local switchTab
local createPage
local TabBar
local PageContainer

-- =======================================================
--                  CLEANUP & RESET LOGIC
-- =======================================================

local function clearWaypointMarkers()
    for _, wp in ipairs(waypointChain) do
        if wp.Marker then
            pcall(function() wp.Marker:Destroy() end)
        end
    end
end

local function stopTweening()
    isTweening = false
    if activeTweenInstance then
        activeTweenInstance:Cancel()
        activeTweenInstance = nil
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Anchored = false
        LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end
end

local function resetAllProcesses()
    for _, conn in pairs(activeConnections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
    activeConnections = {}

    -- Stop Waypoint Tween
    stopTweening()
    clearWaypointMarkers()
    waypointChain = {}

    -- Destroy Custom Tabs
    for tabName, tabData in pairs(customTabsRegistry) do
        if tabData.Cleanup then
            pcall(tabData.Cleanup)
        end
    end
    customTabsRegistry = {}

    -- Destroy Air Platform
    if platformPart then
        platformPart:Destroy()
        platformPart = nil
    end
    platformEnabled = false

    -- Reset Fly
    flyEnabled = false
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end

    -- Reset NoClip
    noclipEnabled = false
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end

    -- Reset Freeze & AntiVoid
    freezeEnabled = false
    antiVoidEnabled = false

    -- Reset Hitbox Expander
    hitboxEnabled = false
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            p.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
            p.Character.HumanoidRootPart.Transparency = 1
        end
    end

    -- Reset Spin
    spinEnabled = false
    if spinConn then spinConn:Disconnect() spinConn = nil end

    -- Reset Unified TP & Views
    loopTpActive = false
    if loopTpConn then loopTpConn:Disconnect() loopTpConn = nil end
    viewActive = false
    partSelectingMode = false

    if partHighlight then
        partHighlight:Destroy()
        partHighlight = nil
    end

    -- Reset Camera
    if Camera then
        Camera.FieldOfView = defaultFOV
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end

    -- Reset Lighting
    pcall(function()
        Lighting.Brightness = defaultBrightness
        Lighting.ClockTime = defaultClockTime
        Lighting.FogEnd = defaultFogEnd
        Lighting.GlobalShadows = defaultGlobalShadows
        Lighting.Ambient = defaultAmbient
    end)

    -- Reset ESP
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("KirikESP") then
            p.Character.KirikESP:Destroy()
        end
    end

    -- Reset Character
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Running, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, true)
            hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, true)
            hum.PlatformStand = false
            hum.WalkSpeed = defaultWalkSpeed
            hum.UseJumpPower = true
            hum.JumpPower = defaultJumpPower
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
        if root then
            root.Anchored = false
        end
    end

    -- Reset Gravity
    workspace.Gravity = defaultGravity
end

-- =======================================================
--                      MAIN WINDOW
-- =======================================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)
MainFrame.Position = UDim2.new(0.5, 0, 0.16, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local GlobalScale = Instance.new("UIScale")
GlobalScale.Scale = currentScale
GlobalScale.Parent = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 45, 62)
MainStroke.Thickness = 1.4
MainStroke.Parent = MainFrame

-- Top Bar / Header
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, TOPBAR_HEIGHT)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 12)
TopBarCorner.Parent = TopBar

local TopBarLine = Instance.new("Frame")
TopBarLine.Size = UDim2.new(1, 0, 0, 1)
TopBarLine.Position = UDim2.new(0, 0, 1, -1)
TopBarLine.BackgroundColor3 = Color3.fromRGB(40, 40, 56)
TopBarLine.BorderSizePixel = 0
TopBarLine.Parent = TopBar

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 14, 0.5, 0)
StatusDot.AnchorPoint = Vector2.new(0, 0.5)
StatusDot.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
StatusDot.BorderSizePixel = 0
StatusDot.Parent = TopBar

local DotCorner = Instance.new("UICorner")
DotCorner.CornerRadius = UDim.new(1, 0)
DotCorner.Parent = StatusDot

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Position = UDim2.new(0, 30, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KIRIK HUB V2.0"
Title.TextColor3 = Color3.fromRGB(248, 250, 252)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local HeaderButtons = Instance.new("Frame")
HeaderButtons.Size = UDim2.new(0, 70, 1, 0)
HeaderButtons.Position = UDim2.new(1, -78, 0, 0)
HeaderButtons.BackgroundTransparency = 1
HeaderButtons.Parent = TopBar

local HeaderLayout = Instance.new("UIListLayout")
HeaderLayout.FillDirection = Enum.FillDirection.Horizontal
HeaderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
HeaderLayout.Padding = UDim.new(0, 6)
HeaderLayout.Parent = HeaderButtons

-- Minimize Button (-) / (+)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Name = "MinimizeBtn"
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 48)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(220, 220, 240)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.Parent = HeaderButtons

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinimizeBtn

-- Close Button (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.BackgroundColor3 = Color3.fromRGB(225, 45, 55)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 13
CloseBtn.Parent = HeaderButtons

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

-- =======================================================
--            CONTENT & TABS CONTAINER
-- =======================================================

local BodyContainer = Instance.new("Frame")
BodyContainer.Name = "BodyContainer"
BodyContainer.Size = UDim2.new(1, 0, 1, -TOPBAR_HEIGHT)
BodyContainer.Position = UDim2.new(0, 0, 0, TOPBAR_HEIGHT)
BodyContainer.BackgroundTransparency = 1
BodyContainer.Parent = MainFrame

-- Scrollable Right-Side Tab Bar
TabBar = Instance.new("ScrollingFrame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(0, 122, 1, -16)
TabBar.Position = UDim2.new(1, -130, 0, 8)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TabBar.BorderSizePixel = 0
TabBar.ScrollBarThickness = 3
TabBar.ScrollBarImageColor3 = Color3.fromRGB(99, 102, 241)
TabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBar.Parent = BodyContainer

local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 8)
TabBarCorner.Parent = TabBar

local TabBarStroke = Instance.new("UIStroke")
TabBarStroke.Color = Color3.fromRGB(38, 38, 52)
TabBarStroke.Thickness = 1
TabBarStroke.Parent = TabBar

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.Parent = TabBar

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 8)
TabPadding.PaddingBottom = UDim.new(0, 8)
TabPadding.Parent = TabBar

-- Content Page View (Left Side)
PageContainer = Instance.new("Frame")
PageContainer.Name = "PageContainer"
PageContainer.Size = UDim2.new(1, -150, 1, -16)
PageContainer.Position = UDim2.new(0, 10, 0, 8)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = BodyContainer

-- =======================================================
--                 PAGES & TAB CONTROLLER
-- =======================================================

local Pages = {}
local tabButtons = {}
local tabFrames = {}

function createPage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(99, 102, 241)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.ScrollingDirection = Enum.ScrollingDirection.Y
    Page.ElasticBehavior = Enum.ElasticBehavior.Always
    Page.Visible = false
    Page.Parent = PageContainer

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 8)
    ListLayout.Parent = Page

    local Padding = Instance.new("UIPadding")
    Padding.PaddingTop = UDim.new(0, 2)
    Padding.PaddingLeft = UDim.new(0, 2)
    Padding.PaddingRight = UDim.new(0, 6)
    Padding.PaddingBottom = UDim.new(0, 12)
    Padding.Parent = Page

    Pages[name] = Page
    return Page
end

local HomePage = createPage("Home")
local EditorPage = createPage("Editor")
local SettingsPage = createPage("Settings")

function switchTab(name)
    for tabName, page in pairs(Pages) do
        local isSelected = (tabName == name)
        page.Visible = isSelected
        if tabButtons[tabName] then
            if isSelected then
                TweenService:Create(tabButtons[tabName], TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(99, 102, 241),
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                }):Play()
            else
                TweenService:Create(tabButtons[tabName], TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(28, 28, 38),
                    TextColor3 = Color3.fromRGB(150, 150, 170)
                }):Play()
            end
        end
    end
end

local function createTabButton(name, layoutOrder, isDeletable)
    local TabItemFrame = Instance.new("Frame")
    TabItemFrame.Name = name .. "TabItem"
    TabItemFrame.Size = UDim2.new(0.92, 0, 0, 36)
    TabItemFrame.BackgroundTransparency = 1
    TabItemFrame.LayoutOrder = layoutOrder
    TabItemFrame.Parent = TabBar

    local btn = Instance.new("TextButton")
    btn.Name = name .. "Btn"
    btn.Size = isDeletable and UDim2.new(1, -26, 1, 0) or UDim2.new(1, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 170)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    pcall(function() btn.TextTruncate = Enum.TextTruncate.AtEnd end)
    btn.Parent = TabItemFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn

    tabButtons[name] = btn
    tabFrames[name] = TabItemFrame

    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)

    if isDeletable then
        local delBtn = Instance.new("TextButton")
        delBtn.Name = "DeleteBtn"
        delBtn.Size = UDim2.new(0, 22, 1, 0)
        delBtn.Position = UDim2.new(1, -22, 0, 0)
        delBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        delBtn.Text = "X"
        delBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        delBtn.Font = Enum.Font.GothamBold
        delBtn.TextSize = 10
        delBtn.Parent = TabItemFrame

        local delCorner = Instance.new("UICorner")
        delCorner.CornerRadius = UDim.new(0, 5)
        delCorner.Parent = delBtn

        delBtn.MouseButton1Click:Connect(function()
            if customTabsRegistry[name] then
                pcall(customTabsRegistry[name].Cleanup)
                customTabsRegistry[name] = nil
            end

            if Pages[name] then
                Pages[name]:Destroy()
                Pages[name] = nil
            end

            TabItemFrame:Destroy()
            tabButtons[name] = nil
            tabFrames[name] = nil

            switchTab("Home")
        end)
    end
end

createTabButton("Home", 1, false)
createTabButton("Editor", 2, false)
createTabButton("Settings", 3, false)

switchTab("Home")

-- =======================================================
--              UI COMPONENT BUILDERS
-- =======================================================

local function createSectionHeader(parent, text)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 24)
    Header.BackgroundTransparency = 1
    Header.Parent = parent

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(120, 125, 180)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Header
end

local function createControlRow(parent, titleText, defaultVal, defaultToggleState, onToggle, onValChange)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 44)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Row.Parent = parent

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 8)
    RowCorner.Parent = Row

    local RowStroke = Instance.new("UIStroke")
    RowStroke.Color = Color3.fromRGB(36, 36, 48)
    RowStroke.Thickness = 1
    RowStroke.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -150, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = titleText
    Label.TextColor3 = Color3.fromRGB(235, 235, 245)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0, 64, 0, 26)
    InputBox.Position = UDim2.new(1, -126, 0.5, 0)
    InputBox.AnchorPoint = Vector2.new(0, 0.5)
    InputBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    InputBox.Text = tostring(defaultVal)
    InputBox.PlaceholderText = "Num"
    InputBox.TextColor3 = Color3.fromRGB(240, 240, 255)
    InputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    InputBox.Font = Enum.Font.GothamBold
    InputBox.TextSize = 12
    InputBox.ClearTextOnFocus = false
    InputBox.Parent = Row

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 5)
    InputCorner.Parent = InputBox

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(48, 48, 66)
    InputStroke.Thickness = 1
    InputStroke.Parent = InputBox

    InputBox.FocusLost:Connect(function()
        local num = tonumber(InputBox.Text)
        if num then
            pcall(onValChange, num)
        else
            InputBox.Text = tostring(defaultVal)
        end
    end)

    local isToggled = defaultToggleState or false
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 50, 0, 26)
    ToggleBtn.Position = UDim2.new(1, -56, 0.5, 0)
    ToggleBtn.AnchorPoint = Vector2.new(0, 0.5)
    ToggleBtn.BackgroundColor3 = isToggled and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(45, 45, 58)
    ToggleBtn.Text = isToggled and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 11
    ToggleBtn.Parent = Row

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = ToggleBtn

    ToggleBtn.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        ToggleBtn.Text = isToggled and "ON" or "OFF"
        TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = isToggled and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(45, 45, 58)
        }):Play()
        pcall(onToggle, isToggled)
    end)
end

local function createSimpleToggle(parent, titleText, defaultState, onToggle)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 44)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Row.Parent = parent

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 8)
    RowCorner.Parent = Row

    local RowStroke = Instance.new("UIStroke")
    RowStroke.Color = Color3.fromRGB(36, 36, 48)
    RowStroke.Thickness = 1
    RowStroke.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = titleText
    Label.TextColor3 = Color3.fromRGB(235, 235, 245)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local isToggled = defaultState or false
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 54, 0, 26)
    ToggleBtn.Position = UDim2.new(1, -60, 0.5, 0)
    ToggleBtn.AnchorPoint = Vector2.new(0, 0.5)
    ToggleBtn.BackgroundColor3 = isToggled and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(45, 45, 58)
    ToggleBtn.Text = isToggled and "ON" or "OFF"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 11
    ToggleBtn.Parent = Row

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = ToggleBtn

    ToggleBtn.MouseButton1Click:Connect(function()
        isToggled = not isToggled
        ToggleBtn.Text = isToggled and "ON" or "OFF"
        TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = isToggled and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(45, 45, 58)
        }):Play()
        pcall(onToggle, isToggled)
    end)
end

local function createButtonRow(parent, titleText, btnText, onClick)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 44)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Row.Parent = parent

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 8)
    RowCorner.Parent = Row

    local RowStroke = Instance.new("UIStroke")
    RowStroke.Color = Color3.fromRGB(36, 36, 48)
    RowStroke.Thickness = 1
    RowStroke.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -120, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = titleText
    Label.TextColor3 = Color3.fromRGB(235, 235, 245)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Size = UDim2.new(0, 95, 0, 26)
    ActionBtn.Position = UDim2.new(1, -105, 0.5, 0)
    ActionBtn.AnchorPoint = Vector2.new(0, 0.5)
    ActionBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
    ActionBtn.Text = btnText
    ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.Font = Enum.Font.GothamBold
    ActionBtn.TextSize = 11
    ActionBtn.Parent = Row

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = ActionBtn

    ActionBtn.MouseButton1Click:Connect(function()
        pcall(onClick)
    end)
end

local function createInputRow(parent, titleText, placeholder, defaultVal, callback)
    local Row = Instance.new("Frame")
    Row.Size = UDim2.new(1, 0, 0, 44)
    Row.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Row.Parent = parent

    local RowCorner = Instance.new("UICorner")
    RowCorner.CornerRadius = UDim.new(0, 8)
    RowCorner.Parent = Row

    local RowStroke = Instance.new("UIStroke")
    RowStroke.Color = Color3.fromRGB(36, 36, 48)
    RowStroke.Thickness = 1
    RowStroke.Parent = Row

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -110, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = titleText
    Label.TextColor3 = Color3.fromRGB(235, 235, 245)
    Label.Font = Enum.Font.GothamMedium
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Row

    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(0, 85, 0, 26)
    InputBox.Position = UDim2.new(1, -95, 0.5, 0)
    InputBox.AnchorPoint = Vector2.new(0, 0.5)
    InputBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    InputBox.Text = tostring(defaultVal or "")
    InputBox.PlaceholderText = placeholder or "Val"
    InputBox.TextColor3 = Color3.fromRGB(240, 240, 255)
    InputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
    InputBox.Font = Enum.Font.GothamBold
    InputBox.TextSize = 12
    InputBox.ClearTextOnFocus = false
    InputBox.Parent = Row

    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 5)
    InputCorner.Parent = InputBox

    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(48, 48, 66)
    InputStroke.Thickness = 1
    InputStroke.Parent = InputBox

    InputBox.FocusLost:Connect(function()
        pcall(callback, InputBox.Text)
    end)
end

-- =======================================================
--              HOME PAGE (CORE FEATURES)
-- =======================================================

createSectionHeader(HomePage, "--- MOVEMENT & PHYSICS ---")

-- 1. Fly Script
local function handleFly()
    if flyEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        flyBV = Instance.new("BodyVelocity")
        flyBV.Velocity = Vector3.zero
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Parent = root

        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.CFrame = root.CFrame
        flyBG.Parent = root

        hum.PlatformStand = true

        task.spawn(function()
            while flyEnabled and char and root and hum do
                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    flyBV.Velocity = (Camera.CFrame.LookVector * moveDir.Z * -1 + Camera.CFrame.RightVector * moveDir.X).Unit * flySpeed
                else
                    flyBV.Velocity = Vector3.zero
                end
                flyBG.CFrame = Camera.CFrame
                RunService.RenderStepped:Wait()
            end
        end)
    else
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
    end
end

createControlRow(HomePage, "Fly", 50, false, function(state)
    flyEnabled = state
    handleFly()
end, function(val)
    flySpeed = val
end)

-- 2. Follow Air Platform
local PlatformCard = Instance.new("Frame")
PlatformCard.Size = UDim2.new(1, 0, 0, 80)
PlatformCard.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
PlatformCard.Parent = HomePage

local PlatCorner = Instance.new("UICorner")
PlatCorner.CornerRadius = UDim.new(0, 8)
PlatCorner.Parent = PlatformCard

local PlatStroke = Instance.new("UIStroke")
PlatStroke.Color = Color3.fromRGB(36, 36, 48)
PlatStroke.Thickness = 1
PlatStroke.Parent = PlatformCard

local PlatLabel = Instance.new("TextLabel")
PlatLabel.Size = UDim2.new(1, -120, 0, 32)
PlatLabel.Position = UDim2.new(0, 12, 0, 4)
PlatLabel.BackgroundTransparency = 1
PlatLabel.Text = "Follow Air Platform"
PlatLabel.TextColor3 = Color3.fromRGB(235, 235, 245)
PlatLabel.Font = Enum.Font.GothamMedium
PlatLabel.TextSize = 13
PlatLabel.TextXAlignment = Enum.TextXAlignment.Left
PlatLabel.Parent = PlatformCard

local PlatToggleBtn = Instance.new("TextButton")
PlatToggleBtn.Size = UDim2.new(0, 54, 0, 26)
PlatToggleBtn.Position = UDim2.new(1, -64, 0, 7)
PlatToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
PlatToggleBtn.Text = "OFF"
PlatToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlatToggleBtn.Font = Enum.Font.GothamBold
PlatToggleBtn.TextSize = 11
PlatToggleBtn.Parent = PlatformCard

local PTBCorner = Instance.new("UICorner")
PTBCorner.CornerRadius = UDim.new(0, 5)
PTBCorner.Parent = PlatToggleBtn

local function toggleAirPlatform(state)
    platformEnabled = state
    PlatToggleBtn.Text = state and "ON" or "OFF"
    PlatToggleBtn.BackgroundColor3 = state and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(45, 45, 58)

    if state then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            if not platformPart or not platformPart.Parent then
                platformPart = Instance.new("Part")
                platformPart.Name = "KirikFollowPlatform"
                platformPart.Size = Vector3.new(7.5, 0.8, 7.5)
                platformPart.Anchored = true
                platformPart.CanCollide = true
                platformPart.Material = Enum.Material.Neon
                platformPart.Color = Color3.fromRGB(99, 102, 241)
                platformPart.Transparency = 0.35
                platformPart.Parent = workspace
            end
            platformHeight = root.Position.Y - 3.4
            platformPart.CFrame = CFrame.new(root.Position.X, platformHeight, root.Position.Z)
        end
    else
        if platformPart then
            platformPart:Destroy()
            platformPart = nil
        end
    end
end

PlatToggleBtn.MouseButton1Click:Connect(function()
    toggleAirPlatform(not platformEnabled)
end)

local platformConn = RunService.Heartbeat:Connect(function()
    if platformEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        if not platformPart or not platformPart.Parent then
            platformPart = Instance.new("Part")
            platformPart.Name = "KirikFollowPlatform"
            platformPart.Size = Vector3.new(7.5, 0.8, 7.5)
            platformPart.Anchored = true
            platformPart.CanCollide = true
            platformPart.Material = Enum.Material.Neon
            platformPart.Color = Color3.fromRGB(99, 102, 241)
            platformPart.Transparency = 0.35
            platformPart.Parent = workspace
            platformHeight = root.Position.Y - 3.4
        end
        platformPart.CFrame = CFrame.new(root.Position.X, platformHeight, root.Position.Z)
    end
end)
table.insert(activeConnections, platformConn)

local PlatControls = Instance.new("Frame")
PlatControls.Size = UDim2.new(1, -24, 0, 30)
PlatControls.Position = UDim2.new(0, 12, 0, 42)
PlatControls.BackgroundTransparency = 1
PlatControls.Parent = PlatformCard

local PlatLayout = Instance.new("UIListLayout")
PlatLayout.FillDirection = Enum.FillDirection.Horizontal
PlatLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
PlatLayout.Padding = UDim.new(0, 8)
PlatLayout.Parent = PlatControls

local PlatUpBtn = Instance.new("TextButton")
PlatUpBtn.Size = UDim2.new(0.35, 0, 1, 0)
PlatUpBtn.BackgroundColor3 = Color3.fromRGB(70, 90, 220)
PlatUpBtn.Text = "Platform UP (+)"
PlatUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlatUpBtn.Font = Enum.Font.GothamBold
PlatUpBtn.TextSize = 11
PlatUpBtn.Parent = PlatControls

local PUBound = Instance.new("UICorner")
PUBound.CornerRadius = UDim.new(0, 5)
PUBound.Parent = PlatUpBtn

local PlatDownBtn = Instance.new("TextButton")
PlatDownBtn.Size = UDim2.new(0.35, 0, 1, 0)
PlatDownBtn.BackgroundColor3 = Color3.fromRGB(70, 90, 220)
PlatDownBtn.Text = "Platform DOWN (-)"
PlatDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlatDownBtn.Font = Enum.Font.GothamBold
PlatDownBtn.TextSize = 11
PlatDownBtn.Parent = PlatControls

local PDBound = Instance.new("UICorner")
PDBound.CornerRadius = UDim.new(0, 5)
PDBound.Parent = PlatDownBtn

local StepInput = Instance.new("TextBox")
StepInput.Size = UDim2.new(0.24, 0, 1, 0)
StepInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StepInput.Text = "3"
StepInput.PlaceholderText = "Step"
StepInput.TextColor3 = Color3.fromRGB(240, 240, 255)
StepInput.Font = Enum.Font.GothamBold
StepInput.TextSize = 11
StepInput.ClearTextOnFocus = false
StepInput.Parent = PlatControls

local StepCorner = Instance.new("UICorner")
StepCorner.CornerRadius = UDim.new(0, 5)
StepCorner.Parent = StepInput

StepInput.FocusLost:Connect(function()
    local num = tonumber(StepInput.Text)
    if num and num > 0 then
        platformStep = num
    else
        StepInput.Text = tostring(platformStep)
    end
end)

PlatUpBtn.MouseButton1Click:Connect(function()
    if platformEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        platformHeight = platformHeight + platformStep
        if platformPart then
            platformPart.CFrame = CFrame.new(root.Position.X, platformHeight, root.Position.Z)
        end
        root.CFrame = root.CFrame + Vector3.new(0, platformStep, 0)
    end
end)

PlatDownBtn.MouseButton1Click:Connect(function()
    if platformEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        platformHeight = platformHeight - platformStep
        if platformPart then
            platformPart.CFrame = CFrame.new(root.Position.X, platformHeight, root.Position.Z)
        end
        root.CFrame = root.CFrame - Vector3.new(0, platformStep, 0)
    end
end)

-- 3. CF Speed
local cfConn = RunService.Heartbeat:Connect(function(delta)
    if cfSpeedEnabled and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * (cfSpeedMultiplier * 30) * delta)
        end
    end
end)
table.insert(activeConnections, cfConn)

createControlRow(HomePage, "CF Speed", 2, false, function(state)
    cfSpeedEnabled = state
end, function(val)
    cfSpeedMultiplier = val
end)

-- 4. WalkSpeed
local wsConn = RunService.RenderStepped:Connect(function()
    if speedEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = customWalkSpeed end
    end
end)
table.insert(activeConnections, wsConn)

createControlRow(HomePage, "WalkSpeed", 16, false, function(state)
    speedEnabled = state
    if not state and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = defaultWalkSpeed end
    end
end, function(val)
    customWalkSpeed = val
end)

-- 5. Jump Power
local jpConn = RunService.RenderStepped:Connect(function()
    if jumpEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = customJumpPower
        end
    end
end)
table.insert(activeConnections, jpConn)

createControlRow(HomePage, "Jump Power", 50, false, function(state)
    jumpEnabled = state
    if not state and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = defaultJumpPower end
    end
end, function(val)
    customJumpPower = val
end)

-- 6. Gravity
createControlRow(HomePage, "Gravity", 196, false, function(state)
    gravityEnabled = state
    if state then
        workspace.Gravity = customGravity
    else
        workspace.Gravity = defaultGravity
    end
end, function(val)
    customGravity = val
    if gravityEnabled then
        workspace.Gravity = customGravity
    end
end)

-- 7. Bulletproof No-Clip (Wall Hack)
createSimpleToggle(HomePage, "No-Clip (Wall Hack)", false, function(state)
    noclipEnabled = state
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if state then
        noclipConn = RunService.Stepped:Connect(function()
            if (noclipEnabled or isTweening) and LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                        part.CanTouch = false
                    end
                end
            end
        end)
        table.insert(activeConnections, noclipConn)
    end
end)

-- 8. Freeze Position
createSimpleToggle(HomePage, "Freeze / Anchor Player", false, function(state)
    freezeEnabled = state
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Anchored = state
    end
end)

-- 9. Anti-Void Fall Protector
createSimpleToggle(HomePage, "Anti-Void Fall Protector", false, function(state)
    antiVoidEnabled = state
end)

local antiVoidConn = RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        if root.Position.Y > (workspace.FallenPartsDestroyHeight + 30) then
            lastSafeCFrame = root.CFrame
        elseif antiVoidEnabled and root.Position.Y <= (workspace.FallenPartsDestroyHeight + 25) then
            if lastSafeCFrame then
                root.CFrame = lastSafeCFrame + Vector3.new(0, 10, 0)
                root.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end)
table.insert(activeConnections, antiVoidConn)

-- 10. Infinite Jump
createSimpleToggle(HomePage, "Infinite Jump", false, function(state)
    infJumpEnabled = state
end)

local infJumpConn = UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
table.insert(activeConnections, infJumpConn)

-- =======================================================
--       UNIFIED TELEPORT & TWEEN CHAIN TP HUB
-- =======================================================

createSectionHeader(HomePage, "--- UNIFIED TELEPORT & TWEEN TP ---")

local UnifiedTPCard = Instance.new("Frame")
UnifiedTPCard.Size = UDim2.new(1, 0, 0, 270)
UnifiedTPCard.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
UnifiedTPCard.Parent = HomePage

local UTCorner = Instance.new("UICorner")
UTCorner.CornerRadius = UDim.new(0, 8)
UTCorner.Parent = UnifiedTPCard

local UTStroke = Instance.new("UIStroke")
UTStroke.Color = Color3.fromRGB(36, 36, 48)
UTStroke.Thickness = 1
UTStroke.Parent = UnifiedTPCard

local ModeSelector = Instance.new("Frame")
ModeSelector.Size = UDim2.new(1, -16, 0, 30)
ModeSelector.Position = UDim2.new(0, 8, 0, 8)
ModeSelector.BackgroundTransparency = 1
ModeSelector.Parent = UnifiedTPCard

local ModeLayout = Instance.new("UIListLayout")
ModeLayout.FillDirection = Enum.FillDirection.Horizontal
ModeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ModeLayout.Padding = UDim.new(0, 6)
ModeLayout.Parent = ModeSelector

local modeButtons = {}
local modeViews = {}

local StatusBanner = Instance.new("TextLabel")
StatusBanner.Size = UDim2.new(1, -16, 0, 22)
StatusBanner.Position = UDim2.new(0, 8, 0, 42)
StatusBanner.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusBanner.Text = "Selected: None"
StatusBanner.TextColor3 = Color3.fromRGB(130, 200, 255)
StatusBanner.Font = Enum.Font.GothamBold
StatusBanner.TextSize = 11
StatusBanner.Parent = UnifiedTPCard

local SBCorner = Instance.new("UICorner")
SBCorner.CornerRadius = UDim.new(0, 5)
SBCorner.Parent = StatusBanner

local function getTargetCFrame()
    if currentTpMode == "Player" and typeof(selectedTarget) == "Instance" and selectedTarget:IsA("Player") and selectedTarget.Character then
        local root = selectedTarget.Character:FindFirstChild("HumanoidRootPart") or selectedTarget.Character:FindFirstChild("Torso")
        return root and (root.CFrame + Vector3.new(0, 2.5, 0))
    elseif currentTpMode == "NPC" and type(selectedTarget) == "table" and selectedTarget.Root and selectedTarget.Root.Parent then
        return selectedTarget.Root.CFrame + Vector3.new(0, 3, 0)
    elseif currentTpMode == "Part" and typeof(selectedTarget) == "Instance" and selectedTarget:IsA("BasePart") and selectedTarget.Parent then
        return selectedTarget.CFrame + Vector3.new(0, 3.5, 0)
    end
    return nil
end

local function getTargetCameraSubject()
    if currentTpMode == "Player" and typeof(selectedTarget) == "Instance" and selectedTarget:IsA("Player") and selectedTarget.Character then
        return selectedTarget.Character:FindFirstChildOfClass("Humanoid")
    elseif currentTpMode == "NPC" and type(selectedTarget) == "table" and selectedTarget.Hum then
        return selectedTarget.Hum
    elseif currentTpMode == "Part" and typeof(selectedTarget) == "Instance" and selectedTarget:IsA("BasePart") then
        return selectedTarget
    end
    return nil
end

-- 1. Players List View
local PlayersListView = Instance.new("ScrollingFrame")
PlayersListView.Size = UDim2.new(1, -16, 0, 150)
PlayersListView.Position = UDim2.new(0, 8, 0, 68)
PlayersListView.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
PlayersListView.BorderSizePixel = 0
PlayersListView.ScrollBarThickness = 3
PlayersListView.ScrollBarImageColor3 = Color3.fromRGB(99, 102, 241)
PlayersListView.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayersListView.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayersListView.Visible = true
PlayersListView.Parent = UnifiedTPCard

local PLCorner = Instance.new("UICorner")
PLCorner.CornerRadius = UDim.new(0, 6)
PLCorner.Parent = PlayersListView

local PLLayout = Instance.new("UIListLayout")
PLLayout.SortOrder = Enum.SortOrder.LayoutOrder
PLLayout.Padding = UDim.new(0, 4)
PLLayout.Parent = PlayersListView

local PLPadding = Instance.new("UIPadding")
PLPadding.PaddingTop = UDim.new(0, 4)
PLPadding.PaddingLeft = UDim.new(0, 4)
PLPadding.PaddingRight = UDim.new(0, 4)
PLPadding.PaddingBottom = UDim.new(0, 4)
PLPadding.Parent = PlayersListView

modeViews["Player"] = PlayersListView

local function refreshPlayersList()
    for _, child in ipairs(PlayersListView:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 26)
            btn.BackgroundColor3 = (selectedTarget == p) and Color3.fromRGB(70, 75, 180) or Color3.fromRGB(28, 28, 38)
            btn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            btn.TextColor3 = Color3.fromRGB(240, 240, 255)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 11
            btn.Parent = PlayersListView

            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 4)
            bCorner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                selectedTarget = p
                selectedTargetName = p.DisplayName .. " (@" .. p.Name .. ")"
                StatusBanner.Text = "Selected Player: " .. selectedTargetName
                refreshPlayersList()
            end)
        end
    end
end

-- 2. NPCs List View
local NPCsContainer = Instance.new("Frame")
NPCsContainer.Size = UDim2.new(1, -16, 0, 150)
NPCsContainer.Position = UDim2.new(0, 8, 0, 68)
NPCsContainer.BackgroundTransparency = 1
NPCsContainer.Visible = false
NPCsContainer.Parent = UnifiedTPCard

local RefreshNPCBtn = Instance.new("TextButton")
RefreshNPCBtn.Size = UDim2.new(1, 0, 0, 24)
RefreshNPCBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
RefreshNPCBtn.Text = "Scan / Refresh NPCs"
RefreshNPCBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshNPCBtn.Font = Enum.Font.GothamBold
RefreshNPCBtn.TextSize = 11
RefreshNPCBtn.Parent = NPCsContainer

local RCorner = Instance.new("UICorner")
RCorner.CornerRadius = UDim.new(0, 5)
RCorner.Parent = RefreshNPCBtn

local NPCsListView = Instance.new("ScrollingFrame")
NPCsListView.Size = UDim2.new(1, 0, 1, -28)
NPCsListView.Position = UDim2.new(0, 0, 0, 28)
NPCsListView.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
NPCsListView.BorderSizePixel = 0
NPCsListView.ScrollBarThickness = 3
NPCsListView.ScrollBarImageColor3 = Color3.fromRGB(99, 102, 241)
NPCsListView.AutomaticCanvasSize = Enum.AutomaticSize.Y
NPCsListView.CanvasSize = UDim2.new(0, 0, 0, 0)
NPCsListView.Parent = NPCsContainer

local NLCorner = Instance.new("UICorner")
NLCorner.CornerRadius = UDim.new(0, 6)
NLCorner.Parent = NPCsListView

local NLLayout = Instance.new("UIListLayout")
NLLayout.SortOrder = Enum.SortOrder.LayoutOrder
NLLayout.Padding = UDim.new(0, 4)
NLLayout.Parent = NPCsListView

local NLPadding = Instance.new("UIPadding")
NLPadding.PaddingTop = UDim.new(0, 4)
NLPadding.PaddingLeft = UDim.new(0, 4)
NLPadding.PaddingRight = UDim.new(0, 4)
NLPadding.PaddingBottom = UDim.new(0, 4)
NLPadding.Parent = NPCsListView

modeViews["NPC"] = NPCsContainer

local function scanAndRefreshNPCs()
    scannedNPCs = {}
    local playerModels = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then playerModels[p.Character] = true end
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Parent and obj.Parent:IsA("Model") and not playerModels[obj.Parent] then
            local root = obj.Parent:FindFirstChild("HumanoidRootPart") or obj.Parent:FindFirstChild("Torso") or obj.Parent:FindFirstChild("Head") or obj.Parent.PrimaryPart
            if root then
                table.insert(scannedNPCs, {Model = obj.Parent, Root = root, Hum = obj, Name = obj.Parent.Name})
            end
        end
    end

    for _, child in ipairs(NPCsListView:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end

    if #scannedNPCs == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, 0, 0, 30)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "No NPCs Found in Workspace"
        emptyLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.TextSize = 11
        emptyLabel.Parent = NPCsListView
    else
        for i, npc in ipairs(scannedNPCs) do
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 26)
            btn.BackgroundColor3 = (selectedTarget == npc) and Color3.fromRGB(70, 75, 180) or Color3.fromRGB(28, 28, 38)
            btn.Text = tostring(i) .. ". " .. npc.Name
            btn.TextColor3 = Color3.fromRGB(240, 240, 255)
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 11
            btn.Parent = NPCsListView

            local bCorner = Instance.new("UICorner")
            bCorner.CornerRadius = UDim.new(0, 4)
            bCorner.Parent = btn

            btn.MouseButton1Click:Connect(function()
                selectedTarget = npc
                selectedTargetName = npc.Name
                StatusBanner.Text = "Selected NPC: " .. selectedTargetName
                scanAndRefreshNPCs()
            end)
        end
    end
end

RefreshNPCBtn.MouseButton1Click:Connect(scanAndRefreshNPCs)

-- 3. Parts Selector & Tween Chain View
local PartsContainer = Instance.new("Frame")
PartsContainer.Size = UDim2.new(1, -16, 0, 150)
PartsContainer.Position = UDim2.new(0, 8, 0, 68)
PartsContainer.BackgroundTransparency = 1
PartsContainer.Visible = false
PartsContainer.Parent = UnifiedTPCard

local SelectPartActionBtn = Instance.new("TextButton")
SelectPartActionBtn.Size = UDim2.new(1, 0, 0, 30)
SelectPartActionBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
SelectPartActionBtn.Text = "Tap / Click Any In-Game Object"
SelectPartActionBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
SelectPartActionBtn.Font = Enum.Font.GothamMedium
SelectPartActionBtn.TextSize = 11
SelectPartActionBtn.Parent = PartsContainer

local SPBCorner = Instance.new("UICorner")
SPBCorner.CornerRadius = UDim.new(0, 6)
SPBCorner.Parent = SelectPartActionBtn

SelectPartActionBtn.MouseButton1Click:Connect(function()
    partSelectingMode = true
    SelectPartActionBtn.Text = ">> TAP ANY PHYSICAL OBJECT IN-GAME NOW <<"
    SelectPartActionBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 130)
end)

local partTapConn = UserInputService.InputBegan:Connect(function(input, processed)
    if partSelectingMode and not processed then
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local target = Mouse.Target
            if target and target:IsA("BasePart") then
                selectedTarget = target
                selectedTargetName = target.Name .. " (" .. target.Parent.Name .. ")"
                partSelectingMode = false

                if partHighlight then partHighlight:Destroy() end
                partHighlight = Instance.new("SelectionBox")
                partHighlight.Adornee = target
                partHighlight.Color3 = Color3.fromRGB(99, 102, 241)
                partHighlight.LineThickness = 0.05
                partHighlight.Parent = target

                SelectPartActionBtn.Text = "Selected: " .. selectedTargetName
                SelectPartActionBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
                StatusBanner.Text = "Selected Part: " .. selectedTargetName
            end
        end
    end
end)
table.insert(activeConnections, partTapConn)

local ChainControlRow = Instance.new("Frame")
ChainControlRow.Size = UDim2.new(1, 0, 0, 30)
ChainControlRow.Position = UDim2.new(0, 0, 0, 36)
ChainControlRow.BackgroundTransparency = 1
ChainControlRow.Parent = PartsContainer

local AddChainBtn = Instance.new("TextButton")
AddChainBtn.Size = UDim2.new(0.60, -4, 1, 0)
AddChainBtn.BackgroundColor3 = Color3.fromRGB(70, 90, 220)
AddChainBtn.Text = "+ Add to Twin Chain (0)"
AddChainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AddChainBtn.Font = Enum.Font.GothamBold
AddChainBtn.TextSize = 11
AddChainBtn.Parent = ChainControlRow

local ACCorner = Instance.new("UICorner")
ACCorner.CornerRadius = UDim.new(0, 5)
ACCorner.Parent = AddChainBtn

local ClearChainBtn = Instance.new("TextButton")
ClearChainBtn.Size = UDim2.new(0.40, -4, 1, 0)
ClearChainBtn.Position = UDim2.new(0.60, 4, 0, 0)
ClearChainBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
ClearChainBtn.Text = "Clear Chain"
ClearChainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearChainBtn.Font = Enum.Font.GothamBold
ClearChainBtn.TextSize = 11
ClearChainBtn.Parent = ChainControlRow

local CCCorner = Instance.new("UICorner")
CCCorner.CornerRadius = UDim.new(0, 5)
CCCorner.Parent = ClearChainBtn

AddChainBtn.MouseButton1Click:Connect(function()
    if typeof(selectedTarget) == "Instance" and selectedTarget:IsA("BasePart") then
        local index = #waypointChain + 1
        local targetCF = selectedTarget.CFrame + Vector3.new(0, 3, 0)

        local bb = Instance.new("BillboardGui")
        bb.Name = "KirikWaypoint_" .. tostring(index)
        bb.Size = UDim2.new(0, 45, 0, 22)
        bb.AlwaysOnTop = true
        bb.Adornee = selectedTarget

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
        txt.TextColor3 = Color3.fromRGB(255, 255, 255)
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 11
        txt.Text = "#" .. tostring(index)
        txt.Parent = bb

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = txt
        bb.Parent = selectedTarget

        table.insert(waypointChain, {
            Part = selectedTarget,
            CFrame = targetCF,
            Marker = bb,
            Index = index
        })

        AddChainBtn.Text = "+ Add to Twin Chain (" .. tostring(#waypointChain) .. ")"
    end
end)

ClearChainBtn.MouseButton1Click:Connect(function()
    stopTweening()
    clearWaypointMarkers()
    waypointChain = {}
    AddChainBtn.Text = "+ Add to Twin Chain (0)"
end)

local TweenRunRow = Instance.new("Frame")
TweenRunRow.Size = UDim2.new(1, 0, 0, 36)
TweenRunRow.Position = UDim2.new(0, 0, 0, 72)
TweenRunRow.BackgroundTransparency = 1
TweenRunRow.Parent = PartsContainer

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(0.35, 0, 1, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Twin Speed:"
SpeedLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
SpeedLabel.Font = Enum.Font.GothamMedium
SpeedLabel.TextSize = 11
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = TweenRunRow

local TweenSpeedInput = Instance.new("TextBox")
TweenSpeedInput.Size = UDim2.new(0.25, -6, 0, 28)
TweenSpeedInput.Position = UDim2.new(0.35, 0, 0.5, 0)
TweenSpeedInput.AnchorPoint = Vector2.new(0, 0.5)
TweenSpeedInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TweenSpeedInput.Text = "30"
TweenSpeedInput.TextColor3 = Color3.fromRGB(240, 240, 255)
TweenSpeedInput.Font = Enum.Font.GothamBold
TweenSpeedInput.TextSize = 12
TweenSpeedInput.ClearTextOnFocus = false
TweenSpeedInput.Parent = TweenRunRow

local TSICorner = Instance.new("UICorner")
TSICorner.CornerRadius = UDim.new(0, 5)
TSICorner.Parent = TweenSpeedInput

TweenSpeedInput.FocusLost:Connect(function()
    local val = tonumber(TweenSpeedInput.Text)
    if val and val > 0 then
        tweenSpeed = val
    else
        TweenSpeedInput.Text = tostring(tweenSpeed)
    end
end)

local RunTweenBtn = Instance.new("TextButton")
RunTweenBtn.Size = UDim2.new(0.40, 0, 0, 28)
RunTweenBtn.Position = UDim2.new(0.60, 0, 0.5, 0)
RunTweenBtn.AnchorPoint = Vector2.new(0, 0.5)
RunTweenBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
RunTweenBtn.Text = "Run Twin TP"
RunTweenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RunTweenBtn.Font = Enum.Font.GothamBold
RunTweenBtn.TextSize = 11
RunTweenBtn.Parent = TweenRunRow

local RTCorner = Instance.new("UICorner")
RTCorner.CornerRadius = UDim.new(0, 5)
RTCorner.Parent = RunTweenBtn

RunTweenBtn.MouseButton1Click:Connect(function()
    if isTweening then
        stopTweening()
        RunTweenBtn.Text = "Run Twin TP"
        RunTweenBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
        return
    end

    if #waypointChain == 0 or not LocalPlayer.Character then return end
    local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    isTweening = true
    RunTweenBtn.Text = "Stop Twin TP"
    RunTweenBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)

    task.spawn(function()
        for _, wp in ipairs(waypointChain) do
            if not isTweening or not LocalPlayer.Character then break end
            local currentRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not currentRoot then break end

            local destCF = (wp.Part and wp.Part.Parent) and (wp.Part.CFrame + Vector3.new(0, 3, 0)) or wp.CFrame
            local dist = (currentRoot.Position - destCF.Position).Magnitude
            local duration = math.max(dist / math.max(tweenSpeed, 1), 0.05)

            currentRoot.Anchored = true
            currentRoot.AssemblyLinearVelocity = Vector3.zero
            currentRoot.AssemblyAngularVelocity = Vector3.zero

            activeTweenInstance = TweenService:Create(currentRoot, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                CFrame = destCF
            })
            activeTweenInstance:Play()

            local done = false
            local conn = activeTweenInstance.Completed:Connect(function()
                done = true
            end)

            while not done and isTweening do
                task.wait()
            end
            if conn then conn:Disconnect() end
        end

        stopTweening()
        RunTweenBtn.Text = "Run Twin TP"
        RunTweenBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    end)
end)

modeViews["Part"] = PartsContainer

local function createModeBtn(name, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.32, 0, 1, 0)
    btn.BackgroundColor3 = (currentTpMode == name) and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(28, 28, 38)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = ModeSelector

    local mCorner = Instance.new("UICorner")
    mCorner.CornerRadius = UDim.new(0, 6)
    mCorner.Parent = btn

    modeButtons[name] = btn

    btn.MouseButton1Click:Connect(function()
        currentTpMode = name
        selectedTarget = nil
        StatusBanner.Text = "Selected: None"

        for mName, mBtn in pairs(modeButtons) do
            mBtn.BackgroundColor3 = (mName == name) and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(28, 28, 38)
        end
        for mName, mView in pairs(modeViews) do
            mView.Visible = (mName == name)
        end

        if name == "Player" then
            refreshPlayersList()
        elseif name == "NPC" then
            scanAndRefreshNPCs()
        end
    end)
end

createModeBtn("Player", "Players")
createModeBtn("NPC", "NPCs")
createModeBtn("Part", "Parts")

refreshPlayersList()
Players.PlayerAdded:Connect(refreshPlayersList)
Players.PlayerRemoving:Connect(refreshPlayersList)

-- Bottom Unified Action Buttons
local UnifiedActions = Instance.new("Frame")
UnifiedActions.Size = UDim2.new(1, -16, 0, 34)
UnifiedActions.Position = UDim2.new(0, 8, 0, 226)
UnifiedActions.BackgroundTransparency = 1
UnifiedActions.Parent = UnifiedTPCard

local UALayout = Instance.new("UIListLayout")
UALayout.FillDirection = Enum.FillDirection.Horizontal
UALayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UALayout.Padding = UDim.new(0, 6)
UALayout.Parent = UnifiedActions

local Uni_TpBtn = Instance.new("TextButton")
Uni_TpBtn.Size = UDim2.new(0.32, 0, 1, 0)
Uni_TpBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
Uni_TpBtn.Text = "Teleport"
Uni_TpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Uni_TpBtn.Font = Enum.Font.GothamBold
Uni_TpBtn.TextSize = 11
Uni_TpBtn.Parent = UnifiedActions

local UTpCorner = Instance.new("UICorner")
UTpCorner.CornerRadius = UDim.new(0, 5)
UTpCorner.Parent = Uni_TpBtn

Uni_TpBtn.MouseButton1Click:Connect(function()
    local cf = getTargetCFrame()
    if cf and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = cf
        LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
    end
end)

local Uni_LoopBtn = Instance.new("TextButton")
Uni_LoopBtn.Size = UDim2.new(0.32, 0, 1, 0)
Uni_LoopBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
Uni_LoopBtn.Text = "Loop TP: OFF"
Uni_LoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Uni_LoopBtn.Font = Enum.Font.GothamBold
Uni_LoopBtn.TextSize = 11
Uni_LoopBtn.Parent = UnifiedActions

local ULoopCorner = Instance.new("UICorner")
ULoopCorner.CornerRadius = UDim.new(0, 5)
ULoopCorner.Parent = Uni_LoopBtn

Uni_LoopBtn.MouseButton1Click:Connect(function()
    loopTpActive = not loopTpActive
    Uni_LoopBtn.Text = loopTpActive and "Loop TP: ON" or "Loop TP: OFF"
    Uni_LoopBtn.BackgroundColor3 = loopTpActive and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(45, 45, 58)
end)

local loopTpRunner = RunService.Heartbeat:Connect(function()
    if loopTpActive and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local cf = getTargetCFrame()
        if cf then
            LocalPlayer.Character.HumanoidRootPart.CFrame = cf
            LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)
table.insert(activeConnections, loopTpRunner)

local Uni_ViewBtn = Instance.new("TextButton")
Uni_ViewBtn.Size = UDim2.new(0.32, 0, 1, 0)
Uni_ViewBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
Uni_ViewBtn.Text = "View: OFF"
Uni_ViewBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Uni_ViewBtn.Font = Enum.Font.GothamBold
Uni_ViewBtn.TextSize = 11
Uni_ViewBtn.Parent = UnifiedActions

local UViewCorner = Instance.new("UICorner")
UViewCorner.CornerRadius = UDim.new(0, 5)
UViewCorner.Parent = Uni_ViewBtn

Uni_ViewBtn.MouseButton1Click:Connect(function()
    viewActive = not viewActive
    Uni_ViewBtn.Text = viewActive and "View: ON" or "View: OFF"
    Uni_ViewBtn.BackgroundColor3 = viewActive and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(45, 45, 58)

    if viewActive then
        local subj = getTargetCameraSubject()
        if subj then Camera.CameraSubject = subj end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        end
    end
end)

createButtonRow(HomePage, "Click TP Tool", "Get Tool", function()
    local tool = Instance.new("Tool")
    tool.Name = "TP Tool"
    tool.RequiresHandle = false
    tool.Activated:Connect(function()
        local pos = Mouse.Hit.Position
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
        end
    end)
    tool.Parent = LocalPlayer.Backpack
end)

-- =======================================================
--              COMBAT & VISUAL UTILITIES
-- =======================================================

createSectionHeader(HomePage, "--- COMBAT & VISUALS ---")

-- Hitbox Expander
createControlRow(HomePage, "Hitbox Expander", 10, false, function(state)
    hitboxEnabled = state
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            if state then
                root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                root.Transparency = 0.6
                root.BrickColor = BrickColor.new("Really red")
                root.Material = Enum.Material.Neon
                root.CanCollide = false
            else
                root.Size = Vector3.new(2, 2, 1)
                root.Transparency = 1
            end
        end
    end
end, function(val)
    hitboxSize = val
end)

local hitboxConn = RunService.RenderStepped:Connect(function()
    if hitboxEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local root = p.Character.HumanoidRootPart
                root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                root.Transparency = 0.6
                root.CanCollide = false
            end
        end
    end
end)
table.insert(activeConnections, hitboxConn)

-- Player ESP
local function updateESP()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local existing = p.Character:FindFirstChild("KirikESP")
            if espEnabled then
                if not existing then
                    local hl = Instance.new("Highlight")
                    hl.Name = "KirikESP"
                    hl.FillColor = Color3.fromRGB(99, 102, 241)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.Parent = p.Character
                end
            else
                if existing then existing:Destroy() end
            end
        end
    end
end

createSimpleToggle(HomePage, "Player ESP (Wallhack)", false, function(state)
    espEnabled = state
    updateESP()
end)

local espPlayerConn = Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espEnabled then updateESP() end
    end)
end)
table.insert(activeConnections, espPlayerConn)

-- FullBright
createSimpleToggle(HomePage, "FullBright / Night Vision", false, function(state)
    fullBrightEnabled = state
    if state then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = defaultBrightness
        Lighting.ClockTime = defaultClockTime
        Lighting.FogEnd = defaultFogEnd
        Lighting.GlobalShadows = defaultGlobalShadows
        Lighting.Ambient = defaultAmbient
    end
end)

-- Camera FOV
createControlRow(HomePage, "Camera FOV", 70, false, function(state)
    fovEnabled = state
    if state then
        Camera.FieldOfView = customFOV
    else
        Camera.FieldOfView = defaultFOV
    end
end, function(val)
    customFOV = val
    if fovEnabled then
        Camera.FieldOfView = customFOV
    end
end)

-- SpinBot
createControlRow(HomePage, "SpinBot", 15, false, function(state)
    spinEnabled = state
    if spinConn then spinConn:Disconnect() spinConn = nil end
    if state then
        spinConn = RunService.RenderStepped:Connect(function()
            if spinEnabled and LocalPlayer.Character then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
                end
            end
        end)
        table.insert(activeConnections, spinConn)
    end
end, function(val)
    spinSpeed = val
end)

-- Anti-AFK
createSimpleToggle(HomePage, "Anti-AFK (No 20m Kick)", false, function(state)
    antiAfkEnabled = state
end)

local afkConn = LocalPlayer.Idled:Connect(function()
    if antiAfkEnabled and VirtualUser then
        pcall(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end
end)
table.insert(activeConnections, afkConn)

-- Delete Tool / BTools
createButtonRow(HomePage, "Client Delete Tool (BTools)", "Get Tool", function()
    local btool = Instance.new("Tool")
    btool.Name = "Delete Tool"
    btool.RequiresHandle = false
    btool.Activated:Connect(function()
        local target = Mouse.Target
        if target and target.Parent and not target:IsA("Terrain") then
            target:Destroy()
        end
    end)
    btool.Parent = LocalPlayer.Backpack
end)

-- =======================================================
--            EDITOR TAB (LUAU TAB BUILDER)
-- =======================================================

createSectionHeader(EditorPage, "--- LUAU TAB BUILDER ---")

local EditorActionRow = Instance.new("Frame")
EditorActionRow.Size = UDim2.new(1, 0, 0, 32)
EditorActionRow.BackgroundTransparency = 1
EditorActionRow.Parent = EditorPage

local EARLayout = Instance.new("UIListLayout")
EARLayout.FillDirection = Enum.FillDirection.Horizontal
EARLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
EARLayout.Padding = UDim.new(0, 6)
EARLayout.Parent = EditorActionRow

local RunScriptBtn = Instance.new("TextButton")
RunScriptBtn.Size = UDim2.new(0, 95, 1, 0)
RunScriptBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
RunScriptBtn.Text = "Run Tab"
RunScriptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RunScriptBtn.Font = Enum.Font.GothamBold
RunScriptBtn.TextSize = 11
RunScriptBtn.Parent = EditorActionRow

local RSBCorner = Instance.new("UICorner")
RSBCorner.CornerRadius = UDim.new(0, 6)
RSBCorner.Parent = RunScriptBtn

local PasteBtn = Instance.new("TextButton")
PasteBtn.Size = UDim2.new(0, 65, 1, 0)
PasteBtn.BackgroundColor3 = Color3.fromRGB(70, 90, 220)
PasteBtn.Text = "Paste"
PasteBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PasteBtn.Font = Enum.Font.GothamMedium
PasteBtn.TextSize = 11
PasteBtn.Parent = EditorActionRow

local PBCorner = Instance.new("UICorner")
PBCorner.CornerRadius = UDim.new(0, 6)
PBCorner.Parent = PasteBtn

local TemplateBtn = Instance.new("TextButton")
TemplateBtn.Size = UDim2.new(0, 80, 1, 0)
TemplateBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
TemplateBtn.Text = "Template"
TemplateBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
TemplateBtn.Font = Enum.Font.GothamMedium
TemplateBtn.TextSize = 11
TemplateBtn.Parent = EditorActionRow

local TmpCorner = Instance.new("UICorner")
TmpCorner.CornerRadius = UDim.new(0, 6)
TmpCorner.Parent = TemplateBtn

local ClearCodeBtn = Instance.new("TextButton")
ClearCodeBtn.Size = UDim2.new(0, 65, 1, 0)
ClearCodeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
ClearCodeBtn.Text = "Clear"
ClearCodeBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
ClearCodeBtn.Font = Enum.Font.GothamMedium
ClearCodeBtn.TextSize = 11
ClearCodeBtn.Parent = EditorActionRow

local CCBCorner = Instance.new("UICorner")
CCBCorner.CornerRadius = UDim.new(0, 6)
CCCorner.Parent = ClearCodeBtn

local DocsToggleBtn = Instance.new("TextButton")
DocsToggleBtn.Size = UDim2.new(0, 65, 1, 0)
DocsToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
DocsToggleBtn.Text = "Docs"
DocsToggleBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
DocsToggleBtn.Font = Enum.Font.GothamMedium
DocsToggleBtn.TextSize = 11
DocsToggleBtn.Parent = EditorActionRow

local DCBCorner = Instance.new("UICorner")
DCBCorner.CornerRadius = UDim.new(0, 6)
DCBCorner.Parent = DocsToggleBtn

-- Status Console Banner
local EditorStatus = Instance.new("TextLabel")
EditorStatus.Size = UDim2.new(1, 0, 0, 24)
EditorStatus.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
EditorStatus.Text = "Status: Ready to build tab."
EditorStatus.TextColor3 = Color3.fromRGB(150, 150, 180)
EditorStatus.Font = Enum.Font.GothamMedium
EditorStatus.TextSize = 11
EditorStatus.TextXAlignment = Enum.TextXAlignment.Left
EditorStatus.Parent = EditorPage

local ESCorner = Instance.new("UICorner")
ESCorner.CornerRadius = UDim.new(0, 5)
ESCorner.Parent = EditorStatus

local ESPadding = Instance.new("UIPadding")
ESPadding.PaddingLeft = UDim.new(0, 8)
ESPadding.Parent = EditorStatus

-- Interactive Docs Panel
local DocsCard = Instance.new("Frame")
DocsCard.Size = UDim2.new(1, 0, 0, 105)
DocsCard.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
DocsCard.Visible = false
DocsCard.Parent = EditorPage

local DCCorner = Instance.new("UICorner")
DCCorner.CornerRadius = UDim.new(0, 8)
DCCorner.Parent = DocsCard

local DCStroke = Instance.new("UIStroke")
DCStroke.Color = Color3.fromRGB(40, 40, 56)
DCStroke.Thickness = 1
DCStroke.Parent = DocsCard

local DocsText = Instance.new("TextLabel")
DocsText.Size = UDim2.new(1, -16, 1, -12)
DocsText.Position = UDim2.new(0, 8, 0, 6)
DocsText.BackgroundTransparency = 1
DocsText.Text = "Kirik Hub Tab Builder API:\n" ..
    "- local tab = Kirik:CreateTab(\"TabName\")\n" ..
    "- tab:AddHeader(\"Header Title\")\n" ..
    "- tab:AddButton(\"Label\", \"BtnText\", function())\n" ..
    "- tab:AddToggle(\"Label\", defaultBool, function(state))\n" ..
    "- tab:AddInput(\"Label\", \"Placeholder\", defaultVal, function(val))\n" ..
    "- tab:Track(connection) -> Auto-cleans up on delete!"
DocsText.TextColor3 = Color3.fromRGB(210, 215, 235)
DocsText.Font = Enum.Font.Code
DocsText.TextSize = 11
DocsText.TextXAlignment = Enum.TextXAlignment.Left
DocsText.TextYAlignment = Enum.TextYAlignment.Top
DocsText.Parent = DocsCard

DocsToggleBtn.MouseButton1Click:Connect(function()
    DocsCard.Visible = not DocsCard.Visible
end)

-- Main Code Editor Box Container
local CodeBoxContainer = Instance.new("Frame")
CodeBoxContainer.Size = UDim2.new(1, 0, 0, 180)
CodeBoxContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
CodeBoxContainer.Parent = EditorPage

local CBCorner = Instance.new("UICorner")
CBCorner.CornerRadius = UDim.new(0, 8)
CBCorner.Parent = CodeBoxContainer

local CBStroke = Instance.new("UIStroke")
CBStroke.Color = Color3.fromRGB(40, 40, 56)
CBStroke.Thickness = 1
CBStroke.Parent = CodeBoxContainer

local CodeScroll = Instance.new("ScrollingFrame")
CodeScroll.Size = UDim2.new(1, -12, 1, -12)
CodeScroll.Position = UDim2.new(0, 6, 0, 6)
CodeScroll.BackgroundTransparency = 1
CodeScroll.BorderSizePixel = 0
CodeScroll.ScrollBarThickness = 3
CodeScroll.ScrollBarImageColor3 = Color3.fromRGB(99, 102, 241)
CodeScroll.AutomaticCanvasSize = Enum.AutomaticSize.XY
CodeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
CodeScroll.Parent = CodeBoxContainer

local CodeBox = Instance.new("TextBox")
CodeBox.Size = UDim2.new(1, 0, 1, 0)
CodeBox.BackgroundTransparency = 1
CodeBox.ClearTextOnFocus = false
CodeBox.MultiLine = true
CodeBox.Font = Enum.Font.Code
CodeBox.TextSize = 12
CodeBox.TextColor3 = Color3.fromRGB(240, 240, 255)
CodeBox.TextXAlignment = Enum.TextXAlignment.Left
CodeBox.TextYAlignment = Enum.TextYAlignment.Top
CodeBox.Parent = CodeScroll

local defaultTemplateCode = 'local Tab = Kirik:CreateTab("MyTab")\n\n' ..
    'Tab:AddHeader("--- CUSTOM SCRIPT ---")\n\n' ..
    'Tab:AddButton("Print Info", "Run", function()\n' ..
    '    print("Kirik Hub V2.0 Custom Tab Active!")\n' ..
    'end)\n\n' ..
    'Tab:AddToggle("Custom Toggle", false, function(state)\n' ..
    '    print("Toggle State: ", state)\n' ..
    'end)\n\n' ..
    'Tab:AddInput("Custom Value", "Type here", "100", function(val)\n' ..
    '    print("Entered Value: ", val)\n' ..
    'end)'

CodeBox.Text = defaultTemplateCode

TemplateBtn.MouseButton1Click:Connect(function()
    CodeBox.Text = defaultTemplateCode
    EditorStatus.Text = "Status: Template loaded."
    EditorStatus.TextColor3 = Color3.fromRGB(150, 150, 180)
end)

ClearCodeBtn.MouseButton1Click:Connect(function()
    CodeBox.Text = ""
    EditorStatus.Text = "Status: Editor cleared."
    EditorStatus.TextColor3 = Color3.fromRGB(150, 150, 180)
end)

PasteBtn.MouseButton1Click:Connect(function()
    local pasted = false
    if getclipboard then
        pcall(function()
            local clip = getclipboard()
            if clip and type(clip) == "string" and #clip > 0 then
                CodeBox.Text = clip
                pasted = true
            end
        end)
    end
    if pasted then
        EditorStatus.Text = "Status: Pasted from clipboard."
        EditorStatus.TextColor3 = Color3.fromRGB(130, 220, 130)
    else
        EditorStatus.Text = "Status: Clipboard unavailable. Paste manually into the box."
        EditorStatus.TextColor3 = Color3.fromRGB(240, 180, 100)
    end
end)

-- =======================================================
--              KIRIK API INJECTION ENGINE
-- =======================================================

local KirikAPI = {}

function KirikAPI:CreateTab(tabName)
    assert(type(tabName) == "string" and #tabName > 0, "Invalid Tab Name")

    if customTabsRegistry[tabName] then
        pcall(customTabsRegistry[tabName].Cleanup)
        customTabsRegistry[tabName] = nil
        if Pages[tabName] then
            Pages[tabName]:Destroy()
            Pages[tabName] = nil
        end
        if tabFrames[tabName] then
            tabFrames[tabName]:Destroy()
            tabFrames[tabName] = nil
            tabButtons[tabName] = nil
        end
    end

    local tabConnections = {}
    local customPage = createPage(tabName)

    createTabButton(tabName, 10 + #TabBar:GetChildren(), true)

    local tabObject = {}

    function tabObject:AddHeader(title)
        createSectionHeader(customPage, title)
    end

    function tabObject:AddButton(title, btnText, callback)
        createButtonRow(customPage, title, btnText, callback)
    end

    function tabObject:AddToggle(title, defaultState, callback)
        createSimpleToggle(customPage, title, defaultState, callback)
    end

    function tabObject:AddInput(title, placeholder, defaultVal, callback)
        createInputRow(customPage, title, placeholder, defaultVal, callback)
    end

    function tabObject:AddControl(title, defaultVal, defaultState, onToggle, onValChange)
        createControlRow(customPage, title, defaultVal, defaultState, onToggle, onValChange)
    end

    function tabObject:Track(conn)
        if conn and conn.Disconnect then
            table.insert(tabConnections, conn)
        end
        return conn
    end

    customTabsRegistry[tabName] = {
        Page = customPage,
        Cleanup = function()
            for _, conn in ipairs(tabConnections) do
                if conn and conn.Disconnect then
                    conn:Disconnect()
                end
            end
            tabConnections = {}
        end
    }

    return tabObject
end

-- Run Code and Build Dynamic Tab
RunScriptBtn.MouseButton1Click:Connect(function()
    local code = CodeBox.Text
    if not code or #code:gsub("%s+", "") == 0 then
        EditorStatus.Text = "Status: Cannot run empty code."
        EditorStatus.TextColor3 = Color3.fromRGB(240, 100, 100)
        return
    end

    if getgenv then
        getgenv().Kirik = KirikAPI
        getgenv().Hub = KirikAPI
    end
    _G.Kirik = KirikAPI
    _G.Hub = KirikAPI

    local loadFunc = loadstring or load_string
    if not loadFunc then
        EditorStatus.Text = "Error: Executor missing loadstring."
        EditorStatus.TextColor3 = Color3.fromRGB(240, 80, 80)
        return
    end

    local func, compileErr = loadFunc(code)
    if not func then
        EditorStatus.Text = "Compile Error: " .. tostring(compileErr):sub(1, 45) .. "..."
        EditorStatus.TextColor3 = Color3.fromRGB(240, 80, 80)
        return
    end

    local success, runErr = pcall(func)
    if success then
        EditorStatus.Text = "Status: Tab successfully created!"
        EditorStatus.TextColor3 = Color3.fromRGB(80, 240, 120)
    else
        EditorStatus.Text = "Runtime Error: " .. tostring(runErr):sub(1, 45) .. "..."
        EditorStatus.TextColor3 = Color3.fromRGB(240, 80, 80)
    end
end)

-- =======================================================
--                    SETTINGS PAGE
-- =======================================================

createSectionHeader(SettingsPage, "--- HUB CONFIGURATION ---")

local ScaleRow = Instance.new("Frame")
ScaleRow.Size = UDim2.new(1, 0, 0, 50)
ScaleRow.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
ScaleRow.Parent = SettingsPage

local ScaleCorner = Instance.new("UICorner")
ScaleCorner.CornerRadius = UDim.new(0, 8)
ScaleCorner.Parent = ScaleRow

local ScaleStroke = Instance.new("UIStroke")
ScaleStroke.Color = Color3.fromRGB(36, 36, 48)
ScaleStroke.Thickness = 1
ScaleStroke.Parent = ScaleRow

local ScaleLabel = Instance.new("TextLabel")
ScaleLabel.Size = UDim2.new(1, -95, 1, 0)
ScaleLabel.Position = UDim2.new(0, 12, 0, 0)
ScaleLabel.BackgroundTransparency = 1
ScaleLabel.Text = "Hub Size (1.0 = Normal, 0.5 = 2x Smaller):"
ScaleLabel.TextColor3 = Color3.fromRGB(235, 235, 245)
ScaleLabel.Font = Enum.Font.GothamMedium
ScaleLabel.TextSize = 12
ScaleLabel.TextXAlignment = Enum.TextXAlignment.Left
ScaleLabel.Parent = ScaleRow

local ScaleInput = Instance.new("TextBox")
ScaleInput.Size = UDim2.new(0, 70, 0, 28)
ScaleInput.Position = UDim2.new(1, -80, 0.5, 0)
ScaleInput.AnchorPoint = Vector2.new(0, 0.5)
ScaleInput.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ScaleInput.Text = "1.0"
ScaleInput.TextColor3 = Color3.fromRGB(240, 240, 255)
ScaleInput.Font = Enum.Font.GothamBold
ScaleInput.TextSize = 12
ScaleInput.ClearTextOnFocus = false
ScaleInput.Parent = ScaleRow

local ScaleInputCorner = Instance.new("UICorner")
ScaleInputCorner.CornerRadius = UDim.new(0, 5)
ScaleInputCorner.Parent = ScaleInput

local ScaleInputStroke = Instance.new("UIStroke")
ScaleInputStroke.Color = Color3.fromRGB(48, 48, 66)
ScaleInputStroke.Thickness = 1
ScaleInputStroke.Parent = ScaleInput

ScaleInput.FocusLost:Connect(function()
    local val = tonumber(ScaleInput.Text)
    if val and val >= 0.2 and val <= 3.0 then
        currentScale = val
        TweenService:Create(GlobalScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Scale = currentScale
        }):Play()
    else
        ScaleInput.Text = tostring(currentScale)
    end
end)

createSectionHeader(SettingsPage, "--- UTILITIES ---")

createButtonRow(SettingsPage, "Reset Character", "Respawn", function()
    if LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
    end
end)

createButtonRow(SettingsPage, "Server Rejoin", "Rejoin", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- =======================================================
--         IN-PLACE MINIMIZE & CLOSE MECHANICS
-- =======================================================

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinimizeBtn.Text = "+"
        BodyContainer.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, BASE_WIDTH, 0, TOPBAR_HEIGHT)
        }):Play()
    else
        MinimizeBtn.Text = "-"
        local expandTween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, BASE_WIDTH, 0, BASE_HEIGHT)
        })
        expandTween:Play()
        expandTween.Completed:Connect(function()
            if not isMinimized then
                BodyContainer.Visible = true
            end
        end)
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    resetAllProcesses()
    ScreenGui:Destroy()
end)

-- =======================================================
--       TOUCH / DRAGGABLE IMPLEMENTATION (ANDROID)
-- =======================================================

local dragging, dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + (delta.X / currentScale),
            startPos.Y.Scale,
            startPos.Y.Offset + (delta.Y / currentScale)
        )
    end
end)
