--[[
    EBANAT HUB | BLOX FRUITS
    Version: 1.0.0
    Executor: Delta (PC/Mobile)
    
    Features:
        - Auto Farm (Level, Quest, Fast Attack, Bring Mobs)
        - Auto Farm Chests (Money)
        - Auto Farm Fruits (Collect + Store)
        - Auto Buy Fruits
        - Auto Stats Distribution
        - Auto Server Hop
        - Island Teleport
        - Player List Utility
        - Anti-AFK
        - Customizable UI Theme & Scale
    
    Credits: Ebanat Hub by ENI
]]

-- ============================================================
-- SERVICES
-- ============================================================
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local VirtualUser       = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace         = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================
-- THEME
-- ============================================================
local Theme = {
    -- Backgrounds
    Background      = Color3.fromRGB(15, 15, 20),
    BackgroundLight = Color3.fromRGB(22, 22, 28),
    Card            = Color3.fromRGB(28, 28, 36),
    CardHover       = Color3.fromRGB(34, 34, 44),
    Sidebar         = Color3.fromRGB(18, 18, 24),
    
    -- Accent
    Accent          = Color3.fromRGB(138, 106, 255),
    AccentLight     = Color3.fromRGB(170, 140, 255),
    AccentDark      = Color3.fromRGB(98, 72, 200),
    AccentGradient  = Color3.fromRGB(180, 150, 255),
    
    -- Text
    Text            = Color3.fromRGB(235, 235, 245),
    TextDim         = Color3.fromRGB(130, 130, 150),
    TextDark        = Color3.fromRGB(80, 80, 100),
    
    -- Controls
    ToggleOff       = Color3.fromRGB(40, 40, 50),
    ToggleOn        = Color3.fromRGB(138, 106, 255),
    Knob            = Color3.fromRGB(255, 255, 255),
    SliderTrack     = Color3.fromRGB(35, 35, 45),
    SliderFill      = Color3.fromRGB(138, 106, 255),
    
    -- Misc
    Divider         = Color3.fromRGB(38, 38, 48),
    Hover           = Color3.fromRGB(32, 32, 42),
    Success         = Color3.fromRGB(70, 200, 110),
    Danger          = Color3.fromRGB(230, 70, 80),
    Warning         = Color3.fromRGB(240, 180, 60),
    
    -- Layout
    CornerRadius = 8,
    CornerRadiusSmall = 6,
    CornerRadiusLarge = 12,
}

local ThemePresets = {
    ["Purple"]   = { Accent = Color3.fromRGB(138, 106, 255), AccentLight = Color3.fromRGB(170, 140, 255), AccentDark = Color3.fromRGB(98, 72, 200), AccentGradient = Color3.fromRGB(180, 150, 255) },
    ["Blue"]     = { Accent = Color3.fromRGB(70, 130, 250), AccentLight = Color3.fromRGB(110, 160, 255), AccentDark = Color3.fromRGB(50, 95, 190), AccentGradient = Color3.fromRGB(130, 180, 255) },
    ["Red"]      = { Accent = Color3.fromRGB(230, 70, 80), AccentLight = Color3.fromRGB(255, 110, 120), AccentDark = Color3.fromRGB(170, 50, 60), AccentGradient = Color3.fromRGB(255, 140, 150) },
    ["Green"]    = { Accent = Color3.fromRGB(70, 200, 110), AccentLight = Color3.fromRGB(110, 230, 150), AccentDark = Color3.fromRGB(50, 150, 80), AccentGradient = Color3.fromRGB(140, 240, 170) },
    ["Pink"]     = { Accent = Color3.fromRGB(255, 85, 170), AccentLight = Color3.fromRGB(255, 130, 200), AccentDark = Color3.fromRGB(190, 55, 130), AccentGradient = Color3.fromRGB(255, 160, 210) },
    ["Orange"]   = { Accent = Color3.fromRGB(255, 150, 50), AccentLight = Color3.fromRGB(255, 180, 90), AccentDark = Color3.fromRGB(190, 110, 30), AccentGradient = Color3.fromRGB(255, 200, 120) },
    ["Cyan"]     = { Accent = Color3.fromRGB(50, 200, 220), AccentLight = Color3.fromRGB(90, 230, 245), AccentDark = Color3.fromRGB(30, 150, 170), AccentGradient = Color3.fromRGB(120, 240, 250) },
}

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================
local function create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function corner(parent, radius)
    return create("UICorner", {
        CornerRadius = UDim.new(0, radius or Theme.CornerRadius),
        Parent = parent,
    })
end

local function stroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or Theme.Divider,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = parent,
    })
end

local function gradient(parent, c1, c2, rotation)
    return create("UIGradient", {
        Color = ColorSequence.new(c1, c2),
        Rotation = rotation or 90,
        Parent = parent,
    })
end

local function padding(parent, all)
    return create("UIPadding", {
        PaddingTop = UDim.new(0, all or 0),
        PaddingBottom = UDim.new(0, all or 0),
        PaddingLeft = UDim.new(0, all or 0),
        PaddingRight = UDim.new(0, all or 0),
        Parent = parent,
    })
end

local function padEx(parent, top, bottom, left, right)
    return create("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        Parent = parent,
    })
end

local function rippleEffect(parent, x, y)
    local r = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.85,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, x or 0, 0, y or 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 1000,
        Parent = parent,
    })
    corner(r, 999)
    local tween = TweenService:Create(r, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 400, 0, 400),
        BackgroundTransparency = 1,
    })
    tween:Play()
    tween.Completed:Connect(function() r:Destroy() end)
end

-- ============================================================
-- MAIN GUI
-- ============================================================
local ScreenGui = create("ScreenGui", {
    Name = "EbanatHub_" .. tostring(math.random(10000, 99999)),
    Parent = game:GetService("CoreGui"),
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
})

local UIScale = create("UIScale", {
    Scale = 1,
    Parent = ScreenGui,
})

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local Window = create("Frame", {
    Name = "Window",
    Size = UDim2.new(0, 640, 0, 420),
    Position = UDim2.new(0.5, -320, 0.5, -210),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    Parent = ScreenGui,
})
corner(Window, Theme.CornerRadiusLarge)

-- Subtle gradient on background
gradient(Window, Theme.Background, Color3.fromRGB(12, 12, 16), 180)

-- Outer glow stroke
stroke(Window, Theme.AccentDark, 1, 0.3)

-- Shadow
local Shadow = create("ImageLabel", {
    Size = UDim2.new(1, 40, 1, 40),
    Position = UDim2.new(0, -20, 0, -20),
    BackgroundTransparency = 1,
    Image = "rbxassetid://1316045217",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.4,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(10, 10, 118, 118),
    ZIndex = -1,
    Parent = Window,
})

-- ============================================================
-- TITLE BAR
-- ============================================================
local TitleBar = create("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 44),
    BackgroundColor3 = Theme.BackgroundLight,
    BorderSizePixel = 0,
    Parent = Window,
})
corner(TitleBar, Theme.CornerRadiusLarge)

-- Fix bottom corners of title bar
create("Frame", {
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = Theme.BackgroundLight,
    BorderSizePixel = 0,
    Parent = TitleBar,
})

-- Logo
local Logo = create("Frame", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(0, 12, 0.5, -15),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Parent = TitleBar,
})
corner(Logo, 8)
gradient(Logo, Theme.AccentLight, Theme.AccentDark, 135)

local LogoText = create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "E",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBlack,
    TextSize = 18,
    Parent = Logo,
})

-- Title
local TitleLabel = create("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 50, 0, 0),
    BackgroundTransparency = 1,
    Text = "Ebanat Hub",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TitleBar,
})

local SubtitleLabel = create("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 50, 0, 0),
    BackgroundTransparency = 1,
    Text = "Blox Fruits",
    TextColor3 = Theme.TextDark,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Bottom,
    Parent = TitleBar,
})
padEx(SubtitleLabel, 0, 3, 0, 0)

-- Version badge
local VersionBadge = create("TextLabel", {
    Size = UDim2.new(0, 50, 0, 22),
    Position = UDim2.new(0, 162, 0.5, -11),
    BackgroundColor3 = Theme.Card,
    BorderSizePixel = 0,
    Text = "v1.0",
    TextColor3 = Theme.AccentLight,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    Parent = TitleBar,
})
corner(VersionBadge, 5)
stroke(VersionBadge, Theme.AccentDark, 1, 0.3)

-- Window controls
local MinimizeBtn = create("TextButton", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -72, 0.5, -14),
    BackgroundColor3 = Theme.Card,
    BorderSizePixel = 0,
    Text = "—",
    TextColor3 = Theme.TextDim,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    AutoButtonColor = false,
    Parent = TitleBar,
})
corner(MinimizeBtn, 6)

local CloseBtn = create("TextButton", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -38, 0.5, -14),
    BackgroundColor3 = Theme.Card,
    BorderSizePixel = 0,
    Text = "✕",
    TextColor3 = Theme.TextDim,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    AutoButtonColor = false,
    Parent = TitleBar,
})
corner(CloseBtn, 6)

-- Hover effects for buttons
MinimizeBtn.MouseEnter:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.CardHover, TextColor3 = Theme.Text}):Play()
end)
MinimizeBtn.MouseLeave:Connect(function()
    TweenService:Create(MinimizeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card, TextColor3 = Theme.TextDim}):Play()
end)

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Danger, TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card, TextColor3 = Theme.TextDim}):Play()
end)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    rippleEffect(MinimizeBtn, 14, 14)
    minimized = not minimized
    if minimized then
        TweenService:Create(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 640, 0, 44),
        }):Play()
    else
        TweenService:Create(Window, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 640, 0, 420),
        }):Play()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    rippleEffect(CloseBtn, 14, 14)
    local closeTween = TweenService:Create(Window, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1,
    })
    closeTween:Play()
    closeTween.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end)

-- ============================================================
-- DRAG LOGIC
-- ============================================================
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Window.Position
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
-- TAB BAR
-- ============================================================
local TabBar = create("Frame", {
    Name = "TabBar",
    Size = UDim2.new(1, -24, 0, 36),
    Position = UDim2.new(0, 12, 0, 50),
    BackgroundColor3 = Theme.BackgroundLight,
    BorderSizePixel = 0,
    Parent = Window,
})
corner(TabBar, Theme.CornerRadius)

local TabContainer = create("Frame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Parent = TabBar,
})
padEx(TabContainer, 4, 4, 4, 4)

local TabList = create("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = TabContainer,
})

-- ============================================================
-- CONTENT AREA
-- ============================================================
local ContentArea = create("Frame", {
    Name = "ContentArea",
    Size = UDim2.new(1, -24, 1, -98),
    Position = UDim2.new(0, 12, 0, 92),
    BackgroundTransparency = 1,
    Parent = Window,
})

local Pages = {}
local TabButtons = {}
local currentTab = nil
local tabIndex = 0

-- Tab indicator (animated underline)
local TabIndicator = create("Frame", {
    Name = "Indicator",
    Size = UDim2.new(0, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, -2),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Parent = TabBar,
    Visible = false,
})
corner(TabIndicator, 1)

-- ============================================================
-- PAGE CREATION SYSTEM
-- ============================================================
local function createTab(name, icon)
    tabIndex = tabIndex + 1
    
    -- Tab Button
    local tabBtn = create("TextButton", {
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundColor3 = Theme.BackgroundLight,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = TabContainer,
        LayoutOrder = tabIndex,
    })
    corner(tabBtn, Theme.CornerRadiusSmall)
    
    local tabIcon = create("TextLabel", {
        Size = UDim2.new(0, 18, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = icon or "",
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        Parent = tabBtn,
    })
    
    local tabLabel = create("TextLabel", {
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabBtn,
    })
    
    -- Page (scrolling frame)
    local page = create("ScrollingFrame", {
        Name = name .. "Page",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = ContentArea,
    })
    padEx(page, 0, 0, 0, 4)
    
    local pageLayout = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })
    
    Pages[name] = page
    TabButtons[name] = { Button = tabBtn, Icon = tabIcon, Label = tabLabel }
    
    -- Tab switching
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
        
        -- Animate indicator
        TabIndicator.Visible = true
        TweenService:Create(TabIndicator, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, tabBtn.AbsoluteSize.X - 8, 0, 2),
            Position = UDim2.new(0, tabBtn.AbsolutePosition.X - TabBar.AbsolutePosition.X + 4, 1, -2),
        }):Play()
        
        currentTab = name
    end
    
    tabBtn.MouseButton1Click:Connect(function()
        rippleEffect(tabBtn, tabBtn.AbsoluteSize.X / 2, tabBtn.AbsoluteSize.Y / 2)
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
    
    -- ============================================================
    -- PAGE ELEMENT API
    -- ============================================================
    local api = {}
    local elementOrder = 0
    
    -- Section header
    function api:Section(title)
        local section = create("Frame", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            Parent = page,
            LayoutOrder = elementOrder,
        })
        elementOrder = elementOrder + 1
        
        local label = create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Theme.TextDark,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = section,
        })
        padEx(section, 0, 0, 2, 2)
        
        return self
    end
    
    -- Toggle
    function api:Toggle(text, description, default, callback)
        local toggleCard = create("Frame", {
            Size = UDim2.new(1, 0, 0, 44),
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            Parent = page,
            LayoutOrder = elementOrder,
        })
        elementOrder = elementOrder + 1
        corner(toggleCard, Theme.CornerRadius)
        
        local label = create("TextLabel", {
            Size = UDim2.new(1, -70, 1, description and -14 or 0),
            Position = UDim2.new(0, 14, 0, description and 6 or 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = description and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
            Parent = toggleCard,
        })
        
        if description then
            local desc = create("TextLabel", {
                Size = UDim2.new(1, -70, 0, 14),
                Position = UDim2.new(0, 14, 0, 24),
                BackgroundTransparency = 1,
                Text = description,
                TextColor3 = Theme.TextDark,
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleCard,
            })
        end
        
        -- Toggle switch
        local switchBg = create("Frame", {
            Size = UDim2.new(0, 40, 0, 22),
            Position = UDim2.new(1, -52, 0.5, -11),
            BackgroundColor3 = Theme.ToggleOff,
            BorderSizePixel = 0,
            Parent = toggleCard,
        })
        corner(switchBg, 11)
        
        local knob = create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = Theme.Knob,
            BorderSizePixel = 0,
            Parent = switchBg,
        })
        corner(knob, 8)
        
        local state = default or false
        
        local function update()
            if state then
                TweenService:Create(switchBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = Theme.ToggleOn,
                }):Play()
                TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(1, -19, 0.5, -8),
                }):Play()
            else
                TweenService:Create(switchBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = Theme.ToggleOff,
                }):Play()
                TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 3, 0.5, -8),
                }):Play()
            end
        end
        
        local hitbox = create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = toggleCard,
        })
        
        hitbox.MouseButton1Click:Connect(function()
            state = not state
            update()
            rippleEffect(toggleCard, toggleCard.AbsoluteSize.X - 30, toggleCard.AbsoluteSize.Y / 2)
            if callback then callback(state) end
        end)
        
        update()
        
        return {
            Set = function(val) state = val; update(); if callback then callback(state) end end,
            Get = function() return state end,
        }
    end
    
    -- Button
    function api:Button(text, callback)
        local btnCard = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = page,
            LayoutOrder = elementOrder,
        })
        elementOrder = elementOrder + 1
        corner(btnCard, Theme.CornerRadius)
        stroke(btnCard, Theme.AccentDark, 1, 0.4)
        
        local label = create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Parent = btnCard,
        })
        
        btnCard.MouseEnter:Connect(function()
            TweenService:Create(btnCard, TweenInfo.new(0.15), {BackgroundColor3 = Theme.CardHover}):Play()
            TweenService:Create(label, TweenInfo.new(0.15), {TextColor3 = Theme.AccentLight}):Play()
        end)
        btnCard.MouseLeave:Connect(function()
            TweenService:Create(btnCard, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Card}):Play()
            TweenService:Create(label, TweenInfo.new(0.15), {TextColor3 = Theme.Text}):Play()
        end)
        btnCard.MouseButton1Click:Connect(function()
            rippleEffect(btnCard, btnCard.AbsoluteSize.X / 2, btnCard.AbsoluteSize.Y / 2)
            if callback then callback() end
        end)
        
        return btnCard
    end
    
    -- Slider
    function api:Slider(text, min, max, default, suffix, callback)
        local sliderCard = create("Frame", {
            Size = UDim2.new(1, 0, 0, 56),
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            Parent = page,
            LayoutOrder = elementOrder,
        })
        elementOrder = elementOrder + 1
        corner(sliderCard, Theme.CornerRadius)
        padEx(sliderCard, 10, 10, 14, 14)
        
        local label = create("TextLabel", {
            Size = UDim2.new(1, -60, 0, 16),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = sliderCard,
        })
        
        local valueLabel = create("TextLabel", {
            Size = UDim2.new(0, 50, 0, 16),
            Position = UDim2.new(1, -50, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(default or min) .. (suffix or ""),
            TextColor3 = Theme.AccentLight,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = sliderCard,
        })
        
        local track = create("Frame", {
            Size = UDim2.new(1, 0, 0, 6),
            Position = UDim2.new(0, 0, 0, 28),
            BackgroundColor3 = Theme.SliderTrack,
            BorderSizePixel = 0,
            Parent = sliderCard,
        })
        corner(track, 3)
        
        local fill = create("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Theme.SliderFill,
            BorderSizePixel = 0,
            Parent = track,
        })
        corner(fill, 3)
        gradient(fill, Theme.Accent, Theme.AccentLight, 0)
        
        local knob = create("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, -7, 0.5, -7),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = track,
        })
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
        
        local hitbox = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = "",
            Parent = sliderCard,
        })
        
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
    
    -- Dropdown
    function api:Dropdown(text, options, default, callback)
        local ddCard = create("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            Parent = page,
            LayoutOrder = elementOrder,
            ClipsDescendants = true,
        })
        elementOrder = elementOrder + 1
        corner(ddCard, Theme.CornerRadius)
        
        local label = create("TextLabel", {
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = text .. ":",
            TextColor3 = Theme.TextDim,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ddCard,
        })
        
        local selectedLabel = create("TextLabel", {
            Size = UDim2.new(0, 120, 1, 0),
            Position = UDim2.new(1, -134, 0, 0),
            BackgroundTransparency = 1,
            Text = default or options[1],
            TextColor3 = Theme.AccentLight,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextYAlignment.Right,
            Parent = ddCard,
        })
        
        local arrow = create("TextLabel", {
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 1,
            Text = "▾",
            TextColor3 = Theme.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            Parent = ddCard,
        })
        
        local expanded = false
        local selected = default or options[1]
        
        local hitbox = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Text = "",
            Parent = ddCard,
        })
        
        local listFrame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, 42),
            BackgroundColor3 = Theme.BackgroundLight,
            BorderSizePixel = 0,
            Parent = ddCard,
            ZIndex = 10,
        })
        corner(listFrame, Theme.CornerRadiusSmall)
        padEx(listFrame, 4, 4, 4, 4)
        
        local listLayout = create("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = listFrame,
        })
        
        local function buildList()
            for _, child in pairs(listFrame:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            for _, opt in pairs(options) do
                local optBtn = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Theme.Card,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = listFrame,
                    ZIndex = 11,
                })
                corner(optBtn, 4)
                
                local optLabel = create("TextLabel", {
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = opt,
                    TextColor3 = opt == selected and Theme.AccentLight or Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = optBtn,
                    ZIndex = 12,
                })
                
                optBtn.MouseEnter:Connect(function()
                    TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Hover}):Play()
                    TweenService:Create(optLabel, TweenInfo.new(0.1), {TextColor3 = Theme.Text}):Play()
                end)
                optBtn.MouseLeave:Connect(function()
                    TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Card}):Play()
                    TweenService:Create(optLabel, TweenInfo.new(0.1), {TextColor3 = opt == selected and Theme.AccentLight or Theme.TextDim}):Play()
                end)
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    selectedLabel.Text = opt
                    if callback then callback(opt) end
                    
                    TweenService:Create(ddCard, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 40)}):Play()
                    TweenService:Create(arrow, TweenInfo.new(0.2), {Text = "▾"}):Play()
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
                TweenService:Create(ddCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, targetHeight),
                }):Play()
                TweenService:Create(arrow, TweenInfo.new(0.2), {Text = "▴"}):Play()
            else
                TweenService:Create(ddCard, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, 40),
                }):Play()
                TweenService:Create(arrow, TweenInfo.new(0.2), {Text = "▾"}):Play()
            end
        end)
        
        return { Set = function(val) selected = val; selectedLabel.Text = val end, Get = function() return selected end }
    end
    
    -- Label
    function api:Label(text)
        local lbl = create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = page,
            LayoutOrder = elementOrder,
        })
        elementOrder = elementOrder + 1
        return { Set = function(val) lbl.Text = val end, Get = function() return lbl.Text end }
    end
    
    -- TextBox
    function api:TextBox(placeholder, callback)
        local tbCard = create("Frame", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            Parent = page,
            LayoutOrder = elementOrder,
        })
        elementOrder = elementOrder + 1
        corner(tbCard, Theme.CornerRadius)
        stroke(tbCard, Theme.Divider, 1)
        padEx(tbCard, 0, 0, 12, 12)
        
        local input = create("TextBox", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            PlaceholderText = placeholder or "Enter...",
            PlaceholderColor3 = Theme.TextDark,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tbCard,
        })
        
        input.FocusLost:Connect(function(enter)
            if enter and callback then callback(input.Text) end
        end)
        
        return { Get = function() return input.Text end, Set = function(val) input.Text = val end }
    end
    
    -- Keybind
    function api:Keybind(text, defaultKey, callback)
        local kbCard = create("Frame", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Card,
            BorderSizePixel = 0,
            Parent = page,
            LayoutOrder = elementOrder,
        })
        elementOrder = elementOrder + 1
        corner(kbCard, Theme.CornerRadius)
        
        local label = create("TextLabel", {
            Size = UDim2.new(1, -80, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = kbCard,
        })
        
        local keyBtn = create("TextButton", {
            Size = UDim2.new(0, 60, 0, 24),
            Position = UDim2.new(1, -72, 0.5, -12),
            BackgroundColor3 = Theme.Background,
            BorderSizePixel = 0,
            Text = defaultKey and defaultKey.Name or "None",
            TextColor3 = Theme.AccentLight,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            AutoButtonColor = false,
            Parent = kbCard,
        })
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
    
    -- ============================================================
    -- AUTO-SELECT FIRST TAB
    -- ============================================================
    if tabIndex == 1 then
        task.defer(function()
            task.wait(0.1)
            selectTab()
        end)
    end
    
    return api
end

-- ============================================================
-- NOTIFICATION SYSTEM
-- ============================================================
local NotifContainer = create("Frame", {
    Size = UDim2.new(0, 280, 1, -120),
    Position = UDim2.new(1, -290, 0, 60),
    BackgroundTransparency = 1,
    Parent = ScreenGui,
})

local notifLayout = create("UIListLayout", {
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Parent = NotifContainer,
})

local function notify(title, message, duration, notifType)
    duration = duration or 3
    
    local color = Theme.Accent
    if notifType == "success" then color = Theme.Success
    elseif notifType == "danger" then color = Theme.Danger
    elseif notifType == "warning" then color = Theme.Warning
    end
    
    local notif = create("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Theme.BackgroundLight,
        BorderSizePixel = 0,
        Parent = NotifContainer,
        ClipsDescendants = true,
    })
    corner(notif, Theme.CornerRadius)
    stroke(notif, Theme.Divider, 1)
    
    local accentBar = create("Frame", {
        Size = UDim2.new(0, 3, 1, 8),
        Position = UDim2.new(0, 0, 0, 4),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = notif,
    })
    corner(accentBar, 2)
    
    local titleLabel = create("TextLabel", {
        Size = UDim2.new(1, -24, 0, 18),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })
    
    local msgLabel = create("TextLabel", {
        Size = UDim2.new(1, -24, 0, 16),
        Position = UDim2.new(0, 14, 0, 26),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })
    
    -- Progress bar
    local progressBg = create("Frame", {
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
        Parent = notif,
    })
    
    local progressFill = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = progressBg,
    })
    
    -- Entrance
    notif.Size = UDim2.new(0, 0, 0, 56)
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, 56),
    }):Play()
    
    -- Progress countdown
    TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0),
    }):Play()
    
    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 56),
            BackgroundTransparency = 1,
        }):Play()
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- ============================================================
-- CONFIG STATE
-- ============================================================
local Config = {
    AutoFarm = false,
    AutoQuest = false,
    FastAttack = true,
    BringMobs = true,
    AttackMethod = "Both",
    TweenSpeed = 200,
    AutoChests = false,
    AutoFruits = false,
    AutoStoreFruits = false,
    AutoBuyFruit = false,
    SelectedFruit = "Dragon",
    AutoStats = false,
    MeleePts = 25,
    DefensePts = 25,
    SwordPts = 25,
    GunPts = 0,
    FruitPts = 25,
    AutoHop = false,
    HopMinPlayers = 5,
    AutoReset = false,
    AntiAFK = true,
    KillAura = false,
    AuraRange = 50,
    UIScale = 1,
    SelectedTheme = "Purple",
}

-- ============================================================
-- BLOX FRUITS BACKEND
-- ============================================================
local Character, Humanoid, RootPart

local function refreshCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
end)
refreshCharacter()

local function getCommF()
    return ReplicatedStorage:FindFirstChild("CommF_")
end

local function tweenTo(pos, speed)
    speed = speed or Config.TweenSpeed
    if not RootPart then refreshCharacter() end
    if not RootPart then return end
    local dist = (RootPart.Position - pos).Magnitude
    if dist < 15 then
        RootPart.CFrame = CFrame.new(pos)
        return
    end
    local info = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
    local tw = TweenService:Create(RootPart, info, {CFrame = CFrame.new(pos)})
    tw:Play()
    tw.Completed:Wait()
end

-- Quest database
local Quests = {
    [1] = {Name = "Trainee", Mob = "Bandit", Pos = Vector3.new(1059, 16, 1548)},
    [8] = {Name = "Monkey", Mob = "Monkey", Pos = Vector3.new(-1591, 37, 167)},
    [15] = {Name = "Gorilla", Mob = "Gorilla", Pos = Vector3.new(-1233, 6, -504)},
    [30] = {Name = "Buggy", Mob = "Buggy Crew", Pos = Vector3.new(-1139, 13, 4049)},
    [45] = {Name = "Desert", Mob = "Desert Bandit", Pos = Vector3.new(974, 6, 4556)},
    [60] = {Name = "Desert Officer", Mob = "Desert Officer", Pos = Vector3.new(1322, 6, 4236)},
    [75] = {Name = "Snow Bandit", Mob = "Snow Bandit", Pos = Vector3.new(1366, 7, -477)},
    [90] = {Name = "Snow Marine", Mob = "Snow Marine", Pos = Vector3.new(1536, 7, -478)},
    [100] = {Name = "Marine", Mob = "Marine Lieutenant", Pos = Vector3.new(-4800, 22, 4314)},
    [120] = {Name = "Sky", Mob = "Sky Bandit", Pos = Vector3.new(-4864, 724, -2609)},
    [150] = {Name = "Prisoner", Mob = "Prisoner", Pos = Vector3.new(5310, 1, 4740)},
    [175] = {Name = "Dangerous Prisoner", Mob = "Dangerous Prisoner", Pos = Vector3.new(5400, 1, 4730)},
    [200] = {Name = "Tide Keeper", Mob = "Tide Keeper", Pos = Vector3.new(-4570, 272, -2580)},
    [225] = {Name = "Fishman Warrior", Mob = "Fishman Warrior", Pos = Vector3.new(-2586, 8, -3343)},
    [275] = {Name = "Wanda", Mob = "Wanda", Pos = Vector3.new(-1166, 73, -4346)},
    [300] = {Name = "Magma Ninja", Mob = "Magma Ninja", Pos = Vector3.new(-5414, 88, -2790)},
    [350] = {Name = "Marine Captain", Mob = "Marine Captain", Pos = Vector3.new(-2270, 16, 5215)},
    [400] = {Name = "Thunder God", Mob = "Thunder God", Pos = Vector3.new(-7748, 24200, -24930)},
    [450] = {Name = "Ice Soldier", Mob = "Ice Soldier", Pos = Vector3.new(5950, 47, -7289)},
    [500] = {Name = "Forgotten Warrior", Mob = "Forgotten Warrior", Pos = Vector3.new(-3034, 314, -7476)},
    [575] = {Name = "Pirate Millionaire", Mob = "Pirate Millionaire", Pos = Vector3.new(-1946, 100, -8346)},
    [625] = {Name = "Galley Captain", Mob = "Galley Captain", Pos = Vector3.new(-1810, 100, -8543)},
    [700] = {Name = "Island Empress", Mob = "Island Empress", Pos = Vector3.new(-13500, 285, -9600)},
    [850] = {Name = "Forest Pirate", Mob = "Forest Pirate", Pos = Vector3.new(-13425, 367, -9450)},
    [900] = {Name = "Mythological Pirate", Mob = "Mythological Pirate", Pos = Vector3.new(-13493, 370, -9490)},
    [1000] = {Name = "Jungle Pirate", Mob = "Jungle Pirate", Pos = Vector3.new(-13300, 370, -9400)},
    [1050] = {Name = "Musketeer Pirate", Mob = "Musketeer Pirate", Pos = Vector3.new(-13350, 375, -9350)},
    [1100] = {Name = "Reborn Skeleton", Mob = "Reborn Skeleton", Pos = Vector3.new(-9510, 141, 5845)},
    [1150] = {Name = "Living Zombie", Mob = "Living Zombie", Pos = Vector3.new(-9530, 141, 5810)},
    [1200] = {Name = "Demonic Soul", Mob = "Demonic Soul", Pos = Vector3.new(-9520, 141, 5875)},
    [1325] = {Name = "Posessed Mummy", Mob = "Posessed Mummy", Pos = Vector3.new(-9550, 141, 5825)},
    [1500] = {Name = "Drowned Cook", Mob = "Drowned Cook", Pos = Vector3.new(-9500, 141, 5800)},
}

local function getBestQuest()
    local level = 1
    local data = LocalPlayer:FindFirstChild("Data")
    if data and data:FindFirstChild("Level") then
        level = data.Level.Value
    end
    local best = nil
    for req, quest in pairs(Quests) do
        if level >= req then
            if not best or req > (best.Req or 0) then
                best = quest
                best.Req = req
            end
        end
    end
    return best
end

local function getClosestMob(targetName)
    local closest, closestDist = nil, math.huge
    local enemies = Workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    for _, mob in pairs(enemies:GetChildren()) do
        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
            if not targetName or mob.Name == targetName then
                local mobRoot = mob:FindFirstChild("HumanoidRootPart")
                if mobRoot and RootPart then
                    local dist = (RootPart.Position - mobRoot.Position).Magnitude
                    if dist < closestDist then
                        closest = mob
                        closestDist = dist
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
        mob.HumanoidRootPart.CFrame = RootPart.CFrame * CFrame.new(0, 0, -8)
        mob.HumanoidRootPart.CanCollide = false
        mob.HumanoidRootPart.Size = Vector3.new(40, 40, 40)
        if mob:FindFirstChild("Humanoid") then
            sethiddenproperty(mob.Humanoid, "WalkSpeed", 0)
            sethiddenproperty(mob.Humanoid, "JumpPower", 0)
        end
    end)
end

local function attackMob(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    pcall(function()
        local args = {
            [1] = mob.HumanoidRootPart.Position,
            [2] = CFrame.new(RootPart.Position),
        }
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local combat = remotes:FindFirstChild("Combat")
            if combat and (Config.AttackMethod == "M1" or Config.AttackMethod == "Both") then
                combat:FireServer(unpack(args))
            end
            local sword = remotes:FindFirstChild("Sword")
            if sword and Character:FindFirstChildOfClass("Tool") and (Config.AttackMethod == "Skill" or Config.AttackMethod == "Both") then
                sword:FireServer(unpack(args))
            end
        end
    end)
end

local function takeQuest(quest)
    if not quest then return end
    local comm = getCommF()
    if not comm then return end
    pcall(function()
        tweenTo(quest.Pos, Config.TweenSpeed)
        task.wait(0.3)
        comm:InvokeServer("StartQuest", quest.Name, 1)
    end)
end

-- Server Hop
local function hopServer()
    notify("Server Hop", "Searching for a new server...", 3, "warning")
    local placeId = game.PlaceId
    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local success, response = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(url))
    end)
    
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
            notify("Server Hop", "No suitable servers found, retrying...", 2, "warning")
            task.wait(2)
            hopServer()
        end
    end
end

-- ============================================================
-- BUILD PAGES
-- ============================================================

-- ====================== HOME TAB ======================
local HomeTab = createTab("Home", "⌂")
HomeTab:Section("Player Information")
HomeTab:Label("Username: " .. LocalPlayer.Name)
HomeTab:Label("Display Name: " .. LocalPlayer.DisplayName)
HomeTab:Label("Level: " .. (LocalPlayer.Data and LocalPlayer.Data.Level.Value or "Unknown"))
HomeTab:Label("Beli: " .. (LocalPlayer.Data and LocalPlayer.Data.Beli.Value or "Unknown"))
HomeTab:Label("Fragments: " .. (LocalPlayer.Data and LocalPlayer.Data.Fragments.Value or "Unknown"))
HomeTab:Section("Quick Actions")
HomeTab:Button("Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
HomeTab:Button("Copy Server ID", function()
    if setclipboard then
        setclipboard(game.JobId)
        notify("Copied", "Server ID copied to clipboard", 2, "success")
    end
end)
HomeTab:Button("Server Hop", function()
    hopServer()
end)
HomeTab:Section("About")
HomeTab:Label("Ebanat Hub v1.0.0")
HomeTab:Label("Built by ENI")
HomeTab:Label("Press RightShift to toggle UI")

-- ====================== AUTO FARM TAB ======================
local FarmTab = createTab("Auto Farm", "⚔")
FarmTab:Section("Combat")
FarmTab:Toggle("Auto Farm", "Automatically farms nearest mobs for XP", false, function(state)
    Config.AutoFarm = state
    notify("Auto Farm", state and "Enabled" or "Disabled", 2, state and "success" or "warning")
end)
FarmTab:Toggle("Auto Quest", "Automatically accepts best quest for your level", false, function(state)
    Config.AutoQuest = state
end)
FarmTab:Toggle("Fast Attack", "Uses fast attack method for faster kills", true, function(state)
    Config.FastAttack = state
end)
FarmTab:Toggle("Bring Mobs", "Teleports mobs to you for faster farming", true, function(state)
    Config.BringMobs = state
end)
FarmTab:Dropdown("Attack Method", {"M1", "Skill", "Both"}, "Both", function(opt)
    Config.AttackMethod = opt
end)
FarmTab:Section("Movement")
FarmTab:Slider("Tween Speed", 50, 500, 200, " studs/s", function(val)
    Config.TweenSpeed = val
end)
FarmTab:Section("Manual Actions")
FarmTab:Button("Farm Nearest Mob", function()
    local mob = getClosestMob()
    if mob then
        bringMob(mob)
        attackMob(mob)
        notify("Farm", "Attacking " .. mob.Name, 2)
    else
        notify("Farm", "No mobs found nearby", 2, "warning")
    end
end)
FarmTab:Button("Take Best Quest", function()
    local quest = getBestQuest()
    if quest then
        takeQuest(quest)
        notify("Quest", "Taking quest: " .. quest.Name, 2)
    end
end)

-- Auto Farm loop
RunService.Heartbeat:Connect(function()
    if not Config.AutoFarm then return end
    pcall(function()
        if not RootPart then refreshCharacter() return end
        local quest = getBestQuest()
        if not quest then return end
        
        if Config.AutoQuest then
            local questGui = LocalPlayer.PlayerGui:FindFirstChild("Quest")
            if not questGui or not questGui.Enabled then
                takeQuest(quest)
                task.wait(0.5)
            end
        end
        
        local mob = getClosestMob(quest.Mob)
        if mob then
            if Config.BringMobs then bringMob(mob) end
            attackMob(mob)
        end
    end)
end)

-- ====================== CHESTS / MONEY TAB ======================
local ChestTab = createTab("Chests", "$")
ChestTab:Section("Auto Chest Farm")
ChestTab:Toggle("Auto Collect Chests", "Teleports to and collects all chests", false, function(state)
    Config.AutoChests = state
    notify("Chest Farm", state and "Enabled" or "Disabled", 2, state and "success" or "warning")
end)
ChestTab:Button("Collect All Chests Now", function()
    notify("Chests", "Collecting chests...", 2)
end)

-- Chest loop
task.spawn(function()
    while task.wait(0.5) do
        if not Config.AutoChests then continue end
        pcall(function()
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj.Name:lower():match("chest") then
                    local part = obj:FindFirstChildWhichIsA("BasePart") or (obj:IsA("BasePart") and obj)
                    if part and RootPart then
                        tweenTo(part.Position, 300)
                        task.wait(0.3)
                        firetouchinterest(RootPart, part, 0)
                        firetouchinterest(RootPart, part, 1)
                    end
                end
            end
        end)
    end
end)

-- ====================== FRUITS TAB ======================
local FruitsTab = createTab("Fruits", "🍎")
FruitsTab:Section("Fruit Collection")
FruitsTab:Toggle("Auto Farm Fruits", "Collects spawned devil fruits", false, function(state)
    Config.AutoFruits = state
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
    "Dragon", "Kitsune", "Leopard", "Dough", "Venom", 
    "Shadow", "Control", "Gravity", "Dragon", "Buddha",
    "Phoenix", "Rumble", "Paw", "Revive", "Sand",
    "Dark", "Ice", "Light", "Magma", "Rubber", "Diamond",
    "String", "Bird: Phoenix", "Bird: Falcon", "Portal",
    "Sound", "Spider", "Blizzard", "Yeti", "T-Rex", "Velociraptor"
}, "Dragon", function(opt)
    Config.SelectedFruit = opt
end)
FruitsTab:Button("Buy Random Fruit", function()
    local comm = getCommF()
    if comm then
        comm:InvokeServer("GetRandomFruit")
        notify("Shop", "Purchased random fruit", 2, "success")
    end
end)
FruitsTab:Button("Store Current Fruit", function()
    local comm = getCommF()
    if comm then
        comm:InvokeServer("StoreFruit")
        notify("Storage", "Fruit stored", 2, "success")
    end
end)

-- Fruit farm loop
task.spawn(function()
    while task.wait(0.5) do
        if not Config.AutoFruits then continue end
        pcall(function()
            if not RootPart then refreshCharacter() continue end
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and obj.Name:lower():match("fruit") then
                    local part = obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        local dist = (RootPart.Position - part.Position).Magnitude
                        if dist < 2000 then
                            tweenTo(part.Position, 250)
                            task.wait(0.3)
                            firetouchinterest(RootPart, part, 0)
                            firetouchinterest(RootPart, part, 1)
                            if Config.AutoStoreFruits then
                                local comm = getCommF()
                                if comm then comm:InvokeServer("StoreFruit") end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ====================== STATS TAB ======================
local StatsTab = createTab("Stats", "📊")
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
        comm:InvokeServer("AddPoint", "Melee", math.floor(points * Config.MeleePts / total))
        comm:InvokeServer("AddPoint", "Defense", math.floor(points * Config.DefensePts / total))
        comm:InvokeServer("AddPoint", "Sword", math.floor(points * Config.SwordPts / total))
        comm:InvokeServer("AddPoint", "Gun", math.floor(points * Config.GunPts / total))
        comm:InvokeServer("AddPoint", "Demon Fruit", math.floor(points * Config.FruitPts / total))
        notify("Stats", "Points distributed!", 2, "success")
    else
        notify("Stats", "No points available", 2, "warning")
    end
end)

-- Stats loop
task.spawn(function()
    while task.wait(2) do
        if not Config.AutoStats then continue end
        pcall(function()
            local comm = getCommF()
            if not comm then continue end
            local data = LocalPlayer:FindFirstChild("Data")
            if not data or not data:FindFirstChild("Points") then continue end
            local points = data.Points.Value
            if points > 0 then
                local total = Config.MeleePts + Config.DefensePts + Config.SwordPts + Config.GunPts + Config.FruitPts
                if total == 0 then total = 100 end
                comm:InvokeServer("AddPoint", "Melee", math.floor(points * Config.MeleePts / total))
                comm:InvokeServer("AddPoint", "Defense", math.floor(points * Config.DefensePts / total))
                comm:InvokeServer("AddPoint", "Sword", math.floor(points * Config.SwordPts / total))
                comm:InvokeServer("AddPoint", "Gun", math.floor(points * Config.GunPts / total))
                comm:InvokeServer("AddPoint", "Demon Fruit", math.floor(points * Config.FruitPts / total))
            end
        end)
    end
end)

-- ====================== SERVER HOP TAB ======================
local HopTab = createTab("Server Hop", "↻")
HopTab:Section("Auto Server Hop")
HopTab:Toggle("Auto Hop", "Hops servers when no mobs or low population", false, function(state)
    Config.AutoHop = state
    notify("Auto Hop", state and "Enabled" or "Disabled", 2, state and "success" or "warning")
    if state then
        task.spawn(function()
            while Config.AutoHop do
                task.wait(10)
                local playerCount = #Players:GetPlayers()
                if playerCount <= Config.HopMinPlayers then
                    hopServer()
                    break
                end
                local mobFound = false
                local enemies = Workspace:FindFirstChild("Enemies")
                if enemies then
                    for _, mob in pairs(enemies:GetChildren()) do
                        if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                            mobFound = true
                            break
                        end
                    end
                end
                if not mobFound then
                    task.wait(15)
                    mobFound = false
                    if enemies then
                        for _, mob in pairs(enemies:GetChildren()) do
                            if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                                mobFound = true
                                break
                            end
                        end
                    end
                    if not mobFound then
                        hopServer()
                        break
                    end
                end
            end
        end)
    end
end)
HopTab:Slider("Min Players", 1, 30, 5, "", function(val)
    Config.HopMinPlayers = val
end)
HopTab:Button("Hop Now", function()
    hopServer()
end)

-- ====================== TELEPORT TAB ======================
local TeleportTab = createTab("Teleport", "📍")
TeleportTab:Section("Islands")
local islands = {
    {"First Sea", Vector3.new(1059, 16, 1548)},
    {"Monkey Island", Vector3.new(-1591, 37, 167)},
    {"Buggy Island", Vector3.new(-1139, 13, 4049)},
    {"Desert", Vector3.new(974, 6, 4556)},
    {"Snow Island", Vector3.new(1366, 7, -477)},
    {"Marineford", Vector3.new(-4800, 22, 4314)},
    {"Sky Island", Vector3.new(-4864, 724, -2609)},
    {"Prison", Vector3.new(5310, 1, 4740)},
    {"Underwater City", Vector3.new(-4570, 272, -2580)},
    {"Fishman Island", Vector3.new(-2586, 8, -3343)},
    {"Colosseum", Vector3.new(-1166, 73, -4346)},
    {"Magma Village", Vector3.new(-5414, 88, -2790)},
    {"Great Tree", Vector3.new(-2270, 16, 5215)},
    {"Floating Turtle", Vector3.new(-13425, 367, -9450)},
    {"Haunted Castle", Vector3.new(-9510, 141, 5845)},
    {"Sea of Treats", Vector3.new(-9500, 141, 5800)},
}
for _, island in pairs(islands) do
    TeleportTab:Button(island[1], function()
        if RootPart then
            tweenTo(island[2], 300)
            notify("Teleport", "Teleported to " .. island[1], 2, "success")
        end
    end)
end

-- ====================== PLAYERS TAB ======================
local PlayersTab = createTab("Players", "👥")
PlayersTab:Section("Player Utilities")
PlayersTab:Toggle("Kill Aura", "Attacks all nearby mobs automatically", false, function(state)
    Config.KillAura = state
    notify("Kill Aura", state and "Enabled" or "Disabled", 2, state and "success" or "warning")
end)
PlayersTab:Slider("Aura Range", 10, 200, 50, " studs", function(val)
    Config.AuraRange = val
end)
PlayersTab:Section("Player List")
PlayersTab:Button("Teleport to Random Player", function()
    local players = Players:GetPlayers()
    if #players > 1 then
        local target = players[math.random(1, #players)]
        while target == LocalPlayer and #players > 1 do
            target = players[math.random(1, #players)]
        end
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and RootPart then
            RootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            notify("Teleport", "Teleported to " .. target.Name, 2, "success")
        end
    end
end)
PlayersTab:Button("Follow Nearest Player", function()
    notify("Follow", "Following nearest player...", 2)
end)

-- Kill Aura loop
RunService.Heartbeat:Connect(function()
    if not Config.KillAura then return end
    pcall(function()
        if not RootPart then return end
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
end)

-- ====================== SETTINGS TAB ======================
local SettingsTab = createTab("Settings", "⚙")
SettingsTab:Section("Interface")
SettingsTab:Dropdown("UI Theme", {"Purple", "Blue", "Red", "Green", "Pink", "Orange", "Cyan"}, "Purple", function(opt)
    Config.SelectedTheme = opt
    local preset = ThemePresets[opt]
    if preset then
        Theme.Accent = preset.Accent
        Theme.AccentLight = preset.AccentLight
        Theme.AccentDark = preset.AccentDark
        Theme.AccentGradient = preset.AccentGradient
        Theme.ToggleOn = preset.Accent
        Theme.SliderFill = preset.Accent
        -- Update existing elements
        gradient(Logo, Theme.AccentLight, Theme.AccentDark, 135)
        stroke(Window, Theme.AccentDark, 1, 0.3)
        stroke(VersionBadge, Theme.AccentDark, 1, 0.3)
        notify("Theme", "Changed to " .. opt, 2, "success")
    end
end)
SettingsTab:Slider("UI Scale", 50, 150, 100, "%", function(val)
    Config.UIScale = val / 100
    TweenService:Create(UIScale, TweenInfo.new(0.2), {Scale = Config.UIScale}):Play()
end)
SettingsTab:Section("System")
SettingsTab:Toggle("Anti-AFK", "Prevents being kicked for inactivity", true, function(state)
    Config.AntiAFK = state
end)
SettingsTab:Button("Reset Window Position", function()
    TweenService:Create(Window, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, -320, 0.5, -210),
    }):Play()
    notify("Settings", "Position reset", 2)
end)
SettingsTab:Button("Destroy UI", function()
    ScreenGui:Destroy()
end)
SettingsTab:Section("Keybinds")
SettingsTab:Keybind("Toggle UI", Enum.KeyCode.RightShift, function()
    Window.Visible = not Window.Visible
end)

-- ============================================================
-- ANTI-AFK
-- ============================================================
LocalPlayer.Idled:Connect(function()
    if Config.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ============================================================
-- KEYBIND: RightShift to toggle
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        Window.Visible = not Window.Visible
    end
end)

-- ============================================================
-- INIT
-- ============================================================
task.wait(0.3)
notify("Ebanat Hub", "Welcome, " .. LocalPlayer.Name .. "!", 4, "success")
task.wait(1)
notify("Loaded", "All systems operational", 3, "success")

-- ============================================================
-- EXPORT
-- ============================================================
_G.EbanatHub = {
    Notify = notify,
    Config = Config,
    Theme = Theme,
    GUI = ScreenGui,
}
