--[[
    DELTA SUITE — GUI LIBRARY v2.0
    Полностью кастомное меню с анимациями
    Совместимость: Delta, все executors с поддержкой Drawing/CoreGui
]]

-- ====== СЕРВИСЫ ======
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ====== ТЕМА ======
local Theme = {
    Background = Color3.fromRGB(18, 18, 24),
    BackgroundLight = Color3.fromRGB(28, 28, 36),
    Sidebar = Color3.fromRGB(22, 22, 30),
    Accent = Color3.fromRGB(124, 92, 255),
    AccentLight = Color3.fromRGB(156, 124, 255),
    AccentDark = Color3.fromRGB(88, 64, 180),
    Text = Color3.fromRGB(240, 240, 250),
    TextDim = Color3.fromRGB(140, 140, 160),
    TextDark = Color3.fromRGB(90, 90, 110),
    ToggleOff = Color3.fromRGB(45, 45, 55),
    ToggleOn = Color3.fromRGB(124, 92, 255),
    ToggleKnob = Color3.fromRGB(255, 255, 255),
    SliderTrack = Color3.fromRGB(40, 40, 50),
    SliderFill = Color3.fromRGB(124, 92, 255),
    Divider = Color3.fromRGB(40, 40, 50),
    Hover = Color3.fromRGB(35, 35, 45),
    Success = Color3.fromRGB(80, 220, 120),
    Danger = Color3.fromRGB(240, 80, 90),
    Notification = Color3.fromRGB(30, 30, 40),
    Corner = 6,
}

-- ====== УТИЛИТЫ ======
local function create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function round(parent, radius)
    local corner = create("UICorner", {
        CornerRadius = UDim.new(0, radius or Theme.Corner),
        Parent = parent,
    })
    return corner
end

local function stroke(parent, color, thickness)
    return create("UIStroke", {
        Color = color or Theme.Divider,
        Thickness = thickness or 1,
        Parent = parent,
    })
end

local function gradient(parent, color1, color2, rotation)
    return create("UIGradient", {
        Color = ColorSequence.new(color1, color2),
        Rotation = rotation or 90,
        Parent = parent,
    })
end

local function padding(parent, top, bottom, left, right)
    return create("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft = UDim.new(0, left or 0),
        PaddingRight = UDim.new(0, right or 0),
        Parent = parent,
    })
end

local function ripple(button)
    local ripple = create("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = button,
        ZIndex = 100,
    })
    round(ripple, 100)
    
    local tween = TweenService:Create(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 300, 0, 300),
        BackgroundTransparency = 1,
    })
    tween:Play()
    tween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- ====== ОСНОВНОЙ GUI ======
local ScreenGui = create("ScreenGui", {
    Name = "DeltaSuite_" .. tostring(math.random(1000, 9999)),
    Parent = game.CoreGui,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})

-- Dragging
local dragging = false
local dragStart = nil
local startPos = nil

-- Main Window
local MainWindow = create("Frame", {
    Name = "MainWindow",
    Size = UDim2.new(0, 580, 0, 400),
    Position = UDim2.new(0.5, -290, 0.5, -200),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    Parent = ScreenGui,
    Active = true,
    Draggable = false,
})
round(MainWindow, 10)
stroke(MainWindow, Theme.AccentDark, 1)

-- Shadow
local Shadow = create("ImageLabel", {
    Name = "Shadow",
    Size = UDim2.new(1, 30, 1, 30),
    Position = UDim2.new(0, -15, 0, -15),
    BackgroundTransparency = 1,
    Image = "rbxassetid://1316045217",
    ImageColor3 = Color3.fromRGB(0, 0, 0),
    ImageTransparency = 0.5,
    ScaleType = Enum.ScaleType.Slice,
    SliceCenter = Rect.new(10, 10, 118, 118),
    ZIndex = 0,
    Parent = MainWindow,
})

-- Title Bar
local TitleBar = create("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 38),
    BackgroundColor3 = Theme.BackgroundLight,
    BorderSizePixel = 0,
    Parent = MainWindow,
})
round(TitleBar, 10)

-- Fix bottom corners
create("Frame", {
    Size = UDim2.new(1, 0, 0, 10),
    Position = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = Theme.BackgroundLight,
    BorderSizePixel = 0,
    Parent = TitleBar,
})

-- Logo / Title
local LogoFrame = create("Frame", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(0, 10, 0.5, -14),
    BackgroundColor3 = Theme.Accent,
    BorderSizePixel = 0,
    Parent = TitleBar,
})
round(LogoFrame, 6)
gradient(LogoFrame, Theme.AccentLight, Theme.Accent, 135)

local LogoText = create("TextLabel", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "Δ",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    Parent = LogoFrame,
})

local TitleText = create("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 46, 0, 0),
    BackgroundTransparency = 1,
    Text = "Delta Suite",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TitleBar,
})

local SubtitleText = create("TextLabel", {
    Size = UDim2.new(0, 200, 1, 0),
    Position = UDim2.new(0, 46, 0, 0),
    BackgroundTransparency = 1,
    Text = "Blox Fruits",
    TextColor3 = Theme.TextDark,
    Font = Enum.Font.Gotham,
    TextSize = 11,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Bottom,
    Parent = TitleBar,
})
padding(SubtitleText, 0, 2, 0, 0)

-- Close Button
local CloseBtn = create("TextButton", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -36, 0.5, -14),
    BackgroundColor3 = Theme.Danger,
    BorderSizePixel = 0,
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    TextSize = 18,
    Parent = TitleBar,
})
round(CloseBtn, 6)

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 100, 110)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Danger}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    ripple(CloseBtn)
    TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    }):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
end)

-- Minimize Button
local MinimizeBtn = create("TextButton", {
    Size = UDim2.new(0, 28, 0, 28),
    Position = UDim2.new(1, -70, 0.5, -14),
    BackgroundColor3 = Theme.ToggleOff,
    BorderSizePixel = 0,
    Text = "—",
    TextColor3 = Theme.Text,
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    Parent = TitleBar,
})
round(MinimizeBtn, 6)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    ripple(MinimizeBtn)
    minimized = not minimized
    if minimized then
        TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 580, 0, 38),
        }):Play()
    else
        TweenService:Create(MainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 580, 0, 400),
        }):Play()
    end
end)

-- Drag Logic
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainWindow.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainWindow.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ====== LAYOUT ======
-- Sidebar
local Sidebar = create("Frame", {
    Name = "Sidebar",
    Size = UDim2.new(0, 150, 1, -38),
    Position = UDim2.new(0, 0, 0, 38),
    BackgroundColor3 = Theme.Sidebar,
    BorderSizePixel = 0,
    Parent = MainWindow,
})
round(Sidebar, 0)

create("Frame", {
    Size = UDim2.new(0, 1, 1, 0),
    Position = UDim2.new(1, -1, 0, 0),
    BackgroundColor3 = Theme.Divider,
    BorderSizePixel = 0,
    Parent = Sidebar,
})

local SidebarScroll = create("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Theme.Accent,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    Parent = Sidebar,
})
padding(SidebarScroll, 8, 8, 8, 8)

local SidebarLayout = create("UIListLayout", {
    Padding = UDim.new(0, 4),
    SortOrder = Enum.SortOrder.LayoutOrder,
    Parent = SidebarScroll,
})

-- Content Area
local ContentArea = create("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -150, 1, -38),
    Position = UDim2.new(0, 150, 0, 38),
    BackgroundColor3 = Theme.Background,
    BorderSizePixel = 0,
    Parent = MainWindow,
})

local ContentPages = {}
local SidebarButtons = {}
local currentPage = nil

-- ====== ФУНКЦИИ СОЗДАНИЯ ЭЛЕМЕНТОВ ======

local function switchPage(pageName)
    for name, page in pairs(ContentPages) do
        if name == pageName then
            page.Visible = true
            TweenService:Create(page, TweenInfo.new(0.2), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        else
            page.Visible = false
        end
    end
    
    for name, btn in pairs(SidebarButtons) do
        if name == pageName then
            TweenService:Create(btn.Indicator, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0, 20)}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Hover}):Play()
            TweenService:Create(btn.Label, TweenInfo.new(0.2), {TextColor3 = Theme.Text}):Play()
            TweenService:Create(btn.Icon, TweenInfo.new(0.2), {TextColor3 = Theme.AccentLight}):Play()
        else
            TweenService:Create(btn.Indicator, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0, 0)}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Sidebar}):Play()
            TweenService:Create(btn.Label, TweenInfo.new(0.2), {TextColor3 = Theme.TextDim}):Play()
            TweenService:Create(btn.Icon, TweenInfo.new(0.2), {TextColor3 = Theme.TextDark}):Play()
        end
    end
    currentPage = pageName
end

local icons = {
    Farm = "⚔",
    Money = "$",
    Fruits = "🍎",
    Stats = "📊",
    Hop = "↻",
    Settings = "⚙",
    Players = "👥",
    Combat = "🗡",
    Teleport = "📍",
    Shop = "🛒",
}

-- ====== СОЗДАНИЕ СТРАНИЦ ======
local PageOrder = 0

local function createPage(name, icon)
    local page = create("ScrollingFrame", {
        Name = name,
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
    padding(page, 12, 12, 12, 12)
    
    local pageLayout = create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = page,
    })
    
    ContentPages[name] = page
    
    -- Sidebar button
    local sidebarBtn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = SidebarScroll,
        LayoutOrder = PageOrder,
    })
    round(sidebarBtn, 6)
    
    local indicator = create("Frame", {
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 4, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = sidebarBtn,
    })
    round(indicator, 2)
    
    local iconLabel = create("TextLabel", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 12, 0.5, -12),
        BackgroundTransparency = 1,
        Text = icon or icons[name] or "○",
        TextColor3 = Theme.TextDark,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = sidebarBtn,
    })
    
    local label = create("TextLabel", {
        Size = UDim2.new(1, -48, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sidebarBtn,
    })
    
    sidebarBtn.MouseEnter:Connect(function()
        if currentPage ~= name then
            TweenService:Create(sidebarBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Hover}):Play()
            TweenService:Create(label, TweenInfo.new(0.15), {TextColor3 = Theme.Text}):Play()
        end
    end)
    sidebarBtn.MouseLeave:Connect(function()
        if currentPage ~= name then
            TweenService:Create(sidebarBtn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Sidebar}):Play()
            TweenService:Create(label, TweenInfo.new(0.15), {TextColor3 = Theme.TextDim}):Play()
        end
    end)
    sidebarBtn.MouseButton1Click:Connect(function()
        ripple(sidebarBtn)
        switchPage(name)
    end)
    
    sidebarBtn.Indicator = indicator
    sidebarBtn.Icon = iconLabel
    sidebarBtn.Label = label
    SidebarButtons[name] = sidebarBtn
    
    PageOrder = PageOrder + 1
    
    -- Page API
    local pageAPI = {}
    
    -- Section
    function pageAPI:Section(title)
        local section = create("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundTransparency = 1,
            Parent = page,
        })
        
        local sectionLabel = create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = title or "Section",
            TextColor3 = Theme.TextDark,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = section,
        })
        
        return self
    end
    
    -- Toggle
    function pageAPI:Toggle(text, default, callback)
        local toggleFrame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Theme.BackgroundLight,
            BorderSizePixel = 0,
            Parent = page,
        })
        round(toggleFrame, 6)
        stroke(toggleFrame, Theme.Divider, 1)
        
        local label = create("TextLabel", {
            Size = UDim2.new(1, -70, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = toggleFrame,
        })
        
        local toggleBg = create("Frame", {
            Size = UDim2.new(0, 44, 0, 22),
            Position = UDim2.new(1, -56, 0.5, -11),
            BackgroundColor3 = Theme.ToggleOff,
            BorderSizePixel = 0,
            Parent = toggleFrame,
        })
        round(toggleBg, 11)
        
        local toggleKnob = create("Frame", {
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 3, 0.5, -8),
            BackgroundColor3 = Theme.ToggleKnob,
            BorderSizePixel = 0,
            Parent = toggleBg,
        })
        round(toggleKnob, 8)
        
        local state = default or false
        
        local function updateToggle()
            if state then
                TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ToggleOn}):Play()
                TweenService:Create(toggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(1, -19, 0.5, -8)}):Play()
            else
                TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ToggleOff}):Play()
                TweenService:Create(toggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -8)}):Play()
            end
        end
        
        local btn = create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = toggleFrame,
        })
        
        btn.MouseButton1Click:Connect(function()
            state = not state
            updateToggle()
            ripple(toggleBg)
            if callback then callback(state) end
        end)
        
        updateToggle()
        
        return {
            Set = function(val)
                state = val
                updateToggle()
                if callback then callback(state) end
            end,
            Get = function() return state end
        }
    end
    
    -- Button
    function pageAPI:Button(text, callback)
        local btnFrame = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.BackgroundLight,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            Parent = page,
        })
        round(btnFrame, 6)
        stroke(btnFrame, Theme.AccentDark, 1)
        
        local btnLabel = create("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamMedium,
            TextSize = 13,
            Parent = btnFrame,
        })
        
        btnFrame.MouseEnter:Connect(function()
            TweenService:Create(btnFrame, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Hover}):Play()
            TweenService:Create(btnLabel, TweenInfo.new(0.15), {TextColor3 = Theme.AccentLight}):Play()
        end)
        btnFrame.MouseLeave:Connect(function()
            TweenService:Create(btnFrame, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BackgroundLight}):Play()
            TweenService:Create(btnLabel, TweenInfo.new(0.15), {TextColor3 = Theme.Text}):Play()
        end)
        btnFrame.MouseButton1Click:Connect(function()
            ripple(btnFrame)
            if callback then callback() end
        end)
        
        return btnFrame
    end
    
    -- Slider
    function pageAPI:Slider(text, min, max, default, callback)
        local sliderFrame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 52),
            BackgroundColor3 = Theme.BackgroundLight,
            BorderSizePixel = 0,
            Parent = page,
        })
        round(sliderFrame, 6)
        stroke(sliderFrame, Theme.Divider, 1)
        padding(sliderFrame, 8, 8, 14, 14)
        
        local sliderLabel = create("TextLabel", {
            Size = UDim2.new(1, -50, 0, 16),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = sliderFrame,
        })
        
        local valueLabel = create("TextLabel", {
            Size = UDim2.new(0, 50, 0, 16),
            Position = UDim2.new(1, -50, 0, 0),
            BackgroundTransparency = 1,
            Text = tostring(default or min),
            TextColor3 = Theme.AccentLight,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = sliderFrame,
        })
        
        local track = create("Frame", {
            Size = UDim2.new(1, 0, 0, 6),
            Position = UDim2.new(0, 0, 0, 26),
            BackgroundColor3 = Theme.SliderTrack,
            BorderSizePixel = 0,
            Parent = sliderFrame,
        })
        round(track, 3)
        
        local fill = create("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = Theme.SliderFill,
            BorderSizePixel = 0,
            Parent = track,
        })
        round(fill, 3)
        
        local knob = create("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(0, 0, 0.5, -7),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Parent = track,
        })
        round(knob, 7)
        stroke(knob, Theme.Accent, 2)
        
        local value = default or min
        local dragging = false
        
        local function update(val)
            value = math.clamp(val, min, max)
            local percent = (value - min) / (max - min)
            TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.1), {Position = UDim2.new(percent, -7, 0.5, -7)}):Play()
            valueLabel.Text = tostring(math.floor(value))
            if callback then callback(value) end
        end
        
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local percent = (Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                update(min + (max - min) * percent)
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                update(min + (max - min) * percent)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        update(default or min)
        
        return { Set = update, Get = function() return value end }
    end
    
    -- Dropdown
    function pageAPI:Dropdown(text, options, default, callback)
        local ddFrame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.BackgroundLight,
            BorderSizePixel = 0,
            Parent = page,
        })
        round(ddFrame, 6)
        stroke(ddFrame, Theme.Divider, 1)
        
        local ddLabel = create("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = text .. ": " .. (default or options[1] or ""),
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = ddFrame,
        })
        
        local arrow = create("TextLabel", {
            Size = UDim2.new(0, 24, 1, 0),
            Position = UDim2.new(1, -28, 0, 0),
            BackgroundTransparency = 1,
            Text = "▼",
            TextColor3 = Theme.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 10,
            Parent = ddFrame,
        })
        
        local expanded = false
        local selected = default or options[1]
        
        local btn = create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            Parent = ddFrame,
        })
        
        local dropdownList = create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 2),
            BackgroundColor3 = Theme.BackgroundLight,
            BorderSizePixel = 0,
            Visible = false,
            Parent = ddFrame,
            ZIndex = 10,
        })
        round(dropdownList, 6)
        stroke(dropdownList, Theme.AccentDark, 1)
        
        local listLayout = create("UIListLayout", {
            Padding = UDim.new(0, 2),
            Parent = dropdownList,
        })
        padding(dropdownList, 4, 4, 4, 4)
        
        local function buildList()
            for _, child in pairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            for _, opt in pairs(options) do
                local optBtn = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = dropdownList,
                    ZIndex = 11,
                })
                round(optBtn, 4)
                
                local optLabel = create("TextLabel", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = opt,
                    TextColor3 = opt == selected and Theme.AccentLight or Theme.TextDim,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = optBtn,
                    ZIndex = 12,
                })
                padding(optLabel, 0, 0, 10, 10)
                
                optBtn.MouseEnter:Connect(function()
                    TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Hover}):Play()
                end)
                optBtn.MouseLeave:Connect(function()
                    TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Background}):Play()
                end)
                optBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    ddLabel.Text = text .. ": " .. opt
                    if callback then callback(opt) end
                    
                    TweenService:Create(dropdownList, TweenInfo.new(0.15), {
                        Size = UDim2.new(1, 0, 0, 0),
                    }):Play()
                    TweenService:Create(arrow, TweenInfo.new(0.15), {Text = "▼"}):Play()
                    task.wait(0.15)
                    dropdownList.Visible = false
                    expanded = false
                end)
            end
        end
        
        btn.MouseButton1Click:Connect(function()
            expanded = not expanded
            if expanded then
                buildList()
                dropdownList.Visible = true
                local targetSize = #options * 30 + 8
                TweenService:Create(dropdownList, TweenInfo.new(0.2), {
                    Size = UDim2.new(1, 0, 0, targetSize),
                }):Play()
                TweenService:Create(arrow, TweenInfo.new(0.2), {Text = "▲"}):Play()
            else
                TweenService:Create(dropdownList, TweenInfo.new(0.15), {
                    Size = UDim2.new(1, 0, 0, 0),
                }):Play()
                TweenService:Create(arrow, TweenInfo.new(0.15), {Text = "▼"}):Play()
                task.wait(0.15)
                dropdownList.Visible = false
            end
        end)
        
        return { Set = function(val) selected = val; ddLabel.Text = text .. ": " .. val end, Get = function() return selected end }
    end
    
    -- Label
    function pageAPI:Label(text)
        local lbl = create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = page,
        })
        return { Set = function(val) lbl.Text = val end }
    end
    
    -- TextBox
    function pageAPI:TextBox(text, placeholder, callback)
        local tbFrame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.BackgroundLight,
            BorderSizePixel = 0,
            Parent = page,
        })
        round(tbFrame, 6)
        stroke(tbFrame, Theme.Divider, 1)
        padding(tbFrame, 0, 0, 14, 14)
        
        local tbLabel = create("TextLabel", {
            Size = UDim2.new(0, 80, 1, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = Theme.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tbFrame,
        })
        
        local input = create("TextBox", {
            Size = UDim2.new(1, -94, 1, 0),
            Position = UDim2.new(0, 80, 0, 0),
            BackgroundTransparency = 1,
            Text = "",
            PlaceholderText = placeholder or "Enter value...",
            PlaceholderColor3 = Theme.TextDark,
            TextColor3 = Theme.Text,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tbFrame,
        })
        
        input.FocusLost:Connect(function(enter)
            if enter and callback then callback(input.Text) end
        end)
        
        return { Get = function() return input.Text end, Set = function(val) input.Text = val end }
    end
    
    return pageAPI
end

-- ====== УВЕДОМЛЕНИЯ ======
local NotificationContainer = create("Frame", {
    Size = UDim2.new(0, 300, 1, -100),
    Position = UDim2.new(1, -310, 0, 50),
    BackgroundTransparency = 1,
    Parent = ScreenGui,
})
local notifLayout = create("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
    VerticalAlignment = Enum.VerticalAlignment.Bottom,
    Parent = NotificationContainer,
})

local function notify(title, message, duration)
    duration = duration or 3
    
    local notif = create("Frame", {
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Theme.Notification,
        BorderSizePixel = 0,
        Parent = NotificationContainer,
        ClipsDescendants = true,
    })
    round(notif, 6)
    stroke(notif, Theme.AccentDark, 1)
    
    local accentBar = create("Frame", {
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = notif,
    })
    
    local titleLabel = create("TextLabel", {
        Size = UDim2.new(1, -18, 0, 20),
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
        Size = UDim2.new(1, -18, 0, 16),
        Position = UDim2.new(0, 14, 0, 28),
        BackgroundTransparency = 1,
        Text = message,
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })
    
    -- Entrance animation
    notif.Size = UDim2.new(0, 0, 0, 60)
    notif.Position = UDim2.new(1, 0, 0, 0)
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, 60),
    }):Play()
    
    task.delay(duration, function()
        TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 60),
            BackgroundTransparency = 1,
        }):Play()
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- ====== СОЗДАНИЕ СТРАНИЦ ======

-- Auto Farm
local farmPage = createPage("Auto Farm", "⚔")
farmPage:Section("Основное")
local farmToggle = farmPage:Toggle("Auto Farm", false, function(state)
    notify("Auto Farm", state and "Включён" or "Выключен")
end)
local questToggle = farmPage:Toggle("Auto Quest", false, function(state)
    notify("Auto Quest", state and "Включён" or "Выключен")
end)
local fastToggle = farmPage:Toggle("Fast Attack", true, function() end)
farmPage:Toggle("Bring Mobs", true, function() end)
farmPage:Section("Настройки")
farmPage:Slider("Tween Speed", 50, 500, 200, function(val) end)
farmPage:Dropdown("Метод атаки", {"M1", "Skill", "Both"}, "Both", function(opt) end)
farmPage:Button("Фарм ближайшего моба", function()
    notify("Farm", "Ищу ближайшего моба...")
end)

-- Money
local moneyPage = createPage("Money", "$")
moneyPage:Section("Фарм денег")
moneyPage:Toggle("Auto Farm Money", false, function(state)
    notify("Money Farm", state and "Запущен" or "Остановлен")
end)
moneyPage:Toggle("Auto Collect Chests", false, function() end)
moneyPage:Button("Собрать все сундуки", function()
    notify("Chests", "Собираю сундуки...")
end)
moneyPage:Section("Цели")
moneyPage:Dropdown("Моб для фарма", {"Pirate Millionaire", "Pirate Billionaire", "Galley Captain", "Cocoa Warrior"}, "Pirate Millionaire", function(opt) end)

-- Fruits
local fruitsPage = createPage("Fruits", "🍎")
fruitsPage:Section("Сбор фруктов")
fruitsPage:Toggle("Auto Farm Fruits", false, function(state)
    notify("Fruits", state and "Сбор включён" or "Сбор выключен")
end)
fruitsPage:Toggle("Auto Store Fruits", false, function() end)
fruitsPage:Section("Покупка")
fruitsPage:Toggle("Auto Buy Fruit", false, function() end)
fruitsPage:Dropdown("Фрукт", {"Dragon", "Kitsune", "Leopard", "Dough", "Venom", "Shadow", "Control"}, "Dragon", function(opt) end)
fruitsPage:Button("Купить случайный фрукт", function()
    notify("Shop", "Покупаю случайный фрукт...")
end)

-- Stats
local statsPage = createPage("Stats", "📊")
statsPage:Section("Авто-распределение")
statsPage:Toggle("Auto Stats", false, function(state)
    notify("Stats", state and "Включён" or "Выключен")
end)
statsPage:Section("Распределение очков")
statsPage:Slider("Melee", 0, 100, 25, function(val) end)
statsPage:Slider("Defense", 0, 100, 25, function(val) end)
statsPage:Slider("Sword", 0, 100, 25, function(val) end)
statsPage:Slider("Gun", 0, 100, 0, function(val) end)
statsPage:Slider("Blox Fruit", 0, 100, 25, function(val) end)

-- Server Hop
local hopPage = createPage("Hop", "↻")
hopPage:Section("Сервер-хоп")
hopPage:Toggle("Auto Hop (No Mobs)", false, function(state)
    notify("Auto Hop", state and "Включён" or "Выключен")
end)
hopPage:Toggle("Auto Hop (Low Players)", false, function() end)
hopPage:Slider("Мин. игроков", 1, 20, 5, function(val) end)
hopPage:Button("Хопнуть сейчас", function()
    notify("Hop", "Ищу новый сервер...")
end)
hopPage:Label("Хопнуто серверов: 0")

-- Settings
local settingsPage = createPage("Settings", "⚙")
settingsPage:Section("Интерфейс")
settingsPage:Slider("Прозрачность окна", 0, 100, 0, function(val)
    MainWindow.BackgroundTransparency = val / 100
end)
settingsPage:Toggle("Показывать уведомления", true, function() end)
settingsPage:Dropdown("Тема акцента", {"Фиолетовый", "Синий", "Красный", "Зелёный", "Розовый"}, "Фиолетовый", function(opt)
    local themes = {
        ["Фиолетовый"] = Color3.fromRGB(124, 92, 255),
        ["Синий"] = Color3.fromRGB(80, 140, 255),
        ["Красный"] = Color3.fromRGB(255, 80, 90),
        ["Зелёный"] = Color3.fromRGB(80, 220, 120),
        ["Розовый"] = Color3.fromRGB(255, 100, 180),
    }
    Theme.Accent = themes[opt] or Theme.Accent
    Theme.AccentLight = Color3.fromRGB(
        math.min(255, Theme.Accent.R * 255 + 32),
        math.min(255, Theme.Accent.G * 255 + 32),
        math.min(255, Theme.Accent.B * 255 + 32)
    )
    notify("Тема", "Цвет изменён: " .. opt)
end)
settingsPage:Section("Прочее")
settingsPage:Button("Сбросить позицию", function()
    TweenService:Create(MainWindow, TweenInfo.new(0.3), {
        Position = UDim2.new(0.5, -290, 0.5, -200),
    }):Play()
end)
settingsPage:Button("Закрыть скрипт", function()
    ScreenGui:Destroy()
end)

-- ====== ИНИЦИАЛИЗАЦИЯ ======
switchPage("Auto Farm")

-- Welcome notification
task.wait(0.5)
notify("Delta Suite", "Добро пожаловать, " .. LocalPlayer.Name .. "!")
task.wait(1.5)
notify("Готово", "Все системы загружены ⚡")

-- Toggle GUI with RightShift
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainWindow.Visible = not MainWindow.Visible
    end
end)

-- ====== API EXPORT ======
_G.DeltaSuite = {
    Notify = notify,
    Theme = Theme,
    GUI = ScreenGui,
    Window = MainWindow,
}