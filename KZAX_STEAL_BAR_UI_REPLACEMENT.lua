-- KZAX STEAL BAR UI REPLACEMENT
-- UI-only module. Keeps the same public API:
--   _G.StealBar.SetProgress(number) -- 0 to 1
--   _G.StealBar.SetState("STEALING" / "READY" / "IDLE")
--   _G.StealBar.Reset()
--   _G.KryzenXSetStealBarVisible(boolean)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local oldGui = PlayerGui:FindFirstChild("StealBarGui")
if oldGui then
    oldGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StealBarGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local bar = Instance.new("Frame")
bar.Name = "StealBar"
bar.Size = UDim2.fromOffset(280, 34)
bar.Position = (function()\n    local saved = _G.KryzenXStealBarPosition\n    if type(saved) == "table" then\n        return UDim2.new(tonumber(saved.xs) or 0.5, tonumber(saved.xo) or -140, tonumber(saved.ys) or 1, tonumber(saved.yo) or -82)\n    end\n    return UDim2.new(0.5, -140, 1, -82)\nend)()
bar.BackgroundColor3 = Color3.fromRGB(218, 222, 228)
bar.BorderSizePixel = 0
bar.Active = true
bar.ClipsDescendants = true
bar.Parent = screenGui

local barCorner = Instance.new("UICorner")
barCorner.CornerRadius = UDim.new(0, 9)
barCorner.Parent = bar

local barStroke = Instance.new("UIStroke")
barStroke.Color = Color3.fromRGB(255, 255, 255)
barStroke.Thickness = 1.4
barStroke.Transparency = 0.05
barStroke.Parent = bar

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 247, 250)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(177, 184, 194))
})
gradient.Rotation = 90
gradient.Parent = bar

local function makeLabel(name, text, size, position, fontSize, alignment, color)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = position
    label.Font = Enum.Font.GothamBold
    label.Text = text
    label.TextSize = fontSize
    label.TextColor3 = color or Color3.fromRGB(35, 39, 45)
    label.TextXAlignment = alignment or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = bar
    return label
end

local title = makeLabel(
    "StealTitle", "STEAL",
    UDim2.fromOffset(54, 15), UDim2.fromOffset(9, 2),
    10, Enum.TextXAlignment.Left
)

local percent = makeLabel(
    "StealPercent", "0%",
    UDim2.fromOffset(42, 15), UDim2.new(1, -51, 0, 2),
    10, Enum.TextXAlignment.Right
)

local statsLabel = makeLabel(
    "PerformanceStats", "FPS: --  |  PING: --ms",
    UDim2.new(1, -18, 0, 10), UDim2.fromOffset(9, 14),
    7, Enum.TextXAlignment.Center, Color3.fromRGB(67, 72, 80)
)

local track = Instance.new("Frame")
track.Name = "Track"
track.Size = UDim2.new(1, -18, 0, 5)
track.Position = UDim2.new(0, 9, 1, -8)
track.BackgroundColor3 = Color3.fromRGB(137, 144, 154)
track.BorderSizePixel = 0
track.ClipsDescendants = true
track.Parent = bar

local trackCorner = Instance.new("UICorner")
trackCorner.CornerRadius = UDim.new(1, 0)
trackCorner.Parent = track

local fill = Instance.new("Frame")
fill.Name = "Fill"
fill.Size = UDim2.new(0, 0, 1, 0)
fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fill.BorderSizePixel = 0
fill.Parent = track

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = fill

local fillGradient = Instance.new("UIGradient")
fillGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(225, 230, 237))
})
fillGradient.Parent = fill

-- Drag support; save position in the same global used by the main GUI.
local dragging = false
local dragInput, dragStart, startPosition

bar.InputBegan:Connect(function(input)
    if _G.KryzenXGuiLocked == true then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = bar.Position
        dragInput = input

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                local p = bar.Position
                _G.KryzenXStealBarPosition = {
                    xs = p.X.Scale, xo = p.X.Offset,
                    ys = p.Y.Scale, yo = p.Y.Offset
                }
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        bar.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
    end
end)

local StealBar = {}

function StealBar.SetProgress(value)
    local progress = math.clamp(tonumber(value) or 0, 0, 1)
    percent.Text = string.format("%d%%", math.floor(progress * 100 + 0.5))
    TweenService:Create(
        fill,
        TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Size = UDim2.new(progress, 0, 1, 0) }
    ):Play()
end

function StealBar.SetState(state)
    state = tostring(state or "IDLE"):upper()
    local active = state == "STEALING"
    title.Text = active and "STEALING" or "STEAL"
    barStroke.Thickness = active and 1.8 or 1.2
    barStroke.Transparency = active and 0 or 0.12
end

function StealBar.Reset()
    StealBar.SetProgress(0)
    StealBar.SetState("READY")
end

_G.StealBar = StealBar

_G.KryzenXSetStealBarVisible = function(visible)
    if screenGui and screenGui.Parent then
        screenGui.Enabled = visible == true
    end
end

-- Start hidden until the existing Auto Steal visibility callback enables it.
screenGui.Enabled = false

task.spawn(function()
    local last = os.clock()
    local samples = {}

    RunService.RenderStepped:Connect(function()
        local now = os.clock()
        local delta = now - last
        last = now
        if delta > 0 then
            table.insert(samples, 1 / delta)
            if #samples > 25 then
                table.remove(samples, 1)
            end
        end
    end)

    while screenGui.Parent do
        local total = 0
        for _, fps in ipairs(samples) do
            total += fps
        end
        local fpsValue = #samples > 0 and math.floor(total / #samples + 0.5) or 0

        local pingValue = 0
        pcall(function()
            local item = Stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
            if item then
                pingValue = tonumber(item:GetValue()) or 0
            end
        end)

        statsLabel.Text = string.format("FPS: %d  |  PING: %dms", fpsValue, math.floor(pingValue + 0.5))
        task.wait(0.5)
    end
end)

return StealBar
