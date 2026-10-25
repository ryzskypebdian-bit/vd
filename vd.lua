local IMG_LOGO_TITLE = "rbxassetid://93349170559446"
local IMG_LOGO_NIEELS = "rbxassetid://93349170559446"

local LUCIDE_ICONS = {
    Close = "rbxassetid://10747384394",
    Minus = "rbxassetid://10734896206",
    Lock = "rbxassetid://10723434711",
    Unlock = "rbxassetid://10723434711",
}

local Library = {}
Library.Scheme = {}
Library.Scheme.AccentColor     = Color3.fromRGB(0, 255, 255)
Library.Scheme.BackgroundColor = Color3.fromRGB(8, 12, 20)
Library.Scheme.MainColor       = Color3.fromRGB(14, 20, 35)
Library.Scheme.OutlineColor    = Color3.fromRGB(0, 179, 255)
Library.Scheme.FontColor       = Color3.fromRGB(180, 239, 255)

local function applyGlowStroke(parent, color1, color2)
    pcall(function()
        if parent:IsA("UIStroke") then
            parent.Color = Color3.fromRGB(255, 255, 255)
        elseif parent:IsA("GuiObject") then
            parent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        end
    end)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, color1 or Library.Scheme.AccentColor),
        ColorSequenceKeypoint.new(1.00, color2 or Library.Scheme.MainColor)
    }
    gradient.Parent = parent
    local rotationSpeed = 120
    local runService = game:GetService("RunService")
    local connection
    connection = runService.Heartbeat:Connect(function(deltaTime)
        if gradient.Parent then
            gradient.Rotation = (gradient.Rotation + rotationSpeed * deltaTime) % 360
        else
            connection:Disconnect()
        end
    end)
    return gradient
end

local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local CoreGui=game:GetService("CoreGui")
local RS=game:GetService("RunService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local Lighting=game:GetService("Lighting")
local WS=game:GetService("Workspace")
local VIM=game:GetService("VirtualInputManager")
local GuiService=game:GetService("GuiService")
local CollectionService=game:GetService("CollectionService")
local TweenService=game:GetService("TweenService")

while not Players.LocalPlayer do task.wait() end
local player = Players.LocalPlayer
local GUI = player:WaitForChild("PlayerGui")
local CAMERA = workspace.CurrentCamera
local KILLER_MARKER = "Lookscriptkiller"

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
local LocalPlayer = player
local UserInputService = UIS
local PlayerGui = GUI
local LP = player
local LOCAL_PLAYER = player

local DEVELOPER_NAME = "rizky"

_G.NIEELS = _G.NIEELS or {}
_G.NIEELS.ScriptAlive = true
_G.NIEELS.SkipEndscreen = false

local StretchRes = { Enabled = false, Amount = 0.67, Conn = nil }

local function StartStretch()
    if StretchRes.Conn then return end
    StretchRes.Conn = RS.RenderStepped:Connect(function()
        if not StretchRes.Enabled then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        cam.CFrame = cam.CFrame * CFrame.new(0,0,0, 1,0,0, 0,StretchRes.Amount,0, 0,0,1)
    end)
end
local function StopStretch()
    if StretchRes.Conn then StretchRes.Conn:Disconnect(); StretchRes.Conn = nil end
end
local function SetStretchRes(enabled)
    StretchRes.Enabled = enabled
    if enabled then StartStretch() else StopStretch() end
end
local function SetStretchAmount(v) StretchRes.Amount = v end

local localPlayer = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera

local SkillCheckConfig = { Enabled = false, Mode = "Legit" }
local SkillCheckState = { busy = false, RandomMode_IsNormal = false }
local SkillCheckConn = nil

local function FindSkillCheckButton()
    local pg = LP:FindFirstChild("PlayerGui") or PlayerGui
    if not pg then return nil end
    local survivorMob = pg:FindFirstChild("Survivor-mob")
    if not survivorMob then return nil end
    local controls = survivorMob:FindFirstChild("Controls")
    if not controls then return nil end
    local action = controls:FindFirstChild("action")
    return action or controls:FindFirstChild("check")
end

local function PressSkillCheck()
    local btn = FindSkillCheckButton()
    if btn and btn:IsA("GuiObject") and btn.Visible and type(firesignal) == "function" then
        pcall(function()
            firesignal(btn.MouseButton1Down)
            task.wait(0.005)
            firesignal(btn.MouseButton1Up)
        end)
        return true
    end
    if btn and btn:IsA("GuiObject") and btn.Visible then
        pcall(function()
            local absPos = btn.AbsolutePosition
            local absSize = btn.AbsoluteSize
            local inset = GuiService:GetGuiInset()
            local touchId = 8822 + math.random(1, 9999)
            VirtualInputManager:SendTouchEvent(touchId, 0, absPos.X + absSize.X/2 + inset.X, absPos.Y + absSize.Y/2 + inset.Y)
            task.wait(0.005)
            VirtualInputManager:SendTouchEvent(touchId, 2, absPos.X + absSize.X/2 + inset.X, absPos.Y + absSize.Y/2 + inset.Y)
        end)
        return true
    end
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        task.wait(0.005)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
    return true
end

local function StopSkillCheckLoop()
    if SkillCheckConn then SkillCheckConn:Disconnect(); SkillCheckConn = nil end
end

local function StartSkillCheckLoop()
    StopSkillCheckLoop()
    SkillCheckConn = RS.Heartbeat:Connect(function()
        if not SkillCheckConfig.Enabled or SkillCheckState.busy then return end
        local pg = LP:FindFirstChild("PlayerGui") or PlayerGui
        if not pg then return end
        local prompt = pg:FindFirstChild("SkillCheckPromptGui")
        if not prompt then return end
        local check = prompt:FindFirstChild("Check")
        if not check or not check.Visible then SkillCheckState.RandomMode_IsNormal = false; return end
        local line = check:FindFirstChild("Line")
        local goal = check:FindFirstChild("Goal")
        if not line or not goal then return end
        local useInstant = SkillCheckConfig.Mode == "Instant"
        if not useInstant then
            useInstant = SkillCheckConfig.Mode == "Random"
            if useInstant then useInstant = not SkillCheckState.RandomMode_IsNormal end
        end
        if useInstant then
            line.Rotation = goal.Rotation + 109
            SkillCheckState.busy = true
            task.spawn(function() PressSkillCheck(); task.wait(0.05); SkillCheckState.busy = false end)
            return
        end
        local isNormal = SkillCheckConfig.Mode == "Normal"
            or (SkillCheckConfig.Mode == "Random" and SkillCheckState.RandomMode_IsNormal)
        local lineRot = line.Rotation % 360
        local goalRot = goal.Rotation % 360
        local minAngle, maxAngle
        if isNormal then
            minAngle = (goalRot + 116) % 360; maxAngle = (goalRot + 140) % 360
        else
            minAngle = (goalRot + 102) % 360; maxAngle = (goalRot + 116) % 360
        end
        local inZone
        if maxAngle < minAngle then inZone = (lineRot >= minAngle) or (lineRot <= maxAngle)
        else inZone = (lineRot >= minAngle) and (lineRot <= maxAngle) end
        if inZone then
            SkillCheckState.busy = true
            task.spawn(function() PressSkillCheck(); task.wait(0.05); SkillCheckState.busy = false end)
        end
    end)
end

local SkillCheck = {}
function SkillCheck.SetEnabled(state)
    SkillCheckConfig.Enabled = state and true or false
    if SkillCheckConfig.Enabled then StartSkillCheckLoop() else StopSkillCheckLoop() end
end
function SkillCheck.SetMode(mode)
    if mode == "Legit" or mode == "Instant" or mode == "Normal" or mode == "Random" then
        SkillCheckConfig.Mode = mode; SkillCheckState.RandomMode_IsNormal = false
    end
end
function SkillCheck.GetMode() return SkillCheckConfig.Mode end
function SkillCheck.IsEnabled() return SkillCheckConfig.Enabled end

LP.CharacterAdded:Connect(function()
    SkillCheckState.busy = false; SkillCheckState.RandomMode_IsNormal = false
    if SkillCheckConfig.Enabled then task.wait(1); StartSkillCheckLoop() end
end)

task.spawn(function()
    local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
    local killerPerks = remotes and remotes:WaitForChild("KillerPerks", 5)
    local kingscourge = killerPerks and killerPerks:WaitForChild("kingscourge", 5)
    local kingScourgeStart = kingscourge and kingscourge:WaitForChild("KingScourgeStart", 5)
    if kingScourgeStart then
        kingScourgeStart.OnClientEvent:Connect(function()
            if SkillCheckConfig.Mode == "Random" then SkillCheckState.RandomMode_IsNormal = true end
        end)
    end
end)

local ENUM_MOUSE = Enum.UserInputType.MouseButton1
local ENUM_TOUCH = Enum.UserInputType.Touch
local ENUM_MOVE = Enum.UserInputType.MouseMovement

local function create(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    return obj
end

local Moonwalk = {
    Enabled = false, GuiVisible = false, Gui = nil,
    IsActive = false, InputConn = nil,
}

local function StartMoonwalk()
    local character = LP.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoidRootPart or not humanoid then return end
    humanoid.AutoRotate = false
    Moonwalk.Enabled = true
end

local function StopMoonwalk()
    Moonwalk.Enabled = false
    local character = LP.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.AutoRotate = true end
end

local function UpdateMoonwalkGUI(isOn)
    if not Moonwalk.Gui then return end
    local frame = Moonwalk.Gui:FindFirstChild("Frame")
    if not frame then return end
    local actionButton = frame:FindFirstChild("ActionButton")
    if not actionButton then return end
    if isOn then
        actionButton.Text = "MOON [ON]"
        actionButton.TextColor3 = Library.Scheme.AccentColor
    else
        actionButton.Text = "MOON [OFF]"
        actionButton.TextColor3 = Library.Scheme.FontColor
    end
end

local function ToggleMoonwalkStatus()
    if Moonwalk.Enabled then StopMoonwalk() else StartMoonwalk() end
    Moonwalk.IsActive = Moonwalk.Enabled
    UpdateMoonwalkGUI(Moonwalk.Enabled)
end

local function CreateMoonwalkGUI()
    if Moonwalk.InputConn then Moonwalk.InputConn:Disconnect(); Moonwalk.InputConn = nil end
    if Moonwalk.Gui then Moonwalk.Gui:Destroy(); Moonwalk.Gui = nil end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MoonwalkCustomGui"; screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui; screenGui.Enabled = false
    Moonwalk.Gui = screenGui; Moonwalk.GuiVisible = false
    local frame = Instance.new("Frame", screenGui)
    frame.Name = "Frame"
    frame.Size = UDim2.fromOffset(110, 36)
    frame.Position = UDim2.fromScale(0.85, 0.45)
    frame.BackgroundColor3 = Library.Scheme.MainColor
    frame.BackgroundTransparency = 0
    frame.Active = true; frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(1, 0)
    local uiStroke = Instance.new("UIStroke", frame)
    uiStroke.Name = "UIStroke"
    uiStroke.Color = Library.Scheme.OutlineColor
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.LineJoinMode = Enum.LineJoinMode.Round
    applyGlowStroke(uiStroke, Library.Scheme.AccentColor, Library.Scheme.MainColor)
    local textButton = Instance.new("TextButton", frame)
    textButton.Name = "ActionButton"
    textButton.Size = UDim2.new(1, 0, 1, 0)
    textButton.Text = "MOON [OFF]"
    textButton.BackgroundTransparency = 1
    textButton.Font = Enum.Font.Code
    textButton.TextSize = 12
    textButton.TextColor3 = Library.Scheme.FontColor
    textButton.BorderSizePixel = 0
    textButton.AutoButtonColor = true
    Instance.new("UICorner", textButton).CornerRadius = UDim.new(1, 0)
    local isDown = false
    local isDragging = false
    local dragHoldDelay = false
    local startPos = nil
    local frameStartPos = nil
    local holdThread = nil
    local function onDrag(input)
        if not isDown or not dragHoldDelay or not startPos or not frameStartPos then return end
        local delta = input.Position - startPos
        if not isDragging and (math.abs(delta.X) > 18 or math.abs(delta.Y) > 18) then isDragging = true end
        if isDragging then
            frame.Position = UDim2.new(
                frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X,
                frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y
            )
        end
    end
    textButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            isDown = true; isDragging = false; dragHoldDelay = false
            startPos = input.Position; frameStartPos = frame.Position
            if holdThread then task.cancel(holdThread) end
            holdThread = task.delay(0.18, function() if isDown then dragHoldDelay = true end end)
        end
    end)
    textButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if holdThread then task.cancel(holdThread) end
            if isDown and not isDragging then ToggleMoonwalkStatus() end
            isDown = false; isDragging = false; dragHoldDelay = false
            startPos = nil; frameStartPos = nil
        end
    end)
    Moonwalk.InputConn = UserInputService.InputChanged:Connect(function(input)
        if isDown and dragHoldDelay
            and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            onDrag(input)
        end
    end)
end

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if Moonwalk.Enabled then StartMoonwalk() end
    if Moonwalk.GuiVisible and Moonwalk.Gui then
        Moonwalk.Gui.Enabled = true
        UpdateMoonwalkGUI(Moonwalk.Enabled)
    end
end)

local MoonwalkRenderConn = RS.RenderStepped:Connect(function(deltaTime)
    if not Moonwalk.Enabled then return end
    local character = LP.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local camera = workspace.CurrentCamera
    if not humanoidRootPart or not humanoid or not camera then return end
    if humanoid.AutoRotate ~= false then humanoid.AutoRotate = false end
    local lookRaw = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
    local rightRaw = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
    local look = lookRaw.Magnitude > 0.001 and lookRaw.Unit or Vector3.zero
    local right = rightRaw.Magnitude > 0.001 and rightRaw.Unit or Vector3.zero
    local sway = math.sin(tick() * 35)
    local faceDir = CFrame.Angles(0, math.rad(30 * sway), 0) * look
    humanoidRootPart.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + faceDir)
    humanoid:Move(-look * 1.2 + right * (sway * 1.05), false)
end)

task.spawn(function() task.wait(1.5); CreateMoonwalkGUI() end)

getgenv().MoonwalkAPI = {
    ShowGUI = function()
        if not Moonwalk.Gui then CreateMoonwalkGUI() end
        Moonwalk.Gui.Enabled = true; Moonwalk.GuiVisible = true
        UpdateMoonwalkGUI(Moonwalk.Enabled)
    end,
    HideGUI = function()
        if Moonwalk.Gui then Moonwalk.Gui.Enabled = false; Moonwalk.GuiVisible = false end
    end,
    Toggle = function() ToggleMoonwalkStatus() end,
    Enable = function() StartMoonwalk(); UpdateMoonwalkGUI(true) end,
    Disable = function() StopMoonwalk(); UpdateMoonwalkGUI(false) end,
}

local AutoDodgeCrouch = false
local DodgeThread = nil
local currentAbyssalAnimationTrack = nil

local function isAbyssalwalkerSkillActive()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return false end
    for _, playerObj in ipairs(Players:GetPlayers()) do
        if playerObj.Team and playerObj.Team.Name == "Killer" and playerObj.Character then
            local killerHRP = playerObj.Character:FindFirstChild("HumanoidRootPart")
            if not killerHRP then continue end
            local distance = (myHRP.Position - killerHRP.Position).Magnitude
            if distance > 25 then continue end
            local humanoid = playerObj.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local animator = humanoid:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        if track.Animation and track.Animation.AnimationId == "rbxassetid://80411309607666" then
                            local timeLeft = track.Length - track.TimePosition
                            if timeLeft <= 1.5 then currentAbyssalAnimationTrack = nil; return false end
                            currentAbyssalAnimationTrack = track; return true
                        end
                    end
                end
            end
        end
    end
    currentAbyssalAnimationTrack = nil
    return false
end

local function getCrouchBtn()
    local b = LP:FindFirstChild("PlayerGui")
    for segment in string.gmatch("Survivor-mob.Controls.crouch.icon", "[^%.]+") do
        if b then b = b:FindFirstChild(segment) end
    end
    if b and b:IsA("GuiObject") and b.Visible and b.Parent and b.Parent:IsA("GuiButton") then return b.Parent end
    return nil
end

local function fireCrouch(state)
    if isMobile then
        local btn = getCrouchBtn()
        if btn then pcall(function() firesignal(btn.MouseButton1Click) end) end
    else
        if state then VIM:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        else VIM:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game) end
    end
end

local function StartAutoDodgeCrouch()
    if DodgeThread then return end
    DodgeThread = task.spawn(function()
        local isCrouching = false
        while AutoDodgeCrouch do
            local skillActive = isAbyssalwalkerSkillActive()
            if skillActive and not isCrouching then isCrouching = true; fireCrouch(true)
            elseif not skillActive and isCrouching then isCrouching = false; fireCrouch(false) end
            task.wait(0.05)
        end
        if isCrouching then fireCrouch(false) end
    end)
end

local function StopAutoDodgeCrouch()
    if DodgeThread then task.cancel(DodgeThread); DodgeThread = nil end
end

local NotifGui = nil
local NotifStack = {}
local NOTIF_WIDTH = 207
local NOTIF_HEIGHT = 47
local NOTIF_GAP = 6
local NOTIF_TOP_OFFSET = 60
local NOTIF_RIGHT_OFFSET = 15
local NOTIF_LOGO_SIZE = 31

local function GetNotifGui()
    if NotifGui and NotifGui.Parent then return NotifGui end
    local sg = CoreGui:FindFirstChild("NIEELS_NotifyGui")
    if not sg then
        sg = Instance.new("ScreenGui")
        sg.Name = "NIEELS_NotifyGui"; sg.ResetOnSpawn = false; sg.IgnoreGuiInset = true
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        local ok = pcall(function() sg.Parent = CoreGui end)
        if not ok then sg.Parent = LP:WaitForChild("PlayerGui") end
    end
    NotifGui = sg
    return sg
end

local function RepositionNotifs()
    local y = NOTIF_TOP_OFFSET
    for i, frame in ipairs(NotifStack) do
        if frame and frame.Parent then
            frame.Position = UDim2.new(1, -(NOTIF_WIDTH + NOTIF_RIGHT_OFFSET), 0, y)
            y = y + NOTIF_HEIGHT + NOTIF_GAP
        end
    end
end

local function NIEELS_Notify(title, text, duration)
    duration = duration or 2
    pcall(function()
        local sg = GetNotifGui()
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, NOTIF_WIDTH, 0, NOTIF_HEIGHT)
        frame.Position = UDim2.new(1, -(NOTIF_WIDTH + NOTIF_RIGHT_OFFSET), 0, NOTIF_TOP_OFFSET)
        frame.BackgroundColor3 = Color3.fromRGB(25, 20, 35); frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0; frame.Parent = sg
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Library.Scheme.AccentColor; stroke.Thickness = 1.0; stroke.Transparency = 1
        applyGlowStroke(stroke, Library.Scheme.AccentColor, Library.Scheme.BackgroundColor)
        local logo = Instance.new("ImageLabel", frame)
        logo.Size = UDim2.new(0, NOTIF_LOGO_SIZE, 0, NOTIF_LOGO_SIZE)
        logo.Position = UDim2.new(0, 9, 0.5, -(NOTIF_LOGO_SIZE / 2))
        logo.BackgroundTransparency = 1; logo.Image = IMG_LOGO_NIEELS
        logo.ImageColor3 = Library.Scheme.FontColor; logo.ScaleType = Enum.ScaleType.Fit
        logo.ZIndex = 2; logo.ImageTransparency = 1
        local t = Instance.new("TextLabel", frame)
        t.Size = UDim2.new(1, -(NOTIF_LOGO_SIZE + 18), 0, 18)
        t.Position = UDim2.new(0, NOTIF_LOGO_SIZE + 13, 0, 4)
        t.BackgroundTransparency = 1; t.Text = title
        t.TextColor3 = Library.Scheme.AccentColor; t.Font = Enum.Font.Code; t.TextSize = 12
        t.TextXAlignment = Enum.TextXAlignment.Left; t.TextTransparency = 1; t.ZIndex = 2
        local b = Instance.new("TextLabel", frame)
        b.Size = UDim2.new(1, -(NOTIF_LOGO_SIZE + 18), 0, 18)
        b.Position = UDim2.new(0, NOTIF_LOGO_SIZE + 13, 0, 22)
        b.BackgroundTransparency = 1; b.Text = text
        b.TextColor3 = Library.Scheme.FontColor; b.Font = Enum.Font.Code; b.TextSize = 11
        b.TextXAlignment = Enum.TextXAlignment.Left; b.TextTransparency = 1; b.ZIndex = 2
        table.insert(NotifStack, 1, frame)
        RepositionNotifs()
        local info = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(frame, info, { BackgroundTransparency = 0 }):Play()
        TweenService:Create(stroke, info, { Transparency = 0 }):Play()
        TweenService:Create(logo, info, { ImageTransparency = 0 }):Play()
        TweenService:Create(t, info, { TextTransparency = 0 }):Play()
        TweenService:Create(b, info, { TextTransparency = 0 }):Play()
        task.delay(duration, function()
            if frame and frame.Parent then
                local out = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                TweenService:Create(frame, out, { BackgroundTransparency = 1 }):Play()
                TweenService:Create(stroke, out, { Transparency = 1 }):Play()
                TweenService:Create(logo, out, { ImageTransparency = 1 }):Play()
                TweenService:Create(t, out, { TextTransparency = 1 }):Play()
                TweenService:Create(b, out, { TextTransparency = 1 }):Play()
                task.wait(0.28)
                for i, f in ipairs(NotifStack) do
                    if f == frame then table.remove(NotifStack, i); break end
                end
                if frame and frame.Parent then frame:Destroy() end
                RepositionNotifs()
            end
        end)
    end)
end

local LowGraphicConfig = { Enabled = false, Loop = nil, Conns = {} }

local function killEffects(container)
    for _, fx in ipairs(container:GetChildren()) do
        pcall(function()
            if fx:IsA("BloomEffect") or fx:IsA("BlurEffect") or fx:IsA("SunRaysEffect")
            or fx:IsA("DepthOfFieldEffect") or fx:IsA("ColorCorrectionEffect") or fx:IsA("Clouds") then
                fx.Enabled = false
            elseif fx:IsA("Atmosphere") then fx.Density = 0; fx.Haze = 0; fx.Glare = 0 end
        end)
    end
end

local function applyPotato()
    if not LowGraphicConfig.Enabled then return end
    pcall(function() if setfpscap then setfpscap(999) end end)
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function() settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01 end)
    pcall(function() UserSettings():GetService("UserGameSettings").SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1 end)
    Lighting.GlobalShadows = false
    pcall(function() Lighting.ShadowSoftness = 0 end)
    Lighting.FogEnd = 1e6; Lighting.FogStart = 1e6
    killEffects(Lighting)
    pcall(function()
        local t = Workspace:FindFirstChildOfClass("Terrain")
        if t then
            t.Decoration = false; t.WaterWaveSize = 0; t.WaterWaveSpeed = 0
            t.WaterReflectance = 0; t.WaterTransparency = 1
        end
    end)
    pcall(function() LP:SetAttribute("lowGraphics", true) end)
end

local function EnableLowGraphic()
    if LowGraphicConfig.Enabled then return end
    LowGraphicConfig.Enabled = true
    applyPotato()
    table.insert(LowGraphicConfig.Conns, Lighting.ChildAdded:Connect(function(child)
        if not LowGraphicConfig.Enabled then return end
        task.defer(function()
            if child:IsA("BloomEffect") or child:IsA("BlurEffect") or child:IsA("SunRaysEffect")
            or child:IsA("DepthOfFieldEffect") or child:IsA("ColorCorrectionEffect") or child:IsA("Clouds") then
                child.Enabled = false
            elseif child:IsA("Atmosphere") then child.Density = 0; child.Haze = 0; child.Glare = 0 end
        end)
    end))
    table.insert(LowGraphicConfig.Conns, Workspace.DescendantAdded:Connect(function(obj)
        if not LowGraphicConfig.Enabled then return end
        if obj:IsA("BasePart") and obj.CastShadow then
            local map = Workspace:FindFirstChild("Map")
            if map and obj:IsDescendantOf(map) then obj.CastShadow = false end
        end
    end))
    table.insert(LowGraphicConfig.Conns, LP.CharacterAdded:Connect(function()
        task.wait(1); if LowGraphicConfig.Enabled then applyPotato() end
    end))
end

local function DisableLowGraphic()
    LowGraphicConfig.Enabled = false
    if LowGraphicConfig.Loop then pcall(function() task.cancel(LowGraphicConfig.Loop) end); LowGraphicConfig.Loop = nil end
    for _, conn in ipairs(LowGraphicConfig.Conns) do pcall(function() conn:Disconnect() end) end
    LowGraphicConfig.Conns = {}
end

local tbl6 = { [25]=true,[17]=true,[30]=true,[67.8]=true,[2]=true,[4]=true,[0.25]=true,[70]=true,[0.65]=true }
local tbl7 = {[1]=true,[10]=true}
local var53
local killerNoCDFlag = false
local var54, _activeKillerT = nil, 0

local function fn6()
    local now = tick()
    if now - _activeKillerT < 2 and var54 ~= nil then return var54 end
    local var55 = nil
    pcall(function()
        local var56 = LP:GetAttribute("SelectedKiller")
        local name = tostring(var56 or ""):lower()
        if name:find("hidden") then var55 = "hidden"
        elseif name:find("mayers") or name:find("stalker") or name:find("michael") then var55 = "mayers" end
        if not var55 then
            local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
            local var57 = ReplicatedStorage2:FindFirstChild("Remotes") and ReplicatedStorage2.Remotes:FindFirstChild("Killers")
            if var57 then
                if var57:FindFirstChild("Stalker") then var55 = "mayers"
                elseif var57:FindFirstChild("Hidden") then var55 = "hidden" end
            end
        end
    end)
    var54, _activeKillerT = var55, now
    return var55
end

local function fn7()
    if var53 then return end
    if not hookfunction then NIEELS_Notify("No Cooldown", "Executor tidak support hookfunction", 2.0); return end
    local var59, err = pcall(function()
        local var58 = newcclosure or function(arg4) return arg4 end
        var53 = hookfunction(task.delay, var58(function(delayTime, callback)
            if not var53 then return task.delay and task.delay(0, callback) or task.spawn(callback) end
            if not killerNoCDFlag then return var53(delayTime, callback) end
            if tbl6[delayTime] then return var53(0, callback) end
            if tbl7[delayTime] and fn6() == "mayers" then return var53(0, callback) end
            return var53(delayTime, callback)
        end))
    end)
    if not var59 then NIEELS_Notify("No Cooldown", "Gagal hook task.delay: " .. tostring(err), 2.0); var53 = nil end
end

local function fn8()
    if var53 then
        if restorefunction then pcall(restorefunction, task.delay) end
        var53 = nil
    end
end

local GetNearestSurvivorForMayers, StartMayersMobileHook, StopMayersMobileHook
do
    local tbl2_list19 = {}
    local tbl2_list20 = {}
    local tbl2_connection27, tbl2_connection28
    local tbl2_flag160 = false
    local tbl2_flag162 = false

    function GetNearestSurvivorForMayers(maxDist)
        maxDist = maxDist or 5
        local char = LP.Character
        local var65 = char and char:FindFirstChild("HumanoidRootPart")
        if not var65 then return nil, math.huge end
        local var66, var67 = nil, maxDist + 0.01
        for _, v in ipairs(Players:GetPlayers()) do
            if v ~= LP and v.Character then
                local humanoidRootPart = v.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = v.Character:FindFirstChildOfClass("Humanoid")
                if humanoidRootPart and humanoid and humanoid.Health > 0 then
                    local magnitude = (humanoidRootPart.Position - var65.Position).Magnitude
                    if magnitude < var67 then var66, var67 = v.Character, magnitude end
                end
            end
        end
        return var66, var67
    end

    local function var64()
        if not (tbl2_flag160 or killerNoCDFlag) then return end
        if fn6() ~= "mayers" then return end
        if tbl2_flag162 then return end
        local char = LP.Character
        if not char then return end
        local humanoidRootPart2 = char:FindFirstChild("HumanoidRootPart")
        local humanoid2 = char:FindFirstChildOfClass("Humanoid")
        if not (humanoidRootPart2 and humanoid2 and humanoid2.Health > 0) then return end
        tbl2_flag162 = true
        task.delay(0.35, function() tbl2_flag162 = false end)
        local var68 = nil
        pcall(function()
            local animation = Instance.new("Animation")
            animation.AnimationId = "rbxassetid://77477445889320"
            local var69 = humanoid2:FindFirstChildOfClass("Animator") or humanoid2
            var68 = var69:LoadAnimation(animation)
            var68.Priority = Enum.AnimationPriority.Action
            var68:Play()
        end)
        local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
        pcall(function() ReplicatedStorage3.Remotes.SoundPlayer:FireServer("132736711620405", humanoidRootPart2, 0.3, 70) end)
        pcall(function() ReplicatedStorage3.Remotes.Attacks.BasicAttack:FireServer(true) end)
        pcall(function()
            local var70 = ReplicatedStorage3:FindFirstChild("Remotes") and ReplicatedStorage3.Remotes:FindFirstChild("Killers") and ReplicatedStorage3.Remotes.Killers:FindFirstChild("Stalker") and ReplicatedStorage3.Remotes.Killers.Stalker:FindFirstChild("ConsumeReady")
            if var70 then var70:FireServer() end
        end)
        task.spawn(function()
            local now2 = tick()
            local flag2 = false
            while tick() - now2 < 2 and not flag2 do
                RunService.Heartbeat:Wait()
                local target, dist = GetNearestSurvivorForMayers(5)
                if target and dist <= 5 then
                    pcall(function()
                        local grab = ReplicatedStorage3.Remotes.Killers.Stalker:FindFirstChild("grab")
                        if grab then grab:FireServer(target) end
                    end)
                    if var68 then pcall(function() var68:Stop(0.1) end) end
                    flag2 = true; break
                end
            end
            if var68 then pcall(function() var68:Stop(0.1) end) end
        end)
    end

    local function fn11(arg6)
        if not (arg6 and arg6:IsA("GuiButton")) then return false end
        if arg6.Name ~= "move2" then return false end
        local parent = arg6.Parent
        if not (parent and parent.Name == "Controls") then return false end
        local parent2 = parent.Parent
        if not (parent2 and parent2.Name == "Slasher-mob") then return false end
        return true
    end

    local function fn12(arg7)
        if not tbl2_flag160 then return end
        if fn6() ~= "mayers" then return end
        if not fn11(arg7) then return end
        if tbl2_list20[arg7] then return end
        tbl2_list20[arg7] = true
        pcall(function() arg7.Active = true end)
        local connection = arg7.Activated:Connect(function()
            if not tbl2_flag160 then return end
            pcall(var64)
        end)
        table.insert(tbl2_list19, connection)
    end

    local function fn13()
        if not tbl2_flag160 then return end
        if fn6() ~= "mayers" then return end
        local var74 = LP:FindFirstChildOfClass("PlayerGui") or playerGui
        if not var74 then return end
        pcall(function()
            local slasherMob = var74:FindFirstChild("Slasher-mob")
            if slasherMob then
                local controls = slasherMob:FindFirstChild("Controls")
                if controls then
                    local move2 = controls:FindFirstChild("move2")
                    if move2 then fn12(move2) end
                    for _, v3 in ipairs(controls:GetDescendants()) do
                        if v3.Name == "move2" then fn12(v3) end
                    end
                end
            end
        end)
        if tbl2_connection28 then pcall(function() tbl2_connection28:Disconnect() end) end
        tbl2_connection28 = var74.ChildAdded:Connect(function(arg8)
            if arg8.Name == "Slasher-mob" then
                task.wait(0.5); fn13()
                if tbl2_connection27 then pcall(function() tbl2_connection27:Disconnect() end) end
                tbl2_connection27 = arg8.DescendantAdded:Connect(function(arg9)
                    if arg9.Name == "move2" then fn12(arg9) end
                end)
                table.insert(tbl2_list19, tbl2_connection27)
            end
        end)
        table.insert(tbl2_list19, tbl2_connection28)
    end

    function StartMayersMobileHook() tbl2_flag160 = true; fn13() end
    function StopMayersMobileHook()
        tbl2_flag160 = false
        for _, v4 in ipairs(tbl2_list19) do pcall(function() v4:Disconnect() end) end
        tbl2_list19 = {}; tbl2_list20 = {}
        if tbl2_connection28 then pcall(function() tbl2_connection28:Disconnect() end) tbl2_connection28 = nil end
        if tbl2_connection27 then pcall(function() tbl2_connection27:Disconnect() end) tbl2_connection27 = nil end
    end
end

local UnlimitedVaultConn = nil; local AntiSlowVaultConn = nil; local AntiSlowVaultHooked = false
local ConfigAntiSlow = { Enabled = false }; local VaultSystemEnabled = false

function EnableUnlimitedVault()
    if UnlimitedVaultConn then UnlimitedVaultConn:Disconnect() end
    for _, v in ipairs(CollectionService:GetTagged("Blocked")) do CollectionService:RemoveTag(v, "Blocked") end
    UnlimitedVaultConn = CollectionService:GetInstanceAddedSignal("Blocked"):Connect(function(instance)
        if not VaultSystemEnabled then return end; CollectionService:RemoveTag(instance, "Blocked")
    end)
end

function DisableUnlimitedVault()
    if UnlimitedVaultConn then UnlimitedVaultConn:Disconnect(); UnlimitedVaultConn = nil end
end

function InstallAntiSlowHook()
    if AntiSlowVaultHooked then return true end
    local ok, result = pcall(function()
        local Modules = ReplicatedStorage:WaitForChild("Modules", 5); if not Modules then return nil end
        local Survivors = Modules:WaitForChild("Survivors", 5); if not Survivors then return nil end
        local Controller = Survivors:WaitForChild("SurvivorAnimationsController", 5); if not Controller then return nil end
        return require(Controller)
    end)
    if not ok or not result or type(result) ~= "table" then return false end
    local orig_isFacingStraightEnough = result._isFacingStraightEnough
    local orig_onVaultAnimation = result._onVaultAnimation
    result._isFacingStraightEnough = function(self, p1, p2, maxA)
        if ConfigAntiSlow.Enabled then self.characterspeed = 20; return true, 0 end
        if orig_isFacingStraightEnough then return orig_isFacingStraightEnough(self, p1, p2, maxA) end
        return true, 0
    end
    result._onVaultAnimation = function(self, vp, isS)
        if ConfigAntiSlow.Enabled then
            if orig_onVaultAnimation then return orig_onVaultAnimation(self, vp, true) end
            return
        end
        if orig_onVaultAnimation then return orig_onVaultAnimation(self, vp, isS) end
    end
    AntiSlowVaultHooked = true; return true
end

function EnableAntiSlowVault()
    ConfigAntiSlow.Enabled = true
    for _, v in ipairs(CollectionService:GetTagged("SlowVault")) do CollectionService:RemoveTag(v, "SlowVault") end
    if AntiSlowVaultConn then AntiSlowVaultConn:Disconnect() end
    AntiSlowVaultConn = CollectionService:GetInstanceAddedSignal("SlowVault"):Connect(function(instance)
        if not VaultSystemEnabled then return end; CollectionService:RemoveTag(instance, "SlowVault")
    end)
    task.spawn(function()
        if InstallAntiSlowHook() then return end
        local attempts, maxAttempts = 0, 10
        while VaultSystemEnabled and not AntiSlowVaultHooked and attempts < maxAttempts do
            attempts = attempts + 1; task.wait(1)
            if InstallAntiSlowHook() then break end
        end
    end)
end

function DisableAntiSlowVault()
    ConfigAntiSlow.Enabled = false
    if AntiSlowVaultConn then AntiSlowVaultConn:Disconnect(); AntiSlowVaultConn = nil end
end

LOCAL_PLAYER.CharacterAdded:Connect(function()
    task.wait(3); if VaultSystemEnabled then AntiSlowVaultHooked = false; InstallAntiSlowHook() end
end)

local SpeedBoost={_enabled=false,_loop=nil,_value=1.27,_char=nil,_hb=nil}
function SpeedBoost:SetValue(v)
    self._value=v
    if self._enabled then local c=LP.Character; if c then c:SetAttribute("speedboost",v) end end
end
function SpeedBoost:IsEnabled() return self._enabled end
function SpeedBoost:Start()
    if self._loop then pcall(function() task.cancel(self._loop) end); self._loop=nil end
    self._char=LP.Character or LP.CharacterAdded:Wait()
    self._enabled=true
    self._loop=task.spawn(function()
        while self._enabled do
            local c=self._char
            if c and c.Parent then c:SetAttribute("speedboost",self._value) end
            task.wait(0.1)
        end
    end)
end
function SpeedBoost:Stop()
    self._enabled=false
    if self._loop then pcall(function() task.cancel(self._loop) end); self._loop=nil end
    if self._hb then self._hb:Disconnect(); self._hb=nil end
    local c=LP.Character
    if c then c:SetAttribute("speedboost",1.0) end
end
function SpeedBoost:Toggle(s)
    if s==nil then s=not self._enabled end
    if s then self:Start() else self:Stop() end
    return self._enabled
end
function SpeedBoost:OnRespawn(c)
    self._char=c
    if self._enabled then task.wait(0.5); if self._char and self._char.Parent then self._char:SetAttribute("speedboost",self._value) end end
end
SpeedBoost:SetValue(1.27)
LP.CharacterAdded:Connect(function(c) SpeedBoost:OnRespawn(c) end)

local ESP={_enabled=false,_loop=nil,_survivorColor=Color3.fromRGB(255,255,255),_killerColor=Color3.fromRGB(255,0,0),_tag="PlayerESP",_txtTag="PlayerESP_Txt",_cache={}}
local function IsKiller(p)
    if not p.Character then return false end
    return p.Character:FindFirstChild(KILLER_MARKER,true)~=nil
end
local function ShouldESP(p) return p~=LP and p.Character~=nil end
local function MakeESP(o,p)
    if not o then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local targetRoot = o:FindFirstChild("HumanoidRootPart")
    local dist = (root and targetRoot) and (root.Position - targetRoot.Position).Magnitude or 9999
    if dist > 250 then
        local ex=o:FindFirstChild(ESP._tag); local ext=o:FindFirstChild(ESP._txtTag)
        if ex then ex:Destroy() end; if ext then ext:Destroy() end
        return
    end
    local isDown = false
    local hum = o:FindFirstChildOfClass("Humanoid")
    if hum then
        isDown = hum.Health <= 0 or hum.Health < 2 or o:GetAttribute("Downed") == true
            or o:GetAttribute("IsDown") == true or o:GetAttribute("Knocked") == true
    end
    local col = IsKiller(p) and ESP._killerColor or ESP._survivorColor
    if isDown then col = Color3.fromRGB(255, 0, 0) end
    local displayText = p.Name
    if isDown then displayText = "🔻 DOWN\n" .. p.Name end
    displayText = displayText .. string.format("\n[%.0fm]", dist)
    local ex=o:FindFirstChild(ESP._tag); local ext=o:FindFirstChild(ESP._txtTag)
    if ex then
        ex.OutlineColor=col
        if ext then
            local txt=ext:FindFirstChildOfClass("TextLabel")
            if txt then txt.TextColor3=col; txt.Text=displayText end
        end
        return
    end
    local hl=Instance.new("Highlight",o)
    hl.Name=ESP._tag; hl.FillTransparency=1; hl.OutlineColor=col; hl.OutlineTransparency=0
    local bb=Instance.new("BillboardGui",o)
    bb.Name=ESP._txtTag; bb.Size=UDim2.new(0,140,0,60); bb.AlwaysOnTop=true; bb.StudsOffset=Vector3.new(0,4.2,0)
    local t=Instance.new("TextLabel",bb)
    t.Name="NameLabel"; t.Size=UDim2.new(1,0,1,0); t.BackgroundTransparency=1; t.Text=displayText; t.TextColor3=col
    t.Font=Enum.Font.Code; t.TextSize=10; t.TextStrokeTransparency=0.3
    table.insert(ESP._cache, hl); table.insert(ESP._cache, bb)
end

local function ClearESP()
    for _, v in ipairs(ESP._cache) do if v and v.Parent then v:Destroy() end end
    table.clear(ESP._cache)
end

function ESP:Start()
    if self._loop then self._loop:Disconnect(); self._loop=nil end
    local lastUpdate = 0
    self._loop=RS.Heartbeat:Connect(function()
        if not self._enabled then return end
        local now = tick()
        if now - lastUpdate < 0.2 then return end
        lastUpdate = now
        for _,p in pairs(Players:GetPlayers()) do if ShouldESP(p) then MakeESP(p.Character,p) end end
    end)
    self._enabled=true
end
function ESP:Stop()
    if self._loop then self._loop:Disconnect(); self._loop=nil end
    ClearESP(); self._enabled=false
end
function ESP:Toggle(s)
    if s==nil then s=not self._enabled end
    if s then self:Start() else self:Stop() end
    return self._enabled
end

local GeneratorESPConfig = { Enabled = false, BaseColor = Color3.fromRGB(255, 170, 0), DoneColor = Color3.fromRGB(0, 255, 120) }
local CachedGenerators = {}

local function GetGameValue(obj, name)
    if not obj then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    local child = obj:FindFirstChild(name)
    if child then
        local success, val = pcall(function() return child.Value end)
        if success then return val end
    end
    return nil
end

local function ApplyGenHighlight(object, color)
    local h = object:FindFirstChild("GenHighlight") or Instance.new("Highlight")
    h.Name = "GenHighlight"; h.Adornee = object; h.FillColor = color; h.OutlineColor = color
    h.FillTransparency = 0.9; h.OutlineTransparency = 0; h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
end

local function CreateBillboard(text, color)
    local bb = Instance.new("BillboardGui")
    bb.Name = "GenESP"; bb.Size = UDim2.new(0, 100, 0, 30); bb.AlwaysOnTop = true
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1; l.Text = text; l.TextColor3 = color
    l.TextStrokeTransparency = 0; l.Font = Enum.Font.Code; l.TextSize = 13; l.Parent = bb
    return bb
end

local function UpdateGenerator(generator)
    if not generator or not generator.Parent then return end
    if not GeneratorESPConfig.Enabled then
        local ob = generator:FindFirstChild("GenESP"); if ob then ob:Destroy() end
        local oh = generator:FindFirstChild("GenHighlight"); if oh then oh:Destroy() end
        return
    end
    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local dist = 9999
    if myRoot then
        if generator:IsA("Model") then
            local cf, _ = generator:GetBoundingBox()
            dist = (myRoot.Position - cf.Position).Magnitude
        elseif generator:IsA("BasePart") then
            dist = (myRoot.Position - generator.Position).Magnitude
        end
    end
    if dist > 250 then
        local ob = generator:FindFirstChild("GenESP"); if ob then ob:Destroy() end
        local oh = generator:FindFirstChild("GenHighlight"); if oh then oh:Destroy() end
        return
    end
    local percent = GetGameValue(generator, "RepairProgress") or GetGameValue(generator, "Progress") or 0
    local billboard = generator:FindFirstChild("GenESP")
    local highlight = generator:FindFirstChild("GenHighlight")
    if percent >= 100 then
        if billboard then billboard:Destroy() end
        if highlight then highlight:Destroy() end
        return
    end
    local cp = math.clamp(percent, 0, 100)
    local cc = GeneratorESPConfig.BaseColor:Lerp(GeneratorESPConfig.DoneColor, cp / 100)
    local text = string.format("Gen %.0f%%", percent)
    if not billboard then
        billboard = CreateBillboard(text, cc); billboard.Adornee = generator; billboard.Parent = generator
    else
        local lbl = billboard:FindFirstChildOfClass("TextLabel")
        if lbl then lbl.Text = text; lbl.TextColor3 = cc end
    end
    ApplyGenHighlight(generator, cc)
end

local function cacheObject(obj) if obj.Name == "Generator" then CachedGenerators[obj] = true end end
local function removeCache(obj) if CachedGenerators[obj] then CachedGenerators[obj] = nil end end
for _, obj in ipairs(WS:GetDescendants()) do cacheObject(obj) end
WS.DescendantAdded:Connect(cacheObject)
WS.DescendantRemoving:Connect(removeCache)

local genEspLastUpdate = 0
local GEN_ESP_INTERVAL = 0.5
RS.Heartbeat:Connect(function()
    local now = tick()
    if now - genEspLastUpdate < GEN_ESP_INTERVAL then return end
    genEspLastUpdate = now
    if GeneratorESPConfig.Enabled then
        for gen in pairs(CachedGenerators) do UpdateGenerator(gen) end
    end
end)

local AutoStalk = { Enabled = false, StalkRange = 150 }
local StalkerConnection = nil

local function getRoot() return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") end

local function getClosestSurvivorForStalk()
    local root = getRoot(); if not root then return nil end
    local closest, shortest = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 30 then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist <= AutoStalk.StalkRange and dist < shortest then shortest = dist; closest = plr end
            end
        end
    end
    return closest
end

local function startAutoStalk()
    if StalkerConnection then return end
    StalkerConnection = RS.Heartbeat:Connect(function()
        if not AutoStalk.Enabled then return end
        local target = getClosestSurvivorForStalk()
        if not target or not target.Character then return end
        local se = ReplicatedStorage:FindFirstChild("Remotes", true)
            and ReplicatedStorage.Remotes:FindFirstChild("Killers", true)
            and ReplicatedStorage.Remotes.Killers:FindFirstChild("Stalker", true)
            and ReplicatedStorage.Remotes.Killers.Stalker:FindFirstChild("StartStalking")
        if se then pcall(function() se:FireServer(target) end) end
    end)
end

local function stopAutoStalk()
    AutoStalk.Enabled = false
    if StalkerConnection then StalkerConnection:Disconnect(); StalkerConnection = nil end
end

local StalkerGUI = nil
local StalkerButton = nil

local function GetNearest()
    local c = LP.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return nil end
    local h = c.HumanoidRootPart
    local n, nd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (h.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < nd then nd = d; n = p end
        end
    end
    return n
end

local function CreateStalker()
    if StalkerGUI then StalkerGUI:Destroy() end
    StalkerGUI = Instance.new("ScreenGui"); StalkerGUI.Name = "rizssky_StalkerGUI"
    StalkerGUI.ResetOnSpawn = false; StalkerGUI.IgnoreGuiInset = true
    local ok = pcall(function() StalkerGUI.Parent = CoreGui end)
    if not ok then StalkerGUI.Parent = LP:WaitForChild("PlayerGui") end
    StalkerButton = Instance.new("ImageButton"); StalkerButton.Name = "StalkerGrabButton"
    StalkerButton.Size = UDim2.new(0, 45, 0, 45); StalkerButton.Position = UDim2.new(0.68, 0, 0.88, 0)
    StalkerButton.AnchorPoint = Vector2.new(0.5, 0.5); StalkerButton.BackgroundColor3 = Library.Scheme.MainColor
    StalkerButton.BackgroundTransparency = 0; StalkerButton.AutoButtonColor = true
    StalkerButton.ZIndex = 10; StalkerButton.Parent = StalkerGUI
    Instance.new("UICorner", StalkerButton).CornerRadius = UDim.new(1, 0)
    local s = Instance.new("UIStroke", StalkerButton)
    s.Color = Library.Scheme.OutlineColor; s.Thickness = 1; s.Transparency = 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.LineJoinMode = Enum.LineJoinMode.Round
    applyGlowStroke(s, Color3.fromRGB(180, 45, 45), Library.Scheme.MainColor)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1; l.Text = "GRAB"
    l.TextColor3 = Library.Scheme.FontColor; l.TextScaled = true
    l.Font = Enum.Font.Code; l.ZIndex = 11; l.Parent = StalkerButton
    local GR = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Killers")
        and ReplicatedStorage.Remotes.Killers:FindFirstChild("Stalker") and ReplicatedStorage.Remotes.Killers.Stalker:FindFirstChild("grab")
    StalkerButton.MouseButton1Click:Connect(function()
        local p = GetNearest()
        if not p then NIEELS_Notify("Stalker Grab", "No player nearby!", 2.0); return end
        if not GR then NIEELS_Notify("Stalker Grab", "Error: Remote not found", 2.0); return end
        pcall(function() GR:FireServer(p.Character) end)
        NIEELS_Notify("Stalker Grab", "Grabbed: " .. p.Name, 2.0)
    end)
end

local function ToggleStalker()
    if StalkerGUI and StalkerGUI.Parent then StalkerGUI:Destroy(); StalkerGUI = nil
    else CreateStalker() end
end

local var973, StopHiddenM2Hook
do
    local num96 = 50
    local num97 = 1.5
    local tbl2 = { flag159 = false, num161 = 0, num160 = 1.0, connection26 = nil }

    local function fn9_local(player)
        local ok, team = pcall(function() return player.Team end)
        if not ok or not team then return "survivor" end
        return team.Name:lower():find("killer") and "killer" or "survivor"
    end

    local function fn267(character)
        if not character then return false end
        local humanoid21 = character:FindFirstChildOfClass("Humanoid")
        if not humanoid21 or humanoid21.Health <= 0 then return false end
        if character:GetAttribute("Knocked") then return false end
        if character:GetAttribute("IsHooked") then return false end
        if character:GetAttribute("IsCarried") then return false end
        return true
    end

    local function fn268()
        local character45 = LP.Character
        local var974 = character45 and character45:FindFirstChild("HumanoidRootPart")
        if not var974 then return nil end
        local var975, huge9 = nil, math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LP and player.Character and fn267(player.Character) then
                if fn9_local(player) ~= "killer" then
                    local part = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Head")
                    if part and part:IsA("BasePart") then
                        local dist = (var974.Position - part.Position).Magnitude
                        if dist <= num96 and dist < huge9 then huge9 = dist; var975 = part end
                    end
                end
            end
        end
        return var975
    end

    local function onEvent()
        if not tbl2.flag159 then return end
        local var976, isKiller = pcall(function() return fn9_local(LP) == "killer" end)
        if not var976 or not isKiller then return end
        tbl2.num161 = tick() + num97
    end

    function var973()
        if tbl2.connection26 then return end
        pcall(function()
            local remotes12 = ReplicatedStorage:FindFirstChild("Remotes")
            local killers = remotes12 and remotes12:FindFirstChild("Killers")
            local var977 = killers and killers:FindFirstChild("Hidden")
            local var978 = var977 and var977:FindFirstChild("preparem2")
            if var978 and var978:IsA("BindableEvent") then tbl2.connection26 = var978.Event:Connect(onEvent)
            elseif var978 and var978:IsA("RemoteEvent") then tbl2.connection26 = var978.OnClientEvent:Connect(onEvent)
            else NIEELS_Notify("AIMLOCK M2", "preparem2 tidak ditemukan", 2) end
        end)
    end

    function StopHiddenM2Hook()
        if tbl2.connection26 then pcall(function() tbl2.connection26:Disconnect() end); tbl2.connection26 = nil end
        tbl2.num161 = 0
    end

    RS.RenderStepped:Connect(function()
        if not tbl2.flag159 then return end
        if tick() > tbl2.num161 then return end
        local var979, isKiller = pcall(function() return fn9_local(LP) == "killer" end)
        if not var979 or not isKiller then return end
        local currentCamera20 = workspace.CurrentCamera
        if not currentCamera20 then return end
        local var980 = fn268()
        if not var980 then return end
        local position21 = var980.Position
        local smooth = math.clamp(tonumber(tbl2.num160) or 1, 0.05, 1)
        pcall(function()
            currentCamera20.CFrame = currentCamera20.CFrame:Lerp(CFrame.new(currentCamera20.CFrame.Position, position21), smooth)
        end)
        pcall(function()
            local char = LP.Character
            local var981 = char and char:FindFirstChild("HumanoidRootPart")
            if var981 then var981.CFrame = CFrame.new(var981.Position, Vector3.new(position21.X, var981.Position.Y, position21.Z)) end
        end)
    end)

    _G.NIEELSAimlockHiddenSet = function(enabled) tbl2.flag159 = enabled and true or false end
    _G.NIEELSAimlockHiddenSetSmooth = function(val) tbl2.num160 = math.clamp(tonumber(val) or 1, 0.05, 1) end
end

task.spawn(function()
    while _G.NIEELS.ScriptAlive do
        if _G.NIEELS.SkipEndscreen then
            pcall(function()
                local map = workspace:FindFirstChild("Map")
                if map then
                    local es = map:FindFirstChild("endscreen", true)
                    if es then
                        for _, d in ipairs(es:GetDescendants()) do
                            if d:IsA("LocalScript") then d.Disabled = true end
                        end
                        es:Destroy()
                    end
                end
                local res = PlayerGui:FindFirstChild("Results")
                if res then
                    local fr = res:FindFirstChild("Frame")
                    if fr then
                        local cl = fr:FindFirstChild("Close")
                        if cl and fr.Visible and cl.Visible then
                            pcall(function()
                                if typeof(firesignal) == "function" then firesignal(cl.MouseButton1Click) end
                            end)
                        end
                    end
                end
            end)
        end
        task.wait(1)
    end
end)

local guiName="NIEELSFreemium_V2_Tabbed"
if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy()
elseif LP.PlayerGui:FindFirstChild(guiName) then LP.PlayerGui[guiName]:Destroy() end
local SG2=Instance.new("ScreenGui")
SG2.Name=guiName; SG2.ResetOnSpawn=false
local ok=pcall(function() SG2.Parent=CoreGui end)
if not ok then SG2.Parent=LP:WaitForChild("PlayerGui") end

local MF=Instance.new("Frame")
MF.Size=UDim2.new(0,365,0,265); MF.Position=UDim2.new(0.5,-174,0.5,-129)
MF.BackgroundColor3=Library.Scheme.BackgroundColor; MF.BorderSizePixel=0; MF.Active=true; MF.Parent=SG2

local BGImage = Instance.new("ImageLabel")
BGImage.Name = "BackgroundLogo"
BGImage.Size = UDim2.new(1, -16, 1, -84)
BGImage.Position = UDim2.new(0, 8, 0, 76)
BGImage.BackgroundTransparency = 1
BGImage.Image = IMG_LOGO_NIEELS
BGImage.ImageColor3 = Color3.fromRGB(55, 110, 170)
BGImage.ImageTransparency = 0.55
BGImage.ScaleType = Enum.ScaleType.Fit
BGImage.ZIndex = 1
BGImage.Parent = MF
Instance.new("UICorner", BGImage).CornerRadius = UDim.new(0, 6)

local MFC=Instance.new("UICorner",MF); MFC.CornerRadius=UDim.new(0,8)
local MS=Instance.new("UIStroke",MF); MS.Thickness=1; MS.Color=Library.Scheme.OutlineColor
MS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; MS.LineJoinMode=Enum.LineJoinMode.Round; MS.Parent=MF
applyGlowStroke(MS, Library.Scheme.AccentColor, Library.Scheme.MainColor)

local TB=Instance.new("Frame",MF)
TB.Size=UDim2.new(1,0,0,32); TB.BackgroundColor3=Library.Scheme.MainColor; TB.BorderSizePixel=0; TB.ZIndex=2
Instance.new("UICorner",TB).CornerRadius=UDim.new(0,8)

local TBB=Instance.new("Frame",TB)
TBB.Size=UDim2.new(1,0,0,8); TBB.Position=UDim2.new(0,0,1,-8); TBB.BackgroundColor3=Library.Scheme.MainColor; TBB.BorderSizePixel=0
local TitleDivider=Instance.new("Frame",TB)
TitleDivider.Size=UDim2.new(1,0,0,1); TitleDivider.Position=UDim2.new(0,0,1,0)
TitleDivider.BackgroundColor3=Library.Scheme.OutlineColor; TitleDivider.BorderSizePixel=0; TitleDivider.ZIndex=5

local TitleLogo=Instance.new("ImageLabel")
TitleLogo.Name="TitleLogo"; TitleLogo.Size=UDim2.new(0,28,0,28); TitleLogo.Position=UDim2.new(0,8,0,2)
TitleLogo.BackgroundTransparency=1; TitleLogo.Image=IMG_LOGO_TITLE; TitleLogo.ImageColor3=Library.Scheme.FontColor
TitleLogo.ScaleType=Enum.ScaleType.Fit; TitleLogo.ZIndex=5; TitleLogo.Parent=TB

local TTL=Instance.new("TextLabel",TB)
TTL.AutomaticSize=Enum.AutomaticSize.X; TTL.Size=UDim2.new(0,0,0,19); TTL.Position=UDim2.new(0,40,0,6)
TTL.BackgroundTransparency=1; TTL.Text="NIEELS HUB"; TTL.TextColor3=Library.Scheme.FontColor; TTL.TextSize=25
TTL.Font=Enum.Font.GothamBlack; TTL.TextStrokeColor3=Color3.fromRGB(0,0,0); TTL.TextStrokeTransparency=0.4; TTL.ZIndex=3

local CB=Instance.new("ImageButton",TB)
CB.Size=UDim2.new(0,22,0,22); CB.Position=UDim2.new(1,-28,0.5,-11)
CB.BackgroundTransparency=1; CB.Image=LUCIDE_ICONS.Close; CB.ImageColor3=Library.Scheme.FontColor
CB.ScaleType=Enum.ScaleType.Fit; CB.ZIndex=3
local CBP=Instance.new("UIPadding",CB); CBP.PaddingTop=UDim.new(0,4); CBP.PaddingBottom=UDim.new(0,4); CBP.PaddingLeft=UDim.new(0,4); CBP.PaddingRight=UDim.new(0,4)
Instance.new("UICorner",CB).CornerRadius=UDim.new(0,5)
local CBS=Instance.new("UIStroke",CB); CBS.Color=Color3.fromRGB(100,100,110); CBS.Thickness=1; CBS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

local MB=Instance.new("ImageButton",TB)
MB.Size=UDim2.new(0,22,0,22); MB.Position=UDim2.new(1,-54,0.5,-11)
MB.BackgroundTransparency=1; MB.Image=LUCIDE_ICONS.Minus; MB.ImageColor3=Library.Scheme.FontColor
MB.ScaleType=Enum.ScaleType.Fit; MB.ZIndex=3
local MBP=Instance.new("UIPadding",MB); MBP.PaddingTop=UDim.new(0,4); MBP.PaddingBottom=UDim.new(0,4); MBP.PaddingLeft=UDim.new(0,4); MBP.PaddingRight=UDim.new(0,4)
Instance.new("UICorner",MB).CornerRadius=UDim.new(0,5)
local MBS=Instance.new("UIStroke",MB); MBS.Color=Color3.fromRGB(100,100,110); MBS.Thickness=1; MBS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

local NIEELSLogo=Instance.new("ImageLabel")
NIEELSLogo.Name="NIEELSLogo"; NIEELSLogo.Size=UDim2.new(0.7,0,0.7,0); NIEELSLogo.Position=UDim2.new(0.15,0,0.15,0)
NIEELSLogo.BackgroundTransparency=1; NIEELSLogo.Image=IMG_LOGO_NIEELS; NIEELSLogo.ImageColor3=Color3.fromRGB(255,255,255)
NIEELSLogo.ScaleType=Enum.ScaleType.Fit; NIEELSLogo.Visible=false; NIEELSLogo.ZIndex=5; NIEELSLogo.Parent=MB

local isLocked=true
local LB=Instance.new("ImageButton",TB)
LB.Size=UDim2.new(0,22,0,22); LB.Position=UDim2.new(1,-80,0.5,-11)
LB.BackgroundTransparency=1; LB.Image=LUCIDE_ICONS.Lock; LB.ImageColor3=Library.Scheme.AccentColor
LB.ScaleType=Enum.ScaleType.Fit; LB.ZIndex=3
local LBP=Instance.new("UIPadding",LB); LBP.PaddingTop=UDim.new(0,4); LBP.PaddingBottom=UDim.new(0,4); LBP.PaddingLeft=UDim.new(0,4); LBP.PaddingRight=UDim.new(0,4)
Instance.new("UICorner",LB).CornerRadius=UDim.new(0,5)
local LBS=Instance.new("UIStroke",LB); LBS.Color=Library.Scheme.AccentColor; LBS.Thickness=1; LBS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border

local CP=Instance.new("Frame",MF)
CP.Size=UDim2.new(1,-40,0,110); CP.Position=UDim2.new(0,20,0.5,-55); CP.BackgroundColor3=Library.Scheme.MainColor
CP.BorderSizePixel=0; CP.Visible=false; CP.ZIndex=50
Instance.new("UICorner",CP).CornerRadius=UDim.new(0,8)

local PS=Instance.new("UIStroke",CP); PS.Color=Color3.fromRGB(139,0,0); PS.Thickness=1
PS.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; PS.LineJoinMode=Enum.LineJoinMode.Round
applyGlowStroke(PS, Color3.fromRGB(255, 50, 50), Library.Scheme.MainColor)

local PT=Instance.new("TextLabel",CP)
PT.Size=UDim2.new(1,-20,0,40); PT.Position=UDim2.new(0,10,0,10); PT.BackgroundTransparency=1
PT.Text="Are you sure you want to exit the script?"; PT.TextColor3=Library.Scheme.FontColor; PT.TextSize=12
PT.Font=Enum.Font.Code; PT.TextWrapped=true; PT.ZIndex=51
local YB=Instance.new("TextButton",CP)
YB.Size=UDim2.new(0.5,-15,0,30); YB.Position=UDim2.new(0,10,0,70); YB.BackgroundColor3=Color3.fromRGB(139,0,0)
YB.Text="Yes"; YB.TextColor3=Library.Scheme.FontColor; YB.Font=Enum.Font.Code; YB.TextSize=12; YB.ZIndex=51
Instance.new("UICorner",YB).CornerRadius=UDim.new(0,5)
local NB=Instance.new("TextButton",CP)
NB.Size=UDim2.new(0.5,-15,0,30); NB.Position=UDim2.new(0.5,5,0,70); NB.BackgroundColor3=Color3.fromRGB(80,80,90)
NB.Text="Close"; NB.TextColor3=Library.Scheme.FontColor; NB.Font=Enum.Font.Code; NB.TextSize=12; NB.ZIndex=51
Instance.new("UICorner",NB).CornerRadius=UDim.new(0,5)

local TabBar=Instance.new("Frame",MF)
TabBar.Size=UDim2.new(1,-16,0,34); TabBar.Position=UDim2.new(0,8,0,36)
TabBar.BackgroundColor3=Library.Scheme.BackgroundColor; TabBar.BorderSizePixel=0; TabBar.ZIndex=2
Instance.new("UICorner",TabBar).CornerRadius=UDim.new(0,6)
local TL=Instance.new("UIListLayout",TabBar)
TL.FillDirection=Enum.FillDirection.Horizontal; TL.HorizontalAlignment=Enum.HorizontalAlignment.Center
TL.VerticalAlignment=Enum.VerticalAlignment.Center; TL.Padding=UDim.new(0,3)
local TP=Instance.new("UIPadding",TabBar)
TP.PaddingLeft=UDim.new(0,3); TP.PaddingRight=UDim.new(0,3); TP.PaddingTop=UDim.new(0,4); TP.PaddingBottom=UDim.new(0,4)

local TabDivider=Instance.new("Frame",MF)
TabDivider.Size=UDim2.new(1,-16,0,1); TabDivider.Position=UDim2.new(0,8,0,72)
TabDivider.BackgroundColor3=Library.Scheme.OutlineColor; TabDivider.BorderSizePixel=0; TabDivider.ZIndex=5

local CC=Instance.new("Frame",MF)
CC.Size=UDim2.new(1,-16,1,-84); CC.Position=UDim2.new(0,8,0,76); CC.BackgroundTransparency=1; CC.ZIndex=2

local TBN={}; local TFN={}; local ActiveTab=nil
local TAC=Library.Scheme.AccentColor; local TIC=Library.Scheme.BackgroundColor
local ACC=Library.Scheme.AccentColor; local ONC=Color3.fromRGB(60,200,120); local OFC=Library.Scheme.MainColor
local LC=Library.Scheme.MainColor; local TRC=Library.Scheme.BackgroundColor
local SECT=Library.Scheme.OutlineColor; local TXC=Library.Scheme.FontColor; local DGC=Color3.fromRGB(139,0,0)

local function CreateTF(n)
    local f=Instance.new("ScrollingFrame")
    f.Name=n.."Tab"; f.Size=UDim2.new(1,0,1,0); f.BackgroundTransparency=1; f.BorderSizePixel=0
    f.ScrollBarThickness=4; f.ScrollBarImageColor3=ACC; f.CanvasSize=UDim2.new(0,0,0,0)
    f.AutomaticCanvasSize=Enum.AutomaticSize.Y; f.ScrollingDirection=Enum.ScrollingDirection.Y; f.Visible=false; f.Parent=CC
    f.ZIndex=3
    local l=Instance.new("UIListLayout",f); l.SortOrder=Enum.SortOrder.LayoutOrder; l.Padding=UDim.new(0,6)
    local p=Instance.new("UIPadding",f)
    p.PaddingLeft=UDim.new(0,6); p.PaddingRight=UDim.new(0,6); p.PaddingTop=UDim.new(0,6); p.PaddingBottom=UDim.new(0,6)
    return f
end

local function SwitchTab(n)
    if ActiveTab==n then return end
    for nm,f in pairs(TFN) do f.Visible=(nm==n) end
    for nm,b in pairs(TBN) do
        local stroke = b:FindFirstChildOfClass("UIStroke")
        if nm==n then
            b.TextColor3=TAC
            if stroke then stroke.Transparency=0 end
        else
            b.TextColor3=Color3.fromRGB(120,120,130)
            if stroke then stroke.Transparency=1 end
        end
    end
    ActiveTab=n
end

local TBC=3
local function CreateTab(n,dn,o)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1/TBC,-4,1,-4); b.LayoutOrder=o; b.BackgroundColor3=TIC; b.BackgroundTransparency=1
    b.Text=dn; b.TextColor3=Color3.fromRGB(120,120,130); b.Font=Enum.Font.Code; b.TextSize=10; b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,4); b.Parent=TabBar; b.ZIndex=3
    local stroke = Instance.new("UIStroke", b)
    stroke.Color=TAC; stroke.Thickness=1; stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; stroke.Transparency=1
    b.MouseButton1Click:Connect(function() SwitchTab(n) end)
    TBN[n]=b; TFN[n]=CreateTF(n)
    return TFN[n]
end

local function CreateSec(p,t,o)
    local s=Instance.new("Frame",p)
    s.Size=UDim2.new(1,0,0,22); s.LayoutOrder=o; s.BackgroundTransparency=1; s.ZIndex=3
    local l=Instance.new("TextLabel",s)
    l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.Text=t
    l.TextColor3=SECT; l.Font=Enum.Font.Code; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left; l.ZIndex=3
    local lp=Instance.new("UIPadding",l); lp.PaddingLeft=UDim.new(0,4)
end

local function CreateDivider(p,o)
    local d=Instance.new("Frame",p)
    d.Size=UDim2.new(1,0,0,8); d.LayoutOrder=o; d.BackgroundTransparency=1; d.ZIndex=3
    local line=Instance.new("Frame",d)
    line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,0.5,0)
    line.BackgroundColor3=Library.Scheme.OutlineColor; line.BorderSizePixel=0
end

local function CreateToggle(p,o,lt,init,cb)
    local C=Instance.new("TextButton"); C.Size=UDim2.new(1,0,0,24)
    C.BackgroundTransparency=1; C.Text=""; C.LayoutOrder=o; C.Parent=p; C.ZIndex=3
    local L=Instance.new("TextLabel"); L.Size=UDim2.new(0.7,0,1,0)
    L.BackgroundTransparency=1; L.Text=lt; L.TextColor3=Color3.fromRGB(200,200,200)
    L.Font=Enum.Font.Code; L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=C; L.ZIndex=3
    local IB=Instance.new("Frame")
    IB.Size=UDim2.new(0,34,0,18); IB.Position=UDim2.new(1,-34,0.5,-9)
    IB.BackgroundColor3=init and Color3.fromRGB(90,120,210) or Color3.fromRGB(40,40,45); IB.Parent=C; IB.ZIndex=3
    Instance.new("UICorner",IB).CornerRadius=UDim.new(1,0)
    local Ci=Instance.new("Frame")
    Ci.Size=UDim2.new(0,14,0,14); Ci.Position=init and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
    Ci.BackgroundColor3=Color3.fromRGB(255,255,255); Ci.Parent=IB; Ci.ZIndex=4
    Instance.new("UICorner",Ci).CornerRadius=UDim.new(1,0)
    local state=init
    C.MouseButton1Click:Connect(function()
        state=not state; cb(state)
        NIEELS_Notify(lt, state and "Enabled" or "Disabled", 2.0)
        TweenService:Create(IB, TweenInfo.new(0.2), { BackgroundColor3 = state and Color3.fromRGB(90,120,210) or Color3.fromRGB(40,40,45) }):Play()
        TweenService:Create(Ci, TweenInfo.new(0.2), { Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7) }):Play()
    end)
    return C
end

local function CreateAction(p,o,lt,bt,cb,cc)
    local C=Instance.new("Frame"); C.Size=UDim2.new(1,0,0,24)
    C.BackgroundTransparency=1; C.LayoutOrder=o; C.Parent=p; C.ZIndex=3
    local L=Instance.new("TextLabel"); L.Size=UDim2.new(0.6,0,1,0)
    L.BackgroundTransparency=1; L.Text=lt; L.TextColor3=Color3.fromRGB(200,200,200)
    L.Font=Enum.Font.Code; L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=C; L.ZIndex=3
    local ac = cc or Color3.fromRGB(90,120,210)
    local B=Instance.new("TextButton"); B.Size=UDim2.new(0.4,0,0,18)
    B.Position=UDim2.new(0.6,0,0.5,-9); B.BackgroundTransparency=1
    B.Text=bt; B.TextColor3=ac; B.Font=Enum.Font.Code; B.TextSize=10; B.AutoButtonColor=false; B.Parent=C; B.ZIndex=4
    Instance.new("UICorner",B).CornerRadius=UDim.new(1,0)
    local S=Instance.new("UIStroke",B); S.Color=ac; S.Thickness=1; S.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    B.MouseButton1Click:Connect(function() cb(B); NIEELS_Notify(lt, "Triggered", 2.0) end)
    return B, L
end

local function CreateSliderRow(p,o,lt,mn,mx,df,isf,cb)
    local C=Instance.new("Frame"); C.Size=UDim2.new(1,0,0,34)
    C.BackgroundTransparency=1; C.LayoutOrder=o; C.Parent=p; C.ZIndex=3
    local L=Instance.new("TextLabel"); L.Size=UDim2.new(1,0,0,14)
    L.Position=UDim2.new(0,0,0,0); L.BackgroundTransparency=1
    L.Text=lt..": "..df; L.TextColor3=Color3.fromRGB(200,200,200)
    L.Font=Enum.Font.Code; L.TextSize=11; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=C; L.ZIndex=3
    local SB=Instance.new("Frame"); SB.Size=UDim2.new(1,0,0,8)
    SB.Position=UDim2.new(0,0,0,20); SB.BackgroundColor3=Color3.fromRGB(40,40,45); SB.Parent=C; SB.ZIndex=3
    Instance.new("UICorner",SB).CornerRadius=UDim.new(1,0)
    local ip=math.clamp((df-mn)/(mx-mn),0,1)
    local SF=Instance.new("Frame"); SF.Size=UDim2.new(ip,0,1,0)
    SF.BackgroundColor3=Color3.fromRGB(90,120,210); SF.Parent=SB; SF.ZIndex=4
    Instance.new("UICorner",SF).CornerRadius=UDim.new(1,0)
    local Ci=Instance.new("Frame"); Ci.Size=UDim2.new(0,14,0,14)
    Ci.AnchorPoint=Vector2.new(0.5,0.5); Ci.Position=UDim2.new(ip,0,0.5,0)
    Ci.BackgroundColor3=Color3.fromRGB(255,255,255); Ci.ZIndex=5; Ci.Parent=SB
    Instance.new("UICorner",Ci).CornerRadius=UDim.new(1,0)
    local drag=false
    local function Upd(input)
        if not SB or not SB.Parent or SB.AbsoluteSize.X<=0 then return end
        local pc=math.clamp((input.Position.X-SB.AbsolutePosition.X)/SB.AbsoluteSize.X,0,1)
        local v=mn+pc*(mx-mn); v=math.clamp(v,mn,mx)
        v=isf and (math.floor(v*100+0.5)/100) or math.floor(v+0.5)
        local cp=math.clamp((v-mn)/(mx-mn),0,1)
        TweenService:Create(SF,TweenInfo.new(0.08),{Size=UDim2.new(cp,0,1,0)}):Play()
        TweenService:Create(Ci,TweenInfo.new(0.08),{Position=UDim2.new(cp,0,0.5,0)}):Play()
        L.Text=lt..": "..v; cb(v)
    end
    SB.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; Upd(i)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then Upd(i) end
    end)
    return L, SF
end

local function CreateCycle(p,o,lt,bt,cb)
    local C=Instance.new("TextButton"); C.Size=UDim2.new(1,0,0,24)
    C.BackgroundTransparency=1; C.Text=""; C.LayoutOrder=o; C.Parent=p; C.ZIndex=3
    local L=Instance.new("TextLabel"); L.Size=UDim2.new(0.6,0,1,0)
    L.BackgroundTransparency=1; L.Text=lt; L.TextColor3=Color3.fromRGB(200,200,200)
    L.Font=Enum.Font.Code; L.TextSize=12; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=C; L.ZIndex=3
    local cc=Color3.fromRGB(90,120,210)
    local VB=Instance.new("TextButton"); VB.Size=UDim2.new(0.4,0,0,18)
    VB.Position=UDim2.new(0.6,0,0.5,-9); VB.BackgroundTransparency=1
    VB.Text=bt; VB.TextColor3=cc; VB.Font=Enum.Font.Code; VB.TextSize=10; VB.AutoButtonColor=false; VB.Parent=C; VB.ZIndex=4
    Instance.new("UICorner",VB).CornerRadius=UDim.new(1,0)
    local S=Instance.new("UIStroke",VB); S.Color=cc; S.Thickness=1; S.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
    VB.MouseButton1Click:Connect(function() cb(VB,L); NIEELS_Notify(lt,"Mode: "..VB.Text,2.0) end)
    return VB, L
end

local MainTab=CreateTab("Main","MAIN",1)
local SurvTab=CreateTab("Survivor","SURVIVOR",2)
local KillerTab=CreateTab("Killer","KILLER",3)

local o=1
CreateSec(MainTab,"VISUAL",o); o=o+1
CreateToggle(MainTab,o,"Low graphic",false,function(v)
    if v then EnableLowGraphic() else DisableLowGraphic() end
end); o=o+1
CreateDivider(MainTab,o); o=o+1
CreateSec(MainTab,"STRETCH RES",o); o=o+1
CreateToggle(MainTab,o,"Stretch Res",false,function(v) SetStretchRes(v) end); o=o+1
CreateSliderRow(MainTab,o,"Stretch Amount",0.1,2.0,0.67,true,function(v) SetStretchAmount(v) end); o=o+1
CreateDivider(MainTab,o); o=o+1
CreateSec(MainTab,"MOONWALK",o); o=o+1
CreateToggle(MainTab,o,"Moonwalk",false,function(v)
    if v then StartMoonwalk(); Moonwalk.IsActive = Moonwalk.Enabled; UpdateMoonwalkGUI(Moonwalk.Enabled)
    else StopMoonwalk(); Moonwalk.IsActive = Moonwalk.Enabled; UpdateMoonwalkGUI(Moonwalk.Enabled) end
end); o=o+1
CreateToggle(MainTab,o,"Show Moonwalk GUI",false,function(v)
    if v then
        if not Moonwalk.Gui then CreateMoonwalkGUI() end
        Moonwalk.Gui.Enabled = true; Moonwalk.GuiVisible = true
        UpdateMoonwalkGUI(Moonwalk.Enabled)
    else
        if Moonwalk.Gui then Moonwalk.Gui.Enabled = false; Moonwalk.GuiVisible = false end
    end
end); o=o+1
CreateDivider(MainTab,o); o=o+1
CreateSec(MainTab,"MISC",o); o=o+1
CreateToggle(MainTab,o,"Skip Endscreen",false,function(v) _G.NIEELS.SkipEndscreen=v end); o=o+1

o=1
CreateSec(SurvTab,"AUTO SKILL CHECK",o); o=o+1
CreateToggle(SurvTab,o,"Auto Skill Check",false,function(s) SkillCheck.SetEnabled(s) end); o=o+1
CreateCycle(SurvTab,o,"Skill Mode","Legit",function(b)
    local mode = SkillCheck.GetMode()
    if mode == "Legit" then SkillCheck.SetMode("Instant")
    elseif mode == "Instant" then SkillCheck.SetMode("Normal")
    elseif mode == "Normal" then SkillCheck.SetMode("Random")
    else SkillCheck.SetMode("Legit") end
    b.Text = SkillCheck.GetMode()
    SkillCheckState.busy = false
end); o=o+1
CreateDivider(SurvTab,o); o=o+1
CreateSec(SurvTab,"MOVEMENT",o); o=o+1
CreateToggle(SurvTab,o,"Speed Boost",false,function(s) SpeedBoost:Toggle(s) end); o=o+1
CreateSliderRow(SurvTab,o,"Speed Value",1.0,2.0,1.27,true,function(v) SpeedBoost:SetValue(v) end); o=o+1
CreateToggle(SurvTab,o,"Auto Dodge Crouch",false,function(v)
    AutoDodgeCrouch = v
    if v then StartAutoDodgeCrouch() else StopAutoDodgeCrouch() end
end); o=o+1
CreateDivider(SurvTab,o); o=o+1
CreateSec(SurvTab,"ESCAPE",o); o=o+1
CreateAction(SurvTab,o,"Instant Escape","ESCAPE",function(b)
    local root = getRoot(); if not root then return end
    local found = nil
    for _, obj in ipairs(WS:GetDescendants()) do
        if string.lower(obj.Name) == "fininshline" and obj:IsA("BasePart") then found = obj; break end
    end
    if found then root.CFrame = found.CFrame + Vector3.new(0, 5, 0) end
    b.Text="Triggered"; b.TextColor3=ONC
    local stroke=b:FindFirstChildOfClass("UIStroke")
    if stroke then stroke.Color=ONC end
    task.wait(0.8)
    b.Text="ESCAPE"; b.TextColor3=ACC
    if stroke then stroke.Color=ACC end
end, ACC); o=o+1
CreateDivider(SurvTab,o); o=o+1
CreateSec(SurvTab,"ESP",o); o=o+1
CreateToggle(SurvTab,o,"ESP Player",false,function(s) ESP:Toggle(s) end); o=o+1
CreateToggle(SurvTab,o,"ESP Generator",false,function(s)
    GeneratorESPConfig.Enabled=s
    if not s then
        for gen in pairs(CachedGenerators) do
            if gen then
                local b=gen:FindFirstChild("GenESP"); if b then b:Destroy() end
                local h=gen:FindFirstChild("GenHighlight"); if h then h:Destroy() end
            end
        end
    end
end); o=o+1

o=1
CreateSec(KillerTab,"MYERS",o); o=o+1
CreateToggle(KillerTab,o,"GRAB GUI",false,function(s)
    if s then
        if not (StalkerGUI and StalkerGUI.Parent) then ToggleStalker() end
    else
        if StalkerGUI and StalkerGUI.Parent then ToggleStalker() end
    end
end); o=o+1
CreateToggle(KillerTab,o,"Auto Stalk",false,function(s)
    AutoStalk.Enabled=s
    if s then startAutoStalk() else stopAutoStalk() end
end); o=o+1
CreateDivider(KillerTab,o); o=o+1
CreateSec(KillerTab,"AIMLOCK HIDDEN M2",o); o=o+1
CreateToggle(KillerTab,o,"Aimlock Hidden M2",false,function(s)
    if _G.NIEELSAimlockHiddenSet then _G.NIEELSAimlockHiddenSet(s) end
    if s then
        if var973 then var973() end
        NIEELS_Notify("Aimlock M2", "Enabled", 2.0)
    else
        if StopHiddenM2Hook then StopHiddenM2Hook() end
        NIEELS_Notify("Aimlock M2", "Disabled", 2.0)
    end
end); o=o+1
CreateSliderRow(KillerTab,o,"M2 Smoothness",0.05,1.0,1.0,true,function(v)
    if _G.NIEELSAimlockHiddenSetSmooth then _G.NIEELSAimlockHiddenSetSmooth(v) end
end); o=o+1
CreateDivider(KillerTab,o); o=o+1
CreateSec(KillerTab,"BYPASS COOLDOWN",o); o=o+1
CreateToggle(KillerTab,o,"Bypass Cooldown Killer",false,function(s)
    killerNoCDFlag = s
    if s then
        fn7()
        local killerType = fn6()
        if killerType == "mayers" then StartMayersMobileHook(); NIEELS_Notify("NO COOLDOWN", "Mayers NO CD Enable", 2.0)
        elseif killerType == "hidden" then NIEELS_Notify("No COOLDOWN", "Hidden NO CD Enable", 2.0)
        else NIEELS_Notify("NO COOLDOWN", "NO Cooldown Enable", 2.0) end
    else
        fn8(); StopMayersMobileHook(); NIEELS_Notify("NO COOLDOWN", "NO Cooldown Disable", 2.0)
    end
end); o=o+1

local SavedSize = MF.Size
local SavedPosition = MF.Position
local isMin=false
local MiniFrame=Instance.new("Frame")
MiniFrame.Name="MiniFrame"; MiniFrame.Size=UDim2.new(0,37,0,37); MiniFrame.Position=UDim2.new(0,100,0,100)
MiniFrame.BackgroundColor3=Library.Scheme.MainColor; MiniFrame.BorderSizePixel=0; MiniFrame.Active=true
MiniFrame.Visible=false; MiniFrame.ZIndex=100; MiniFrame.ClipsDescendants=true; MiniFrame.Parent=SG2
Instance.new("UICorner",MiniFrame).CornerRadius=UDim.new(1,0)

local MiniStroke=Instance.new("UIStroke",MiniFrame); MiniStroke.Color=Library.Scheme.AccentColor; MiniStroke.Thickness=1
MiniStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; MiniStroke.LineJoinMode=Enum.LineJoinMode.Round
applyGlowStroke(MiniStroke, Library.Scheme.AccentColor, Library.Scheme.MainColor)

local MiniGlow=Instance.new("ImageLabel",MiniFrame); MiniGlow.Name="Glow"; MiniGlow.Size=UDim2.new(1,10,1,10)
MiniGlow.Position=UDim2.new(0,-5,0,-5); MiniGlow.BackgroundTransparency=1; MiniGlow.Image="rbxassetid://5028857084"
MiniGlow.ImageColor3=Library.Scheme.AccentColor; MiniGlow.ImageTransparency=0.5; MiniGlow.ZIndex=99
local MiniLogo=Instance.new("ImageLabel"); MiniLogo.Size=UDim2.new(0.7,0,0.7,0); MiniLogo.Position=UDim2.new(0.15,0,0.15,0)
MiniLogo.BackgroundTransparency=1; MiniLogo.Image=IMG_LOGO_NIEELS; MiniLogo.ImageColor3=Library.Scheme.FontColor
MiniLogo.ScaleType=Enum.ScaleType.Fit; MiniLogo.ZIndex=101; MiniLogo.Parent=MiniFrame
local MiniBtn=Instance.new("TextButton"); MiniBtn.Size=UDim2.new(1,0,1,0); MiniBtn.BackgroundTransparency=1
MiniBtn.Text=""; MiniBtn.ZIndex=102; MiniBtn.Parent=MiniFrame

local miniDrag, miniStart, miniPos = false, nil, nil
local miniMoved=false
MiniBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        miniDrag=not isLocked; miniMoved=false; miniStart=i.Position; miniPos=MiniFrame.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if isLocked then return end
    if not miniDrag or not miniStart then return end
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        local d=i.Position-miniStart
        if math.abs(d.X)>3 or math.abs(d.Y)>3 then miniMoved=true end
        MiniFrame.Position=UDim2.new(miniPos.X.Scale,miniPos.X.Offset+d.X,miniPos.Y.Scale,miniPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        miniDrag=false; miniStart=nil
    end
end)

local function RestoreFromMini()
    isMin=false; MF.Visible=true
    if SavedSize then MF.Size=SavedSize else MF.Size=UDim2.new(0,347,0,257) end
    TB.Size=UDim2.new(1,0,0,32); TTL.Visible=true; CB.Visible=true; LB.Visible=true; TBB.Visible=true
    TitleLogo.Visible=true; TabBar.Visible=true; CC.Visible=true
    if TabDivider then TabDivider.Visible=true end
    MB.Size=UDim2.new(0,22,0,22); MB.Position=UDim2.new(1,-54,0.5,-11)
    MB.BackgroundTransparency=1; NIEELSLogo.Visible=false
end
MiniBtn.MouseButton1Click:Connect(function()
    if miniMoved then return end
    if isMin then RestoreFromMini() else MF.Visible=false; isMin=true end
end)
MB.MouseButton1Click:Connect(function()
    if CP.Visible then return end
    isMin=not isMin
    if isMin then SavedSize=MF.Size; SavedPosition=MF.Position; MiniFrame.Visible=true; MF.Visible=false
    else RestoreFromMini() end
end)
LB.MouseButton1Click:Connect(function()
    if CP.Visible then return end
    isLocked=not isLocked
    local stroke=LB:FindFirstChildOfClass("UIStroke")
    if isLocked then
        LB.Image=LUCIDE_ICONS.Lock; LB.ImageColor3=Library.Scheme.AccentColor
        if stroke then stroke.Color=Library.Scheme.AccentColor end
    else
        LB.Image=LUCIDE_ICONS.Unlock; LB.ImageColor3=Color3.fromRGB(120,120,130)
        if stroke then stroke.Color=Color3.fromRGB(100,100,110) end
    end
end)

CB.MouseButton1Click:Connect(function() if not CP.Visible then CP.Visible=true end end)
NB.MouseButton1Click:Connect(function() CP.Visible=false end)

local dg=false
local ds,sp=nil,nil
local function IBH(i)
    if isLocked or CP.Visible then return end
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dg=true; ds=i.Position; sp=MF.Position
    end
end
MF.InputBegan:Connect(function(i) IBH(i) end)
TB.InputBegan:Connect(function(i) if not isMin then IBH(i) end end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dg=false; ds=nil end
end)
UIS.InputChanged:Connect(function(i)
    if not dg or isLocked or CP.Visible or not ds then return end
    if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
        local d=i.Position-ds
        MF.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
    end
end)

SwitchTab("Main")
NIEELS_Notify("NIEELS HUB", "Script loaded by "..DEVELOPER_NAME.."!", 3)

YB.MouseButton1Click:Connect(function()
    _G.NIEELS.ScriptAlive=false
    ESP:Stop(); SpeedBoost:Stop()
    stopAutoStalk()
    DisableLowGraphic()
    SetStretchRes(false)
    if _G.NIEELSAimlockHiddenSet then _G.NIEELSAimlockHiddenSet(false) end
    if StopHiddenM2Hook then StopHiddenM2Hook() end
    fn8(); StopMayersMobileHook()
    GeneratorESPConfig.Enabled=false
    for gen in pairs(CachedGenerators) do
        if gen then
            local b=gen:FindFirstChild("GenESP"); if b then b:Destroy() end
            local h=gen:FindFirstChild("GenHighlight"); if h then h:Destroy() end
        end
    end
    VaultSystemEnabled=false; DisableUnlimitedVault(); DisableAntiSlowVault()
    StopAutoDodgeCrouch(); SkillCheck.SetEnabled(false)
    if StalkerGUI then StalkerGUI:Destroy() end
    if MiniFrame then MiniFrame:Destroy() end
    StopMoonwalk()
    if MoonwalkRenderConn then MoonwalkRenderConn:Disconnect() end
    if Moonwalk.InputConn then Moonwalk.InputConn:Disconnect(); Moonwalk.InputConn = nil end
    if Moonwalk.Gui then Moonwalk.Gui:Destroy(); Moonwalk.Gui = nil end
    if getgenv then getgenv().MoonwalkAPI = nil end
    SG2:Destroy()
end)
