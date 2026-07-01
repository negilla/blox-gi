--[[
    EBANAT HUB | BLOX FRUITS
    Version: 3.0.0 — Delta Compatible
    Fixed: Cancellable actions, chest detection, ESP system, scrolling, 3 seas teleport
]]

-- ============================================================
-- EXECUTOR DETECTION
-- ============================================================
local gethui = gethui or function() return game:GetService("CoreGui") end
local setclipboard = setclipboard or function() end
local sethiddenproperty = sethiddenproperty or function() end
local firetouchinterest = firetouchinterest or function() end

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- THEME
-- ============================================================
local Theme = {
    Background = Color3.fromRGB(15, 15, 20),
    BackgroundLight = Color3.fromRGB(22, 22, 28),
    Card = Color3.fromRGB(28, 28, 36),
    CardHover = Color3.fromRGB(34, 34, 44),
    Accent = Color3.fromRGB(138, 106, 255),
    AccentLight = Color3.fromRGB(170, 140, 255),
    AccentDark = Color3.fromRGB(98, 72, 200),
    Text = Color3.fromRGB(235, 235, 245),
    TextDim = Color3.fromRGB(130, 130, 150),
    TextDark = Color3.fromRGB(80, 80, 100),
    ToggleOff = Color3.fromRGB(40, 40, 50),
    SliderTrack = Color3.fromRGB(35, 35, 45),
    Divider = Color3.fromRGB(38, 38, 48),
    Hover = Color3.fromRGB(32, 32, 42),
    Success = Color3.fromRGB(70, 200, 110),
    Danger = Color3.fromRGB(230, 70, 80),
    Warning = Color3.fromRGB(240, 180, 60),
}

local ThemePresets = {
    ["Purple"] = { Color3.fromRGB(138, 106, 255), Color3.fromRGB(170, 140, 255), Color3.fromRGB(98, 72, 200) },
    ["Blue"]   = { Color3.fromRGB(70, 130, 250), Color3.fromRGB(110, 160, 255), Color3.fromRGB(50, 95, 190) },
    ["Red"]    = { Color3.fromRGB(230, 70, 80), Color3.fromRGB(255, 110, 120), Color3.fromRGB(170, 50, 60) },
    ["Green"]  = { Color3.fromRGB(70, 200, 110), Color3.fromRGB(110, 230, 150), Color3.fromRGB(50, 150, 80) },
    ["Pink"]   = { Color3.fromRGB(255, 85, 170), Color3.fromRGB(255, 130, 200), Color3.fromRGB(190, 55, 130) },
    ["Orange"] = { Color3.fromRGB(255, 150, 50), Color3.fromRGB(255, 180, 90), Color3.fromRGB(190, 110, 30) },
    ["Cyan"]   = { Color3.fromRGB(50, 200, 220), Color3.fromRGB(90, 230, 245), Color3.fromRGB(30, 150, 170) },
}

-- ============================================================
-- UTILITY
-- ============================================================
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Divider
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function gradient(parent, c1, c2, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rotation or 90
    g.Parent = parent
    return g
end

local function pad(parent, top, bottom, left, right)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.Parent = parent
    return p
end

local function ripple(parent, x, y)
    local r = Instance.new("Frame")
    r.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    r.BackgroundTransparency = 0.85
    r.Size = UDim2.new(0, 0, 0, 0)
    r.Position = UDim2.new(0, x or 0, 0, y or 0)
    r.AnchorPoint = Vector2.new(0.5, 0.5)
    r.ZIndex = 1000
    r.Parent = parent
    corner(r, 999)
    local tw = TweenService:Create(r, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 400, 0, 400), BackgroundTransparency = 1,
    })
    tw:Play()
    tw.Completed:Connect(function() r:Destroy() end)
end

-- ============================================================
-- SCREEN GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EbanatHub_" .. tostring(math.random(10000, 99999))
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = gethui()

local UIScale = Instance.new("UIScale")
UIScale.Scale = 1
UIScale.Parent = ScreenGui

-- ============================================================
-- MAIN WINDOW — slightly larger
-- ============================================================
local Window = Instance.new("Frame")
Window.Size = UDim2.new(0, 680, 0, 460)
Window.Position = UDim2.new(0.5, -340, 0.5, -230)
Window.BackgroundColor3 = Theme.Background
Window.BorderSizePixel = 0
Window.Parent = ScreenGui
corner(Window, 12)
gradient(Window, Theme.Background, Color3.fromRGB(12, 12, 16), 180)
stroke(Window, Theme.AccentDark, 1, 0.3)

local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 40, 1, 40)
Shadow.Position = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.4
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.ZIndex = -1
Shadow.Parent = Window

-- ============================================================
-- TITLE BAR
-- ============================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Theme.BackgroundLight
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Window
corner(TitleBar, 12)

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 14)
TitleFix.Position = UDim2.new(0, 0, 1, -14)
TitleFix.BackgroundColor3 = Theme.BackgroundLight
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Logo = Instance.new("Frame")
Logo.Size = UDim2.new(0, 30, 0, 30)
Logo.Position = UDim2.new(0, 12, 0.5, -15)
Logo.BackgroundColor3 = Theme.Accent
Logo.BorderSizePixel = 0
Logo.Parent = TitleBar
corner(Logo, 8)
gradient(Logo, Theme.AccentLight, Theme.AccentDark, 135)

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, 0, 1, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "E"
LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
LogoText.Font = Enum.Font.GothamBlack
LogoText.TextSize = 18
LogoText.Parent = Logo

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 200, 1, 0)
TitleLabel.Position = UDim2.new(0, 50, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Ebanat Hub"
TitleLabel.TextColor3 = Theme.Text
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local SubtitleLabel = Instance.new("TextLabel")
SubtitleLabel.Size = UDim2.new(0, 200, 1, 0)
SubtitleLabel.Position = UDim2.new(0, 50, 0, 0)
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Text = "Blox Fruits"
SubtitleLabel.TextColor3 = Theme.TextDark
SubtitleLabel.Font = Enum.Font.Gotham
SubtitleLabel.TextSize = 11
SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
SubtitleLabel.TextYAlignment = Enum.TextYAlignment.Bottom
SubtitleLabel.Parent = TitleBar

local VersionBadge = Instance.new("TextLabel")
VersionBadge.Size = UDim2.new(0, 56, 0, 22)
VersionBadge.Position = UDim2.new(0, 168, 0.5, -11)
VersionBadge.BackgroundColor3 = Theme.Card
VersionBadge.BorderSizePixel = 0
VersionBadge.Text = "v3.0"
VersionBadge.TextColor3 = Theme.AccentLight
VersionBadge.Font = Enum.Font.GothamMedium
VersionBadge.TextSize = 10
VersionBadge.Parent = TitleBar
corner(VersionBadge, 5)
stroke(VersionBadge, Theme.AccentDark, 1, 0.3)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 28, 0, 28)
MinimizeBtn.Position = UDim2.new(1, -72, 0.5, -14)
MinimizeBtn.BackgroundColor3 = Theme.Card
MinimizeBtn.BorderSizePixel = 0
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Theme.TextDim
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 14
MinimizeBtn.AutoButtonColor = false
MinimizeBtn.Parent = TitleBar
corner(MinimizeBtn, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -38, 0.5, -14)
CloseBtn.BackgroundColor3 = Theme.Card
CloseBtn.BorderSizePixel = 0
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.TextDim
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar
corner(CloseBtn, 6)

MinimizeBtn.MouseEnter:Connect(function() TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.CardHover, TextColor3 = Theme.Text}):Play() end)
MinimizeBtn.MouseLeave:Connect(function() TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card, TextColor3 = Theme.TextDim}):Play() end)
CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Danger, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play() end)
CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card, TextColor3 = Theme.TextDim}):Play() end)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    ripple(MinimizeBtn, 14, 14)
    minimized = not minimized
    if minimized then
        TweenService:Create(Window, TweenInfo.new(0.3), {Size = UDim2.new(0, 680, 0, 44)}):Play()
    else
        TweenService:Create(Window, TweenInfo.new(0.3), {Size = UDim2.new(0, 680, 0, 460)}):Play()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    ripple(CloseBtn, 14, 14)
    local tw = TweenService:Create(Window, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1,
    })
    tw:Play()
    tw.Completed:Connect(function() ScreenGui:Destroy() end)
end)

-- ============================================================
-- DRAG
-- ============================================================
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Window.Position
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ============================================================
-- TAB BAR — horizontal scrolling frame
-- ============================================================
local TabBar = Instance.new("ScrollingFrame")
TabBar.Size = UDim2.new(1, -24, 0, 36)
TabBar.Position = UDim2.new(0, 12, 0, 50)
TabBar.BackgroundColor3 = Theme.BackgroundLight
TabBar.BorderSizePixel = 0
TabBar.ScrollBarThickness = 0
TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
TabBar.ScrollingDirection = Enum.ScrollingDirection.X
TabBar.Parent = Window
corner(TabBar, 8)

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, 0, 1, 0)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = TabBar
pad(TabContainer, 4, 4, 4, 4)

local TabList = Instance.new("UIListLayout")
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.Padding = UDim.new(0, 4)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabContainer

-- ============================================================
-- CONTENT AREA — fixed sizing
-- ============================================================
local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -24, 1, -98)
ContentArea.Position = UDim2.new(0, 12, 0, 92)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = Window

local Pages = {}
local TabButtons = {}
local currentTab = nil
local tabIndex = 0

local TabIndicator = Instance.new("Frame")
TabIndicator.Size = UDim2.new(0, 0, 0, 2)
TabIndicator.Position = UDim2.new(0, 0, 1, -2)
TabIndicator.BackgroundColor3 = Theme.Accent
TabIndicator.BorderSizePixel = 0
TabIndicator.Visible = false
TabIndicator.Parent = TabBar
corner(TabIndicator, 1)

-- ============================================================
-- TAB CREATION — with FIXED scrolling
-- ============================================================
local function createTab(name, icon)
    tabIndex = tabIndex + 1

    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0, 76, 1, 0)
    tabBtn.BackgroundColor3 = Theme.BackgroundLight
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = ""
    tabBtn.AutoButtonColor = false
    tabBtn.LayoutOrder = tabIndex
    tabBtn.Parent = TabContainer
    corner(tabBtn, 6)

    local tabIcon = Instance.new("TextLabel")
    tabIcon.Size = UDim2.new(0, 18, 1, 0)
    tabIcon.Position = UDim2.new(0, 8, 0, 0)
    tabIcon.BackgroundTransparency = 1
    tabIcon.Text = icon or ""
    tabIcon.TextColor3 = Theme.TextDim
    tabIcon.Font = Enum.Font.GothamBold
    tabIcon.TextSize = 11
    tabIcon.Parent = tabBtn

    local tabLabel = Instance.new("TextLabel")
    tabLabel.Size = UDim2.new(1, -28, 1, 0)
    tabLabel.Position = UDim2.new(0, 26, 0, 0)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Text = name
    tabLabel.TextColor3 = Theme.TextDim
    tabLabel.Font = Enum.Font.GothamMedium
    tabLabel.TextSize = 11
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.Parent = tabBtn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.None
    page.Visible = false
    page.Parent = ContentArea
    pad(page, 0, 0, 0, 4)

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Parent = page

    -- CRITICAL FIX: Manual CanvasSize update
    pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize + 12)
    end)

    Pages[name] = page
    TabButtons[name] = { Button = tabBtn, Icon = tabIcon, Label = tabLabel }

    -- Update tab bar canvas size
    TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabBar.CanvasSize = UDim2.new(0, TabList.AbsoluteContentSize + 8, 0, 0)
    end)

    local function selectTab()
        for tabName, tabData in pairs(TabButtons) do
            if tabName == name then
                TweenService:Create(tabData.Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.AccentDark}):Play()
                TweenService:Create(tabData.Label, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
                TweenService:Create(tabData.Icon, TweenInfo.new(0.2), {TextColor3 = Theme.AccentLight}):Play()
            else
                TweenService:Create(tabData.Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.BackgroundLight}):Play()
                TweenService:Create(tabData.Label, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim}):Play()
                TweenService:Create(tabData.Icon, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim}):Play()
            end
        end
        for pageName, pageFrame in pairs(Pages) do
            pageFrame.Visible = (pageName == name)
        end
        TabIndicator.Visible = true
        TweenService:Create(TabIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, tabBtn.AbsoluteSize.X - 8, 0, 2),
            Position = UDim2.new(0, tabBtn.AbsolutePosition.X - TabBar.AbsolutePosition.X + 4, 1, -2),
        }):Play()
        currentTab = name
    end

    tabBtn.MouseButton1Click:Connect(function()
        ripple(tabBtn, tabBtn.AbsoluteSize.X / 2, tabBtn.AbsoluteSize.Y / 2)
        selectTab()
    end)
    tabBtn.MouseEnter:Connect(function()
        if currentTab ~= name then
            TweenService:Create(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card}):Play()
            TweenService:Create(tabLabel, TweenInfo.new(0.15), {TextColor3 = Theme.Text}):Play()
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if currentTab ~= name then
            TweenService:Create(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BackgroundLight}):Play()
            TweenService:Create(tabLabel, TweenInfo.new(0.15), {TextColor3 = Theme.TextDim}):Play()
        end
    end)

    local api = {}
    local order = 0

    function api:Section(title)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, 0, 0, 28)
        section.BackgroundTransparency = 1
        section.LayoutOrder = order
        section.Parent = page
        order = order + 1
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = title
        label.TextColor3 = Theme.TextDark
        label.Font = Enum.Font.GothamBold
        label.TextSize = 11
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = section
        return self
    end

    function api:Toggle(text, description, default, callback)
        local toggleCard = Instance.new("Frame")
        toggleCard.Size = UDim2.new(1, 0, 0, 44)
        toggleCard.BackgroundColor3 = Theme.Card
        toggleCard.BorderSizePixel = 0
        toggleCard.LayoutOrder = order
        toggleCard.Parent = page
        order = order + 1
        corner(toggleCard, 8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -70, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = toggleCard

        local switchBg = Instance.new("Frame")
        switchBg.Size = UDim2.new(0, 40, 0, 22)
        switchBg.Position = UDim2.new(1, -52, 0.5, -11)
        switchBg.BackgroundColor3 = Theme.ToggleOff
        switchBg.BorderSizePixel = 0
        switchBg.Parent = toggleCard
        corner(switchBg, 11)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = UDim2.new(0, 3, 0.5, -8)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = switchBg
        corner(knob, 8)

        local state = default or false
        local function update()
            if state then
                TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Accent}):Play()
                TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(1, -19, 0.5, -8)}):Play()
            else
                TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ToggleOff}):Play()
                TweenService:Create(knob, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -8)}):Play()
            end
        end

        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(1, 0, 1, 0)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.Parent = toggleCard

        hitbox.MouseButton1Click:Connect(function()
            state = not state
            update()
            ripple(toggleCard, toggleCard.AbsoluteSize.X - 30, toggleCard.AbsoluteSize.Y / 2)
            if callback then callback(state) end
        end)
        update()

        return {
            Set = function(val) state = val; update(); if callback then callback(state) end end,
            Get = function() return state end,
        }
    end

    function api:Button(text, callback)
        local btnCard = Instance.new("TextButton")
        btnCard.Size = UDim2.new(1, 0, 0, 38)
        btnCard.BackgroundColor3 = Theme.Card
        btnCard.BorderSizePixel = 0
        btnCard.Text = ""
        btnCard.AutoButtonColor = false
        btnCard.LayoutOrder = order
        btnCard.Parent = page
        order = order + 1
        corner(btnCard, 8)
        stroke(btnCard, Theme.AccentDark, 1, 0.4)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.Parent = btnCard

        btnCard.MouseEnter:Connect(function() TweenService:Create(btnCard, TweenInfo.new(0.15), {BackgroundColor3 = Theme.CardHover}):Play(); TweenService:Create(label, TweenInfo.new(0.15), {TextColor3 = Theme.AccentLight}):Play() end)
        btnCard.MouseLeave:Connect(function() TweenService:Create(btnCard, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card}):Play(); TweenService:Create(label, TweenInfo.new(0.15), {TextColor3 = Theme.Text}):Play() end)
        btnCard.MouseButton1Click:Connect(function()
            ripple(btnCard, btnCard.AbsoluteSize.X / 2, btnCard.AbsoluteSize.Y / 2)
            if callback then callback() end
        end)
        return btnCard
    end

    function api:Slider(text, min, max, default, suffix, callback)
        local sliderCard = Instance.new("Frame")
        sliderCard.Size = UDim2.new(1, 0, 0, 56)
        sliderCard.BackgroundColor3 = Theme.Card
        sliderCard.BorderSizePixel = 0
        sliderCard.LayoutOrder = order
        sliderCard.Parent = page
        order = order + 1
        corner(sliderCard, 8)
        pad(sliderCard, 10, 10, 14, 14)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 0, 16)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = sliderCard

        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 50, 0, 16)
        valueLabel.Position = UDim2.new(1, -50, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(default or min) .. (suffix or "")
        valueLabel.TextColor3 = Theme.AccentLight
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.TextSize = 12
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = sliderCard

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, 0, 0, 6)
        track.Position = UDim2.new(0, 0, 0, 28)
        track.BackgroundColor3 = Theme.SliderTrack
        track.BorderSizePixel = 0
        track.Parent = sliderCard
        corner(track, 3)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = track
        corner(fill, 3)
        gradient(fill, Theme.Accent, Theme.AccentLight, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new(0, -7, 0.5, -7)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel = 0
        knob.Parent = track
        corner(knob, 7)
        stroke(knob, Theme.Accent, 2)

        local value = default or min
        local sliding = false

        local function update(val)
            value = math.clamp(val, min, max)
            local pct = (value - min) / (max - min)
            TweenService:Create(fill, TweenInfo.new(0.08), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.08), {Position = UDim2.new(pct, -7, 0.5, -7)}):Play()
            valueLabel.Text = tostring(math.floor(value)) .. (suffix or "")
            if callback then callback(value) end
        end

        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(1, 0, 0, 20)
        hitbox.Position = UDim2.new(0, 0, 0, 22)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.Parent = sliderCard

        hitbox.MouseButton1Down:Connect(function()
            sliding = true
            local pct = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            update(min + (max - min) * pct)
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local pct = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                update(min + (max - min) * pct)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end)
        update(default or min)
        return { Set = update, Get = function() return value end }
    end

    function api:Dropdown(text, options, default, callback)
        local ddCard = Instance.new("Frame")
        ddCard.Size = UDim2.new(1, 0, 0, 40)
        ddCard.BackgroundColor3 = Theme.Card
        ddCard.BorderSizePixel = 0
        ddCard.LayoutOrder = order
        ddCard.ClipsDescendants = true
        ddCard.Parent = page
        order = order + 1
        corner(ddCard, 8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text .. ":"
        label.TextColor3 = Theme.TextDim
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = ddCard

        local selectedLabel = Instance.new("TextLabel")
        selectedLabel.Size = UDim2.new(0, 120, 1, 0)
        selectedLabel.Position = UDim2.new(1, -134, 0, 0)
        selectedLabel.BackgroundTransparency = 1
        selectedLabel.Text = default or options[1]
        selectedLabel.TextColor3 = Theme.AccentLight
        selectedLabel.Font = Enum.Font.GothamBold
        selectedLabel.TextSize = 12
        selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
        selectedLabel.Parent = ddCard

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 20, 1, 0)
        arrow.Position = UDim2.new(1, -20, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = "v"
        arrow.TextColor3 = Theme.TextDim
        arrow.Font = Enum.Font.GothamBold
        arrow.TextSize = 10
        arrow.Parent = ddCard

        local expanded = false
        local selected = default or options[1]

        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(1, 0, 0, 40)
        hitbox.BackgroundTransparency = 1
        hitbox.Text = ""
        hitbox.Parent = ddCard

        local listFrame = Instance.new("Frame")
        listFrame.Size = UDim2.new(1, 0, 0, 0)
        listFrame.Position = UDim2.new(0, 0, 0, 42)
        listFrame.BackgroundColor3 = Theme.BackgroundLight
        listFrame.BorderSizePixel = 0
        listFrame.ZIndex = 10
        listFrame.Parent = ddCard
        corner(listFrame, 6)
        pad(listFrame, 4, 4, 4, 4)

        local listLayout = Instance.new("UIListLayout")
        listLayout.Padding = UDim.new(0, 2)
        listLayout.Parent = listFrame

        local function buildList()
            for _, child in pairs(listFrame:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for _, opt in pairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 30)
                optBtn.BackgroundColor3 = Theme.Card
                optBtn.BorderSizePixel = 0
                optBtn.Text = ""
                optBtn.AutoButtonColor = false
                optBtn.ZIndex = 11
                optBtn.Parent = listFrame
                corner(optBtn, 4)

                local optLabel = Instance.new("TextLabel")
                optLabel.Size = UDim2.new(1, -20, 1, 0)
                optLabel.Position = UDim2.new(0, 10, 0, 0)
                optLabel.BackgroundTransparency = 1
                optLabel.Text = opt
                optLabel.TextColor3 = (opt == selected) and Theme.AccentLight or Theme.TextDim
                optLabel.Font = Enum.Font.Gotham
                optLabel.TextSize = 12
                optLabel.TextXAlignment = Enum.TextXAlignment.Left
                optLabel.ZIndex = 12
                optLabel.Parent = optBtn

                optBtn.MouseEnter:Connect(function() TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Hover}):Play() end)
                optBtn.MouseLeave:Connect(function() TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Card}):Play() end)
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    selectedLabel.Text = opt
                    if callback then callback(opt) end
                    TweenService:Create(ddCard, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 40)}):Play()
                    TweenService:Create(arrow, TweenInfo.new(0.2), {Text = "v"}):Play()
                    task.wait(0.2)
                    expanded = false
                end)
            end
        end

        hitbox.MouseButton1Click:Connect(function()
            expanded = not expanded
            if expanded then
                buildList()
                local targetHeight = 40 + (#options * 32) + 8
                TweenService:Create(ddCard, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
                TweenService:Create(arrow, TweenInfo.new(0.2), {Text = "^"}):Play()
            else
                TweenService:Create(ddCard, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 40)}):Play()
                TweenService:Create(arrow, TweenInfo.new(0.2), {Text = "v"}):Play()
            end
        end)

        return { Set = function(val) selected = val; selectedLabel.Text = val end, Get = function() return selected end }
    end

    function api:Label(text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = Theme.TextDim
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 11
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LayoutOrder = order
        lbl.Parent = page
        order = order + 1
        return { Set = function(val) lbl.Text = val end, Get = function() return lbl.Text end }
    end

    function api:Keybind(text, defaultKey, callback)
        local kbCard = Instance.new("Frame")
        kbCard.Size = UDim2.new(1, 0, 0, 38)
        kbCard.BackgroundColor3 = Theme.Card
        kbCard.BorderSizePixel = 0
        kbCard.LayoutOrder = order
        kbCard.Parent = page
        order = order + 1
        corner(kbCard, 8)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -80, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = kbCard

        local keyBtn = Instance.new("TextButton")
        keyBtn.Size = UDim2.new(0, 60, 0, 24)
        keyBtn.Position = UDim2.new(1, -72, 0.5, -12)
        keyBtn.BackgroundColor3 = Theme.Background
        keyBtn.BorderSizePixel = 0
        keyBtn.Text = (defaultKey and defaultKey.Name) or "None"
        keyBtn.TextColor3 = Theme.AccentLight
        keyBtn.Font = Enum.Font.GothamBold
        keyBtn.TextSize = 11
        keyBtn.AutoButtonColor = false
        keyBtn.Parent = kbCard
        corner(keyBtn, 4)
        stroke(keyBtn, Theme.Divider, 1)

        local listening = false
        local currentKey = defaultKey

        keyBtn.MouseButton1Click:Connect(function()
            listening = true
            keyBtn.Text = "..."
            keyBtn.TextColor3 = Theme.Warning
        end)
        UserInputService.InputBegan:Connect(function(input, gpe)
            if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
                listening = false
                currentKey = input.KeyCode
                keyBtn.Text = currentKey.Name
                keyBtn.TextColor3 = Theme.AccentLight
            elseif input.KeyCode == currentKey and not gpe then
                if callback then callback() end
            end
        end)
        return { Get = function() return currentKey end }
    end

    if tabIndex == 1 then
        task.defer(function() task.wait(0.1); selectTab() end)
    end
    return api
end

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 280, 1, -120)
NotifContainer.Position = UDim2.new(1, -290, 0, 60)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.Padding = UDim.new(0, 8)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Parent = NotifContainer

local function notify(title, message, duration, notifType)
    duration = duration or 3
    local color = Theme.Accent
    if notifType == "success" then color = Theme.Success
    elseif notifType == "danger" then color = Theme.Danger
    elseif notifType == "warning" then color = Theme.Warning end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 56)
    notif.BackgroundColor3 = Theme.BackgroundLight
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.Parent = NotifContainer
    corner(notif, 8)
    stroke(notif, Theme.Divider, 1)

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, 8)
    accentBar.Position = UDim2.new(0, 0, 0, 4)
    accentBar.BackgroundColor3 = color
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notif
    corner(accentBar, 2)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -24, 0, 18)
    titleLabel.Position = UDim2.new(0, 14, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Theme.Text
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 12
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notif

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -24, 0, 16)
    msgLabel.Position = UDim2.new(0, 14, 0, 26)
    msgLabel.BackgroundTransparency = 1
    msgLabel.Text = message
    msgLabel.TextColor3 = Theme.TextDim
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 11
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.Parent = notif

    notif.Size = UDim2.new(0, 0, 0, 56)
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 56)}):Play()

    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.3), {Size = UDim2.new(0, 0, 0, 56), BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- ============================================================
-- CONFIG
-- ============================================================
local Config = {
    AutoFarm = false, AutoQuest = false, FastAttack = true, BringMobs = true,
    AttackMethod = "Both", TweenSpeed = 200, SuperEffective = false,
    AutoChests = false, AutoFruits = false, AutoStoreFruits = false,
    AutoBuyFruit = false, SelectedFruit = "Dragon",
    AutoStats = false, MeleePts = 25, DefensePts = 25, SwordPts = 25, GunPts = 0, FruitPts = 25,
    AutoHop = false, HopMinPlayers = 5,
    AntiAFK = true, KillAura = false, AuraRange = 50,
    UIScale = 1, SelectedTheme = "Purple",
    -- ESP
    FruitESP = false, ChestESP = false, IslandESP = false, MobESP = false, PlayerESP = false,
}

-- ============================================================
-- BLOX FRUITS BACKEND
-- ============================================================
local Character, Humanoid, RootPart
local ActiveTween = nil

local function refreshCharacter()
    Character = LocalPlayer.Character
    if not Character then Character = LocalPlayer.CharacterAdded:Wait() end
    Humanoid = Character:WaitForChild("Humanoid", 5)
    RootPart = Character:WaitForChild("HumanoidRootPart", 5)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    Character = char
    Humanoid = char:WaitForChild("Humanoid", 5)
    RootPart = char:WaitForChild("HumanoidRootPart", 5)
end)
pcall(refreshCharacter)

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
local CommF = Remotes and Remotes:FindFirstChild("CommF_")
local CommE = Remotes and Remotes:FindFirstChild("CommE_")
if not CommF then CommF = ReplicatedStorage:FindFirstChild("CommF_") end
if not CommE then CommE = ReplicatedStorage:FindFirstChild("CommE_") end

local function getCommF()
    if CommF then return CommF end
    CommF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    if not CommF then CommF = ReplicatedStorage:FindFirstChild("CommF_") end
    return CommF
end

local function getCommE()
    if CommE then return CommE end
    CommE = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommE_")
    if not CommE then CommE = ReplicatedStorage:FindFirstChild("CommE_") end
    return CommE
end

-- CRITICAL FIX: stopMovement function to cancel tweens
local function stopMovement()
    if ActiveTween then
        pcall(function() ActiveTween:Cancel() end)
        ActiveTween = nil
    end
end

-- Non-blocking tween (for manual actions only)
local function tweenTo(pos, speed)
    speed = speed or Config.TweenSpeed
    if not RootPart then return end
    stopMovement()
    local dist = (RootPart.Position - pos).Magnitude
    if dist < 15 then
        RootPart.CFrame = CFrame.new(pos)
        return
    end
    local info = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    ActiveTween = TweenService:Create(RootPart, info, {CFrame = CFrame.new(pos)})
    ActiveTween:Play()
    ActiveTween.Completed:Wait()
    ActiveTween = nil
end

-- Instant teleport (for auto loops — cancellable)
local function teleportTo(pos)
    if not RootPart then return end
    RootPart.CFrame = CFrame.new(pos)
end

-- ============================================================
-- QUEST DATA — ALL THREE SEAS
-- ============================================================
local Quests = {
    [1]    = {Name = "Trainee",           Mob = "Bandit",               Pos = Vector3.new(1059, 16, 1548)},
    [8]    = {Name = "Monkey",            Mob = "Monkey",               Pos = Vector3.new(-1591, 37, 167)},
    [15]   = {Name = "Gorilla",           Mob = "Gorilla",              Pos = Vector3.new(-1233, 6, -504)},
    [30]   = {Name = "Buggy",             Mob = "Buggy Crew",           Pos = Vector3.new(-1139, 13, 4049)},
    [45]   = {Name = "Desert",            Mob = "Desert Bandit",        Pos = Vector3.new(974, 6, 4556)},
    [60]   = {Name = "Desert Officer",    Mob = "Desert Officer",       Pos = Vector3.new(1322, 6, 4236)},
    [75]   = {Name = "Snow Bandit",       Mob = "Snow Bandit",          Pos = Vector3.new(1366, 7, -477)},
    [90]   = {Name = "Snow Marine",       Mob = "Snow Marine",          Pos = Vector3.new(1536, 7, -478)},
    [100]  = {Name = "Marine",            Mob = "Marine Lieutenant",    Pos = Vector3.new(-4800, 22, 4314)},
    [120]  = {Name = "Sky",               Mob = "Sky Bandit",           Pos = Vector3.new(-4864, 724, -2609)},
    [150]  = {Name = "Prisoner",          Mob = "Prisoner",             Pos = Vector3.new(5310, 1, 4740)},
    [175]  = {Name = "Dangerous Prisoner",Mob = "Dangerous Prisoner",   Pos = Vector3.new(5400, 1, 4730)},
    [200]  = {Name = "Tide Keeper",       Mob = "Tide Keeper",          Pos = Vector3.new(-4570, 272, -2580)},
    [225]  = {Name = "Fishman Warrior",   Mob = "Fishman Warrior",      Pos = Vector3.new(-2586, 8, -3343)},
    [275]  = {Name = "Wanda",             Mob = "Wanda",                Pos = Vector3.new(-1166, 73, -4346)},
    [300]  = {Name = "Magma Ninja",       Mob = "Magma Ninja",          Pos = Vector3.new(-5414, 88, -2790)},
    [350]  = {Name = "Marine Captain",    Mob = "Marine Captain",       Pos = Vector3.new(-2270, 16, 5215)},
    [400]  = {Name = "Thunder God",       Mob = "Thunder God",          Pos = Vector3.new(-7748, 24200, -24930)},
    [450]  = {Name = "Ice Soldier",       Mob = "Ice Soldier",          Pos = Vector3.new(5950, 47, -7289)},
    [500]  = {Name = "Forgotten Warrior", Mob = "Forgotten Warrior",    Pos = Vector3.new(-3034, 314, -7476)},
    [575]  = {Name = "Pirate Millionaire",Mob = "Pirate Millionaire",   Pos = Vector3.new(-1946, 100, -8346)},
    [625]  = {Name = "Galley Captain",    Mob = "Galley Captain",       Pos = Vector3.new(-1810, 100, -8543)},
    [700]  = {Name = "Island Empress",    Mob = "Island Empress",       Pos = Vector3.new(-13500, 285, -9600)},
    [850]  = {Name = "Forest Pirate",     Mob = "Forest Pirate",        Pos = Vector3.new(-13425, 367, -9450)},
    [900]  = {Name = "Mythological Pirate",Mob = "Mythological Pirate", Pos = Vector3.new(-13493, 370, -9490)},
    [1000] = {Name = "Jungle Pirate",     Mob = "Jungle Pirate",        Pos = Vector3.new(-13300, 370, -9400)},
    [1050] = {Name = "Musketeer Pirate",  Mob = "Musketeer Pirate",     Pos = Vector3.new(-13350, 375, -9350)},
    [1100] = {Name = "Reborn Skeleton",   Mob = "Reborn Skeleton",      Pos = Vector3.new(-9510, 141, 5845)},
    [1150] = {Name = "Living Zombie",     Mob = "Living Zombie",        Pos = Vector3.new(-9530, 141, 5810)},
    [1200] = {Name = "Demonic Soul",      Mob = "Demonic Soul",         Pos = Vector3.new(-9520, 141, 5875)},
    [1325] = {Name = "Posessed Mummy",    Mob = "Posessed Mummy",       Pos = Vector3.new(-9550, 141, 5825)},
    [1500] = {Name = "Drowned Cook",      Mob = "Drowned Cook",         Pos = Vector3.new(-9500, 141, 5800)},
    [1525] = {Name = "Pilot",             Mob = "Pilot",                Pos = Vector3.new(-13442, 285, -9400)},
    [1575] = {Name = "Sea Soldier",       Mob = "Sea Soldier",          Pos = Vector3.new(-13460, 285, -9420)},
    [1625] = {Name = "Water Fighter",     Mob = "Water Fighter",        Pos = Vector3.new(-13480, 285, -9440)},
    [1700] = {Name = "Gargoyle",          Mob = "Gargoyle",             Pos = Vector3.new(-13500, 285, -9600)},
    [1725] = {Name = "Dragon Talon Sage", Mob = "Dragon Talon Sage",    Pos = Vector3.new(-13520, 285, -9620)},
    [1775] = {Name = "Giant Islander",    Mob = "Giant Islander",       Pos = Vector3.new(-13480, 380, -9500)},
    [1800] = {Name = "Dragon Talon",      Mob = "Dragon Talon",         Pos = Vector3.new(-13540, 285, -9640)},
    [1875] = {Name = "Street Thug",       Mob = "Street Thug",          Pos = Vector3.new(-13400, 285, -9380)},
    [2175] = {Name = "Cocoa Warrior",     Mob = "Cocoa Warrior",        Pos = Vector3.new(-13425, 367, -9450)},
    [2200] = {Name = "Chocolate Bar Baker",Mob = "Chocolate Bar Baker", Pos = Vector3.new(-13430, 367, -9460)},
    [2225] = {Name = "Sweet Pirate",      Mob = "Sweet Pirate",         Pos = Vector3.new(-13435, 367, -9470)},
    [2250] = {Name = "Yeti",              Mob = "Yeti",                 Pos = Vector3.new(-13440, 367, -9480)},
    [2275] = {Name = "Peanut Scout",      Mob = "Peanut Scout",         Pos = Vector3.new(-13445, 367, -9490)},
    [2300] = {Name = "Peanut President",  Mob = "Peanut President",     Pos = Vector3.new(-13450, 367, -9500)},
    [2325] = {Name = "Big MOM",           Mob = "Big MOM",              Pos = Vector3.new(-13455, 367, -9510)},
    [2350] = {Name = "Cake Queen",        Mob = "Cake Queen",           Pos = Vector3.new(-13460, 367, -9520)},
}

local function getBestQuest()
    local level = 1
    local data = LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then level = data.Level.Value end
    local best = nil
    for req, quest in pairs(Quests) do
        if level >= req then
            if not best or req > (best.Req or 0) then best = quest; best.Req = req end
        end
    end
    return best
end

local function getClosestMob(targetName)
    local closest, closestDist = nil, math.huge
    local enemies = Workspace:FindFirstChild("Enemies")
    if enemies then
        for _, mob in pairs(enemies:GetChildren()) do
            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                if not targetName or mob.Name == targetName then
                    local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                    if mobRoot and RootPart then
                        local dist = (RootPart.Position - mobRoot.Position).Magnitude
                        if dist < closestDist then closest = mob; closestDist = dist end
                    end
                end
            end
        end
    end
    return closest
end

local function bringMob(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    pcall(function()
        mob.HumanoidRootPart.CFrame = RootPart.CFrame * CFrame.new(0, 0, -10)
        mob.HumanoidRootPart.CanCollide = false
        if mob:FindFirstChild("Humanoid") then
            pcall(function() mob.Humanoid.WalkSpeed = 0; mob.Humanoid.JumpPower = 0 end)
        end
    end)
end

local lastAttack = 0
local function attackMob(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    if not RootPart then return end
    local mobPos = mob.HumanoidRootPart.Position
    local myPos = RootPart.Position
    local commE = getCommE()
    if commE then
        pcall(function() commE:FireServer(mobPos) end)
        pcall(function() commE:FireServer(mobPos, CFrame.new(myPos, mobPos)) end)
    end
    if Config.FastAttack then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
        end)
    end
    if Config.SuperEffective then
        local now = tick()
        if now - lastAttack > 1 then
            lastAttack = now
            for _, key in pairs({"Z", "X", "C", "V", "F"}) do
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
                    task.wait(0.03)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
                end)
            end
        end
    end
end

local function hasActiveQuest()
    local questGui = LocalPlayer:FindFirstChild("PlayerGui")
    if questGui then
        local questFrame = questGui:FindFirstChild("Quest")
        if questFrame then return questFrame.Enabled end
    end
    return false
end

-- ============================================================
-- CHEST DETECTION — FIXED: broad search
-- ============================================================
local function findAllChests()
    local chests = {}
    -- Search Workspace children
    for _, obj in pairs(Workspace:GetChildren()) do
        local name = obj.Name:lower()
        if name:match("chest") then
            local part = obj:FindFirstChildWhichIsA("BasePart")
            if not part and obj:IsA("BasePart") then part = obj end
            if part then
                table.insert(chests, {Model = obj, Part = part, Pos = part.Position})
            end
        end
    end
    -- Search inside common container names
    for _, containerName in pairs({"Map", "Islands", "World"}) do
        local container = Workspace:FindFirstChild(containerName)
        if container then
            for _, obj in pairs(container:GetChildren()) do
                if obj.Name:lower():match("chest") then
                    local part = obj:FindFirstChildWhichIsA("BasePart")
                    if not part and obj:IsA("BasePart") then part = obj end
                    if part then
                        table.insert(chests, {Model = obj, Part = part, Pos = part.Position})
                    end
                end
                -- Search one level deeper
                for _, child in pairs(obj:GetChildren()) do
                    if child.Name:lower():match("chest") then
                        local part = child:FindFirstChildWhichIsA("BasePart")
                        if not part and child:IsA("BasePart") then part = child end
                        if part then
                            table.insert(chests, {Model = child, Part = part, Pos = part.Position})
                        end
                    end
                end
            end
        end
    end
    return chests
end

-- ============================================================
-- SERVER HOP
-- ============================================================
local function hopServer()
    notify("Server Hop", "Searching for a new server...", 3, "warning")
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local success, response = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if success and response and response.data then
        local candidates = {}
        for _, server in pairs(response.data) do
            if server.playing < server.maxPlayers and server.playing >= Config.HopMinPlayers then
                table.insert(candidates, server.id)
            end
        end
        if #candidates > 0 then
            local target = candidates[math.random(1, #candidates)]
            notify("Server Hop", "Joining new server...", 2, "success")
            TeleportService:TeleportToPlaceInstance(placeId, target, LocalPlayer)
        else
            notify("Server Hop", "No servers found, retrying...", 2, "warning")
            task.wait(2)
            hopServer()
        end
    end
end

-- ============================================================
-- ESP SYSTEM
-- ============================================================
local ESPObjects = {
    Fruit = {}, Chest = {}, Island = {}, Mob = {}, Player = {}
}

local ESPColors = {
    Fruit = Color3.fromRGB(255, 80, 80),
    Chest = Color3.fromRGB(255, 200, 50),
    Island = Color3.fromRGB(100, 200, 255),
    Mob = Color3.fromRGB(255, 100, 200),
    Player = Color3.fromRGB(100, 255, 100),
}

local function clearESP(type)
    for _, obj in pairs(ESPObjects[type]) do
        pcall(function() obj.Highlight:Destroy() end)
        pcall(function() obj.Billboard:Destroy() end)
    end
    ESPObjects[type] = {}
end

local function clearAllESP()
    for type, _ in pairs(ESPObjects) do clearESP(type) end
end

local function addESP(target, espType, text)
    if not target then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = ESPColors[espType]
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineTransparency = 0
    highlight.Parent = target

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 30)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 5000
    billboard.Parent = target

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = ESPColors[espType]
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.3
    label.Parent = billboard

    table.insert(ESPObjects[espType], {Highlight = highlight, Billboard = billboard, Target = target})
end

-- Island ESP: create invisible parts at island positions
local IslandParts = {}
local function setupIslandESP()
    local islands = {
        {"Windmill Village", Vector3.new(1059, 16, 1548)},
        {"Jungle", Vector3.new(-1591, 37, 167)},
        {"Pirate Village", Vector3.new(-1139, 13, 4049)},
        {"Desert", Vector3.new(974, 6, 4556)},
        {"Snow Island", Vector3.new(1366, 7, -477)},
        {"MarineFord", Vector3.new(-4800, 22, 4314)},
        {"Sky Island", Vector3.new(-4864, 724, -2609)},
        {"Prison", Vector3.new(5310, 1, 4740)},
        {"Colosseum", Vector3.new(-1166, 73, -4346)},
        {"Magma Village", Vector3.new(-5414, 88, -2790)},
        {"Underwater City", Vector3.new(-4570, 272, -2580)},
        {"Fishman Island", Vector3.new(-2586, 8, -3343)},
        {"Fountain City", Vector3.new(-2270, 16, 5215)},
        {"Thunder God", Vector3.new(-7748, 24200, -24930)},
        {"Ice Castle", Vector3.new(5950, 47, -7289)},
        {"Forgotten Island", Vector3.new(-3034, 314, -7476)},
        {"Floating Turtle", Vector3.new(-13425, 367, -9450)},
        {"Castle on the Sea", Vector3.new(-13500, 285, -9600)},
        {"Haunted Castle", Vector3.new(-9510, 141, 5845)},
        {"Sea of Treats", Vector3.new(-9500, 141, 5800)},
        {"Port Town", Vector3.new(-13442, 285, -9400)},
        {"Hydra Island", Vector3.new(-13520, 285, -9620)},
    }
    for _, island in pairs(islands) do
        local part = Instance.new("Part")
        part.Position = island[2]
        part.Size = Vector3.new(1, 1, 1)
        part.Transparency = 1
        part.CanCollide = false
        part.Anchored = true
        part.Parent = nil -- hidden by default

        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 200, 0, 30)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 10000
        billboard.Parent = part

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = island[1]
        label.TextColor3 = ESPColors.Island
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.TextStrokeTransparency = 0.3
        label.Parent = billboard

        table.insert(IslandParts, {Part = part, Name = island[1]})
    end
end
setupIslandESP()

-- ESP update loop
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            -- Fruit ESP
            if Config.FruitESP then
                clearESP("Fruit")
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj:IsA("Model") and obj.Name:lower():match("fruit") then
                        addESP(obj, "Fruit", "Devil Fruit: " .. obj.Name)
                    end
                end
            else
                clearESP("Fruit")
            end

            -- Chest ESP
            if Config.ChestESP then
                clearESP("Chest")
                local chests = findAllChests()
                for _, chest in pairs(chests) do
                    addESP(chest.Model, "Chest", "Chest")
                end
            else
                clearESP("Chest")
            end

            -- Mob ESP
            if Config.MobESP then
                clearESP("Mob")
                local enemies = Workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, mob in pairs(enemies:GetChildren()) do
                        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                            addESP(mob, "Mob", mob.Name .. " [" .. math.floor(mob.Humanoid.Health) .. " HP]")
                        end
                    end
                end
            else
                clearESP("Mob")
            end

            -- Player ESP
            if Config.PlayerESP then
                clearESP("Player")
                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        addESP(plr.Character, "Player", plr.Name)
                    end
                end
            else
                clearESP("Player")
            end

            -- Island ESP
            for _, islandData in pairs(IslandParts) do
                if Config.IslandESP then
                    islandData.Part.Parent = Workspace
                else
                    islandData.Part.Parent = nil
                end
            end
        end)
    end
end)

-- ============================================================
-- THREE SEAS TELEPORT DATA
-- ============================================================
local SeaIslands = {
    ["First Sea"] = {
        {"Windmill Village", Vector3.new(1059, 16, 1548)},
        {"Jungle", Vector3.new(-1591, 37, 167)},
        {"Pirate Village", Vector3.new(-1139, 13, 4049)},
        {"Desert", Vector3.new(974, 6, 4556)},
        {"Snow Island", Vector3.new(1366, 7, -477)},
        {"MarineFord", Vector3.new(-4800, 22, 4314)},
        {"Sky Island (Upper Yard)", Vector3.new(-4864, 724, -2609)},
        {"Prison", Vector3.new(5310, 1, 4740)},
        {"Colosseum", Vector3.new(-1166, 73, -4346)},
        {"Magma Village", Vector3.new(-5414, 88, -2790)},
        {"Underwater City", Vector3.new(-4570, 272, -2580)},
        {"Fishman Island", Vector3.new(-2586, 8, -3343)},
        {"Fountain City", Vector3.new(-2270, 16, 5215)},
        {"Thunder God", Vector3.new(-7748, 24200, -24930)},
        {"Ice Castle", Vector3.new(5950, 47, -7289)},
        {"Forgotten Island", Vector3.new(-3034, 314, -7476)},
    },
    ["Second Sea"] = {
        {"The Cafe", Vector3.new(-380, 74, 314)},
        {"Light House", Vector3.new(-378, 74, 304)},
        {"Dark Arena", Vector3.new(-340, 13, 30)},
        {"Gravestone", Vector3.new(-480, 5, 330)},
        {"Pirate Millionaire Island", Vector3.new(-1946, 100, -8346)},
        {"Galley Captain Island", Vector3.new(-1810, 100, -8543)},
        {"Island Empress Island", Vector3.new(-13500, 285, -9600)},
        {"Forest Pirate Island", Vector3.new(-13425, 367, -9450)},
        {"Mini Sky Island", Vector3.new(-13350, 375, -9350)},
        {"Castle on the Sea", Vector3.new(-13500, 285, -9600)},
    },
    ["Third Sea"] = {
        {"Port Town", Vector3.new(-13442, 285, -9400)},
        {"Hydra Island", Vector3.new(-13520, 285, -9620)},
        {"Great Tree (Third Sea)", Vector3.new(-13480, 380, -9500)},
        {"Floating Turtle", Vector3.new(-13425, 367, -9450)},
        {"Haunted Castle", Vector3.new(-9510, 141, 5845)},
        {"Sea of Treats", Vector3.new(-9500, 141, 5800)},
        {"Cocoa Warrior Island", Vector3.new(-13425, 367, -9450)},
        {"Yeti Island", Vector3.new(-13440, 367, -9480)},
        {"Peanut Island", Vector3.new(-13445, 367, -9490)},
        {"Cake Queen Island", Vector3.new(-13460, 367, -9520)},
    },
}

-- ============================================================
-- BUILD PAGES
-- ============================================================

-- HOME
local HomeTab = createTab("Home", "H")
HomeTab:Section("Player Information")
HomeTab:Label("Username: " .. LocalPlayer.Name)
HomeTab:Label("Display Name: " .. LocalPlayer.DisplayName)
local levelLabel = HomeTab:Label("Level: Loading...")
local beliLabel = HomeTab:Label("Beli: Loading...")
local fragLabel = HomeTab:Label("Fragments: Loading...")
local questLabel = HomeTab:Label("Best Quest: None")

task.spawn(function()
    while true do
        task.wait(2)
        local data = LocalPlayer:FindFirstChild("Data")
        if data then
            if data:FindFirstChild("Level") then levelLabel.Set("Level: " .. tostring(data.Level.Value)) end
            if data:FindFirstChild("Beli") then beliLabel.Set("Beli: " .. tostring(data.Beli.Value)) end
            if data:FindFirstChild("Fragments") then fragLabel.Set("Fragments: " .. tostring(data.Fragments.Value)) end
        end
        local quest = getBestQuest()
        if quest then questLabel.Set("Best Quest: " .. quest.Name .. " (Lv." .. quest.Req .. ")") end
    end
end)

HomeTab:Section("Quick Actions")
HomeTab:Button("Stop All Actions", function()
    Config.AutoFarm = false
    Config.AutoQuest = false
    Config.AutoChests = false
    Config.AutoFruits = false
    Config.AutoStats = false
    Config.AutoHop = false
    Config.KillAura = false
    stopMovement()
    notify("Stopped", "All actions cancelled", 2, "warning")
end)
HomeTab:Button("Rejoin Server", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
HomeTab:Button("Copy Server ID", function() setclipboard(game.JobId); notify("Copied", "Server ID copied to clipboard", 2, "success") end)
HomeTab:Button("Server Hop", function() hopServer() end)
HomeTab:Section("About")
HomeTab:Label("Ebanat Hub v3.0.0")
HomeTab:Label("Built by ENI")
HomeTab:Label("Press RightShift to toggle UI")

-- AUTO FARM — with cancellable actions
local FarmTab = createTab("Farm", "S")
FarmTab:Section("Combat")
FarmTab:Toggle("Auto Farm", "Automatically farms nearest mobs for XP", false, function(state)
    Config.AutoFarm = state
    if not state then stopMovement() end
    notify("Auto Farm", state and "Enabled" or "Disabled", 2, state and "success" or "warning")
end)
FarmTab:Toggle("Auto Quest", "Auto accepts best quest (instant teleport)", false, function(state)
    Config.AutoQuest = state
    if not state then stopMovement() end
end)
FarmTab:Toggle("Fast Attack", "Uses fast attack method", true, function(state)
    Config.FastAttack = state
end)
FarmTab:Toggle("Super Effective", "Uses all skills (Z,X,C,V,F)", false, function(state)
    Config.SuperEffective = state
end)
FarmTab:Toggle("Bring Mobs", "Teleports mobs to you", true, function(state)
    Config.BringMobs = state
end)
FarmTab:Dropdown("Attack Method", {"M1", "Skill", "Both"}, "Both", function(opt)
    Config.AttackMethod = opt
end)
FarmTab:Section("Combat Utilities")
FarmTab:Toggle("Kill Aura", "Attacks all nearby mobs", false, function(state)
    Config.KillAura = state
    notify("Kill Aura", state and "Enabled" or "Disabled", 2, state and "success" or "warning")
end)
FarmTab:Slider("Aura Range", 10, 200, 50, " studs", function(val)
    Config.AuraRange = val
end)
FarmTab:Section("Manual Actions")
FarmTab:Button("Farm Nearest Mob", function()
    local mob = getClosestMob()
    if mob then bringMob(mob); attackMob(mob); notify("Farm", "Attacking " .. mob.Name, 2)
    else notify("Farm", "No mobs found", 2, "warning") end
end)
FarmTab:Button("Take Best Quest", function()
    local quest = getBestQuest()
    if quest then
        teleportTo(quest.Pos)
        task.wait(0.3)
        local comm = getCommF()
        if comm then pcall(function() comm:InvokeServer("StartQuest", quest.Name, 1) end) end
        notify("Quest", "Taking quest: " .. quest.Name, 2)
    end
end)

-- CRITICAL FIX: Auto farm loop uses teleportTo (instant) instead of tweenTo (blocking)
-- This means toggling off immediately stops all movement
task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.AutoFarm then
            pcall(function()
                if not RootPart then refreshCharacter() return end
                local quest = getBestQuest()
                if not quest then return end

                -- Auto quest: instant teleport, cancellable
                if Config.AutoQuest and not hasActiveQuest() then
                    teleportTo(quest.Pos)
                    task.wait(0.3)
                    if not Config.AutoFarm then return end
                    local comm = getCommF()
                    if comm then
                        pcall(function() comm:InvokeServer("StartQuest", quest.Name, 1) end)
                    end
                    task.wait(0.5)
                    return
                end

                -- Find and attack mob
                local mob = getClosestMob(quest.Mob) or getClosestMob(nil)
                if mob then
                    if Config.BringMobs then bringMob(mob) end
                    attackMob(mob)
                end
            end)
        end
    end
end)

-- Kill Aura loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if Config.KillAura and RootPart then
            pcall(function()
                local enemies = Workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, mob in pairs(enemies:GetChildren()) do
                        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                            local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                            if mobRoot then
                                local dist = (RootPart.Position - mobRoot.Position).Magnitude
                                if dist <= Config.AuraRange then
                                    bringMob(mob)
                                    attackMob(mob)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- CHESTS — FIXED: better detection + instant teleport
local ChestTab = createTab("Chests", "$")
ChestTab:Section("Auto Chest Farm")
ChestTab:Toggle("Auto Collect Chests", "Teleports to and collects all chests", false, function(state)
    Config.AutoChests = state
    if not state then stopMovement() end
    notify("Chest Farm", state and "Enabled" or "Disabled", 2, state and "success" or "warning")
end)
ChestTab:Button("Collect All Chests Now", function()
    notify("Chests", "Searching for chests...", 2)
    task.spawn(function()
        if not RootPart then return end
        local chests = findAllChests()
        if #chests == 0 then
            notify("Chests", "No chests found in this server", 3, "warning")
            return
        end
        notify("Chests", "Found " .. #chests .. " chests, collecting...", 2, "success")
        for i, chest in pairs(chests) do
            if RootPart and chest.Part and chest.Part.Parent then
                teleportTo(chest.Pos + Vector3.new(0, 5, 0))
                task.wait(0.2)
                pcall(function()
                    firetouchinterest(RootPart, chest.Part, 0)
                    firetouchinterest(RootPart, chest.Part, 1)
                end)
                task.wait(0.1)
            end
        end
        notify("Chests", "Collection complete!", 2, "success")
    end)
end)

-- Chest loop — uses teleportTo (instant, cancellable)
task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.AutoChests and RootPart then
            pcall(function()
                local chests = findAllChests()
                for _, chest in pairs(chests) do
                    if not Config.AutoChests then break end
                    if chest.Part and chest.Part.Parent then
                        teleportTo(chest.Pos + Vector3.new(0, 5, 0))
                        task.wait(0.2)
                        if not Config.AutoChests then break end
                        pcall(function()
                            firetouchinterest(RootPart, chest.Part, 0)
                            firetouchinterest(RootPart, chest.Part, 1)
                        end)
                        task.wait(0.1)
                    end
                end
            end)
        end
    end
end)

-- FRUITS
local FruitsTab = createTab("Fruits", "F")
FruitsTab:Section("Fruit Collection")
FruitsTab:Toggle("Auto Farm Fruits", "Collects spawned devil fruits", false, function(state)
    Config.AutoFruits = state
    if not state then stopMovement() end
    notify("Fruit Farm", state and "Enabled" or "Disabled", 2, state and "success" or "warning")
end)
FruitsTab:Toggle("Auto Store Fruits", "Stores collected fruits in inventory", false, function(state)
    Config.AutoStoreFruits = state
end)
FruitsTab:Section("Fruit Shop")
FruitsTab:Toggle("Auto Buy Fruit", "Auto buys selected fruit from shop", false, function(state)
    Config.AutoBuyFruit = state
end)
FruitsTab:Dropdown("Select Fruit", {
    "Dragon", "Kitsune", "Leopard", "Dough", "Venom", "Shadow", "Control", "Gravity", "Buddha",
    "Phoenix", "Rumble", "Paw", "Revive", "Sand", "Dark", "Ice", "Light", "Magma", "Rubber",
    "Diamond", "String", "Portal", "Sound", "Spider", "Blizzard"
}, "Dragon", function(opt) Config.SelectedFruit = opt end)
FruitsTab:Button("Buy Random Fruit", function()
    local comm = getCommF()
    if comm then pcall(function() comm:InvokeServer("GetRandomFruit") end); notify("Shop", "Purchased random fruit", 2, "success") end
end)
FruitsTab:Button("Store Current Fruit", function()
    local comm = getCommF()
    if comm then pcall(function() comm:InvokeServer("StoreFruit") end); notify("Storage", "Fruit stored", 2, "success") end
end)

-- Fruit loop — uses teleportTo
task.spawn(function()
    while true do
        task.wait(0.5)
        if Config.AutoFruits and RootPart then
            pcall(function()
                for _, obj in pairs(Workspace:GetChildren()) do
                    if not Config.AutoFruits then break end
                    if obj:IsA("Model") and obj.Name:lower():match("fruit") then
                        local part = obj:FindFirstChildWhichIsA("BasePart")
                        if part then
                            teleportTo(part.Position + Vector3.new(0, 5, 0))
                            task.wait(0.2)
                            if not Config.AutoFruits then break end
                            pcall(function()
                                firetouchinterest(RootPart, part, 0)
                                firetouchinterest(RootPart, part, 1)
                            end)
                            if Config.AutoStoreFruits then
                                local comm = getCommF()
                                if comm then pcall(function() comm:InvokeServer("StoreFruit") end) end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- STATS
local StatsTab = createTab("Stats", "P")
StatsTab:Section("Auto Stats Distribution")
StatsTab:Toggle("Auto Distribute Stats", "Automatically allocates stat points", false, function(state)
    Config.AutoStats = state
    notify("Auto Stats", state and "Enabled" or "Disabled", 2, state and "success" or "warning")
end)
StatsTab:Section("Point Allocation")
StatsTab:Slider("Melee", 0, 100, 25, "%", function(val) Config.MeleePts = val end)
StatsTab:Slider("Defense", 0, 100, 25, "%", function(val) Config.DefensePts = val end)
StatsTab:Slider("Sword", 0, 100, 25, "%", function(val) Config.SwordPts = val end)
StatsTab:Slider("Gun", 0, 100, 0, "%", function(val) Config.GunPts = val end)
StatsTab:Slider("Blox Fruit", 0, 100, 25, "%", function(val) Config.FruitPts = val end)
StatsTab:Button("Distribute Now", function()
    local comm = getCommF()
    if not comm then return end
    local data = LocalPlayer:FindFirstChild("Data")
    if not data or not data:FindFirstChild("Points") then return end
    local points = data.Points.Value
    if points > 0 then
        local total = Config.MeleePts + Config.DefensePts + Config.SwordPts + Config.GunPts + Config.FruitPts
        if total == 0 then total = 100 end
        pcall(function()
            comm:InvokeServer("AddPoint", "Melee", math.floor(points * Config.MeleePts / total))
            comm:InvokeServer("AddPoint", "Defense", math.floor(points * Config.DefensePts / total))
            comm:InvokeServer("AddPoint", "Sword", math.floor(points * Config.SwordPts / total))
            comm:InvokeServer("AddPoint", "Gun", math.floor(points * Config.GunPts / total))
            comm:InvokeServer("AddPoint", "Demon Fruit", math.floor(points * Config.FruitPts / total))
        end)
        notify("Stats", "Points distributed!", 2, "success")
    else
        notify("Stats", "No points available", 2, "warning")
    end
end)

task.spawn(function()
    while true do
        task.wait(2)
        if Config.AutoStats then
            pcall(function()
                local comm = getCommF()
                if not comm then return end
                local data = LocalPlayer:FindFirstChild("Data")
                if not data or not data:FindFirstChild("Points") then return end
                local points = data.Points.Value
                if points > 0 then
                    local total = Config.MeleePts + Config.DefensePts + Config.SwordPts + Config.GunPts + Config.FruitPts
                    if total == 0 then total = 100 end
                    pcall(function()
                        comm:InvokeServer("AddPoint", "Melee", math.floor(points * Config.MeleePts / total))
                        comm:InvokeServer("AddPoint", "Defense", math.floor(points * Config.DefensePts / total))
                        comm:InvokeServer("AddPoint", "Sword", math.floor(points * Config.SwordPts / total))
                        comm:InvokeServer("AddPoint", "Gun", math.floor(points * Config.GunPts / total))
                        comm:InvokeServer("AddPoint", "Demon Fruit", math.floor(points * Config.FruitPts / total))
                    end)
                end
            end)
        end
    end
end)

-- ESP TAB — NEW
local ESPTab = createTab("ESP", "E")
ESPTab:Section("Visual ESP")
ESPTab:Toggle("Fruit ESP", "Highlights all devil fruits", false, function(state)
    Config.FruitESP = state
    if not state then clearESP("Fruit") end
    notify("ESP", "Fruit ESP " .. (state and "Enabled" or "Disabled"), 2, state and "success" or "warning")
end)
ESPTab:Toggle("Chest ESP", "Highlights all chests", false, function(state)
    Config.ChestESP = state
    if not state then clearESP("Chest") end
    notify("ESP", "Chest ESP " .. (state and "Enabled" or "Disabled"), 2, state and "success" or "warning")
end)
ESPTab:Toggle("Island ESP", "Shows island names in world", false, function(state)
    Config.IslandESP = state
    notify("ESP", "Island ESP " .. (state and "Enabled" or "Disabled"), 2, state and "success" or "warning")
end)
ESPTab:Toggle("Mob ESP", "Highlights all mobs with HP", false, function(state)
    Config.MobESP = state
    if not state then clearESP("Mob") end
    notify("ESP", "Mob ESP " .. (state and "Enabled" or "Disabled"), 2, state and "success" or "warning")
end)
ESPTab:Toggle("Player ESP", "Highlights all players", false, function(state)
    Config.PlayerESP = state
    if not state then clearESP("Player") end
    notify("ESP", "Player ESP " .. (state and "Enabled" or "Disabled"), 2, state and "success" or "warning")
end)
ESPTab:Section("ESP Actions")
ESPTab:Button("Clear All ESP", function()
    clearAllESP()
    Config.FruitESP = false; Config.ChestESP = false; Config.IslandESP = false
    Config.MobESP = false; Config.PlayerESP = false
    notify("ESP", "All ESP cleared", 2, "warning")
end)

-- TELEPORT — THREE SEAS
local TeleportTab = createTab("Teleport", "T")
for seaName, islands in pairs(SeaIslands) do
    TeleportTab:Section(seaName)
    for _, island in pairs(islands) do
        TeleportTab:Button(island[1], function()
            if RootPart then
                teleportTo(island[2])
                notify("Teleport", "Teleported to " .. island[1], 2, "success")
            end
        end)
    end
end

-- SERVER HOP
local HopTab = createTab("Hop", "R")
HopTab:Section("Auto Server Hop")
HopTab:Toggle("Auto Hop", "Hops when no mobs or low population", false, function(state)
    Config.AutoHop = state
    notify("Auto Hop", state and "Enabled" or "Disabled", 2, state and "success" or "warning")
    if state then
        task.spawn(function()
            while Config.AutoHop do
                task.wait(10)
                local playerCount = #Players:GetPlayers()
                if playerCount <= Config.HopMinPlayers then hopServer(); break end
                local mobFound = false
                local enemies = Workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, mob in pairs(enemies:GetChildren()) do
                        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then mobFound = true; break end
                    end
                end
                if not mobFound then
                    task.wait(15)
                    mobFound = false
                    if enemies then
                        for _, mob in pairs(enemies:GetChildren()) do
                            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then mobFound = true; break end
                        end
                    end
                    if not mobFound then hopServer(); break end
                end
            end
        end)
    end
end)
HopTab:Slider("Min Players", 1, 30, 5, "", function(val) Config.HopMinPlayers = val end)
HopTab:Button("Hop Now", function() hopServer() end)

-- SETTINGS
local SettingsTab = createTab("Settings", "X")
SettingsTab:Section("Interface")
SettingsTab:Dropdown("UI Theme", {"Purple", "Blue", "Red", "Green", "Pink", "Orange", "Cyan"}, "Purple", function(opt)
    local preset = ThemePresets[opt]
    if preset then
        Theme.Accent = preset[1]; Theme.AccentLight = preset[2]; Theme.AccentDark = preset[3]
        gradient(Logo, Theme.AccentLight, Theme.AccentDark, 135)
        stroke(Window, Theme.AccentDark, 1, 0.3)
        stroke(VersionBadge, Theme.AccentDark, 1, 0.3)
        notify("Theme", "Changed to " .. opt, 2, "success")
    end
end)
SettingsTab:Slider("UI Scale", 50, 150, 100, "%", function(val)
    TweenService:Create(UIScale, TweenInfo.new(0.2), {Scale = val / 100}):Play()
end)
SettingsTab:Section("System")
SettingsTab:Toggle("Anti-AFK", "Prevents being kicked for inactivity", true, function(state)
    Config.AntiAFK = state
end)
SettingsTab:Button("Reset Window Position", function()
    TweenService:Create(Window, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -340, 0.5, -230)}):Play()
    notify("Settings", "Position reset", 2)
end)
SettingsTab:Button("Destroy UI", function()
    clearAllESP()
    ScreenGui:Destroy()
end)
SettingsTab:Section("Keybinds")
SettingsTab:Keybind("Toggle UI", Enum.KeyCode.RightShift, function() Window.Visible = not Window.Visible end)

-- ANTI-AFK
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- KEYBIND
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Window.Visible = not Window.Visible
    end
end)

-- INIT
task.wait(0.3)
notify("Ebanat Hub", "Welcome, " .. LocalPlayer.Name .. "!", 4, "success")
task.wait(1)
notify("Loaded", "v3.0 - All systems operational", 3, "success")
