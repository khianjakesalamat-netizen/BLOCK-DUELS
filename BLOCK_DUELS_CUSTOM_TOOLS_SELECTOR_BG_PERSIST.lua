-- WHITE ROTATING: all violet/purple rotating color effects changed to white.
-- OUTFIT: renamed from AVATAR, now uses a selector like ANIM PACK (no 3D cards).
-- BUTTON BACKGROUND: image selector added below Background Image selector.
-- REMOVED: first two background images (#1 and #2) from GUI panel.
-- KZAX button: text is now solid white (no shimmer).
-- TAB POSITION: added picker below Lock UI (Up/Bottom/Left/Right).
-- CUSTOM TOOLS: added below OUTFIT with toggle and PICK button.
-- CUSTOM SOUNDS: added below CUSTOM TOOLS toggle (Bat -> katana slash, Medusa -> gunshot).
-- CUSTOM TOOLS SELECTOR: now uses 3D preview cards (ViewportFrame) like BAT SKINS.
-- REMOVED BAT SKIN PICKER: bat skin UI removed from GUI panel.
-- ANIM PACK: moved below SKY THEME.
-- CUSTOM SOUNDS: moved below CUSTOM TOOLS toggle button.
-- KATANA CUSTOM SOUND: REMOVED - only Medusa sound remains.
-- KATANA SKIN: now renders as normal bat; only works when CUSTOM SOUNDS is ON.
-- TITLE: small KZAX text replaced with big glossy red ADAPT-style KZAX.
-- FIX: Custom Tools & Custom Sounds toggles now restore ON/OFF state from saved config.
-- RED ROTATING: all rotating color effects changed to red.
-- REMOVED: Button Background Image selector and floating button background images.
-- FLOATING BUTTONS: touch effect is now RED and buttons do NOT move when pressed.
-- FIX: Floating button touch effect now clears when finger is lifted, toggle state stays separate.
-- CHANGE: RED -> WHITE throughout the file.
-- CHANGE: Removed profile thumbnail from STEAL BAR and aligned contents evenly.
-- CHANGE: Removed all red rotating borders (animated UIStroke gradients).
-- CHANGE: Floating button lining changed from red to black.
-- CHANGE: STEAL RANGE default now 60.
-- CHANGE: SEMI 60 RADIUS centered in steal bar.
-- REMOVED: Body Lock and Body Lock Range (entire Defense body-lock section).
-- ADDED: KICK WARNING module ("DON'T ENTER" / "ENTER") with slim progress bar.
-- ADDED: Kick Warning toggle button below Steal Radius.
-- ADDED: SHINY GRAPHICS module with toggle below Anti Lag.
-- ADDED: BODY LOCK module (Range = 13) with toggle below Anti Ragdoll.
-- CHANGED: Body Lock range changed from 15 to 13.
-- REMOVED: ANIM PACK code and GUI selector.
-- CHANGE: ESP LINE and ESP PLAYER BODY changed to WHITE color.
-- CHANGE: STEAL BAR lining changed to solid BLACK.
-- CHANGE: Body Lock range changed to 15.
-- CHANGE: Intro replaced with Free intro By yerky.txt
-- CHANGE: ESP tracer lines now aim at foot of player
-- CHANGE: Animation pack save/load now works properly (Vampire persists after re-execute)
-- CHANGE: Kick Warning toggle now properly works ON/OFF
-- REMOVED: INTRO SYSTEM
-- REMOVED: ADAPT SKIN code, ADAPT toggle button, ADAPT preset selector and picker
-- MOVED: Steal Bar Match toggle now below Kick Warning toggle
-- FIX: Outfit selection now persists across re-execution (saved to config)
-- CHANGE: Background Image selector now has < > arrows on each side to swipe through images
-- CHANGE: Steal bar progress fill is now SOLID WHITE (glow overlay removed)
-- ADDED: MANUAL JUMP / HOLD JUMP selector (triangle dropdown) under Infinite Jump
-- CHANGE: Background Image < > arrows now ONLY swipe the gallery (do not change bg)
-- CHANGE: Clicking a background thumbnail is now the ONLY way to change the bg
-- ADDED: InfiniteJump standalone module (MANUAL/HOLD modes)
-- ADDED: MVP SONG INTRO (redrum 0:40 -> 0:50) standalone
-- CHANGE: TP BAT AIMBOT replaced with NEW prediction-based aimbot (speed 57)
-- CHANGE: Floating button "TP BAT" renamed to "BAT BYPASS"
-- CHANGE: GUI toggle "TP Bat" renamed to "BAT BYPASS"
-- CHANGE: BAT BYPASS aimbot ACTIVATE_DISTANCE changed from 13 to 0.1 (instant hit on contact)
-- ADDED: ADAPT INTRO (SOUNDLESS) — tap-to-skip, no sound
-- CHANGE: Intro banner "ADAPT" -> "KZAX" text (soundless intro)
-- CHANGE: Intro "discord.gg/adaptt" -> "I LOVE KZAX"
-- CHANGE: Speed indicator "using KZAX" -> "I LOVE KZAX!"
-- REMOVED: chainSpear intro variant (only toji/gojo remain)
-- REMOVED: FONT STYLE code + GUI Font Style row

-- ============================================================
-- INFINITE JUMP MODULE (MANUAL + HOLD) — Standalone
-- ============================================================
local InfiniteJump = (function()
    local Players          = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local RunService       = game:GetService("RunService")

    local localPlayer = Players.LocalPlayer

    local CONFIG = {
        JumpPower       = 50,
        ManualJumpPower = 55,
        HoldThreshold   = 30,
        MaxFallSpeed    = -120,
        FallCap         = -50,
        InputDelay      = 0.2,
    }

    local enabled = false
    local mode    = "HOLD"
    local connections = {}

    local function getCharacter()
        local character = localPlayer.Character
        if not character then return nil, nil, nil end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not rootPart or not humanoid then return nil, nil, nil end
        return character, rootPart, humanoid
    end

    local function applyJump(rootPart, power)
        if not rootPart or not rootPart.Parent then return end
        local v = rootPart.Velocity
        rootPart.Velocity = Vector3.new(v.X, power, v.Z)
    end

    local function onJumpRequest()
        if not enabled then return end
        if mode ~= "MANUAL" then return end
        local _, rootPart = getCharacter()
        if not rootPart then return end
        applyJump(rootPart, CONFIG.ManualJumpPower)
    end

    local function onInputBegan(input)
        if not enabled then return end
        if mode ~= "HOLD" then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode ~= Enum.KeyCode.Space then return end
        if UserInputService:GetFocusedTextBox() then return end
        task.delay(CONFIG.InputDelay, function()
            if enabled and mode == "HOLD"
                and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                local _, rootPart = getCharacter()
                if rootPart then
                    applyJump(rootPart, CONFIG.JumpPower)
                end
            end
        end)
    end

    local function onHeartbeat()
        if not enabled then return end
        if mode ~= "HOLD" then return end
        local _, rootPart, humanoid = getCharacter()
        if not rootPart or not humanoid then return end
        local holdingJump = UserInputService:IsKeyDown(Enum.KeyCode.Space)
            or (humanoid.Jump == true)
        if holdingJump and rootPart.Velocity.Y < CONFIG.HoldThreshold then
            applyJump(rootPart, CONFIG.JumpPower)
        end
        if rootPart.Velocity.Y < CONFIG.MaxFallSpeed then
            local v = rootPart.Velocity
            rootPart.Velocity = Vector3.new(v.X, CONFIG.FallCap, v.Z)
        end
    end

    local function startConnections()
        connections.jumpRequest = UserInputService.JumpRequest:Connect(onJumpRequest)
        connections.inputBegan  = UserInputService.InputBegan:Connect(onInputBegan)
        connections.heartbeat   = RunService.Heartbeat:Connect(onHeartbeat)
    end

    local function stopConnections()
        for _, conn in pairs(connections) do
            if conn and typeof(conn) == "RBXScriptConnection" then
                pcall(function() conn:Disconnect() end)
            end
        end
        connections = {}
    end

    local M = {}
    function M.SetEnabled(state)
        enabled = state == true
        if enabled then
            stopConnections()
            startConnections()
        else
            stopConnections()
        end
        return enabled
    end
    function M.GetEnabled() return enabled end
    function M.SetMode(newMode)
        if newMode ~= "MANUAL" and newMode ~= "HOLD" then
            return false, "Mode must be 'MANUAL' or 'HOLD'"
        end
        mode = newMode
        return true
    end
    function M.GetMode() return mode end
    function M.Toggle() return M.SetEnabled(not enabled) end

    localPlayer.CharacterAdded:Connect(function()
        task.wait(0.2)
        if enabled then
            stopConnections()
            startConnections()
        end
    end)

    return M
end)()

if getgenv then getgenv().InfiniteJump = InfiniteJump end
_G.InfiniteJump = InfiniteJump

-- ============================================================
-- SPEED MODULE (Inlined from SpeedModule.lua)
-- ============================================================
local SpeedModule = (function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LP = Players.LocalPlayer

    local SPEEDS = {
        normal       = 59.5,
        carry        = 28.8,
        lagger       = 29,
        laggerCarry  = 15,
    }

    local state = {
        speedMode          = false,
        laggerToggled      = false,
        laggerCarryToggled = false,
        externalLock       = nil,
        speedLabel         = nil,
        onModeChanged      = nil,
        activeSpeed        = SPEEDS.normal,
    }

    local conn = nil
    local lastAppliedX, lastAppliedZ = 0, 0

    local function getHumanoidRootPart()
        local char = LP.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function getHumanoid()
        local char = LP.Character
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    local function isLocked()
        if type(state.externalLock) == "function" then
            local ok, locked = pcall(state.externalLock)
            if ok and locked then return true end
        end
        return false
    end

    local function getTargetSpeed()
        if state.speedMode then
            return SPEEDS.carry
        elseif state.laggerCarryToggled then
            return SPEEDS.laggerCarry
        elseif state.laggerToggled then
            return SPEEDS.lagger
        end
        return SPEEDS.normal
    end

    local function setAllFalse()
        state.speedMode = false
        state.laggerToggled = false
        state.laggerCarryToggled = false
    end

    local function notify()
        state.activeSpeed = getTargetSpeed()
        if type(state.onModeChanged) == "function" then
            pcall(state.onModeChanged, {
                speedMode = state.speedMode,
                laggerToggled = state.laggerToggled,
                laggerCarryToggled = state.laggerCarryToggled,
                activeSpeed = state.activeSpeed,
            })
        end
    end

    local function startLoop()
        if conn then return end
        conn = RunService.RenderStepped:Connect(function()
            if isLocked() then
                lastAppliedX, lastAppliedZ = 0, 0
                return
            end
            local hrp = getHumanoidRootPart()
            local hum = getHumanoid()
            if not hrp or not hum then return end
            local speed = getTargetSpeed()
            state.activeSpeed = speed
            local md = hum.MoveDirection
            if md.Magnitude > 0.001 then
                local targetX = md.X * speed
                local targetZ = md.Z * speed
                local curVel = hrp.AssemblyLinearVelocity
                hrp.AssemblyLinearVelocity = Vector3.new(targetX, curVel.Y, targetZ)
                lastAppliedX, lastAppliedZ = targetX, targetZ
            else
                if lastAppliedX ~= 0 or lastAppliedZ ~= 0 then
                    local curVel = hrp.AssemblyLinearVelocity
                    if math.abs(curVel.X) > 0.1 or math.abs(curVel.Z) > 0.1 then
                        hrp.AssemblyLinearVelocity = Vector3.new(0, curVel.Y, 0)
                    end
                    lastAppliedX, lastAppliedZ = 0, 0
                end
            end
            if state.speedLabel then
                local v = hrp.AssemblyLinearVelocity or hrp.Velocity
                local flatSpeed = math.sqrt(v.X * v.X + v.Z * v.Z)
                pcall(function()
                    state.speedLabel.Text = "Speed: " .. string.format("%.1f", flatSpeed)
                end)
            end
        end)
    end

    local function stopLoop()
        if conn then
            conn:Disconnect()
            conn = nil
        end
    end

    local M = {}

    function M.toggleCarryMode()
        local was = state.speedMode
        setAllFalse()
        state.speedMode = not was
        notify()
        return state.speedMode
    end
    function M.toggleLaggerMode()
        local was = state.laggerToggled
        setAllFalse()
        state.laggerToggled = not was
        notify()
        return state.laggerToggled
    end
    function M.toggleLaggerCarryMode()
        local was = state.laggerCarryToggled
        setAllFalse()
        state.laggerCarryToggled = not was
        notify()
        return state.laggerCarryToggled
    end
    function M.toggleLaggerCycle()
        if state.speedMode then
            state.speedMode = false; state.laggerToggled = true; state.laggerCarryToggled = false
        elseif state.laggerToggled then
            state.laggerToggled = false; state.laggerCarryToggled = true
        elseif state.laggerCarryToggled then
            state.laggerCarryToggled = false; state.speedMode = true
        else
            state.speedMode = true
        end
        notify()
        return state
    end
    function M.setNormalSpeed(v) if type(v) == "number" and v > 0 then SPEEDS.normal = v end end
    function M.setCarrySpeed(v) if type(v) == "number" and v > 0 then SPEEDS.carry = v end end
    function M.setLaggerSpeed(v) if type(v) == "number" and v > 0 then SPEEDS.lagger = v end end
    function M.setLaggerCarrySpeed(v) if type(v) == "number" and v > 0 then SPEEDS.laggerCarry = v end end
    function M.getSpeed(key) return SPEEDS[key] end
    function M.getState()
        return {
            activeSpeed = state.activeSpeed,
            speedMode = state.speedMode,
            laggerToggled = state.laggerToggled,
            laggerCarryToggled = state.laggerCarryToggled,
            speeds = {
                normal = SPEEDS.normal,
                carry = SPEEDS.carry,
                lagger = SPEEDS.lagger,
                laggerCarry = SPEEDS.laggerCarry,
            },
        }
    end
    function M.setSpeedLabel(lbl) state.speedLabel = lbl end
    function M.setExternalLock(fn) state.externalLock = fn end
    M.onModeChanged = nil
    function M.start() startLoop() end
    function M.stop() stopLoop() end
    function M.reset()
        setAllFalse()
        lastAppliedX, lastAppliedZ = 0, 0
        notify()
    end
    return M
end)()

-- ============================================================
-- ADAPT INTRO (SOUNDLESS) — standalone, tap-to-skip
-- ============================================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local LP = Players.LocalPlayer

if _G.LustHubRunning then return end
_G.LustHubRunning = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HS = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LP = Players.LocalPlayer
local camera = workspace.CurrentCamera
local ContentProvider = game:GetService("ContentProvider")

local CONFIG_FILE = "AmiriDuels_Config.json"
local BUTTON_POS_FILE = "AmiriDuels_ButtonPositions.json"

-- ============================================================
-- ADAPT INTRO (SOUNDLESS) — chainSpear variant REMOVED
-- ============================================================
do
    local AdaptPlayers = game:GetService("Players")
    local AdaptUIS = game:GetService("UserInputService")
    local AdaptTS = game:GetService("TweenService")
    local AdaptRS = game:GetService("RunService")
    local AdaptLighting = game:GetService("Lighting")

    local adaptLP = AdaptPlayers.LocalPlayer
    local adaptPG = adaptLP:WaitForChild("PlayerGui")

    if not _G._AdaptIntroSoundlessLoaded then
        _G._AdaptIntroSoundlessLoaded = true

        local screenGui
        local existing = adaptPG:FindFirstChild("AdaptHubPolished")
        if existing then existing:Destroy() end
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AdaptHubPolished"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = adaptPG

        local function adaptPlayIntro()
            if _G._AdaptIntroCleanup then pcall(_G._AdaptIntroCleanup) end
            _G._AdaptIntroPlaying = true
            local flag28 = AdaptUIS.TouchEnabled and not AdaptUIS.KeyboardEnabled

            local tbl38 = {
                130451097419605, 129030262345273, 76292842640935, 82757811555212,
                92910922537368, 105960347086002, 116720305084998, 90341354549871,
                72399600208480, 81834484116440,
            }

            -- Only toji or gojo now (chainSpear removed)
            local v78 = Random.new():NextInteger(1, 100)
            local adaptCurrentIntroVariant = v78 <= 50 and "toji" or "gojo"
            if _G._AdaptForceIntroVariant == "toji" or _G._AdaptForceIntroVariant == "gojo" then
                adaptCurrentIntroVariant = _G._AdaptForceIntroVariant
            end
            _G._AdaptCurrentIntroVariant = adaptCurrentIntroVariant

            local adaptIntro = screenGui:FindFirstChild("AdaptIntro")
            if adaptIntro then adaptIntro:Destroy() end
            local adaptIntroBlur = AdaptLighting:FindFirstChild("AdaptIntroBlur")
            if adaptIntroBlur then adaptIntroBlur:Destroy() end

            local frame2 = Instance.new("Frame")
            frame2.Name = "AdaptIntro"
            frame2.BackgroundColor3 = Color3.fromRGB(10, 5, 8)
            frame2.BackgroundTransparency = 1
            frame2.BorderSizePixel = 0
            frame2.Size = UDim2.new(1, 0, 1, 0)
            frame2.ZIndex = 1000
            frame2.Visible = false
            frame2.Parent = screenGui

            -- Wheel backdrop kept hidden (no variant uses it now)
            local imageLabel = Instance.new("ImageLabel")
            imageLabel.Name = "IntroBackdropImage"
            imageLabel.BackgroundTransparency = 1
            imageLabel.Image = "rbxassetid://98541566010518"
            imageLabel.ImageTransparency = 1
            imageLabel.ScaleType = Enum.ScaleType.Fit
            imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            imageLabel.Position = UDim2.new(0.5, 0, 0.42, 0)
            imageLabel.Size = UDim2.new(0.92, 0, 0.5, 0)
            imageLabel.ZIndex = 1000
            imageLabel.Visible = false
            imageLabel.Parent = frame2
            local uiScale = Instance.new("UIScale", imageLabel)

            -- TOJI CUTOUT STAGE
            local frame3 = Instance.new("Frame")
            frame3.Name = "TojiCutoutStage"
            frame3.BackgroundTransparency = 1
            frame3.BorderSizePixel = 0
            frame3.AnchorPoint = Vector2.new(0.5, 0.5)
            frame3.Position = UDim2.new(0.5, 0, 0.42, 0)
            frame3.Size = flag28 and UDim2.new(0.76, 0, 0, 312) or UDim2.new(0.92, 0, 0.5, 0)
            frame3.Rotation = -2
            frame3.ClipsDescendants = false
            frame3.Visible = adaptCurrentIntroVariant == "toji"
            frame3.ZIndex = 1000
            frame3.Parent = frame2
            local uiScale2 = Instance.new("UIScale")
            uiScale2.Scale = 1
            uiScale2.Parent = frame3

            local tbl43, tbl44, tbl45, tbl46, tbl47 = {}, {}, {}, {}, {}
            local tbl48 = { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } }
            local tbl49 = { { -2, 0 }, { 2, 0 }, { 0, -2 }, { 0, 2 } }
            local tbl50, tbl51 = {}, {}

            local imageLabel2 = Instance.new("ImageLabel")
            imageLabel2.Name = "TojiPantsWhiteFill"
            imageLabel2.BackgroundTransparency = 1
            imageLabel2.Image = "rbxassetid://82757811555212"
            imageLabel2.ImageColor3 = Color3.fromRGB(255, 255, 255)
            imageLabel2.ImageTransparency = 1
            imageLabel2.ScaleType = Enum.ScaleType.Fit
            imageLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
            imageLabel2.Position = UDim2.fromScale(0.5, 0.5)
            imageLabel2.Size = UDim2.fromScale(1, 1)
            imageLabel2.ZIndex = 998
            imageLabel2.Parent = frame3

            local tbl52 = {
                [130451097419605] = true, [129030262345273] = true,
                [105960347086002] = true, [81834484116440] = true,
                [92910922537368] = true, [116720305084998] = true,
                [76292842640935] = true, [90341354549871] = true,
                [72399600208480] = true,
            }
            local tbl53 = { [129030262345273] = true, [105960347086002] = true, [81834484116440] = true }

            for i, v79 in ipairs(tbl38) do
                local tbl54 = {}
                for _, v80 in ipairs(tbl48) do
                    local instance2 = Instance.new("ImageLabel")
                    instance2.Name = "TojiSeamFill" .. i
                    instance2.BackgroundTransparency = 1
                    instance2.Image = "rbxassetid://" .. tostring(v79)
                    instance2.ImageColor3 = Color3.fromRGB(10, 10, 8)
                    instance2.ImageTransparency = 1
                    instance2.ScaleType = Enum.ScaleType.Fit
                    instance2.AnchorPoint = Vector2.new(0.5, 0.5)
                    instance2.Position = UDim2.new(0.5, v80[1], 0.5, v80[2])
                    instance2.Size = UDim2.fromScale(1, 1)
                    instance2.ZIndex = 999
                    instance2.Parent = frame3
                    table.insert(tbl54, { image = instance2, x = v80[1], y = v80[2] })
                end
                local imageLabel3 = Instance.new("ImageLabel")
                imageLabel3.Name = "TojiPiece" .. i
                imageLabel3.BackgroundTransparency = 1
                imageLabel3.Image = "rbxassetid://" .. tostring(v79)
                imageLabel3.ImageTransparency = 1
                imageLabel3.ScaleType = Enum.ScaleType.Fit
                imageLabel3.AnchorPoint = Vector2.new(0.5, 0.5)
                imageLabel3.Position = UDim2.fromScale(0.5, 0.5)
                imageLabel3.Size = UDim2.fromScale(1, 1)
                imageLabel3.ZIndex = 1000
                imageLabel3.Parent = frame3
                tbl43[i] = imageLabel3
                tbl44[imageLabel3] = tbl54
                if v79 == 129030262345273 then
                    local imageLabel4 = Instance.new("ImageLabel")
                    imageLabel4.Name = "TojiSwordShine"
                    imageLabel4.BackgroundTransparency = 1
                    imageLabel4.Image = imageLabel3.Image
                    imageLabel4.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    imageLabel4.ImageTransparency = 1
                    imageLabel4.ScaleType = Enum.ScaleType.Fit
                    imageLabel4.AnchorPoint = Vector2.new(0.5, 0.5)
                    imageLabel4.Position = imageLabel3.Position
                    imageLabel4.Size = imageLabel3.Size
                    imageLabel4.ZIndex = 1001
                    imageLabel4.Parent = frame3
                    local uiGradient = Instance.new("UIGradient")
                    uiGradient.Rotation = -25
                    uiGradient.Offset = Vector2.new(-1, 0)
                    local tbl55 = {
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(0.36, 1),
                        NumberSequenceKeypoint.new(0.5, 0),
                        NumberSequenceKeypoint.new(0.64, 1),
                        NumberSequenceKeypoint.new(1, 1),
                    }
                    uiGradient.Transparency = NumberSequence.new(tbl55)
                    uiGradient.Parent = imageLabel4
                    tbl46[imageLabel3] = { image = imageLabel4, gradient = uiGradient }
                end
                if v79 == 105960347086002 then
                    local tbl55 = {}
                    for _, v80 in ipairs(tbl49) do
                        local imageLabel4 = Instance.new("ImageLabel")
                        imageLabel4.Name = "TojiMovingHandWhiteFill"
                        imageLabel4.BackgroundTransparency = 1
                        imageLabel4.Image = "rbxassetid://" .. tostring(v79)
                        imageLabel4.ImageColor3 = Color3.fromRGB(255, 255, 255)
                        imageLabel4.ImageTransparency = 1
                        imageLabel4.ScaleType = Enum.ScaleType.Fit
                        imageLabel4.AnchorPoint = Vector2.new(0.5, 0.5)
                        imageLabel4.Position = UDim2.new(0.5, v80[1], 0.5, v80[2])
                        imageLabel4.Size = UDim2.fromScale(1, 1)
                        imageLabel4.ZIndex = 998
                        imageLabel4.Parent = frame3
                        table.insert(tbl55, { image = imageLabel4, x = v80[1], y = v80[2] })
                    end
                    tbl45[imageLabel3] = tbl55
                end
                if tbl52[v79] then
                    if v79 == 92910922537368 then tbl47[imageLabel3] = { x = 2, y = 3 }
                    elseif v79 == 116720305084998 then tbl47[imageLabel3] = { x = 2, y = 5 }
                    else tbl47[imageLabel3] = { x = 0, y = 0 } end
                    table.insert(tbl50, imageLabel3)
                    if tbl53[v79] then table.insert(tbl51, imageLabel3) end
                end
            end

            local function fn56(arg, arg2, rotation, arg3)
                local tbl54 = tbl44[arg] or {}
                local tbl55 = tbl45[arg] or {}
                local v79 = tbl46[arg]
                local tbl56 = tbl47[arg] or { x = 0, y = 0 }
                local udim2 = UDim2.new(arg2.X.Scale, arg2.X.Offset + tbl56.x, arg2.Y.Scale, arg2.Y.Offset + 5 + tbl56.y)
                if arg3 then
                    TweenService:Create(arg, arg3, { Position = udim2, Rotation = rotation }):Play()
                    for _, v80 in ipairs(tbl54) do
                        TweenService:Create(v80.image, arg3, {
                            Position = UDim2.new(udim2.X.Scale, udim2.X.Offset + v80.x, udim2.Y.Scale, udim2.Y.Offset + v80.y),
                            Rotation = rotation,
                        }):Play()
                    end
                    for _, v80 in ipairs(tbl55) do
                        TweenService:Create(v80.image, arg3, {
                            Position = UDim2.new(udim2.X.Scale, udim2.X.Offset + v80.x, udim2.Y.Scale, udim2.Y.Offset + v80.y),
                            Rotation = rotation,
                        }):Play()
                    end
                    if v79 then TweenService:Create(v79.image, arg3, { Position = udim2, Rotation = rotation }):Play() end
                else
                    arg.Position = udim2
                    arg.Rotation = rotation
                    for _, v80 in ipairs(tbl54) do
                        v80.image.Position = UDim2.new(udim2.X.Scale, udim2.X.Offset + v80.x, udim2.Y.Scale, udim2.Y.Offset + v80.y)
                        v80.image.Rotation = rotation
                    end
                    for _, v80 in ipairs(tbl55) do
                        v80.image.Position = UDim2.new(udim2.X.Scale, udim2.X.Offset + v80.x, udim2.Y.Scale, udim2.Y.Offset + v80.y)
                        v80.image.Rotation = rotation
                    end
                    if v79 then v79.image.Position = udim2; v79.image.Rotation = rotation end
                end
            end

            -- GOJO CUTOUT STAGE
            local tbl54 = { pieces = {}, layers = {}, birds = {}, sunLayers = {} }
            local tbl55 = {
                { id = 109352181830543, role = "torso", pivot = Vector2.new(0.5, 0.53) },
                { id = 122114082580659, role = "torsoOverlay", pivot = Vector2.new(0.5, 0.53), parent = "torso" },
                { id = 139479809590896, role = "straightLeg", pivot = Vector2.new(0.5537, 0.4321), parent = "torso" },
                { id = 100210458187990, role = "straightBoot", pivot = Vector2.new(0.112, 0.2012), parent = "straightLeg" },
                { id = 78084312740336, role = "bentLeg", pivot = Vector2.new(0.4586, 0.4857), parent = "torso" },
                { id = 73089083195386, role = "bentBoot", pivot = Vector2.new(0.2577, 0.456), parent = "bentLeg" },
                { id = 106466482082324, role = "leftHand", pivot = Vector2.new(0.135, 0.6286), parent = "torso" },
                { id = 105145816596875, role = "rightHand", pivot = Vector2.new(0.8436, 0.5786), parent = "torso" },
                { id = 119573317226147, role = "head", pivot = Vector2.new(0.6503, 0.7274), parent = "torso" },
                { id = 92470817410025, role = "hair", pivot = Vector2.new(0.684, 0.8095), parent = "head" },
            }

            local frame4 = Instance.new("Frame")
            frame4.Name = "GojoCutoutStage"
            frame4.BackgroundTransparency = 1
            frame4.BorderSizePixel = 0
            frame4.AnchorPoint = Vector2.new(0.5, 0.5)
            frame4.Position = UDim2.new(0.5, 0, 0.43, 0)
            frame4.Size = flag28 and UDim2.new(0.76, 0, 0, 312) or UDim2.new(0.92, 0, 0.62, 0)
            frame4.Rotation = -38
            frame4.ClipsDescendants = false
            frame4.Visible = adaptCurrentIntroVariant == "gojo"
            frame4.ZIndex = 1000
            frame4.Parent = frame2
            tbl54.stage = frame4
            local uiAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
            uiAspectRatioConstraint2.Name = "GojoSourceAspect"
            uiAspectRatioConstraint2.AspectRatio = 0.77619047619047621
            uiAspectRatioConstraint2.DominantAxis = Enum.DominantAxis.Height
            uiAspectRatioConstraint2.Parent = frame4
            local uiScale3 = Instance.new("UIScale")
            uiScale3.Name = "GojoScale"
            uiScale3.Scale = 1
            uiScale3.Parent = frame4
            tbl54.scale = uiScale3
            tbl54.active = false

            for i, v79 in ipairs(tbl55) do
                local instance2 = Instance.new("Frame")
                instance2.Name = "GojoJoint_" .. v79.role
                instance2.BackgroundTransparency = 1
                instance2.BorderSizePixel = 0
                instance2.AnchorPoint = Vector2.new(0.5, 0.5)
                local parent = v79.parent and tbl54.layers[v79.parent]
                if parent then
                    instance2.Position = UDim2.fromScale(0.5 + v79.pivot.X - parent.pivot.X, 0.5 + v79.pivot.Y - parent.pivot.Y)
                else
                    instance2.Position = UDim2.fromScale(v79.pivot.X, v79.pivot.Y)
                end
                instance2.Size = UDim2.fromScale(1, 1)
                instance2.ZIndex = 1000 + i
                instance2.Parent = parent and parent.image or frame4
                local imageLabel3 = Instance.new("ImageLabel")
                imageLabel3.Name = "Gojo_" .. v79.role
                imageLabel3.BackgroundTransparency = 1
                imageLabel3.BorderSizePixel = 0
                imageLabel3.Image = "rbxassetid://" .. tostring(v79.id)
                imageLabel3.ImageColor3 = Color3.fromRGB(255, 255, 255)
                imageLabel3.ImageTransparency = 1
                imageLabel3.ScaleType = Enum.ScaleType.Stretch
                imageLabel3.AnchorPoint = Vector2.new(1, 1)
                imageLabel3.Position = UDim2.fromScale(0.5 - v79.pivot.X, 0.5 - v79.pivot.Y)
                imageLabel3.Size = UDim2.fromScale(1, 1)
                imageLabel3.ZIndex = 1000 + i
                imageLabel3.Parent = instance2
                tbl54.pieces[i] = imageLabel3
                tbl54.layers[v79.role] = { image = instance2, pivot = v79.pivot, basePosition = instance2.Position }
            end

            tbl54.addBird = function(arg)
                local n34 = flag28 and 18 or 34
                local frame5 = Instance.new("Frame")
                frame5.Name = "GojoBird" .. arg
                frame5.BackgroundTransparency = 1
                frame5.BorderSizePixel = 0
                frame5.AnchorPoint = Vector2.new(0.5, 0.5)
                frame5.Position = UDim2.fromScale(0.5, 0.42)
                frame5.Size = UDim2.fromOffset(n34, math.floor(n34 * 0.56))
                frame5.Visible = adaptCurrentIntroVariant == "gojo"
                frame5.ZIndex = 1015
                frame5.Parent = frame2
                local n35 = math.floor(n34 * 0.58)
                local n36 = flag28 and 2 or 3
                local frame6 = Instance.new("Frame")
                frame6.Name = "LeftWing"
                frame6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                frame6.BackgroundTransparency = 1
                frame6.BorderSizePixel = 0
                frame6.AnchorPoint = Vector2.new(0.5, 0.5)
                frame6.Position = UDim2.new(0.5, -n35 * 0.23, 0.5, 0)
                frame6.Size = UDim2.fromOffset(n35, n36)
                frame6.Rotation = 22
                frame6.ZIndex = frame5.ZIndex
                frame6.Parent = frame5
                Instance.new("UICorner", frame6).CornerRadius = UDim.new(1, 0)
                local clone = frame6:Clone()
                clone.Name = "RightWing"
                clone.Position = UDim2.new(0.5, n35 * 0.23, 0.5, 0)
                clone.Rotation = -22
                clone.Parent = frame5
                local clone2 = frame6:Clone()
                clone2.Name = "LeftFeather"
                clone2.Position = UDim2.new(0.5, -n35 * 0.3, 0.5, n36 * 1.15)
                clone2.Size = UDim2.fromOffset(math.floor(n35 * 0.68), math.max(1, n36 - 1))
                clone2.Rotation = 34
                clone2.Parent = frame5
                local clone3 = clone2:Clone()
                clone3.Name = "RightFeather"
                clone3.Position = UDim2.new(0.5, n35 * 0.3, 0.5, n36 * 1.15)
                clone3.Rotation = -34
                clone3.Parent = frame5
                local uiScale4 = Instance.new("UIScale")
                local scale = 0.76 + arg % 4 * 0.1
                uiScale4.Scale = scale
                uiScale4.Parent = frame5
                tbl54.birds[arg] = {
                    frame = frame5, leftWing = frame6, rightWing = clone,
                    leftFeather = clone2, rightFeather = clone3, scale = uiScale4,
                    baseScale = scale,
                    phase = (arg - 1) / 6 * 3.1415926535897931 * 2,
                    radiusX = 0.22 + arg % 3 * 0.045,
                    radiusY = 0.13 + arg % 2 * 0.045,
                    speed = 0.2 + arg % 3 * 0.025,
                }
            end
            for i = 1, 6 do tbl54.addBird(i) end

            tbl54.addAtmosphere = function()
                local frame5 = Instance.new("Frame")
                frame5.Name = "GojoGoldenSun"
                frame5.BackgroundTransparency = 1
                frame5.BorderSizePixel = 0
                frame5.AnchorPoint = Vector2.new(0.5, 0.5)
                frame5.Position = UDim2.fromScale(0.5, 0.43)
                frame5.Size = flag28 and UDim2.fromOffset(260, 260) or UDim2.fromOffset(500, 500)
                frame5.Visible = adaptCurrentIntroVariant == "gojo"
                frame5.ZIndex = 950
                frame5.Parent = frame2
                tbl54.sunRoot = frame5
                local uiScale4 = Instance.new("UIScale")
                uiScale4.Scale = 1
                uiScale4.Parent = frame5
                tbl54.sunScale = uiScale4
                local tbl66 = {
                    { size = 1.1, color = Color3.fromRGB(255, 126, 22), target = 0.9 },
                    { size = 1.03, color = Color3.fromRGB(255, 177, 35), target = 0.76 },
                    { size = 0.96, color = Color3.fromRGB(255, 218, 77), target = 0.6 },
                }
                for i, v79 in ipairs(tbl66) do
                    local instance2 = Instance.new("Frame")
                    instance2.Name = "GoldenSunLayer" .. i
                    instance2.BackgroundColor3 = v79.color
                    instance2.BackgroundTransparency = 1
                    instance2.BorderSizePixel = 0
                    instance2.AnchorPoint = Vector2.new(0.5, 0.5)
                    instance2.Position = UDim2.fromScale(0.5, 0.5)
                    instance2.Size = UDim2.fromScale(v79.size, v79.size)
                    instance2.ZIndex = frame5.ZIndex + i
                    instance2.Parent = frame5
                    Instance.new("UICorner", instance2).CornerRadius = UDim.new(1, 0)
                    if i == #tbl66 then
                        local uiGradient = Instance.new("UIGradient")
                        uiGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 238, 137)),
                            ColorSequenceKeypoint.new(0.48, Color3.fromRGB(255, 205, 54)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 126, 135)),
                        })
                        uiGradient.Rotation = 48
                        uiGradient.Parent = instance2
                    end
                    tbl54.sunLayers[i] = { frame = instance2, target = v79.target }
                end
            end
            tbl54.addAtmosphere()

            -- BANNER + CAPTIONS
            local instance2 = Instance.new("TextLabel")
            instance2.Name = "IntroBanner"
            instance2.BackgroundTransparency = 1
            instance2.Text = "KZAX"
            instance2.TextColor3 = Color3.fromRGB(255, 255, 255)
            instance2.Font = Enum.Font.GothamBlack
            instance2.TextScaled = true
            instance2.AnchorPoint = Vector2.new(0.5, 0.5)
            instance2.Position = UDim2.new(0.5, 0, 0.42, 0)
            instance2.Size = flag28 and UDim2.new(0.38, 0, 0, 78) or UDim2.new(0.92, 0, 0, 170)
            instance2.TextTransparency = 1
            instance2.ZIndex = 1002
            instance2.Parent = frame2

            local textLabel = Instance.new("TextLabel")
            textLabel.Name = "TapAnywhere"
            textLabel.BackgroundTransparency = 1
            textLabel.Text = "TAP ANYWHERE TO SKIP"
            textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel.TextTransparency = 1
            textLabel.TextSize = flag28 and 18 or 44
            textLabel.Font = Enum.Font.GothamBlack
            textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            textLabel.Position = flag28 and UDim2.new(0.5, 0, 0.42, 58) or UDim2.fromScale(0.5, 0.82)
            textLabel.Size = UDim2.new(0.7, 0, 0, 20)
            textLabel.TextXAlignment = Enum.TextXAlignment.Center
            textLabel.ZIndex = 1003
            textLabel.Parent = frame2

            local textLabel2 = Instance.new("TextLabel")
            textLabel2.Name = "DiscordInvite"
            textLabel2.BackgroundTransparency = 1
            textLabel2.Text = "I LOVE KZAX"
            textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
            textLabel2.TextTransparency = 1
            textLabel2.TextSize = flag28 and 24 or 40
            textLabel2.Font = Enum.Font.GothamBlack
            textLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
            textLabel2.Position = flag28 and UDim2.new(0.5, 0, 0.42, 80) or UDim2.fromScale(0.5, 0.89)
            textLabel2.Size = UDim2.new(0.7, 0, 0, 18)
            textLabel2.TextXAlignment = Enum.TextXAlignment.Center
            textLabel2.ZIndex = 1003
            textLabel2.Parent = frame2

            local frame5 = Instance.new("Frame")
            frame5.Name = "IntroCaptionShield"
            frame5.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
            frame5.BackgroundTransparency = 1
            frame5.BorderSizePixel = 0
            frame5.AnchorPoint = Vector2.new(0.5, 0.5)
            frame5.Position = UDim2.new(0.5, 0, 0.42, flag28 and 70 or 124)
            frame5.Size = UDim2.new(0.58, 0, 0, 48)
            frame5.ZIndex = 1002
            frame5.Parent = frame2
            frame5.Visible = false
            Instance.new("UICorner", frame5).CornerRadius = UDim.new(0, 14)
            local uiGradient = Instance.new("UIGradient")
            uiGradient.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.94),
                NumberSequenceKeypoint.new(0.16, 0.14),
                NumberSequenceKeypoint.new(0.84, 0.14),
                NumberSequenceKeypoint.new(1, 0.94),
            })
            uiGradient.Parent = frame5

            local textButton = Instance.new("TextButton")
            textButton.Name = "TapCatcher"
            textButton.BackgroundTransparency = 1
            textButton.Text = ""
            textButton.AutoButtonColor = false
            textButton.Size = UDim2.new(1, 0, 1, 0)
            textButton.ZIndex = 1004
            textButton.Parent = frame2

            local blurEffect = Instance.new("BlurEffect")
            blurEffect.Name = "AdaptIntroBlur"
            blurEffect:SetAttribute("_AdaptIntroEffect", true)
            blurEffect.Size = 0
            blurEffect.Parent = AdaptLighting

            local flag29, flag30, flag31, flag32, flag33 = false, false, false, false, false
            local connection2 = nil

            _G._AdaptIntroCleanup = function()
                flag29 = true; flag31 = false; flag32 = false; flag33 = false
                tbl54.active = false
                if connection2 then connection2:Disconnect(); connection2 = nil end
                _G._AdaptIntroPlaying = false
                if frame2 and frame2.Parent then frame2:Destroy() end
                if blurEffect and blurEffect.Parent then blurEffect:Destroy() end
            end

            local function fn59()
                flag33 = true
                task.spawn(function()
                    for _, v84 in ipairs(tbl50) do fn56(v84, UDim2.new(0.5, -1, 0.5, -3), -1) end
                    task.wait(0.18)
                    if not flag33 or flag29 then return end
                    local flag34 = false
                    while flag33 and not flag29 do
                        flag34 = not flag34
                        local udim2 = flag34 and UDim2.new(0.5, -1, 0.5, -2) or UDim2.new(0.5, 1, 0.5, 1)
                        local n34 = flag34 and -1 or 1
                        for _, v84 in ipairs(tbl50) do
                            fn56(v84, udim2, n34, TweenInfo.new(1.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))
                        end
                        local udim22 = flag34 and UDim2.new(0.5, -2, 0.5, -3) or UDim2.new(0.5, 2, 0.5, 2)
                        local n35 = flag34 and -2 or 2
                        for _, v84 in ipairs(tbl51) do
                            fn56(v84, udim22, n35, TweenInfo.new(1.05, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut))
                        end
                        task.wait(1.08)
                    end
                end)
            end

            tbl54.play = function()
                tbl54.active = true
                task.spawn(function()
                    local now2 = os.clock()
                    local layers = tbl54.layers
                    while tbl54.active and not flag29 do
                        local n34 = (os.clock() - now2) * 2.5
                        local v84 = math.sin(n34 * 0.82)
                        local v85 = math.sin(n34 * 0.68 + 0.45)
                        tbl54.stage.Position = UDim2.new(0.5, math.sin(n34 * 0.57 + 0.8) * 4, 0.42, v84 * 6)
                        tbl54.stage.Rotation = -38 + v85 * 1.15
                        tbl54.scale.Scale = 1 + math.sin(n34 * 0.73 + 1.2) * 0.014
                        local v86 = 25.13
                        layers.torso.image.Rotation = math.sin(n34 * 0.76) * v86
                        layers.head.image.Rotation = math.sin(n34 * 0.92 + 0.65) * 1.55
                        layers.hair.image.Rotation = math.sin(n34 * 1.08 + 1.1) * 0.85
                        layers.leftHand.image.Rotation = math.sin(n34 * 0.88 + 0.25) * 3.25
                        layers.rightHand.image.Rotation = math.sin(n34 * 0.96 + 2.35) * 3.15
                        layers.straightLeg.image.Rotation = math.sin(n34 * 0.72 + 0.2) * 4
                        layers.straightBoot.image.Rotation = math.sin(n34 * 0.91 + 0.75) * 1.25
                        layers.bentLeg.image.Rotation = math.sin(n34 * 0.79 + 3.05) * 4.15
                        layers.bentBoot.image.Rotation = math.sin(n34 * 0.98 + 3.55) * 1.35
                        for _, bird in ipairs(tbl54.birds) do
                            local n35 = n34 * bird.speed + bird.phase
                            local n36 = math.sin(n34 * 3.8 + bird.phase) * 7.5
                            local n37 = (math.sin(n35) + 1) * 0.5
                            bird.frame.Position = UDim2.fromScale(0.5 + math.cos(n35) * bird.radiusX, 0.42 + math.sin(n35 * 1.08) * bird.radiusY + math.sin(n34 * 1.3 + bird.phase) * 0.012)
                            bird.frame.Rotation = math.sin(n35 * 1.7) * 5
                            bird.scale.Scale = bird.baseScale * (0.91 + n37 * 0.13)
                            bird.leftWing.Rotation = 20 + n36
                            bird.rightWing.Rotation = -20 - n36
                            bird.leftFeather.Rotation = 32 + n36 * 0.72
                            bird.rightFeather.Rotation = -32 - n36 * 0.72
                        end
                        tbl54.sunScale.Scale = 1 + math.sin(n34 * 0.18 + 0.6) * 0.018
                        AdaptRS.RenderStepped:Wait()
                    end
                end)
            end

            local function fn60()
                if not flag30 or flag29 then return end
                flag29 = true; flag31 = false; flag32 = false; flag33 = false
                tbl54.active = false
                if connection2 then connection2:Disconnect(); connection2 = nil end
                local tweenInfo = TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(frame2, tweenInfo, { BackgroundTransparency = 1 }):Play()
                TweenService:Create(instance2, tweenInfo, { TextTransparency = 1 }):Play()
                if adaptCurrentIntroVariant == "gojo" then
                    if tbl54.scale then TweenService:Create(tbl54.scale, tweenInfo, { Scale = 0.06 }):Play() end
                    if tbl54.sunScale then TweenService:Create(tbl54.sunScale, tweenInfo, { Scale = 0.06 }):Play() end
                end
                TweenService:Create(imageLabel, tweenInfo, { ImageTransparency = 1 }):Play()
                for _, v84 in ipairs(tbl43) do
                    TweenService:Create(v84, tweenInfo, { ImageTransparency = 1 }):Play()
                    for _, v86 in ipairs(tbl44[v84] or {}) do
                        TweenService:Create(v86.image, tweenInfo, { ImageTransparency = 1 }):Play()
                    end
                    for _, v87 in ipairs(tbl45[v84] or {}) do
                        TweenService:Create(v87.image, tweenInfo, { ImageTransparency = 1 }):Play()
                    end
                    local v87 = tbl46[v84]
                    if v87 then
                        if v87.gradientTween then v87.gradientTween:Cancel() end
                        if v87.pulseTween then v87.pulseTween:Cancel() end
                        TweenService:Create(v87.image, tweenInfo, { ImageTransparency = 1 }):Play()
                    end
                end
                TweenService:Create(imageLabel2, tweenInfo, { ImageTransparency = 1 }):Play()
                for _, piece in ipairs(tbl54.pieces) do
                    TweenService:Create(piece, tweenInfo, { ImageTransparency = 1 }):Play()
                end
                for _, bird in ipairs(tbl54.birds) do
                    TweenService:Create(bird.leftWing, tweenInfo, { BackgroundTransparency = 1 }):Play()
                    TweenService:Create(bird.rightWing, tweenInfo, { BackgroundTransparency = 1 }):Play()
                    TweenService:Create(bird.leftFeather, tweenInfo, { BackgroundTransparency = 1 }):Play()
                    TweenService:Create(bird.rightFeather, tweenInfo, { BackgroundTransparency = 1 }):Play()
                end
                for _, sunLayer in ipairs(tbl54.sunLayers) do
                    TweenService:Create(sunLayer.frame, tweenInfo, { BackgroundTransparency = 1 }):Play()
                end
                TweenService:Create(frame5, tweenInfo, { BackgroundTransparency = 1 }):Play()
                TweenService:Create(textLabel, tweenInfo, { TextTransparency = 1 }):Play()
                TweenService:Create(textLabel2, tweenInfo, { TextTransparency = 1 }):Play()
                TweenService:Create(blurEffect, tweenInfo, { Size = 0 }):Play()
                task.delay(0.42, function()
                    if frame2 and frame2.Parent then frame2:Destroy() end
                    if blurEffect and blurEffect.Parent then blurEffect:Destroy() end
                    _G._AdaptIntroPlaying = false
                    local reveal = _G._AdaptRevealMainAfterIntro
                    _G._AdaptRevealMainAfterIntro = nil
                    if reveal then reveal() end
                end)
            end

            textButton.Activated:Connect(fn60)

            local function fn61()
                if flag30 or flag29 then return false end
                flag30 = true
                frame2.Visible = true
                TweenService:Create(frame2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.5 }):Play()
                TweenService:Create(blurEffect, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = 10 }):Play()
                TweenService:Create(instance2, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 }):Play()
                if adaptCurrentIntroVariant == "gojo" then
                    tbl54.stage.Visible = true
                    tbl54.sunRoot.Visible = true
                    for _, sunLayer in ipairs(tbl54.sunLayers) do
                        TweenService:Create(sunLayer.frame, TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { BackgroundTransparency = sunLayer.target }):Play()
                    end
                    for i, piece in ipairs(tbl54.pieces) do
                        task.delay((i - 1) * 0.03, function()
                            if not flag29 and piece.Parent then
                                TweenService:Create(piece, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
                            end
                        end)
                    end
                    for i, bird in ipairs(tbl54.birds) do
                        bird.frame.Visible = true
                        task.delay(0.08 + (i - 1) * 0.055, function()
                            if not flag29 and bird.frame.Parent then
                                TweenService:Create(bird.leftWing, TweenInfo.new(0.3), { BackgroundTransparency = 0.04 }):Play()
                                TweenService:Create(bird.rightWing, TweenInfo.new(0.3), { BackgroundTransparency = 0.04 }):Play()
                                TweenService:Create(bird.leftFeather, TweenInfo.new(0.3), { BackgroundTransparency = 0.22 }):Play()
                                TweenService:Create(bird.rightFeather, TweenInfo.new(0.3), { BackgroundTransparency = 0.22 }):Play()
                            end
                        end)
                    end
                else
                    TweenService:Create(imageLabel2, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
                    for i, v84 in ipairs(tbl43) do
                        task.delay((i - 1) * 0.035, function()
                            if not flag29 and v84.Parent then
                                TweenService:Create(v84, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
                                for _, v86 in ipairs(tbl44[v84] or {}) do
                                    TweenService:Create(v86.image, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.15 }):Play()
                                end
                                for _, v87 in ipairs(tbl45[v84] or {}) do
                                    TweenService:Create(v87.image, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0 }):Play()
                                end
                                local v87 = tbl46[v84]
                                if v87 then
                                    TweenService:Create(v87.image, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { ImageTransparency = 0.25 }):Play()
                                    v87.gradient.Offset = Vector2.new(-1, 0)
                                    v87.gradientTween = TweenService:Create(v87.gradient, TweenInfo.new(1.15, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), { Offset = Vector2.new(1, 0) })
                                    v87.gradientTween:Play()
                                    v87.pulseTween = TweenService:Create(v87.image, TweenInfo.new(0.72, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { ImageTransparency = 0.58 })
                                    v87.pulseTween:Play()
                                end
                            end
                        end)
                    end
                end
                TweenService:Create(frame5, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.08 }):Play()
                TweenService:Create(textLabel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.05 }):Play()
                TweenService:Create(textLabel2, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0.05 }):Play()
                if adaptCurrentIntroVariant == "gojo" then tbl54.play() else fn59() end
                task.delay(6, fn60)
                return true
            end

            fn61()
        end

        _G._AdaptPlayIntro = adaptPlayIntro
        _G._AdaptIntroEnabled = true
        adaptPlayIntro()
    end
end

-- ============================================================
-- CUSTOM TOOLS ENGINE (Standalone)
-- ============================================================
local CT_Players    = game:GetService("Players")
local CT_RunService = game:GetService("RunService")
local CT_LP         = CT_Players.LocalPlayer

local function _saveCfg()
    if type(saveAmbitiousConfig) == "function" then
        pcall(saveAmbitiousConfig)
    end
end

local CT_ITEMS = {
    { key = "Bat",    match = function(n) n = n:lower() return n:find("bat") ~= nil or n:find("slap") ~= nil end },
    { key = "Medusa", match = function(n) return n:lower():find("medusa") ~= nil end },
}

local function ctMatchItem(inst)
    if not (inst:IsA("Tool") or inst:IsA("Model") or inst:IsA("Accessory") or inst:IsA("BasePart")) then
        return nil
    end
    for _, item in ipairs(CT_ITEMS) do
        if item.match(inst.Name) then return item end
    end
    return nil
end

local function isReplicaStuff(d)
    if d.Name == "LocalReplica" then return true end
    return d:FindFirstAncestor("LocalReplica") ~= nil
end

local CT_Trans = {}
do
    local PRIORITY = { "custom", "rainbow", "transparent" }
    local baseline = setmetatable({}, { __mode = "k" })
    local claims   = setmetatable({}, { __mode = "k" })
    local guards   = setmetatable({}, { __mode = "k" })

    function CT_Trans.getBaseline(part)
        local b = baseline[part]
        if b ~= nil then return b end
        local ok, val = pcall(function() return part.Transparency end)
        if not ok then return nil end
        baseline[part] = val
        return val
    end

    local function wantedValue(part)
        local c = claims[part]
        if not c then return nil end
        for _, who in ipairs(PRIORITY) do
            if c[who] ~= nil then return c[who] end
        end
        return nil
    end

    local function setIfDifferent(part, v)
        local ok, cur = pcall(function() return part.Transparency end)
        if ok and cur ~= nil and math.abs(cur - v) <= 0.001 then return end
        pcall(function() part.Transparency = v end)
    end

    local function resolve(part)
        local v = wantedValue(part)
        if v ~= nil then
            setIfDifferent(part, v)
            return
        end
        local b = baseline[part]
        if b ~= nil then
            setIfDifferent(part, b)
        end
    end

    local function armGuard(part)
        if guards[part] then return end
        local ok, conn = pcall(function()
            return part:GetPropertyChangedSignal("Transparency"):Connect(function()
                local v = wantedValue(part)
                if v == nil then return end
                local ok2, cur = pcall(function() return part.Transparency end)
                if ok2 and cur ~= nil and math.abs(cur - v) > 0.001 then
                    pcall(function() part.Transparency = v end)
                end
            end)
        end)
        if ok and conn then guards[part] = conn end
    end

    local function disarmGuard(part)
        local conn = guards[part]
        if conn then
            pcall(function() conn:Disconnect() end)
            guards[part] = nil
        end
    end

    function CT_Trans.enforce()
        for part, _ in pairs(claims) do
            if part.Parent then
                local v = wantedValue(part)
                if v ~= nil then
                    local ok, cur = pcall(function() return part.Transparency end)
                    if ok and cur ~= nil and math.abs(cur - v) > 0.001 then
                        pcall(function() part.Transparency = v end)
                    end
                end
            end
        end
    end

    function CT_Trans.claim(part, who, value)
        if not part then return end
        if CT_Trans.getBaseline(part) == nil then return end
        local c = claims[part]
        if not c then c = {}; claims[part] = c end
        c[who] = value
        armGuard(part)
        resolve(part)
    end

    function CT_Trans.release(part, who)
        if not part then return end
        local c = claims[part]
        if not c then return end
        c[who] = nil
        if next(c) == nil then
            claims[part] = nil
            disarmGuard(part)
        end
        if part.Parent then resolve(part) end
    end
end

local CT_JANITORS = {}
task.spawn(function()
    while true do
        task.wait(10)
        for _, fn in ipairs(CT_JANITORS) do pcall(fn) end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.25)
        if _G.AmbitiousCustomToolsEnabled == true then
            pcall(CT_Trans.enforce)
        end
    end
end)

-- ============================================================
-- CUSTOM TOOLS
-- ============================================================
do
    local ASSETS = {
        DiamondSword      = { cat = "Bat",    label = "Diamond Sword",
                              mesh = "rbxassetid://8827558932", tex = "rbxassetid://8827558969",
                              scale = Vector3.new(0.2, 0.2, 0.2),
                              c0 = CFrame.new(-0.05, -0.1, -0.12) * CFrame.Angles(math.rad(90), math.rad(180), 300),
                              view = 4.9 },
        Katana            = { cat = "Bat",    label = "Katana",
                              mesh = "rbxassetid://13528902482", tex = "rbxassetid://13528902373",
                              scale = Vector3.new(1.4, 1.4, 1.4),
                              c0 = CFrame.new(0, 0.6, 0) * CFrame.Angles(math.rad(270), math.rad(180), math.rad(180)),
                              view = 6.6 },
        Skull             = { cat = "Medusa", label = "Skull",
                              mesh = "rbxassetid://2050312704", tex = "rbxassetid://2050313393",
                              scale = Vector3.new(1, 1, 1),
                              c0 = CFrame.new(0, 0.65, -0.4) * CFrame.Angles(math.rad(330), 0, 0),
                              view = 4.2 },
        GoldenDesertEagle = { cat = "Medusa", label = "Golden Desert Eagle",
                              mesh = "rbxassetid://430251413", tex = "rbxassetid://435840335",
                              scale = Vector3.new(0.01, 0.01, 0.01),
                              c0 = CFrame.new(0, 0, -0.8) * CFrame.Angles(math.rad(330), math.rad(180), 0),
                              view = 3.0 },
    }
    _G.AmbitiousCustomToolAssets = ASSETS

    _G.AmbitiousCustomToolSkins = _G.AmbitiousCustomToolSkins
        or { Bat = "DiamondSword", Medusa = "GoldenDesertEagle" }

    local function skinFor(cat)
        local key = _G.AmbitiousCustomToolSkins[cat]
        if key and ASSETS[key] and ASSETS[key].cat == cat then return key end
        return (cat == "Bat") and "DiamondSword" or "GoldenDesertEagle"
    end

    local enabled       = false
    local tracked       = setmetatable({}, { __mode = "k" })
    local watchers      = setmetatable({}, { __mode = "k" })
    local pendingHandle = setmetatable({}, { __mode = "k" })
    local teardown

    local function buildReplica(handle, mode)
        local existing = handle:FindFirstChild("LocalReplica")
        if existing then existing:Destroy() end
        local data = ASSETS[mode] or ASSETS.DiamondSword
        local m = Instance.new("Model")
        m.Name = "LocalReplica"
        local p = Instance.new("Part")
        p.Name        = "MainPart"
        p.CanCollide  = false
        p.CanQuery    = false
        p.CanTouch    = false
        p.Massless    = true
        p.Size        = Vector3.new(1, 1, 1)
        p.Transparency= 0
        p.Anchored    = false
        p.Parent      = m
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType  = Enum.MeshType.FileMesh
        mesh.MeshId    = data.mesh
        mesh.TextureId = data.tex
        mesh.Parent    = p
        local w = Instance.new("Motor6D")
        w.Part0 = handle
        w.Part1 = p
        mesh.Scale = data.scale
        w.C0 = data.c0
        w.Parent = p
        m.Parent = handle
        return m
    end

    local function hideNode(entry, d)
        if isReplicaStuff(d) then return end
        if d:IsA("BasePart") or d:IsA("Decal") or d:IsA("Texture") then
            entry.hidden[d] = true
            CT_Trans.claim(d, "custom", 1)
        end
    end

    local function setupTool(tool)
        if tracked[tool] then return end
        local handle = tool:FindFirstChild("Handle")
        if not handle then
            if pendingHandle[tool] then return end
            local c
            c = tool.ChildAdded:Connect(function(child)
                if child.Name == "Handle" then
                    pcall(function() c:Disconnect() end)
                    pendingHandle[tool] = nil
                    if enabled then setupTool(tool) end
                end
            end)
            pendingHandle[tool] = c
            return
        end
        local entry = { hidden = {}, conns = {} }
        tracked[tool] = entry
        for _, d in ipairs(tool:GetDescendants()) do hideNode(entry, d) end
        local item = ctMatchItem(tool)
        local mode = skinFor((item and item.key == "Bat") and "Bat" or "Medusa")
        entry.cat = (item and item.key == "Bat") and "Bat" or "Medusa"
        buildReplica(handle, mode)
        table.insert(entry.conns, tool.DescendantAdded:Connect(function(d)
            task.defer(function()
                if tracked[tool] then hideNode(entry, d) end
            end)
        end))
        table.insert(entry.conns, tool.AncestryChanged:Connect(function(_, parent)
            if not parent then teardown(tool, false) end
        end))
    end

    function teardown(tool, doRestore)
        local entry = tracked[tool]
        if not entry then return end
        for _, conn in ipairs(entry.conns) do pcall(function() conn:Disconnect() end) end
        local handle = tool:FindFirstChild("Handle")
        if handle then
            local rep = handle:FindFirstChild("LocalReplica")
            if rep then pcall(function() rep:Destroy() end) end
        end
        for obj in pairs(entry.hidden) do
            CT_Trans.release(obj, "custom")
        end
        entry.hidden = {}
        tracked[tool] = nil
    end

    local function tryRegister(inst)
        if not enabled then return end
        if inst:IsA("Tool") and ctMatchItem(inst) then
            setupTool(inst)
        end
    end

    local function unwatch(container)
        local conns = watchers[container]
        if not conns then return end
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        watchers[container] = nil
    end

    local function watch(container)
        if not container or watchers[container] then return end
        watchers[container] = { container.ChildAdded:Connect(tryRegister) }
        for _, child in ipairs(container:GetChildren()) do tryRegister(child) end
    end

    local function watchAll()
        watch(CT_LP:FindFirstChildOfClass("Backpack"))
        watch(CT_LP.Character)
    end

    CT_LP.ChildAdded:Connect(function(child)
        if enabled and child:IsA("Backpack") then watch(child) end
    end)

    CT_LP.CharacterAdded:Connect(function(char)
        for tool in pairs(tracked) do teardown(tool, false) end
        for _, c in pairs(pendingHandle) do pcall(function() c:Disconnect() end) end
        table.clear(pendingHandle)
        for container in pairs(watchers) do unwatch(container) end
        if not enabled then return end
        watch(char)
        task.defer(function()
            if enabled then watchAll() end
        end)
    end)

    table.insert(CT_JANITORS, function()
        for tool in pairs(tracked) do
            if not tool.Parent then teardown(tool, false) end
        end
        for tool, c in pairs(pendingHandle) do
            if not tool.Parent then
                pcall(function() c:Disconnect() end)
                pendingHandle[tool] = nil
            end
        end
        for container in pairs(watchers) do
            if not container.Parent then unwatch(container) end
        end
    end)

    local function rebuildIfNeeded(tool, entry, deep)
        local handle = tool:FindFirstChild("Handle")
        if not handle then return end
        local rep      = handle:FindFirstChild("LocalReplica")
        local mainPart = rep and rep:FindFirstChild("MainPart")
        local motor    = mainPart and mainPart:FindFirstChildOfClass("Motor6D")
        local broken   = (not rep) or (not mainPart) or (not motor) or motor.Part0 ~= handle
        if broken then
            local item = ctMatchItem(tool)
            buildReplica(handle, skinFor((item and item.key == "Bat") and "Bat" or "Medusa"))
        end
        if broken or deep then
            for _, d in ipairs(tool:GetDescendants()) do hideNode(entry, d) end
        end
    end

    local function integrityPass(deep)
        if not enabled then return end
        watchAll()
        local bp = CT_LP:FindFirstChildOfClass("Backpack")
        if bp then for _, ch in ipairs(bp:GetChildren()) do tryRegister(ch) end end
        local chr = CT_LP.Character
        if chr then for _, ch in ipairs(chr:GetChildren()) do tryRegister(ch) end end
        for tool, entry in pairs(tracked) do
            if not tool.Parent then
                teardown(tool, false)
            else
                rebuildIfNeeded(tool, entry, deep)
            end
        end
    end

    _G.AmbitiousCustomToolsRecheck = function() pcall(integrityPass, true) end

    _G.AmbitiousSetCustomToolSkin = function(cat, key)
        if not ASSETS[key] or ASSETS[key].cat ~= cat then return end
        _G.AmbitiousCustomToolSkins[cat] = key
        for tool, entry in pairs(tracked) do
            if tool.Parent and entry.cat == cat then
                local handle = tool:FindFirstChild("Handle")
                if handle then pcall(buildReplica, handle, key) end
            end
        end
        _saveCfg()
    end

    task.spawn(function()
        local n = 0
        while true do
            task.wait(0.4)
            if enabled then
                n = n + 1
                pcall(integrityPass, (n % 5) == 0)
            end
        end
    end)

    CT_LP.CharacterAdded:Connect(function()
        task.delay(0.6, function() if enabled then pcall(integrityPass, true) end end)
    end)

    _G.AmbitiousCustomTools = {
        setEnabled = function(on)
            on = on and true or false
            enabled = on
            _G.AmbitiousCustomToolsEnabled = on
            if on then
                watchAll()
                pcall(integrityPass, true)
            else
                for tool in pairs(tracked) do teardown(tool, true) end
                for _, c in pairs(pendingHandle) do pcall(function() c:Disconnect() end) end
                table.clear(pendingHandle)
                for container in pairs(watchers) do unwatch(container) end
                local char = CT_LP.Character
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            local handle = tool:FindFirstChild("Handle")
                            if handle then
                                local rep = handle:FindFirstChild("LocalReplica")
                                if rep then rep:Destroy() end
                            end
                        end
                    end
                end
                local bp = CT_LP:FindFirstChildOfClass("Backpack")
                if bp then
                    for _, tool in ipairs(bp:GetChildren()) do
                        if tool:IsA("Tool") then
                            local handle = tool:FindFirstChild("Handle")
                            if handle then
                                local rep = handle:FindFirstChild("LocalReplica")
                                if rep then rep:Destroy() end
                            end
                        end
                    end
                end
            end
        end,
        isEnabled = function() return enabled end,
    }
end

-- ============================================================
-- CUSTOM SOUNDS ENGINE (Standalone)
-- ============================================================
do
    local SOUNDS = {
        Medusa = { id = "rbxassetid://3102797479", doublePlay = true, delay = 0.5 },
    }

    local hooked = setmetatable({}, { __mode = "k" })

    local enabled       = false
    local tracked       = setmetatable({}, { __mode = "k" })
    local watchers      = setmetatable({}, { __mode = "k" })
    local pendingHandle = setmetatable({}, { __mode = "k" })
    local teardown

    local function playCustom(entry)
        local cs = entry.sound
        if not cs or not cs.Parent then return end
        local d = entry.data
        if entry.timer then            pcall(task.cancel, entry.timer)
            entry.timer = nil
        end
        pcall(function()
            cs:Stop()
            cs.TimePosition = d.skip or 0
            cs.Volume = 1
            cs:Play()
        end)
        if d.doublePlay and d.delay then
            entry.timer = task.delay(d.delay, function()
                entry.timer = nil
                if not enabled then return end
                if cs and cs.Parent then
                    pcall(function()
                        cs:Stop()
                        cs.TimePosition = d.skip or 0
                        cs.Volume = 1
                        cs:Play()
                    end)
                end
            end)
        end
    end

    local function hookSound(entry, snd)
        if not snd:IsA("Sound") then return end
        if snd.Name == "CustomSound" then return end
        if hooked[snd] then return end
        if entry.muted[snd] ~= nil then return end
        entry.muted[snd] = snd.Volume
        hooked[snd] = true
        local function trigger()
            if not enabled then return end
            if snd.Playing or snd.TimePosition > 0 then
                pcall(function()
                    snd.Volume = 0
                    snd:Stop()
                end)
                playCustom(entry)
            end
        end
        local c1 = snd:GetPropertyChangedSignal("Playing"):Connect(trigger)
        local c2 = snd:GetPropertyChangedSignal("TimePosition"):Connect(trigger)
        table.insert(entry.conns, c1)
        table.insert(entry.conns, c2)
        local c3
        c3 = snd.AncestryChanged:Connect(function(_, parent)
            if parent then return end
            pcall(function() c1:Disconnect() end)
            pcall(function() c2:Disconnect() end)
            pcall(function() c3:Disconnect() end)
            hooked[snd] = nil
            entry.muted[snd] = nil
            if entry.timer then
                pcall(task.cancel, entry.timer)
                entry.timer = nil
            end
        end)
        table.insert(entry.conns, c3)
        if snd.Playing then trigger() end
    end

    local function setupTool(tool)
        if tracked[tool] then return end
        local item = ctMatchItem(tool)
        if not item then return end
        local data = SOUNDS[item.key]
        if not data then return end
        local handle = tool:FindFirstChild("Handle")
        if not handle then
            if pendingHandle[tool] then return end
            local c
            c = tool.ChildAdded:Connect(function(child)
                if child.Name == "Handle" then
                    pcall(function() c:Disconnect() end)
                    pendingHandle[tool] = nil
                    if enabled then setupTool(tool) end
                end
            end)
            pendingHandle[tool] = c
            return
        end
        local old = handle:FindFirstChild("CustomSound")
        if old then pcall(function() old:Destroy() end) end
        local cs = Instance.new("Sound")
        cs.Name        = "CustomSound"
        cs.SoundId     = data.id
        cs.Volume      = 1
        cs.Looped      = false
        cs.RollOffMode = Enum.RollOffMode.Inverse
        cs.MaxDistance = 1000
        cs.MinDistance = 1000
        cs.Parent      = handle
        local entry = { sound = cs, data = data, conns = {}, muted = {} }
        tracked[tool] = entry
        for _, d in ipairs(tool:GetDescendants()) do hookSound(entry, d) end
        table.insert(entry.conns, tool.DescendantAdded:Connect(function(d)
            if tracked[tool] then hookSound(entry, d) end
        end))
        table.insert(entry.conns, tool.AncestryChanged:Connect(function(_, parent)
            if not parent then teardown(tool) end
        end))
    end

    function teardown(tool)
        local entry = tracked[tool]
        if not entry then return end
        if entry.timer then
            pcall(task.cancel, entry.timer)
            entry.timer = nil
        end
        for _, conn in ipairs(entry.conns) do pcall(function() conn:Disconnect() end) end
        if entry.sound then pcall(function() entry.sound:Destroy() end) end
        for snd, vol in pairs(entry.muted) do
            hooked[snd] = nil
            if snd and snd.Parent then pcall(function() snd.Volume = vol end) end
        end
        tracked[tool] = nil
    end

    local function tryRegister(inst)
        if not enabled then return end
        if inst:IsA("Tool") and ctMatchItem(inst) then setupTool(inst) end
    end

    local function unwatch(container)
        local conns = watchers[container]
        if not conns then return end
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        watchers[container] = nil
    end

    local function watch(container)
        if not container or watchers[container] then return end
        watchers[container] = { container.ChildAdded:Connect(tryRegister) }
        for _, child in ipairs(container:GetChildren()) do tryRegister(child) end
    end

    local function watchAll()
        watch(CT_LP:FindFirstChildOfClass("Backpack"))
        watch(CT_LP.Character)
    end

    CT_LP.ChildAdded:Connect(function(child)
        if enabled and child:IsA("Backpack") then watch(child) end
    end)

    CT_LP.CharacterAdded:Connect(function(char)
        for tool in pairs(tracked) do teardown(tool) end
        for _, c in pairs(pendingHandle) do pcall(function() c:Disconnect() end) end
        table.clear(pendingHandle)
        for container in pairs(watchers) do unwatch(container) end
        if not enabled then return end
        watch(char)
        task.defer(function()
            if enabled then watchAll() end
        end)
    end)

    table.insert(CT_JANITORS, function()
        for tool in pairs(tracked) do
            if not tool.Parent then teardown(tool) end
        end
        for tool, c in pairs(pendingHandle) do
            if not tool.Parent then
                pcall(function() c:Disconnect() end)
                pendingHandle[tool] = nil
            end
        end
        for container in pairs(watchers) do
            if not container.Parent then unwatch(container) end
        end
    end)

    _G.AmbitiousCustomSounds = {
        setEnabled = function(on)
            on = on and true or false
            enabled = on
            _G.AmbitiousCustomSoundsEnabled = on
            if on then
                watchAll()
            else
                for tool in pairs(tracked) do teardown(tool) end
                for _, c in pairs(pendingHandle) do pcall(function() c:Disconnect() end) end
                table.clear(pendingHandle)
                for container in pairs(watchers) do unwatch(container) end
                local char = CT_LP.Character
                if char then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            local handle = tool:FindFirstChild("Handle")
                            if handle then
                                local cs = handle:FindFirstChild("CustomSound")
                                if cs then cs:Destroy() end
                            end
                        end
                    end
                end
                local bp = CT_LP:FindFirstChildOfClass("Backpack")
                if bp then
                    for _, tool in ipairs(bp:GetChildren()) do
                        if tool:IsA("Tool") then
                            local handle = tool:FindFirstChild("Handle")
                            if handle then
                                local cs = handle:FindFirstChild("CustomSound")
                                if cs then cs:Destroy() end
                            end
                        end
                    end
                end
            end
        end,
        isEnabled = function() return enabled end,
    }
end

-- =============================================================================
-- [SHINY GRAPHICS - STANDALONE MODULE]
-- =============================================================================
_G.AceShinyGraphics = _G.AceShinyGraphics or {
    shinyEnabled = false,
    runtimeOn = false,
    shinyConns = {},
    shinyOriginals = {},
}

local aceShinyGraphics = _G.AceShinyGraphics

do
    local shinyConns = aceShinyGraphics.shinyConns or {}
    for _, shinyConn in ipairs(shinyConns) do
        pcall(function() shinyConn:Disconnect() end)
    end
end

aceShinyGraphics.shinyConns = {}
aceShinyGraphics.shinyOriginals = aceShinyGraphics.shinyOriginals or {}
aceShinyGraphics.runtimeOn = false
aceShinyGraphics.shinyEnabled = false

local function aceShinySetupListener(arg)
    pcall(function()
        if arg:IsA("BasePart") then
            aceShinyGraphics.shinyOriginals[arg] = aceShinyGraphics.shinyOriginals[arg] or {
                Material = arg.Material,
                Reflectance = arg.Reflectance,
                CastShadow = arg.CastShadow,
            }
            arg.Material = Enum.Material.SmoothPlastic
            arg.Reflectance = 0.75
            arg.CastShadow = false
        end
    end)
end

local function aceShinyProcessInput(className, name)
    local instance = Lighting:FindFirstChild(name)
    if instance and not instance:IsA(className) then
        pcall(function() instance:Destroy() end)
        instance = nil
    end
    if not instance then
        instance = Instance.new(className)
        instance.Name = name
        instance.Parent = Lighting
    end
    return instance
end

local function aceShinyCreateEffects()
    local bloom = aceShinyProcessInput("BloomEffect", "AceShinyBloom")
    bloom.Intensity = 1.6
    bloom.Size = 52
    bloom.Threshold = 0.75
    bloom.Enabled = true
    local sunRays = aceShinyProcessInput("SunRaysEffect", "AceShinySunRays")
    sunRays.Intensity = 0.55
    sunRays.Spread = 1
    sunRays.Enabled = true
    local colorCorrection = aceShinyProcessInput("ColorCorrectionEffect", "AceShinyColorCorrection")
    colorCorrection.Saturation = 0.9
    colorCorrection.Contrast = 0.22
    colorCorrection.Brightness = 0.07
    colorCorrection.Enabled = true
end

local function enableShinyGraphics()
    aceShinyGraphics.shinyEnabled = true
    if aceShinyGraphics.runtimeOn then
        pcall(aceShinyCreateEffects)
        return
    end
    aceShinyGraphics.runtimeOn = true
    for _, descendant in ipairs(workspace:GetDescendants()) do
        aceShinySetupListener(descendant)
    end
    for _, shinyConn in ipairs(aceShinyGraphics.shinyConns) do
        pcall(function() shinyConn:Disconnect() end)
    end
    aceShinyGraphics.shinyConns = {}
    table.insert(aceShinyGraphics.shinyConns, workspace.DescendantAdded:Connect(function(descendant)
        if aceShinyGraphics.shinyEnabled then
            aceShinySetupListener(descendant)
        end
    end))
    pcall(aceShinyCreateEffects)
end

local function disableShinyGraphics()
    aceShinyGraphics.shinyEnabled = false
    aceShinyGraphics.runtimeOn = false
    for _, shinyConn in ipairs(aceShinyGraphics.shinyConns) do
        pcall(function() shinyConn:Disconnect() end)
    end
    aceShinyGraphics.shinyConns = {}
    for k, shinyOriginal in pairs(aceShinyGraphics.shinyOriginals) do
        pcall(function()
            k.Material = shinyOriginal.Material
            k.Reflectance = shinyOriginal.Reflectance
            k.CastShadow = shinyOriginal.CastShadow
        end)
    end
    aceShinyGraphics.shinyOriginals = {}
    for _, loopItem in ipairs({ "AceShinyBloom", "AceShinySunRays", "AceShinyColorCorrection" }) do
        local item2 = Lighting:FindFirstChild(loopItem)
        if item2 then
            pcall(function() item2:Destroy() end)
        end
    end
end

_G.ShinyGraphics = {
    Enable = enableShinyGraphics,
    Disable = disableShinyGraphics,
    Toggle = function()
        if aceShinyGraphics.shinyEnabled then
            disableShinyGraphics()
            return false
        else
            enableShinyGraphics()
            return true
        end
    end,
    IsEnabled = function()
        return aceShinyGraphics.shinyEnabled == true
    end,
}

-- ============================================================
-- REST OF THE ORIGINAL SCRIPT
-- ============================================================
local function _getFileFn(name)
    local direct = rawget(_G, name)
    if type(direct) == "function" then return direct end
    if syn and type(syn[name]) == "function" then return syn[name] end
    if fluxus and type(fluxus[name]) == "function" then return fluxus[name] end
    if getgenv then
        local env = getgenv()
        if type(env[name]) == "function" then return env[name] end
    end
end
local _ace_readfile = _getFileFn("readfile")
local _ace_writefile = _getFileFn("writefile")
local _ace_delfile = _getFileFn("delfile")
local _ace_isfile = _getFileFn("isfile")
if type(_ace_isfile) ~= "function" then
    _ace_isfile = function(path)
        if type(_ace_readfile) ~= "function" then return false end
        local ok, result = pcall(_ace_readfile, path)
        return ok and type(result) == "string"
    end
end
local canSaveConfig = (type(_ace_readfile) == "function" and type(_ace_writefile) == "function")

local function refreshFileApis()
    if type(_ace_readfile) ~= "function" then _ace_readfile = _getFileFn("readfile") end
    if type(_ace_writefile) ~= "function" then _ace_writefile = _getFileFn("writefile") end
    if type(_ace_delfile) ~= "function" then _ace_delfile = _getFileFn("delfile") end
    if type(_ace_isfile) ~= "function" then
        _ace_isfile = _getFileFn("isfile")
        if type(_ace_isfile) ~= "function" then
            _ace_isfile = function(path)
                if type(_ace_readfile) ~= "function" then return false end
                local ok, result = pcall(_ace_readfile, path)
                return ok and type(result) == "string"
            end
        end
    end
    canSaveConfig = (type(_ace_readfile) == "function" and type(_ace_writefile) == "function")
    return canSaveConfig
end

local function loadDedicatedButtonPositions()
    refreshFileApis()
    if not canSaveConfig then return end
    local ok, raw = pcall(_ace_readfile, BUTTON_POS_FILE)
    if not ok or type(raw) ~= "string" or raw == "" then return end
    local decodedOk, data = pcall(function() return HS:JSONDecode(raw) end)
    if decodedOk and type(data) == "table" then
        local positions = data.positions or data
        if type(positions) == "table" then
            if tonumber(data.version) == BUTTON_LAYOUT_VERSION then
                savedButtonPositions = positions
            else savedButtonPositions = {} end
        end
    end
end

local function saveDedicatedButtonPositions()
    refreshFileApis()
    if not canSaveConfig then return false end
    if not savedButtonPositions then savedButtonPositions = {} end
    local ok, raw = pcall(function()
        return HS:JSONEncode({version = BUTTON_LAYOUT_VERSION, savedAt = os.time(), positions = savedButtonPositions})
    end)
    if not ok then return false end
    local wrote = pcall(_ace_writefile, BUTTON_POS_FILE, raw)
    if not wrote then return false end
    local verified, check = pcall(_ace_readfile, BUTTON_POS_FILE)
    return verified and check == raw
end

local _autoSaveQueued = false
local _autoSaveSerial = 0
local _isBuildingGui = true

_G._KZAXTabPosition = _G._KZAXTabPosition or "Up"
function _G.KZAXValidTabPosition(v)
    if v == "Up" or v == "Bottom" or v == "Left" or v == "Right" then return v end
    return "Up"
end

_G._KZAXJumpMode = _G._KZAXJumpMode or "HOLD"

_G.Lust = _G.Lust or {}
_G.Lust.Connections = {aimbot = nil, bypass = nil, autoLeft = nil, autoRight = nil,
    dropBrainrot = nil, antiRagdoll = nil, infJump = nil, autoTPDown = nil, enemySpeed = nil,
    movement = nil, stepped = nil, stretch = nil, stretchFov = nil, antiLagDesc = nil, esp = nil,
    batCounter = nil, medusa = {}, steal = nil, progress = nil, bodyLock = nil}
_G.Lust.Active = {autoBat = false, bypass = false, autoLeft = false, autoRight = false,
    antiRagdoll = false, jump = false, medusa = false, batCounter = false, autoTPDown = false,
    antiLag = false, antiDie = false, stretch = false, esp = false, steal = false, bodyLock = false}
_G.Lust.SafeModeLocked = false
_G.Lust.OriginalOutfit = {shirt = nil, pants = nil}
_G.Lust.OriginalAccessories = {}

local function _getOrMakeLV(hrp)
    local lv = hrp:FindFirstChild("_RHSpeedLV")
    local att = hrp:FindFirstChild("RootAttachment")
    if not att then att = Instance.new("Attachment"); att.Name = "RootAttachment"; att.Parent = hrp end
    if not lv then lv = Instance.new("LinearVelocity"); lv.Name = "_RHSpeedLV"; lv.Parent = hrp end
    lv.Attachment0 = att
    lv.RelativeTo = Enum.ActuatorRelativeTo.World
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
    lv.PrimaryTangentAxis = Vector3.new(1, 0, 0)
    lv.SecondaryTangentAxis = Vector3.new(0, 0, 1)
    lv.PlaneVelocity = Vector2.new(0, 0)
    lv.MaxForce = math.huge
    return lv
end
local function _speedLVSet(hrp, x, z) local lv = _getOrMakeLV(hrp); lv.PlaneVelocity = Vector2.new(x, z) end
local function _speedLVClear(hrp) local lv = hrp:FindFirstChild("_RHSpeedLV"); if lv then lv:Destroy() end end

function _G.Lust.StopAll()
    for _, conn in pairs(_G.Lust.Connections) do
        if type(conn) == "RBXScriptConnection" then pcall(function() conn:Disconnect() end)
        elseif type(conn) == "table" then
            for _, c in ipairs(conn) do if type(c) == "RBXScriptConnection" then pcall(function() c:Disconnect() end) end end
        end
    end
    for k in pairs(_G.Lust.Connections) do
        if type(_G.Lust.Connections[k]) == "table" then _G.Lust.Connections[k] = {} else _G.Lust.Connections[k] = nil end
    end
    for k in pairs(_G.Lust.Active) do _G.Lust.Active[k] = false end
    _G.Lust.SafeModeLocked = false
end

NS = 59.5; CS = 28.8; LAGGER_SPEED_1 = 29; LAGGER_SPEED_2 = 15
MEDUSA_COOLDOWN = 25; BAT_AIMBOT_SPEED = 58; BYPASS_AIMBOT_SPEED = 57
MOBILE_PANEL_WIDTH = 250; MOBILE_PANEL_HEIGHT = 390
BUTTON_LAYOUT_VERSION = 5; BAT_V2_HIT_DIST = 4.5
_isDraggingButton = false
speedMode = false; antiRagdollEnabled = false; jumpEnabled = false
laggerToggled = false; laggerLevel = 1
medusaCounterEnabled = false; batCounterEnabled = false
autoLeftEnabled = false; autoRightEnabled = false; autoBatEnabled = false
bypassToggled = false; antiDesyncAutoSwingEnabled = true
_G.AceAntiDesyncAimbotOn = false
dropMode = 1; antiLagEnabled = false; removeAccessoriesEnabled = false; vizFpsBoosterEnabled = false
stretchEnabled = false; povEnabled = false; uiLocked = false; uiScaleValue = 100
antiDieEnabled = false
_antiDieConn = nil; _antiDieHealthConn = nil; _antiDieStateConn = nil
buttonScaleValue = 0.80; espEnabled = false
CONFIG = { AUTO_STEAL_ENABLED = false, STEAL_RANGE = 60 }

stealBarMatchEnabled = false
setStealBarMatchVisual = nil

bodyLockEnabled = false
bodyLockRadius = 15
bodyLockConn = nil
setBodyLockVisual = nil
bodyLockRadiusBox = nil

function getNearestBodyLockTarget()
    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local nearest = nil
    local shortest = math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tr = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tr and hum and hum.Health > 0 then
                local d = (tr.Position - root.Position).Magnitude
                if d <= bodyLockRadius and d < shortest then
                    shortest = d
                    nearest = plr
                end
            end
        end
    end
    return nearest
end

function startBodyLock()
    if bodyLockConn then return end
    bodyLockEnabled = true
    _G.Lust.Active.bodyLock = true
    bodyLockConn = RunService.Heartbeat:Connect(function()
        if not bodyLockEnabled then return end
        local character = LP.Character
        local myRoot = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not myRoot or not humanoid or humanoid.Health <= 0 then return end
        local target = getNearestBodyLockTarget()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            local myPos = myRoot.Position
            local offset = Vector3.new(targetPos.X, myPos.Y, targetPos.Z) - myPos
            if offset.Magnitude > 0.1 then
                humanoid.AutoRotate = false
                local lookDir = offset.Unit
                local currentDir = myRoot.CFrame.LookVector
                local cross = currentDir:Cross(lookDir)
                local currentVel = myRoot.AssemblyAngularVelocity
                myRoot.AssemblyAngularVelocity = Vector3.new(currentVel.X, cross.Y * 40, currentVel.Z)
            end
        else
            humanoid.AutoRotate = true
        end
    end)
    _G.Lust.Connections.bodyLock = bodyLockConn
end

function stopBodyLock()
    bodyLockEnabled = false
    _G.Lust.Active.bodyLock = false
    if bodyLockConn then bodyLockConn:Disconnect(); bodyLockConn = nil end
    _G.Lust.Connections.bodyLock = nil
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.AutoRotate = true end
end

function setBodyLock(on)
    bodyLockEnabled = on
    if on then startBodyLock() else stopBodyLock() end
    if setBodyLockVisual then setBodyLockVisual(on) end
    pcall(saveAllSettings)
end

local Steal = {AutoStealEnabled = false, StealRadius = CONFIG.STEAL_RANGE, StealDuration = 1.3, StealDelay = 0.25, Data = {}}
local isStealing = false
local autoGrabSetDelayRadius = 9; local autoGrabStopTime = 0.96; local autoGrabStopEnabled = true
local stealConnection = nil

local function isMyPlotByName(plotName)
    local plots = workspace:FindFirstChild("Plots"); if not plots then return false end
    local plot = plots:FindFirstChild(plotName); if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yb = sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled == true end
    end
    return false
end

local function findNearestPrompt()
    local char = LP.Character; if not char then return nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return nil, nil end
    local plots = workspace:FindFirstChild("Plots"); if not plots then return nil, nil end
    local nearestPrompt, nearestDist, nearestName = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local pods = plot:FindFirstChild("AnimalPodiums"); if not pods then continue end
        for _, pod in ipairs(pods:GetChildren()) do
            pcall(function()
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - root.Position).Magnitude
                    if dist < nearestDist and dist <= Steal.StealRadius then
                        local att = spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _, child in ipairs(att:GetChildren()) do
                                if child:IsA("ProximityPrompt") and child.ActionText and child.ActionText:find("Steal") then
                                    nearestPrompt = child; nearestDist = dist; nearestName = pod.Name; break
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
    return nearestPrompt, nearestName
end

local function executeSteal(prompt, podName)
    if isStealing then return end
    if not Steal.Data[prompt] then
        Steal.Data[prompt] = {hold = {}, trigger = {}, ready = true}
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(Steal.Data[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(Steal.Data[prompt].trigger, c.Function) end
                end
            end
        end)
    end
    local data = Steal.Data[prompt]
    if not data.ready then return end
    data.ready = false; isStealing = true
    if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
    if progressPct then progressPct.Text = "0%" end
    task.spawn(function()
        for _, f in ipairs(data.hold) do task.spawn(f) end
        local startTime = tick(); local duration = Steal.StealDuration; local promptFired = false
        if autoGrabStopEnabled then
            while isStealing and Steal.AutoStealEnabled do
                local elapsed = tick() - startTime
                if elapsed >= autoGrabStopTime then break end
                local progress = math.clamp(elapsed / duration, 0, 1)
                if progressFill then progressFill.Size = UDim2.new(progress, 0, 1, 0) end
                if progressPct then progressPct.Text = math.floor(progress * 100) .. "%" end
                if not prompt.Parent or not prompt.Parent.Parent then break end
                local char = LP.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - prompt.Parent.Parent.Position).Magnitude > Steal.StealRadius then break end
                task.wait()
            end
            local stopProgress = math.clamp(autoGrabStopTime / duration, 0, 1)
            if progressFill then progressFill.Size = UDim2.new(stopProgress, 0, 1, 0) end
            if progressPct then progressPct.Text = math.floor(stopProgress * 100) .. "%" end
            local phase2Timeout = math.max(2.99 - autoGrabStopTime - math.max(duration - autoGrabStopTime, 0), 0.05)
            local phase2Start = tick()
            while isStealing and Steal.AutoStealEnabled do
                if tick() - phase2Start >= phase2Timeout then
                    if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
                    if progressPct then progressPct.Text = "0%" end
                    data.ready = true; isStealing = false
                    task.wait()
                    local newPrompt, newName = findNearestPrompt()
                    if newPrompt then executeSteal(newPrompt, newName) end
                    return
                end
                if not prompt.Parent or not prompt.Parent.Parent then
                    isStealing = false
                    if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
                    if progressPct then progressPct.Text = "0%" end
                    data.ready = true; return
                end
                local char = LP.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - prompt.Parent.Parent.Position).Magnitude
                    if dist <= autoGrabSetDelayRadius then break
                    elseif dist > Steal.StealRadius then
                        isStealing = false
                        if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
                        if progressPct then progressPct.Text = "0%" end
                        data.ready = true; return
                    end
                end
                task.wait()
            end
            if isStealing and Steal.AutoStealEnabled then
                local fillStart = tick(); local fillDuration = math.max(duration - autoGrabStopTime, 0.05)
                while true do
                    local fp = math.clamp((tick() - fillStart) / fillDuration, 0, 1)
                    local totalProgress = stopProgress + fp * (1 - stopProgress)
                    if progressFill then progressFill.Size = UDim2.new(totalProgress, 0, 1, 0) end
                    if progressPct then progressPct.Text = math.floor(totalProgress * 100) .. "%" end
                    if fp >= 1 and not promptFired then
                        promptFired = true
                        pcall(function()
                            for _, f in ipairs(data.trigger) do task.spawn(f) end
                            local remote = ReplicatedStorage:FindFirstChild("StealAnimal")
                            if remote and podName then remote:FireServer(podName) end
                            if prompt then prompt:Fire() end
                        end)
                        break
                    end
                    task.wait()
                end
            end
        else
            while isStealing and Steal.AutoStealEnabled do
                local elapsed = tick() - startTime
                local progress = math.clamp(elapsed / duration, 0, 1)
                if progressFill then progressFill.Size = UDim2.new(progress, 0, 1, 0) end
                if progressPct then progressPct.Text = math.floor(progress * 100) .. "%" end
                if not prompt.Parent or not prompt.Parent.Parent then break end
                local char = LP.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - prompt.Parent.Parent.Position).Magnitude > Steal.StealRadius then break end
                if elapsed >= duration and not promptFired then
                    promptFired = true
                    pcall(function()
                        for _, f in ipairs(data.trigger) do task.spawn(f) end
                        local remote = ReplicatedStorage:FindFirstChild("StealAnimal")
                        if remote and podName then remote:FireServer(podName) end
                        if prompt then prompt:Fire() end
                    end)
                    break
                end
                task.wait()
            end
        end
        if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
        if progressPct then progressPct.Text = "0%" end
        data.ready = true; isStealing = false
    end)
end

function startAutoStealSemi()
    if stealConnection then return end
    Steal.StealRadius = CONFIG.STEAL_RANGE
    Steal.AutoStealEnabled = true
    stealConnection = RunService.Heartbeat:Connect(function()
        if not Steal.AutoStealEnabled or isStealing then return end
        local p, n = findNearestPrompt()
        if p then executeSteal(p, n) end
    end)
    _G.Lust.Connections.steal = stealConnection
    _G.Lust.Active.steal = true
end

function stopAutoSteal()
    if stealConnection then
        stealConnection:Disconnect(); stealConnection = nil
        _G.Lust.Connections.steal = nil; _G.Lust.Active.steal = false
    end
    isStealing = false; Steal.AutoStealEnabled = false
    if progressFill then TS:Create(progressFill, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 1, 0)}):Play() end
    if progressPct then progressPct.Text = "0%" end
end

currentSkyTheme = "Off"; CANDY_SKY_TAG = "LustHubSkyTheme"; candyOriginalLighting = nil
savedProgressBarPos = nil; savedButtonPositions = {}
hideButtonsEnabled = false; setHideButtonsVisual = nil
loadDedicatedButtonPositions()
savedMobilePanelPos = nil; savedMainGuiPos = nil; instaResetFloatingPos = nil; bypassFloatingPos = nil

animSelectorLabel = nil
unwalkSavedAnimate = nil; unwalkEnabled = false

local ACCESSORY_PACK_ORDER = {{"Off", "Off"}, {"Bleed 1", "Bleed 1"}, {"Bleed 2", "Bleed 2"}, {"Bleed 3", "Bleed 3"}}
currentAccessoryPack = "Off"; accSelectorLabel = nil
avatarCardRefs = {}
local refreshAccessoryCards

-- ============================================================
-- OUTFIT PACKS
-- ============================================================
local BLEED_PACKS = {
    ["Bleed 1"] = {accessory = 10159600649, offset = Vector3.new(0, 1, -0.2),
        headMesh = "http://www.roblox.com/asset/?id=134079402", headTexture = "http://www.roblox.com/asset/?id=133940918",
        shirt = "http://www.roblox.com/asset/?id=9683332638", pants = "http://www.roblox.com/asset/?id=93182020184041", korblox = "none",
        headlessKorblox = true},
    ["Bleed 2"] = {accessory = 1744060292, offset = Vector3.new(0, 1.3, -0.2),
        headMesh = "http://www.roblox.com/asset/?id=134079402", headTexture = "http://www.roblox.com/asset/?id=133940918",
        shirt = "http://www.roblox.com/asset/?id=9683332638", pants = "http://www.roblox.com/asset/?id=93182020184041", korblox = "none",
        headlessKorblox = true},
    ["Bleed 3"] = {accessory = 8349240186, offset = Vector3.new(0, 0.9, 0),
        headMesh = "https://assetdelivery.roblox.com/v1/asset/?id=16673245747", headTexture = nil,
        shirt = "http://www.roblox.com/asset/?id=11926549070", pants = "http://www.roblox.com/asset/?id=13189494471", korblox = "none",
        headlessKorblox = true},
}

local function saveOriginalOutfit(char)
    if not char then return end
    local shirt = char:FindFirstChildWhichIsA("Shirt"); local pants = char:FindFirstChildWhichIsA("Pants")
    _G.Lust.OriginalOutfit.shirt = shirt and shirt.ShirtTemplate or nil
    _G.Lust.OriginalOutfit.pants = pants and pants.PantsTemplate or nil
end
local function restoreOriginalOutfit(char)
    if not char then return end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Shirt") or obj:IsA("Pants") then obj:Destroy() end
    end
    if _G.Lust.OriginalOutfit.shirt then local s = Instance.new("Shirt"); s.ShirtTemplate = _G.Lust.OriginalOutfit.shirt; s.Parent = char end
    if _G.Lust.OriginalOutfit.pants then local p = Instance.new("Pants"); p.PantsTemplate = _G.Lust.OriginalOutfit.pants; p.Parent = char end
    _G.Lust.OriginalOutfit.shirt = nil; _G.Lust.OriginalOutfit.pants = nil
end
local function clearAllOutfit(char)
    if not char then return end
    for _, obj in ipairs(char:GetChildren()) do if obj:IsA("Shirt") or obj:IsA("Pants") then obj:Destroy() end end
end
local function saveOriginalAccessories(char)
    _G.Lust.OriginalAccessories = {}
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") then table.insert(_G.Lust.OriginalAccessories, child:Clone()) end
    end
end
local function restoreOriginalAccessories(char)
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or child.Name == "AuFfitAccessory" then child:Destroy() end
    end
    for _, clone in ipairs(_G.Lust.OriginalAccessories) do
        if clone and clone.Parent == nil then local newAcc = clone:Clone(); newAcc.Parent = char end
    end
    _G.Lust.OriginalAccessories = {}
end
local function clearAllAccessories(char)
    if not char then return end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or child.Name == "AuFfitAccessory" then child:Destroy() end
        if child.Name:find("Korblox_") or child.Name:find("Headless_") then child:Destroy() end
    end
    local partsToHide = {"Head", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
    for _, partName in ipairs(partsToHide) do
        local part = char:FindFirstChild(partName)
        if part and part:IsA("BasePart") then part.Transparency = 0 end
    end
    local head = char:FindFirstChild("Head")
    if head and head:IsA("MeshPart") then head.Transparency = 0 end
end

local function applyHeadlessKorblox(char)
    if not char then return end
    pcall(function() LP.CharacterAvatarType = Enum.AvatarType.R6 end)
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        head.CanCollide = false
        head.LocalTransparencyModifier = 1
        local face = head:FindFirstChild("face")
        if face then face.Transparency = 1 end
    end
    pcall(function()
        local neck = char:FindFirstChild("Neck")
        if neck then neck.Enabled = false end
    end)
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("Accessory") then
            local w = v:FindFirstChildWhichIsA("Weld") or v:FindFirstChildWhichIsA("WeldConstraint") or v:FindFirstChildWhichIsA("Motor6D")
            if w then
                local p0, p1 = w.Part0, w.Part1
                if (p0 and p0.Name == "Head") or (p1 and p1.Name == "Head") then
                    v.Parent = nil
                end
            end
        end
    end
    local rightLegConfig = {
        id = "rbxassetid://139607718",
        targetBodyPart = "RightUpperLeg",
        partsToHide = {"RightUpperLeg", "RightLowerLeg", "RightFoot"},
    }
    local targetPart = char:FindFirstChild(rightLegConfig.targetBodyPart)
    if targetPart then
        local oldAsset = char:FindFirstChild("Korblox_RightLeg")
        if oldAsset then oldAsset:Destroy() end
        for _, partName in ipairs(rightLegConfig.partsToHide) do
            local limb = char:FindFirstChild(partName)
            if limb and limb:IsA("BasePart") then limb.Transparency = 1 end
        end
        local success, objects = pcall(function() return game:GetObjects(rightLegConfig.id) end)
        if success and objects and #objects > 0 then
            local assetModel = objects[1]
            assetModel.Name = "Korblox_RightLeg"
            local mainMesh = assetModel:IsA("BasePart") and assetModel or assetModel:FindFirstChildWhichIsA("BasePart", true)
            if mainMesh then
                mainMesh.CanCollide = false
                mainMesh.CFrame = targetPart.CFrame
                local weld = Instance.new("WeldConstraint")
                weld.Part0 = targetPart
                weld.Part1 = mainMesh
                weld.Parent = mainMesh
                assetModel.Parent = char
            end
        end
    end
end

local function applyBleedOutfit(packName)
    local config = BLEED_PACKS[packName]; if not config then return false end
    local char = LP.Character; if not char then return false end
    char:WaitForChild("Head", 10); local head = char:FindFirstChild("Head"); if not head then return false end
    if config.headMesh then
        for _, d in ipairs(char:GetChildren()) do
            if d:IsA("CharacterMesh") and d.BodyPart == Enum.BodyPart.Head then pcall(function() d:Destroy() end) end
        end
        local done = false
        if head:IsA("MeshPart") then
            done = pcall(function() head.MeshId = config.headMesh; if config.headTexture then head.TextureID = config.headTexture end end)
        end
        if not done then
            local sm = head:FindFirstChildWhichIsA("SpecialMesh") or Instance.new("SpecialMesh")
            sm.Parent = head; sm.MeshType = Enum.MeshType.FileMesh; sm.MeshId = config.headMesh; sm.TextureId = config.headTexture or ""
        end
    end
    if config.shirt then
        local s = char:FindFirstChildWhichIsA("Shirt") or Instance.new("Shirt")
        s.Name = "Shirt"; s.ShirtTemplate = config.shirt; s.Parent = char
    end
    if config.pants then
        local p = char:FindFirstChildWhichIsA("Pants") or Instance.new("Pants")
        p.Name = "Pants"; p.PantsTemplate = config.pants; p.Parent = char
    end
    if config.accessory and head then
        local old = char:FindFirstChild("AuFfitAccessory"); if old then old:Destroy() end
        local objs = nil
        local ok, res = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(config.accessory)) end)
        if ok and typeof(res) == "table" and #res > 0 then objs = res
        else
            ok, res = pcall(function() return game:GetService("InsertService"):LoadAsset(config.accessory) end)
            if ok and res then objs = {res} end
        end
        if objs then
            local handle
            for _, o in ipairs(objs) do
                if o:IsA("BasePart") then handle = o; break end
                local f = o:FindFirstChildWhichIsA("BasePart", true); if f then handle = f; break end
            end
            if handle then
                local h = handle:Clone()
                h.Name = "AuFfitAccessory"; h.CanCollide = false; h.Anchored = false; h.Massless = true; h.Parent = char
                local weld = Instance.new("Weld"); weld.Part0 = head; weld.Part1 = h
                weld.C0 = CFrame.new(config.offset or Vector3.zero); weld.Parent = h
            end
            for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
        end
    end
    if config.headlessKorblox then
        applyHeadlessKorblox(char)
    end
    return true
end

local function applyAccessoryPack(packName)
    local char = LP.Character
    if not char then return false end
    if packName == "Off" then
        clearAllAccessories(char); restoreOriginalOutfit(char); restoreOriginalAccessories(char); return true
    end
    if not BLEED_PACKS[packName] then return false end
    if not _G.Lust.OriginalOutfit.shirt and not _G.Lust.OriginalOutfit.pants then saveOriginalOutfit(char) end
    if #_G.Lust.OriginalAccessories == 0 then saveOriginalAccessories(char) end
    clearAllOutfit(char); clearAllAccessories(char)
    return applyBleedOutfit(packName) == true
end

DEFAULT_KB = {
    DropBrainrot = {kb = Enum.KeyCode.X, gp = nil}, AutoLeft = {kb = Enum.KeyCode.Z, gp = nil},
    AutoRight = {kb = Enum.KeyCode.C, gp = nil}, AutoBat = {kb = Enum.KeyCode.E, gp = nil},
    TPFloor = {kb = Enum.KeyCode.F, gp = nil}, CarryToggle = {kb = Enum.KeyCode.Q, gp = nil},
    LaggerMode = {kb = Enum.KeyCode.R, gp = nil}, LaggerCarry = {kb = Enum.KeyCode.Y, gp = nil},
    ToggleGUI = {kb = Enum.KeyCode.T, gp = nil}, InstaReset = {kb = Enum.KeyCode.G, gp = nil},
    Bypass = {kb = Enum.KeyCode.N, gp = nil},
}
KB = {}
for k, v in pairs(DEFAULT_KB) do KB[k] = {kb = v.kb, gp = v.gp} end

_isResetting = false; _lastSavedJSON = nil; _isLoading = false

local CANDY_SKY_PRESETS = {
    ["Off"] = {kind = "off"},
    ["Night"] = {clock = 22, brightness = 2, ambient = {110,100,130}, outAmb = {120,110,140}, sky = {stars = 4000, moon = 18, sun = 0, moonTex = true}, atm = {dens = 0.45, color = {120,60,180}, decay = {60,20,100}, glare = 0.5, haze = 1.2}},
    ["Aurora"] = {clock = 14, brightness = 3, ambient = {150,120,150}, outAmb = {160,130,150}, atm = {dens = 0.55, color = {255,80,200}, decay = {255,20,150}, glare = 2.5, haze = 3}, clouds = {cover = 0.7, dens = 0.7, color = {255,240,250}}},
    ["Sunset"] = {clock = 17.2, brightness = 2.5, ambient = {170,120,100}, outAmb = {180,130,110}, sky = {stars = 0, sun = 25, moon = 0}, atm = {dens = 0.5, color = {255,130,60}, decay = {255,80,30}, glare = 2, haze = 2.5}, clouds = {cover = 0.55, dens = 0.55, color = {255,200,140}}},
    ["Galaxy"] = {clock = 0, brightness = 1.5, ambient = {70,60,100}, outAmb = {80,70,110}, sky = {stars = 10000, moon = 30, sun = 0}, atm = {dens = 0.15, color = {40,20,80}, decay = {20,10,50}, glare = 0.3, haze = 0.5}},
    ["Cyber"] = {clock = 21, brightness = 2.2, ambient = {90,130,170}, outAmb = {100,140,180}, sky = {stars = 2000, moon = 12}, atm = {dens = 0.4, color = {0,200,255}, decay = {150,0,255}, glare = 2, haze = 2}, clouds = {cover = 0.4, dens = 0.6, color = {100,200,255}}},
    ["Sakura"] = {clock = 11, brightness = 3.5, ambient = {170,150,160}, outAmb = {180,160,170}, sky = {sun = 8}, atm = {dens = 0.3, color = {255,200,220}, decay = {255,170,200}, glare = 1, haze = 1.5}, clouds = {cover = 0.6, dens = 0.4, color = {255,250,252}}},
    ["Pink Night"] = {clock = 23, brightness = 2.2, ambient = {120,60,110}, outAmb = {140,70,120}, sky = {stars = 5000, moon = 22, sun = 0, moonTex = true}, atm = {dens = 0.5, color = {255,80,180}, decay = {140,30,100}, glare = 0.7, haze = 1.4}, clouds = {cover = 0.3, dens = 0.5, color = {180,90,150}}},
    ["Blood Moon"] = {clock = 22.5, brightness = 1.6, ambient = {130,40,40}, outAmb = {150,50,50}, sky = {stars = 1500, moon = 28, sun = 0, moonTex = true}, atm = {dens = 0.6, color = {220,30,30}, decay = {120,10,10}, glare = 1.4, haze = 2}, clouds = {cover = 0.5, dens = 0.7, color = {120,30,30}}},
    ["Emerald Dawn"] = {clock = 6.5, brightness = 2.8, ambient = {130,170,140}, outAmb = {140,180,150}, sky = {sun = 18, moon = 0, stars = 0}, atm = {dens = 0.4, color = {80,200,140}, decay = {40,150,90}, glare = 1.8, haze = 2.2}, clouds = {cover = 0.5, dens = 0.5, color = {200,255,220}}},
    ["Volcanic"] = {clock = 19, brightness = 2, ambient = {180,80,40}, outAmb = {200,90,50}, sky = {stars = 200, sun = 12, moon = 0}, atm = {dens = 0.75, color = {255,60,0}, decay = {180,20,0}, glare = 3, haze = 3.5}, clouds = {cover = 0.8, dens = 0.9, color = {120,40,20}}},
    ["Arctic"] = {clock = 9, brightness = 3.2, ambient = {200,220,235}, outAmb = {210,230,245}, sky = {sun = 10, stars = 0, moon = 0}, atm = {dens = 0.3, color = {180,220,255}, decay = {140,200,240}, glare = 1.5, haze = 1.8}, clouds = {cover = 0.7, dens = 0.6, color = {250,253,255}}},
    ["Midnight Ocean"] = {clock = 1.5, brightness = 1.7, ambient = {60,90,130}, outAmb = {70,100,140}, sky = {stars = 6000, moon = 24, sun = 0, moonTex = true}, atm = {dens = 0.5, color = {20,60,140}, decay = {10,30,90}, glare = 0.6, haze = 1.5}},
    ["Vaporwave"] = {clock = 19.5, brightness = 2.4, ambient = {180,120,200}, outAmb = {190,130,210}, sky = {stars = 1000, moon = 14}, atm = {dens = 0.45, color = {255,100,220}, decay = {120,60,255}, glare = 2.2, haze = 2.4}, clouds = {cover = 0.5, dens = 0.55, color = {200,150,255}}},
    ["Toxic"] = {clock = 13, brightness = 2.5, ambient = {140,180,80}, outAmb = {150,190,90}, atm = {dens = 0.55, color = {100,220,40}, decay = {60,150,20}, glare = 1.8, haze = 2.6}, clouds = {cover = 0.65, dens = 0.7, color = {180,255,120}}},
    ["Solar Eclipse"] = {clock = 12, brightness = 0.9, ambient = {50,40,60}, outAmb = {60,50,70}, sky = {stars = 3500, sun = 22, moon = 0}, atm = {dens = 0.5, color = {255,140,40}, decay = {30,20,40}, glare = 2.8, haze = 1.8}},
    ["Hellscape"] = {clock = 18, brightness = 1.8, ambient = {200,60,30}, outAmb = {220,70,40}, sky = {stars = 100, sun = 30, moon = 0}, atm = {dens = 0.85, color = {255,30,0}, decay = {120,0,0}, glare = 3.5, haze = 4}, clouds = {cover = 0.95, dens = 0.95, color = {80,20,10}}},
    ["Heaven"] = {clock = 12, brightness = 4, ambient = {240,235,210}, outAmb = {250,245,220}, sky = {sun = 16, moon = 0, stars = 0}, atm = {dens = 0.25, color = {255,250,220}, decay = {255,240,200}, glare = 3, haze = 1.5}, clouds = {cover = 0.85, dens = 0.5, color = {255,255,255}}},
    ["Storm"] = {clock = 15, brightness = 1.4, ambient = {90,90,110}, outAmb = {100,100,120}, sky = {stars = 0, sun = 6, moon = 0}, atm = {dens = 0.65, color = {80,90,120}, decay = {40,50,80}, glare = 0.5, haze = 3}, clouds = {cover = 0.95, dens = 0.95, color = {60,65,80}}},
    ["Sunrise"] = {clock = 6.2, brightness = 2.8, ambient = {220,180,130}, outAmb = {230,190,140}, sky = {sun = 22, stars = 0, moon = 0}, atm = {dens = 0.45, color = {255,180,100}, decay = {255,140,80}, glare = 2.4, haze = 2.2}, clouds = {cover = 0.4, dens = 0.4, color = {255,220,180}}},
    ["Deep Space"] = {clock = 0, brightness = 1, ambient = {30,25,50}, outAmb = {40,35,60}, sky = {stars = 15000, moon = 0, sun = 0}, atm = {dens = 0.08, color = {15,5,40}, decay = {5,0,20}, glare = 0.2, haze = 0.3}},
    ["Lavender Dream"] = {clock = 18.5, brightness = 2.6, ambient = {180,160,220}, outAmb = {190,170,230}, sky = {stars = 800, moon = 16, sun = 0}, atm = {dens = 0.4, color = {200,160,255}, decay = {160,120,220}, glare = 1.4, haze = 1.8}, clouds = {cover = 0.55, dens = 0.5, color = {220,200,255}}},
    ["Inferno"] = {clock = 17.5, brightness = 2.2, ambient = {220,100,40}, outAmb = {235,110,50}, sky = {sun = 26, moon = 0, stars = 0}, atm = {dens = 0.6, color = {255,90,20}, decay = {200,40,0}, glare = 3, haze = 3.2}, clouds = {cover = 0.7, dens = 0.7, color = {200,80,40}}},
    ["Mint Sky"] = {clock = 10, brightness = 3.2, ambient = {180,230,210}, outAmb = {190,240,220}, sky = {sun = 10}, atm = {dens = 0.32, color = {150,255,210}, decay = {100,220,180}, glare = 1.6, haze = 1.6}, clouds = {cover = 0.55, dens = 0.45, color = {240,255,250}}},
}
local CANDY_SKY_ORDER = {
    {"Off","Off"}, {"Night","Night"}, {"Aurora","Aurora"}, {"Sunset","Sunset"},
    {"Galaxy","Galaxy"}, {"Cyber","Cyber"}, {"Sakura","Sakura"},
    {"Pink Night","Pink Night"}, {"Blood Moon","Blood Moon"},
    {"Emerald Dawn","Emerald Dawn"}, {"Volcanic","Volcanic"},
    {"Arctic","Arctic"}, {"Midnight Ocean","Midnight Ocean"},
    {"Vaporwave","Vaporwave"}, {"Toxic","Toxic"},
    {"Solar Eclipse","Solar Eclipse"}, {"Hellscape","Hellscape"},
    {"Heaven","Heaven"}, {"Storm","Storm"}, {"Sunrise","Sunrise"},
    {"Deep Space","Deep Space"}, {"Lavender Dream","Lavender Dream"},
    {"Inferno","Inferno"}, {"Mint Sky","Mint Sky"}
}
local function candySaveOriginalLighting()
    if candyOriginalLighting then return end
    candyOriginalLighting = {ClockTime = Lighting.ClockTime, OutdoorAmbient = Lighting.OutdoorAmbient,
        Ambient = Lighting.Ambient, Brightness = Lighting.Brightness,
        FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd, FogColor = Lighting.FogColor,
        ColorShift_Top = Lighting.ColorShift_Top, ColorShift_Bottom = Lighting.ColorShift_Bottom,
        GeographicLatitude = Lighting.GeographicLatitude, GlobalShadows = Lighting.GlobalShadows,
        LightingChildren = {}, TerrainChildren = {}}
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") or child:IsA("Atmosphere") then table.insert(candyOriginalLighting.LightingChildren, child:Clone()) end
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        for _, child in ipairs(terrain:GetChildren()) do
            if child:IsA("Clouds") then table.insert(candyOriginalLighting.TerrainChildren, child:Clone()) end
        end
    end
end
local function candyClearSky(removeAll)
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:GetAttribute(CANDY_SKY_TAG) or (removeAll and (child:IsA("Sky") or child:IsA("Atmosphere"))) then
            pcall(function() child:Destroy() end)
        end
    end
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        for _, child in ipairs(terrain:GetChildren()) do
            if child:GetAttribute(CANDY_SKY_TAG) or (removeAll and child:IsA("Clouds")) then
                pcall(function() child:Destroy() end)
            end
        end
    end
end
local function candyInstance(className, parent, props)
    local inst = Instance.new(className); inst:SetAttribute(CANDY_SKY_TAG, true)
    for k, v in pairs(props or {}) do pcall(function() inst[k] = v end) end
    inst.Parent = parent; return inst
end
local function candyColor(rgb) return Color3.fromRGB(rgb[1], rgb[2], rgb[3]) end
local function CandyApplyCustomSky(mode)
    candySaveOriginalLighting(); candyClearSky(true)
    local terrain = workspace:FindFirstChildOfClass("Terrain")
    local preset = CANDY_SKY_PRESETS[mode]
    if not preset or preset.kind == "off" then
        if candyOriginalLighting then
            for k, v in pairs(candyOriginalLighting) do
                if k ~= "LightingChildren" and k ~= "TerrainChildren" then pcall(function() Lighting[k] = v end) end
            end
            for _, child in ipairs(candyOriginalLighting.LightingChildren or {}) do child:Clone().Parent = Lighting end
            local offTerrain = workspace:FindFirstChildOfClass("Terrain")
            if offTerrain then
                for _, child in ipairs(candyOriginalLighting.TerrainChildren or {}) do child:Clone().Parent = offTerrain end
            end
        end
        currentSkyTheme = "Off"; return
    end
    Lighting.FogStart = 0; Lighting.FogEnd = 100000
    Lighting.FogColor = Color3.fromRGB(170, 70, 255)
    Lighting.ColorShift_Top = Color3.fromRGB(0,0,0)
    Lighting.ColorShift_Bottom = Color3.fromRGB(0,0,0)
    Lighting.GlobalShadows = true
    Lighting.ClockTime = preset.clock or 14; Lighting.Brightness = preset.brightness or 2
    if preset.outAmb then Lighting.OutdoorAmbient = candyColor(preset.outAmb) end
    if preset.ambient then Lighting.Ambient = candyColor(preset.ambient) end
    if preset.sky then
        local skyProps = {}
        if preset.sky.stars then skyProps.StarCount = preset.sky.stars end
        if preset.sky.moon then skyProps.MoonAngularSize = preset.sky.moon end
        if preset.sky.sun then skyProps.SunAngularSize = preset.sky.sun end
        if preset.sky.moonTex then skyProps.MoonTextureId = "rbxasset://sky/moon.jpg" end
        candyInstance("Sky", Lighting, skyProps)
    end
    if preset.atm then
        candyInstance("Atmosphere", Lighting, {Density = preset.atm.dens or 0.3, Color = candyColor(preset.atm.color),
            Decay = candyColor(preset.atm.decay), Glare = preset.atm.glare or 1, Haze = preset.atm.haze or 1})
    end
    if preset.clouds and terrain then
        candyInstance("Clouds", terrain, {Cover = preset.clouds.cover or 0.5, Density = preset.clouds.dens or 0.5,
            Color = candyColor(preset.clouds.color)})
    end
    currentSkyTheme = mode
end
local function setSkyTheme(theme)
    currentSkyTheme = theme; CandyApplyCustomSky(theme)
    if skySelectorLabel then skySelectorLabel.Text = theme end
end

medusaDebounce = false; medusaLastUsed = 0
dropActive = false; lastDropTime = 0; lastMoveDir = Vector3.new(0,0,0); origFOV = 70
local resetCooldown = false; local resetThread = nil; local currentResetChar = nil
local resetSuccessful = false; local stopResetSequence = false
local cameraLocked = false; local lockedCameraCFrame = nil

local function instaResetFast()
    if resetCooldown then return end
    resetCooldown = true; resetSuccessful = false; stopResetSequence = false; cameraLocked = false
    local character = LP.Character; if not character then resetCooldown = false return end
    local humanoid = character:FindFirstChildOfClass("Humanoid"); if not humanoid then resetCooldown = false return end
    local cam = workspace.CurrentCamera
    if cam then lockedCameraCFrame = cam.CFrame; cameraLocked = true; cam.CFrame = lockedCameraCFrame end
    currentResetChar = character
    local isRespawning = false
    resetThread = task.spawn(function()
        local attempts = 0; local maxAttempts = 40; local originalHipHeight = humanoid.HipHeight
        while character and character.Parent and humanoid and humanoid.Health > 0 and not isRespawning and not stopResetSequence do
            if LP.Character ~= character then isRespawning = true; break end
            pcall(function()
                humanoid.HipHeight = 1e30; humanoid.AutoRotate = true
                local rootPart = character:FindFirstChild("HumanoidRootPart"); if rootPart then rootPart.CanCollide = false end
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = false end
                end
            end)
            if not character or not character.Parent or not humanoid or humanoid.Health <= 0 or LP.Character ~= character then
                resetSuccessful = true; break
            end
            attempts = attempts + 1; if attempts >= maxAttempts then break end
            task.wait(0.05)
        end
        if not resetSuccessful then
            if character and character.Parent and humanoid and humanoid.Health > 0 and not isRespawning then
                pcall(function() humanoid.Health = 0 end); task.wait(0.1)
                if not character.Parent or humanoid.Health <= 0 then resetSuccessful = true end
            end
        end
        if not resetSuccessful and character and character.Parent and humanoid then
            pcall(function()
                humanoid.HipHeight = originalHipHeight
                local rootPart = character:FindFirstChild("HumanoidRootPart"); if rootPart then rootPart.CanCollide = true end
                for _, part in ipairs(character:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.CanCollide = true end
                end
            end)
        end
        cameraLocked = false; resetCooldown = false; resetThread = nil
        currentResetChar = nil; stopResetSequence = false
    end)
end
function instaReset() instaResetFast() end
LP.CharacterAdded:Connect(function()
    stopResetSequence = true
    if resetThread then task.cancel(resetThread); resetThread = nil end
    resetCooldown = false; currentResetChar = nil; cameraLocked = false
end)
task.spawn(function()
    local cam = workspace.CurrentCamera
    while true do task.wait(0.016); if cameraLocked and lockedCameraCFrame and cam then cam.CFrame = lockedCameraCFrame end end
end)

_anyKeyListening = false; _prevAutoRotate = nil
bypassConn = nil; enemySpeedConn = nil; movementLoop = nil; steppedConn = nil
alConn = nil; arConn = nil; holdInfJumpConn = nil; autoTPConn = nil
stretchConn = nil; stretchFovConn = nil; antiLagDescConn = nil
dropConnections = {}; enemySpeedLabels = {}
Conns = {autoSteal = nil, batCounter = nil, anchor = {}, progress = nil, autoLeft = nil, autoRight = nil}
keyButtonRefs = {}
progressFill = nil; progressPct = nil; progressRadLbl = nil; pbFpsLbl = nil; pbPingLbl = nil; pbRadiusLbl = nil; pbFrame = nil
speedLabel = nil; modeValLbl = nil
normalBox, carryBox, laggerBox, lagger2Box, radInput, autoTPHeightBox, uiScaleBox = nil, nil, nil, nil, nil, nil, nil
dropModeBtnRef = nil; setJumpToggleState = nil
autoBatSetVisual, autoLeftSetVisual, autoRightSetVisual, setBatCounterVisual, setMedusaVisual = nil, nil, nil, nil, nil
setAntiRagVisual, setJumpVisual, setAntiLagVisual, setAntiDieVisual, setVizFpsBoosterVisual, setAutoTPDownVisual, setLockUIVisual, setInstaGrab, bypassSetVisual = nil, nil, nil, nil, nil, nil, nil, nil, nil
setESPVIsual = nil
setShinyGraphicsVisual = nil
mobSetAutoBat, mobSetAutoLeft, mobSetAutoRight, mobSetDropBR, mobSetTpDown, mobSetCarry, mobSetLagger1, mobSetLagger2 = nil, nil, nil, nil, nil, nil, nil, nil
miniBtn, main, gui = nil, nil, nil
MobilePanel = nil
instaResetFloatingButton = nil; bypassFloatingButton = nil
showGui = nil; hideGui = nil; mainUIScale = nil
skySelectorLabel = nil; pbScale = nil

GAMEPAD_KEYS = {[Enum.KeyCode.ButtonA] = true, [Enum.KeyCode.ButtonB] = true,
    [Enum.KeyCode.ButtonX] = true, [Enum.KeyCode.ButtonY] = true,
    [Enum.KeyCode.ButtonL1] = true, [Enum.KeyCode.ButtonR1] = true,
    [Enum.KeyCode.ButtonL2] = true, [Enum.KeyCode.ButtonR2] = true,
    [Enum.KeyCode.ButtonL3] = true, [Enum.KeyCode.ButtonR3] = true,
    [Enum.KeyCode.ButtonStart] = true, [Enum.KeyCode.ButtonSelect] = true,
    [Enum.KeyCode.DPadUp] = true, [Enum.KeyCode.DPadDown] = true,
    [Enum.KeyCode.DPadLeft] = true, [Enum.KeyCode.DPadRight] = true}
MOVE_KEYS = {[Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true, [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Up] = true, [Enum.KeyCode.Left] = true, [Enum.KeyCode.Down] = true, [Enum.KeyCode.Right] = true}
local BAT_COUNTER_SLAP_LIST = {"Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap",
    "Emerald Slap", "Ruby Slap", "Dark Matter Slap", "Flame Slap",
    "Nuclear Slap", "Galaxy Slap", "Glitched Slap"}
AP = {L1 = Vector3.new(-476.48, -6.28, 92.73), L2 = Vector3.new(-483.12, -4.95, 94.80),
    L_FACE = Vector3.new(-482.25, -4.96, 92.09),
    R1 = Vector3.new(-476.16, -6.52, 25.62), R2 = Vector3.new(-483.06, -5.03, 25.48),
    R_FACE = Vector3.new(-482.06, -6.93, 35.47)}
function isGamepadInput(inp) return inp and inp.UserInputType and inp.UserInputType.Name:match("^Gamepad") ~= nil end
function isBindableInput(inp)
    if not inp or inp.KeyCode == Enum.KeyCode.Unknown then return false end
    if inp.UserInputType == Enum.UserInputType.Keyboard then return true end
    return isGamepadInput(inp) and GAMEPAD_KEYS[inp.KeyCode] == true
end
function kbMatch(entry, kc) return kc and (kc == entry.kb or (entry.gp and kc == entry.gp)) end
function resetProgressBar()
    if progressPct then progressPct.Text = "0%" end
    if progressFill then progressFill.Size = UDim2.new(0, 0, 1, 0) end
end

local function startHoldInfJump() end
function startJumpMode()
    jumpEnabled = true; _G.Lust.Active.jump = true
    if _G.InfiniteJump then
        _G.InfiniteJump.SetEnabled(true)
        _G.InfiniteJump.SetMode(_G._KZAXJumpMode or "HOLD")
    end
    if setJumpVisual then setJumpVisual(true) end
end
function stopJumpMode()
    jumpEnabled = false; _G.Lust.Active.jump = false
    if _G.InfiniteJump then _G.InfiniteJump.SetEnabled(false) end
    if setJumpVisual then setJumpVisual(false) end
end

local resetCooldown = 0
local function forceReset()
    local char = LP.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        root.Velocity = Vector3.zero; root.RotVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") then obj.Enabled = true end
            if obj:IsA("Constraint") then obj.Enabled = true end
        end
        if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum end
        local pm = LP:FindFirstChild("PlayerScripts") and LP.PlayerScripts:FindFirstChild("PlayerModule")
        local cm = pm and pm:FindFirstChild("ControlModule")
        if cm then local controls = require(cm); if controls then controls:Enable() end end
        hum.AutoRotate = true; hum.PlatformStand = false; hum.Sit = false
    end)
end
function startAntiRagdoll()
    if _G.Lust.Connections.antiRagdoll then return end
    antiRagdollEnabled = true; _G.Lust.Active.antiRagdoll = true
    _G.Lust.Connections.antiRagdoll = RunService.Heartbeat:Connect(function()
        if not antiRagdollEnabled then return end
        local char = LP.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then return end
        local state = hum:GetState()
        local ragdolled = (state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown)
        if ragdolled then
            local now = tick()
            if now - resetCooldown > 0.15 then resetCooldown = now; forceReset() end
        end
    end)
    if setAntiRagVisual then setAntiRagVisual(true) end
end
function stopAntiRagdoll()
    antiRagdollEnabled = false; _G.Lust.Active.antiRagdoll = false
    if _G.Lust.Connections.antiRagdoll then _G.Lust.Connections.antiRagdoll:Disconnect(); _G.Lust.Connections.antiRagdoll = nil end
    if setAntiRagVisual then setAntiRagVisual(false) end
end
function setAntiRag(on) if on then startAntiRagdoll() else stopAntiRagdoll() end end
autoTPDownHeight = 20; autoTPDownEnabled = false
local autoTPConn = nil

local function doAutoTPDown(force)
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not force then
        if hum.FloorMaterial ~= Enum.Material.Air then return end
        if hrp.Position.Y < autoTPDownHeight then return end
    end
    local x, y, z = hrp.Position.X, hrp.Position.Y, hrp.Position.Z
    local _, yRot, _ = hrp.CFrame:ToEulerAnglesYXZ()
    hrp.CFrame = CFrame.new(x, -7, z) * CFrame.Angles(0, yRot, 0)
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.Velocity = Vector3.zero
end

function runTPDown()
    pcall(function() doAutoTPDown(true) end)
end

function startAutoTPDown()
    if autoTPConn then task.cancel(autoTPConn); autoTPConn = nil end
    autoTPDownEnabled = true
    _G.Lust.Active.autoTPDown = true
    autoTPConn = task.spawn(function()
        while autoTPDownEnabled do
            task.wait(0.1)
            pcall(function() doAutoTPDown(false) end)
        end
    end)
    if setAutoTPDownVisual then setAutoTPDownVisual(true) end
end

function stopAutoTPDown()
    autoTPDownEnabled = false
    _G.Lust.Active.autoTPDown = false
    if autoTPConn then task.cancel(autoTPConn); autoTPConn = nil end
    if setAutoTPDownVisual then setAutoTPDownVisual(false) end
end

function setupChar(char) if antiRagdollEnabled then task.wait(0.5); startAntiRagdoll() end end
LP.CharacterAdded:Connect(setupChar)
if LP.Character then task.spawn(function() setupChar(LP.Character) end) end

local espHighlightCache = {}; local espTracerCache = {}; local espConn = nil; local _espLastRun = 0

local function clearESP()
    for plr in pairs(espHighlightCache) do pcall(function() espHighlightCache[plr]:Destroy() end) end
    for plr in pairs(espTracerCache) do
        for _, ln in ipairs(espTracerCache[plr]) do pcall(function() ln.Visible = false; ln:Remove() end) end
    end
    espHighlightCache = {}; espTracerCache = {}
end
local function makeESPTracers()
    if not (Drawing and type(Drawing.new) == "function") then return nil end
    local WHITE = Color3.fromRGB(255, 255, 255)
    local outer = Drawing.new("Line"); outer.Color = WHITE; outer.Thickness = 2.2; outer.Transparency = 0.90; outer.Visible = false
    local mid = Drawing.new("Line"); mid.Color = WHITE; mid.Thickness = 1.2; mid.Transparency = 0.74; mid.Visible = false
    local core = Drawing.new("Line"); core.Color = WHITE; core.Thickness = 0.6; core.Transparency = 0.10; core.Visible = false
    return {outer, mid, core}
end
local function updateESP()
    local now = tick()
    if now - _espLastRun < 0.03 then return end
    _espLastRun = now
    if not espEnabled then clearESP(); return end
    local myChar = LP.Character; local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position
    local myScreenPos, myOnScreen = camera:WorldToViewportPoint(myPos)
    local myVec = Vector2.new(myScreenPos.X, myScreenPos.Y)
    local currentPlayers = Players:GetPlayers()
    local plrSet = {}
    for _, p in ipairs(currentPlayers) do plrSet[p] = true end
    for plr in pairs(espHighlightCache) do
        if not plrSet[plr] then pcall(function() espHighlightCache[plr]:Destroy() end); espHighlightCache[plr] = nil end
    end
    for plr in pairs(espTracerCache) do
        if not plrSet[plr] then
            for _, ln in ipairs(espTracerCache[plr]) do pcall(function() ln.Visible = false; ln:Remove() end) end
            espTracerCache[plr] = nil
        end
    end
    for _, plr in ipairs(currentPlayers) do
        if plr == LP then continue end
        local char = plr.Character
        if not char then
            if espHighlightCache[plr] then pcall(function() espHighlightCache[plr]:Destroy() end); espHighlightCache[plr] = nil end
            if espTracerCache[plr] then
                for _, ln in ipairs(espTracerCache[plr]) do pcall(function() ln.Visible = false end) end
            end
            continue
        end
        local tRoot = char:FindFirstChild("HumanoidRootPart")
        local tHead = char:FindFirstChild("Head")
        local tHum = char:FindFirstChildOfClass("Humanoid")
        local alive = tRoot and tHead and tHum and tHum.Health > 0
        if alive then
            local hl = espHighlightCache[plr]
            if not hl or not hl.Parent or hl.Parent ~= char then
                if hl then pcall(function() hl:Destroy() end) end
                hl = Instance.new("Highlight")
                hl.Name = "LustHubESP"; hl.FillColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.72; hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0.05; hl.Adornee = char; hl.Parent = char
                espHighlightCache[plr] = hl
            end
            local lines = espTracerCache[plr]
            if not lines then lines = makeESPTracers(); espTracerCache[plr] = lines or {} end
            if lines and #lines > 0 then
                local footPos = tRoot.Position - Vector3.new(0, tHum.HipHeight + (tRoot.Size.Y / 2) + 0.5, 0)
                if tHum.RigType == Enum.HumanoidRigType.R15 then
                    local lowerTorso = char:FindFirstChild("LowerTorso")
                    if lowerTorso then
                        footPos = lowerTorso.Position - Vector3.new(0, lowerTorso.Size.Y / 2 + 1.2, 0)
                    end
                else
                    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                    if torso then
                        footPos = torso.Position - Vector3.new(0, torso.Size.Y / 2 + 1.5, 0)
                    end
                end
                local destPos = footPos
                local pos, onScreen = camera:WorldToViewportPoint(destPos)
                if onScreen and pos.Z > 0 and myOnScreen then
                    local tVec = Vector2.new(pos.X, pos.Y)
                    for _, ln in ipairs(lines) do ln.From = myVec; ln.To = tVec; ln.Visible = true end
                else
                    for _, ln in ipairs(lines) do ln.Visible = false end
                end
            end
        else
            if espHighlightCache[plr] then pcall(function() espHighlightCache[plr]:Destroy() end); espHighlightCache[plr] = nil end
            if espTracerCache[plr] then
                for _, ln in ipairs(espTracerCache[plr]) do pcall(function() ln.Visible = false end) end
            end
        end
    end
end
local function startESPLoop()
    if _G.Lust.Connections.esp then return end
    _G.Lust.Active.esp = true
    _G.Lust.Connections.esp = RunService.RenderStepped:Connect(updateESP)
end
local function stopESPLoop()
    _G.Lust.Active.esp = false
    if _G.Lust.Connections.esp then _G.Lust.Connections.esp:Disconnect(); _G.Lust.Connections.esp = nil end
    clearESP()
end
function toggleESP(on)
    espEnabled = on
    if on then startESPLoop() else stopESPLoop() end
    if setESPVIsual then setESPVIsual(on) end
end
local function getClosestTarget()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local myPos = root.Position; local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if char then
                local tRoot = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if tRoot and hum and hum.Health > 0 then
                    local dist = (tRoot.Position - myPos).Magnitude
                    if dist < minDist then minDist = dist; closest = tRoot end
                end
            end
        end
    end
    return closest
end
local function getClosestTargetBody() return getClosestTarget() end

function setupSpeedIndicator(char)
    local head = char:WaitForChild("Head", 5); if not head then return end
    local oldBB = head:FindFirstChild("LustHubSpeedIndicator"); if oldBB then oldBB:Destroy() end
    local bb = Instance.new("BillboardGui", head)
    bb.Name = "LustHubSpeedIndicator"; bb.Size = UDim2.new(0, 200, 0, 70)
    bb.StudsOffset = Vector3.new(0, 2.0, 0); bb.AlwaysOnTop = true
    local mainFrame = Instance.new("Frame", bb); mainFrame.Size = UDim2.new(1, 0, 1, 0); mainFrame.BackgroundTransparency = 1
    local titleLabel = Instance.new("TextLabel", mainFrame)
    titleLabel.Size = UDim2.new(1, 0, 0, 22); titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1; titleLabel.Text = "I LOVE KZAX!"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255); titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextScaled = true; titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    titleLabel.TextStrokeTransparency = 0; titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    local separator = Instance.new("Frame", mainFrame)
    separator.Size = UDim2.new(0.5, 0, 0, 2); separator.Position = UDim2.new(0.25, 0, 0, 24)
    separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255); separator.BackgroundTransparency = 0.3
    separator.BorderSizePixel = 0
    local grad = Instance.new("UIGradient", separator)
    grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))})
    grad.Rotation = 0
    speedLabel = Instance.new("TextLabel", mainFrame)
    speedLabel.Size = UDim2.new(1, 0, 0, 22); speedLabel.Position = UDim2.new(0, 0, 0, 30)
    speedLabel.BackgroundTransparency = 1; speedLabel.Text = "Speed: 0.0"
    speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255); speedLabel.Font = Enum.Font.GothamBold
    speedLabel.TextScaled = true; speedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    speedLabel.TextStrokeTransparency = 0; speedLabel.TextXAlignment = Enum.TextXAlignment.Center
    SpeedModule.setSpeedLabel(speedLabel)
end
function updateEnemySpeedLabels()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LP then
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid") and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local velocity = hrp.AssemblyLinearVelocity
                local speed = (Vector3.new(velocity.X, 0, velocity.Z).Magnitude)
                local label = enemySpeedLabels[player]
                if not label then
                    local head = char:FindFirstChild("Head")
                    if head then
                        local bb = Instance.new("BillboardGui", head)
                        bb.Size = UDim2.new(0, 100, 0, 25); bb.StudsOffset = Vector3.new(0, 3.5, 0)
                        bb.AlwaysOnTop = true; bb.Name = "EnemySpeedGui"
                        local textLabel = Instance.new("TextLabel", bb)
                        textLabel.Size = UDim2.new(1, 0, 1, 0); textLabel.BackgroundTransparency = 1
                        textLabel.Text = string.format("%.1f", speed)
                        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255); textLabel.Font = Enum.Font.GothamBold
                        textLabel.TextScaled = true; textLabel.TextStrokeTransparency = 0
                        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        label = textLabel; enemySpeedLabels[player] = label
                    end
                elseif label and label.Parent and label.Parent.Parent ~= char then
                    local head = char:FindFirstChild("Head"); if head then label.Parent.Parent = head end
                end
                if label then label.Text = string.format("%.1f", speed) end
            else
                local label = enemySpeedLabels[player]
                if label and label.Parent and label.Parent.Parent then label.Parent.Parent = nil end
                enemySpeedLabels[player] = nil
            end
        end
    end
    for player, label in pairs(enemySpeedLabels) do
        if not player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            if label and label.Parent and label.Parent.Parent then label.Parent.Parent = nil end
            enemySpeedLabels[player] = nil
        end
    end
end
function startEnemySpeed()
    if _G.Lust.Connections.enemySpeed then return end
    _G.Lust.Connections.enemySpeed = RunService.Heartbeat:Connect(function() updateEnemySpeedLabels() end)
end
function stopEnemySpeed()
    if _G.Lust.Connections.enemySpeed then _G.Lust.Connections.enemySpeed:Disconnect(); _G.Lust.Connections.enemySpeed = nil end
end

-- ============================================================
-- SPEED MODULE INTEGRATION
-- ============================================================
SpeedModule.setNormalSpeed(NS)
SpeedModule.setCarrySpeed(CS)
SpeedModule.setLaggerSpeed(LAGGER_SPEED_1)
SpeedModule.setLaggerCarrySpeed(LAGGER_SPEED_2)

SpeedModule.setExternalLock(function()
    return autoBatEnabled or bypassToggled or autoLeftEnabled or autoRightEnabled
end)

local function syncSpeedLegacyState()
    local st = SpeedModule.getState()
    speedMode = st.speedMode
    laggerToggled = st.laggerToggled or st.laggerCarryToggled
    laggerLevel = st.laggerCarryToggled and 2 or 1
end

SpeedModule.onModeChanged = function(state)
    syncSpeedLegacyState()
    refreshSpeedModeLabel()
    if mobSetCarry then mobSetCarry(state.speedMode) end
    if mobSetLagger1 then mobSetLagger1(state.laggerToggled and not state.laggerCarryToggled) end
    if mobSetLagger2 then mobSetLagger2(state.laggerCarryToggled) end
    pcall(saveAllSettings)
end
syncSpeedLegacyState()

function refreshSpeedModeLabel()
    local st = SpeedModule.getState()
    if modeValLbl then
        if st.laggerCarryToggled then modeValLbl.Text = "Lagger Spd 2"
        elseif st.laggerToggled then modeValLbl.Text = "Lagger Spd 1"
        elseif st.speedMode then modeValLbl.Text = "Carry Mode"
        else modeValLbl.Text = "Normal" end
    end
end

function resetMovementState()
    refreshSpeedModeLabel()
    local st = SpeedModule.getState()
    if mobSetCarry then mobSetCarry(st.speedMode) end
    if mobSetLagger1 then mobSetLagger1(st.laggerToggled and not st.laggerCarryToggled) end
    if mobSetLagger2 then mobSetLagger2(st.laggerCarryToggled) end
end

function toggleCarryMode()
    SpeedModule.toggleCarryMode()
    resetMovementState()
end

function toggleLaggerCycle()
    SpeedModule.toggleLaggerCycle()
    resetMovementState()
end

local function toggleLaggerMode()
    SpeedModule.toggleLaggerMode()
    resetMovementState()
end

local function toggleLaggerCarryMode()
    SpeedModule.toggleLaggerCarryMode()
    resetMovementState()
end

SpeedModule.start()

function stopAutoLeft()
    if _G.Lust.Connections.autoLeft then _G.Lust.Connections.autoLeft:Disconnect(); _G.Lust.Connections.autoLeft = nil end
    _G.Lust.Active.autoLeft = false; alPhase = 1
    local char = LP.Character
    if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum:Move(Vector3.zero, false) end end
    if autoLeftSetVisual then autoLeftSetVisual(false) end
    if mobSetAutoLeft then mobSetAutoLeft(false) end
end
function startAutoLeft()
    if _G.ForceStopTPBat then pcall(_G.ForceStopTPBat) end
    if _G.Lust.Connections.autoLeft then return end
    if autoRightEnabled then autoRightEnabled = false; stopAutoRight(); if autoRightSetVisual then autoRightSetVisual(false) end; if mobSetAutoRight then mobSetAutoRight(false) end end
    disableAllAimbots()
    _G.Lust.Active.autoLeft = true; alPhase = 1
    _G.Lust.Connections.autoLeft = RunService.Heartbeat:Connect(function()
        if not autoLeftEnabled then return end
        local char = LP.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local spd = NS
        if alPhase == 1 then
            local tgt = Vector3.new(AP.L1.X, root.Position.Y, AP.L1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                alPhase = 2
                local d = AP.L2 - root.Position; local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false); root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd); return
            end
            local d = AP.L1 - root.Position; local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false); root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif alPhase == 2 then
            local tgt = Vector3.new(AP.L2.X, root.Position.Y, AP.L2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false); root.AssemblyLinearVelocity = Vector3.zero
                autoLeftEnabled = false
                if _G.Lust.Connections.autoLeft then _G.Lust.Connections.autoLeft:Disconnect(); _G.Lust.Connections.autoLeft = nil end
                _G.Lust.Active.autoLeft = false; alPhase = 1
                if autoLeftSetVisual then autoLeftSetVisual(false) end
                if mobSetAutoLeft then mobSetAutoLeft(false) end
                local facePos = Vector3.new(AP.L_FACE.X, root.Position.Y, AP.L_FACE.Z)
                if (facePos - root.Position).Magnitude > 0.01 then root.CFrame = CFrame.new(root.Position, facePos) end
                return
            end
            local d = AP.L2 - root.Position; local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false); root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
    if autoLeftSetVisual then autoLeftSetVisual(true) end
    if mobSetAutoLeft then mobSetAutoLeft(true) end
end
function stopAutoRight()
    if _G.Lust.Connections.autoRight then _G.Lust.Connections.autoRight:Disconnect(); _G.Lust.Connections.autoRight = nil end
    _G.Lust.Active.autoRight = false; arPhase = 1
    local char = LP.Character
    if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum:Move(Vector3.zero, false) end end
    if autoRightSetVisual then autoRightSetVisual(false) end
    if mobSetAutoRight then mobSetAutoRight(false) end
end
function startAutoRight()
    if _G.ForceStopTPBat then pcall(_G.ForceStopTPBat) end
    if _G.Lust.Connections.autoRight then return end
    if autoLeftEnabled then autoLeftEnabled = false; stopAutoLeft(); if autoLeftSetVisual then autoLeftSetVisual(false) end; if mobSetAutoLeft then mobSetAutoLeft(false) end end
    disableAllAimbots()
    _G.Lust.Active.autoRight = true; arPhase = 1
    _G.Lust.Connections.autoRight = RunService.Heartbeat:Connect(function()
        if not autoRightEnabled then return end
        local char = LP.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end
        local spd = NS
        if arPhase == 1 then
            local tgt = Vector3.new(AP.R1.X, root.Position.Y, AP.R1.Z)
            if (tgt - root.Position).Magnitude < 1 then
                arPhase = 2
                local d = AP.R2 - root.Position; local mv = Vector3.new(d.X, 0, d.Z).Unit
                hum:Move(mv, false); root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd); return
            end
            local d = AP.R1 - root.Position; local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false); root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        elseif arPhase == 2 then
            local tgt = Vector3.new(AP.R2.X, root.Position.Y, AP.R2.Z)
            if (tgt - root.Position).Magnitude < 1 then
                hum:Move(Vector3.zero, false); root.AssemblyLinearVelocity = Vector3.zero
                autoRightEnabled = false
                if _G.Lust.Connections.autoRight then _G.Lust.Connections.autoRight:Disconnect(); _G.Lust.Connections.autoRight = nil end
                _G.Lust.Active.autoRight = false; arPhase = 1
                if autoRightSetVisual then autoRightSetVisual(false) end
                if mobSetAutoRight then mobSetAutoRight(false) end
                local facePos = Vector3.new(AP.R_FACE.X, root.Position.Y, AP.R_FACE.Z)
                if (facePos - root.Position).Magnitude > 0.01 then root.CFrame = CFrame.new(root.Position, facePos) end
                return
            end
            local d = AP.R2 - root.Position; local mv = Vector3.new(d.X, 0, d.Z).Unit
            hum:Move(mv, false); root.AssemblyLinearVelocity = Vector3.new(mv.X * spd, root.AssemblyLinearVelocity.Y, mv.Z * spd)
        end
    end)
    if autoRightSetVisual then autoRightSetVisual(true) end
    if mobSetAutoRight then mobSetAutoRight(true) end
end

-- ============================================================
-- AUTO BAT (legacy) — retained for GUI compatibility
-- ============================================================
local AUTO_BAT = {
    SPEED_NORMAL = tonumber(_G.AIMBOT_SPEED_NORMAL) or BAT_AIMBOT_SPEED or 58,
    SPEED_BYPASS = tonumber(_G.AIMBOT_SPEED_BYPASS) or 60,
    SWING_COOLDOWN = 0.08,
    AB2_SWING_CD = 0.12,
}

local _abBypassPart, _abBypassWeld = nil, nil
local _autoBatLastScan = 0
local _autoBatTarget = nil
local autoBatEquippedThisRun = false
local autoBatMode = "normal"

local function _abCleanupProxy()
    if _abBypassPart then pcall(function() _abBypassPart:Destroy() end) end
    if _abBypassWeld then pcall(function() _abBypassWeld:Destroy() end) end
    _abBypassPart, _abBypassWeld = nil, nil
end

local function _abCreateProxy()
    _abCleanupProxy()
    local c = LP.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    _abBypassPart = Instance.new("Part")
    _abBypassPart.Name = "F1BatAimbotProxy"
    _abBypassPart.Size = Vector3.new(1,1,1)
    _abBypassPart.Transparency = 1
    _abBypassPart.CanCollide = false
    _abBypassPart.Massless = true
    _abBypassPart.Parent = c
    _abBypassWeld = Instance.new("Weld")
    _abBypassWeld.Part0 = hrp
    _abBypassWeld.Part1 = _abBypassPart
    _abBypassWeld.C0 = CFrame.new(0,0,0)
    _abBypassWeld.Parent = _abBypassPart
end

resetAutoBatMotion = function()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
    end
    if _abBypassPart then _abBypassPart.AssemblyLinearVelocity = Vector3.zero end
    if hum then hum.AutoRotate = true end
end

local function getAutoBatTarget()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local now = tick()
    if now - _autoBatLastScan <= 0.1 and _autoBatTarget and _autoBatTarget.Parent then
        local hum = _autoBatTarget.Parent:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then return _autoBatTarget end
    end
    _autoBatLastScan = now
    _autoBatTarget = nil
    local closest, minDist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if tRoot and hum and hum.Health > 0 then
                local dist = (tRoot.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = tRoot
                end
            end
        end
    end
    _autoBatTarget = closest
    return _autoBatTarget
end

local _autoBatHittingCooldown = false

local function _autoBatSwing(char)
    if _autoBatHittingCooldown then return end
    _autoBatHittingCooldown = true
    task.spawn(function()
        local hum = char:FindFirstChildOfClass("Humanoid")
        local bat = char:FindFirstChildOfClass("Tool")
        if not bat then
            local bp = LP:FindFirstChild("Backpack")
            if bp then
                for _, t in ipairs(bp:GetChildren()) do
                    local n = t.Name:lower()
                    if n:find("bat") or n:find("slap") then
                        bat = t
                        break
                    end
                end
            end
        end
        if bat then
            if bat.Parent ~= char and hum then
                pcall(function() hum:EquipTool(bat) end)
                task.wait(0.05)
            end
            local remote = nil
            for _, d in ipairs(bat:GetDescendants()) do
                if d:IsA("RemoteEvent") then
                    remote = d
                    break
                end
            end
            if remote then
                pcall(function() remote:FireServer() end)
                task.wait(0.12)
                pcall(function() remote:FireServer() end)
            else
                pcall(function() bat:Activate() end)
                task.wait(0.12)
                pcall(function() bat:Activate() end)
            end
        end
        task.delay(AUTO_BAT.SWING_COOLDOWN or 0.08, function()
            _autoBatHittingCooldown = false
        end)
    end)
end

function disableAutoBat()
    autoBatEnabled = false
    autoBatEquippedThisRun = false
    if autoBatSetVisual then autoBatSetVisual(false) end
    if mobSetAutoBat then mobSetAutoBat(false) end
    if _abBypassPart then
        _abBypassPart.AssemblyLinearVelocity = Vector3.zero
    end
    _abCleanupProxy()
    local char = LP.Character
    if char then
        local hum2 = char:FindFirstChildOfClass("Humanoid")
        if hum2 then hum2.AutoRotate = true end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end
    _autoBatTarget = nil
    _G.Lust.Active.autoBat = false
    _G.AIMBOT_ENABLED = false
end

function enableAutoBat()
    if _G.ForceStopTPBat then pcall(_G.ForceStopTPBat) end
    if autoLeftEnabled then
        autoLeftEnabled = false
        if autoLeftSetVisual then autoLeftSetVisual(false) end
        if mobSetAutoLeft then mobSetAutoLeft(false) end
        stopAutoLeft()
    end
    if autoRightEnabled then
        autoRightEnabled = false
        if autoRightSetVisual then autoRightSetVisual(false) end
        if mobSetAutoRight then mobSetAutoRight(false) end
        stopAutoRight()
    end
    if bypassToggled then
        bypassToggled = false
        if bypassFloatingButton then
            local btnFrame = bypassFloatingButton:FindFirstChild("Frame")
            if btnFrame then
                TS:Create(btnFrame, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(0,0,0)}):Play()
                local lbl = btnFrame:FindFirstChild("TextLabel")
                if lbl then
                    TS:Create(lbl, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                end
            end
        end
        stopBypassAimbot()
    end
    autoBatEquippedThisRun = false
    autoBatEnabled = true
    _G.Lust.Active.autoBat = true
    _G.AIMBOT_ENABLED = true
    if autoBatSetVisual then autoBatSetVisual(true) end
    if mobSetAutoBat then mobSetAutoBat(true) end
end

RunService.Heartbeat:Connect(function()
    if not autoBatEnabled then return end
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not hum then return end
    if not _abBypassPart or _abBypassPart.Parent ~= char then
        _abCreateProxy()
    end
    if not char:FindFirstChildOfClass("Tool") then
        local bp = LP:FindFirstChildOfClass("Backpack") or LP:FindFirstChild("Backpack")
        local bpBat = bp and bp:FindFirstChild("Bat")
        if bpBat then
            pcall(function() hum:EquipTool(bpBat) end)
        end
    end
    local target = getAutoBatTarget()
    if target then
        local targetVel = target.AssemblyLinearVelocity
        local targetPos = target.Position
        local myPos = root.Position
        local predictPos = targetPos + targetVel * 0.14
        predictPos = predictPos + target.CFrame.LookVector * 0.3
        local direction = predictPos - myPos
        local flatDir = Vector3.new(direction.X, 0, direction.Z)
        if flatDir.Magnitude > 0 then
            flatDir = flatDir.Unit
        else
            flatDir = Vector3.zero
        end
        local chaseSpeed = (autoBatMode == "bypass")
            and (AUTO_BAT.SPEED_BYPASS or 60)
            or (AUTO_BAT.SPEED_NORMAL or 58)
        local desiredHeight = targetPos.Y + 3.7
        local yVel = (desiredHeight - myPos.Y) * 19.5 + targetVel.Y * 0.8
        if hum.FloorMaterial ~= Enum.Material.Air then
            yVel = math.max(yVel, 13)
        end
        yVel = math.clamp(yVel, -70, 110)
        local desiredVel = Vector3.new(flatDir.X * chaseSpeed, yVel, flatDir.Z * chaseSpeed)
        if _abBypassPart then
            _abBypassPart.AssemblyLinearVelocity = _abBypassPart.AssemblyLinearVelocity:Lerp(desiredVel, 0.8)
        end
        local speed3 = targetVel.Magnitude
        local predictTime = math.clamp(speed3 / 150, 0.05, 0.2)
        local predictedPos = targetPos + targetVel * predictTime
        local toPredict = predictedPos - myPos
        if toPredict.Magnitude > 0.1 then
            hum.AutoRotate = false
            local goalCF = CFrame.lookAt(myPos, predictedPos)
            local diffCF = root.CFrame:Inverse() * goalCF
            local rx, ry, rz = diffCF:ToEulerAnglesXYZ()
            rx = math.clamp(rx, -2.5, 2.5)
            ry = math.clamp(ry, -2.5, 2.5)
            rz = math.clamp(rz, -2.5, 2.5)
            root.AssemblyAngularVelocity = root.CFrame:VectorToWorldSpace(Vector3.new(rx * 42, ry * 42, rz * 42))
        end
        if autoBatEnabled and (targetPos - myPos).Magnitude < 6 then
            _autoBatSwing(char)
        end
    else
        hum.AutoRotate = true
        root.AssemblyAngularVelocity = Vector3.zero
        if _abBypassPart then
            _abBypassPart.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)

-- ============================================================
-- TP BAT (NEW AIMBOT) — replaces old TPBat system
-- Speed = 57
-- ACTIVATE_DISTANCE = 0.1  <-- CHANGED: was 13
-- ============================================================
do
    local TP_Players    = game:GetService("Players")
    local TP_RunService = game:GetService("RunService")
    local TP_LP         = TP_Players.LocalPlayer

    local CONFIG = {
        FOLLOW_SPEED = 57,
        ACTIVATE_DISTANCE = 0.1,   -- <-- CHANGED: was 13, now swings instantly on contact
        MIN_FOLLOW_DISTANCE = 1,
        PREDICTION_TIME = 0.22,
        PREDICT_AHEAD = 3,
        MAX_VELOCITY_CHANGE = 150,
        VELOCITY_SMOOTHING = 0.2,
        MAX_HORIZONTAL_VELOCITY = 80,
        SERVER_TICKRATE = 1/60,
        MIN_PING_COMPENSATION = 0.03,
        MAX_PING_COMPENSATION = 0.25,
        ACCELERATION_PREDICTION_WEIGHT = 0.3,
        DIRECTION_CHANGE_DETECTION_TIME = 0.12,
        QUICK_DIRECTION_CHANGE_MULTIPLIER = 1.5,
        GRAVITY = 196.2,
        AIR_CONTROL_FACTOR = 0.8,
        AERIAL_VELOCITY_DECAY = 0.95,
        MIN_AIRBORNE_TIME = 0.08,
        FALLING_SPEED_THRESHOLD = -15,
        SWING_COOLDOWN = 0.08,
        KEYBIND = Enum.KeyCode.X,
    }

    local STATE = {
        enabled = false,
        conn = nil,
        targetPlayer = nil,
        lastTargetPos = nil,
        targetVelocity = Vector3.zero,
        smoothedVelocity = Vector3.zero,
        velocityHistory = {},
        accelerationHistory = {},
        aerialVelocityHistory = {},
        verticalVelocityHistory = {},
        previousDirection = nil,
        lastDirectionChangeTime = 0,
        airborneTime = 0,
        lastYVelocity = 0,
        lastJumpTime = 0,
        lastActivationTime = 0,
        currentPing = 0.1,
        realPingMs = 0,
        previousAutoRotate = nil,
        previousHumanoid = nil,
        swingLocked = false,
        nextSwingAt = 0,
    }

    local function getAverage(list)
        if #list == 0 then return Vector3.zero end
        local sum = Vector3.zero
        for _, v in ipairs(list) do sum = sum + v end
        return sum / #list
    end

    local function addToHistory(list, value, maxSize)
        table.insert(list, value)
        if #list > maxSize then table.remove(list, 1) end
    end

    local function resetState()
        STATE.targetPlayer = nil
        STATE.lastTargetPos = nil
        STATE.targetVelocity = Vector3.zero
        STATE.smoothedVelocity = Vector3.zero
        STATE.velocityHistory = {}
        STATE.accelerationHistory = {}
        STATE.aerialVelocityHistory = {}
        STATE.verticalVelocityHistory = {}
        STATE.previousDirection = nil
        STATE.airborneTime = 0
        STATE.lastYVelocity = 0
    end

    local function findBat()
        local char = TP_LP.Character
        if not char then return nil end
        local equipped = char:FindFirstChildOfClass("Tool")
        if equipped then
            local name = equipped.Name:lower()
            if name:find("bat") or name:find("slap") then
                return equipped
            end
        end
        local backpack = TP_LP:FindFirstChildOfClass("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    local name = tool.Name:lower()
                    if name:find("bat") or name:find("slap") then
                        return tool
                    end
                end
            end
        end
        return nil
    end

    local function findNearestEnemy(myRoot)
        local nearest, nearestDist = nil, math.huge
        for _, player in ipairs(TP_Players:GetPlayers()) do
            if player ~= TP_LP and player.Character then
                local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
                if targetRoot and targetHum and targetHum.Health > 0 then
                    local dist = (targetRoot.Position - myRoot.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearest = player
                    end
                end
            end
        end
        return nearest, nearestDist
    end

    local function faceTarget(myRoot, direction)
        if direction.Magnitude < 0.01 then return end
        local cross = myRoot.CFrame.LookVector:Cross(direction.Unit)
        local angle = math.asin(math.clamp(cross.Magnitude, -1, 1))
        myRoot.AssemblyAngularVelocity = cross.Magnitude > 0.01
            and cross.Unit * angle * 80
            or Vector3.zero
    end

    local function updatePing()
        local ok, ping = pcall(function()
            return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if ok and type(ping) == "number" then
            STATE.realPingMs = math.floor(ping)
        end
        STATE.currentPing = math.clamp(
            STATE.realPingMs / 1000,
            CONFIG.MIN_PING_COMPENSATION,
            CONFIG.MAX_PING_COMPENSATION
        )
    end

    local function swingBat()
        local now = tick()
        if STATE.swingLocked or now < STATE.nextSwingAt then return end
        STATE.swingLocked = true
        STATE.nextSwingAt = now + CONFIG.SWING_COOLDOWN

        pcall(function()
            local char = TP_LP.Character
            if not char then return end

            local bat = findBat()
            if not bat then return end

            if bat.Parent ~= char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(bat) end
            end

            bat:Activate()
            local remote = bat:FindFirstChildWhichIsA("RemoteEvent")
            if remote then remote:FireServer() end
        end)

        task.delay(CONFIG.SWING_COOLDOWN, function()
            STATE.swingLocked = false
        end)
    end

    local function aimbotLoop(dt)
        CONFIG.FOLLOW_SPEED = tonumber(BYPASS_AIMBOT_SPEED) or 57
        if not STATE.enabled then return end

        local char = TP_LP.Character
        if not char then return end

        local myRoot = char:FindFirstChild("HumanoidRootPart")
        local myHum = char:FindFirstChildOfClass("Humanoid")
        if not myRoot or not myHum or myHum.Health <= 0 then return end

        myHum.AutoRotate = false

        local equippedTool = char:FindFirstChildOfClass("Tool")
        if not equippedTool then
            local bat = findBat()
            if bat and bat.Parent ~= char then
                pcall(function() myHum:EquipTool(bat) end)
            end
        end

        local target, dist = findNearestEnemy(myRoot)
        if not target or not target.Character then
            resetState()
            return
        end

        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
        if not targetRoot or not targetHum or targetHum.Health <= 0 then
            resetState()
            return
        end

        if STATE.targetPlayer ~= target then resetState() end
        STATE.targetPlayer = target

        updatePing()

        local targetPos = targetRoot.Position
        local dt_clamped = math.max(dt, 1/240)

        if STATE.lastTargetPos then
            local instantVel = (targetPos - STATE.lastTargetPos) / dt_clamped
            local accel = instantVel - STATE.targetVelocity

            if accel.Magnitude > CONFIG.MAX_VELOCITY_CHANGE then
                instantVel = STATE.targetVelocity + accel.Unit * CONFIG.MAX_VELOCITY_CHANGE
            end

            local horizontalVel = Vector3.new(instantVel.X, 0, instantVel.Z)
            if horizontalVel.Magnitude > CONFIG.MAX_HORIZONTAL_VELOCITY then
                horizontalVel = horizontalVel.Unit * CONFIG.MAX_HORIZONTAL_VELOCITY
                instantVel = Vector3.new(horizontalVel.X, instantVel.Y, horizontalVel.Z)
            end

            addToHistory(STATE.accelerationHistory, (instantVel - STATE.targetVelocity) / dt_clamped, 4)
            addToHistory(STATE.velocityHistory, instantVel, 8)
            addToHistory(STATE.verticalVelocityHistory, instantVel.Y, 5)

            STATE.targetVelocity = instantVel
            STATE.smoothedVelocity = STATE.smoothedVelocity:Lerp(instantVel, CONFIG.VELOCITY_SMOOTHING)
        end
        STATE.lastTargetPos = targetPos

        local isAirborne = targetHum.FloorMaterial == Enum.Material.Air
        STATE.airborneTime = isAirborne and (STATE.airborneTime + dt_clamped) or 0

        if isAirborne and STATE.airborneTime >= CONFIG.MIN_AIRBORNE_TIME then
            addToHistory(STATE.aerialVelocityHistory, STATE.targetVelocity, 6)
        elseif not isAirborne then
            STATE.aerialVelocityHistory = {}
        end

        local smoothedVel = STATE.smoothedVelocity
        if isAirborne and #STATE.aerialVelocityHistory > 0 then
            local avgAerial = getAverage(STATE.aerialVelocityHistory)
            smoothedVel = Vector3.new(avgAerial.X, STATE.targetVelocity.Y, avgAerial.Z) * CONFIG.AIR_CONTROL_FACTOR
        end

        local isQuickTurn = false
        local horizontalTargetVel = Vector3.new(STATE.targetVelocity.X, 0, STATE.targetVelocity.Z)
        if horizontalTargetVel.Magnitude > 5 then
            local newDir = horizontalTargetVel.Unit
            if STATE.previousDirection and STATE.previousDirection:Dot(newDir) < 0.5 then
                isQuickTurn = (tick() - STATE.lastDirectionChangeTime) < CONFIG.DIRECTION_CHANGE_DETECTION_TIME
                STATE.lastDirectionChangeTime = tick()
            end
            STATE.previousDirection = newDir
        end

        local serverDelay = STATE.currentPing + CONFIG.SERVER_TICKRATE
        local adjustedDelay = isQuickTurn
            and (serverDelay * CONFIG.QUICK_DIRECTION_CHANGE_MULTIPLIER)
            or serverDelay

        local avgAccel = getAverage(STATE.accelerationHistory)
        local accelContribution = avgAccel * CONFIG.ACCELERATION_PREDICTION_WEIGHT
            * (adjustedDelay * adjustedDelay * 0.5)

        local predictedPos = targetPos + smoothedVel * adjustedDelay + accelContribution

        local predictionTime = CONFIG.PREDICTION_TIME * 1.1
        if isAirborne then
            predictedPos = predictedPos + smoothedVel * predictionTime
                + Vector3.new(0, -0.5 * CONFIG.GRAVITY * predictionTime * predictionTime, 0)
        else
            predictedPos = predictedPos + smoothedVel * predictionTime
        end

        local horizSmoothed = Vector3.new(smoothedVel.X, 0, smoothedVel.Z)
        if horizSmoothed.Magnitude > 1 then
            predictedPos = predictedPos + horizSmoothed.Unit * CONFIG.PREDICT_AHEAD
        end

        local direction = predictedPos - myRoot.Position
        faceTarget(myRoot, direction)

        if (targetPos - myRoot.Position).Magnitude <= CONFIG.ACTIVATE_DISTANCE then
            if tick() - STATE.lastActivationTime >= 0.3 then
                swingBat()
                STATE.lastActivationTime = tick()
            end
        end

        if direction.Magnitude > CONFIG.MIN_FOLLOW_DISTANCE then
            local speed = CONFIG.FOLLOW_SPEED
            myRoot.AssemblyLinearVelocity = direction.Unit * speed
        else
            local currentVel = myRoot.AssemblyLinearVelocity
            myRoot.AssemblyLinearVelocity = Vector3.new(0, currentVel.Y * 0.5, 0)
        end
    end

    local function startAimbot()
        if STATE.enabled then return end
        STATE.enabled = true

        local char = TP_LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                STATE.previousHumanoid = hum
                STATE.previousAutoRotate = hum.AutoRotate
                hum.AutoRotate = false
            end
        end

        resetState()
        STATE.lastActivationTime = 0

        STATE.conn = TP_RunService.RenderStepped:Connect(function(dt)
            pcall(aimbotLoop, dt)
        end)

        print("[TP Bat Aimbot] ✅ ACTIVATED")
    end

    local function stopAimbot()
        if not STATE.enabled then return end
        STATE.enabled = false

        if STATE.conn then
            STATE.conn:Disconnect()
            STATE.conn = nil
        end

        local char = TP_LP.Character
        if char then
            local myRoot = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")

            if myRoot then
                myRoot.AssemblyLinearVelocity = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
            end

            local previous = STATE.previousHumanoid
            if previous and previous.Parent then
                previous.AutoRotate = STATE.previousAutoRotate == nil and true or STATE.previousAutoRotate
            elseif hum then
                hum.AutoRotate = true
            end
        end

        STATE.previousHumanoid = nil
        STATE.previousAutoRotate = nil
        resetState()

        print("[TP Bat Aimbot] ❌ DEACTIVATED")
    end

    startBypassAimbot = function()
        if STATE.enabled then return end
        bypassToggled = true
        _G.AceAntiDesyncAimbotOn = true
        startAimbot()
        if bypassSetVisual then pcall(bypassSetVisual, true) end
    end

    stopBypassAimbot = function()
        local wasEnabled = STATE.enabled
        bypassToggled = false
        _G.AceAntiDesyncAimbotOn = false
        stopAimbot()
        if wasEnabled and bypassSetVisual then pcall(bypassSetVisual, false) end
    end

    toggleBypass = function(state)
        if state == nil then
            state = not STATE.enabled
        end
        if state then
            startBypassAimbot()
        else
            stopBypassAimbot()
        end
        return STATE.enabled
    end

    _G.ForceStopTPBat = function()
        stopBypassAimbot()
        return true
    end

    _G.TPBatStop = function()
        if STATE.enabled then
            stopBypassAimbot()
        end
    end

    _G.TPBatToggle = function(state)
        return toggleBypass(state)
    end

    findBatBypass = function() return findBat() end
    tryHitBatBypass = function() swingBat() end
    getClosestPlayerBypass = function()
        local char = TP_LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return nil, math.huge end
        return findNearestEnemy(root)
    end

    _G.__TPBatState = STATE
    _G.__TPBatConfig = CONFIG
end

LP.CharacterAdded:Connect(function()
    if bypassToggled then
        task.wait(0.5)
        if startBypassAimbot then pcall(startBypassAimbot) end
    end
end)

function findBat()
    local char = LP.Character; if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
    end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("bat") or tool.Name:lower():find("slap")) then return tool end
        end
    end
    return nil
end
function isBatTool(tool)
    if not tool then return false end
    for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do if tool.Name == name then return true end end
    return tool.Name:lower():find("bat") or tool.Name:lower():find("slap")
end
local batCounterDebounce = false
local function findBatForCounter()
    local c = LP.Character; if not c then return nil end
    local bp = LP:FindFirstChildOfClass("Backpack")
    for _, name in ipairs(BAT_COUNTER_SLAP_LIST) do
        local t = c:FindFirstChild(name) or (bp and bp:FindFirstChild(name)); if t then return t end
    end
    for _, ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
    if bp then for _, ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    return nil
end
local function swingBatInstant(bat, char)
    local hum2 = char:FindFirstChildOfClass("Humanoid")
    if bat.Parent ~= char and hum2 then pcall(function() hum2:EquipTool(bat) end) end
    local remote = bat:FindFirstChildOfClass("RemoteEvent") or bat:FindFirstChildOfClass("RemoteFunction")
    if remote and remote:IsA("RemoteEvent") then
        pcall(function() remote:FireServer() end); pcall(function() remote:FireServer() end); pcall(function() remote:FireServer() end)
    else
        pcall(function() bat:Activate() end); pcall(function() bat:Activate() end); pcall(function() bat:Activate() end)
    end
end
function startBatCounter()
    if _G.Lust.Connections.batCounter then return end
    if not batCounterEnabled then return end
    local char = LP.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    _G.Lust.Connections.batCounter = hum.StateChanged:Connect(function(oldState, newState)
        if batCounterDebounce then return end
        if not batCounterEnabled then return end
        local isRagdolled = newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown
        if isRagdolled then
            batCounterDebounce = true
            task.spawn(function()
                local bat = findBatForCounter()
                if bat then
                    local c = LP.Character; if c then swingBatInstant(bat, c) end
                end
                task.wait(0.15); batCounterDebounce = false
            end)
        end
    end)
    _G.Lust.Active.batCounter = true
    if setBatCounterVisual then setBatCounterVisual(true) end
end
function stopBatCounter()
    if _G.Lust.Connections.batCounter then _G.Lust.Connections.batCounter:Disconnect(); _G.Lust.Connections.batCounter = nil end
    batCounterDebounce = false; _G.Lust.Active.batCounter = false
    if setBatCounterVisual then setBatCounterVisual(false) end
end
function setBatCounterState(state)
    batCounterEnabled = state == true
    if batCounterEnabled then startBatCounter() else stopBatCounter() end
end
function toggleBatCounter(state) setBatCounterState(state) end
if batCounterEnabled then task.spawn(function() task.wait(0.5); startBatCounter() end) end
LP.CharacterAdded:Connect(function(newChar)
    if batCounterEnabled then
        if _G.Lust.Connections.batCounter then _G.Lust.Connections.batCounter:Disconnect(); _G.Lust.Connections.batCounter = nil end
        batCounterDebounce = false
        local hum = newChar:WaitForChild("Humanoid", 5); if hum then startBatCounter() end
    end
end)
function findMedusa()
    local c = LP.Character; if not c then return nil end
    for _, t in ipairs(c:GetChildren()) do
        if t:IsA("Tool") then local n = t.Name:lower(); if n:find("medusa") or n:find("head") or n:find("stone") then return t end end
    end
    local bp = LP:FindFirstChild("Backpack")
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") then local n = t.Name:lower(); if n:find("medusa") or n:find("head") or n:find("stone") then return t end end
        end
    end
    return nil
end
function useMedusaCounter()
    if medusaDebounce then return end
    if tick() - medusaLastUsed < MEDUSA_COOLDOWN then return end
    local c = LP.Character; if not c then return end
    medusaDebounce = true
    local med = findMedusa(); if not med then medusaDebounce = false; return end
    if med.Parent ~= c then local hum2 = c:FindFirstChildOfClass("Humanoid"); if hum2 then hum2:EquipTool(med) end end
    pcall(function() med:Activate() end)
    medusaLastUsed = tick(); medusaDebounce = false
end
function onAnchorChanged(part)
    return part:GetPropertyChangedSignal("Anchored"):Connect(function()
        if medusaCounterEnabled and part.Anchored and part.Transparency == 1 then useMedusaCounter() end
    end)
end
function setupMedusa(char)
    for _, c in pairs(_G.Lust.Connections.medusa) do pcall(function() c:Disconnect() end) end
    _G.Lust.Connections.medusa = {}
    if not char or not medusaCounterEnabled then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then table.insert(_G.Lust.Connections.medusa, onAnchorChanged(part)) end
    end
    table.insert(_G.Lust.Connections.medusa, char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then table.insert(_G.Lust.Connections.medusa, onAnchorChanged(part)) end
    end))
end
function stopMedusaCounter()
    for _, c in pairs(_G.Lust.Connections.medusa) do pcall(function() c:Disconnect() end) end
    _G.Lust.Connections.medusa = {}; _G.Lust.Active.medusa = false
end
function setMedusaCounterState(state)
    medusaCounterEnabled = state
    if state then
        _G.Lust.Active.medusa = true
        if LP.Character then setupMedusa(LP.Character) else stopMedusaCounter() end
        if setMedusaVisual then setMedusaVisual(true) end
    else
        stopMedusaCounter()
        if setMedusaVisual then setMedusaVisual(false) end
    end
end

local DROP_ASCEND_DURATION = 0.22; local DROP_ASCEND_SPEED = 160; local _dropConn = nil
function stopDropBrainrot()
    dropActive = false
    if _dropConn then _dropConn:Disconnect(); _dropConn = nil end
    if _G.Lust.Connections.dropBrainrot then _G.Lust.Connections.dropBrainrot:Disconnect(); _G.Lust.Connections.dropBrainrot = nil end
    for _, t in ipairs(dropConnections) do
        if type(t) == "thread" then pcall(task.cancel, t)
        elseif type(t) == "RBXScriptConnection" then pcall(t.Disconnect, t) end
    end
    dropConnections = {}
    local c = LP.Character
    if c then local root = c:FindFirstChild("HumanoidRootPart"); if root then root.AssemblyLinearVelocity = Vector3.zero end end
    if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end
    if mobSetDropBR then mobSetDropBR(false) end
end
function runDropBrainrot()
    if dropActive then return end
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    if dropMode == 1 then
        local speedH = 0
        if root then local vel = root.AssemblyLinearVelocity; speedH = Vector3.new(vel.X, 0, vel.Z).Magnitude end
        local cooldown = (speedH > 5) and 0.6 or 0.25
        if tick() - lastDropTime < cooldown then return end
        lastDropTime = tick()
        dropActive = true
        if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end
        if mobSetDropBR then mobSetDropBR(true) end
        local wasAutoBat = false
        if autoBatEnabled then
            wasAutoBat = true; disableAutoBat()
            if autoBatSetVisual then autoBatSetVisual(false) end
            if mobSetAutoBat then mobSetAutoBat(false) end
        end
        local function finishDrop(threadRef)
            if threadRef and dropConnections then
                for i = #dropConnections, 1, -1 do if dropConnections[i] == threadRef then table.remove(dropConnections, i); break end end
            end
            dropActive = false
            local c = LP.Character
            if c then
                local r = c:FindFirstChild("HumanoidRootPart"); local h = c:FindFirstChildOfClass("Humanoid")
                if r then
                    r.AssemblyLinearVelocity = Vector3.zero; r.AssemblyAngularVelocity = Vector3.zero
                    if r.Position.Y < -100 then r.CFrame = CFrame.new(r.Position.X, 5, r.Position.Z) end
                    local rp = RaycastParams.new(); rp.FilterDescendantsInstances = {c}; rp.FilterType = Enum.RaycastFilterType.Exclude
                    local rr = workspace:Raycast(r.Position, Vector3.new(0, -2000, 0), rp)
                    if rr then
                        local off = (h and h.HipHeight or 2) + (r.Size.Y / 2)
                        r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z)
                    end
                    if h and h.Health > 0 then h:ChangeState(Enum.HumanoidStateType.Running) end
                end
            end
            if wasAutoBat then
                enableAutoBat()
                if autoBatSetVisual then autoBatSetVisual(true) end
                if mobSetAutoBat then mobSetAutoBat(true) end
            end
            if dropBrainrotSetVisual then dropBrainrotSetVisual(false) end
            if mobSetDropBR then mobSetDropBR(false) end
        end
        local flingThread = nil
        flingThread = task.spawn(function()
            local startTime = tick()
            while dropActive and (tick() - startTime) < 0.25 do
                RunService.Heartbeat:Wait()
                local c = LP.Character; local r = c and c:FindFirstChild("HumanoidRootPart")
                if not r then break end
                local vel = r.AssemblyLinearVelocity; vel = Vector3.new(0, vel.Y, 0)
                r.AssemblyLinearVelocity = vel * 10000 + Vector3.new(0, 10000, 0)
                RunService.RenderStepped:Wait()
                if r and r.Parent then r.AssemblyLinearVelocity = vel end
                RunService.Stepped:Wait()
                if r and r.Parent then r.AssemblyLinearVelocity = vel + Vector3.new(0, 0.1, 0) end
            end
            finishDrop(flingThread)
        end)
        table.insert(dropConnections, flingThread)
        task.delay(0.35, function() if dropActive then finishDrop(flingThread) end end)
        return
    end
    dropActive = true
    if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end
    if mobSetDropBR then mobSetDropBR(true) end
    local t0 = tick()
    if _dropConn then _dropConn:Disconnect() end
    _G.Lust.Connections.dropBrainrot = RunService.Heartbeat:Connect(function()
        local c = LP.Character; local r = c and c:FindFirstChild("HumanoidRootPart")
        if not r then stopDropBrainrot(); return end
        if not dropActive then stopDropBrainrot(); return end
        if tick() - t0 >= DROP_ASCEND_DURATION then
            stopDropBrainrot()
            pcall(function()
                local rp = RaycastParams.new(); rp.FilterDescendantsInstances = {c}; rp.FilterType = Enum.RaycastFilterType.Exclude
                local rr = workspace:Raycast(r.Position, Vector3.new(0, -3000, 0), rp)
                if rr then
                    local hum2 = c:FindFirstChildOfClass("Humanoid")
                    local off = ((hum2 and hum2.HipHeight) or 2) + (r.Size.Y / 2)
                    r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z)
                    r.AssemblyLinearVelocity = Vector3.zero; r.AssemblyAngularVelocity = Vector3.zero
                end
                local h2 = c:FindFirstChildOfClass("Humanoid"); if h2 and h2.Health > 0 then h2:ChangeState(Enum.HumanoidStateType.Running) end
            end)
            return
        end
        local lv = r.AssemblyLinearVelocity
        r.AssemblyLinearVelocity = Vector3.new(lv.X, DROP_ASCEND_SPEED, lv.Z)
    end)
end
function executeDropWithToggle(setVisual)
    if dropActive then return end
    task.spawn(function()
        if setVisual then setVisual(true) end
        runDropBrainrot()
        while dropActive do task.wait() end
        task.wait(0.1)
        if setVisual then setVisual(false) end
    end)
end
function applyButtonScale(val)
    buttonScaleValue = math.clamp(val, 0.50, 1.50)
    local scale = buttonScaleValue
    if MobilePanel then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        if container then
            local sc = container:FindFirstChild("ButtonScale") or Instance.new("UIScale")
            sc.Name = "ButtonScale"; sc.Scale = scale; sc.Parent = container
        end
    end
    if instaResetFloatingButton then
        local frame = instaResetFloatingButton:FindFirstChild("Frame")
        if frame then local sc = frame:FindFirstChild("ButtonScale") or Instance.new("UIScale"); sc.Name = "ButtonScale"; sc.Scale = scale; sc.Parent = frame end
    end
    if bypassFloatingButton then
        local frame = bypassFloatingButton:FindFirstChild("Frame")
        if frame then local sc = frame:FindFirstChild("ButtonScale") or Instance.new("UIScale"); sc.Name = "ButtonScale"; sc.Scale = scale; sc.Parent = frame end
    end
end
local function _applyVizFpsBooster(on)
    local L = game:GetService("Lighting")
    if on then
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        L.GlobalShadows = false
        L.Brightness = 3
        L.FogEnd = 9e9
        L.EnvironmentDiffuseScale = 0
        L.EnvironmentSpecularScale = 0
        pcall(function() L.Technology = Enum.Technology.Legacy end)
    else
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
        L.GlobalShadows = true
        L.Brightness = 2
        L.FogEnd = 100000
        L.EnvironmentDiffuseScale = 1
        L.EnvironmentSpecularScale = 1
        pcall(function() L.Technology = Enum.Technology.ShadowMap end)
    end
end

local vizFpsBoosterEnabled = false

local function toggleVizFpsBooster(on)
    vizFpsBoosterEnabled = on
    _applyVizFpsBooster(on)
end

local defLightBrightness = nil; local defLightClock = nil; local defLightAmbient = nil; local defGlobalShadows = nil; local defFogEnd = nil
function applyAntiLagDerender(obj)
    pcall(function()
        if obj:IsA("Accessory") or obj:IsA("Hat") then obj:Destroy()
        elseif obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic; obj.Reflectance = 0; obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then obj.Enabled = false
        elseif obj:IsA("AnimationController") or obj:IsA("Animator") then
            for _, t in ipairs(obj:GetPlayingAnimationTracks()) do pcall(function() t:Stop(0) end) end
        end
    end)
end
function enableAntiLag()
    removeAccessoriesEnabled = true; antiLagEnabled = true; _G.Lust.Active.antiLag = true
    if defLightBrightness == nil then
        defLightBrightness = Lighting.Brightness; defLightClock = Lighting.ClockTime
        defLightAmbient = Lighting.OutdoorAmbient; defGlobalShadows = Lighting.GlobalShadows; defFogEnd = Lighting.FogEnd
    end
    Lighting.GlobalShadows = false; Lighting.FogEnd = 1e10; Lighting.Brightness = 0
    for _, e in pairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = false end
        end)
    end
    for _, obj in ipairs(workspace:GetDescendants()) do applyAntiLagDerender(obj) end
    if _G.Lust.Connections.antiLagDesc then _G.Lust.Connections.antiLagDesc:Disconnect() end
    _G.Lust.Connections.antiLagDesc = workspace.DescendantAdded:Connect(function(obj)
        if removeAccessoriesEnabled then applyAntiLagDerender(obj) end
    end)
    if setAntiLagVisual then setAntiLagVisual(true) end
end
function disableAntiLag()
    removeAccessoriesEnabled = false; antiLagEnabled = false; _G.Lust.Active.antiLag = false
    if _G.Lust.Connections.antiLagDesc then _G.Lust.Connections.antiLagDesc:Disconnect(); _G.Lust.Connections.antiLagDesc = nil end
    if defLightBrightness ~= nil then Lighting.Brightness = defLightBrightness end
    if defLightClock ~= nil then Lighting.ClockTime = defLightClock end
    if defLightAmbient ~= nil then Lighting.OutdoorAmbient = defLightAmbient end
    if defGlobalShadows ~= nil then Lighting.GlobalShadows = defGlobalShadows end
    if defFogEnd ~= nil then Lighting.FogEnd = defFogEnd end
    for _, e in pairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = true end
        end)
    end
    if setAntiLagVisual then setAntiLagVisual(false) end
end
local function stopAntiDie()
    if _antiDieConn then _antiDieConn:Disconnect(); _antiDieConn = nil end
    if _antiDieHealthConn then _antiDieHealthConn:Disconnect(); _antiDieHealthConn = nil end
    if _antiDieStateConn then _antiDieStateConn:Disconnect(); _antiDieStateConn = nil end
end

local function setupAntiDie(char)
    stopAntiDie()
    if not char or not antiDieEnabled or _isResetting then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
    end
    pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
    _antiDieHealthConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if antiDieEnabled and not _isResetting and hum.Parent and hum.Health < hum.MaxHealth then
            pcall(function() hum.Health = hum.MaxHealth end)
        end
    end)
    _antiDieConn = RunService.Heartbeat:Connect(function()
        if antiDieEnabled and not _isResetting and hum and hum.Parent then
            pcall(function()
                if hum.Health < hum.MaxHealth then
                    hum.Health = hum.MaxHealth
                end
            end)
        end
    end)
    _antiDieStateConn = hum.StateChanged:Connect(function(_, newState)
        if antiDieEnabled and not _isResetting and newState == Enum.HumanoidStateType.Dead then
            pcall(function()
                hum.Health = hum.MaxHealth
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
        end
    end)
end

function enableAntiDie()
    antiDieEnabled = true
    _G.Lust.Active.antiDie = true
    setupAntiDie(LP.Character)
end

function disableAntiDie()
    antiDieEnabled = false
    _G.Lust.Active.antiDie = false
    stopAntiDie()
end

LP.CharacterAdded:Connect(function(char)
    task.wait(0.15)
    if antiDieEnabled and not _isResetting then
        setupAntiDie(char)
    end
end)

function applyStretchFOV(val) local cam = workspace.CurrentCamera; if cam then pcall(function() cam.FieldOfView = val end) end end
function enableStretch()
    if _G.Lust.Connections.stretch then return end
    _G.Lust.Active.stretch = true; stretchEnabled = true
    local cam = workspace.CurrentCamera; if not cam then return end
    origFOV = cam.FieldOfView or 70
    applyStretchFOV(120)
    _G.Lust.Connections.stretch = RunService.RenderStepped:Connect(function()
        if not stretchEnabled then _G.Lust.Connections.stretch:Disconnect(); _G.Lust.Connections.stretch = nil; return end
        local c = workspace.CurrentCamera
        if c then c.CFrame = c.CFrame * CFrame.new(0,0,0,1,0,0,0,0.7,0,0,0,1) end
    end)
    if _G.Lust.Connections.stretchFov then _G.Lust.Connections.stretchFov:Disconnect() end
    _G.Lust.Connections.stretchFov = RunService.RenderStepped:Connect(function()
        if stretchEnabled then applyStretchFOV(120)
        else _G.Lust.Connections.stretchFov:Disconnect(); _G.Lust.Connections.stretchFov = nil end
    end)
    if _G.stretchToggleSetter then _G.stretchToggleSetter(true) end
end
function disableStretch()
    _G.Lust.Active.stretch = false; stretchEnabled = false
    if _G.Lust.Connections.stretch then _G.Lust.Connections.stretch:Disconnect(); _G.Lust.Connections.stretch = nil end
    if _G.Lust.Connections.stretchFov then _G.Lust.Connections.stretchFov:Disconnect(); _G.Lust.Connections.stretchFov = nil end
    local cam = workspace.CurrentCamera; if cam then pcall(function() cam.FieldOfView = povEnabled and 120 or (origFOV or 70) end) end
    if _G.stretchToggleSetter then _G.stretchToggleSetter(false) end
end
function enablePOV()
    povEnabled = true
    local cam = workspace.CurrentCamera
    if not cam then return end
    pcall(function() cam.FieldOfView = 120 end)
    if _G.Lust.Connections.povFov then
        _G.Lust.Connections.povFov:Disconnect()
        _G.Lust.Connections.povFov = nil
    end
    _G.Lust.Connections.povFov = RunService.RenderStepped:Connect(function()
        if not povEnabled then
            if _G.Lust.Connections.povFov then
                _G.Lust.Connections.povFov:Disconnect()
                _G.Lust.Connections.povFov = nil
            end
            return
        end
        local c = workspace.CurrentCamera
        if c then pcall(function() c.FieldOfView = 120 end) end
    end)
end

function disablePOV()
    povEnabled = false
    if _G.Lust.Connections.povFov then
        _G.Lust.Connections.povFov:Disconnect()
        _G.Lust.Connections.povFov = nil
    end
    local cam = workspace.CurrentCamera
    if cam then
        pcall(function()
            if stretchEnabled then
                cam.FieldOfView = 120
            else
                cam.FieldOfView = origFOV or 70
            end
        end)
    end
end
local _mainGuiSaveToken = 0
local function persistMainGuiPosition(reason)
    if not main or not main.Parent then return false end
    if _isBuildingGui or _isLoading or _isResetting then return false end
    savedMainGuiPos = {
        XScale = main.Position.X.Scale, XOffset = main.Position.X.Offset,
        YScale = main.Position.Y.Scale, YOffset = main.Position.Y.Offset
    }
    _mainGuiSaveToken = _mainGuiSaveToken + 1
    local token = _mainGuiSaveToken
    task.defer(function()
        if token ~= _mainGuiSaveToken then return end
        if _isBuildingGui or _isLoading or _isResetting then return end
        pcall(syncFloatingButtonPositions)
        pcall(function() saveAllSettings() end)
    end)
    return true
end

local function drag(f)
    local dn, ds, sp, di = false
    f.InputBegan:Connect(function(i)
        if uiLocked then return end
        if _isDraggingButton then return end
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dn = true; ds = i.Position; sp = f.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    dn = false
                    if (f == main or f.Name == "MenuDragHandle") then
                        persistMainGuiPosition("menu drag release")
                    end
                end
            end)
        end
    end)
    f.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then di = i end
    end)
    UIS.InputChanged:Connect(function(i)
        if i == di and dn then
            if uiLocked then dn = false; return end
            if _isDraggingButton then return end
            local nX = sp.X.Offset + (i.Position.X - ds.X); local nY = sp.Y.Offset + (i.Position.Y - ds.Y)
            f.Position = UDim2.new(sp.X.Scale, nX, sp.Y.Scale, nY)
        end
    end)
end
function setupMovementAndIndicators(char)
    if _G.Lust.Connections.movement then _G.Lust.Connections.movement:Disconnect(); _G.Lust.Connections.movement = nil end
    if _G.Lust.Connections.stepped then _G.Lust.Connections.stepped:Disconnect(); _G.Lust.Connections.stepped = nil end
    _G.Lust.Connections.stepped = RunService.Stepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                for _, part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end)
    _G.Lust.Connections.movement = RunService.RenderStepped:Connect(function()
        local char2 = LP.Character
        if not char2 then return end
        local hum = char2:FindFirstChildOfClass("Humanoid")
        local hrp = char2:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end
        if speedLabel then
            local v = hrp.AssemblyLinearVelocity or hrp.Velocity
            local flatSpeed = math.sqrt(v.X * v.X + v.Z * v.Z)
            speedLabel.Text = "Speed: " .. string.format("%.1f", flatSpeed)
        end
    end)
    setupSpeedIndicator(char)
    startEnemySpeed()
end
function toggleHideButtons(state)
    if state == nil then hideButtonsEnabled = not hideButtonsEnabled else hideButtonsEnabled = state end
    local visible = not hideButtonsEnabled
    if MobilePanel then
        local floatingPanel = MobilePanel:FindFirstChild("FloatingPanel")
        if floatingPanel then
            local buttonsContainer = floatingPanel:FindFirstChild("ButtonsContainer")
            if buttonsContainer then
                buttonsContainer.Visible = visible
            end
        end
    end
    if instaResetFloatingButton then
        local frame = instaResetFloatingButton:FindFirstChild("Frame")
        if frame then frame.Visible = visible end
    end
    if bypassFloatingButton then
        local frame = bypassFloatingButton:FindFirstChild("Frame")
        if frame then frame.Visible = visible end
    end
    if setHideButtonsVisual then setHideButtonsVisual(hideButtonsEnabled) end
end

function toggleLockUI(state)
    if state == nil then uiLocked = not uiLocked else uiLocked = state end
    if setLockUIVisual then setLockUIVisual(uiLocked) end
end
function disableAllAimbots()
    if autoBatEnabled then disableAutoBat() end
    if bypassToggled then toggleBypass(false) end
end
function stopAllBackgroundTasks()
    _G.Lust.StopAll()
    for _, t in ipairs(dropConnections) do
        if type(t) == "thread" then pcall(task.cancel, t)
        elseif type(t) == "RBXScriptConnection" then pcall(t.Disconnect, t) end
    end
    dropConnections = {}; dropActive = false; alPhase = 1; arPhase = 1
    lastDropTime = 0; medusaDebounce = false; medusaLastUsed = 0
end

-- ============================================================
-- BACKGROUND IMAGES
-- ============================================================
local BackgroundImages = {
    "rbxassetid://127008542588565",
    "rbxassetid://93417009946836",
    "rbxassetid://102729289645203",
    "rbxassetid://116355482429334",
    "rbxassetid://133090961209841",
    "rbxassetid://84995781107338",
    "rbxassetid://100137217709081",
    "rbxassetid://90631990302263",
    "rbxassetid://109619268613730",
    "rbxassetid://88369503310562",
    "rbxassetid://80708025126373",
    "rbxassetid://102253425322931",
    "rbxassetid://96005510156373",
    "rbxassetid://90384569541777"
}
local currentBgIndex = 1; local bgImageRef = nil; local bgImageCorner = nil

local function applyStealBarBackground()
    if not pbFrame then return end
    local stealBG = pbFrame:FindFirstChild("AdaptStealBarBG")
    if stealBarMatchEnabled then
        local asset = BackgroundImages[currentBgIndex] or ""
        if not stealBG then
            stealBG = Instance.new("ImageLabel")
            stealBG.Name = "AdaptStealBarBG"
            stealBG.BackgroundTransparency = 1
            stealBG.BorderSizePixel = 0
            stealBG.Size = UDim2.fromScale(1, 1)
            stealBG.ImageTransparency = 0.3
            stealBG.ScaleType = Enum.ScaleType.Crop
            stealBG.ZIndex = 1
            stealBG.Parent = pbFrame
            Instance.new("UICorner", stealBG).CornerRadius = UDim.new(0, 16)
        end
        stealBG.Image = asset
        stealBG.Visible = true
        stealBG.ImageTransparency = 0.3
        pbFrame.BackgroundTransparency = 0.3
    else
        if stealBG then
            stealBG.Image = ""
            stealBG.Visible = false
        end
        pbFrame.BackgroundTransparency = 0
    end
end

local function applyBackgroundImage(index)
    index = math.clamp(index or currentBgIndex, 1, #BackgroundImages)
    currentBgIndex = index
    local asset = BackgroundImages[index]
    if bgImageRef then
        bgImageRef.Image = asset; bgImageRef.Visible = true; bgImageRef.ImageTransparency = 0
        if not bgImageCorner then
            bgImageCorner = Instance.new("UICorner"); bgImageCorner.CornerRadius = UDim.new(0, 18); bgImageCorner.Parent = bgImageRef
        end
    end
    applyStealBarBackground()
    if not _isLoading and not _isResetting and not _isBuildingGui then saveAllSettings() end
end
local function setupBackgroundImage()
    if bgImageRef then return end
    local bg = Instance.new("ImageLabel")
    bg.Name = "KZAXBackgroundImage"; bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0); bg.BackgroundTransparency = 1
    bg.Image = BackgroundImages[currentBgIndex] or ""; bg.ImageTransparency = 0
    bg.ScaleType = Enum.ScaleType.Crop; bg.ZIndex = 0; bg.Parent = main
    bgImageCorner = Instance.new("UICorner"); bgImageCorner.CornerRadius = UDim.new(0, 18); bgImageCorner.Parent = bg
    bgImageRef = bg; bgImageRef.Visible = true
end

local function syncFloatingButtonPositions()
    if main then
        config.mainGuiPos = {XScale = main.Position.X.Scale, XOffset = main.Position.X.Offset,
            YScale = main.Position.Y.Scale, YOffset = main.Position.Y.Offset}
    end
    if MobilePanel and MobilePanel:FindFirstChild("FloatingPanel") then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        local buttonsContainer = container:FindFirstChild("ButtonsContainer")
        if buttonsContainer then
            for _, btn in ipairs(buttonsContainer:GetChildren()) do
                if btn:IsA("GuiObject") and btn.Name and btn.Position then
                    savedButtonPositions[btn.Name] = {X = btn.Position.X.Offset, Y = btn.Position.Y.Offset}
                end
            end
        end
        savedMobilePanelPos = {XScale = container.Position.X.Scale, XOffset = container.Position.X.Offset,
            YScale = container.Position.Y.Scale, YOffset = container.Position.Y.Offset}
    end
    if instaResetFloatingButton and instaResetFloatingButton:FindFirstChild("Frame") then
        local frame = instaResetFloatingButton:FindFirstChild("Frame")
        instaResetFloatingPos = {XScale = frame.Position.X.Scale, XOffset = frame.Position.X.Offset,
            YScale = frame.Position.Y.Scale, YOffset = frame.Position.Y.Offset}
    end
    if bypassFloatingButton and bypassFloatingButton:FindFirstChild("Frame") then
        local frame = bypassFloatingButton:FindFirstChild("Frame")
        bypassFloatingPos = {XScale = frame.Position.X.Scale, XOffset = frame.Position.X.Offset,
            YScale = frame.Position.Y.Scale, YOffset = frame.Position.Y.Offset}
    end
    pcall(saveDedicatedButtonPositions)
end

-- ============================================================
-- (FONT STYLE SELECTOR — REMOVED)
-- ============================================================

function buildConfigTable()
    local config = {normalSpeed = NS, carrySpeed = CS, laggerSpeed1 = LAGGER_SPEED_1, laggerSpeed2 = LAGGER_SPEED_2,
        stealRadius = CONFIG.STEAL_RANGE, autoTPDownHeight = autoTPDownHeight, autoTPDownEnabled = autoTPDownEnabled,
        antiRagdoll = antiRagdollEnabled, autoSteal = CONFIG.AUTO_STEAL_ENABLED, jumpEnabled = jumpEnabled,
        jumpMode = _G._KZAXJumpMode or "HOLD",
        medusaCounter = medusaCounterEnabled, batCounter = batCounterEnabled,
        laggerToggled = laggerToggled, laggerLevel = laggerLevel, carryMode = speedMode,
        batAimbotSpeed = BAT_AIMBOT_SPEED, bypassSpeed = BYPASS_AIMBOT_SPEED, dropMode = dropMode,
        stretchEnabled = stretchEnabled, povEnabled = povEnabled, uiScale = uiScaleValue, buttonScale = buttonScaleValue,
        skyTheme = currentSkyTheme, accessoryPack = currentAccessoryPack,
        espEnabled = espEnabled, antiLag = antiLagEnabled, antiDie = (antiDieEnabled == true), vizFpsBooster = vizFpsBoosterEnabled,
        shinyGraphics = (_G.AceShinyGraphics and _G.AceShinyGraphics.shinyEnabled == true),
        bodyLock = bodyLockEnabled,
        stealBarMatch = stealBarMatchEnabled,
        mobileButtonPositions = savedButtonPositions,
        instaResetFloatingPos = instaResetFloatingPos, bypassFloatingPos = bypassFloatingPos,
        lockUI = uiLocked, hideButtons = hideButtonsEnabled, backgroundIndex = currentBgIndex,
        tabPosition = _G._KZAXTabPosition,
        customToolsEnabled = _G.AmbitiousCustomToolsEnabled or false,
        customToolsSkins = _G.AmbitiousCustomToolSkins,
        customSoundsEnabled = _G.AmbitiousCustomSoundsEnabled or false,
        kickWarningEnabled = _G._AdaptKickWarningEnabled == true,
        outfitIndex = currentOutfitIndex,
        animationPack = _G._KZAXGetAnimationPack and _G._KZAXGetAnimationPack() or "OFF"}
    if main then
        config.mainGuiPos = {
            XScale = main.Position.X.Scale, XOffset = main.Position.X.Offset,
            YScale = main.Position.Y.Scale, YOffset = main.Position.Y.Offset
        }
    end
    if pbFrame then config.progressBarPos = {XScale = pbFrame.Position.X.Scale, XOffset = pbFrame.Position.X.Offset,
        YScale = pbFrame.Position.Y.Scale, YOffset = pbFrame.Position.Y.Offset} end
    if MobilePanel and MobilePanel:FindFirstChild("FloatingPanel") then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        config.mobilePanelPos = {XScale = container.Position.X.Scale, XOffset = container.Position.X.Offset,
            YScale = container.Position.Y.Scale, YOffset = container.Position.Y.Offset}
    end
    return config
end
local function queueConfigSave(reason)
    if _isBuildingGui or not canSaveConfig or _isLoading or _isResetting then return end
    _autoSaveSerial = _autoSaveSerial + 1
    local serial = _autoSaveSerial
    if _autoSaveQueued then return end
    _autoSaveQueued = true
    task.delay(0.15, function()
        _autoSaveQueued = false
        if _isLoading or _isResetting then return end
        if serial ~= _autoSaveSerial then queueConfigSave(reason); return end
        pcall(syncFloatingButtonPositions)
        local ok = saveAllSettings()
        if not ok then warn("[AmiriDuels] AUTO-SAVE FAILED" .. (reason and (" (" .. tostring(reason) .. ")") or "")) end
    end)
end
function saveAllSettings()
    if _isBuildingGui then return false end
    refreshFileApis()
    if not canSaveConfig then warn("[AmiriDuels] SAVE CONFIG FAILED: readfile/writefile unavailable."); return false end
    if _isResetting then return false end
    pcall(syncFloatingButtonPositions)
    local config = buildConfigTable()
    config.version = 2; config.buttonLayoutVersion = BUTTON_LAYOUT_VERSION; config.savedAt = os.time()
    local keybinds = {}
    for k, v in pairs(KB) do keybinds[k] = {kb = v.kb and v.kb.Name or nil, gp = v.gp and v.gp.Name or nil} end
    config.keybinds = keybinds
    local encodeOk, json = pcall(function() return HS:JSONEncode(config) end)
    if not encodeOk or type(json) ~= "string" then warn("[AmiriDuels] SAVE CONFIG FAILED: JSON encode error."); return false end
    local writeOk, writeErr = pcall(_ace_writefile, CONFIG_FILE, json)
    if not writeOk then warn("[AmiriDuels] SAVE CONFIG FAILED: " .. tostring(writeErr)); return false end
    local readOk, savedText = pcall(_ace_readfile, CONFIG_FILE)
    if not readOk or savedText ~= json then warn("[AmiriDuels] SAVE CONFIG FAILED: verification failed."); return false end
    _lastSavedJSON = json
    print("[AmiriDuels] CONFIG SAVED: " .. CONFIG_FILE)
    return true
end
function loadAllSettings()
    refreshFileApis()
    if not canSaveConfig then warn("[LustHub] Config load unavailable."); return false end
    if not _ace_isfile(CONFIG_FILE) then
        local defaultConfig = buildConfigTable()
        local keybinds = {}
        for k, v in pairs(KB) do keybinds[k] = {kb = v.kb and v.kb.Name, gp = v.gp and v.gp.Name} end
        local mainConfig = {}
        for k, v in pairs(defaultConfig) do mainConfig[k] = v end
        mainConfig.keybinds = keybinds
        local defaultJson = HS:JSONEncode(mainConfig)
        local ok = pcall(_ace_writefile, CONFIG_FILE, defaultJson)
        if ok then _lastSavedJSON = defaultJson; print("[AmiriDuels] Created default config file.")
        else warn("[AmiriDuels] Could not create default config file.") end
        return false
    end
    local success, data = pcall(function() return HS:JSONDecode(_ace_readfile(CONFIG_FILE)) end)
    if not success or type(data) ~= "table" then warn("[LustHub] Failed to load config, using defaults."); return false end
    _isLoading = true
    local keybinds = data.keybinds or {}
    for keyId, val in pairs(keybinds) do
        if KB[keyId] then KB[keyId].kb = val.kb and Enum.KeyCode[val.kb] or nil; KB[keyId].gp = val.gp and Enum.KeyCode[val.gp] or nil end
    end
    NS = data.normalSpeed or NS; CS = data.carrySpeed or CS
    LAGGER_SPEED_1 = data.laggerSpeed1 or LAGGER_SPEED_1; LAGGER_SPEED_2 = data.laggerSpeed2 or LAGGER_SPEED_2
    pcall(function()
        SpeedModule.setNormalSpeed(NS)
        SpeedModule.setCarrySpeed(CS)
        SpeedModule.setLaggerSpeed(LAGGER_SPEED_1)
        SpeedModule.setLaggerCarrySpeed(LAGGER_SPEED_2)
    end)
    CONFIG.STEAL_RANGE = data.stealRadius or CONFIG.STEAL_RANGE
    autoTPDownHeight = data.autoTPDownHeight or 20
    autoTPDownEnabled = (data.autoTPDownEnabled == true)
    uiLocked = data.lockUI or false
    hideButtonsEnabled = (data.hideButtons == true)
    antiRagdollEnabled = data.antiRagdoll or false
    CONFIG.AUTO_STEAL_ENABLED = data.autoSteal or false
    jumpEnabled = (data.jumpEnabled == true)
    if data.jumpMode == "MANUAL" or data.jumpMode == "HOLD" then
        _G._KZAXJumpMode = data.jumpMode
    end
    medusaCounterEnabled = data.medusaCounter or false
    batCounterEnabled = data.batCounter or false
    antiLagEnabled = data.antiLag or false
    antiDieEnabled = data.antiDie or false
    vizFpsBoosterEnabled = data.vizFpsBooster or false
    if type(_G.AceShinyGraphics) == "table" then
        _G.AceShinyGraphics.shinyEnabled = (data.shinyGraphics == true)
    end
    bodyLockEnabled = (data.bodyLock == true)
    stealBarMatchEnabled = (data.stealBarMatch == true)
    laggerToggled = data.laggerToggled or false
    speedMode = data.carryMode or false
    laggerLevel = data.laggerLevel or 1
    uiScaleValue = tonumber(data.uiScale) or 100
    uiScaleValue = math.clamp(uiScaleValue, 50, 150)
    buttonScaleValue = tonumber(data.buttonScale) or 0.80
    buttonScaleValue = math.clamp(buttonScaleValue, 0.50, 1.50)
    espEnabled = data.espEnabled or false
    stretchEnabled = data.stretchEnabled or false
    povEnabled = data.povEnabled or false
    BAT_AIMBOT_SPEED = data.batAimbotSpeed or BAT_AIMBOT_SPEED
    BYPASS_AIMBOT_SPEED = data.bypassSpeed or BYPASS_AIMBOT_SPEED
    dropMode = data.dropMode or 1
    currentSkyTheme = data.skyTheme or "Off"
    currentAccessoryPack = data.accessoryPack or "Off"
    currentBgIndex = data.backgroundIndex or 1
    currentBgIndex = math.clamp(currentBgIndex, 1, #BackgroundImages)
    if type(data.tabPosition) == "string" then
        _G._KZAXTabPosition = _G.KZAXValidTabPosition(data.tabPosition)
    end
    if data.customToolsSkins then _G.AmbitiousCustomToolSkins = data.customToolsSkins end
    if type(data.outfitIndex) == "number" then
        _G._KZAXSavedOutfitIndex = data.outfitIndex
    end
    _G.AmbitiousCustomToolsEnabled = (data.customToolsEnabled == true)
    if _G.KZAXCustomToolsSetState then
        pcall(_G.KZAXCustomToolsSetState, _G.AmbitiousCustomToolsEnabled)
    end
    if _G.AmbitiousCustomTools then
        pcall(function() _G.AmbitiousCustomTools.setEnabled(_G.AmbitiousCustomToolsEnabled) end)
    end
    _G.AmbitiousCustomSoundsEnabled = (data.customSoundsEnabled == true)
    if _G.KZAXCustomSoundsSetState then
        pcall(_G.KZAXCustomSoundsSetState, _G.AmbitiousCustomSoundsEnabled)
    end
    if _G.AmbitiousCustomSounds then
        pcall(function() _G.AmbitiousCustomSounds.setEnabled(_G.AmbitiousCustomSoundsEnabled) end)
    end
    _G._AdaptKickWarningEnabled = (data.kickWarningEnabled == true)
    if _G._AdaptKickWarning then
        pcall(function() _G._AdaptKickWarning.SetEnabled(_G._AdaptKickWarningEnabled) end)
    end
    if _G.KZAXKickWarnSetState then
        pcall(_G.KZAXKickWarnSetState, _G._AdaptKickWarningEnabled)
    end
    if data.animationPack and data.animationPack ~= "OFF" then
        _G._KZAXAnimationPack = data.animationPack
    end
    if data.instaResetFloatingPos then instaResetFloatingPos = data.instaResetFloatingPos end
    if data.bypassFloatingPos then bypassFloatingPos = data.bypassFloatingPos end
    if data.progressBarPos then savedProgressBarPos = data.progressBarPos end
    if data.mobileButtonPositions then
        if tonumber(data.buttonLayoutVersion) == BUTTON_LAYOUT_VERSION then savedButtonPositions = data.mobileButtonPositions
        else savedButtonPositions = {} end
    end
    if data.mobilePanelPos then savedMobilePanelPos = data.mobilePanelPos end
    savedMainGuiPos = nil
    if type(data.mainGuiPos) == "table" then
        savedMainGuiPos = {
            XScale = tonumber(data.mainGuiPos.XScale) or 0.5,
            XOffset = tonumber(data.mainGuiPos.XOffset) or -165,
            YScale = tonumber(data.mainGuiPos.YScale) or 0.5,
            YOffset = tonumber(data.mainGuiPos.YOffset) or -250
        }
    end
    _lastSavedJSON = HS:JSONEncode(data)
    _isLoading = false
    print("[LustHub] Config loaded successfully from " .. CONFIG_FILE)
    return true
end
function forceResetUI()
    if normalBox then normalBox.Text = tostring(NS) end
    if carryBox then carryBox.Text = tostring(CS) end
    if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end
    if laggerBox then laggerBox.Text = tostring(LAGGER_SPEED_1) end
    if lagger2Box then lagger2Box.Text = tostring(LAGGER_SPEED_2) end
    if autoTPHeightBox then autoTPHeightBox.Text = tostring(autoTPDownHeight) end
    if uiScaleBox then uiScaleBox.Text = tostring(uiScaleValue) end
    if _G.uiScaleValueLabel then _G.uiScaleValueLabel.Text = string.format("%.2f", uiScaleValue / 100) end
    if mainUIScale then mainUIScale.Scale = uiScaleValue / 100 end
    if pbScale then pbScale.Scale = uiScaleValue / 100 end
    if _G.buttonScaleValueLabel then _G.buttonScaleValueLabel.Text = string.format("%.2f", buttonScaleValue) end
    applyButtonScale(buttonScaleValue)
    if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end
    local function safeSet(fn, val) if fn then fn(val) end end
    safeSet(autoBatSetVisual, false); safeSet(autoLeftSetVisual, false); safeSet(autoRightSetVisual, false)
    safeSet(setBatCounterVisual, false); safeSet(setMedusaVisual, false); safeSet(setAntiRagVisual, false)
    safeSet(setJumpVisual, false); safeSet(setAntiLagVisual, false); safeSet(setAntiDieVisual, false); toggleVizFpsBooster(false); safeSet(setAutoTPDownVisual, false)
    safeSet(setBodyLockVisual, false)
    safeSet(setStealBarMatchVisual, false)
    if _G.ShinyGraphics then _G.ShinyGraphics.Disable() end
    safeSet(setShinyGraphicsVisual, false)
    safeSet(setHideButtonsVisual, false); hideButtonsEnabled = false; toggleHideButtons(false); safeSet(setLockUIVisual, false); safeSet(setInstaGrab, false); safeSet(bypassSetVisual, false)
    safeSet(setESPVIsual, false)
    if _G.stretchToggleSetter then _G.stretchToggleSetter(false) end
    povEnabled = false
    if setPOVVisual then setPOVVisual(false) end
    disablePOV()
    safeSet(mobSetAutoBat, false); safeSet(mobSetAutoLeft, false); safeSet(mobSetAutoRight, false)
    safeSet(mobSetDropBR, false); safeSet(mobSetTpDown, false); safeSet(mobSetCarry, false)
    safeSet(mobSetLagger1, false); safeSet(mobSetLagger2, false)
    if setJumpToggleState then setJumpToggleState(false) end
    refreshSpeedModeLabel(); updateProgressBarVisibility(); setSkyTheme("Off"); disableAntiLag()
    for _, ref in ipairs(keyButtonRefs) do
        local entry = ref.entry
        local label = (entry.gp and entry.gp.Name) or (entry.kb and entry.kb.Name) or "None"
        ref.btn.Text = label
    end
    currentAccessoryPack = "Off"; clearAllAccessories(LP.Character)
    if accSelectorLabel then accSelectorLabel.Text = "OFF" end
    if refreshAccessoryCards then refreshAccessoryCards() end
end
function resetFloatingPositions()
    if MobilePanel and MobilePanel:FindFirstChild("FloatingPanel") then
        local container = MobilePanel:FindFirstChild("FloatingPanel")
        container.Position = UDim2.new(1, -MOBILE_PANEL_WIDTH - 10, 0, -20)
        savedButtonPositions = {}
        if container:FindFirstChild("ButtonsContainer") then
            for _, btn in ipairs(container.ButtonsContainer:GetChildren()) do
                if btn:IsA("TextButton") and btn.Name then
                    local defX, defY = getDefaultButtonPosition(btn.Name)
                    btn.Position = UDim2.new(0, defX, 0, defY)
                end
            end
        end
    end
    if instaResetFloatingButton and instaResetFloatingButton:FindFirstChild("Frame") then
        local btnFrame = instaResetFloatingButton:FindFirstChild("Frame")
        btnFrame.Position = UDim2.new(1, -MOBILE_PANEL_WIDTH - 10, 0, MOBILE_PANEL_HEIGHT + 10); instaResetFloatingPos = nil
    end
    if bypassFloatingButton and bypassFloatingButton:FindFirstChild("Frame") then
        local btnFrame = bypassFloatingButton:FindFirstChild("Frame")
        btnFrame.Position = UDim2.new(1, -10 - 60, 0, MOBILE_PANEL_HEIGHT + 10); bypassFloatingPos = nil
    end
    if pbFrame then pbFrame.Position = UDim2.new(0.5, -150, 1, -70); savedProgressBarPos = nil end
    savedMobilePanelPos = nil; savedMainGuiPos = nil; instaResetFloatingPos = nil; bypassFloatingPos = nil
end
function resetToFactoryDefaults()
    _isResetting = true
    stopAllBackgroundTasks(); stopAutoSteal(); stopAutoTPDown(); stopBatCounter(); stopMedusaCounter()
    stopAntiRagdoll(); stopJumpMode(); disableAutoBat(); toggleBypass(false)
    stopBodyLock()
    if espEnabled then toggleESP(false) end
    if stretchEnabled then disableStretch() end
    if antiLagEnabled then disableAntiLag() end
    if antiDieEnabled then disableAntiDie() end
    if _G.ShinyGraphics then _G.ShinyGraphics.Disable() end
    if dropActive then stopDropBrainrot() end
    NS = 59.5; CS = 28.8; LAGGER_SPEED_1 = 29; LAGGER_SPEED_2 = 15
    pcall(function()
        SpeedModule.setNormalSpeed(NS)
        SpeedModule.setCarrySpeed(CS)
        SpeedModule.setLaggerSpeed(LAGGER_SPEED_1)
        SpeedModule.setLaggerCarrySpeed(LAGGER_SPEED_2)
    end)
    SpeedModule.reset()
    CONFIG.STEAL_RANGE = 60; autoTPDownHeight = 20
    speedMode = false; laggerToggled = false; laggerLevel = 1
    antiRagdollEnabled = false; jumpEnabled = false
    medusaCounterEnabled = false; batCounterEnabled = false
    autoBatEnabled = false; autoLeftEnabled = false; autoRightEnabled = false
    antiLagEnabled = false; antiDieEnabled = false; vizFpsBoosterEnabled = false; autoTPDownEnabled = false; uiLocked = false
    CONFIG.AUTO_STEAL_ENABLED = false
    BAT_AIMBOT_SPEED = 58; BYPASS_AIMBOT_SPEED = 57; bypassToggled = false
    dropMode = 1; stretchEnabled = false; uiScaleValue = 100
    bodyLockEnabled = false
    stealBarMatchEnabled = false
    if mainUIScale then mainUIScale.Scale = 1 end
    if pbScale then pbScale.Scale = 1 end
    buttonScaleValue = 0.80; applyButtonScale(0.80); espEnabled = false
    currentAccessoryPack = "Off"; clearAllAccessories(LP.Character)
    if accSelectorLabel then accSelectorLabel.Text = "OFF" end
    if refreshAccessoryCards then refreshAccessoryCards() end
    for key, val in pairs(DEFAULT_KB) do if KB[key] then KB[key].kb = val.kb; KB[key].gp = val.gp end end
    if _ace_isfile(CONFIG_FILE) and type(_ace_delfile) == "function" then pcall(_ace_delfile, CONFIG_FILE) end
    resetFloatingPositions(); forceResetUI(); setSkyTheme("Off")
    updateProgressBarVisibility(); refreshSpeedModeLabel(); currentBgIndex = 1; applyBackgroundImage(1)
    _G._KZAXTabPosition = "Up"
    _G._KZAXJumpMode = "HOLD"
    if _G.KZAXTabPosClose then pcall(_G.KZAXTabPosClose) end
    if _G.KZAXApplyTabPosition then pcall(_G.KZAXApplyTabPosition, "Up") end
    _lastSavedJSON = nil; saveAllSettings()
    if LP.Character then setupMovementAndIndicators(LP.Character) end
    _isResetting = false
end
function updateProgressBarVisibility() if pbFrame then pbFrame.Visible = CONFIG.AUTO_STEAL_ENABLED end end
function applyShimmerToText(obj, speed)
    speed = speed or 0.8
    local grad = Instance.new("UIGradient", obj)
    grad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(75, 75, 75)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 75, 75))})
    grad.Rotation = 45; grad.Offset = Vector2.new(0,0)
    task.spawn(function()
        local t = 0
        while grad and grad.Parent do
            t = t + 0.02; grad.Offset = Vector2.new(math.sin(t * speed) * 0.4, 0); task.wait(0.04)
        end
    end)
    return grad
end

local _bwStrokes = {}
_G._bwLoopStarted = false

local function makeRotatingBW(target, thickness, speed) return nil, nil end
local function applyBWToEverything(root, thickness, speed) return end

function getDefaultButtonPosition(btnName)
    local positions = {TpBat = {0, 0}, DropBR = {86, 0}, AutoLeft = {176, 0},
        AutoBat = {86, 104}, AutoRight = {176, 104},
        TpDown = {86, 208}, Carry = {176, 208},
        Lagger1 = {86, 312}, Lagger2 = {176, 312}}
    local pos = positions[btnName] or {0, 0}
    return pos[1], pos[2]
end

local _CFnew = CFrame.new
local _V3new = Vector3.new

local HOMERO_CFG = {
    body = { 10725826963, 86500008, 86500054, 86500036, 86500064, 86500078 },
    aplicarCuerpo = true,
    items = {
        { id = 103227869700418, offset = _CFnew(0,0,0) },
        { id = 84952305140948,   offset = _CFnew(0,0,0) },
        { id = 122465238537030,  offset = _CFnew(0,0,0) },
    },
    shirt = nil,
    pants = "rbxassetid://78591690208112",
    skinColor = Color3.fromRGB(234,184,146),
    headColor = Color3.fromRGB(0,0,0),
}

local TAG = "LocalOutfit_"

local function loadObjectsHomero(id)
    local ok, res = pcall(function() return game:GetObjects("rbxassetid://" .. tostring(id)) end)
    if ok and typeof(res) == "table" and #res > 0 then return res end
    ok, res = pcall(function() return game:GetService("InsertService"):LoadAsset(id) end)
    if ok and res then return { res } end
    return nil
end

local function collectPartsHomero(objs)
    local out = {}
    for _, o in ipairs(objs) do
        if o:IsA("BasePart") then out[#out + 1] = o end
        for _, d in ipairs(o:GetDescendants()) do
            if d:IsA("BasePart") then out[#out + 1] = d end
        end
    end
    return out
end

local function findAttHomero(char, name)
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("Attachment") and p.Name == name and p.Parent:IsA("BasePart") then
            return p
        end
    end
end

local function applyBodyHomero(char)
    local total = 0
    for _, id in ipairs(HOMERO_CFG.body) do
        local objs = loadObjectsHomero(id)
        if objs then
            for _, mp in ipairs(collectPartsHomero(objs)) do
                local orig = char:FindFirstChild(mp.Name)
                if orig and orig:IsA("BasePart") then
                    local c = mp:Clone()
                    c.Name = TAG .. "body_" .. mp.Name
                    c.CanCollide = false
                    c.Anchored = false
                    c.Massless = true
                    c.Size = orig.Size
                    c.CFrame = orig.CFrame
                    c.Parent = char
                    local w = Instance.new("WeldConstraint")
                    w.Part0 = orig
                    w.Part1 = c
                    w.Parent = c
                    orig.Transparency = 1
                    total = total + 1
                end
            end
            for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
        end
    end
    return total
end

local function attachItemHomero(char, entry)
    local objs = loadObjectsHomero(entry.id)
    if not objs then return false end
    local handle
    for _, p in ipairs(collectPartsHomero(objs)) do
        if p.Name == "Handle" then handle = p; break end
        if not handle then handle = p end
    end
    if not handle then
        for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
        return false
    end
    local H = handle:Clone()
    for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
    H.Name = TAG .. "item_" .. tostring(entry.id)
    H.CanCollide = false
    H.Anchored = false
    H.Massless = true
    local wrap = H:FindFirstChildWhichIsA("WrapLayer")
    local target, c0, c1
    if wrap then
        target = char:FindFirstChild("UpperTorso")
              or char:FindFirstChild("Torso")
              or char:FindFirstChild("HumanoidRootPart")
        c0 = entry.offset or _CFnew()
        c1 = _CFnew()
    else
        local hAtt = H:FindFirstChildOfClass("Attachment")
        local bAtt = hAtt and findAttHomero(char, hAtt.Name)
        if bAtt then
            target = bAtt.Parent
            c0 = bAtt.CFrame * (entry.offset or _CFnew())
            c1 = hAtt.CFrame
        else
            target = char:FindFirstChild("Head")
            c0 = entry.offset or _CFnew(0, 1.4, 0)
            c1 = _CFnew()
        end
    end
    if not target then H:Destroy(); return false end
    H.CFrame = target.CFrame * c0 * c1:Inverse()
    H.Parent = char
    local w = Instance.new("Weld")
    w.Part0 = target
    w.Part1 = H
    w.C0 = c0
    w.C1 = c1
    w.Parent = H
    return true
end

function applyHomeroOutfit(char)
    if not char then char = LP.Character end
    if not char then return end
    char:WaitForChild("Humanoid", 10)
    char:WaitForChild("Head", 10)
    task.wait(0.4)
    for _, d in ipairs(char:GetChildren()) do
        if d.Name:sub(1, #TAG) == TAG then pcall(function() d:Destroy() end) end
    end
    if HOMERO_CFG.skinColor then
        local bc = char:FindFirstChildWhichIsA("BodyColors") or Instance.new("BodyColors")
        bc.HeadColor3 = HOMERO_CFG.headColor or HOMERO_CFG.skinColor
        bc.TorsoColor3 = HOMERO_CFG.skinColor
        bc.LeftArmColor3, bc.RightArmColor3 = HOMERO_CFG.skinColor, HOMERO_CFG.skinColor
        bc.LeftLegColor3, bc.RightLegColor3 = HOMERO_CFG.skinColor, HOMERO_CFG.skinColor
        bc.Parent = char
    end
    for _, a in ipairs(char:GetChildren()) do
        if a:IsA("Accessory") then
            local h = a:FindFirstChild("Handle")
            if h then h.Transparency = 1 end
        end
    end
    if HOMERO_CFG.shirt then
        local s = char:FindFirstChildWhichIsA("Shirt") or Instance.new("Shirt")
        s.Name = "Shirt"
        s.ShirtTemplate = HOMERO_CFG.shirt
        s.Parent = char
    end
    if HOMERO_CFG.pants then
        local p = char:FindFirstChildWhichIsA("Pants") or Instance.new("Pants")
        p.Name = "Pants"
        p.PantsTemplate = HOMERO_CFG.pants
        p.Parent = char
    end
    if HOMERO_CFG.aplicarCuerpo then applyBodyHomero(char) end
    for _, e in ipairs(HOMERO_CFG.items) do attachItemHomero(char, e) end
    return true
end

function applyNoOutfit(char)
    if not char then char = LP.Character end
    if not char then return end
    for _, d in ipairs(char:GetChildren()) do
        if d.Name:sub(1, #TAG) == TAG then pcall(function() d:Destroy() end) end
    end
    local oldAcc = char:FindFirstChild("AuFfitAccessory")
    if oldAcc then pcall(function() oldAcc:Destroy() end) end
    local oldKorblox = char:FindFirstChild("Korblox_RightLeg")
    if oldKorblox then pcall(function() oldKorblox:Destroy() end) end
    for _, d in ipairs(char:GetChildren()) do
        if d:IsA("CharacterMesh") and d.BodyPart == Enum.BodyPart.Head then
            pcall(function() d:Destroy() end)
        end
    end
    local head = char:FindFirstChild("Head")
    if head then
        head.Transparency = 0
        head.CanCollide = true
        head.LocalTransparencyModifier = 0
        local face = head:FindFirstChild("face")
        if face then face.Transparency = 0 end
        local sm = head:FindFirstChildWhichIsA("SpecialMesh")
        if sm then pcall(function() sm:Destroy() end) end
    end
    pcall(function()
        local neck = char:FindFirstChild("Neck")
        if neck then neck.Enabled = true end
    end)
    for _, partName in ipairs({"RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
        local limb = char:FindFirstChild(partName)
        if limb then limb.Transparency = 0 end
    end
    local shirt = char:FindFirstChildWhichIsA("Shirt")
    if shirt then pcall(function() shirt:Destroy() end) end
    local pants = char:FindFirstChildWhichIsA("Pants")
    if pants then pcall(function() pants:Destroy() end) end
    for _, a in ipairs(char:GetChildren()) do
        if a:IsA("Accessory") then
            local h = a:FindFirstChild("Handle")
            if h then h.Transparency = 0 end
        end
    end
    return true
end

-- ============================================================
-- BUILD GUI
-- ============================================================
function buildGui()
    local RED = Color3.fromRGB(255, 255, 255)
    local BG = Color3.fromRGB(0, 0, 0)
    local BG2 = Color3.fromRGB(8, 8, 8)
    local ROW_BG = Color3.fromRGB(8, 8, 8)
    local ROW_BORDER = Color3.fromRGB(120, 120, 120)
    local GRAY = Color3.fromRGB(255, 255, 255)
    local INP = Color3.fromRGB(8, 8, 8)
    local TAB_ACTIVE = Color3.fromRGB(255, 255, 255)
    local TAB_INACT = Color3.fromRGB(255, 255, 255)
    local SECT_LBL = Color3.fromRGB(255, 255, 255)
    local TOGGLE_BG = Color3.fromRGB(8, 8, 8)
    local KNOB = Color3.fromRGB(255, 255, 255)
    local TRACK_ACTIVE = Color3.fromRGB(8, 8, 8)

    local GUI_W, GUI_H = 350, 520
    local old = game:GetService("CoreGui"):FindFirstChild("KZAX")
    if old then old:Destroy() end
    local pg = LP:FindFirstChild("PlayerGui")
    if pg then local o = pg:FindFirstChild("KZAX"); if o then o:Destroy() end end
    gui = Instance.new("ScreenGui")
    gui.Name = "KZAX"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999999
    gui.IgnoreGuiInset = true
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    if not pcall(function() gui.Parent = game:GetService("CoreGui") end) then gui.Parent = LP:WaitForChild("PlayerGui") end
    main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, GUI_W, 0, GUI_H)
    main.Position = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2)
    main.BackgroundColor3 = BG; main.BackgroundTransparency = 1
    main.BorderSizePixel = 0; main.ClipsDescendants = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)
    mainUIScale = Instance.new("UIScale", main); mainUIScale.Scale = uiScaleValue / 100
    setupBackgroundImage(); applyBackgroundImage(currentBgIndex)
    local shadow = Instance.new("Frame", main)
    shadow.Size = UDim2.new(1, 12, 1, 12); shadow.Position = UDim2.new(0, -6, 0, 6)
    shadow.BackgroundColor3 = Color3.fromRGB(0,0,0); shadow.BackgroundTransparency = 0.9
    shadow.BorderSizePixel = 0; shadow.ZIndex = 2
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 22)

    local titleLabel = Instance.new("TextLabel", main)
    titleLabel.Name = "TitleMain"
    titleLabel.Size = UDim2.new(1, -80, 0, 110)
    titleLabel.Position = UDim2.new(0, 40, 0, -6)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "KZAX"
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextScaled = true
    titleLabel.TextXAlignment = Enum.TextXAlignment.Center
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.ZIndex = 20

    local stroke1 = Instance.new("UIStroke", titleLabel)
    stroke1.Name = "TitleOuterStroke"
    stroke1.Color = Color3.fromRGB(0, 0, 0)
    stroke1.Thickness = 6
    stroke1.Transparency = 0
    stroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

    local stroke2 = Instance.new("UIStroke", titleLabel)
    stroke2.Name = "TitleInnerStroke"
    stroke2.Color = Color3.fromRGB(60, 60, 60)
    stroke2.Thickness = 2
    stroke2.Transparency = 0.2
    stroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

    local grad = Instance.new("UIGradient", titleLabel)
    grad.Name = "TitleGradient"
    grad.Rotation = 90
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(220, 220, 220)),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(160, 160, 160)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(90, 90, 90))
    })

    local closeBtn = Instance.new("TextButton", main)
    closeBtn.Size = UDim2.new(0, 34, 0, 34); closeBtn.Position = UDim2.new(1, -44, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(0,0,0); closeBtn.BackgroundTransparency = 1
    closeBtn.BorderSizePixel = 0; closeBtn.Text = "−"; closeBtn.TextColor3 = RED
    closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 26; closeBtn.AutoButtonColor = false
    closeBtn.ZIndex = 200
    closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = GRAY end)
    closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = RED end)

    do
        local dragging = false
        local dragInput = nil
        local dragStart = nil
        local startPos = nil
        local moved = false
        local dragThreshold = 3

        titleLabel.Active = true
        titleLabel.InputBegan:Connect(function(input)
            if uiLocked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                moved = false
                dragStart = input.Position
                startPos = main.Position
                dragInput = input
            end
        end)

        titleLabel.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if not dragging or uiLocked then return end
            if input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                if delta.Magnitude >= dragThreshold then moved = true end
                if moved then
                    main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    savedMainGuiPos = {
                        XScale = main.Position.X.Scale, XOffset = main.Position.X.Offset,
                        YScale = main.Position.Y.Scale, YOffset = main.Position.Y.Offset
                    }
                end
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if not dragging then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if moved and main and main.Parent then
                    persistMainGuiPosition("GUI menu position")
                end
                dragging = false
                dragInput = nil
                dragStart = nil
                startPos = nil
                moved = false
            end
        end)
    end

    miniBtn = Instance.new("TextButton", gui)
    miniBtn.Size = UDim2.new(0, 118, 0, 30); miniBtn.Position = UDim2.new(0, 16, 0, 58)
    miniBtn.BackgroundColor3 = BG2; miniBtn.BackgroundTransparency = 0
    miniBtn.BorderSizePixel = 0; miniBtn.Text = "KZAX"; miniBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
    miniBtn.Font = Enum.Font.GothamBlack; miniBtn.TextSize = 14; miniBtn.ZIndex = 1000
    miniBtn.Visible = true
    Instance.new("UICorner", miniBtn).CornerRadius = UDim.new(0, 8)

    local miniStroke1 = Instance.new("UIStroke", miniBtn)
    miniStroke1.Color = Color3.fromRGB(0, 0, 0)
    miniStroke1.Thickness = 3
    miniStroke1.Transparency = 0
    miniStroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

    local miniStroke2 = Instance.new("UIStroke", miniBtn)
    miniStroke2.Color = Color3.fromRGB(60, 60, 60)
    miniStroke2.Thickness = 1
    miniStroke2.Transparency = 0.2
    miniStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual

    local miniGrad = Instance.new("UIGradient", miniBtn)
    miniGrad.Rotation = 90
    miniGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(220, 220, 220)),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(160, 160, 160)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(90, 90, 90))
    })

    local function animateShow()
        miniBtn.Visible = true
        miniBtn.ZIndex = 1000
        main.Visible = true
        main.Size = UDim2.new(0, GUI_W, 0, GUI_H)
        local targetPosition = main.Position
        if not savedMainGuiPos then
            targetPosition = UDim2.new(0.5, -GUI_W/2, 0.5, -GUI_H/2)
            main.Position = targetPosition
        end
        local slideStart = UDim2.new(
            targetPosition.X.Scale, targetPosition.X.Offset,
            targetPosition.Y.Scale, targetPosition.Y.Offset - math.max(GUI_H, 220)
        )
        main.Position = slideStart
        -- Keep the panel surface transparent so the background image stays visible
        -- throughout the slide-in animation.
        main.BackgroundTransparency = 1
        TS:Create(main, TweenInfo.new(0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = targetPosition
        }):Play()
        pcall(saveAllSettings)
    end
    local function animateHide()
        main.Visible = false
        miniBtn.Visible = true
    end
    showGui = function() if main.Visible then return end; animateShow() end
    hideGui = function() if not main.Visible then return end; animateHide() end
    closeBtn.Activated:Connect(hideGui)
    miniBtn.Activated:Connect(function() if main.Visible then hideGui() else showGui() end end)
    task.spawn(function()
        while gui and gui.Parent do
            if miniBtn then miniBtn.Visible = true; miniBtn.ZIndex = 1000 end
            task.wait(0.25)
        end
    end)
    local tabBar = Instance.new("Frame", main)
    tabBar.Name = "RoundedTabContainer"
    tabBar.Size = UDim2.new(1, -18, 0, 48); tabBar.Position = UDim2.new(0, 9, 1, -58)
    tabBar.BackgroundTransparency = 1
    tabBar.BorderSizePixel = 0; tabBar.ZIndex = 10
    local tabPadding = Instance.new("UIPadding", tabBar)
    tabPadding.PaddingLeft = UDim.new(0, 3); tabPadding.PaddingRight = UDim.new(0, 3)
    tabPadding.PaddingTop = UDim.new(0, 3); tabPadding.PaddingBottom = UDim.new(0, 3)
    local tabs = {"Move", "Combat", "Visual", "Keybind", "Config"}
    local tabPages = {"Moment", "Combat", "Visual", "Keybinds", "Main"}
    local tabButtons = {}
    local tabContent = Instance.new("Frame", main)
    tabContent.Size = UDim2.new(1, -18, 1, -128); tabContent.Position = UDim2.new(0, 9, 0, 62)
    tabContent.BackgroundTransparency = 1; tabContent.ClipsDescendants = true; tabContent.ZIndex = 5
    local contentPages = {}
    for i, name in ipairs(tabs) do
        local pageName = tabPages[i]
        local btn = Instance.new("TextButton", tabBar)
        btn.Size = UDim2.new(0.20, -6, 0, 42); btn.Position = UDim2.new((i-1) * 0.20, 3, 0, 3)
        btn.BackgroundColor3 = Color3.fromRGB(8, 8, 8); btn.BackgroundTransparency = 0.18
        btn.BorderSizePixel = 0; btn.Text = name; btn.TextColor3 = TAB_INACT
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
        btn.TextTruncate = Enum.TextTruncate.AtEnd; btn.AutoButtonColor = false; btn.ZIndex = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local page = Instance.new("ScrollingFrame", tabContent)
        page.Size = UDim2.new(1, 0, 1, 0); page.Position = UDim2.new(0, 0, 0, 0)
        page.BackgroundColor3 = Color3.fromRGB(8, 8, 8); page.BackgroundTransparency = 0.6
        page.BorderSizePixel = 0; page.ClipsDescendants = true
        page.ScrollBarThickness = 0; page.ScrollBarImageTransparency = 1
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.ScrollingDirection = Enum.ScrollingDirection.Y; page.ZIndex = 6
        Instance.new("UICorner", page).CornerRadius = UDim.new(0, 16)
        page.Visible = (i == 1)
        local layout = Instance.new("UIListLayout", page)
        layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Padding = UDim.new(0, 4)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        local padding = Instance.new("UIPadding", page)
        padding.PaddingLeft = UDim.new(0, 8); padding.PaddingRight = UDim.new(0, 8)
        padding.PaddingTop = UDim.new(0, 4); padding.PaddingBottom = UDim.new(0, 8)
        contentPages[pageName] = page
        btn.Activated:Connect(function()
            for _, pg2 in pairs(contentPages) do pg2.Visible = false end
            page.Visible = true
            for _, b in ipairs(tabButtons) do
                b.TextColor3 = TAB_INACT; b.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
                local bs = b:FindFirstChild("TabStroke"); if bs then bs.Color = Color3.fromRGB(8, 8, 8); bs.Thickness = 1 end
            end
            btn.TextColor3 = TAB_ACTIVE; btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            local activeStroke = btn:FindFirstChild("TabStroke")
            if activeStroke then activeStroke.Color = Color3.fromRGB(255, 255, 255); activeStroke.Thickness = 2.5; activeStroke.Transparency = 0 end
        end)
        table.insert(tabButtons, btn)
    end
    if tabButtons[1] then
        tabButtons[1].TextColor3 = TAB_ACTIVE; tabButtons[1].BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        local firstStroke = tabButtons[1]:FindFirstChild("TabStroke")
        if firstStroke then firstStroke.Color = Color3.fromRGB(255, 255, 255); firstStroke.Thickness = 2.5; firstStroke.Transparency = 0 end
    end

    do
        local H = Enum.FillDirection.Horizontal
        local V = Enum.FillDirection.Vertical
        local W_NARROW, W_WIDE = 350, 385
        local BAR_W = 32

        local LAYOUTS = {
            Up = {
                wide = false,
                barPos = UDim2.new(0, 9, 1, -58),
                barSize = UDim2.new(1, -18, 0, 48),
                dir = H,
                btnSize = UDim2.new(0.20, -6, 0, 42),
                btnPosFn = function(i) return UDim2.new((i-1)*0.20, 3, 0, 3) end,
                contentPos = UDim2.new(0, 9, 0, 62),
                contentSize = UDim2.new(1, -18, 1, -128),
            },
            Bottom = {
                wide = false,
                barPos = UDim2.new(0, 9, 0, 62),
                barSize = UDim2.new(1, -18, 0, 48),
                dir = H,
                btnSize = UDim2.new(0.20, -6, 0, 42),
                btnPosFn = function(i) return UDim2.new((i-1)*0.20, 3, 0, 3) end,
                contentPos = UDim2.new(0, 9, 1, -128),
                contentSize = UDim2.new(1, -18, 1, -128),
            },
            Left = {
                wide = true,
                barPos = UDim2.new(0, 9, 0, 62),
                barSize = UDim2.new(0, BAR_W, 1, -128),
                dir = V,
                btnSize = UDim2.new(0, 42, 0, 42),
                btnPosFn = function(i) return UDim2.new(0, 3, (i-1)*0.20, 3) end,
                contentPos = UDim2.new(0, 9 + BAR_W + 6, 0, 62),
                contentSize = UDim2.new(1, -18 - BAR_W - 6, 1, -128),
            },
            Right = {
                wide = true,
                barPos = UDim2.new(1, -9 - BAR_W, 0, 62),
                barSize = UDim2.new(0, BAR_W, 1, -128),
                dir = V,
                btnSize = UDim2.new(0, 42, 0, 42),
                btnPosFn = function(i) return UDim2.new(0, 3, (i-1)*0.20, 3) end,
                contentPos = UDim2.new(0, 9, 0, 62),
                contentSize = UDim2.new(1, -18 - BAR_W - 6, 1, -128),
            },
        }

        function _G.KZAXApplyTabPosition(pos)
            pos = _G.KZAXValidTabPosition(pos)
            local L = LAYOUTS[pos]
            if not L or not tabBar or not tabContent then return end
            _G._KZAXTabPosition = pos
            local newW = L.wide and W_WIDE or W_NARROW
            main.Size = UDim2.new(0, newW, 0, 520)
            if mainUIScale then mainUIScale.Scale = uiScaleValue / 100 end
            tabBar.Position = L.barPos
            tabBar.Size = L.barSize
            local layout = tabBar:FindFirstChildOfClass("UIListLayout")
            if not layout then
                layout = Instance.new("UIListLayout", tabBar)
                layout.SortOrder = Enum.SortOrder.LayoutOrder
            end
            layout.FillDirection = L.dir
            layout.Padding = UDim.new(0, 4)
            layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            layout.VerticalAlignment = Enum.VerticalAlignment.Center
            for i, btn in ipairs(tabButtons) do
                btn.Size = L.btnSize
                btn.Position = L.btnPosFn(i)
                btn.LayoutOrder = i
            end
            tabContent.Position = L.contentPos
            tabContent.Size = L.contentSize
        end
    end

    local pageCounters = {}
    local function getNextOrder(page)
        if not pageCounters[page] then pageCounters[page] = 0 end
        pageCounters[page] = pageCounters[page] + 1
        return pageCounters[page]
    end
    local function mkSect(page, txt)
        local f = Instance.new("Frame", page)
        f.Size = UDim2.new(1, 0, 0, 24); f.BackgroundTransparency = 1
        f.BorderSizePixel = 0; f.LayoutOrder = getNextOrder(page); f.ZIndex = 7
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, -16, 1, 0); l.Position = UDim2.new(0, 8, 0, 0)
        l.BackgroundTransparency = 1; l.Text = txt:upper(); l.TextColor3 = SECT_LBL
        l.Font = Enum.Font.GothamBlack; l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextStrokeColor3 = Color3.fromRGB(120, 120, 120); l.TextStrokeTransparency = 0.3; l.ZIndex = 8
        return f
    end
    local function mkRow(page, h)
        h = h or 30
        local f = Instance.new("Frame", page)
        f.Size = UDim2.new(1, -4, 0, h); f.BackgroundColor3 = ROW_BG
        f.BackgroundTransparency = 0.6; f.BorderSizePixel = 0
        f.LayoutOrder = getNextOrder(page); f.ZIndex = 7
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
        local rowStroke = Instance.new("UIStroke", f)
        rowStroke.Color = ROW_BORDER; rowStroke.Thickness = 1; rowStroke.Transparency = 0.4
        f.MouseEnter:Connect(function() f.BackgroundColor3 = Color3.fromRGB(8, 8, 8) end)
        f.MouseLeave:Connect(function() f.BackgroundColor3 = ROW_BG end)
        return f
    end
    local function mkLabel(row, txt)
        local l = Instance.new("TextLabel", row)
        l.Size = UDim2.new(0.55, 0, 1, 0); l.Position = UDim2.new(0, 10, 0, 0)
        l.BackgroundTransparency = 1; l.Text = txt; l.TextColor3 = RED
        l.Font = Enum.Font.GothamBlack; l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left; l.TextTruncate = Enum.TextTruncate.AtEnd
        l.TextStrokeColor3 = Color3.fromRGB(0,0,0); l.TextStrokeTransparency = 0.5; l.ZIndex = 8
        return l
    end
    local function mkPill(row, offset)
        local pill = Instance.new("Frame", row)
        pill.Size = UDim2.new(0, 34, 0, 18); pill.Position = UDim2.new(1, -(offset or 44), 0.5, -9)
        pill.BackgroundColor3 = TOGGLE_BG; pill.BorderSizePixel = 0; pill.ZIndex = 8
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
        local stroke = Instance.new("UIStroke", pill)
        stroke.Color = ROW_BORDER; stroke.Thickness = 1.2; stroke.Transparency = 0.6
        local dot = Instance.new("Frame", pill)
        dot.Size = UDim2.new(0, 13, 0, 13); dot.Position = UDim2.new(0, 3, 0.5, -6.5)
        dot.BackgroundColor3 = KNOB; dot.BorderSizePixel = 0; dot.ZIndex = 9
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        return pill, dot
    end
    local function animPill(pill, dot, on)
        TS:Create(pill, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {BackgroundColor3 = on and TRACK_ACTIVE or TOGGLE_BG}):Play()
        TS:Create(dot, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
            Position = on and UDim2.new(1, -17, 0.5, -6.5) or UDim2.new(0, 3, 0.5, -6.5),
            BackgroundColor3 = on and Color3.fromRGB(255, 255, 255) or KNOB}):Play()
        local stroke = pill:FindFirstChildOfClass("UIStroke")
        if stroke then TS:Create(stroke, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
            Color = on and RED or ROW_BORDER, Transparency = on and 0 or 0.6}):Play() end
    end
    local function mkToggle(page, txt, cb)
        local row = mkRow(page, 34); mkLabel(row, txt)
        local pill, dot = mkPill(row, 44)
        local on = false
        local function sv(s) on = s; animPill(pill, dot, s) end
        local clk = Instance.new("TextButton", pill)
        clk.Size = UDim2.new(1,0,1,0); clk.BackgroundTransparency = 1; clk.Text = ""
        clk.AutoButtonColor = false; clk.ZIndex = 10
        clk.Activated:Connect(function() on = not on; sv(on); pcall(cb, on) end)
        return sv, row
    end
    local function mkBox(parent, default, w, xOff, cb)
        local tb = Instance.new("TextBox", parent)
        local bw = w or 50
        local xo = math.max(xOff or 56, bw + 12)
        tb.Size = UDim2.new(0, bw, 0, 22); tb.Position = UDim2.new(1, -xo, 0.5, -11)
        tb.BackgroundColor3 = INP; tb.BackgroundTransparency = 0.7; tb.BorderSizePixel = 0
        tb.Text = tostring(default); tb.TextColor3 = RED; tb.Font = Enum.Font.GothamBlack
        tb.TextSize = 11; tb.ClearTextOnFocus = false; tb.ZIndex = 8
        Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
        local bs = Instance.new("UIStroke", tb)
        bs.Color = ROW_BORDER; bs.Thickness = 1.2; bs.Transparency = 0.25
        tb.Focused:Connect(function() bs.Color = RED; bs.Transparency = 0 end)
        tb.FocusLost:Connect(function()
            bs.Color = ROW_BORDER; bs.Transparency = 0.25
            if cb then local n = tonumber(tb.Text); if n then cb(n) else tb.Text = tostring(default) end end
        end)
        return tb
    end
    local function mkKeyButton(parent, kbEntry)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0, 80, 0, 22); btn.Position = UDim2.new(1, -88, 0.5, -11)
        btn.BackgroundColor3 = INP; btn.BackgroundTransparency = 0.5; btn.BorderSizePixel = 0
        local function getLabel() return (kbEntry.gp and kbEntry.gp.Name) or (kbEntry.kb and kbEntry.kb.Name) or "None" end
        btn.Text = getLabel(); btn.TextColor3 = RED; btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 9; btn.ZIndex = 8; btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local li = false; local lc; local pv = btn.Text; local listenStart = 0
        btn.Activated:Connect(function()
            if li then li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end; btn.Text = pv; btn.TextColor3 = RED; return end
            pv = btn.Text; li = true; _anyKeyListening = true; listenStart = tick(); btn.Text = "..."; btn.TextColor3 = RED
            lc = UIS.InputBegan:Connect(function(inp)
                if not li then return end
                if inp.KeyCode == Enum.KeyCode.Escape then li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end; btn.Text = pv; btn.TextColor3 = RED; return end
                local isGp = isGamepadInput(inp)
                if isGp and tick()-listenStart < 0.15 then return end
                if not isBindableInput(inp) then return end
                btn.Text = inp.KeyCode.Name; pv = inp.KeyCode.Name; btn.TextColor3 = RED
                li = false; _anyKeyListening = false; if lc then lc:Disconnect(); lc = nil end
                if isGp then kbEntry.gp = inp.KeyCode; kbEntry.kb = nil else kbEntry.kb = inp.KeyCode; kbEntry.gp = nil end
            end)
        end)
        table.insert(keyButtonRefs, {btn = btn, entry = kbEntry})
        return btn
    end
    local function addKeybindRow(page, labelText, kbEntry)
        local row = mkRow(page, 34); mkLabel(row, labelText); mkKeyButton(row, kbEntry)
    end

    -- ============================================================
    -- MOVE TAB
    -- ============================================================
    local momentPage = contentPages["Moment"]
    mkSect(momentPage, "Speed")
    do local row = mkRow(momentPage, 30); mkLabel(row, "Normal Speed"); normalBox = mkBox(row, NS, 50, 56, function(v) if v > 0 and v <= 500 then NS = v; SpeedModule.setNormalSpeed(v) end; saveAllSettings() end) end
    do local row = mkRow(momentPage, 30); mkLabel(row, "Carry Speed"); carryBox = mkBox(row, CS, 50, 56, function(v) if v > 0 and v <= 500 then CS = v; SpeedModule.setCarrySpeed(v) end; saveAllSettings() end) end
    do local row = mkRow(momentPage, 30); mkLabel(row, "Lagger 1 Speed"); laggerBox = mkBox(row, LAGGER_SPEED_1, 50, 56, function(v) if v > 0 and v <= 500 then LAGGER_SPEED_1 = v; SpeedModule.setLaggerSpeed(v) end; saveAllSettings() end) end
    do local row = mkRow(momentPage, 30); mkLabel(row, "Lagger 2 Speed"); lagger2Box = mkBox(row, LAGGER_SPEED_2, 50, 56, function(v) if v > 0 and v <= 500 then LAGGER_SPEED_2 = v; SpeedModule.setLaggerCarrySpeed(v) end; saveAllSettings() end) end
    do
        local row = mkRow(momentPage, 30); mkLabel(row, "Current Mode")
        modeValLbl = Instance.new("TextLabel", row)
        modeValLbl.Size = UDim2.new(0, 110, 1, 0); modeValLbl.Position = UDim2.new(1, -118, 0, 0)
        modeValLbl.BackgroundTransparency = 1; modeValLbl.Text = "Normal"
        modeValLbl.TextColor3 = GRAY; modeValLbl.Font = Enum.Font.GothamBlack
        modeValLbl.TextSize = 11; modeValLbl.TextXAlignment = Enum.TextXAlignment.Right; modeValLbl.ZIndex = 8
        local clk = Instance.new("TextButton", row)
        clk.Size = UDim2.new(1,0,1,0); clk.BackgroundTransparency = 1; clk.Text = ""
        clk.AutoButtonColor = false; clk.ZIndex = 8
        clk.Activated:Connect(function() toggleCarryMode(); saveAllSettings() end)
    end
    mkSect(momentPage, "Jump & Movement")

    -- ================= INFINITE JUMP WITH MANUAL/HOLD SELECTOR =================
    do
        local jumpMode = _G._KZAXJumpMode or "HOLD"

        local row = mkRow(momentPage, 34)
        mkLabel(row, "Infinite Jump")

        local jumpPill, jumpDot = mkPill(row, 44)
        local jumpOn = false
        setJumpToggleState = function(state)
            if jumpOn == state then return end
            jumpOn = state
            animPill(jumpPill, jumpDot, state)
            if _G.InfiniteJump then
                _G.InfiniteJump.SetMode(jumpMode)
                _G.InfiniteJump.SetEnabled(state)
            end
            saveAllSettings()
        end
        local jumpClk = Instance.new("TextButton", jumpPill)
        jumpClk.Size = UDim2.new(1,0,1,0); jumpClk.BackgroundTransparency = 1; jumpClk.Text = ""
        jumpClk.AutoButtonColor = false; jumpClk.ZIndex = 10
        jumpClk.Activated:Connect(function() setJumpToggleState(not jumpOn) end)
        setJumpVisual = function(state) setJumpToggleState(state) end

        -- Triangle dropdown button
        local arrow = Instance.new("TextButton", row)
        arrow.Size = UDim2.new(0, 30, 0, 24)
        arrow.Position = UDim2.new(1, -82, 0.5, -12)
        arrow.BackgroundColor3 = INP
        arrow.BackgroundTransparency = 0.15
        arrow.BorderSizePixel = 0
        arrow.Text = "▼"
        arrow.TextColor3 = RED
        arrow.Font = Enum.Font.GothamBlack
        arrow.TextSize = 12
        arrow.AutoButtonColor = false
        arrow.ZIndex = 12
        Instance.new("UICorner", arrow).CornerRadius = UDim.new(0, 7)
        local arrowStroke = Instance.new("UIStroke", arrow)
        arrowStroke.Color = ROW_BORDER
        arrowStroke.Thickness = 1.2
        arrowStroke.Transparency = 0.35

        local optionsFrame = Instance.new("Frame", momentPage)
        optionsFrame.Size = UDim2.new(1, -16, 0, 34)
        optionsFrame.BackgroundTransparency = 1
        optionsFrame.Visible = false
        optionsFrame.Active = false
        optionsFrame.ClipsDescendants = true
        optionsFrame.ZIndex = 10
        optionsFrame.LayoutOrder = getNextOrder(momentPage)

        local optLayout = Instance.new("UIListLayout", optionsFrame)
        optLayout.FillDirection = Enum.FillDirection.Horizontal
        optLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        optLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        optLayout.Padding = UDim.new(0, 6)

        local open = false
        local setOpen

        local function updateChoiceVisuals()
            for _, child in ipairs(optionsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    local selected = (child:GetAttribute("JumpMode") == jumpMode)
                    local cs = child:FindFirstChildOfClass("UIStroke")
                    if cs then
                        cs.Color = selected and RED or ROW_BORDER
                        cs.Thickness = selected and 1.8 or 1.1
                        cs.Transparency = selected and 0.05 or 0.35
                    end
                end
            end
        end

        local function makeJumpOption(text, mode)
            local b = Instance.new("TextButton", optionsFrame)
            b.Size = UDim2.new(0.5, -3, 0, 30)
            b.BackgroundColor3 = INP
            b.BackgroundTransparency = 0.3
            b.BorderSizePixel = 0
            b.Text = text
            b.TextColor3 = RED
            b.Font = Enum.Font.GothamBlack
            b.TextSize = 10
            b.AutoButtonColor = false
            b.ZIndex = 11
            b:SetAttribute("JumpMode", mode)
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

            local st = Instance.new("UIStroke", b)
            st.Color = (jumpMode == mode) and RED or ROW_BORDER
            st.Thickness = (jumpMode == mode) and 1.8 or 1.1
            st.Transparency = (jumpMode == mode) and 0.05 or 0.35

            b.Activated:Connect(function()
                jumpMode = mode
                _G._KZAXJumpMode = mode
                if _G.InfiniteJump then
                    _G.InfiniteJump.SetMode(mode)
                end
                updateChoiceVisuals()
                saveAllSettings()
                setOpen(false)
            end)
            return b
        end

        makeJumpOption("MANUAL JUMP", "MANUAL")
        makeJumpOption("HOLD JUMP", "HOLD")

        setOpen = function(state)
            open = state
            arrow.Text = state and "▲" or "▼"
            arrow.Rotation = state and 180 or 0

            if state then
                updateChoiceVisuals()
                optionsFrame.Visible = true
                optionsFrame.Active = true
                for _, child in ipairs(optionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundTransparency = 1
                        child.Size = UDim2.new(0.5, -3, 0, 22)
                        TS:Create(child, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.3,
                            Size = UDim2.new(0.5, -3, 0, 30)
                        }):Play()
                    end
                end
            else
                optionsFrame.Active = false
                for _, child in ipairs(optionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        TS:Create(child, TweenInfo.new(0.10, Enum.EasingStyle.Quad), {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0.5, -3, 0, 20)
                        }):Play()
                    end
                end
                task.delay(0.11, function()
                    if not open and optionsFrame.Parent then
                        optionsFrame.Visible = false
                    end
                end)
            end
        end

        arrow.Activated:Connect(function()
            setOpen(not open)
        end)

        task.defer(function()
            if _G._KZAXJumpMode then
                jumpMode = _G._KZAXJumpMode
            end
            if _G.InfiniteJump then
                _G.InfiniteJump.SetMode(jumpMode)
            end
            updateChoiceVisuals()
        end)
    end

    autoLeftSetVisual = mkToggle(momentPage, "Auto Left", function(on)
        autoLeftEnabled = on
        if on then
            if _G.ForceStopTPBat then pcall(_G.ForceStopTPBat) end
            startAutoLeft()
            if bypassSetVisual then bypassSetVisual(false) end
        else
            stopAutoLeft()
        end
        if mobSetAutoLeft then mobSetAutoLeft(on) end
        saveAllSettings()
    end)
    autoRightSetVisual = mkToggle(momentPage, "Auto Right", function(on)
        autoRightEnabled = on
        if on then
            if _G.ForceStopTPBat then pcall(_G.ForceStopTPBat) end
            startAutoRight()
            if bypassSetVisual then bypassSetVisual(false) end
        else
            stopAutoRight()
        end
        if mobSetAutoRight then mobSetAutoRight(on) end
        saveAllSettings()
    end)
    mkSect(momentPage, "Drop & TP")
    local dropBrainrotRow
    dropBrainrotSetVisual, dropBrainrotRow = mkToggle(momentPage, "Drop Brainrot", function(on)
        if on then executeDropWithToggle(function(v) dropBrainrotSetVisual(v); if mobSetDropBR then mobSetDropBR(v) end end) end
    end)
    do
        local row = dropBrainrotRow
        local arrow = Instance.new("TextButton", row)
        arrow.Size = UDim2.new(0, 30, 0, 24)
        arrow.Position = UDim2.new(1, -82, 0.5, -12)
        arrow.BackgroundColor3 = INP
        arrow.BackgroundTransparency = 0.15
        arrow.BorderSizePixel = 0
        arrow.Text = "▼"
        arrow.TextColor3 = RED
        arrow.Font = Enum.Font.GothamBlack
        arrow.TextSize = 12
        arrow.AutoButtonColor = false
        arrow.ZIndex = 12
        Instance.new("UICorner", arrow).CornerRadius = UDim.new(0, 7)
        local arrowStroke = Instance.new("UIStroke", arrow)
        arrowStroke.Color = ROW_BORDER
        arrowStroke.Thickness = 1.2
        arrowStroke.Transparency = 0.35

        local optionsFrame = Instance.new("Frame", momentPage)
        optionsFrame.Size = UDim2.new(1, -16, 0, 34)
        optionsFrame.BackgroundTransparency = 1
        optionsFrame.Visible = false
        optionsFrame.Active = false
        optionsFrame.ClipsDescendants = true
        optionsFrame.ZIndex = 10
        optionsFrame.LayoutOrder = getNextOrder(momentPage)

        local optLayout = Instance.new("UIListLayout", optionsFrame)
        optLayout.FillDirection = Enum.FillDirection.Horizontal
        optLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        optLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        optLayout.Padding = UDim.new(0, 6)

        local open = false
        local setOpen

        local function updateChoiceVisuals()
            for _, child in ipairs(optionsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    local selected = (child:GetAttribute("DropMode") == dropMode)
                    local cs = child:FindFirstChildOfClass("UIStroke")
                    if cs then
                        cs.Color = selected and RED or ROW_BORDER
                        cs.Thickness = selected and 1.8 or 1.1
                        cs.Transparency = selected and 0.05 or 0.35
                    end
                end
            end
        end

        local function makeDropOption(text, mode)
            local b = Instance.new("TextButton", optionsFrame)
            b.Size = UDim2.new(0.5, -3, 0, 30)
            b.BackgroundColor3 = INP
            b.BackgroundTransparency = 0.3
            b.BorderSizePixel = 0
            b.Text = text
            b.TextColor3 = RED
            b.Font = Enum.Font.GothamBlack
            b.TextSize = 10
            b.AutoButtonColor = false
            b.ZIndex = 11
            b:SetAttribute("DropMode", mode)
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

            local st = Instance.new("UIStroke", b)
            st.Color = (dropMode == mode) and RED or ROW_BORDER
            st.Thickness = (dropMode == mode) and 1.8 or 1.1
            st.Transparency = (dropMode == mode) and 0.05 or 0.35

            b.Activated:Connect(function()
                if dropActive then stopDropBrainrot() end
                dropMode = mode
                updateChoiceVisuals()
                saveAllSettings()
                setOpen(false)
            end)
            return b
        end

        makeDropOption("FLING", 1)
        makeDropOption("JUMP DROP", 2)

        setOpen = function(state)
            open = state
            arrow.Text = state and "▲" or "▼"
            arrow.Rotation = state and 180 or 0

            if state then
                updateChoiceVisuals()
                optionsFrame.Visible = true
                optionsFrame.Active = true
                for _, child in ipairs(optionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.BackgroundTransparency = 1
                        child.Size = UDim2.new(0.5, -3, 0, 22)
                        TS:Create(child, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 0.3,
                            Size = UDim2.new(0.5, -3, 0, 30)
                        }):Play()
                    end
                end
            else
                optionsFrame.Active = false
                for _, child in ipairs(optionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        TS:Create(child, TweenInfo.new(0.10, Enum.EasingStyle.Quad), {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0.5, -3, 0, 20)
                        }):Play()
                    end
                end
                task.delay(0.11, function()
                    if not open and optionsFrame.Parent then
                        optionsFrame.Visible = false
                    end
                end)
            end
        end

        arrow.Activated:Connect(function()
            setOpen(not open)
        end)
    end
    do
        local row = mkRow(momentPage, 30); mkLabel(row, "TP Down")
        local clk = Instance.new("TextButton", row)
        clk.Size = UDim2.new(0.58, 0, 1, 0); clk.BackgroundTransparency = 1; clk.Text = ""
        clk.AutoButtonColor = false; clk.ZIndex = 8
        clk.Activated:Connect(function() runTPDown() end)
        local actLbl = Instance.new("TextLabel", row)
        actLbl.Size = UDim2.new(0, 70, 1, 0); actLbl.Position = UDim2.new(1, -78, 0, 0)
        actLbl.BackgroundTransparency = 1; actLbl.Text = "ACTIVATE"
        actLbl.TextColor3 = RED; actLbl.Font = Enum.Font.GothamBlack
        actLbl.TextSize = 9; actLbl.TextXAlignment = Enum.TextXAlignment.Right; actLbl.ZIndex = 8
    end
    do
        local row = mkRow(momentPage, 34)
        mkLabel(row, "Auto TP Down")
        local pill, dot = mkPill(row, 44)
        local on = false
        local function setToggle(state)
            on = state
            animPill(pill, dot, state)
        end
        local clk = Instance.new("TextButton", pill)
        clk.Size = UDim2.new(1,0,1,0); clk.BackgroundTransparency = 1; clk.Text = ""
        clk.AutoButtonColor = false; clk.ZIndex = 10
        clk.Activated:Connect(function()
            setToggle(not on)
            if on then startAutoTPDown() else stopAutoTPDown() end
            saveAllSettings()
        end)
        local arrow = Instance.new("TextButton", row)
        arrow.Size = UDim2.new(0, 30, 0, 24)
        arrow.Position = UDim2.new(1, -82, 0.5, -12)
        arrow.BackgroundColor3 = INP
        arrow.BackgroundTransparency = 0.15
        arrow.BorderSizePixel = 0
        arrow.Text = "▼"
        arrow.TextColor3 = RED
        arrow.Font = Enum.Font.GothamBlack
        arrow.TextSize = 12
        arrow.AutoButtonColor = false
        arrow.ZIndex = 10
        Instance.new("UICorner", arrow).CornerRadius = UDim.new(0, 7)
        local arrowStroke = Instance.new("UIStroke", arrow)
        arrowStroke.Color = ROW_BORDER
        arrowStroke.Thickness = 1.2
        arrowStroke.Transparency = 0.35

        local heightRow = mkRow(momentPage, 30)
        heightRow.Visible = false
        mkLabel(heightRow, "Height Y")
        autoTPHeightBox = mkBox(heightRow, autoTPDownHeight, 50, 56, function(v)
            if v and v >= 1 and v <= 500 then autoTPDownHeight = v end
            saveAllSettings()
        end)

        local expanded = false
        local arrowDefaultSize = UDim2.new(0, 30, 0, 24)
        local arrowPressedSize = UDim2.new(0, 27, 0, 21)
        arrow.Activated:Connect(function()
            expanded = not expanded
            arrow.Text = expanded and "▲" or "▼"
            TS:Create(arrow, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = arrowPressedSize
            }):Play()
            task.delay(0.06, function()
                if arrow and arrow.Parent then
                    TS:Create(arrow, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Size = arrowDefaultSize,
                        BackgroundTransparency = expanded and 0 or 0.15
                    }):Play()
                end
            end)
            TS:Create(arrow, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Rotation = expanded and 180 or 0
            }):Play()
            if expanded then
                heightRow.Visible = true
                heightRow.Size = UDim2.new(1, -4, 0, 0)
                TS:Create(heightRow, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, -4, 0, 30)
                }):Play()
            else
                local closeTween = TS:Create(heightRow, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(1, -4, 0, 0)
                })
                closeTween:Play()
                closeTween.Completed:Connect(function()
                    if not expanded and heightRow and heightRow.Parent then
                        heightRow.Visible = false
                        heightRow.Size = UDim2.new(1, -4, 0, 30)
                    end
                end)
            end
        end)
        setAutoTPDownVisual = function(state) setToggle(state) end
    end
    setInstaResetVisual = mkToggle(momentPage, "Insta Reset", function(on)
        if on then instaReset(); task.delay(0.3, function() if setInstaResetVisual then setInstaResetVisual(false) end end) end
    end)

    -- ============================================================
    -- COMBAT TAB
    -- ============================================================
    local combatPage = contentPages["Combat"]
    mkSect(combatPage, "Visual")
    setESPVIsual = mkToggle(combatPage, "Player ESP", function(on) toggleESP(on); saveAllSettings() end)
    local stretchToggleSetter
    stretchToggleSetter = mkToggle(combatPage, "Stretch Rez", function(on)
        if on then enableStretch() else disableStretch() end
        stretchEnabled = on; saveAllSettings()
    end)
    _G.stretchToggleSetter = stretchToggleSetter
    stretchToggleSetter(stretchEnabled)

    setPOVVisual = mkToggle(combatPage, "POV", function(on)
        povEnabled = on
        if on then enablePOV() else disablePOV() end
        saveAllSettings()
    end)
    setPOVVisual(povEnabled)

    setAntiDieVisual = mkToggle(combatPage, "Anti Die", function(on) if on then enableAntiDie() else disableAntiDie() end; saveAllSettings() end)
    mkSect(combatPage, "Aimbots")
    autoBatSetVisual = mkToggle(combatPage, "Auto Bat", function(on)
        if on then
            if _G.ForceStopTPBat then pcall(_G.ForceStopTPBat) end
            enableAutoBat()
            if bypassSetVisual then bypassSetVisual(false) end
        else
            disableAutoBat()
        end
        if mobSetAutoBat then mobSetAutoBat(on) end
        saveAllSettings()
    end)
    bypassSetVisual = mkToggle(combatPage, "BAT BYPASS", function(on)
        if on then
            toggleBypass(true)
        else
            toggleBypass(false)
            if _G.ForceStopTPBat then pcall(_G.ForceStopTPBat) end
        end
        if bypassSetVisual then bypassSetVisual(bypassToggled == true) end
        saveAllSettings()
    end)
    if bypassSetVisual then bypassSetVisual(bypassToggled) end
    mkSect(combatPage, "Counters")
    setBatCounterVisual = mkToggle(combatPage, "Bat Counter", function(on) setBatCounterState(on); saveAllSettings() end)
    setMedusaVisual = mkToggle(combatPage, "Medusa Counter", function(on) setMedusaCounterState(on); saveAllSettings() end)
    mkSect(combatPage, "Defense")
    setAntiRagVisual = mkToggle(combatPage, "Anti Ragdoll", function(on) setAntiRag(on); saveAllSettings() end)
    setBodyLockVisual = mkToggle(combatPage, "Body Lock", function(on)
        if on then startBodyLock() else stopBodyLock() end
        bodyLockEnabled = on
        saveAllSettings()
    end)

    -- ============================================================
    -- VISUAL TAB
    -- ============================================================
    local visualPage = contentPages["Visual"]

    mkSect(visualPage, "Background Image")
    do
        local row = mkRow(visualPage, 55)

        local leftArrow = Instance.new("TextButton", row)
        leftArrow.Name = "BgPrevArrow"
        leftArrow.Size = UDim2.new(0, 24, 0, 44)
        leftArrow.Position = UDim2.new(0, 4, 0.5, -22)
        leftArrow.BackgroundColor3 = INP
        leftArrow.BackgroundTransparency = 0.5
        leftArrow.BorderSizePixel = 0
        leftArrow.Text = "<"
        leftArrow.TextColor3 = RED
        leftArrow.Font = Enum.Font.GothamBlack
        leftArrow.TextSize = 14
        leftArrow.AutoButtonColor = false
        leftArrow.ZIndex = 10
        Instance.new("UICorner", leftArrow).CornerRadius = UDim.new(0, 6)
        local laStroke = Instance.new("UIStroke", leftArrow)
        laStroke.Color = ROW_BORDER; laStroke.Thickness = 1

        local rightArrow = Instance.new("TextButton", row)
        rightArrow.Name = "BgNextArrow"
        rightArrow.Size = UDim2.new(0, 24, 0, 44)
        rightArrow.Position = UDim2.new(1, -28, 0.5, -22)
        rightArrow.BackgroundColor3 = INP
        rightArrow.BackgroundTransparency = 0.5
        rightArrow.BorderSizePixel = 0
        rightArrow.Text = ">"
        rightArrow.TextColor3 = RED
        rightArrow.Font = Enum.Font.GothamBlack
        rightArrow.TextSize = 14
        rightArrow.AutoButtonColor = false
        rightArrow.ZIndex = 10
        Instance.new("UICorner", rightArrow).CornerRadius = UDim.new(0, 6)
        local raStroke = Instance.new("UIStroke", rightArrow)
        raStroke.Color = ROW_BORDER; raStroke.Thickness = 1

        local container = Instance.new("ScrollingFrame", row)
        container.Size = UDim2.new(1, -60, 1, -6); container.Position = UDim2.new(0, 30, 0, 3)
        container.BackgroundTransparency = 1; container.BorderSizePixel = 0
        container.ClipsDescendants = true; container.ZIndex = 8
        container.ScrollingDirection = Enum.ScrollingDirection.X
        container.ScrollingEnabled = true; container.ScrollBarThickness = 0
        container.CanvasSize = UDim2.new(0, 0, 0, 0)
        container.AutomaticCanvasSize = Enum.AutomaticSize.X
        container.ElasticBehavior = Enum.ElasticBehavior.Always
        local galleryLayout = Instance.new("UIListLayout", container)
        galleryLayout.FillDirection = Enum.FillDirection.Horizontal
        galleryLayout.Padding = UDim.new(0, 6)
        galleryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        galleryLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        local galleryPadding = Instance.new("UIPadding", container)
        galleryPadding.PaddingLeft = UDim.new(0, 3); galleryPadding.PaddingRight = UDim.new(0, 3)
        local bgButtons = {}
        local function updateBgGallery()
            for i, btn in ipairs(bgButtons) do
                local st = btn:FindFirstChildOfClass("UIStroke")
                if st then
                    local selected = (i == currentBgIndex)
                    st.Color = selected and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(120, 120, 120)
                    st.Thickness = selected and 2.5 or 1
                    st.Transparency = selected and 0.1 or 0.6
                end
            end
        end
        for i, asset in ipairs(BackgroundImages) do
            local btn = Instance.new("ImageButton", container)
            btn.Size = UDim2.new(0, 62, 0, 42); btn.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
            btn.BackgroundTransparency = 0.2; btn.Image = asset; btn.ImageTransparency = 0
            btn.ScaleType = Enum.ScaleType.Crop; btn.ZIndex = 9; btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
            bgButtons[i] = btn
            btn.Activated:Connect(function() applyBackgroundImage(i); updateBgGallery() end)
        end

        -- Scroll-only function (does NOT change the background)
        local function scrollBgGallery(direction)
            local step = 62 + 6
            local currentPos = container.CanvasPosition.X
            local targetPos = currentPos + (direction * step * 1.5)
            local canvasW = container.AbsoluteCanvasSize.X
            local viewW = container.AbsoluteSize.X
            local maxScroll = math.max(0, canvasW - viewW)
            targetPos = math.clamp(targetPos, 0, maxScroll)
            TS:Create(container, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                CanvasPosition = Vector2.new(targetPos, container.CanvasPosition.Y)
            }):Play()
        end
        leftArrow.Activated:Connect(function() scrollBgGallery(-1) end)
        rightArrow.Activated:Connect(function() scrollBgGallery(1) end)

        updateBgGallery()
    end

    -- ============================================================
    -- FONT STYLE ROW — REMOVED
    -- ============================================================

    do
        local row = mkRow(visualPage, 30); mkLabel(row, "Sky Theme")
        local currentIndex = 1
        for i, entry in ipairs(CANDY_SKY_ORDER) do if entry[2] == currentSkyTheme then currentIndex = i; break end end
        local container = Instance.new("Frame", row)
        container.Size = UDim2.new(0, 160, 1, 0); container.Position = UDim2.new(1, -168, 0, 0)
        container.BackgroundTransparency = 1; container.ZIndex = 8
        local leftBtn = Instance.new("TextButton", container)
        leftBtn.Size = UDim2.new(0, 32, 0, 26); leftBtn.Position = UDim2.new(0, 0, 0.5, -13)
        leftBtn.BackgroundColor3 = INP; leftBtn.BackgroundTransparency = 0.7
        leftBtn.BorderSizePixel = 0; leftBtn.Text = "<"; leftBtn.TextColor3 = RED
        leftBtn.Font = Enum.Font.GothamBlack; leftBtn.TextSize = 13; leftBtn.AutoButtonColor = false
        leftBtn.ZIndex = 9
        Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 6)
        local leftStroke = Instance.new("UIStroke", leftBtn); leftStroke.Color = ROW_BORDER; leftStroke.Thickness = 1
        skySelectorLabel = Instance.new("TextLabel", container)
        skySelectorLabel.Size = UDim2.new(0, 80, 0, 26); skySelectorLabel.Position = UDim2.new(0.5, -40, 0.5, -13)
        skySelectorLabel.BackgroundTransparency = 1; skySelectorLabel.Text = CANDY_SKY_ORDER[currentIndex][2]
        skySelectorLabel.TextColor3 = RED; skySelectorLabel.Font = Enum.Font.GothamBlack
        skySelectorLabel.TextSize = 12; skySelectorLabel.TextXAlignment = Enum.TextXAlignment.Center; skySelectorLabel.ZIndex = 9
        local rightBtn = Instance.new("TextButton", container)
        rightBtn.Size = UDim2.new(0, 32, 0, 26); rightBtn.Position = UDim2.new(1, -32, 0.5, -13)
        rightBtn.BackgroundColor3 = INP; rightBtn.BackgroundTransparency = 0.7
        rightBtn.BorderSizePixel = 0; rightBtn.Text = ">"; rightBtn.TextColor3 = RED
        rightBtn.Font = Enum.Font.GothamBlack; rightBtn.TextSize = 13; rightBtn.AutoButtonColor = false
        rightBtn.ZIndex = 9
        Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 6)
        local rightStroke = Instance.new("UIStroke", rightBtn); rightStroke.Color = ROW_BORDER; rightStroke.Thickness = 1
        local function updateSkySelector(direction)
            local idx = 1
            for i, entry in ipairs(CANDY_SKY_ORDER) do if entry[2] == currentSkyTheme then idx = i; break end end
            local newIdx = idx + direction
            if newIdx < 1 then newIdx = #CANDY_SKY_ORDER end
            if newIdx > #CANDY_SKY_ORDER then newIdx = 1 end
            setSkyTheme(CANDY_SKY_ORDER[newIdx][2]); saveAllSettings()
        end
        leftBtn.Activated:Connect(function() updateSkySelector(-1) end)
        rightBtn.Activated:Connect(function() updateSkySelector(1) end)
    end

    -- ANIMATION PACK ROW
    do
        local AnimationPacks = {
            ["Zombie"] = { idle = {{"rbxassetid://616158929", 1}, {"rbxassetid://616158929", 1}}, walk = "rbxassetid://616168032", run = "rbxassetid://616163682", jump = "rbxassetid://616161997", fall = "rbxassetid://616157476", climb = "rbxassetid://616156119" },
            ["Ninja"] = { idle = {{"rbxassetid://656117400", 1}, {"rbxassetid://656117400", 1}}, walk = "rbxassetid://656121766", run = "rbxassetid://656118852", jump = "rbxassetid://656117878", fall = "rbxassetid://656115606", climb = "rbxassetid://656114359" },
            ["Knight"] = { idle = {{"rbxassetid://657595757", 1}, {"rbxassetid://657595757", 1}}, walk = "rbxassetid://657552124", run = "rbxassetid://657564596", jump = "rbxassetid://658409194", fall = "rbxassetid://657600338", climb = "rbxassetid://658360781" },
            ["Elder"] = { idle = {{"rbxassetid://845397899", 1}, {"rbxassetid://845397899", 1}}, walk = "rbxassetid://845403856", run = "rbxassetid://845386501", jump = "rbxassetid://845398858", fall = "rbxassetid://845397673", climb = "rbxassetid://845392038" },
            ["Levitate"] = { idle = {{"rbxassetid://616006778", 1}, {"rbxassetid://616006778", 1}}, walk = "rbxassetid://616013216", run = "rbxassetid://616013216", jump = "rbxassetid://616008936", fall = "rbxassetid://616005863", climb = "rbxassetid://616003713" },
            ["Astronaut"] = { idle = {{"rbxassetid://891621366", 1}, {"rbxassetid://891621366", 1}}, walk = "rbxassetid://891636393", run = "rbxassetid://891636393", jump = "rbxassetid://891627522", fall = "rbxassetid://891617961", climb = "rbxassetid://891609353" },
            ["Pirate"] = { idle = {{"rbxassetid://750781874", 1}, {"rbxassetid://750781874", 1}}, walk = "rbxassetid://750785693", run = "rbxassetid://750783738", jump = "rbxassetid://750782230", fall = "rbxassetid://750780242", climb = "rbxassetid://750779899" },
            ["Toy"] = { idle = {{"rbxassetid://782841498", 1}, {"rbxassetid://782841498", 1}}, walk = "rbxassetid://782843345", run = "rbxassetid://782842708", jump = "rbxassetid://782847020", fall = "rbxassetid://782846423", climb = "rbxassetid://782843869" },
            ["Vampire"] = { idle = {{"rbxassetid://1083445855", 1}, {"rbxassetid://1083445855", 1}}, walk = "rbxassetid://1083473930", run = "rbxassetid://1083462077", jump = "rbxassetid://1083455352", fall = "rbxassetid://1083443587", climb = "rbxassetid://1083439238" },
            ["Werewolf"] = { idle = {{"rbxassetid://1083195517", 1}, {"rbxassetid://1083195517", 1}}, walk = "rbxassetid://1083178339", run = "rbxassetid://1083216690", jump = "rbxassetid://1083218792", fall = "rbxassetid://1083189019", climb = "rbxassetid://1083182000" },
            ["Rthro"] = { idle = {{"rbxassetid://2510196951", 1}, {"rbxassetid://2510196951", 1}}, walk = "rbxassetid://2510202577", run = "rbxassetid://2510198475", jump = "rbxassetid://2510197830", fall = "rbxassetid://2510195892", climb = "rbxassetid://2510192778" },
            ["Stylish"] = { idle = {{"rbxassetid://616136790", 1}, {"rbxassetid://616136790", 1}}, walk = "rbxassetid://616146177", run = "rbxassetid://616140816", jump = "rbxassetid://616139451", fall = "rbxassetid://616134815", climb = "rbxassetid://616133594" },
        }

        local AnimationPackList = {"OFF", "Unwalk", "Hit Harder", "Zombie", "Ninja", "Knight", "Elder", "Levitate", "Astronaut", "Pirate", "Toy", "Vampire", "Werewolf", "Rthro", "Stylish"}
        local AnimationPackIndex = 1

        local HIT_HARDER_ANIMS = {
            idle1 = "rbxassetid://133806214992291", idle2 = "rbxassetid://94970088341563",
            walk = "rbxassetid://707897309", run = "rbxassetid://707861613",
            jump = "rbxassetid://116936326516985", fall = "rbxassetid://116936326516985",
        }

        local selectedAnimationPack = "OFF"
        local OriginalAnims = {}
        local animUnwalkSavedAnimate = nil
        local animUnwalkEnabled = false
        local hitHarderAnimEnabled = false
        local animationPackValueLabel = nil

        local function getAnimate(char)
            char = char or LP.Character
            return char and char:FindFirstChild("Animate") or nil
        end

        local function stopCurrentAnimations(char)
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
        end

        local function setAnimId(obj, id)
            if obj and id then pcall(function() obj.AnimationId = id end) end
        end

        local function reloadAnimate(animate)
            if not animate then return end
            pcall(function()
                animate.Disabled = true
                task.wait()
                animate.Disabled = false
            end)
        end

        local function backupAnimations(char)
            local animate = getAnimate(char)
            if not animate or next(OriginalAnims) ~= nil then return end
            local function getId(obj) return obj and obj.AnimationId or nil end
            OriginalAnims = {
                idle1 = getId(animate.idle and animate.idle:FindFirstChild("Animation1")),
                idle2 = getId(animate.idle and animate.idle:FindFirstChild("Animation2")),
                walk = getId(animate.walk and animate.walk:FindFirstChild("WalkAnim")),
                run = getId(animate.run and animate.run:FindFirstChild("RunAnim")),
                jump = getId(animate.jump and animate.jump:FindFirstChild("JumpAnim")),
                fall = getId(animate.fall and animate.fall:FindFirstChild("FallAnim")),
                climb = getId(animate.climb and animate.climb:FindFirstChild("ClimbAnim")),
            }
        end

        local function resetAnimations()
            local char = LP.Character
            local animate = getAnimate(char)
            if not animate or next(OriginalAnims) == nil then return end
            stopCurrentAnimations(char)
            setAnimId(animate.idle and animate.idle:FindFirstChild("Animation1"), OriginalAnims.idle1)
            setAnimId(animate.idle and animate.idle:FindFirstChild("Animation2"), OriginalAnims.idle2)
            setAnimId(animate.walk and animate.walk:FindFirstChild("WalkAnim"), OriginalAnims.walk)
            setAnimId(animate.run and animate.run:FindFirstChild("RunAnim"), OriginalAnims.run)
            setAnimId(animate.jump and animate.jump:FindFirstChild("JumpAnim"), OriginalAnims.jump)
            setAnimId(animate.fall and animate.fall:FindFirstChild("FallAnim"), OriginalAnims.fall)
            setAnimId(animate.climb and animate.climb:FindFirstChild("ClimbAnim"), OriginalAnims.climb)
            reloadAnimate(animate)
        end

        local function enableAnimUnwalk()
            animUnwalkEnabled = true
            local char = LP.Character
            local animate = getAnimate(char)
            if animate then
                if not animUnwalkSavedAnimate then animUnwalkSavedAnimate = animate:Clone() end
                stopCurrentAnimations(char)
                animate:Destroy()
            end
        end

        local function disableAnimUnwalk()
            animUnwalkEnabled = false
            local char = LP.Character
            if char and not char:FindFirstChild("Animate") and animUnwalkSavedAnimate then
                local newAnimate = animUnwalkSavedAnimate:Clone()
                newAnimate.Parent = char
            end
        end

        local function enableHitHarderAnim()
            hitHarderAnimEnabled = true
            local char = LP.Character
            local animate = getAnimate(char)
            if not animate then return end
            backupAnimations(char)
            stopCurrentAnimations(char)
            setAnimId(animate.idle and animate.idle:FindFirstChild("Animation1"), HIT_HARDER_ANIMS.idle1)
            setAnimId(animate.idle and animate.idle:FindFirstChild("Animation2"), HIT_HARDER_ANIMS.idle2)
            setAnimId(animate.walk and animate.walk:FindFirstChild("WalkAnim"), HIT_HARDER_ANIMS.walk)
            setAnimId(animate.run and animate.run:FindFirstChild("RunAnim"), HIT_HARDER_ANIMS.run)
            setAnimId(animate.jump and animate.jump:FindFirstChild("JumpAnim"), HIT_HARDER_ANIMS.jump)
            setAnimId(animate.fall and animate.fall:FindFirstChild("FallAnim"), HIT_HARDER_ANIMS.fall)
            reloadAnimate(animate)
        end

        local function disableHitHarderAnim()
            hitHarderAnimEnabled = false
            resetAnimations()
            if selectedAnimationPack ~= "OFF" then
                task.wait()
                applyAnimationPack(selectedAnimationPack)
            end
        end

        local applyAnimationPack
        applyAnimationPack = function(packName)
            selectedAnimationPack = packName or "OFF"
            if selectedAnimationPack ~= "Unwalk" and animUnwalkEnabled then disableAnimUnwalk() end
            if selectedAnimationPack ~= "Hit Harder" and hitHarderAnimEnabled then
                hitHarderAnimEnabled = false; resetAnimations()
            end
            if selectedAnimationPack == "Unwalk" then resetAnimations(); enableAnimUnwalk(); return end
            if selectedAnimationPack == "Hit Harder" then disableAnimUnwalk(); enableHitHarderAnim(); return end
            if selectedAnimationPack == "OFF" then resetAnimations(); return end
            local pack = AnimationPacks[selectedAnimationPack]
            local char = LP.Character
            local animate = getAnimate(char)
            if not pack or not animate then return end
            backupAnimations(char)
            stopCurrentAnimations(char)
            setAnimId(animate.idle and animate.idle:FindFirstChild("Animation1"), pack.idle[1][1])
            setAnimId(animate.idle and animate.idle:FindFirstChild("Animation2"), pack.idle[2][1])
            setAnimId(animate.walk and animate.walk:FindFirstChild("WalkAnim"), pack.walk)
            setAnimId(animate.run and animate.run:FindFirstChild("RunAnim"), pack.run)
            setAnimId(animate.jump and animate.jump:FindFirstChild("JumpAnim"), pack.jump)
            setAnimId(animate.fall and animate.fall:FindFirstChild("FallAnim"), pack.fall)
            setAnimId(animate.climb and animate.climb:FindFirstChild("ClimbAnim"), pack.climb)
            reloadAnimate(animate)
        end

        local animRow = mkRow(visualPage, 30)
        mkLabel(animRow, "Animation Pack")

        local animContainer = Instance.new("Frame", animRow)
        animContainer.Size = UDim2.new(0, 160, 1, 0)
        animContainer.Position = UDim2.new(1, -168, 0, 0)
        animContainer.BackgroundTransparency = 1
        animContainer.ZIndex = 8

        local aPrev = Instance.new("TextButton", animContainer)
        aPrev.Size = UDim2.new(0, 32, 0, 26); aPrev.Position = UDim2.new(0, 0, 0.5, -13)
        aPrev.BackgroundColor3 = INP; aPrev.BackgroundTransparency = 0.7
        aPrev.BorderSizePixel = 0; aPrev.Text = "<"; aPrev.TextColor3 = RED
        aPrev.Font = Enum.Font.GothamBlack; aPrev.TextSize = 13; aPrev.AutoButtonColor = false
        aPrev.ZIndex = 9
        Instance.new("UICorner", aPrev).CornerRadius = UDim.new(0, 6)
        local aPrevStroke = Instance.new("UIStroke", aPrev); aPrevStroke.Color = ROW_BORDER; aPrevStroke.Thickness = 1

        animationPackValueLabel = Instance.new("TextLabel", animContainer)
        animationPackValueLabel.Name = "AnimationPackValue"
        animationPackValueLabel.Position = UDim2.new(0.5, -40, 0.5, -13)
        animationPackValueLabel.Size = UDim2.new(0, 80, 0, 26)
        animationPackValueLabel.BackgroundTransparency = 1
        animationPackValueLabel.Text = selectedAnimationPack
        animationPackValueLabel.TextColor3 = RED
        animationPackValueLabel.Font = Enum.Font.GothamBlack
        animationPackValueLabel.TextSize = 12
        animationPackValueLabel.TextXAlignment = Enum.TextXAlignment.Center
        animationPackValueLabel.ZIndex = 9

        local aNext = Instance.new("TextButton", animContainer)
        aNext.Size = UDim2.new(0, 32, 0, 26); aNext.Position = UDim2.new(1, -32, 0.5, -13)
        aNext.BackgroundColor3 = INP; aNext.BackgroundTransparency = 0.7
        aNext.BorderSizePixel = 0; aNext.Text = ">"; aNext.TextColor3 = RED
        aNext.Font = Enum.Font.GothamBlack; aNext.TextSize = 13; aNext.AutoButtonColor = false
        aNext.ZIndex = 9
        Instance.new("UICorner", aNext).CornerRadius = UDim.new(0, 6)
        local aNextStroke = Instance.new("UIStroke", aNext); aNextStroke.Color = ROW_BORDER; aNextStroke.Thickness = 1

        local function refreshAnimationPackRow()
            if animationPackValueLabel then animationPackValueLabel.Text = selectedAnimationPack end
        end

        local function setPackIndex(nextIndex)
            if nextIndex < 1 then nextIndex = #AnimationPackList end
            if nextIndex > #AnimationPackList then nextIndex = 1 end
            AnimationPackIndex = nextIndex
            selectedAnimationPack = AnimationPackList[AnimationPackIndex]
            refreshAnimationPackRow()
            applyAnimationPack(selectedAnimationPack)
            saveAllSettings()
        end

        aPrev.Activated:Connect(function() setPackIndex(AnimationPackIndex - 1) end)
        aNext.Activated:Connect(function() setPackIndex(AnimationPackIndex + 1) end)

        task.delay(0.5, function()
            local savedAnim = _G._KZAXAnimationPack
            if savedAnim then
                for i, name in ipairs(AnimationPackList) do
                    if name == savedAnim then AnimationPackIndex = i; selectedAnimationPack = savedAnim; break end
                end
                refreshAnimationPackRow()
                if selectedAnimationPack ~= "OFF" then
                    task.wait(0.3)
                    pcall(function() applyAnimationPack(selectedAnimationPack) end)
                end
            end
        end)

        LP.CharacterAdded:Connect(function(char)
            task.wait(1.5)
            if selectedAnimationPack and selectedAnimationPack ~= "OFF" then
                pcall(function() applyAnimationPack(selectedAnimationPack) end)
            end
        end)

        _G._KZAXGetAnimationPack = function() return selectedAnimationPack end
        _G._KZAXGetAnimationPackIndex = function() return AnimationPackIndex end
        _G._KZAXSetAnimationPack = function(pack)
            for i, name in ipairs(AnimationPackList) do
                if name == pack then
                    AnimationPackIndex = i; selectedAnimationPack = pack
                    refreshAnimationPackRow()
                    task.spawn(function() applyAnimationPack(pack) end)
                    return true
                end
            end
            return false
        end
    end

    -- OUTFIT SECTION
    do
        local OUTFITS = {
            { accessory = 10159600649, offset = Vector3.new(0, 1, -0.2),
              shirt = "http://www.roblox.com/asset/?id=9683332638", pants = "http://www.roblox.com/asset/?id=93182020184041",
              headMesh = "http://www.roblox.com/asset/?id=134079402", headTexture = "http://www.roblox.com/asset/?id=133940918",
              korblox = "none", label = "Outfit 1", headlessKorblox = true },
            { accessory = 1744060292, offset = Vector3.new(0, 1.3, -0.2),
              shirt = "http://www.roblox.com/asset/?id=9683332638", pants = "http://www.roblox.com/asset/?id=93182020184041",
              headMesh = "http://www.roblox.com/asset/?id=134079402", headTexture = "http://www.roblox.com/asset/?id=133940918",
              korblox = "none", label = "Outfit 2", headlessKorblox = true },
            { accessory = 8349240186, offset = Vector3.new(0, 0.9, 0),
              shirt = "http://www.roblox.com/asset/?id=11926549070", pants = "http://www.roblox.com/asset/?id=13189494471",
              headMesh = "https://assetdelivery.roblox.com/v1/asset/?id=16673245747", headTexture = nil,
              korblox = "none", label = "Outfit 3", headlessKorblox = true },
            { accessory = 121097973925756, offset = Vector3.new(0, 0.9, 0),
              shirt = "http://www.roblox.com/asset/?id=123181702116947", pants = "http://www.roblox.com/asset/?id=93330291631062",
              headMesh = "http://www.roblox.com/asset/?id=134079402", headTexture = "http://www.roblox.com/asset/?id=133940918",
              korblox = "none", label = "Outfit 4", headlessKorblox = true },
            { label = "Homero Chino", customApply = function(char) return applyHomeroOutfit(char) end },
            { label = "NO", customApply = function(char) return applyNoOutfit(char) end },
        }

        local currentOutfitIndex = 1
        if _G._KZAXSavedOutfitIndex and type(_G._KZAXSavedOutfitIndex) == "number" then
            if _G._KZAXSavedOutfitIndex >= 1 and _G._KZAXSavedOutfitIndex <= #OUTFITS then
                currentOutfitIndex = _G._KZAXSavedOutfitIndex
            end
        end
        if currentAccessoryPack and currentAccessoryPack ~= "Off" then
            for i, outfit in ipairs(OUTFITS) do
                if outfit.label == currentAccessoryPack then currentOutfitIndex = i; break end
            end
        end

        local outfitSelectorLabel = nil
        local outfitStatusLabel = nil
        local outfitRow = mkRow(visualPage, 30)
        mkLabel(outfitRow, "Outfit")

        local container = Instance.new("Frame", outfitRow)
        container.Size = UDim2.new(0, 160, 1, 0)
        container.Position = UDim2.new(1, -168, 0, 0)
        container.BackgroundTransparency = 1
        container.ZIndex = 8

        local leftBtn = Instance.new("TextButton", container)
        leftBtn.Size = UDim2.new(0, 32, 0, 26); leftBtn.Position = UDim2.new(0, 0, 0.5, -13)
        leftBtn.BackgroundColor3 = INP; leftBtn.BackgroundTransparency = 0.7
        leftBtn.BorderSizePixel = 0; leftBtn.Text = "<"; leftBtn.TextColor3 = RED
        leftBtn.Font = Enum.Font.GothamBlack; leftBtn.TextSize = 13; leftBtn.AutoButtonColor = false
        leftBtn.ZIndex = 9
        Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 6)
        local leftStroke = Instance.new("UIStroke", leftBtn); leftStroke.Color = ROW_BORDER; leftStroke.Thickness = 1

        outfitSelectorLabel = Instance.new("TextLabel", container)
        outfitSelectorLabel.Size = UDim2.new(0, 80, 0, 26); outfitSelectorLabel.Position = UDim2.new(0.5, -40, 0.5, -13)
        outfitSelectorLabel.BackgroundTransparency = 1; outfitSelectorLabel.Text = OUTFITS[currentOutfitIndex].label
        outfitSelectorLabel.TextColor3 = RED; outfitSelectorLabel.Font = Enum.Font.GothamBlack
        outfitSelectorLabel.TextSize = 12; outfitSelectorLabel.TextXAlignment = Enum.TextXAlignment.Center
        outfitSelectorLabel.ZIndex = 9

        local rightBtn = Instance.new("TextButton", container)
        rightBtn.Size = UDim2.new(0, 32, 0, 26); rightBtn.Position = UDim2.new(1, -32, 0.5, -13)
        rightBtn.BackgroundColor3 = INP; rightBtn.BackgroundTransparency = 0.7
        rightBtn.BorderSizePixel = 0; rightBtn.Text = ">"; rightBtn.TextColor3 = RED
        rightBtn.Font = Enum.Font.GothamBlack; rightBtn.TextSize = 13; rightBtn.AutoButtonColor = false
        rightBtn.ZIndex = 9
        Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 6)
        local rightStroke = Instance.new("UIStroke", rightBtn); rightStroke.Color = ROW_BORDER; rightStroke.Thickness = 1

        local statusRow = mkRow(visualPage, 22)
        statusRow.BackgroundTransparency = 1
        outfitStatusLabel = Instance.new("TextLabel", statusRow)
        outfitStatusLabel.Size = UDim2.new(1, -20, 1, 0); outfitStatusLabel.Position = UDim2.new(0, 10, 0, 0)
        outfitStatusLabel.BackgroundTransparency = 1; outfitStatusLabel.Text = ""
        outfitStatusLabel.TextColor3 = RED; outfitStatusLabel.Font = Enum.Font.GothamBold
        outfitStatusLabel.TextSize = 9; outfitStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
        outfitStatusLabel.ZIndex = 9

        local function applyOutfitByIndex(index)
            local outfit = OUTFITS[index]
            if not outfit then return false end
            local char = LP.Character
            if not char then return false end
            local ok = false
            if outfit.customApply then
                ok = outfit.customApply(char) == true
            else
                if not _G.Lust.OriginalOutfit.shirt and not _G.Lust.OriginalOutfit.pants then saveOriginalOutfit(char) end
                if #_G.Lust.OriginalAccessories == 0 then saveOriginalAccessories(char) end
                clearAllOutfit(char); clearAllAccessories(char)
                local packName = "__custom_" .. index
                BLEED_PACKS[packName] = {
                    accessory = outfit.accessory, offset = outfit.offset, shirt = outfit.shirt,
                    pants = outfit.pants, headMesh = outfit.headMesh, headTexture = outfit.headTexture,
                    korblox = outfit.korblox, headlessKorblox = outfit.headlessKorblox,
                }
                ok = applyBleedOutfit(packName) == true
            end
            if outfitStatusLabel then
                outfitStatusLabel.Text = string.upper(outfit.label) .. (ok and "  ✓ SUCCESS" or "  ✗ FAILED")
                task.delay(1.5, function()
                    if outfitStatusLabel and outfitStatusLabel.Parent then outfitStatusLabel.Text = "" end
                end)
            end
            currentAccessoryPack = outfit.label
            currentOutfitIndex = index
            _G._KZAXSavedOutfitIndex = index
            saveAllSettings()
            return ok
        end

        local function updateOutfitSelector(direction)
            currentOutfitIndex = currentOutfitIndex + direction
            if currentOutfitIndex < 1 then currentOutfitIndex = #OUTFITS end
            if currentOutfitIndex > #OUTFITS then currentOutfitIndex = 1 end
            outfitSelectorLabel.Text = OUTFITS[currentOutfitIndex].label
            applyOutfitByIndex(currentOutfitIndex)
        end

        leftBtn.Activated:Connect(function() updateOutfitSelector(-1) end)
        rightBtn.Activated:Connect(function() updateOutfitSelector(1) end)

        _G._KZAXApplyCurrentOutfit = function()
            if currentOutfitIndex and OUTFITS[currentOutfitIndex] then
                task.wait(0.3)
                applyOutfitByIndex(currentOutfitIndex)
            end
        end
    end

    -- CUSTOM TOOLS + CUSTOM SOUNDS
    do
        local ctSelectorLabel = nil
        local ctStatusLabel = nil

        local ctToggleRow = mkRow(visualPage, 34)
        mkLabel(ctToggleRow, "Custom Tools")
        local ctPill, ctDot = mkPill(ctToggleRow, 44)
        local ctOn = false
        local ctOpenButtonRow = nil
        local function ctAnim(state)
            ctOn = state
            animPill(ctPill, ctDot, state)
        end
        local ctClk = Instance.new("TextButton", ctPill)
        ctClk.Size = UDim2.new(1,0,1,0); ctClk.BackgroundTransparency = 1; ctClk.Text = ""
        ctClk.AutoButtonColor = false; ctClk.ZIndex = 10
        ctClk.Activated:Connect(function()
            ctAnim(not ctOn)
            if _G.AmbitiousCustomTools then
                _G.AmbitiousCustomTools.setEnabled(ctOn)
            end
            _G.AmbitiousCustomToolsEnabled = ctOn
            if ctOpenButtonRow then ctOpenButtonRow.Visible = ctOn end
            saveAllSettings()
        end)

        _G.KZAXCustomToolsSetState = ctAnim
        _G.KZAXCustomToolsToggle = ctClk

        ctOpenButtonRow = mkRow(visualPage, 30)
        ctOpenButtonRow.Name = "OpenCustomToolsSelectorRow"
        ctOpenButtonRow.Visible = ctOn
        local ctOpenLabel = mkLabel(ctOpenButtonRow, "OPEN CUSTOM TOOLS SELECTOR")
        if ctOpenLabel then
            ctOpenLabel.TextSize = 10
            ctOpenLabel.Font = Enum.Font.GothamBlack
        end
        local ctOpenHolder = Instance.new("Frame", ctOpenButtonRow)
        ctOpenHolder.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        ctOpenHolder.BackgroundTransparency = 0.15
        ctOpenHolder.BorderSizePixel = 0
        ctOpenHolder.Size = UDim2.new(0, 76, 0, 24)
        ctOpenHolder.Position = UDim2.new(1, -83, 0.5, -12)
        ctOpenHolder.ZIndex = 8
        Instance.new("UICorner", ctOpenHolder).CornerRadius = UDim.new(0, 10)
        local ctOpenStroke = Instance.new("UIStroke", ctOpenHolder)
        ctOpenStroke.Color = Color3.fromRGB(255, 255, 255)
        ctOpenStroke.Thickness = 1
        local ctOpenButton = Instance.new("TextButton", ctOpenHolder)
        ctOpenButton.Size = UDim2.new(1, 0, 1, 0)
        ctOpenButton.BackgroundTransparency = 1
        ctOpenButton.Text = "OPEN"
        ctOpenButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ctOpenButton.Font = Enum.Font.GothamBlack
        ctOpenButton.TextSize = 10
        ctOpenButton.ZIndex = 9
        ctOpenButton.Activated:Connect(function()
            if _G.KZAXOpenCustomToolsSelector then
                _G.KZAXOpenCustomToolsSelector()
            end
        end)

        local csToggleRow = mkRow(visualPage, 34)
        mkLabel(csToggleRow, "Custom Sounds")
        local csPill, csDot = mkPill(csToggleRow, 44)
        local csOn = false
        local function csAnim(state)
            csOn = state
            animPill(csPill, csDot, state)
        end
        local csClk = Instance.new("TextButton", csPill)
        csClk.Size = UDim2.new(1,0,1,0); csClk.BackgroundTransparency = 1; csClk.Text = ""
        csClk.AutoButtonColor = false; csClk.ZIndex = 10
        csClk.Activated:Connect(function()
            csAnim(not csOn)
            if _G.AmbitiousCustomSounds then
                _G.AmbitiousCustomSounds.setEnabled(csOn)
            end
            _G.AmbitiousCustomSoundsEnabled = csOn
            saveAllSettings()
        end)

        _G.KZAXCustomSoundsSetState = csAnim
        _G.KZAXCustomSoundsToggle = csClk

        local ctPickRow = mkRow(visualPage, 34)
        ctPickRow.Visible = false
        mkLabel(ctPickRow, "Pick Tool Skin")

        local ctPickHolder = Instance.new("Frame", ctPickRow)
        ctPickHolder.Name = "CustomToolsPickHolder"
        ctPickHolder.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
        ctPickHolder.BackgroundTransparency = 0.3
        ctPickHolder.BorderSizePixel = 0
        ctPickHolder.Size = UDim2.new(0, 66, 0, 26)
        ctPickHolder.Position = UDim2.new(1, -73, 0.5, -13)
        ctPickHolder.ClipsDescendants = true
        ctPickHolder.ZIndex = 8
        Instance.new("UICorner", ctPickHolder).CornerRadius = UDim.new(0, 13)
        local ctPickStroke = Instance.new("UIStroke", ctPickHolder)
        ctPickStroke.Color = Color3.fromRGB(255, 255, 255)
        ctPickStroke.Thickness = 1.2
        ctPickStroke.Transparency = 0.15

        local ctPickBtn = Instance.new("TextButton", ctPickHolder)
        ctPickBtn.Name = "CustomToolsPickButton"
        ctPickBtn.BackgroundTransparency = 1
        ctPickBtn.Text = "PICK"
        ctPickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ctPickBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        ctPickBtn.TextStrokeTransparency = 0.3
        ctPickBtn.TextSize = 11
        ctPickBtn.Font = Enum.Font.GothamBlack
        ctPickBtn.Size = UDim2.new(1, 0, 1, 0)
        ctPickBtn.BorderSizePixel = 0
        ctPickBtn.ZIndex = 9
        ctPickBtn.AutoButtonColor = false

        local ctStatusRow = mkRow(visualPage, 22)
        ctStatusRow.BackgroundTransparency = 1
        ctStatusLabel = Instance.new("TextLabel", ctStatusRow)
        ctStatusLabel.Size = UDim2.new(1, -20, 1, 0); ctStatusLabel.Position = UDim2.new(0, 10, 0, 0)
        ctStatusLabel.BackgroundTransparency = 1; ctStatusLabel.Text = ""
        ctStatusLabel.TextColor3 = RED; ctStatusLabel.Font = Enum.Font.GothamBold
        ctStatusLabel.TextSize = 9; ctStatusLabel.TextXAlignment = Enum.TextXAlignment.Center
        ctStatusLabel.ZIndex = 9

        local ctPickGui = nil
        local ctJustClosedAt = 0

        local function closeCtPicker()
            if ctPickGui and ctPickGui.Parent then
                local f = ctPickGui:FindFirstChild("Frame")
                if f then TS:Create(f, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end
                local g = ctPickGui
                ctPickGui = nil
                ctJustClosedAt = tick()
                task.delay(0.25, function() pcall(function() g:Destroy() end) end)
            end
        end

        local function makeToolPreview(card, assetKey)
            local assetData = _G.AmbitiousCustomToolAssets and _G.AmbitiousCustomToolAssets[assetKey]
            if not assetData then return end
            local viewport = Instance.new("ViewportFrame", card)
            viewport.Name = "ToolPreview"
            viewport.Size = UDim2.new(1, 0, 1, -26)
            viewport.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
            viewport.BorderSizePixel = 0
            viewport.ZIndex = 4
            viewport.Ambient = Color3.fromRGB(255, 255, 255)
            viewport.LightColor = Color3.fromRGB(255, 255, 255)
            viewport.LightDirection = Vector3.new(-1, -1, -1)
            Instance.new("UICorner", viewport).CornerRadius = UDim.new(0, 10)
            local world = Instance.new("WorldModel", viewport)
            local model = Instance.new("Model", world)
            local part = Instance.new("Part", model)
            part.Name = "PreviewPart"
            part.Size = Vector3.new(1, 1, 1)
            part.Anchored = true
            part.CanCollide = false
            part.CanQuery = false
            part.CanTouch = false
            part.Transparency = 0
            part.Parent = model
            local mesh = Instance.new("SpecialMesh", part)
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = assetData.mesh
            mesh.TextureId = assetData.tex
            mesh.Scale = assetData.scale
            mesh.Parent = part
            model.PrimaryPart = part
            local boxCF, boxSize = model:GetBoundingBox()
            local focus = boxCF.Position
            local maxDim = math.max(boxSize.X, boxSize.Y, boxSize.Z)
            local dist = math.max(maxDim * 1.8, 4.5)
            local cam = Instance.new("Camera", viewport)
            cam.FieldOfView = 60
            viewport.CurrentCamera = cam
            cam.CFrame = CFrame.lookAt(focus + Vector3.new(0, 0.3, dist), focus)
            local base = part.CFrame
            local started = tick()
            local conn
            conn = RunService.RenderStepped:Connect(function()
                if not viewport.Parent or not part.Parent then
                    if conn then conn:Disconnect() end
                    return
                end
                local t = tick() - started
                part.CFrame = base * CFrame.Angles(0, t * 1.6, 0)
            end)
        end

        local function openCtPicker()
            if ctPickGui then closeCtPicker(); return end
            if tick() - ctJustClosedAt < 0.25 then return end

            -- New CUSTOM TOOLS selector UI (adapted to the existing BLOCK DUELS engine).
            ctPickGui = Instance.new("ScreenGui")
            ctPickGui.Name = "KZAXCustomToolsPicker"
            ctPickGui.ResetOnSpawn = false
            ctPickGui.IgnoreGuiInset = true
            ctPickGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            ctPickGui.DisplayOrder = 999999
            ctPickGui.Parent = gui

            local backdrop = Instance.new("TextButton", ctPickGui)
            backdrop.Name = "Backdrop"
            backdrop.Size = UDim2.fromScale(1, 1)
            backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
            backdrop.BackgroundTransparency = 0.46
            backdrop.BorderSizePixel = 0
            backdrop.Text = ""
            backdrop.AutoButtonColor = false
            backdrop.ZIndex = 1
            backdrop.Activated:Connect(closeCtPicker)

            local frame = Instance.new("Frame", ctPickGui)
            frame.Name = "Frame"
            frame.Size = UDim2.new(0, 390, 0, 430)
            frame.Position = UDim2.new(0.5, -195, 0.5, -215)
            frame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
            frame.BorderSizePixel = 0
            frame.ZIndex = 2
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 15)
            local frameStroke = Instance.new("UIStroke", frame)
            frameStroke.Color = Color3.fromRGB(90, 90, 95)
            frameStroke.Thickness = 1
            frameStroke.Transparency = 0.3

            local title = Instance.new("TextLabel", frame)
            title.Size = UDim2.new(1, -60, 0, 34)
            title.Position = UDim2.new(0, 14, 0, 7)
            title.BackgroundTransparency = 1
            title.Text = "CUSTOM TOOLS"
            title.TextColor3 = Color3.new(1, 1, 1)
            title.Font = Enum.Font.GothamBlack
            title.TextSize = 14
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.ZIndex = 4

            local close = Instance.new("TextButton", frame)
            close.Size = UDim2.new(0, 30, 0, 30)
            close.Position = UDim2.new(1, -38, 0, 8)
            close.BackgroundColor3 = Color3.fromRGB(24, 24, 27)
            close.BorderSizePixel = 0
            close.Text = "X"
            close.TextColor3 = Color3.new(1, 1, 1)
            close.Font = Enum.Font.GothamBold
            close.TextSize = 12
            close.AutoButtonColor = false
            close.ZIndex = 5
            Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
            close.Activated:Connect(closeCtPicker)

            local subtitle = Instance.new("TextLabel", frame)
            subtitle.Size = UDim2.new(1, -28, 0, 20)
            subtitle.Position = UDim2.new(0, 14, 0, 39)
            subtitle.BackgroundTransparency = 1
            subtitle.Text = "Select a Bat or Medusa skin"
            subtitle.TextColor3 = Color3.fromRGB(150, 150, 155)
            subtitle.Font = Enum.Font.GothamSemibold
            subtitle.TextSize = 9
            subtitle.TextXAlignment = Enum.TextXAlignment.Left
            subtitle.ZIndex = 4

            local tabs = Instance.new("Frame", frame)
            tabs.Size = UDim2.new(1, -28, 0, 34)
            tabs.Position = UDim2.new(0, 14, 0, 66)
            tabs.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
            tabs.BorderSizePixel = 0
            tabs.ZIndex = 4
            Instance.new("UICorner", tabs).CornerRadius = UDim.new(0, 9)
            local batTab = Instance.new("TextButton", tabs)
            batTab.Size = UDim2.new(0.5, -2, 1, -4)
            batTab.Position = UDim2.new(0, 2, 0, 2)
            batTab.BackgroundColor3 = Color3.fromRGB(238, 238, 238)
            batTab.BorderSizePixel = 0
            batTab.Text = "BAT"
            batTab.TextColor3 = Color3.fromRGB(0, 0, 0)
            batTab.Font = Enum.Font.GothamBlack
            batTab.TextSize = 10
            batTab.ZIndex = 5
            Instance.new("UICorner", batTab).CornerRadius = UDim.new(0, 7)
            local medTab = Instance.new("TextButton", tabs)
            medTab.Size = UDim2.new(0.5, -2, 1, -4)
            medTab.Position = UDim2.new(0.5, 0, 0, 2)
            medTab.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
            medTab.BorderSizePixel = 0
            medTab.Text = "MEDUSA"
            medTab.TextColor3 = Color3.fromRGB(225, 225, 225)
            medTab.Font = Enum.Font.GothamBlack
            medTab.TextSize = 10
            medTab.ZIndex = 5
            Instance.new("UICorner", medTab).CornerRadius = UDim.new(0, 7)

            local previewHolder = Instance.new("Frame", frame)
            previewHolder.Size = UDim2.new(0, 168, 0, 170)
            previewHolder.Position = UDim2.new(0, 14, 0, 108)
            previewHolder.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
            previewHolder.BorderSizePixel = 0
            previewHolder.ZIndex = 4
            Instance.new("UICorner", previewHolder).CornerRadius = UDim.new(0, 12)
            local previewTitle = Instance.new("TextLabel", previewHolder)
            previewTitle.Size = UDim2.new(1, -16, 0, 18)
            previewTitle.Position = UDim2.new(0, 8, 0, 5)
            previewTitle.BackgroundTransparency = 1
            previewTitle.Text = "3D PREVIEW"
            previewTitle.TextColor3 = Color3.fromRGB(150, 150, 155)
            previewTitle.Font = Enum.Font.GothamBlack
            previewTitle.TextSize = 8
            previewTitle.TextXAlignment = Enum.TextXAlignment.Left
            previewTitle.ZIndex = 6
            local preview = Instance.new("ViewportFrame", previewHolder)
            preview.Size = UDim2.new(1, -12, 1, -30)
            preview.Position = UDim2.new(0, 6, 0, 24)
            preview.BackgroundColor3 = Color3.fromRGB(7, 7, 9)
            preview.BackgroundTransparency = 0.15
            preview.BorderSizePixel = 0
            preview.ZIndex = 5
            preview.Ambient = Color3.fromRGB(200, 200, 210)
            preview.LightColor = Color3.fromRGB(255, 255, 255)
            preview.LightDirection = Vector3.new(-0.35, -1, -0.55)
            Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 10)
            local previewWorld = Instance.new("WorldModel", preview)
            local previewPart = Instance.new("Part")
            previewPart.Name = "SkinPreviewPart"
            previewPart.Size = Vector3.new(1, 1, 1)
            previewPart.Anchored = true
            previewPart.CanCollide = false
            previewPart.CanTouch = false
            previewPart.CanQuery = false
            previewPart.Parent = previewWorld
            local previewMesh = Instance.new("SpecialMesh", previewPart)
            previewMesh.MeshType = Enum.MeshType.FileMesh
            local previewCam = Instance.new("Camera", preview)
            previewCam.FieldOfView = 38
            preview.CurrentCamera = previewCam

            local list = Instance.new("Frame", frame)
            list.Size = UDim2.new(0, 186, 0, 170)
            list.Position = UDim2.new(0, 190, 0, 108)
            list.BackgroundTransparency = 1
            list.ZIndex = 4
            local info = Instance.new("TextLabel", list)
            info.Size = UDim2.new(1, 0, 0, 20)
            info.BackgroundTransparency = 1
            info.TextColor3 = Color3.fromRGB(150, 150, 155)
            info.Font = Enum.Font.GothamSemibold
            info.TextSize = 9
            info.TextXAlignment = Enum.TextXAlignment.Left
            info.ZIndex = 5
            local function makeChoice(y)
                local b = Instance.new("TextButton", list)
                b.Size = UDim2.new(1, 0, 0, 38)
                b.Position = UDim2.new(0, 0, 0, y)
                b.BackgroundColor3 = Color3.fromRGB(20, 20, 23)
                b.BorderSizePixel = 0
                b.TextColor3 = Color3.new(1, 1, 1)
                b.Font = Enum.Font.GothamSemibold
                b.TextSize = 10
                b.AutoButtonColor = false
                b.ZIndex = 5
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
                local st = Instance.new("UIStroke", b)
                st.Color = Color3.fromRGB(70, 70, 75)
                st.Transparency = 0.6
                return b
            end
            local choose1 = makeChoice(25)
            local choose2 = makeChoice(70)
            local state = Instance.new("TextLabel", list)
            state.Size = UDim2.new(1, 0, 0, 36)
            state.Position = UDim2.new(0, 0, 0, 118)
            state.BackgroundTransparency = 1
            state.TextColor3 = Color3.fromRGB(150, 150, 155)
            state.Font = Enum.Font.GothamSemibold
            state.TextSize = 9
            state.TextWrapped = true
            state.TextXAlignment = Enum.TextXAlignment.Left
            state.ZIndex = 5

            local currentCat = "Bat"
            local options = {
                Bat = {
                    {key = "DiamondSword", label = "Diamond Sword"},
                    {key = "Katana", label = "Katana"},
                },
                Medusa = {
                    {key = "Skull", label = "Skull"},
                    {key = "GoldenDesertEagle", label = "Golden Desert Eagle"},
                }
            }
            local spinConnection
            local function updatePreview(key)
                local data = _G.AmbitiousCustomToolAssets and _G.AmbitiousCustomToolAssets[key]
                if not data then return end
                previewMesh.MeshId = data.mesh
                previewMesh.TextureId = data.tex
                previewMesh.Scale = data.scale
                previewPart.CFrame = CFrame.new()
                local maxDim = math.max(data.scale.X, data.scale.Y, data.scale.Z) * 2
                local dist = math.max(maxDim * 2.2, 3.5)
                previewCam.CFrame = CFrame.lookAt(Vector3.new(0, 0.2, dist), Vector3.new(0, 0, 0))
            end
            -- Live 3D manga/tool preview: slowly turn the selected mesh in the viewport.
            local previewStarted = tick()
            spinConnection = RunService.RenderStepped:Connect(function()
                if not preview.Parent or not previewPart.Parent then
                    if spinConnection then spinConnection:Disconnect(); spinConnection = nil end
                    return
                end
                local angle = (tick() - previewStarted) * 0.85
                previewPart.CFrame = CFrame.new(0, 0, 0) * CFrame.Angles(0, angle, 0)
            end)
            local function refreshSelector()
                local opts = options[currentCat]
                local selected = _G.AmbitiousCustomToolSkins and _G.AmbitiousCustomToolSkins[currentCat]
                choose1.Text = (selected == opts[1].key and "> " or "") .. opts[1].label
                choose2.Text = (selected == opts[2].key and "> " or "") .. opts[2].label
                info.Text = "CHOOSE " .. string.upper(currentCat) .. " SKIN"
                state.Text = "CURRENT: " .. (selected and (_G.AmbitiousCustomToolAssets[selected] or {}).label or "Default")
                updatePreview(selected or opts[1].key)
                local batActive = currentCat == "Bat"
                batTab.BackgroundColor3 = batActive and Color3.fromRGB(238,238,238) or Color3.fromRGB(25,25,28)
                batTab.TextColor3 = batActive and Color3.fromRGB(0,0,0) or Color3.fromRGB(225,225,225)
                medTab.BackgroundColor3 = not batActive and Color3.fromRGB(238,238,238) or Color3.fromRGB(25,25,28)
                medTab.TextColor3 = not batActive and Color3.fromRGB(0,0,0) or Color3.fromRGB(225,225,225)
            end
            local function selectOption(index)
                local entry = options[currentCat][index]
                if not entry then return end
                if _G.AmbitiousSetCustomToolSkin then
                    _G.AmbitiousSetCustomToolSkin(currentCat, entry.key)
                end
                refreshSelector()
                if ctStatusLabel then
                    ctStatusLabel.Text = entry.label .. "  ✓ APPLIED"
                    task.delay(1.5, function()
                        if ctStatusLabel and ctStatusLabel.Parent then ctStatusLabel.Text = "" end
                    end)
                end
                saveAllSettings()
            end
            batTab.Activated:Connect(function() currentCat = "Bat"; refreshSelector() end)
            medTab.Activated:Connect(function() currentCat = "Medusa"; refreshSelector() end)
            choose1.Activated:Connect(function() selectOption(1) end)
            choose2.Activated:Connect(function() selectOption(2) end)
            refreshSelector()

            frame.Size = UDim2.new(0, 0, 0, 0)
            frame.Position = UDim2.new(0.5, 0, 0.5, 0)
            TS:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 390, 0, 430),
                Position = UDim2.new(0.5, -195, 0.5, -215)
            }):Play()
        end
        ctPickBtn.Activated:Connect(openCtPicker)
        _G.KZAXOpenCustomToolsSelector = openCtPicker

        _G.KZAXCustomToolsPickBtn = ctPickBtn
    end

    setAntiLagVisual = mkToggle(visualPage, "Anti Lag", function(on) if on then enableAntiLag() else disableAntiLag() end; saveAllSettings() end)

    setShinyGraphicsVisual = mkToggle(visualPage, "Shiny Graphics", function(on)
        if _G.ShinyGraphics then
            if on then _G.ShinyGraphics.Enable() else _G.ShinyGraphics.Disable() end
        end
        _G.AceShinyGraphics.shinyEnabled = on
        saveAllSettings()
    end)

    setVizFpsBoosterVisual = mkToggle(visualPage, "Viz FPS Booster", function(on) toggleVizFpsBooster(on); saveAllSettings() end)

    -- CONFIG TAB
    local mainPage = contentPages["Main"]
    mkSect(mainPage, "Auto Steal")
    setInstaGrab = mkToggle(mainPage, "Auto Steal", function(on)
        CONFIG.AUTO_STEAL_ENABLED = on
        if on then pcall(startAutoStealSemi) else stopAutoSteal() end
        updateProgressBarVisibility(); saveAllSettings()
    end)
    do
        local row = mkRow(mainPage, 30); mkLabel(row, "Steal Radius")
        radInput = mkBox(row, CONFIG.STEAL_RANGE, 50, 56, function(v)
            if v and v >= 5 and v <= 300 then
                CONFIG.STEAL_RANGE = math.floor(v+0.5); Steal.StealRadius = CONFIG.STEAL_RANGE
                radInput.Text = tostring(CONFIG.STEAL_RANGE); saveAllSettings()
            end
        end)
    end

    local setKickWarnVisual
    setKickWarnVisual = mkToggle(mainPage, "Kick Warning", function(on)
        _G._AdaptKickWarningEnabled = on
        if _G._AdaptKickWarning then
            pcall(function() _G._AdaptKickWarning.SetEnabled(on) end)
        end
        saveAllSettings()
    end)
    _G.KZAXKickWarnSetState = setKickWarnVisual
    setKickWarnVisual(_G._AdaptKickWarningEnabled == true)

    do
        local stealMatchRow = mkRow(mainPage, 34)
        mkLabel(stealMatchRow, "Steal Bar Match")
        local smPill, smDot = mkPill(stealMatchRow, 44)
        local smOn = stealBarMatchEnabled
        animPill(smPill, smDot, smOn)
        local function applyStealBarMatchState(state)
            smOn = state
            stealBarMatchEnabled = state
            animPill(smPill, smDot, state)
            applyStealBarBackground()
            saveAllSettings()
        end
        setStealBarMatchVisual = function(state)
            if smOn == (state == true) then
                stealBarMatchEnabled = (state == true)
                animPill(smPill, smDot, stealBarMatchEnabled)
                return
            end
            applyStealBarMatchState(state == true)
        end
        local smClk = Instance.new("TextButton", smPill)
        smClk.Size = UDim2.new(1,0,1,0); smClk.BackgroundTransparency = 1; smClk.Text = ""
        smClk.AutoButtonColor = false; smClk.ZIndex = 10
        smClk.Activated:Connect(function() applyStealBarMatchState(not smOn) end)
    end

    mkSect(mainPage, "Config")
    setHideButtonsVisual = mkToggle(mainPage, "Hide Buttons", function(on)
        toggleHideButtons(on)
        saveAllSettings()
    end)
    setHideButtonsVisual(hideButtonsEnabled)

    setLockUIVisual = mkToggle(mainPage, "Lock UI", function(on) toggleLockUI(on); saveAllSettings() end)

    do
        local row = mkRow(mainPage, 34)
        mkLabel(row, "Tab Position")
        local tpHolder = Instance.new("Frame", row)
        tpHolder.Name = "TabPosBtnHolder"
        tpHolder.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
        tpHolder.BackgroundTransparency = 0.3
        tpHolder.BorderSizePixel = 0
        tpHolder.Size = UDim2.new(0, 66, 0, 26)
        tpHolder.Position = UDim2.new(1, -73, 0.5, -13)
        tpHolder.ClipsDescendants = true
        tpHolder.ZIndex = 8
        Instance.new("UICorner", tpHolder).CornerRadius = UDim.new(0, 13)
        local tpStroke = Instance.new("UIStroke", tpHolder)
        tpStroke.Color = Color3.fromRGB(255, 255, 255)
        tpStroke.Thickness = 1.2
        tpStroke.Transparency = 0.15
        local tpBtn = Instance.new("TextButton", tpHolder)
        tpBtn.Name = "TabPosButton"
        tpBtn.BackgroundTransparency = 1
        tpBtn.Text = "PICK"
        tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        tpBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        tpBtn.TextStrokeTransparency = 0.3
        tpBtn.TextSize = 11
        tpBtn.Font = Enum.Font.GothamBlack
        tpBtn.Size = UDim2.new(1, 0, 1, 0)
        tpBtn.BorderSizePixel = 0
        tpBtn.ZIndex = 9
        tpBtn.AutoButtonColor = false
        tpBtn.MouseEnter:Connect(function()
            TS:Create(tpHolder, TweenInfo.new(0.12), {Size = UDim2.new(0, 72, 0, 28), Position = UDim2.new(1, -76, 0.5, -14)}):Play()
        end)
        tpBtn.MouseLeave:Connect(function()
            TS:Create(tpHolder, TweenInfo.new(0.12), {Size = UDim2.new(0, 66, 0, 26), Position = UDim2.new(1, -73, 0.5, -13)}):Play()
        end)
        local tpGui = nil
        local tpJustClosedAt = 0
        local function closeTabPosPicker()
            if tpGui and tpGui.Parent then
                local f = tpGui:FindFirstChild("Frame")
                if f then TS:Create(f, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play() end
                local g = tpGui
                tpGui = nil
                tpJustClosedAt = tick()
                task.delay(0.25, function() pcall(function() g:Destroy() end) end)
            end
        end
        _G.KZAXTabPosClose = closeTabPosPicker
        local TP_ORDER = {"Up", "Bottom", "Left", "Right"}
        tpBtn.Activated:Connect(function()
            if tpGui then closeTabPosPicker(); return end
            if tick() - tpJustClosedAt < 0.25 then return end
            tpGui = Instance.new("ScreenGui")
            tpGui.Name = "KZAXTabPosPicker"
            tpGui.ResetOnSpawn = false
            tpGui.IgnoreGuiInset = true
            tpGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            tpGui.DisplayOrder = 999999
            tpGui.Parent = gui
            local backdrop = Instance.new("Frame", tpGui)
            backdrop.Name = "Backdrop"; backdrop.Size = UDim2.new(1, 0, 1, 0)
            backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            backdrop.BackgroundTransparency = 0.5; backdrop.BorderSizePixel = 0; backdrop.ZIndex = 1
            local frame = Instance.new("Frame", tpGui)
            frame.Name = "Frame"; frame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
            frame.BorderSizePixel = 0; frame.ZIndex = 2
            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 16)
            local fStroke = Instance.new("UIStroke", frame)
            fStroke.Color = Color3.fromRGB(90, 90, 90); fStroke.Thickness = 1.2; fStroke.Transparency = 0.3
            local titleBar = Instance.new("Frame", frame)
            titleBar.Size = UDim2.new(1, 0, 0, 48); titleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
            titleBar.BackgroundTransparency = 0.15; titleBar.BorderSizePixel = 0; titleBar.ZIndex = 3
            Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 16)
            local title = Instance.new("TextLabel", titleBar)
            title.Size = UDim2.new(1, -60, 1, 0); title.Position = UDim2.new(0, 18, 0, 0)
            title.BackgroundTransparency = 1; title.Text = "TAB POSITION PREVIEW"
            title.TextColor3 = Color3.fromRGB(255, 255, 255); title.Font = Enum.Font.GothamBlack
            title.TextSize = 16; title.TextXAlignment = Enum.TextXAlignment.Left; title.ZIndex = 4
            local closeBtn = Instance.new("TextButton", titleBar)
            closeBtn.Size = UDim2.new(0, 36, 0, 36); closeBtn.Position = UDim2.new(1, -44, 0, 6)
            closeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 28); closeBtn.BackgroundTransparency = 0.1
            closeBtn.BorderSizePixel = 0; closeBtn.Text = "X"; closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            closeBtn.Font = Enum.Font.GothamBlack; closeBtn.TextSize = 14
            closeBtn.AutoButtonColor = false; closeBtn.ZIndex = 4
            Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 10)
            closeBtn.Activated:Connect(closeTabPosPicker)
            local scrollFrame = Instance.new("ScrollingFrame", frame)
            scrollFrame.Size = UDim2.new(1, -16, 1, -64); scrollFrame.Position = UDim2.new(0, 8, 0, 56)
            scrollFrame.BackgroundTransparency = 1; scrollFrame.BorderSizePixel = 0
            scrollFrame.ScrollBarThickness = 4; scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; scrollFrame.ZIndex = 3
            local grid = Instance.new("UIGridLayout", scrollFrame)
            grid.CellSize = UDim2.new(0, 156, 0, 156); grid.CellPadding = UDim2.new(0, 8, 0, 8)
            grid.FillDirection = Enum.FillDirection.Horizontal
            grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
            grid.SortOrder = Enum.SortOrder.LayoutOrder
            local gridPad = Instance.new("UIPadding", scrollFrame)
            gridPad.PaddingLeft = UDim.new(0, 8); gridPad.PaddingTop = UDim.new(0, 8)
            gridPad.PaddingRight = UDim.new(0, 8); gridPad.PaddingBottom = UDim.new(0, 8)
            local cardStrokes = {}
            local function refreshCards()
                for mode, st in pairs(cardStrokes) do
                    local on = (_G._KZAXTabPosition == mode)
                    st.Color = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
                    st.Thickness = on and 1.8 or 1
                    st.Transparency = on and 0.05 or 0.5
                end
            end
            local MOCK = {
                Up     = {tabs={0.07,0.20,0.86,0.09}, tabsH=true,  body={0.07,0.34,0.86,0.58}},
                Bottom = {tabs={0.07,0.83,0.86,0.09}, tabsH=true,  body={0.07,0.20,0.86,0.56}},
                Left   = {tabs={0.07,0.20,0.19,0.62}, tabsH=false, body={0.31,0.20,0.62,0.72}},
                Right  = {tabs={0.74,0.20,0.19,0.62}, tabsH=false, body={0.07,0.20,0.62,0.72}},
            }
            local function drawCells(parent, x, y, w, h, n, horizontal, gap, z)
                for i = 1, n do
                    local cell = Instance.new("Frame", parent)
                    cell.BorderSizePixel = 0; cell.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
                    cell.BackgroundTransparency = 0.32; cell.ZIndex = z
                    if horizontal then
                        local cw = (w - gap*(n-1))/n
                        cell.Size = UDim2.new(cw, 0, h, 0)
                        cell.Position = UDim2.new(x + (cw+gap)*(i-1), 0, y, 0)
                    else
                        local ch = (h - gap*(n-1))/n
                        cell.Size = UDim2.new(w, 0, ch, 0)
                        cell.Position = UDim2.new(x, 0, y + (ch+gap)*(i-1), 0)
                    end
                    Instance.new("UICorner", cell).CornerRadius = UDim.new(0, 2)
                end
            end
            for i, mode in ipairs(TP_ORDER) do
                local card = Instance.new("TextButton", scrollFrame)
                card.Name = mode; card.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
                card.BorderSizePixel = 0; card.Text = ""; card.AutoButtonColor = false
                card.LayoutOrder = i; card.ZIndex = 3
                Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)
                cardStrokes[mode] = Instance.new("UIStroke", card)
                cardStrokes[mode].Color = Color3.fromRGB(50, 50, 50)
                cardStrokes[mode].Thickness = 1
                cardStrokes[mode].Transparency = 0.5
                local win = Instance.new("Frame", card)
                win.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
                win.BorderSizePixel = 0; win.ClipsDescendants = true
                win.Size = UDim2.new(1, -16, 1, -30); win.Position = UDim2.new(0, 8, 0, 8); win.ZIndex = 4
                Instance.new("UICorner", win).CornerRadius = UDim.new(0, 8)
                local M = MOCK[mode]
                drawCells(win, M.tabs[1], M.tabs[2], M.tabs[3], M.tabs[4], 5, M.tabsH, 0.012, 6)
                for j = 1, 4 do
                    local rowH = 0.115
                    local ry = M.body[2] + (rowH+0.028)*(j-1)
                    if ry + rowH > M.body[2] + M.body[4] then break end
                    local r = Instance.new("Frame", win)
                    r.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    r.BackgroundTransparency = 0.28; r.BorderSizePixel = 0
                    r.Size = UDim2.new(M.body[3], 0, rowH, 0)
                    r.Position = UDim2.new(M.body[1], 0, ry, 0); r.ZIndex = 5
                    Instance.new("UICorner", r).CornerRadius = UDim.new(0, 3)
                end
                local caption = Instance.new("TextLabel", card)
                caption.BackgroundTransparency = 1; caption.Text = string.upper(mode)
                caption.TextColor3 = Color3.fromRGB(255, 255, 255)
                caption.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                caption.TextStrokeTransparency = 0.3
                caption.Font = Enum.Font.GothamBlack; caption.TextSize = 11
                caption.Size = UDim2.new(1, 0, 0, 18); caption.Position = UDim2.new(0, 0, 1, -21)
                caption.ZIndex = 6
                card.Activated:Connect(function()
                    _G.KZAXApplyTabPosition(mode)
                    refreshCards()
                    saveAllSettings()
                end)
            end
            refreshCards()
            backdrop.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    closeTabPosPicker()
                end
            end)
            frame.Size = UDim2.new(0, 0, 0, 0)
            frame.Position = UDim2.new(0.5, 0, 0.5, 0)
            TS:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 380, 0, 404),
                Position = UDim2.new(0.5, -190, 0.5, -202)
            }):Play()
        end)
    end

    do
        local row = mkRow(mainPage, 34); mkLabel(row, "Button Scale")
        local container = Instance.new("Frame", row)
        container.Size = UDim2.new(0, 150, 1, 0); container.Position = UDim2.new(1, -160, 0, 0)
        container.BackgroundTransparency = 1; container.ZIndex = 8
        local leftBtn = Instance.new("TextButton", container)
        leftBtn.Size = UDim2.new(0, 32, 0, 26); leftBtn.Position = UDim2.new(0, 0, 0.5, -13)
        leftBtn.BackgroundColor3 = INP; leftBtn.BackgroundTransparency = 0.7
        leftBtn.BorderSizePixel = 0; leftBtn.Text = "<"; leftBtn.TextColor3 = RED
        leftBtn.Font = Enum.Font.GothamBlack; leftBtn.TextSize = 13; leftBtn.AutoButtonColor = false; leftBtn.ZIndex = 9
        Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 6)
        local leftStroke = Instance.new("UIStroke", leftBtn); leftStroke.Color = ROW_BORDER; leftStroke.Thickness = 1
        local valueLabel = Instance.new("TextLabel", container)
        valueLabel.Size = UDim2.new(0, 70, 0, 26); valueLabel.Position = UDim2.new(0.5, -35, 0.5, -13)
        valueLabel.BackgroundTransparency = 1; valueLabel.Text = string.format("%.2f", buttonScaleValue)
        valueLabel.TextColor3 = RED; valueLabel.Font = Enum.Font.GothamBlack
        valueLabel.TextSize = 12; valueLabel.TextXAlignment = Enum.TextXAlignment.Center; valueLabel.ZIndex = 9
        local rightBtn = Instance.new("TextButton", container)
        rightBtn.Size = UDim2.new(0, 32, 0, 26); rightBtn.Position = UDim2.new(1, -32, 0.5, -13)
        rightBtn.BackgroundColor3 = INP; rightBtn.BackgroundTransparency = 0.7
        rightBtn.BorderSizePixel = 0; rightBtn.Text = ">"; rightBtn.TextColor3 = RED
        rightBtn.Font = Enum.Font.GothamBlack; rightBtn.TextSize = 13; rightBtn.AutoButtonColor = false; rightBtn.ZIndex = 9
        Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 6)
        local rightStroke = Instance.new("UIStroke", rightBtn); rightStroke.Color = ROW_BORDER; rightStroke.Thickness = 1
        local function updateButtonScale(delta)
            local newVal = math.clamp(buttonScaleValue + delta, 0.50, 1.50)
            if newVal ~= buttonScaleValue then
                buttonScaleValue = newVal; valueLabel.Text = string.format("%.2f", buttonScaleValue)
                applyButtonScale(buttonScaleValue); saveAllSettings()
                queueConfigSave("mobile button size")
            end
        end
        leftBtn.Activated:Connect(function() updateButtonScale(-0.05) end)
        rightBtn.Activated:Connect(function() updateButtonScale(0.05) end)
        _G.buttonScaleValueLabel = valueLabel
    end
    do
        local row = mkRow(mainPage, 34); mkLabel(row, "UI Scale")
        local container = Instance.new("Frame", row)
        container.Size = UDim2.new(0, 150, 1, 0); container.Position = UDim2.new(1, -160, 0, 0)
        container.BackgroundTransparency = 1; container.ZIndex = 8
        local leftBtn = Instance.new("TextButton", container)
        leftBtn.Size = UDim2.new(0, 32, 0, 26); leftBtn.Position = UDim2.new(0, 0, 0.5, -13)
        leftBtn.BackgroundColor3 = INP; leftBtn.BackgroundTransparency = 0.7
        leftBtn.BorderSizePixel = 0; leftBtn.Text = "<"; leftBtn.TextColor3 = RED
        leftBtn.Font = Enum.Font.GothamBlack; leftBtn.TextSize = 13; leftBtn.AutoButtonColor = false; leftBtn.ZIndex = 9
        Instance.new("UICorner", leftBtn).CornerRadius = UDim.new(0, 6)
        local leftStroke = Instance.new("UIStroke", leftBtn); leftStroke.Color = ROW_BORDER; leftStroke.Thickness = 1
        local valueLabel = Instance.new("TextLabel", container)
        valueLabel.Size = UDim2.new(0, 70, 0, 26); valueLabel.Position = UDim2.new(0.5, -35, 0.5, -13)
        valueLabel.BackgroundTransparency = 1; valueLabel.Text = string.format("%.2f", uiScaleValue / 100)
        valueLabel.TextColor3 = RED; valueLabel.Font = Enum.Font.GothamBlack
        valueLabel.TextSize = 12; valueLabel.TextXAlignment = Enum.TextXAlignment.Center; valueLabel.ZIndex = 9
        local rightBtn = Instance.new("TextButton", container)
        rightBtn.Size = UDim2.new(0, 32, 0, 26); rightBtn.Position = UDim2.new(1, -32, 0.5, -13)
        rightBtn.BackgroundColor3 = INP; rightBtn.BackgroundTransparency = 0.7
        rightBtn.BorderSizePixel = 0; rightBtn.Text = ">"; rightBtn.TextColor3 = RED
        rightBtn.Font = Enum.Font.GothamBlack; rightBtn.TextSize = 13; rightBtn.AutoButtonColor = false; rightBtn.ZIndex = 9
        Instance.new("UICorner", rightBtn).CornerRadius = UDim.new(0, 6)
        local rightStroke = Instance.new("UIStroke", rightBtn); rightStroke.Color = ROW_BORDER; rightStroke.Thickness = 1
        local function updateUIScale(delta)
            local newVal = math.clamp(uiScaleValue + delta, 50, 150)
            if newVal ~= uiScaleValue then
                uiScaleValue = newVal
                if mainUIScale then mainUIScale.Scale = uiScaleValue / 100 end
                if pbScale then pbScale.Scale = uiScaleValue / 100 end
                valueLabel.Text = string.format("%.2f", uiScaleValue / 100)
                local saved = saveAllSettings()
                if not saved then pcall(function() queueConfigSave("ui scale") end) end
            end
        end
        leftBtn.Activated:Connect(function() updateUIScale(-5) end)
        rightBtn.Activated:Connect(function() updateUIScale(5) end)
        _G.uiScaleValueLabel = valueLabel
    end

    do
        local row = mkRow(mainPage, 44); row.Size = UDim2.new(1, 0, 0, 44)
        local saveBtn = Instance.new("TextButton", row)
        saveBtn.Size = UDim2.new(1, -12, 0.8, 0); saveBtn.Position = UDim2.new(0, 6, 0.1, 0)
        saveBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8); saveBtn.BackgroundTransparency = 0.5
        saveBtn.BorderSizePixel = 0; saveBtn.Text = "SAVE NOW"; saveBtn.TextColor3 = RED
        saveBtn.Font = Enum.Font.GothamBold; saveBtn.TextSize = 13
        saveBtn.TextStrokeColor3 = Color3.fromRGB(120, 120, 120); saveBtn.TextStrokeTransparency = 0
        saveBtn.AutoButtonColor = false; saveBtn.ZIndex = 8
        Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
        local saveStroke = Instance.new("UIStroke", saveBtn)
        saveStroke.Color = ROW_BORDER; saveStroke.Thickness = 1.2; saveStroke.Transparency = 0.5
        saveBtn.Activated:Connect(function()
            local ok = saveAllSettings()
            saveBtn.Text = ok and "SAVED ✓" or "SAVE FAILED"
            task.delay(1.2, function() if saveBtn and saveBtn.Parent then saveBtn.Text = "SAVE NOW" end end)
        end)
    end
    do
        local row = mkRow(mainPage, 44); row.Size = UDim2.new(1, 0, 0, 44)
        local resetPosBtn = Instance.new("TextButton", row)
        resetPosBtn.Size = UDim2.new(1, -12, 0.8, 0); resetPosBtn.Position = UDim2.new(0, 6, 0.1, 0)
        resetPosBtn.BackgroundColor3 = Color3.fromRGB(8, 8, 8); resetPosBtn.BackgroundTransparency = 0.5
        resetPosBtn.BorderSizePixel = 0; resetPosBtn.Text = "RESET POSITIONS"; resetPosBtn.TextColor3 = RED
        resetPosBtn.Font = Enum.Font.GothamBold; resetPosBtn.TextSize = 13
        resetPosBtn.TextStrokeColor3 = Color3.fromRGB(120, 120, 120); resetPosBtn.TextStrokeTransparency = 0
        resetPosBtn.AutoButtonColor = false; resetPosBtn.ZIndex = 8
        Instance.new("UICorner", resetPosBtn).CornerRadius = UDim.new(0, 8)
        local resetStroke = Instance.new("UIStroke", resetPosBtn)
        resetStroke.Color = ROW_BORDER; resetStroke.Thickness = 1.2; resetStroke.Transparency = 0.5
        local resetDebounce = false
        resetPosBtn.Activated:Connect(function()
            if resetDebounce then return end
            resetDebounce = true; resetFloatingPositions(); saveAllSettings()
            resetPosBtn.Text = "RESET ✓"
            task.delay(1.2, function() if resetPosBtn and resetPosBtn.Parent then resetPosBtn.Text = "RESET POSITIONS"; resetDebounce = false end end)
        end)
    end
    do
        local row = mkRow(mainPage, 44); row.Size = UDim2.new(1, 0, 0, 44)
        local delBtn = Instance.new("TextButton", row)
        delBtn.Size = UDim2.new(1, -12, 0.8, 0); delBtn.Position = UDim2.new(0, 6, 0.1, 0)
        delBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); delBtn.BackgroundTransparency = 0.5
        delBtn.BorderSizePixel = 0; delBtn.Text = "RESET ALL SETTINGS"; delBtn.TextColor3 = RED
        delBtn.Font = Enum.Font.GothamBold; delBtn.TextSize = 13
        delBtn.TextStrokeColor3 = Color3.fromRGB(120, 120, 120); delBtn.TextStrokeTransparency = 0
        delBtn.AutoButtonColor = false; delBtn.ZIndex = 8
        Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 8)
        local delStroke = Instance.new("UIStroke", delBtn)
        delStroke.Color = ROW_BORDER; delStroke.Thickness = 1.2; delStroke.Transparency = 0.5
        local deleteState = 0; local originalDeleteText = "RESET ALL SETTINGS"; local delDebounce = false
        delBtn.Activated:Connect(function()
            if delDebounce then return end
            if deleteState == 0 then
                deleteState = 1; delBtn.Text = "CONFIRM RESET?"; delBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 120)
                task.delay(2, function()
                    if delBtn and delBtn.Parent and deleteState == 1 then
                        deleteState = 0; delBtn.Text = originalDeleteText; delBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                    end
                end)
            elseif deleteState == 1 then
                delDebounce = true
                local success = pcall(resetToFactoryDefaults)
                delBtn.Text = success and "RESET ✓" or "ERROR"
                delBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); deleteState = 0
                task.delay(1.5, function()
                    if delBtn and delBtn.Parent then
                        delBtn.Text = originalDeleteText; delBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); delDebounce = false
                    end
                end)
            end
        end)
    end

    -- KEYBIND TAB
    local keyPage = contentPages["Keybinds"]
    mkSect(keyPage, "Keybinds")
    addKeybindRow(keyPage, "Carry Mode", KB.CarryToggle)
    addKeybindRow(keyPage, "Lagger Mode", KB.LaggerMode)
    addKeybindRow(keyPage, "Lagger Carry", KB.LaggerCarry)
    addKeybindRow(keyPage, "Auto Left", KB.AutoLeft)
    addKeybindRow(keyPage, "Auto Right", KB.AutoRight)
    addKeybindRow(keyPage, "Auto Bat", KB.AutoBat)
    addKeybindRow(keyPage, "BAT BYPASS", KB.Bypass)
    addKeybindRow(keyPage, "TP Down", KB.TPFloor)
    addKeybindRow(keyPage, "Drop Brainrot", KB.DropBrainrot)
    addKeybindRow(keyPage, "Insta Reset", KB.InstaReset)
    addKeybindRow(keyPage, "GUI Menu", KB.ToggleGUI)
    local spacer = Instance.new("Frame", keyPage)
    spacer.Size = UDim2.new(1, 0, 0, 16); spacer.BackgroundTransparency = 1
    spacer.LayoutOrder = getNextOrder(keyPage); spacer.ZIndex = 7

    -- PROGRESS BAR (SEMI 60 RADIUS CENTERED)
    pbFrame = Instance.new("Frame", gui)
    pbFrame.Size = UDim2.new(0, 360, 0, 58); pbFrame.Position = UDim2.new(0.5, -180, 1, -68)
    pbFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0); pbFrame.BackgroundTransparency = 0
    pbFrame.BorderSizePixel = 0; pbFrame.Active = true; pbFrame.ClipsDescendants = true
    pbFrame.Visible = CONFIG.AUTO_STEAL_ENABLED; pbFrame.ZIndex = 1
    pbScale = Instance.new("UIScale", pbFrame); pbScale.Scale = uiScaleValue / 100
    if savedProgressBarPos then
        pbFrame.Position = UDim2.new(savedProgressBarPos.XScale or 0.5, savedProgressBarPos.XOffset or -180,
            savedProgressBarPos.YScale or 1, savedProgressBarPos.YOffset or -60)
    end
    Instance.new("UICorner", pbFrame).CornerRadius = UDim.new(0, 16)
    local pbSt = Instance.new("UIStroke", pbFrame)
    pbSt.Color = Color3.fromRGB(0, 0, 0); pbSt.Thickness = 2; pbSt.Transparency = 0; pbSt.ZIndex = 1
    applyStealBarBackground()

    local function makePBLabel(parent, size, pos, txt, fontSize, align)
        local l = Instance.new("TextLabel", parent)
        l.Size = size; l.Position = pos
        l.BackgroundTransparency = 1; l.Text = txt
        l.TextColor3 = Color3.fromRGB(255, 255, 255)
        l.Font = Enum.Font.GothamBold; l.TextSize = fontSize
        l.TextXAlignment = align or Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Center
        l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); l.TextStrokeTransparency = 0.35
        l.ZIndex = 2
        return l
    end

    progressPct = makePBLabel(pbFrame, UDim2.new(0, 62, 0, 18), UDim2.new(0, 12, 0, 3),
        "0%", 14, Enum.TextXAlignment.Left)
    progressPct.Font = Enum.Font.GothamBlack
    pbFpsLbl = makePBLabel(pbFrame, UDim2.new(0, 100, 0, 15), UDim2.new(0, 12, 0, 18),
        "FPS: 60", 9, Enum.TextXAlignment.Left)
    pbRadiusLbl = makePBLabel(pbFrame, UDim2.new(1, -24, 0, 15), UDim2.new(0, 12, 0, 18),
        "SEMI 60 RADIUS", 10, Enum.TextXAlignment.Center)
    pbPingLbl = makePBLabel(pbFrame, UDim2.new(0, 90, 0, 15), UDim2.new(1, -102, 0, 18),
        "PING: 0ms", 9, Enum.TextXAlignment.Right)

    local fillRegion = Instance.new("Frame", pbFrame)
    fillRegion.Size = UDim2.new(1, -24, 0, 10); fillRegion.Position = UDim2.new(0, 12, 1, -16)
    fillRegion.BackgroundColor3 = Color3.fromRGB(30, 30, 30); fillRegion.BackgroundTransparency = 0
    fillRegion.BorderSizePixel = 0; fillRegion.ClipsDescendants = true; fillRegion.ZIndex = 1
    Instance.new("UICorner", fillRegion).CornerRadius = UDim.new(1, 0)
    local fillRegStroke = Instance.new("UIStroke", fillRegion)
    fillRegStroke.Color = Color3.fromRGB(0, 0, 0); fillRegStroke.Thickness = 1; fillRegStroke.Transparency = 0

    progressFill = Instance.new("Frame", fillRegion)
    progressFill.Size = UDim2.new(0, 0, 1, 0); progressFill.Position = UDim2.new(0, 0, 0, 0)
    progressFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    progressFill.BackgroundTransparency = 0
    progressFill.BorderSizePixel = 0
    progressFill.ZIndex = 1
    Instance.new("UICorner", progressFill).CornerRadius = UDim.new(1, 0)

    progressRadLbl = pbFpsLbl
    drag(pbFrame)
    task.spawn(function()
        local lastFrame = tick(); local fpsSamples = {}; local fpsAvg = 60
        RunService.RenderStepped:Connect(function()
            local now = tick(); local dt = now - lastFrame; lastFrame = now
            if dt > 0 then
                table.insert(fpsSamples, 1 / dt)
                if #fpsSamples > 30 then table.remove(fpsSamples, 1) end
                local sum = 0
                for _, v in ipairs(fpsSamples) do sum = sum + v end
                fpsAvg = sum / #fpsSamples
            end
        end)
        while true do
            local ping = 0
            pcall(function() ping = LP:GetNetworkPing() * 1000 end)
            if pbFpsLbl then pbFpsLbl.Text = string.format("FPS: %d", math.floor(fpsAvg + 0.5)) end
            if pbPingLbl then pbPingLbl.Text = string.format("PING: %dms", math.floor(ping + 0.5)) end
            if pbRadiusLbl then pbRadiusLbl.Text = string.format("SEMI %d RADIUS", math.floor(tonumber(CONFIG.STEAL_RANGE) or 60)) end
            task.wait(0.5)
        end
    end)
end

function createMobilePanel()
    local panel = Instance.new("ScreenGui")
    panel.Name = "KZAXMobilePanel"
    panel.ResetOnSpawn = false
    panel.DisplayOrder = 1000001
    panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
    if not pcall(function() panel.Parent = game:GetService("CoreGui") end) then panel.Parent = LP:WaitForChild("PlayerGui") end
    local BTN_W, BTN_H = 78, 78
    local GAP = 8; local COLUMNS = 3; local ROWS = 4; local ROW_GAP = 26
    local PANEL_W = BTN_W * COLUMNS + GAP * (COLUMNS - 1)
    local PANEL_H = BTN_H * ROWS + ROW_GAP * (ROWS - 1)
    local container = Instance.new("Frame", panel)
    container.Name = "FloatingPanel"; container.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
    container.Position = UDim2.new(1, -PANEL_W - 10, 0, -20)
    container.BackgroundTransparency = 1; container.BorderSizePixel = 0
    container.Active = false; container.Selectable = false; container.ClipsDescendants = false
    local btnContainer = Instance.new("Frame", container)
    btnContainer.Name = "ButtonsContainer"; btnContainer.Size = UDim2.new(1, 0, 1, 0)
    btnContainer.BackgroundTransparency = 1; btnContainer.ClipsDescendants = false
    local RED = Color3.fromRGB(255, 255, 255)
    local INACTIVE_BG = Color3.fromRGB(8, 0, 0)
    local INACTIVE_TEXT = Color3.fromRGB(255, 255, 255)
    local buttons = {}
    local buttonNames = {"TpBat", "DropBR", "AutoLeft", "AutoBat", "AutoRight", "TpDown", "Carry", "Lagger1", "Lagger2"}
    local buttonTexts = {"BAT\nBYPASS", "DROP\nBR", "AUTO\nLEFT", "BAT\nAIMBOT", "AUTO\nRIGHT", "TP\nDOWN", "CARRY\nSPD", "LAGGER\nMODE", "LAGGER\nCARRY"}

    local function createButton(name, text, order, isToggle, callback)
        local btn = Instance.new("TextButton", btnContainer)
        btn.Name = name
        btn.Size = UDim2.new(0, BTN_W, 0, BTN_H)
        btn.BackgroundColor3 = INACTIVE_BG
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 10
        local savedPos = savedButtonPositions[name]
        if savedPos then
            btn.Position = UDim2.new(0, savedPos.X or 0, 0, savedPos.Y or 0)
        else
            local defX, defY = getDefaultButtonPosition(name)
            btn.Position = UDim2.new(0, defX, 0, defY)
        end
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 18)
        local buttonGradient = Instance.new("UIGradient")
        buttonGradient.Name = "WhiteBlackDiagonalGradient"
        buttonGradient.Rotation = 45
        buttonGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(5, 5, 5)),
            ColorSequenceKeypoint.new(0.22, Color3.fromRGB(35, 35, 35)),
            ColorSequenceKeypoint.new(0.46, Color3.fromRGB(180, 180, 180)),
            ColorSequenceKeypoint.new(0.58, Color3.fromRGB(220, 220, 220)),
            ColorSequenceKeypoint.new(0.78, Color3.fromRGB(60, 60, 60)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(5, 5, 5))
        })
        buttonGradient.Enabled = false
        buttonGradient.Parent = btn
        local buttonStroke = Instance.new("UIStroke")
        buttonStroke.Name = "BlackOuterOutline"
        buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        buttonStroke.Thickness = 2
        buttonStroke.Color = Color3.fromRGB(0, 0, 0)
        buttonStroke.Transparency = 0
        buttonStroke.LineJoinMode = Enum.LineJoinMode.Round
        buttonStroke.Parent = btn
        local blackGradient = Instance.new("UIGradient")
        blackGradient.Name = "BlackEdgeHighlight"
        blackGradient.Rotation = 0
        blackGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 0, 0)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))
        })
        blackGradient.Parent = buttonStroke
        local label = Instance.new("TextLabel", btn)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = INACTIVE_TEXT
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 10
        label.TextWrapped = true
        label.ZIndex = 11
        local pressEffect = false
        local toggleState = false
        local function refreshVisual()
            local show = pressEffect or toggleState
            btn.BackgroundColor3 = show and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(8, 0, 0)
            buttonGradient.Enabled = show
            if show then
                label.TextColor3 = Color3.fromRGB(0, 0, 0)
                label.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
                label.TextStrokeTransparency = 0.15
            else
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextStrokeTransparency = 1
            end
            buttonStroke.Color = Color3.fromRGB(0, 0, 0)
            buttonStroke.Thickness = show and 2.2 or 2
            buttonStroke.Transparency = 0
        end
        local function setActive(state)
            toggleState = state and true or false
            refreshVisual()
        end
        local pressDebounce = false
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                if pressDebounce then return end
                pressDebounce = true
                task.delay(0.12, function() pressDebounce = false end)
                if uiLocked then
                    pressEffect = true
                    refreshVisual()
                end
            end
        end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                pressEffect = false
                refreshVisual()
            end
        end)
        -- LOCK UI OFF: drag only; LOCK UI ON: activate only.
        local dragInput, dragStart, startPos
        local didDrag = false
        local movedRecently = false
        btn.InputBegan:Connect(function(input)
            if uiLocked or _isDraggingButton then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
                dragStart = input.Position
                startPos = btn.Position
                didDrag = false
            end
        end)
        btn.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if not dragStart or not startPos or uiLocked or _isDraggingButton then return end
            if input == dragInput then
                local delta = input.Position - dragStart
                if not didDrag and (math.abs(delta.X) > 5 or math.abs(delta.Y) > 5) then
                    didDrag = true
                end
                if didDrag then
                    btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                if didDrag then
                    movedRecently = true
                    pcall(syncFloatingButtonPositions)
                    pcall(saveAllSettings)
                    task.delay(0.2, function() movedRecently = false end)
                end
                dragInput, dragStart, startPos, didDrag = nil, nil, nil, false
            end
        end)
        btn.Activated:Connect(function()
            -- OFF = position editing only. ON = floating button actions enabled.
            if movedRecently or not uiLocked then return end
            if callback then callback(setActive) end
        end)
        buttons[name] = {btn = btn, setActive = setActive, label = label}
        return setActive
    end

    for i, name in ipairs(buttonNames) do
        local text = buttonTexts[i]; local callback
        if name == "TpBat" then callback = function(setActive) toggleBypass(); setActive(bypassToggled); saveAllSettings() end
        elseif name == "DropBR" then callback = function(setActive)
            if autoBatEnabled then return end
            setActive(true)
            executeDropWithToggle(function(v) if dropBrainrotSetVisual then dropBrainrotSetVisual(v) end end)
            task.delay(0.3, function() setActive(false) end)
        end
        elseif name == "AutoLeft" then callback = function(setActive)
            autoLeftEnabled = not autoLeftEnabled; setActive(autoLeftEnabled)
            if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
            if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
            saveAllSettings()
        end
        elseif name == "AutoBat" then callback = function(setActive)
            if not autoBatEnabled then enableAutoBat() else disableAutoBat() end
            setActive(autoBatEnabled); saveAllSettings()
        end
        elseif name == "AutoRight" then callback = function(setActive)
            autoRightEnabled = not autoRightEnabled; setActive(autoRightEnabled)
            if autoRightEnabled then startAutoRight() else stopAutoRight() end
            if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
            saveAllSettings()
        end
        elseif name == "TpDown" then callback = function(setActive) runTPDown(); setActive(true); task.delay(0.2, function() setActive(false) end) end
        elseif name == "Carry" then callback = function(setActive)
            SpeedModule.toggleCarryMode()
            syncSpeedLegacyState()
            local st = SpeedModule.getState()
            setActive(st.speedMode)
            if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(false) end
            if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(false) end
            refreshSpeedModeLabel(); saveAllSettings()
        end
        elseif name == "Lagger1" then callback = function(setActive)
            SpeedModule.toggleLaggerMode()
            syncSpeedLegacyState()
            local st = SpeedModule.getState()
            setActive(st.laggerToggled and not st.laggerCarryToggled)
            if buttons.Carry and buttons.Carry.setActive then buttons.Carry.setActive(false) end
            if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(false) end
            refreshSpeedModeLabel(); saveAllSettings()
        end
        elseif name == "Lagger2" then callback = function(setActive)
            SpeedModule.toggleLaggerCarryMode()
            syncSpeedLegacyState()
            local st = SpeedModule.getState()
            setActive(st.laggerCarryToggled)
            if buttons.Carry and buttons.Carry.setActive then buttons.Carry.setActive(false) end
            if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(false) end
            refreshSpeedModeLabel(); saveAllSettings()
        end
        end
        local setActive = createButton(name, text, i-1, true, callback)
        if name == "AutoBat" then mobSetAutoBat = setActive end
        if name == "AutoLeft" then mobSetAutoLeft = setActive end
        if name == "AutoRight" then mobSetAutoRight = setActive end
        if name == "DropBR" then mobSetDropBR = setActive end
        if name == "TpDown" then mobSetTpDown = setActive end
        if name == "Carry" then mobSetCarry = setActive end
        if name == "Lagger1" then mobSetLagger1 = setActive end
        if name == "Lagger2" then mobSetLagger2 = setActive end
    end
    if buttons.AutoBat and buttons.AutoBat.setActive then buttons.AutoBat.setActive(autoBatEnabled) end
    if buttons.AutoLeft and buttons.AutoLeft.setActive then buttons.AutoLeft.setActive(autoLeftEnabled) end
    if buttons.AutoRight and buttons.AutoRight.setActive then buttons.AutoRight.setActive(autoRightEnabled) end
    if buttons.Carry and buttons.Carry.setActive then buttons.Carry.setActive(speedMode) end
    if buttons.Lagger1 and buttons.Lagger1.setActive then buttons.Lagger1.setActive(laggerToggled and laggerLevel == 1) end
    if buttons.Lagger2 and buttons.Lagger2.setActive then buttons.Lagger2.setActive(laggerToggled and laggerLevel == 2) end
    if savedMobilePanelPos then
        container.Position = UDim2.new(savedMobilePanelPos.XScale or 1, savedMobilePanelPos.XOffset or (-PANEL_W - 10),
            savedMobilePanelPos.YScale or 0, savedMobilePanelPos.YOffset or 0)
    end
    return panel
end

function createInstaResetFloatingButton()
    local panel = Instance.new("ScreenGui")
    panel.Name = "InstaResetButton"; panel.ResetOnSpawn = false
    panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; panel.DisplayOrder = 20
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
    if not pcall(function() panel.Parent = game:GetService("CoreGui") end) then panel.Parent = LP:WaitForChild("PlayerGui") end
    return panel
end
function createBypassFloatingButton()
    local panel = Instance.new("ScreenGui")
    panel.Name = "BypassButton"; panel.ResetOnSpawn = false
    panel.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; panel.DisplayOrder = 21
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(panel) end end)
    if not pcall(function() panel.Parent = game:GetService("CoreGui") end) then panel.Parent = LP:WaitForChild("PlayerGui") end
    bypassFloatingButton = panel
    return panel
end

function reapplyAllStates()
    if antiRagdollEnabled then setAntiRag(true) else setAntiRag(false) end
    if bodyLockEnabled then startBodyLock() else stopBodyLock() end
    if jumpEnabled then startJumpMode() else stopJumpMode() end
    if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
    if autoRightEnabled then startAutoRight() else stopAutoRight() end
    if autoBatEnabled then enableAutoBat() else disableAutoBat() end
    if bypassToggled then toggleBypass(true) else toggleBypass(false) end
    if autoTPDownEnabled then startAutoTPDown() else stopAutoTPDown() end
    if medusaCounterEnabled then setMedusaCounterState(true) else setMedusaCounterState(false) end
    if batCounterEnabled then startBatCounter() else stopBatCounter() end
    if espEnabled then toggleESP(true) else toggleESP(false) end
    if antiLagEnabled then enableAntiLag() else disableAntiLag() end
    if antiDieEnabled then enableAntiDie() else disableAntiDie() end
    toggleVizFpsBooster(vizFpsBoosterEnabled)
    if _G.ShinyGraphics then
        if _G.AceShinyGraphics and _G.AceShinyGraphics.shinyEnabled then
            _G.ShinyGraphics.Enable()
        else
            _G.ShinyGraphics.Disable()
        end
    end
    if stretchEnabled then enableStretch() else disableStretch() end
    if setJumpVisual then setJumpVisual(jumpEnabled) end
    if setAntiRagVisual then setAntiRagVisual(antiRagdollEnabled) end
    if setBodyLockVisual then setBodyLockVisual(bodyLockEnabled) end
    if setVizFpsBoosterVisual then setVizFpsBoosterVisual(vizFpsBoosterEnabled) end
    if setAutoTPDownVisual then setAutoTPDownVisual(autoTPDownEnabled) end
    if CONFIG.AUTO_STEAL_ENABLED then pcall(startAutoStealSemi) else stopAutoSteal() end
    if currentAccessoryPack and currentAccessoryPack ~= "Off" then applyAccessoryPack(currentAccessoryPack) end
    if setStealBarMatchVisual then setStealBarMatchVisual(stealBarMatchEnabled) end
    applyStealBarBackground()
    updateProgressBarVisibility(); refreshSpeedModeLabel(); applyBackgroundImage(currentBgIndex)
    if _G.KZAXApplyTabPosition then pcall(_G.KZAXApplyTabPosition, _G._KZAXTabPosition or "Up") end
    if _G.InfiniteJump then
        _G.InfiniteJump.SetMode(_G._KZAXJumpMode or "HOLD")
        _G.InfiniteJump.SetEnabled(jumpEnabled)
    end
end
function updateUIFromLoaded()
    task.wait()
    if savedMainGuiPos and main then
        main.Position = UDim2.new(savedMainGuiPos.XScale or 0.5, savedMainGuiPos.XOffset or -165,
            savedMainGuiPos.YScale or 0.5, savedMainGuiPos.YOffset or -250)
        local pos = savedMainGuiPos
        task.defer(function()
            if main and main.Parent and pos then
                main.Position = UDim2.new(pos.XScale or 0.5, pos.XOffset or -165,
                    pos.YScale or 0.5, pos.YOffset or -250)
            end
        end)
    end
    if normalBox then normalBox.Text = tostring(NS) end
    if carryBox then carryBox.Text = tostring(CS) end
    if radInput then radInput.Text = tostring(CONFIG.STEAL_RANGE) end
    if laggerBox then laggerBox.Text = tostring(LAGGER_SPEED_1) end
    if lagger2Box then lagger2Box.Text = tostring(LAGGER_SPEED_2) end
    if autoTPHeightBox then autoTPHeightBox.Text = tostring(autoTPDownHeight) end
    if uiScaleBox then uiScaleBox.Text = tostring(uiScaleValue) end
    if _G.uiScaleValueLabel then _G.uiScaleValueLabel.Text = string.format("%.2f", uiScaleValue / 100) end
    if mainUIScale then mainUIScale.Scale = uiScaleValue / 100 end
    if pbScale then pbScale.Scale = uiScaleValue / 100 end
    if _G.buttonScaleValueLabel then _G.buttonScaleValueLabel.Text = string.format("%.2f", buttonScaleValue) end
    applyButtonScale(buttonScaleValue)
    if dropModeBtnRef then dropModeBtnRef.Text = dropMode == 1 and "Fling" or "Jump Drop" end
    refreshSpeedModeLabel()
    for _, ref in ipairs(keyButtonRefs) do
        local entry = ref.entry
        local label = (entry.gp and entry.gp.Name) or (entry.kb and entry.kb.Name) or "None"
        ref.btn.Text = label
    end
    if savedProgressBarPos and pbFrame then
        pbFrame.Position = UDim2.new(savedProgressBarPos.XScale or 0.5, savedProgressBarPos.XOffset or -180,
            savedProgressBarPos.YScale or 1, savedProgressBarPos.YOffset or -60)
    end
    if uiLocked and setLockUIVisual then setLockUIVisual(true) end
    if antiRagdollEnabled then if setAntiRagVisual then setAntiRagVisual(true) end; startAntiRagdoll() end
    if bodyLockEnabled then if setBodyLockVisual then setBodyLockVisual(true) end; startBodyLock() end
    if stealBarMatchEnabled then if setStealBarMatchVisual then setStealBarMatchVisual(true) end end
    if CONFIG.AUTO_STEAL_ENABLED and setInstaGrab then setInstaGrab(true); pcall(startAutoStealSemi) end
    if jumpEnabled then if setJumpVisual then setJumpVisual(true) end; startJumpMode()
    else if setJumpVisual then setJumpVisual(false) end end
    if _G.InfiniteJump then
        _G.InfiniteJump.SetMode(_G._KZAXJumpMode or "HOLD")
        _G.InfiniteJump.SetEnabled(jumpEnabled)
    end
    if medusaCounterEnabled then
        if setMedusaVisual then setMedusaVisual(true) end
        if LP.Character then setupMedusa(LP.Character) end
    else if setMedusaVisual then setMedusaVisual(false) end; stopMedusaCounter() end
    if batCounterEnabled then if setBatCounterVisual then setBatCounterVisual(true) end; startBatCounter()
    else if setBatCounterVisual then setBatCounterVisual(false) end; stopBatCounter() end
    if autoTPDownEnabled then if setAutoTPDownVisual then setAutoTPDownVisual(true) end; startAutoTPDown() end
    if antiLagEnabled then if setAntiLagVisual then setAntiLagVisual(true) end; enableAntiLag()
    else if setAntiLagVisual then setAntiLagVisual(false) end; disableAntiLag() end
    if antiDieEnabled then
        enableAntiDie()
        if setAntiDieVisual then setAntiDieVisual(true) end
    else
        disableAntiDie()
        if setAntiDieVisual then setAntiDieVisual(false) end
    end
    if vizFpsBoosterEnabled then if setVizFpsBoosterVisual then setVizFpsBoosterVisual(true) end; toggleVizFpsBooster(true)
    else if setVizFpsBoosterVisual then setVizFpsBoosterVisual(false) end; toggleVizFpsBooster(false) end
    if _G.AceShinyGraphics and _G.AceShinyGraphics.shinyEnabled then
        if _G.ShinyGraphics then _G.ShinyGraphics.Enable() end
        if setShinyGraphicsVisual then setShinyGraphicsVisual(true) end
    else
        if _G.ShinyGraphics then _G.ShinyGraphics.Disable() end
        if setShinyGraphicsVisual then setShinyGraphicsVisual(false) end
    end
    if espEnabled then toggleESP(true); if setESPVIsual then setESPVIsual(true) end
    else toggleESP(false); if setESPVIsual then setESPVIsual(false) end end
    if stretchEnabled then enableStretch(); if _G.stretchToggleSetter then _G.stretchToggleSetter(true) end
    else if _G.stretchToggleSetter then _G.stretchToggleSetter(false) end end
    if povEnabled then
        enablePOV()
        if setPOVVisual then setPOVVisual(true) end
    else
        disablePOV()
        if setPOVVisual then setPOVVisual(false) end
    end
    if mobSetAutoBat then mobSetAutoBat(autoBatEnabled) end
    if mobSetAutoLeft then mobSetAutoLeft(autoLeftEnabled) end
    if mobSetAutoRight then mobSetAutoRight(autoRightEnabled) end
    if mobSetCarry then mobSetCarry(speedMode) end
    if mobSetLagger1 then mobSetLagger1(laggerToggled and laggerLevel == 1) end
    if mobSetLagger2 then mobSetLagger2(laggerToggled and laggerLevel == 2) end
    updateProgressBarVisibility(); startEnemySpeed()
    if currentAccessoryPack and currentAccessoryPack ~= "Off" then task.wait(0.2); applyAccessoryPack(currentAccessoryPack) end
    if accSelectorLabel then accSelectorLabel.Text = string.upper(currentAccessoryPack or "OFF") end
    if refreshAccessoryCards then refreshAccessoryCards() end
    applyBackgroundImage(currentBgIndex)
    if _G.KZAXApplyTabPosition then pcall(_G.KZAXApplyTabPosition, _G._KZAXTabPosition or "Up") end
end
local function createNameTag() return end

-- ============================================================
-- BUILD GUI
-- ============================================================
buildGui()

if main then
    local dragHandle = Instance.new("Frame")
    dragHandle.Name = "MenuDragHandle"
    dragHandle.Parent = main
    dragHandle.Size = UDim2.new(1, -92, 0, 58)
    dragHandle.Position = UDim2.new(0, 0, 0, 0)
    dragHandle.BackgroundTransparency = 1
    dragHandle.BorderSizePixel = 0
    dragHandle.Active = true
    dragHandle.Selectable = false
    dragHandle.ZIndex = 999
    drag(main)
end

if main then pcall(makeRotatingBW, main, 3.5, 4) end
applyBWToEverything(gui, 2.5, 3)

MobilePanel = createMobilePanel()
instaResetFloatingButton = nil
bypassFloatingButton = nil
applyButtonScale(buttonScaleValue)
_isBuildingGui = false
local _loadedConfigOK = loadAllSettings()
if MobilePanel then toggleHideButtons(hideButtonsEnabled) end

if _G.KZAXApplyTabPosition then
    pcall(_G.KZAXApplyTabPosition, _G._KZAXTabPosition or "Up")
end

if _loadedConfigOK and savedMainGuiPos and main then
    local p = savedMainGuiPos
    main.Position = UDim2.new(
        tonumber(p.XScale) or 0.5, tonumber(p.XOffset) or -175,
        tonumber(p.YScale) or 0.5, tonumber(p.YOffset) or -260
    )
end

if _loadedConfigOK then
    task.defer(function()
        if currentSkyTheme and CANDY_SKY_PRESETS[currentSkyTheme] then
            setSkyTheme(currentSkyTheme)
        else
            currentSkyTheme = "Off"
            setSkyTheme("Off")
        end
    end)
end

local function applySavedButtonPositionsNow()
    if MobilePanel and MobilePanel:FindFirstChild("FloatingPanel") then
        local container = MobilePanel.FloatingPanel
        local buttonsContainer = container:FindFirstChild("ButtonsContainer")
        if buttonsContainer then
            for name, pos in pairs(savedButtonPositions or {}) do
                local btn = buttonsContainer:FindFirstChild(name)
                if btn and btn:IsA("GuiObject") and type(pos) == "table" then
                    btn.Position = UDim2.new(0, tonumber(pos.X) or 0, 0, tonumber(pos.Y) or 0)
                end
            end
        end
        if savedMobilePanelPos then
            container.Position = UDim2.new(savedMobilePanelPos.XScale or 1, savedMobilePanelPos.XOffset or 0,
                savedMobilePanelPos.YScale or 0, savedMobilePanelPos.YOffset or 0)
        end
    end
    if pbFrame and savedProgressBarPos then
        pbFrame.Position = UDim2.new(savedProgressBarPos.XScale or 0.5, savedProgressBarPos.XOffset or -180,
            savedProgressBarPos.YScale or 1, savedProgressBarPos.YOffset or -60)
    end
end
if _loadedConfigOK then updateUIFromLoaded() else applyButtonScale(buttonScaleValue) end
if _loadedConfigOK then
    applyButtonScale(buttonScaleValue)
    if _G.buttonScaleValueLabel then _G.buttonScaleValueLabel.Text = string.format("%.2f", buttonScaleValue) end
end
applySavedButtonPositionsNow()

if setStealBarMatchVisual then pcall(setStealBarMatchVisual, stealBarMatchEnabled) end
pcall(applyStealBarBackground)

task.spawn(function()
    local lastSignature = nil
    while task.wait(0.25) do
        if MobilePanel and MobilePanel.Parent and not _isLoading and not _isResetting then
            local parts = {}
            local container = MobilePanel:FindFirstChild("FloatingPanel")
            local bc = container and container:FindFirstChild("ButtonsContainer")
            if bc then
                for _, btn in ipairs(bc:GetChildren()) do
                    if btn:IsA("GuiObject") then
                        parts[#parts + 1] = btn.Name .. ":" .. btn.Position.X.Offset .. ":" .. btn.Position.Y.Offset
                    end
                end
                table.sort(parts)
                parts[#parts + 1] = "P:" .. container.Position.X.Scale .. ":" .. container.Position.X.Offset .. ":" ..
                    container.Position.Y.Scale .. ":" .. container.Position.Y.Offset
            end
            local sig = table.concat(parts, "|")
            if lastSignature and sig ~= lastSignature then
                pcall(syncFloatingButtonPositions); pcall(saveDedicatedButtonPositions); pcall(saveAllSettings)
            end
            lastSignature = sig
        end
    end
end)

if LP.Character then
    task.wait(0.1)
    while not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or not LP.Character:FindFirstChildOfClass("Humanoid") do task.wait() end
    setupMovementAndIndicators(LP.Character)
    if _G._KZAXApplyCurrentOutfit then
        task.wait(0.3)
        pcall(_G._KZAXApplyCurrentOutfit)
    elseif currentAccessoryPack ~= "Off" then
        task.wait(0.3); applyAccessoryPack(currentAccessoryPack)
    end
    createNameTag()
end

LP.CharacterAdded:Connect(function(char)
    stopAutoSteal(); stopAutoLeft(); stopAutoRight(); stopBatCounter(); stopMedusaCounter(); stopDropBrainrot()
    if autoBatEnabled then disableAutoBat() end
    if bypassToggled then stopBypassAimbot() end
    task.wait(0.1)
    while not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or not LP.Character:FindFirstChildOfClass("Humanoid") do task.wait() end
    setupMovementAndIndicators(char); createNameTag()
    reapplyAllStates(); updateProgressBarVisibility(); refreshSpeedModeLabel()
    if _G._KZAXApplyCurrentOutfit then
        task.wait(0.5)
        pcall(_G._KZAXApplyCurrentOutfit)
    end
end)

local lastLaggerToggle = 0
local LAGGER_COOLDOWN = 0.3
local function activateLaggerCarry()
    SpeedModule.toggleLaggerCarryMode()
    syncSpeedLegacyState()
    resetMovementState(); saveAllSettings()
end
UIS.InputBegan:Connect(function(input, gpe)
    if _anyKeyListening then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if gpe or UIS:GetFocusedTextBox() then return end
    elseif not isGamepadInput(input) then return end
    if not isBindableInput(input) then return end
    local kc = input.KeyCode; if not kc then return end
    if kbMatch(KB.LaggerMode, kc) then
        if tick() - lastLaggerToggle >= LAGGER_COOLDOWN then
            lastLaggerToggle = tick(); toggleLaggerCycle(); saveAllSettings()
        end
        return
    end
    if kbMatch(KB.LaggerCarry, kc) then activateLaggerCarry(); return end
    if kbMatch(KB.ToggleGUI, kc) then
        if main and main.Visible then if hideGui then hideGui() end
        else if showGui then showGui() end end
        return
    end
    if kbMatch(KB.CarryToggle, kc) then toggleCarryMode(); saveAllSettings(); return end
    if kbMatch(KB.DropBrainrot, kc) then
        if not dropActive then
            if dropBrainrotSetVisual then dropBrainrotSetVisual(true) end
            executeDropWithToggle(dropBrainrotSetVisual)
        end
        return
    end
    if kbMatch(KB.TPFloor, kc) then runTPDown(); return end
    if kbMatch(KB.InstaReset, kc) then instaReset(); return end
    if kbMatch(KB.AutoLeft, kc) then
        autoLeftEnabled = not autoLeftEnabled
        if autoLeftEnabled then startAutoLeft() else stopAutoLeft() end
        if autoLeftSetVisual then autoLeftSetVisual(autoLeftEnabled) end
        if mobSetAutoLeft then mobSetAutoLeft(autoLeftEnabled) end
        saveAllSettings(); return
    end
    if kbMatch(KB.AutoRight, kc) then
        autoRightEnabled = not autoRightEnabled
        if autoRightEnabled then startAutoRight() else stopAutoRight() end
        if autoRightSetVisual then autoRightSetVisual(autoRightEnabled) end
        if mobSetAutoRight then mobSetAutoRight(autoRightEnabled) end
        saveAllSettings(); return
    end
    if kbMatch(KB.AutoBat, kc) then
        if not autoBatEnabled then
            enableAutoBat()
            if autoBatSetVisual then autoBatSetVisual(true) end
            if mobSetAutoBat then mobSetAutoBat(true) end
        else
            disableAutoBat()
            if autoBatSetVisual then autoBatSetVisual(false) end
            if mobSetAutoBat then mobSetAutoBat(false) end
        end
        saveAllSettings(); return
    end
    if kbMatch(KB.Bypass, kc) then toggleBypass(); saveAllSettings(); return end
end)

task.spawn(function()
    while task.wait(30) do
        pcall(function()
            collectgarbage("collect")
            if #_G.Lust.Connections > 0 then
                for k, v in pairs(_G.Lust.Connections) do
                    if type(v) == "table" and #v == 0 then _G.Lust.Connections[k] = nil end
                end
            end
            if #enemySpeedLabels > 30 then
                for player in pairs(enemySpeedLabels) do
                    if not player or not player.Character then enemySpeedLabels[player] = nil end
                end
            end
        end)
    end
end)

-- ============================================================
-- KICK WARNING MODULE
-- ============================================================
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local localPlayer = Players.LocalPlayer
    local playerGui = localPlayer:WaitForChild("PlayerGui")

    local function createKickWarning()
        if _G._AdaptKickWarning and type(_G._AdaptKickWarning.Destroy) == "function" then
            pcall(_G._AdaptKickWarning.Destroy)
        end
        local DURATION = 2.3
        local destroyed, showing, wasHolding = false, false, false
        local renderConn, camConn = nil, nil
        local old = playerGui:FindFirstChild("AdaptKickWarning")
        if old then old:Destroy() end
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "AdaptKickWarning"
        screenGui.ResetOnSpawn = false
        screenGui.IgnoreGuiInset = true
        screenGui.DisplayOrder = 999
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        screenGui.Parent = playerGui
        local banner = Instance.new("Frame", screenGui)
        banner.Name = "KickTimerBanner"
        banner.AnchorPoint = Vector2.new(0.5, 0)
        banner.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        banner.BorderSizePixel = 0
        banner.Visible = false
        banner.ClipsDescendants = true
        banner.ZIndex = 100
        Instance.new("UICorner", banner).CornerRadius = UDim.new(1, 0)
        local readyFill = Instance.new("Frame", banner)
        readyFill.Name = "ReadyFill"
        readyFill.Size = UDim2.new(1, 0, 1, 0)
        readyFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        readyFill.BackgroundTransparency = 1
        readyFill.BorderSizePixel = 0
        readyFill.ZIndex = 101
        Instance.new("UICorner", readyFill).CornerRadius = UDim.new(1, 0)
        local borderPath = Instance.new("Frame", banner)
        borderPath.Name = "ProgressBorderPath"
        borderPath.BackgroundTransparency = 1
        borderPath.Size = UDim2.fromScale(1, 1)
        borderPath.ClipsDescendants = true
        borderPath.ZIndex = 102
        Instance.new("UICorner", borderPath).CornerRadius = UDim.new(1, 0)
        local segments = {}
        local litCount = 0
        local label = Instance.new("TextLabel", banner)
        label.Size = UDim2.new(1, -16, 1, 0); label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1; label.Text = "DON'T ENTER"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBlack; label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center; label.ZIndex = 103
        local BAR_W, BAR_H, TOP_OFFSET = 320, 28, 12
        local function clearSegments()
            for _, seg in ipairs(segments) do
                if seg and seg.Parent then seg:Destroy() end
            end
            segments = {}; litCount = 0
        end
        local function buildSegments()
            clearSegments()
            local thick = 2; local inset = thick + 1
            local radius = math.max(3, (BAR_H - inset * 2) * 0.5)
            local halfH = BAR_H * 0.5
            local startX = inset + radius
            local endX = BAR_W - inset - radius
            local straightLen = math.max(1, endX - startX)
            local arcLen = math.pi * radius
            local total = straightLen * 2 + arcLen * 2
            local count = math.clamp(math.ceil(total / 4), 60, 160)
            local segLen = total / count + 1.0
            for i = 1, count do
                local dist = (i - 0.5) / count * total
                local px, py, rot
                if dist <= straightLen then
                    px = startX + dist; py = inset; rot = 0
                elseif dist <= straightLen + arcLen then
                    local ang = -math.pi/2 + (dist - straightLen) / radius
                    px = endX + math.cos(ang) * radius
                    py = halfH + math.sin(ang) * radius
                    rot = ang + math.pi/2
                elseif dist <= straightLen * 2 + arcLen then
                    px = endX - (dist - straightLen - arcLen); py = BAR_H - inset; rot = math.pi
                else
                    local ang = math.pi/2 + (dist - straightLen*2 - arcLen) / radius
                    px = startX + math.cos(ang) * radius
                    py = halfH + math.sin(ang) * radius
                    rot = ang + math.pi/2
                end
                local seg = Instance.new("Frame", borderPath)
                seg.Name = "ProgressSegment"
                seg.AnchorPoint = Vector2.new(0.5, 0.5)
                seg.Position = UDim2.fromOffset(px, py)
                seg.Size = UDim2.fromOffset(segLen, thick)
                seg.Rotation = math.deg(rot)
                seg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                seg.BackgroundTransparency = 1
                seg.BorderSizePixel = 0; seg.ZIndex = 102
                Instance.new("UICorner", seg).CornerRadius = UDim.new(1, 0)
                segments[i] = seg
            end
        end
        local function resetVisual()
            readyFill.BackgroundTransparency = 1
            litCount = 0
            for _, seg in ipairs(segments) do seg.BackgroundTransparency = 1 end
        end
        local function updateProgress(p)
            local total = #segments
            local target = math.clamp(math.floor(math.clamp(p, 0, 1) * total + 0.5), 0, total)
            if target < litCount then
                for i = target + 1, litCount do
                    if segments[i] then segments[i].BackgroundTransparency = 1 end
                end
            elseif litCount < target then
                for i = litCount + 1, target do
                    if segments[i] then segments[i].BackgroundTransparency = 0 end
                end
            end
            litCount = target
        end
        local function resize()
            local cam = workspace.CurrentCamera
            local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
            BAR_W = math.clamp(math.floor(vp.X * 0.25), 260, 340)
            BAR_H = 28; TOP_OFFSET = 12
            banner.Size = UDim2.fromOffset(BAR_W, BAR_H)
            buildSegments()
            if not banner.Visible then
                resetVisual()
                banner.Position = UDim2.new(0.5, 0, 0, -BAR_H - 10)
            end
        end
        resize()
        local cam = workspace.CurrentCamera
        if cam then
            camConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
        end
        local function hide()
            if renderConn then renderConn:Disconnect(); renderConn = nil end
            if banner.Parent then
                banner.Visible = false
                resetVisual()
                banner.Position = UDim2.new(0.5, 0, 0, -BAR_H - 10)
            end
            showing = false
        end
        local function isHoldingBrainrot()
            if type(_G._AdaptSafeModeHoldingBrainrot) == "function" then
                local ok, r = pcall(_G._AdaptSafeModeHoldingBrainrot)
                if ok and r then return true end
            end
            if localPlayer:GetAttribute("Stealing") == true then return true end
            local char = localPlayer.Character
            if not char then return false end
            for _, c in ipairs(char:GetChildren()) do
                local n = c.Name:lower()
                if n:find("brainrot") or n:find("brain") or n:find("animal")
                    or n:find("carry") or n:find("stolen") or n:find("held") or n:find("steal") then
                    return true
                end
            end
            for k, v in pairs(char:GetAttributes()) do
                local n = k:lower()
                if v == true and (n:find("carrying") or n:find("carry") or n:find("stealing")
                    or n:find("isstealing") or n:find("hasbrainrot")) then
                    return true
                end
            end
            return false
        end
        local function isEnabled() return _G._AdaptKickWarningEnabled == true end
        local function show()
            if destroyed or not isEnabled() or showing then return end
            showing = true
            resize(); resetVisual()
            label.Text = "DON'T ENTER"
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            banner.Visible = true
            banner.Position = UDim2.new(0.5, 0, 0, -BAR_H - 10)
            TweenService:Create(banner, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Position = UDim2.new(0.5, 0, 0, TOP_OFFSET) }):Play()
            local startT = tick()
            local finished = false
            if renderConn then renderConn:Disconnect() end
            renderConn = RunService.RenderStepped:Connect(function()
                if destroyed or not isEnabled() then hide(); return end
                if finished or not banner.Parent then
                    if renderConn then renderConn:Disconnect(); renderConn = nil end
                    return
                end
                local p = math.clamp((tick() - startT) / DURATION, 0, 1)
                updateProgress(p)
                if p >= 1 then
                    finished = true
                    if renderConn then renderConn:Disconnect(); renderConn = nil end
                    readyFill.BackgroundTransparency = 0
                    for _, s in ipairs(segments) do s.BackgroundTransparency = 0 end
                    label.Text = "ENTER"
                    label.TextColor3 = Color3.fromRGB(0, 0, 0)
                    task.delay(2.5, function()
                        if destroyed then return end
                        if not isEnabled() then hide(); return end
                        TweenService:Create(banner, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                            { Position = UDim2.new(0.5, 0, 0, -BAR_H - 10) }):Play()
                        task.delay(0.45, function()
                            if destroyed then return end
                            banner.Visible = false
                            showing = false
                        end)
                    end)
                end
            end)
        end
        local function setEnabled(v)
            _G._AdaptKickWarningEnabled = (v == true)
            if not _G._AdaptKickWarningEnabled then hide(); wasHolding = false end
            return _G._AdaptKickWarningEnabled
        end
        local function destroy()
            destroyed = true
            hide()
            if camConn then camConn:Disconnect(); camConn = nil end
            if screenGui.Parent then screenGui:Destroy() end
            if _G._AdaptKickWarning and _G._AdaptKickWarning.Destroy == destroy then
                _G._AdaptKickWarning = nil
            end
        end
        _G._AdaptKickWarning = {
            SetDuration = function(v) local n = tonumber(v); if n and n > 0 then DURATION = n end end,
            GetDuration = function() return DURATION end,
            SetEnabled = setEnabled,
            IsEnabled = isEnabled,
            Show = show,
            Hide = hide,
            Destroy = destroy,
        }
        setEnabled(_G._AdaptKickWarningEnabled == true)
        task.spawn(function()
            while not destroyed and screenGui.Parent do
                if isEnabled() then
                    local h = isHoldingBrainrot()
                    if not wasHolding and h then show() end
                    wasHolding = h
                else
                    if showing then hide() end
                    wasHolding = false
                end
                task.wait(0.1)
            end
        end)
    end
    createKickWarning()
end

-- ============================================================
-- MVP SONG INTRO CODE (standalone)
-- Tumutugtog ng redrum intro mula 0:40 hanggang 0:50
-- ============================================================

local SoundService = game:GetService("SoundService")

local MVP_REDRUM_URL = "https://file.garden/algLafWA1jk8WMfK/redrum_spotdown.org%202.mp3"
local MVP_REDRUM_FILE = "mvp_redrum.mp3"

local mvpRedrumAsset = nil
local mvpFullRedrumSound = nil
local mvpMusicRequest = 0
local mvpMusicRefreshers = {}

-- ------------------------------------------------------------
-- 1) Kunin / i-download ang redrum asset
-- ------------------------------------------------------------
local function getMVPRedrumAsset()
    if mvpRedrumAsset then return mvpRedrumAsset end

    local assetLoader = getcustomasset or getsynasset
    if type(assetLoader) ~= "function" or type(writefile) ~= "function" then
        return nil, "custom asset functions unavailable"
    end

    local exists = false
    if type(isfile) == "function" then
        local okExists, result = pcall(isfile, MVP_REDRUM_FILE)
        exists = okExists and result == true
    end

    if not exists then
        local okDownload, data = pcall(function()
            return game:HttpGet(MVP_REDRUM_URL)
        end)
        if not okDownload or type(data) ~= "string" or #data < 256 then
            return nil, "could not download redrum"
        end

        local okWrite = pcall(writefile, MVP_REDRUM_FILE, data)
        if not okWrite then
            return nil, "could not save redrum"
        end
    end

    local okAsset, asset = pcall(assetLoader, MVP_REDRUM_FILE)
    if not okAsset or type(asset) ~= "string" or asset == "" then
        return nil, "could not create redrum asset"
    end

    mvpRedrumAsset = asset
    return asset
end

-- ------------------------------------------------------------
-- 2) Gumawa at mag-play ng redrum sound
-- ------------------------------------------------------------
local function makeMVPRedrumSound(startAt, name)
    local asset, err = getMVPRedrumAsset()
    if not asset then
        warn("[MVP Music] " .. tostring(err))
        return nil
    end

    local sound = Instance.new("Sound")
    sound.Name = name or "MVPRedrum"
    sound.SoundId = asset
    sound.Volume = 1
    sound.Looped = false
    sound.Parent = SoundService

    local startPosition = math.max(0, tonumber(startAt) or 0)
    pcall(function() sound.TimePosition = startPosition end)
    pcall(function() sound:Play() end)

    task.spawn(function()
        local startedWaiting = tick()
        while sound.Parent and not sound.IsLoaded and tick() - startedWaiting < 8 do
            task.wait(0.05)
        end
        if sound.Parent then
            pcall(function()
                sound.TimePosition = startPosition
                if not sound.Playing then sound:Play() end
            end)
        end
    end)

    return sound
end

-- ------------------------------------------------------------
-- 3) Ihinto ang full redrum (para sa music toggle)
-- ------------------------------------------------------------
local function stopMVPFullRedrum()
    mvpMusicRequest = mvpMusicRequest + 1
    if mvpFullRedrumSound then
        pcall(function() mvpFullRedrumSound:Stop() end)
        pcall(function() mvpFullRedrumSound:Destroy() end)
        mvpFullRedrumSound = nil
    end
end

-- ------------------------------------------------------------
-- 4) INTRO PLAYER (40s -> 50s)
-- ------------------------------------------------------------
local function playMVPRedrumIntro()
    -- linisin ang dating intro sound kung meron
    local oldIntro = SoundService:FindFirstChild("MVPRedrumIntro")
    if oldIntro then
        pcall(function() oldIntro:Stop() end)
        pcall(function() oldIntro:Destroy() end)
    end

    local introSound = makeMVPRedrumSound(40, "MVPRedrumIntro")

    task.spawn(function()
        local thisSound = introSound
        if not thisSound then return end

        -- hintayin ma-load
        local loadDeadline = tick() + 15
        while thisSound.Parent and not thisSound.IsLoaded and tick() < loadDeadline do
            task.wait(0.05)
        end
        if not thisSound.Parent then return end

        -- i-set sa 40s at i-play
        pcall(function()
            thisSound.TimePosition = 40
            thisSound:Play()
        end)

        -- siguraduhing tumutugtog mula 40s
        local playDeadline = tick() + 5
        while thisSound.Parent and (not thisSound.Playing or thisSound.TimePosition < 39.9) and tick() < playDeadline do
            pcall(function()
                if thisSound.TimePosition < 39.9 then
                    thisSound.TimePosition = 40
                end
                if not thisSound.Playing then
                    thisSound:Play()
                end
            end)
            task.wait(0.03)
        end

        -- hintayin hanggang 50s
        while thisSound.Parent and thisSound.TimePosition < 50 do
            task.wait(0.03)
        end

        -- linisin
        if thisSound.Parent then
            pcall(function() thisSound:Stop() end)
            pcall(function() thisSound:Destroy() end)
        end
        if introSound == thisSound then
            introSound = nil
        end
    end)
end

-- ------------------------------------------------------------
-- 5) AWTU-MATICONG PAG-PLAY
-- ------------------------------------------------------------
playMVPRedrumIntro()

-- (opsyonal) expose sa _G para ma-trigger ulit kung gusto
_G.MVPPlayRedrumIntro = playMVPRedrumIntro
_G.MVPStopRedrum = stopMVPFullRedrum