-- dumped by AdukyyMor v2.0.1
-- tag: loadstring
-- bytes: 145119
-- extra: 
--========================================================--
--              CHINOINFIERNO
--       FLUENT STYLE UI + FULL ENGINE (INTEGRATED)
--========================================================--

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

--========================================================--
-- CONFIGURACIÓN
--========================================================--

local KEY_CORRECTA = "1"
local DISCORD_LINK = "https://discord.gg/WvfdnxKRD"
local CFG_FILE = "chinoinfierno_settings.txt"
local HasEnteredPanel = false

--========================================================--
-- AUDIO DE TOGGLES
--========================================================--

local function playToggleSound()
    task.spawn(function()
        local url = "https://files.catbox.moe/so5gi0.mp3"
        local fileName = "chinohub_toggle.mp3"

        if isfile and writefile and not isfile(fileName) then
            pcall(function()
                local audioData = game:HttpGet(url)
                writefile(fileName, audioData)
            end)
        end

        local sound = Instance.new("Sound")
        sound.Parent = workspace.CurrentCamera
        sound.SoundId = (getcustomasset and isfile and isfile(fileName) and getcustomasset(fileName)) or url
        sound.Volume = 1.1
        sound.TimePosition = 0.28
        sound:Play()

        sound.Ended:Connect(function()
            sound:Destroy()
        end)
    end)
end

--========================================================--
-- LIMPIEZA PREVIA
--========================================================--

pcall(function()
    if Lighting:FindFirstChild("CHINO_BlurEffect") then Lighting.CHINO_BlurEffect:Destroy() end
    if Lighting:FindFirstChild("InfiernoGlassBlur") then Lighting.InfiernoGlassBlur:Destroy() end
    if CoreGui:FindFirstChild("CHINOHUB_ModernUI") then CoreGui.CHINOHUB_ModernUI:Destroy() end
    if CoreGui:FindFirstChild("FloatingSnapGui") then CoreGui.FloatingSnapGui:Destroy() end
    if CoreGui:FindFirstChild("AstralProjectionGui") then CoreGui.AstralProjectionGui:Destroy() end
    if PlayerGui:FindFirstChild("CHINOHUB_ModernUI") then PlayerGui.CHINOHUB_ModernUI:Destroy() end
    if workspace:FindFirstChild("AK_SurfaceCamPart") then workspace.AK_SurfaceCamPart:Destroy() end
end)

--========================================================--
-- BLUR
--========================================================--

local Blur = Instance.new("BlurEffect")
Blur.Name = "CHINO_BlurEffect"
Blur.Size = 22
Blur.Parent = Lighting

--========================================================--
-- SCREEN GUI
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CHINOHUB_ModernUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999999
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = gethui and gethui() or CoreGui
end)
if not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end

--========================================================--
-- ELEMENTOS VISUALES MIGRADOS
--========================================================--

local SettingsVisual = {
    Box = false,
    Lines = false,
    FOV = false,
    TargetLine = false,

    FOVRadius = 150,
    FOVMin = 145,
    FOVMax = 155,
    FOVSpeed = 2,

    LineOriginY = 1,
    LineTargetOffset = 0,

    TargetLineThickness = 1,
    TargetMarkerSize = 7
}

local CurrentTarget = nil
local FOVTime = 0

local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.Size = UDim2.fromOffset(SettingsVisual.FOVRadius * 2, SettingsVisual.FOVRadius * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.ZIndex = 50
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1
FOVStroke.Transparency = 0.15
FOVStroke.Color = Color3.fromRGB(135, 150, 255)
FOVStroke.Parent = FOVCircle

local TargetLine = Instance.new("Frame")
TargetLine.Name = "TargetLine"
TargetLine.AnchorPoint = Vector2.new(0.5, 0.5)
TargetLine.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
TargetLine.BackgroundTransparency = 0.05
TargetLine.BorderSizePixel = 0
TargetLine.Size = UDim2.fromOffset(0, SettingsVisual.TargetLineThickness)
TargetLine.Visible = false
TargetLine.ZIndex = 20
TargetLine.Parent = ScreenGui

local TargetMarker = Instance.new("Frame")
TargetMarker.Name = "TargetMarker"
TargetMarker.Size = UDim2.fromOffset(SettingsVisual.TargetMarkerSize, SettingsVisual.TargetMarkerSize)
TargetMarker.AnchorPoint = Vector2.new(0.5, 0.5)
TargetMarker.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
TargetMarker.BorderSizePixel = 0
TargetMarker.Visible = false
TargetMarker.ZIndex = 30
TargetMarker.Parent = ScreenGui

local MarkerCorner = Instance.new("UICorner")
MarkerCorner.CornerRadius = UDim.new(1, 0)
MarkerCorner.Parent = TargetMarker

local MarkerStroke = Instance.new("UIStroke")
MarkerStroke.Thickness = 1
MarkerStroke.Color = Color3.fromRGB(255, 255, 255)
MarkerStroke.Parent = TargetMarker

local VisualPlayerObjects = {}

local function CreateVisualPlayerObjects(player)
    if player == LocalPlayer then return end
    local data = {}

    local box = Instance.new("SelectionBox")
    box.Name = "ESPBox"
    box.LineThickness = 0.015
    box.Color3 = Color3.fromRGB(135, 150, 255)
    box.SurfaceTransparency = 1
    box.Visible = false
    box.Parent = ScreenGui
    data.Box = box

    local line = Instance.new("Frame")
    line.Name = "ESPLine"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = Color3.fromRGB(135, 150, 255)
    line.BackgroundTransparency = 0.1
    line.BorderSizePixel = 0
    line.Size = UDim2.fromOffset(0, 1)
    line.Visible = false
    line.ZIndex = 10
    line.Parent = ScreenGui
    data.Line = line

    VisualPlayerObjects[player] = data
end

local function RemoveVisualPlayerObjects(player)
    if CurrentTarget == player then
        CurrentTarget = nil
        TargetLine.Visible = false
        TargetMarker.Visible = false
    end

    local data = VisualPlayerObjects[player]
    if not data then return end

    for _, object in pairs(data) do
        if object then object:Destroy() end
    end
    VisualPlayerObjects[player] = nil
end

for _, pl in ipairs(Players:GetPlayers()) do
    CreateVisualPlayerObjects(pl)
end
Players.PlayerAdded:Connect(CreateVisualPlayerObjects)
Players.PlayerRemoving:Connect(RemoveVisualPlayerObjects)

local function HasLineOfSight(targetCharacter, targetHead)
    local myCharacter = LocalPlayer.Character
    if not myCharacter then return false end

    local myHead = myCharacter:FindFirstChild("Head")
    if not myHead then return false end

    local origin = myHead.Position
    local direction = targetHead.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {myCharacter, targetCharacter}
    params.IgnoreWater = true

    local result = workspace:Raycast(origin, direction, params)
    return result == nil
end

local function GetBestVisualTarget()
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestPlayer = nil
    local bestDistance = SettingsVisual.FOVRadius

    for player in pairs(VisualPlayerObjects) do
        local character = player.Character
        if character then
            local head = character:FindFirstChild("Head") or character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")

            if head then
                local position, visible = Camera:WorldToViewportPoint(head.Position)
                if visible and position.Z > 0 then
                    local screenPosition = Vector2.new(position.X, position.Y)
                    local distance = (screenPosition - center).Magnitude

                    if distance <= SettingsVisual.FOVRadius and distance < bestDistance then
                        bestDistance = distance
                        bestPlayer = player
                    end
                end
            end
        end
    end
    return bestPlayer
end

local function UpdateTargetLine()
    if not SettingsVisual.TargetLine or not CurrentTarget then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local myCharacter = LocalPlayer.Character
    local targetCharacter = CurrentTarget.Character
    if not myCharacter or not targetCharacter then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local myHead = myCharacter:FindFirstChild("Head")
    local targetHead = targetCharacter:FindFirstChild("Head") or targetCharacter:FindFirstChild("UpperTorso") or targetCharacter:FindFirstChild("Torso")
    if not myHead or not targetHead then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local myPosition, myVisible = Camera:WorldToViewportPoint(myHead.Position)
    local targetPosition, targetVisible = Camera:WorldToViewportPoint(targetHead.Position)

    if not myVisible or not targetVisible or myPosition.Z <= 0 or targetPosition.Z <= 0 then
        TargetLine.Visible = false
        TargetMarker.Visible = false
        return
    end

    local from = Vector2.new(myPosition.X, myPosition.Y)
    local target = Vector2.new(targetPosition.X, targetPosition.Y)
    local difference = target - from
    local length = difference.Magnitude

    if length <= 0 then return end

    local visible = HasLineOfSight(targetCharacter, targetHead)
    if visible then
        TargetLine.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        TargetMarker.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    else
        TargetLine.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
        TargetMarker.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
    end

    TargetLine.Position = UDim2.fromOffset((from.X + target.X) / 2, (from.Y + target.Y) / 2)
    TargetLine.Size = UDim2.fromOffset(length, SettingsVisual.TargetLineThickness)
    TargetLine.Rotation = math.deg(math.atan2(difference.Y, difference.X))
    TargetLine.Visible = true

    TargetMarker.Position = UDim2.fromOffset(target.X, target.Y)
    TargetMarker.Visible = true
end

--========================================================--
-- FONDO
--========================================================--

local Background = Instance.new("Frame")
Background.Name = "Background"
Background.Size = UDim2.new(1,0,1,0)
Background.Position = UDim2.new(0,0,0,0)
Background.BackgroundColor3 = Color3.fromRGB(12,9,19)
Background.BorderSizePixel = 0
Background.ClipsDescendants = true
Background.Parent = ScreenGui

--========================================================--
-- ORBES AMBIENTALES
--========================================================--

local OrbFolder = Instance.new("Folder")
OrbFolder.Name = "AmbientOrbs"
OrbFolder.Parent = Background

local RegisteredOrbs = {}

local function CreateOrb(position, size, color)
    local holder = Instance.new("Frame")
    holder.Size = size
    holder.Position = position
    holder.AnchorPoint = Vector2.new(.5, .5)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Parent = OrbFolder

    local glow = Instance.new("Frame")
    glow.Name = "Glow"
    glow.Size = UDim2.new(1, 100, 1, 100)
    glow.Position = UDim2.new(.5, 0, .5, 0)
    glow.AnchorPoint = Vector2.new(.5, .5)
    glow.BackgroundColor3 = color
    glow.BackgroundTransparency = .84
    glow.BorderSizePixel = 0
    glow.Parent = holder

    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow

    local core = Instance.new("Frame")
    core.Name = "Core"
    core.Size = UDim2.new(.6, 0, .6, 0)
    core.Position = UDim2.new(.5, 0, .5, 0)
    core.AnchorPoint = Vector2.new(.5, .5)
    core.BackgroundColor3 = color
    core.BackgroundTransparency = .78
    core.BorderSizePixel = 0
    core.Parent = holder

    local coreCorner = Instance.new("UICorner")
    coreCorner.CornerRadius = UDim.new(1, 0)
    coreCorner.Parent = core

    table.insert(RegisteredOrbs, {Glow = glow, Core = core})
    return holder
end

local RedOrb = CreateOrb(UDim2.new(.50, 0, .25, 0), UDim2.new(0, 520, 0, 520), Color3.fromRGB(190, 25, 55))
local PurpleOrb = CreateOrb(UDim2.new(.25, 0, .55, 0), UDim2.new(0, 560, 0, 560), Color3.fromRGB(105, 20, 135))
local BlueOrb = CreateOrb(UDim2.new(.75, 0, .78, 0), UDim2.new(0, 650, 0, 650), Color3.fromRGB(65, 105, 205))

task.spawn(function()
    local t = 0
    while ScreenGui.Parent do
        t = t + 0.015
        RedOrb.Position = UDim2.new(0.50 + math.sin(t * 0.45) * 0.14, 0, 0.28 + math.cos(t * 0.35) * 0.12, 0)
        PurpleOrb.Position = UDim2.new(0.28 + math.cos(t * 0.32) * 0.16, 0, 0.58 + math.sin(t * 0.40) * 0.14, 0)
        BlueOrb.Position = UDim2.new(0.72 + math.sin(t * 0.38) * 0.15, 0, 0.74 + math.cos(t * 0.48) * 0.13, 0)
        RunService.RenderStepped:Wait()
    end
end)

--========================================================--
-- INTRO (WELCOME -> CHINOINFIERNOHUB)
--========================================================--

local Intro = Instance.new("TextLabel")
Intro.Size = UDim2.new(1, 0, 0, 70)
Intro.Position = UDim2.new(.5, 0, .5, 0)
Intro.AnchorPoint = Vector2.new(.5, .5)
Intro.BackgroundTransparency = 1
Intro.Text = "WELCOME"
Intro.TextColor3 = Color3.fromRGB(255, 255, 255)
Intro.TextTransparency = 1
Intro.TextSize = 32
Intro.Font = Enum.Font.GothamMedium
Intro.Parent = Background

task.wait(0.8)
TweenService:Create(Intro, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
task.wait(1.4)
TweenService:Create(Intro, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
task.wait(1.0)

Intro.Text = "CHRISS-CRACKED"
Intro.Font = Enum.Font.GothamMedium
TweenService:Create(Intro, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
task.wait(1.4)
TweenService:Create(Intro, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
task.wait(1.0)
Intro:Destroy()

--========================================================--
-- KEY CARD
--========================================================--

local Card = Instance.new("Frame")
Card.Name = "KeyCard"
Card.Size = UDim2.new(0, 320, 0, 420)
Card.Position = UDim2.new(.5, 0, .5, 30)
Card.AnchorPoint = Vector2.new(.5, .5)
Card.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
Card.BackgroundTransparency = 1
Card.BorderSizePixel = 0
Card.ClipsDescendants = true
Card.Active = true
Card.Draggable = true
Card.Parent = Background

local CardScale = Instance.new("UIScale")
CardScale.Parent = Card

local function UpdateKeyScale()
    local cam = workspace.CurrentCamera
    if cam then
        local v = cam.ViewportSize
        if v.X < 600 then
            CardScale.Scale = math.clamp(v.X / 600, .72, .95)
        else
            CardScale.Scale = 1
        end
    end
end
UpdateKeyScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateKeyScale)
end

local CardCorner = Instance.new("UICorner")
CardCorner.CornerRadius = UDim.new(0, 24)
CardCorner.Parent = Card

local CardStroke = Instance.new("UIStroke")
CardStroke.Color = Color3.fromRGB(255, 255, 255)
CardStroke.Transparency = .88
CardStroke.Thickness = 1.1
CardStroke.Parent = Card

local AvatarBg = Instance.new("Frame")
AvatarBg.Size = UDim2.new(0, 80, 0, 80)
AvatarBg.Position = UDim2.new(.5, 0, 0, 22)
AvatarBg.AnchorPoint = Vector2.new(.5, 0)
AvatarBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
AvatarBg.BackgroundTransparency = .92
AvatarBg.BorderSizePixel = 0
AvatarBg.Parent = Card

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(1, 0)
AvatarCorner.Parent = AvatarBg

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = Color3.fromRGB(135, 150, 255)
AvatarStroke.Transparency = .45
AvatarStroke.Thickness = 1.5
AvatarStroke.Parent = AvatarBg

local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(1, -8, 1, -8)
Avatar.Position = UDim2.new(.5, 0, .5, 0)
Avatar.AnchorPoint = Vector2.new(.5, .5)
Avatar.BackgroundTransparency = 1
Avatar.Parent = AvatarBg

local AvatarImageCorner = Instance.new("UICorner")
AvatarImageCorner.CornerRadius = UDim.new(1, 0)
AvatarImageCorner.Parent = Avatar

task.spawn(function()
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
    end)
    if ok and image then Avatar.Image = image end
end)

local Title = Instance.new("TextLabel")
Title.Text = "CHINOINFIERNO"
Title.Size = UDim2.new(1, 0, 0, 24)
Title.Position = UDim2.new(0, 0, 0, 114)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamMedium
Title.Parent = Card

local Subtitle = Instance.new("TextLabel")
Subtitle.Text = "Enter your key to continue"
Subtitle.Size = UDim2.new(1, 0, 0, 18)
Subtitle.Position = UDim2.new(0, 0, 0, 138)
Subtitle.BackgroundTransparency = 1
Subtitle.TextColor3 = Color3.fromRGB(160, 165, 185)
Subtitle.TextSize = 12
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = Card

local InputHolder = Instance.new("Frame")
InputHolder.Size = UDim2.new(0, 240, 0, 36)
InputHolder.Position = UDim2.new(.5, 0, 0, 180)
InputHolder.AnchorPoint = Vector2.new(.5, 0)
InputHolder.BackgroundTransparency = 1
InputHolder.Parent = Card

local Lock = Instance.new("ImageLabel")
Lock.Size = UDim2.new(0, 14, 0, 14)
Lock.Position = UDim2.new(0, 3, .5, -7)
Lock.BackgroundTransparency = 1
Lock.Image = "rbxassetid://6031082533"
Lock.ImageColor3 = Color3.fromRGB(255, 255, 255)
Lock.ImageTransparency = .45
Lock.Parent = InputHolder

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(1, -26, 1, -4)
KeyInput.Position = UDim2.new(0, 26, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = ""
KeyInput.PlaceholderText = "Pega tu Key aquí..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(140, 145, 165)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 13
KeyInput.Font = Enum.Font.Gotham
KeyInput.TextXAlignment = Enum.TextXAlignment.Left
KeyInput.ClearTextOnFocus = false
KeyInput.Parent = InputHolder

local Underline = Instance.new("Frame")
Underline.Size = UDim2.new(1, 0, 0, 1)
Underline.Position = UDim2.new(0, 0, 1, -1)
Underline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Underline.BackgroundTransparency = .65
Underline.BorderSizePixel = 0
Underline.Parent = InputHolder

local Login = Instance.new("TextButton")
Login.Size = UDim2.new(0, 240, 0, 40)
Login.Position = UDim2.new(.5, 0, 0, 245)
Login.AnchorPoint = Vector2.new(.5, 0)
Login.BackgroundColor3 = Color3.fromRGB(65, 85, 205)
Login.BackgroundTransparency = .32
Login.Text = "LOGIN"
Login.TextColor3 = Color3.fromRGB(255, 255, 255)
Login.TextSize = 12
Login.Font = Enum.Font.GothamMedium
Login.BorderSizePixel = 0
Login.Parent = Card

local LoginCorner = Instance.new("UICorner")
LoginCorner.CornerRadius = UDim.new(0, 14)
LoginCorner.Parent = Login

local LoginGradient = Instance.new("UIGradient")
LoginGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 50, 160)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 110, 230))
}
LoginGradient.Parent = Login

local Discord = Instance.new("TextButton")
Discord.Size = UDim2.new(0, 240, 0, 18)
Discord.Position = UDim2.new(.5, 0, 0, 315)
Discord.AnchorPoint = Vector2.new(.5, 0)
Discord.BackgroundTransparency = 1
Discord.Text = DISCORD_LINK
Discord.TextColor3 = Color3.fromRGB(150, 185, 240)
Discord.TextSize = 11
Discord.Font = Enum.Font.Gotham
Discord.Parent = Card

Discord.MouseButton1Click:Connect(function()
    if setclipboard then setclipboard(DISCORD_LINK) end
    Discord.Text = "COPIED!"
    task.wait(1.5)
    if Discord.Parent then Discord.Text = DISCORD_LINK end
end)

local Hint = Instance.new("TextLabel")
Hint.Size = UDim2.new(1, 0, 0, 15)
Hint.Position = UDim2.new(0, 0, 0, 338)
Hint.BackgroundTransparency = 1
Hint.Text = "Click to copy Discord"
Hint.TextColor3 = Color3.fromRGB(130, 135, 155)
Hint.TextSize = 10
Hint.Font = Enum.Font.Gotham
Hint.Parent = Card

local StatusLabel = Instance.new("TextLabel", Card)
StatusLabel.Size = UDim2.new(1, 0, 0, 18)
StatusLabel.Position = UDim2.new(0, 0, 0, 365)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Gotham

TweenService:Create(
    Card,
    TweenInfo.new(.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    {BackgroundTransparency = .75, Position = UDim2.new(.5, 0, .5, 0)}
):Play()

--========================================================--
-- VARIABLES DE ESTADOS Y CONTROL
--========================================================--

local ThemeColor = Color3.fromRGB(135, 150, 255)
local DynamicColorElements = {}
local MainHubFrameRef = nil

local SilentAimEnabled = false
local TargetHitPart = "Neck" -- POR DEFECTO NECK
local CurrentLockedTarget = nil
local WallbangEnabled = false

local P = {}

local InfiniteJumpEnabled = false
local JumpPowerBypassValue = 50
local InfStaminaEnabled = false
local OriginalSprintUpdate = nil
local AutoSprintLoop = nil

local SpeedHackEnabled = false
local SpeedValue = 4
local HeadHidingAntiAim = false

local SkipCratesEnabled = false
local PotatoBoostEnabled = false
local OriginalCameraFOV = Camera.FieldOfView

local AutoSafeDamageEnabled = false
local AutoSafeActive = false
local AutoSafeDepth = 25
local SavedAutoSafeY = nil
local TargetAutoSafeY = nil
local FrozenCameraCFrame = nil

local PlayerESP_Name = false
local PlayerESP_Health = false
local PlayerESP_Dist = false
local PlayerESP_Highlight = false
local WeaponESPEnabled = false
local ItemESPEnabled = false

local GunModsActive = false
local FireRateVal = 1000
local AccuracyVal = 1
local RecoilVal = 0
local ReloadVal = 0.1
local AutomaticVal = true
local DurabilityVal = 999999999

local MeleeAuraEnabled = false
local AutoAttackEnabled = false
local SavedMeleeAttributes = {}

-- TUNING DE VEHÍCULOS
local VehAcceleration = 20
local VehBraking = 40
local VehDeceleration = 10
local VehForwardMaxSpeed = 120
local VehReverseMaxSpeed = 45
local VehSuspension = 2

local VehAcceleration_Enabled = true
local VehBraking_Enabled = true
local VehDeceleration_Enabled = true
local VehForwardMaxSpeed_Enabled = true
local VehReverseMaxSpeed_Enabled = true
local VehSuspension_Enabled = true

local AutoPickupEnabled = false
local AutoPickupRadius = 85
local AutoInteractEnabled = false
local HideNameEnabled = false

local HighlightCache = {}
local PlayerBillboards = {}
local WeaponBillboardCache = {}
local WeaponCacheTokens = {}
local ItemDrawingsCache = {}
local RegisteredWeaponDB = {}
local VelocityHistory = {}

local FloatingSnapActive = false
local FloatingSnapDepth = 15
local FloatingSavedSurfaceY = nil
local FloatingTargetY = nil

local AstralActive = false
local AstralOrb = nil
local AstralConnection = nil
local AstralSpeed = 40
local FrozenCharCF = nil

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
local SendRemote = RemotesFolder and RemotesFolder:FindFirstChild("Send")
local GetRemote = RemotesFolder and RemotesFolder:FindFirstChild("Get")
local DroppedItems = workspace:WaitForChild("DroppedItems", 10)
local ItemsFolder = ReplicatedStorage:WaitForChild("Items", 10)
local GunsFolder = ItemsFolder and ItemsFolder:FindFirstChild("gun")
local MeleeFolder = ItemsFolder and ItemsFolder:FindFirstChild("melee")
local ThrowableFolder = ItemsFolder and ItemsFolder:FindFirstChild("throwable")

local RemoteCounter
pcall(function()
    for _, obj in ipairs(getgc(true)) do
        if typeof(obj) == "table" and rawget(obj, "event") and rawget(obj, "func") then
            RemoteCounter = obj
            break
        end
    end
end)

local RawCallCount = 0
local function FireServerHook(...)
    if not SendRemote then return end
    local args = {...}
    if RemoteCounter and type(RemoteCounter.event) == "number" then
        RemoteCounter.event = RemoteCounter.event + 1
        pcall(function() SendRemote:FireServer(RemoteCounter.event, unpack(args)) end)
    else
        RawCallCount = RawCallCount + 1
        pcall(function() SendRemote:FireServer(RawCallCount, unpack(args)) end)
    end
end

local function InvokeServerHook(...)
    if not GetRemote then return end
    local args = {...}
    if RemoteCounter and type(RemoteCounter.func) == "number" then
        RemoteCounter.func = RemoteCounter.func + 1
        local ok, res = pcall(function() return GetRemote:InvokeServer(RemoteCounter.func, unpack(args)) end)
        return res
    else
        local ok, res = pcall(function() return GetRemote:InvokeServer(unpack(args)) end)
        return res
    end
end

--========================================================--
-- SISTEMA DE NIEVE
--========================================================--

local ActiveSnowContainers = {}

local function AttachSnowEffect(parentFrame)
    local container = Instance.new("Frame")
    container.Name = "SnowContainer"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.ZIndex = 2
    container.Parent = parentFrame
    Instance.new("UICorner", container).CornerRadius = UDim.new(0, 16)
    
    table.insert(ActiveSnowContainers, container)

    task.spawn(function()
        while container.Parent do
            task.wait(math.random(7, 18) / 100)
            task.spawn(function()
                if not container.Parent then return end
                local startX = math.random()
                local size = math.random(2, 5)
                local flake = Instance.new("Frame", container)
                flake.Size = UDim2.new(0, size, 0, size)
                flake.Position = UDim2.new(startX, 0, -0.1, 0)
                flake.BackgroundColor3 = (math.random(1, 3) == 1 and Color3.fromRGB(255, 255, 255)) or ThemeColor
                flake.BackgroundTransparency = math.random(20, 50) / 100
                flake.BorderSizePixel = 0
                flake.ZIndex = 2
                Instance.new("UICorner", flake).CornerRadius = UDim.new(1, 0)

                local fallTime = math.random(18, 35) / 10
                local tw = TweenService:Create(flake, TweenInfo.new(fallTime, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(startX + (math.random(-4, 4) / 100), 0, 1.1, 0),
                    BackgroundTransparency = 1
                })
                tw:Play()
                tw.Completed:Connect(function()
                    flake:Destroy()
                end)
            end)
        end
    end)
end

--========================================================--
-- BASE DE DATOS Y ENGINES
--========================================================--

local RarityColors = {
    Common = Color3.fromRGB(255, 255, 255),
    Uncommon = Color3.fromRGB(99, 255, 52),
    Rare = Color3.fromRGB(51, 170, 255),
    Epic = Color3.fromRGB(237, 44, 255),
    Legendary = Color3.fromRGB(255, 150, 0),
    Omega = Color3.fromRGB(255, 20, 51)
}

local function registerFolderItems(folder)
    if not folder then return end
    for _, item in ipairs(folder:GetChildren()) do
        if item:IsA("Tool") then
            local handle = item:FindFirstChild("Handle")
            local dName = item:GetAttribute("DisplayName") or item.Name
            local iId = item:GetAttribute("ItemId") or item:GetAttribute("Id") or item.Name
            local rarity = item:GetAttribute("RarityName") or "Common"
            local img = item:GetAttribute("ImageId") or "rbxassetid://7072725737"
            local key
            if handle then
                local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                if mesh and mesh.MeshId ~= "" then
                    key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
                elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then
                    key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity
                end
            end
            if not key and iId ~= "" and iId ~= item.Name then key = "ITEMID_" .. iId .. "_RARITY_" .. rarity end
            if not key then key = "NAME_" .. dName .. "_" .. item.Name .. "_RARITY_" .. rarity end
            RegisteredWeaponDB[key] = {Name = dName, Rarity = rarity, ImageId = img, ToolName = item.Name}
        end
    end
end

if ItemsFolder then
    for _, sub in ipairs({"gun", "melee", "throwable", "consumable", "farming", "misc", "rod", "fish"}) do
        registerFolderItems(ItemsFolder:FindFirstChild(sub))
    end
end

local function getWeaponData(tool)
    if not tool or not tool:IsA("Tool") then return nil end
    local handle = tool:FindFirstChild("Handle")
    local dName = tool:GetAttribute("DisplayName") or tool.Name
    local iId = tool:GetAttribute("ItemId") or tool:GetAttribute("Id") or tool.Name
    local rarity = tool:GetAttribute("RarityName") or "Common"
    local key
    if handle then
        local mesh = handle:FindFirstChildOfClass("SpecialMesh")
        if mesh and mesh.MeshId ~= "" then key = mesh.MeshId .. (mesh.TextureId or "") .. "_RARITY_" .. rarity
        elseif handle:IsA("MeshPart") and handle.MeshId ~= "" then key = handle.MeshId .. (handle.TextureID or "") .. "_RARITY_" .. rarity end
    end
    if not key and iId ~= "" and iId ~= tool.Name then key = "ITEMID_" .. iId .. "_RARITY_" .. rarity end
    if not key then key = "NAME_" .. dName .. "_" .. tool.Name .. "_RARITY_" .. rarity end
    return RegisteredWeaponDB[key]
end

local function getPing()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return 0.08 end
    local netStats = pGui:FindFirstChild("NetworkStats")
    if not netStats then return 0.08 end
    local pingLabel = netStats:FindFirstChild("PingLabel")
    if not pingLabel then return 0.08 end
    local text = pingLabel.Text
    if typeof(text) ~= "string" then return 0.08 end
    local ms = tonumber(text:match("%d+"))
    if not ms then return 0.08 end
    local s = ms / 1000
    if s < 0 or s > 1.5 then s = 0.08 end
    return s
end

--========================================================--
-- MOTOR DE SELECCIÓN Y PREDICCIÓN CON LÓGICA DE YA.TXT
--========================================================--

local function getBypassedTargetPart(character)
    if not character then return nil, Vector3.zero end
    local head = character:FindFirstChild("Head")
    local upperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    local root = character:FindFirstChild("HumanoidRootPart")

    if TargetHitPart == "Head" then
        return (head or upperTorso or root), Vector3.zero
    elseif TargetHitPart == "Neck" then
        if head then
            return head, Vector3.new(0, -0.65, 0)
        elseif upperTorso then
            return upperTorso, Vector3.new(0, 0.3, 0)
        end
        return (head or upperTorso or root), Vector3.new(0, -0.4, 0)
    elseif TargetHitPart == "Chest" then
        return (upperTorso or root or head), Vector3.zero
    end
    return (head or upperTorso or root), Vector3.zero
end

RunService.Heartbeat:Connect(function()
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local root = pl.Character:FindFirstChild("HumanoidRootPart")
            if root then
                VelocityHistory[pl] = VelocityHistory[pl] or {}
                table.insert(VelocityHistory[pl], {time = os.clock(), pos = root.Position})
                if #VelocityHistory[pl] > 6 then
                    table.remove(VelocityHistory[pl], 1)
                end
            else
                VelocityHistory[pl] = nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(pl)
    VelocityHistory[pl] = nil
end)

local function calculateTargetVelocity(pl, rootPart)
    if rootPart and rootPart.AssemblyLinearVelocity.Magnitude > 22 then
        return rootPart.AssemblyLinearVelocity
    end

    local history = VelocityHistory[pl]
    if not history or #history < 2 then return Vector3.zero end

    local totalVel = Vector3.zero
    local count = 0
    for i = 2, #history do
        local dt = history[i].time - history[i - 1].time
        if dt > 0 then
            totalVel = totalVel + (history[i].pos - history[i - 1].pos) / dt
            count = count + 1
        end
    end
    if count == 0 then return Vector3.zero end

    local avg = totalVel / count
    if avg.Y > 150 then
        return Vector3.new(avg.X * 1.15, math.clamp(avg.Y * 0.85, 0, 400), avg.Z * 1.15)
    end
    return avg
end

local function predictPosition(targetPart, customOffset, rootPart)
    if not targetPart then return Vector3.zero end
    local offset = customOffset or Vector3.zero
    local basePos = targetPart.Position + offset
    local pl = Players:GetPlayerFromCharacter(targetPart.Parent)
    if not pl then return basePos end

    local targetChar = targetPart.Parent
    local hum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
    local isDowned = hum and (hum:GetAttribute("HasBeenDowned") or hum:GetAttribute("IsDead") or hum.Health <= 0)

    if isDowned then return basePos end

    local vel = calculateTargetVelocity(pl, rootPart) or Vector3.zero
    local ping = getPing()

    return basePos + (vel * ping * 1.2)
end

local function isShotgun()
    local char = LocalPlayer.Character
    if not char then return false end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            local ammo = item:GetAttribute("AmmoType")
            if ammo == "shotgun" or ammo == "shootgun" then return true end
        end
    end
    return false
end

--========================================================--
-- MODAL DE ADVERTENCIA (DE YA.TXT)
--========================================================--

local function ShowWarningModal(titleText, bodyText, confirmText, onConfirm)
    local alertOverlay = Instance.new("Frame", ScreenGui)
    alertOverlay.Size = UDim2.new(1, 0, 1, 0)
    alertOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    alertOverlay.BackgroundTransparency = 0.55
    alertOverlay.BorderSizePixel = 0
    alertOverlay.ZIndex = 9999

    local alertBox = Instance.new("Frame", alertOverlay)
    alertBox.Size = UDim2.new(0, 320, 0, 160)
    alertBox.Position = UDim2.new(0.5, -160, 0.5, -80)
    alertBox.BackgroundColor3 = Color3.fromRGB(18, 15, 27)
    alertBox.BackgroundTransparency = 0.1
    alertBox.BorderSizePixel = 0
    alertBox.ZIndex = 10000
    Instance.new("UICorner", alertBox).CornerRadius = UDim.new(0, 16)

    local stroke = Instance.new("UIStroke", alertBox)
    stroke.Color = ThemeColor
    stroke.Thickness = 1.4
    table.insert(DynamicColorElements, {Type = "Stroke", Element = stroke})

    local title = Instance.new("TextLabel", alertBox)
    title.Size = UDim2.new(1, -24, 0, 26)
    title.Position = UDim2.new(0, 12, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = "⚠️ " .. titleText
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 10001

    local desc = Instance.new("TextLabel", alertBox)
    desc.Size = UDim2.new(1, -24, 0, 60)
    desc.Position = UDim2.new(0, 12, 0, 42)
    desc.BackgroundTransparency = 1
    desc.Text = bodyText
    desc.TextColor3 = Color3.fromRGB(185, 190, 210)
    desc.TextSize = 11
    desc.Font = Enum.Font.Gotham
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = 10001

    local actionBtn = Instance.new("TextButton", alertBox)
    actionBtn.Size = UDim2.new(0.68, 0, 0, 30)
    actionBtn.Position = UDim2.new(0, 12, 1, -40)
    actionBtn.BackgroundColor3 = ThemeColor
    actionBtn.BackgroundTransparency = 0.2
    actionBtn.BorderSizePixel = 0
    actionBtn.Text = confirmText or "ENTENDIDO"
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.TextSize = 10
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.ZIndex = 10001
    Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 8)
    table.insert(DynamicColorElements, {Type = "Background", Element = actionBtn})

    local closeBtn = Instance.new("TextButton", alertBox)
    closeBtn.Size = UDim2.new(0.26, 0, 0, 30)
    closeBtn.Position = UDim2.new(1, -12 - (alertBox.AbsoluteSize.X * 0.26), 1, -40)
    closeBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "CERRAR"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
    closeBtn.TextSize = 10
    closeBtn.Font = Enum.Font.GothamMedium
    closeBtn.ZIndex = 10001
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

    actionBtn.MouseButton1Click:Connect(function()
        alertOverlay:Destroy()
        if onConfirm then onConfirm() end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        alertOverlay:Destroy()
    end)
end

--========================================================--
-- SILENT AIM HOOK
--========================================================--

if SendRemote and hookfunction then
    local originalFireServer
    originalFireServer = hookfunction(SendRemote.FireServer, function(self, ...)
        if self ~= SendRemote then return originalFireServer(self, ...) end
        local args = {...}
        
        local remoteMethod = args[2]
        if typeof(remoteMethod) == "string" then
            local checkLower = string.lower(remoteMethod)
            if checkLower:find("blacklist") or checkLower:find("punish") or checkLower:find("cheat") or checkLower:find("report") or checkLower:find("flag") then
                return nil
            end
        end

        if SilentAimEnabled and args[2] == "shoot_gun" and CurrentLockedTarget then
            local targetChar = CurrentLockedTarget.Character
            local hitPart, hitOffset = getBypassedTargetPart(targetChar)
            local root = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            local hum = targetChar and targetChar:FindFirstChild("Humanoid")
            local myHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
            
            if hitPart and myHead then
                local targetPos = predictPosition(hitPart, hitOffset, root)
                local originPos = myHead.Position
                
                if isShotgun() then
                    args[4] = CFrame.new(originPos, targetPos)
                    local pellets = {}
                    for i = 1, 6 do
                        local spreadOffset = Vector3.new(
                            math.random(-2, 2) * 0.02,
                            math.random(-2, 2) * 0.02,
                            math.random(-2, 2) * 0.02
                        )
                        table.insert(pellets, {
                            [1] = {
                                Instance = hitPart,
                                Normal = Vector3.new(0, 1, 0),
                                Position = targetPos + spreadOffset
                            }
                        })
                    end
                    args[5] = pellets
                else
                    args[4] = CFrame.new(originPos, targetPos)
                    args[5] = {
                        [1] = {
                            [1] = {
                                Instance = hitPart,
                                Normal = Vector3.new(0, 1, 0),
                                Position = targetPos
                            }
                        }
                    }
                end

                pcall(function()
                    local tracerPart = Instance.new("Part")
                    tracerPart.Anchored = true
                    tracerPart.CanCollide = false
                    tracerPart.Size = Vector3.new(0.08, 0.08, (targetPos - originPos).Magnitude)
                    tracerPart.CFrame = CFrame.new(originPos, targetPos) * CFrame.new(0, 0, -tracerPart.Size.Z / 2)
                    tracerPart.Material = Enum.Material.Neon
                    tracerPart.Transparency = 0.35
                    tracerPart.Color = ThemeColor
                    tracerPart.Parent = workspace
                    Debris:AddItem(tracerPart, 4)

                    local currentHealth = hum and hum.Health or 100
                    task.spawn(function()
                        task.wait(0.08)
                        if hum and hum.Health < currentHealth then
                            if tracerPart and tracerPart.Parent then
                                tracerPart.Color = Color3.fromRGB(0, 255, 0)
                            end
                            for _, descendant in ipairs(targetChar:GetDescendants()) do
                                if descendant:IsA("BasePart") then
                                    local glowPart = Instance.new("Part")
                                    glowPart.Size = descendant.Size + Vector3.new(0.05, 0.05, 0.05)
                                    glowPart.CFrame = descendant.CFrame
                                    glowPart.Anchored = true
                                    glowPart.CanCollide = false
                                    glowPart.Material = Enum.Material.Neon
                                    glowPart.Color = Color3.fromRGB(0, 255, 0)
                                    glowPart.Transparency = 0.5
                                    glowPart.Parent = workspace
                                    TweenService:Create(glowPart, TweenInfo.new(1.2, Enum.EasingStyle.Linear), {Transparency = 1}):Play()
                                    Debris:AddItem(glowPart, 1.5)
                                end
                            end
                        end
                    end)
                end)
            end
        end
        return originalFireServer(self, unpack(args))
    end)
end

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char then
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if head then
            for _, item in ipairs(head:GetChildren()) do
                if item:IsA("BillboardGui") and (item.Name:lower():find("punish") or item.Name:lower():find("blacklist") or item.Name:lower():find("warn") or item.Name:lower():find("stun")) then
                    item:Destroy()
                end
            end
        end

        if hum then
            if hum.PlatformStand then hum.PlatformStand = false end
            for _, attr in ipairs({"Blacklisted", "InBlacklist", "IsPunished", "Stunned", "CannotWalk", "NoJump"}) do
                if hum:GetAttribute(attr) then
                    hum:SetAttribute(attr, false)
                end
            end
        end
    end
end)

--========================================================--
-- GUN MODS & MELEE AURA
--========================================================--

local function isMeleeTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    if tool.Name == "Fists" then return true end
    if MeleeFolder and ThrowableFolder then
        if MeleeFolder:FindFirstChild(tool.Name) and not ThrowableFolder:FindFirstChild(tool.Name) then
            return true
        end
    end
    return false
end

local function isGunTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    return (GunsFolder and GunsFolder:FindFirstChild(tool.Name) ~= nil) or tool.Name:match("Gun") or tool:FindFirstChild("Handle")
end

local function applyGodGun(tool)
    if not tool or not isGunTool(tool) then return end
    pcall(function()
        tool:SetAttribute("fire_rate", FireRateVal)
        tool:SetAttribute("accuracy", AccuracyVal)
        tool:SetAttribute("Recoil", RecoilVal)
        tool:SetAttribute("recoil", RecoilVal)
        tool:SetAttribute("reload_time", ReloadVal)
        tool:SetAttribute("Durability", DurabilityVal)
        tool:SetAttribute("automatic", AutomaticVal)
        tool:SetAttribute("Spread", 0)
        tool:SetAttribute("spread", 0)
    end)
end

local function modifyFists(tool, state)
    if not tool then return end
    local attrs = tool:GetAttributes()
    local keys = {}
    for k in pairs(attrs) do table.insert(keys, k) end
    table.sort(keys)
    if #keys >= 7 then
        local k6, k7 = keys[6], keys[7]
        if state then
            if SavedMeleeAttributes[k6] == nil then SavedMeleeAttributes[k6] = tool:GetAttribute(k6) end
            if SavedMeleeAttributes[k7] == nil then SavedMeleeAttributes[k7] = tool:GetAttribute(k7) end
            tool:SetAttribute(k6, 360)
            tool:SetAttribute(k7, 20)
        else
            if SavedMeleeAttributes[k6] then tool:SetAttribute(k6, SavedMeleeAttributes[k6]) end
            if SavedMeleeAttributes[k7] then tool:SetAttribute(k7, SavedMeleeAttributes[k7]) end
        end
    end
end

local function updateMeleeTools()
    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not char or not backpack then return end
    for _, t in ipairs(char:GetChildren()) do
        if isMeleeTool(t) then modifyFists(t, MeleeAuraEnabled) end
    end
    for _, t in ipairs(backpack:GetChildren()) do
        if isMeleeTool(t) then modifyFists(t, MeleeAuraEnabled) end
    end
end

RunService.Heartbeat:Connect(function()
    if GunModsActive and LocalPlayer.Character then
        for _, t in ipairs(LocalPlayer.Character:GetChildren()) do
            if isGunTool(t) then applyGodGun(t) end
        end
    end
    if MeleeAuraEnabled then
        updateMeleeTools()
    end
end)

task.spawn(function()
    while true do
        task.wait(0.35)
        if AutoAttackEnabled and LocalPlayer.Character and SendRemote then
            local char = LocalPlayer.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local tool = char:FindFirstChildOfClass("Tool")
            if root and tool and isMeleeTool(tool) then
                local targets = {}
                local positions = {}
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        local eHead = pl.Character:FindFirstChild("Head") or pl.Character:FindFirstChild("UpperTorso") or pl.Character:FindFirstChild("Torso")
                        local eRoot = pl.Character.HumanoidRootPart
                        if eHead and eRoot then
                            local dist = (eRoot.Position - root.Position).Magnitude
                            if dist <= 20 then
                                table.insert(targets, pl)
                                table.insert(positions, eHead.Position)
                            end
                        end
                    end
                end
                if #targets > 0 then
                    local lookCF = CFrame.lookAt(root.Position, positions[1])
                    FireServerHook("melee_attack", tool, targets, lookCF, 0.75)
                end
            end
        end
    end
end)

--========================================================--
-- VEHICLE MODS (CON BYPASS REAL DE FÍSICA PARA 5000)
--========================================================--

local function applyVehicleMods(model)
    if not model or not model:IsA("Model") then return end
    pcall(function()
        local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
        for _, desc in ipairs(model:GetDescendants()) do
            if desc:IsA("VehicleSeat") or desc:IsA("Seat") then
                if VehForwardMaxSpeed_Enabled then
                    desc.MaxSpeed = VehForwardMaxSpeed
                    if desc.ThrottleFloat > 0 and primary then
                        primary.AssemblyLinearVelocity = primary.CFrame.LookVector * VehForwardMaxSpeed
                    elseif desc.ThrottleFloat < 0 and primary then
                        primary.AssemblyLinearVelocity = -primary.CFrame.LookVector * VehReverseMaxSpeed
                    end
                end
                desc.SteerFloat = 1
                desc.TurnSpeed = 2.2
                pcall(function()
                    desc.Torque = 999999999
                end)
            end
            if desc:IsA("SpringConstraint") or desc:IsA("CylindricalConstraint") then
                if VehSuspension_Enabled then desc.FreeLength = VehSuspension end
                desc.Stiffness = 15000
            end
        end
        if VehAcceleration_Enabled then model:SetAttribute("Motors acceleration", VehAcceleration) end
        if VehBraking_Enabled then model:SetAttribute("Motors braking", VehBraking) end
        if VehDeceleration_Enabled then model:SetAttribute("Motors deceleration", VehDeceleration) end
        if VehForwardMaxSpeed_Enabled then model:SetAttribute("Motors forwardMaxSpeed", VehForwardMaxSpeed) end
        if VehReverseMaxSpeed_Enabled then model:SetAttribute("Motors reverseMaxSpeed", VehReverseMaxSpeed) end
    end)
end

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and hum.SeatPart then
        local veh = hum.SeatPart:FindFirstAncestorWhichIsA("Model")
        if veh then applyVehicleMods(veh) end
    end
end)

--========================================================--
-- SKIP CRATES & PROXIMITY PROMPTS
--========================================================--

task.spawn(function()
    local success, CrateController = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Game"):WaitForChild("CrateSystem"):WaitForChild("Crate"))
    end)
    
    if success and CrateController then
        while true do
            task.wait()
            if SkipCratesEnabled then
                pcall(function()
                    if CrateController.class and CrateController.class.objects then
                        for _, crate in pairs(CrateController.class.objects) do
                            if crate.states and crate.states.open and crate.states.open.set then
                                crate.states.open.set(true)
                            end
                            if CrateController.skipping and CrateController.skipping.set then
                                CrateController.skipping.set(true)
                            end
                        end
                    end
                    if CrateController.spinning and CrateController.skip_spin then
                        if not CrateController.spinning.get() then
                            CrateController.skip_spin()
                        end
                    end
                end)
            end
        end
    end
end)

ProximityPromptService.PromptShown:Connect(function(prompt)
    if AutoInteractEnabled and prompt and prompt.Enabled then
        task.spawn(function()
            pcall(function()
                if fireproximityprompt then
                    fireproximityprompt(prompt, 0)
                else
                    prompt:InputHoldBegin()
                    task.wait(prompt.HoldDuration or 0)
                    prompt:InputHoldEnd()
                end
            end)
        end)
    end
end)

--========================================================--
-- STAMINA & JUMP
--========================================================--

local function toggleInfStamina(enable)
    InfStaminaEnabled = enable
    pcall(function()
        local success, sprintModule = pcall(function()
            return require(ReplicatedStorage.Modules.Game.Sprint)
        end)
        if success and sprintModule then
            local consumeFunc = sprintModule.consume_stamina
            local upvalues = getupvalues(consumeFunc)
            local sprintBar
            for _, uv in ipairs(upvalues) do
                if type(uv) == "table" and rawget(uv, "sprint_bar") then
                    sprintBar = uv.sprint_bar
                    break
                end
            end
            
            if sprintBar then
                if enable then
                    local originalUpdate = sprintBar.update
                    sprintBar.update = function(...)
                        return originalUpdate(function() return 1 end)
                    end
                    OriginalSprintUpdate = originalUpdate
                    AutoSprintLoop = task.spawn(function()
                        while InfStaminaEnabled do
                            pcall(function()
                                FireServerHook("set_sprinting_1", true)
                                task.wait(0.5)
                                FireServerHook("set_sprinting_1", false)
                            end)
                            task.wait(0.1)
                        end
                        pcall(function() FireServerHook("set_sprinting_1", false) end)
                    end)
                else
                    if AutoSprintLoop then
                        task.cancel(AutoSprintLoop)
                        AutoSprintLoop = nil
                    end
                    pcall(function() FireServerHook("set_sprinting_1", false) end)
                    if OriginalSprintUpdate and sprintBar then
                        sprintBar.update = OriginalSprintUpdate
                        OriginalSprintUpdate = nil
                    end
                end
            end
        end
    end)
end

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, JumpPowerBypassValue, root.AssemblyLinearVelocity.Z)
            end
        end)
    end
end)

--========================================================--
-- AUTO-PICKUP & ANTI-KILL
--========================================================--

local al_pickup_cache = {}
RunService.RenderStepped:Connect(function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if AutoPickupEnabled and DroppedItems and myRoot then
        local currentTime = tick()
        for _, model in ipairs(DroppedItems:GetChildren()) do
            if model:IsA("Model") then
                local part = model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("PickUpZone")
                if part then
                    local dist = (part.Position - myRoot.Position).Magnitude
                    if dist <= AutoPickupRadius and (currentTime - (al_pickup_cache[model] or 0)) >= 0.20 then
                        al_pickup_cache[model] = currentTime
                        InvokeServerHook("pickup_dropped_item", model)
                    end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if AutoSafeDamageEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and root then
            if hum.Health > 0 then
                if hum.Health <= 30 and not AutoSafeActive then
                    AutoSafeActive = true
                    SavedAutoSafeY = root.Position.Y
                    TargetAutoSafeY = SavedAutoSafeY - AutoSafeDepth
                    FrozenCameraCFrame = Camera.CFrame
                end
                
                if AutoSafeActive then
                    if TargetAutoSafeY then
                        local offsetX = math.sin(os.clock() * 35) * 3.5
                        local offsetZ = math.cos(os.clock() * 35) * 3.5
                        root.CFrame = CFrame.new(root.Position.X + offsetX, TargetAutoSafeY, root.Position.Z + offsetZ)
                        root.Velocity = Vector3.zero
                    end
                    
                    if FrozenCameraCFrame then
                        Camera.CFrame = FrozenCameraCFrame
                    end
                    
                    if hum.Health >= 40 then
                        AutoSafeActive = false
                        if SavedAutoSafeY then
                            root.CFrame = CFrame.new(root.Position.X, SavedAutoSafeY + 1.5, root.Position.Z)
                        end
                        TargetAutoSafeY = nil
                        SavedAutoSafeY = nil
                        FrozenCameraCFrame = nil
                    end
                end
            else
                AutoSafeActive = false
                TargetAutoSafeY = nil
                SavedAutoSafeY = nil
                FrozenCameraCFrame = nil
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    AutoSafeActive = false
    TargetAutoSafeY = nil
    SavedAutoSafeY = nil
    FrozenCameraCFrame = nil
end)

--========================================================--
-- POTATO BOOST (200 FPS)
--========================================================--

local function togglePotatoGraphics(enable)
    PotatoBoostEnabled = enable
    pcall(function()
        if setfpscap then
            setfpscap(enable and 200 or 60)
        end
        if enable then
            Camera.FieldOfView = 96
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.Brightness = 1.8

            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("SunRaysEffect") or effect:IsA("DepthOfFieldEffect") then
                    effect.Enabled = false
                end
            end

            for _, desc in ipairs(workspace:GetDescendants()) do
                if desc:IsA("BasePart") and not desc.Parent:FindFirstChildOfClass("Humanoid") then
                    desc.Material = Enum.Material.SmoothPlastic
                    desc.Reflectance = 0
                elseif desc:IsA("Decal") or desc:IsA("Texture") then
                    desc.Transparency = 0.5
                elseif desc:IsA("ParticleEmitter") or desc:IsA("Trail") or desc:IsA("Smoke") or desc:IsA("Fire") then
                    desc.Enabled = false
                end
            end
        else
            Camera.FieldOfView = OriginalCameraFOV or 70
            Lighting.GlobalShadows = true
            Lighting.Brightness = 2.0

            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("PostEffect") then effect.Enabled = true end
            end
        end
    end)
end

--========================================================--
-- ESP MOTOR
--========================================================--

local function removePlayerESP(pl)
    if PlayerBillboards[pl] then
        if PlayerBillboards[pl].Billboard then pcall(function() PlayerBillboards[pl].Billboard:Destroy() end) end
        PlayerBillboards[pl] = nil
    end
    if HighlightCache[pl] then
        pcall(function() HighlightCache[pl]:Destroy() end)
        HighlightCache[pl] = nil
    end
    if WeaponBillboardCache[pl] then 
        pcall(function() WeaponBillboardCache[pl]:Destroy() end)
        WeaponBillboardCache[pl] = nil 
    end
    WeaponCacheTokens[pl] = nil
    RemoveVisualPlayerObjects(pl)
end
Players.PlayerRemoving:Connect(removePlayerESP)

local function ensurePlayerESP(pl)
    if pl == LocalPlayer then return end
    local char = pl.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not head or not root or not hum then return end

    if not PlayerBillboards[pl] or not PlayerBillboards[pl].Billboard or not PlayerBillboards[pl].Billboard.Parent or PlayerBillboards[pl].Billboard.Adornee ~= head then
        if PlayerBillboards[pl] and PlayerBillboards[pl].Billboard then
            pcall(function() PlayerBillboards[pl].Billboard:Destroy() end)
        end

        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_" .. pl.Name
        bb.Adornee = head
        bb.Size = UDim2.new(0, 160, 0, 60)
        bb.StudsOffset = Vector3.new(0, 2.2, 0)
        bb.AlwaysOnTop = true
        bb.Parent = CoreGui

        local container = Instance.new("Frame", bb)
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1

        local nameLabel = Instance.new("TextLabel", container)
        nameLabel.Size = UDim2.new(1, 0, 0, 16)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = pl.Name
        nameLabel.TextColor3 = ThemeColor
        nameLabel.TextSize = 13
        nameLabel.Font = Enum.Font.GothamMedium

        local hpBg = Instance.new("Frame", container)
        hpBg.Size = UDim2.new(0, 75, 0, 4)
        hpBg.Position = UDim2.new(0.5, -37, 0, 18)
        hpBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        hpBg.BorderSizePixel = 0
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)

        local hpFill = Instance.new("Frame", hpBg)
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BackgroundColor3 = ThemeColor
        hpFill.BorderSizePixel = 0
        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)

        local distLabel = Instance.new("TextLabel", container)
        distLabel.Size = UDim2.new(1, 0, 0, 14)
        distLabel.Position = UDim2.new(0, 0, 0, 24)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = ""
        distLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
        distLabel.TextSize = 11
        distLabel.Font = Enum.Font.GothamMedium

        PlayerBillboards[pl] = { Billboard = bb, Name = nameLabel, HpBg = hpBg, HpFill = hpFill, Dist = distLabel, Humanoid = hum, Root = root }
    end
end

task.spawn(function()
    while true do
        task.wait(0.3)
        if WeaponESPEnabled then
            for _, pl in ipairs(Players:GetPlayers()) do
                if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    local char = pl.Character
                    local root = char.HumanoidRootPart
                    local tools = {}
                    local token = ""
                    local bp = pl:FindFirstChild("Backpack")
                    if bp then
                        for _, t in ipairs(bp:GetChildren()) do 
                            if t:IsA("Tool") and t.Name ~= "Fists" then 
                                table.insert(tools, t) 
                                token = token .. t.Name .. "_"
                            end 
                        end
                    end
                    for _, t in ipairs(char:GetChildren()) do 
                        if t:IsA("Tool") and t.Name ~= "Fists" then 
                            table.insert(tools, t) 
                            token = token .. t.Name .. "_E_"
                        end 
                    end
                    
                    local bg = WeaponBillboardCache[pl]
                    if not bg or not bg.Parent or bg.Adornee ~= root then
                        if bg then pcall(function() bg:Destroy() end) end
                        bg = Instance.new("BillboardGui")
                        bg.Name = "WeaponESP_" .. pl.Name
                        bg.Adornee = root
                        bg.Size = UDim2.new(0, 140, 0, 24)
                        bg.StudsOffset = Vector3.new(0, -4, 0)
                        bg.AlwaysOnTop = true
                        bg.Parent = CoreGui
                        
                        local layout = Instance.new("UIListLayout", bg)
                        layout.FillDirection = Enum.FillDirection.Horizontal
                        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout.Padding = UDim.new(0, 4)
                        
                        WeaponBillboardCache[pl] = bg
                        WeaponCacheTokens[pl] = nil
                    end

                    if WeaponCacheTokens[pl] ~= token then
                        WeaponCacheTokens[pl] = token
                        bg:ClearAllChildren()
                        local layout = Instance.new("UIListLayout", bg)
                        layout.FillDirection = Enum.FillDirection.Horizontal
                        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout.Padding = UDim.new(0, 4)
                        
                        for _, t in ipairs(tools) do
                            local info = getWeaponData(t)
                            if info then
                                local icon = Instance.new("ImageLabel", bg)
                                icon.Size = UDim2.new(0, 22, 0, 22)
                                icon.BackgroundTransparency = 0.2
                                icon.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
                                icon.Image = info.ImageId
                                Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 6)
                                local stroke = Instance.new("UIStroke", icon)
                                stroke.Color = RarityColors[info.Rarity] or Color3.fromRGB(255, 255, 255)
                                stroke.Thickness = 1.5
                            end
                        end
                    end
                end
            end
        else
            for _, bg in pairs(WeaponBillboardCache) do bg:Destroy() end
            WeaponBillboardCache = {}
            WeaponCacheTokens = {}
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if ItemESPEnabled and DroppedItems and myRoot then
        local closestPerName = {}
        for _, model in ipairs(DroppedItems:GetChildren()) do
            if model:IsA("Model") and model:FindFirstChild("PickUpZone") then
                local zone = model.PickUpZone
                local dist = (zone.Position - myRoot.Position).Magnitude
                local itemName = model.Name
                if not closestPerName[itemName] or dist < closestPerName[itemName].dist then
                    closestPerName[itemName] = {model = model, dist = dist, zone = zone}
                end
            end
        end

        for _, data in pairs(ItemDrawingsCache) do
            if data.Billboard then data.Billboard.Enabled = false end
            if data.Highlight then data.Highlight.Enabled = false end
        end

        for name, info in pairs(closestPerName) do
            local model = info.model
            local zone = info.zone
            local dist = info.dist
            local itemData = ItemDrawingsCache[model]
            if not itemData then
                local bb = Instance.new("BillboardGui")
                bb.Name = "ItemESP_" .. name
                bb.Adornee = zone
                bb.Size = UDim2.new(0, 120, 0, 35)
                bb.StudsOffset = Vector3.new(0, 1.5, 0)
                bb.AlwaysOnTop = true
                bb.Parent = CoreGui

                local label = Instance.new("TextLabel", bb)
                label.Size = UDim2.new(1, 0, 0, 18)
                label.BackgroundTransparency = 1
                label.Text = name
                label.TextColor3 = RarityColors[model:GetAttribute("RarityName")] or Color3.fromRGB(255, 255, 255)
                label.TextStrokeTransparency = 0.2
                label.TextSize = 12
                label.Font = Enum.Font.GothamMedium

                local distLbl = Instance.new("TextLabel", bb)
                distLbl.Name = "DistLbl"
                distLbl.Size = UDim2.new(1, 0, 0, 16)
                distLbl.Position = UDim2.new(0, 0, 0, 16)
                distLbl.BackgroundTransparency = 1
                distLbl.TextColor3 = Color3.fromRGB(230, 230, 240)
                distLbl.TextSize = 11
                distLbl.Font = Enum.Font.GothamMedium

                local hl = Instance.new("Highlight")
                hl.Adornee = model
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency = 0.6
                hl.OutlineTransparency = 0.2
                hl.FillColor = label.TextColor3
                hl.Parent = CoreGui
                
                itemData = {Billboard = bb, DistLabel = distLbl, Highlight = hl}
                ItemDrawingsCache[model] = itemData
            end
            if dist <= 300 then
                itemData.Billboard.Enabled = true
                itemData.Highlight.Enabled = true
                if itemData.DistLabel then
                    itemData.DistLabel.Text = string.format("%.0f m", dist * 0.28)
                end
            end
        end
    else
        for _, v in pairs(ItemDrawingsCache) do
            if v.Billboard then v.Billboard.Enabled = false end
            if v.Highlight then v.Highlight.Enabled = false end
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    local bestTarget = GetBestVisualTarget()
    CurrentLockedTarget = (SilentAimEnabled or SettingsVisual.TargetLine) and bestTarget or nil

    if SettingsVisual.TargetLine then
        CurrentTarget = bestTarget
    else
        CurrentTarget = nil
    end

    if SettingsVisual.FOV and HasEnteredPanel then
        FOVCircle.Visible = true
        FOVStroke.Color = ThemeColor
        FOVTime = FOVTime + dt * SettingsVisual.FOVSpeed
        local wave = (math.sin(FOVTime) + 1) / 2
        local radius = SettingsVisual.FOVMin + (SettingsVisual.FOVMax - SettingsVisual.FOVMin) * wave
        FOVCircle.Size = UDim2.fromOffset(radius * 2, radius * 2)
    else
        FOVCircle.Visible = false
    end

    UpdateTargetLine()

    if FloatingSnapActive and FloatingTargetY and LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = CFrame.new(root.Position.X, FloatingTargetY, root.Position.Z)
            root.Velocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end

    if SpeedHackEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            local move = hum.MoveDirection.Unit * ((SpeedValue / 20) * 26 * dt)
            root.CFrame = root.CFrame + Vector3.new(move.X, 0, move.Z)
        end
    end

    if HeadHidingAntiAim and LocalPlayer.Character then
        local neck = LocalPlayer.Character:FindFirstChild("Neck", true)
        if neck then neck.C0 = CFrame.new(0, -1.8, 0.2) * CFrame.Angles(math.rad(-85), 0, 0) end
    end

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then
            local char = pl.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChild("Humanoid")

            if char and root and hum then
                ensurePlayerESP(pl)
                local data = PlayerBillboards[pl]

                if data and data.Billboard and data.Billboard.Parent then
                    local dist = myRoot and (root.Position - myRoot.Position).Magnitude or 0
                    data.Name.Visible = PlayerESP_Name
                    data.Name.TextColor3 = ThemeColor

                    if PlayerESP_Health then
                        local pct = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                        data.HpBg.Visible = true
                        data.HpFill.Size = UDim2.new(pct, 0, 1, 0)
                        data.HpFill.BackgroundColor3 = ThemeColor
                    else
                        data.HpBg.Visible = false
                    end

                    data.Dist.Visible = PlayerESP_Dist
                    if PlayerESP_Dist then
                        data.Dist.Text = string.format("%.0f m", dist * 0.28)
                    end
                end

                if CurrentLockedTarget == pl then
                    local hl = HighlightCache[pl]
                    if not hl or not hl.Parent or hl.Adornee ~= char then
                        if hl then pcall(function() hl:Destroy() end) end
                        hl = Instance.new("Highlight")
                        hl.Name = "FOVDestroyerHighlight_" .. pl.Name
                        hl.Adornee = char
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.FillColor = Color3.fromRGB(255, 50, 50)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.4
                        hl.OutlineTransparency = 0.1
                        hl.Parent = CoreGui
                        HighlightCache[pl] = hl
                    else
                        hl.Enabled = true
                        hl.FillColor = Color3.fromRGB(255, 50, 50)
                    end
                elseif HighlightCache[pl] then
                    HighlightCache[pl].Enabled = false
                end
            else
                if PlayerBillboards[pl] and PlayerBillboards[pl].Billboard then
                    PlayerBillboards[pl].Name.Visible = false
                    PlayerBillboards[pl].HpBg.Visible = false
                    PlayerBillboards[pl].Dist.Visible = false
                end
                if HighlightCache[pl] then HighlightCache[pl].Enabled = false end
            end
        end
    end

    for player, data in pairs(VisualPlayerObjects) do
        local character = player.Character
        if not character then
            data.Box.Visible = false
            data.Line.Visible = false
            continue
        end

        local root = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")

        if not root or not head then
            data.Box.Visible = false
            data.Line.Visible = false
            continue
        end

        data.Box.Adornee = character
        data.Box.Color3 = ThemeColor
        data.Box.Visible = SettingsVisual.Box

        if SettingsVisual.Lines then
            local headPosition, visible = Camera:WorldToViewportPoint(head.Position)
            if visible and headPosition.Z > 0 then
                local enemyHead = Vector2.new(headPosition.X, headPosition.Y)
                local lineStart = Vector2.new(Camera.ViewportSize.X / 2, SettingsVisual.LineOriginY)
                local lineTarget = Vector2.new(enemyHead.X, enemyHead.Y + SettingsVisual.LineTargetOffset)
                local difference = lineTarget - lineStart
                local length = difference.Magnitude

                if length > 0 then
                    data.Line.BackgroundColor3 = ThemeColor
                    data.Line.Position = UDim2.fromOffset((lineStart.X + lineTarget.X) / 2, (lineStart.Y + lineTarget.Y) / 2)
                    data.Line.Size = UDim2.fromOffset(length, 1)
                    data.Line.Rotation = math.deg(math.atan2(difference.Y, difference.X))
                    data.Line.Visible = true
                else
                    data.Line.Visible = false
                end
            else
                data.Line.Visible = false
            end
        else
            data.Line.Visible = false
        end
    end
end)

local function UpdateSystemTheme(newColor)
    ThemeColor = newColor
    FOVStroke.Color = newColor

    for _, item in ipairs(DynamicColorElements) do
        if item.Type == "Stroke" then
            item.Element.Color = newColor
        elseif item.Type == "Background" then
            item.Element.BackgroundColor3 = newColor
        elseif item.Type == "Text" then
            item.Element.TextColor3 = newColor
        elseif item.Type == "Toggle" and item.State() then
            item.Element.BackgroundColor3 = newColor
        end
    end

    for _, obj in pairs(VisualPlayerObjects) do
        if obj.Box then obj.Box.Color3 = newColor end
        if obj.Line then obj.Line.BackgroundColor3 = newColor end
    end

    for _, orb in ipairs(RegisteredOrbs) do
        TweenService:Create(orb.Glow, TweenInfo.new(0.4), {BackgroundColor3 = newColor}):Play()
        TweenService:Create(orb.Core, TweenInfo.new(0.4), {BackgroundColor3 = newColor}):Play()
    end

    if AstralOrb then AstralOrb.Color = newColor end
end

--========================================================--
-- PANEL TÁCTIL TP
--========================================================--

local FloatingSnapGui = Instance.new("ScreenGui")
FloatingSnapGui.Name = "FloatingSnapGui"
FloatingSnapGui.ResetOnSpawn = false
FloatingSnapGui.Enabled = false
FloatingSnapGui.Parent = CoreGui

local TouchSnapFrame = Instance.new("Frame", FloatingSnapGui)
TouchSnapFrame.Size = UDim2.new(0, 130, 0, 128)
TouchSnapFrame.Position = UDim2.new(0.04, 0, 0.45, 0)
TouchSnapFrame.BackgroundColor3 = Color3.fromRGB(20, 18, 28)
TouchSnapFrame.BackgroundTransparency = 0.1
TouchSnapFrame.BorderSizePixel = 0
TouchSnapFrame.Active = true
TouchSnapFrame.Draggable = true
Instance.new("UICorner", TouchSnapFrame).CornerRadius = UDim.new(0, 16)
AttachSnowEffect(TouchSnapFrame)

local touchStroke = Instance.new("UIStroke", TouchSnapFrame)
touchStroke.Color = ThemeColor
touchStroke.Thickness = 1.3
table.insert(DynamicColorElements, {Type = "Stroke", Element = touchStroke})

local btnTouchTP = Instance.new("TextButton", TouchSnapFrame)
btnTouchTP.Size = UDim2.new(0, 78, 0, 26)
btnTouchTP.Position = UDim2.new(0, 8, 0, 8)
btnTouchTP.BackgroundColor3 = Color3.fromRGB(28, 25, 38)
btnTouchTP.BackgroundTransparency = 0.2
btnTouchTP.BorderSizePixel = 0
btnTouchTP.Text = "TP"
btnTouchTP.TextColor3 = Color3.fromRGB(255, 255, 255)
btnTouchTP.TextSize = 11
btnTouchTP.Font = Enum.Font.GothamMedium
btnTouchTP.ZIndex = 2
Instance.new("UICorner", btnTouchTP).CornerRadius = UDim.new(0, 6)

local btnLock = Instance.new("TextButton", TouchSnapFrame)
btnLock.Size = UDim2.new(0, 26, 0, 26)
btnLock.Position = UDim2.new(1, -34, 0, 8)
btnLock.BackgroundColor3 = Color3.fromRGB(28, 25, 38)
btnLock.BorderSizePixel = 0
btnLock.Text = "🔓"
btnLock.TextColor3 = Color3.fromRGB(255, 255, 255)
btnLock.TextSize = 11
btnLock.ZIndex = 2
Instance.new("UICorner", btnLock).CornerRadius = UDim.new(0, 6)

local isPanelLocked = false
btnLock.MouseButton1Click:Connect(function()
    isPanelLocked = not isPanelLocked
    TouchSnapFrame.Draggable = not isPanelLocked
    btnLock.Text = isPanelLocked and "🔒" or "🔓"
    btnLock.BackgroundColor3 = isPanelLocked and Color3.fromRGB(200, 20, 30) or Color3.fromRGB(28, 25, 38)
end)

local function triggerTouchTP()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if not FloatingSnapActive then
        FloatingSavedSurfaceY = root.Position.Y
        FloatingTargetY = FloatingSavedSurfaceY - FloatingSnapDepth
        FloatingSnapActive = true
        root.CFrame = CFrame.new(root.Position.X, FloatingTargetY, root.Position.Z)
        btnTouchTP.Text = "SUBIR"
        btnTouchTP.BackgroundColor3 = Color3.fromRGB(200, 25, 45)
    else
        FloatingSnapActive = false
        if FloatingSavedSurfaceY then root.CFrame = CFrame.new(root.Position.X, FloatingSavedSurfaceY + 1.5, root.Position.Z) end
        FloatingTargetY = nil
        FloatingSavedSurfaceY = nil
        btnTouchTP.Text = "TP"
        btnTouchTP.BackgroundColor3 = Color3.fromRGB(28, 25, 38)
    end
end
btnTouchTP.MouseButton1Click:Connect(triggerTouchTP)

local fsInput = Instance.new("TextBox", TouchSnapFrame)
fsInput.Size = UDim2.new(1, -16, 0, 20)
fsInput.Position = UDim2.new(0, 8, 0, 40)
fsInput.BackgroundTransparency = 0.5
fsInput.BackgroundColor3 = Color3.fromRGB(14, 12, 21)
fsInput.Text = tostring(FloatingSnapDepth) .. "m ✎"
fsInput.TextColor3 = Color3.fromRGB(255, 255, 255)
fsInput.TextSize = 11
fsInput.Font = Enum.Font.GothamMedium
fsInput.ZIndex = 2
Instance.new("UICorner", fsInput).CornerRadius = UDim.new(0, 6)

fsInput.Focused:Connect(function() fsInput.Text = "" end)

local fsBar = Instance.new("Frame", TouchSnapFrame)
fsBar.Size = UDim2.new(1, -16, 0, 10)
fsBar.Position = UDim2.new(0, 8, 0, 68)
fsBar.BackgroundColor3 = Color3.fromRGB(30, 28, 42)
fsBar.ZIndex = 2
Instance.new("UICorner", fsBar).CornerRadius = UDim.new(1, 0)

local fsFill = Instance.new("Frame", fsBar)
fsFill.Size = UDim2.new((FloatingSnapDepth - 5) / 95, 0, 1, 0)
fsFill.BackgroundColor3 = ThemeColor
fsFill.ZIndex = 2
Instance.new("UICorner", fsFill).CornerRadius = UDim.new(1, 0)
table.insert(DynamicColorElements, {Type = "Background", Element = fsFill})

local fsDot = Instance.new("Frame", fsFill)
fsDot.Size = UDim2.new(0, 18, 0, 18)
fsDot.Position = UDim2.new(1, -8, 0.5, -8)
fsDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fsDot.BorderSizePixel = 0
fsDot.ZIndex = 3
Instance.new("UICorner", fsDot).CornerRadius = UDim.new(1, 0)

local fsHitboxPadding = Instance.new("TextButton", fsDot)
fsHitboxPadding.Size = UDim2.new(0, 42, 0, 42)
fsHitboxPadding.Position = UDim2.new(0.5, -21, 0.5, -21)
fsHitboxPadding.BackgroundTransparency = 1
fsHitboxPadding.Text = ""
fsHitboxPadding.ZIndex = 4

local function setDepth(val)
    FloatingSnapDepth = math.clamp(val, 5, 100)
    fsInput.Text = tostring(FloatingSnapDepth) .. "m ✎"
    fsFill.Size = UDim2.new((FloatingSnapDepth - 5) / 95, 0, 1, 0)
    if FloatingSnapActive and FloatingSavedSurfaceY then
        FloatingTargetY = FloatingSavedSurfaceY - FloatingSnapDepth
    end
end

fsInput.FocusLost:Connect(function()
    local num = tonumber(fsInput.Text:match("%d+"))
    if num then setDepth(num) else fsInput.Text = tostring(FloatingSnapDepth) .. "m ✎" end
end)

local isDraggingDepth = false
local function handleDepthInput(input)
    local pos = math.clamp((input.Position.X - fsBar.AbsolutePosition.X) / fsBar.AbsoluteSize.X, 0, 1)
    setDepth(math.floor(5 + (95 * pos)))
end

fsBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingDepth = true
        handleDepthInput(input)
    end
end)

fsHitboxPadding.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingDepth = true
        handleDepthInput(input)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingDepth = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDraggingDepth and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        handleDepthInput(input)
    end
end)

local tpKeyBox = Instance.new("TextBox", TouchSnapFrame)
tpKeyBox.Size = UDim2.new(1, -16, 0, 20)
tpKeyBox.Position = UDim2.new(0, 8, 1, -26)
tpKeyBox.BackgroundColor3 = Color3.fromRGB(14, 12, 21)
tpKeyBox.BackgroundTransparency = 0.4
tpKeyBox.Text = "Key: E"
tpKeyBox.TextColor3 = Color3.fromRGB(180, 180, 200)
tpKeyBox.TextSize = 10
tpKeyBox.Font = Enum.Font.GothamMedium
tpKeyBox.ZIndex = 2
Instance.new("UICorner", tpKeyBox).CornerRadius = UDim.new(0, 6)

local selectedTPKey = Enum.KeyCode.E
tpKeyBox.Focused:Connect(function() tpKeyBox.Text = "..." end)
tpKeyBox.FocusLost:Connect(function() tpKeyBox.Text = "Key: " .. tostring(selectedTPKey.Name) end)

UserInputService.InputBegan:Connect(function(input, gp)
    if tpKeyBox:IsFocused() and input.UserInputType == Enum.UserInputType.Keyboard then
        selectedTPKey = input.KeyCode
        tpKeyBox:ReleaseFocus()
    elseif not gp and input.KeyCode == selectedTPKey then
        triggerTouchTP()
    end
end)

--========================================================--
-- GHOST ASTRAL
--========================================================--

local AstralProjectionGui = Instance.new("ScreenGui")
AstralProjectionGui.Name = "AstralProjectionGui"
AstralProjectionGui.ResetOnSpawn = false
AstralProjectionGui.Enabled = false
AstralProjectionGui.Parent = CoreGui

local AstralSwitchCard = Instance.new("Frame", AstralProjectionGui)
AstralSwitchCard.Size = UDim2.new(0, 120, 0, 70)
AstralSwitchCard.Position = UDim2.new(0.04, 0, 0.62, 0)
AstralSwitchCard.BackgroundColor3 = Color3.fromRGB(20, 18, 28)
AstralSwitchCard.BackgroundTransparency = 0.1
AstralSwitchCard.BorderSizePixel = 0
AstralSwitchCard.Active = true
AstralSwitchCard.Draggable = true
Instance.new("UICorner", AstralSwitchCard).CornerRadius = UDim.new(0, 16)
AttachSnowEffect(AstralSwitchCard)

local astralStroke = Instance.new("UIStroke", AstralSwitchCard)
astralStroke.Color = ThemeColor
astralStroke.Thickness = 1.3
table.insert(DynamicColorElements, {Type = "Stroke", Element = astralStroke})

local AstralLabel = Instance.new("TextLabel", AstralSwitchCard)
AstralLabel.Size = UDim2.new(1, -55, 0, 36)
AstralLabel.Position = UDim2.new(0, 10, 0, 2)
AstralLabel.BackgroundTransparency = 1
AstralLabel.Text = "Ghost"
AstralLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
AstralLabel.TextSize = 12
AstralLabel.Font = Enum.Font.GothamMedium
AstralLabel.TextXAlignment = Enum.TextXAlignment.Left
AstralLabel.ZIndex = 2

local SwitchBg = Instance.new("Frame", AstralSwitchCard)
SwitchBg.Size = UDim2.new(0, 36, 0, 20)
SwitchBg.Position = UDim2.new(1, -44, 0, 10)
SwitchBg.BackgroundColor3 = Color3.fromRGB(35, 32, 45)
SwitchBg.ZIndex = 2
Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)

local SwitchThumb = Instance.new("Frame", SwitchBg)
SwitchThumb.Size = UDim2.new(0, 16, 0, 16)
SwitchThumb.Position = UDim2.new(0, 2, 0.5, -8)
SwitchThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SwitchThumb.ZIndex = 3
Instance.new("UICorner", SwitchThumb).CornerRadius = UDim.new(1, 0)

local SwitchBtn = Instance.new("TextButton", SwitchBg)
SwitchBtn.Size = UDim2.new(1, 0, 1, 0)
SwitchBtn.BackgroundTransparency = 1
SwitchBtn.Text = ""
SwitchBtn.ZIndex = 4

local ghostKeyBox = Instance.new("TextBox", AstralSwitchCard)
ghostKeyBox.Size = UDim2.new(1, -16, 0, 20)
ghostKeyBox.Position = UDim2.new(0, 8, 1, -26)
ghostKeyBox.BackgroundColor3 = Color3.fromRGB(14, 12, 21)
ghostKeyBox.BackgroundTransparency = 0.4
ghostKeyBox.Text = "Key: Q"
ghostKeyBox.TextColor3 = Color3.fromRGB(180, 180, 200)
ghostKeyBox.TextSize = 10
ghostKeyBox.Font = Enum.Font.GothamMedium
ghostKeyBox.ZIndex = 2
Instance.new("UICorner", ghostKeyBox).CornerRadius = UDim.new(0, 6)

local selectedGhostKey = Enum.KeyCode.Q
ghostKeyBox.Focused:Connect(function() ghostKeyBox.Text = "..." end)
ghostKeyBox.FocusLost:Connect(function() ghostKeyBox.Text = "Key: " .. tostring(selectedGhostKey.Name) end)

local function toggleAstralProjection(enable)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    AstralActive = enable
    if enable then
        FrozenCharCF = root.CFrame
        root.Anchored = true

        AstralOrb = Instance.new("Part")
        AstralOrb.Name = "AstralOrb_Ghost"
        AstralOrb.Shape = Enum.PartType.Ball
        AstralOrb.Size = Vector3.new(1.8, 1.8, 1.8)
        AstralOrb.Material = Enum.Material.Neon
        AstralOrb.Color = ThemeColor
        AstralOrb.Transparency = 0.35
        AstralOrb.CanCollide = false
        AstralOrb.Anchored = true
        AstralOrb.CFrame = root.CFrame
        AstralOrb.Parent = workspace

        local orbHL = Instance.new("Highlight", AstralOrb)
        orbHL.FillColor = ThemeColor
        orbHL.OutlineColor = Color3.fromRGB(255, 255, 255)
        orbHL.FillTransparency = 0.4

        Camera.CameraSubject = AstralOrb

        AstralConnection = RunService.RenderStepped:Connect(function(dt)
            if AstralOrb and AstralActive then
                local hum = char:FindFirstChild("Humanoid")
                if hum and hum.MoveDirection.Magnitude > 0 then
                    local move = hum.MoveDirection.Unit * (AstralSpeed * dt)
                    AstralOrb.CFrame = AstralOrb.CFrame + Vector3.new(move.X, 0, move.Z)
                end
            end
        end)
    else
        if AstralConnection then AstralConnection:Disconnect(); AstralConnection = nil end
        if AstralOrb then
            local finalPos = AstralOrb.Position
            root.Anchored = false
            root.CFrame = CFrame.new(finalPos) + Vector3.new(0, 2, 0)
            AstralOrb:Destroy()
            AstralOrb = nil
        else
            root.Anchored = false
        end
        if char:FindFirstChild("Humanoid") then
            Camera.CameraSubject = char.Humanoid
        end
    end
end

SwitchBtn.MouseButton1Click:Connect(function()
    local newState = not AstralActive
    if newState then playToggleSound() end
    TweenService:Create(SwitchBg, TweenInfo.new(0.2), {
        BackgroundColor3 = newState and ThemeColor or Color3.fromRGB(35, 32, 45)
    }):Play()
    TweenService:Create(SwitchThumb, TweenInfo.new(0.2), {
        Position = newState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    }):Play()
    toggleAstralProjection(newState)
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if ghostKeyBox:IsFocused() and input.UserInputType == Enum.UserInputType.Keyboard then
        selectedGhostKey = input.KeyCode
        ghostKeyBox:ReleaseFocus()
    elseif not gp and input.KeyCode == selectedGhostKey then
        local newState = not AstralActive
        if newState then playToggleSound() end
        TweenService:Create(SwitchBg, TweenInfo.new(0.2), {
            BackgroundColor3 = newState and ThemeColor or Color3.fromRGB(35, 32, 45)
        }):Play()
        TweenService:Create(SwitchThumb, TweenInfo.new(0.2), {
            Position = newState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        toggleAstralProjection(newState)
    end
end)

--========================================================--
-- PERSISTENCIA
--========================================================--

local function SaveConfigurationSafe()
    if not writefile then return false end
    local buffer = {
        "FOV=" .. (SettingsVisual.FOV and "1" or "0"),
        "Silent=" .. (SilentAimEnabled and "1" or "0"),
        "Jump=" .. (InfiniteJumpEnabled and "1" or "0"),
        "Stamina=" .. (InfStaminaEnabled and "1" or "0"),
        "Speed=" .. (SpeedHackEnabled and "1" or "0"),
        "SpeedVal=" .. tostring(SpeedValue),
        "Potato=" .. (PotatoBoostEnabled and "1" or "0"),
        "Crates=" .. (SkipCratesEnabled and "1" or "0"),
        "AutoKill=" .. (AutoSafeDamageEnabled and "1" or "0"),
        "ESP_Box=" .. (SettingsVisual.Box and "1" or "0"),
        "ESP_Line=" .. (SettingsVisual.Lines and "1" or "0"),
        "ESP_Name=" .. (PlayerESP_Name and "1" or "0"),
        "ESP_HP=" .. (PlayerESP_Health and "1" or "0"),
        "ESP_Dist=" .. (PlayerESP_Dist and "1" or "0"),
        "ESP_Wep=" .. (WeaponESPEnabled and "1" or "0"),
        "ESP_Item=" .. (ItemESPEnabled and "1" or "0"),
        "GunMods=" .. (GunModsActive and "1" or "0"),
        "Melee=" .. (MeleeAuraEnabled and "1" or "0"),
        "Pickup=" .. (AutoPickupEnabled and "1" or "0"),
        "Interact=" .. (AutoInteractEnabled and "1" or "0"),
        "V_Acc=" .. tostring(VehAcceleration),
        "V_Brk=" .. tostring(VehBraking),
        "V_Dec=" .. tostring(VehDeceleration),
        "V_Fwd=" .. tostring(VehForwardMaxSpeed),
        "V_Rev=" .. tostring(VehReverseMaxSpeed),
        "V_Sus=" .. tostring(VehSuspension),
        "V_Acc_E=" .. (VehAcceleration_Enabled and "1" or "0"),
        "V_Brk_E=" .. (VehBraking_Enabled and "1" or "0"),
        "V_Dec_E=" .. (VehDeceleration_Enabled and "1" or "0"),
        "V_Fwd_E=" .. (VehForwardMaxSpeed_Enabled and "1" or "0"),
        "V_Rev_E=" .. (VehReverseMaxSpeed_Enabled and "1" or "0"),
        "V_Sus_E=" .. (VehSuspension_Enabled and "1" or "0")
    }
    local content = table.concat(buffer, "\n")
    pcall(function() writefile(CFG_FILE, content) end)
    return true
end

local function LoadConfigurationSafe()
    if not (isfile and readfile) then return end
    local exists = false
    pcall(function() exists = isfile(CFG_FILE) end)
    if not exists then return end

    pcall(function()
        local content = readfile(CFG_FILE)
        for line in string.gmatch(content, "[^\r\n]+") do
            local key, val = string.match(line, "([^=]+)=(.*)")
            if key and val then
                if key == "FOV" then SettingsVisual.FOV = (val == "1")
                elseif key == "Silent" then SilentAimEnabled = (val == "1")
                elseif key == "Jump" then InfiniteJumpEnabled = (val == "1")
                elseif key == "Stamina" then if val == "1" then toggleInfStamina(true) end
                elseif key == "Speed" then SpeedHackEnabled = (val == "1")
                elseif key == "SpeedVal" then SpeedValue = tonumber(val) or SpeedValue
                elseif key == "Potato" then if val == "1" then togglePotatoGraphics(true) end
                elseif key == "Crates" then SkipCratesEnabled = (val == "1")
                elseif key == "AutoKill" then AutoSafeDamageEnabled = (val == "1")
                elseif key == "ESP_Box" then SettingsVisual.Box = (val == "1")
                elseif key == "ESP_Line" then SettingsVisual.Lines = (val == "1")
                elseif key == "ESP_Name" then PlayerESP_Name = (val == "1")
                elseif key == "ESP_HP" then PlayerESP_Health = (val == "1")
                elseif key == "ESP_Dist" then PlayerESP_Dist = (val == "1")
                elseif key == "ESP_Wep" then WeaponESPEnabled = (val == "1")
                elseif key == "ESP_Item" then ItemESPEnabled = (val == "1")
                elseif key == "GunMods" then GunModsActive = (val == "1")
                elseif key == "Melee" then MeleeAuraEnabled = (val == "1")
                elseif key == "Pickup" then AutoPickupEnabled = (val == "1")
                elseif key == "Interact" then AutoInteractEnabled = (val == "1")
                elseif key == "V_Acc" then VehAcceleration = tonumber(val) or VehAcceleration
                elseif key == "V_Brk" then VehBraking = tonumber(val) or VehBraking
                elseif key == "V_Dec" then VehDeceleration = tonumber(val) or VehDeceleration
                elseif key == "V_Fwd" then VehForwardMaxSpeed = tonumber(val) or VehForwardMaxSpeed
                elseif key == "V_Rev" then VehReverseMaxSpeed = tonumber(val) or VehReverseMaxSpeed
                elseif key == "V_Sus" then VehSuspension = tonumber(val) or VehSuspension
                elseif key == "V_Acc_E" then VehAcceleration_Enabled = (val == "1")
                elseif key == "V_Brk_E" then VehBraking_Enabled = (val == "1")
                elseif key == "V_Dec_E" then VehDeceleration_Enabled = (val == "1")
                elseif key == "V_Fwd_E" then VehForwardMaxSpeed_Enabled = (val == "1")
                elseif key == "V_Rev_E" then VehReverseMaxSpeed_Enabled = (val == "1")
                elseif key == "V_Sus_E" then VehSuspension_Enabled = (val == "1")
                end
            end
        end
    end)
end

LoadConfigurationSafe()

--========================================================--
-- MAIN HUB
--========================================================--

local function OpenMainHub()
    HasEnteredPanel = true

    TweenService:Create(
        Card,
        TweenInfo.new(.45, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
        {Size = UDim2.new(0,0,0,0), BackgroundTransparency = 1}
    ):Play()
    task.wait(.45)
    Card:Destroy()

    local Main = Instance.new("Frame")
    Main.Name = "MainHub"
    Main.Size = UDim2.new(0, 650, 0, 410)
    Main.Position = UDim2.new(.5, 0, .5, 0)
    Main.AnchorPoint = Vector2.new(.5, .5)
    Main.BackgroundColor3 = Color3.fromRGB(16, 14, 24)
    Main.BackgroundTransparency = 0.22
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Active = true
    Main.Draggable = true
    Main.ZIndex = 10
    Main.Parent = Background
    MainHubFrameRef = Main

    local MainBackgroundImage = Instance.new("ImageLabel")
    MainBackgroundImage.Name = "MainBackgroundImage"
    MainBackgroundImage.Size = UDim2.new(1, 0, 1, 0)
    MainBackgroundImage.Position = UDim2.new(0, 0, 0, 0)
    MainBackgroundImage.BackgroundTransparency = 1
    MainBackgroundImage.BorderSizePixel = 0
    MainBackgroundImage.Image = "rbxassetid://105275560374583"
    MainBackgroundImage.ScaleType = Enum.ScaleType.Crop
    MainBackgroundImage.ImageTransparency = 0.12
    MainBackgroundImage.ZIndex = 0
    MainBackgroundImage.Parent = Main

    local MainBackgroundCorner = Instance.new("UICorner")
    MainBackgroundCorner.CornerRadius = UDim.new(0, 28)
    MainBackgroundCorner.Parent = MainBackgroundImage

    local MainImageOverlay = Instance.new("Frame")
    MainImageOverlay.Name = "MainImageOverlay"
    MainImageOverlay.Size = UDim2.new(1, 0, 1, 0)
    MainImageOverlay.Position = UDim2.new(0, 0, 0, 0)
    MainImageOverlay.BackgroundColor3 = Color3.fromRGB(8, 7, 15)
    MainImageOverlay.BackgroundTransparency = 0.48
    MainImageOverlay.BorderSizePixel = 0
    MainImageOverlay.ZIndex = 1
    MainImageOverlay.Parent = Main

    local OverlayCorner = Instance.new("UICorner")
    OverlayCorner.CornerRadius = UDim.new(0, 28)
    OverlayCorner.Parent = MainImageOverlay

    AttachSnowEffect(Main)

    local MainScale = Instance.new("UIScale")
    MainScale.Parent = Main

    local function UpdateMainScale()
        local cam = workspace.CurrentCamera
        if cam then
            local v = cam.ViewportSize
            if v.X < 700 then
                MainScale.Scale = math.clamp(math.min(v.X/720, v.Y/500), .62, .95)
            else
                MainScale.Scale = 1
            end
        end
    end
    UpdateMainScale()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateMainScale)
    end

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 28)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = ThemeColor
    MainStroke.Transparency = .75
    MainStroke.Thickness = 1.2
    MainStroke.Parent = Main
    table.insert(DynamicColorElements, {Type = "Stroke", Element = MainStroke})

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 175, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(14, 12, 21)
    Sidebar.BackgroundTransparency = .25
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 2
    Sidebar.Parent = Main

    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 28)
    SideCorner.Parent = Sidebar

    local HubLogo = Instance.new("TextLabel")
    HubLogo.Size = UDim2.new(1, -20, 0, 27)
    HubLogo.Position = UDim2.new(0, 10, 0, 18)
    HubLogo.BackgroundTransparency = 1
    HubLogo.Text = "CHINOINFIERNO"
    HubLogo.TextColor3 = Color3.fromRGB(255, 255, 255)
    HubLogo.TextSize = 16
    HubLogo.Font = Enum.Font.GothamMedium
    HubLogo.TextXAlignment = Enum.TextXAlignment.Center
    HubLogo.ZIndex = 3
    HubLogo.Parent = Sidebar

    local KeyActiveFrame = Instance.new("Frame", Sidebar)
    KeyActiveFrame.Size = UDim2.new(1, -20, 0, 18)
    KeyActiveFrame.Position = UDim2.new(0, 10, 0, 44)
    KeyActiveFrame.BackgroundTransparency = 1
    KeyActiveFrame.ZIndex = 3

    local GreenDot = Instance.new("Frame", KeyActiveFrame)
    GreenDot.Size = UDim2.new(0, 7, 0, 7)
    GreenDot.Position = UDim2.new(0, 36, 0.5, -3)
    GreenDot.BackgroundColor3 = Color3.fromRGB(45, 240, 120)
    GreenDot.BorderSizePixel = 0
    GreenDot.ZIndex = 3
    Instance.new("UICorner", GreenDot).CornerRadius = UDim.new(1, 0)

    local KeyActiveLabel = Instance.new("TextLabel", KeyActiveFrame)
    KeyActiveLabel.Size = UDim2.new(1, -50, 1, 0)
    KeyActiveLabel.Position = UDim2.new(0, 48, 0, 0)
    KeyActiveLabel.BackgroundTransparency = 1
    KeyActiveLabel.Text = "Key Active •"
    KeyActiveLabel.TextColor3 = Color3.fromRGB(45, 240, 120)
    KeyActiveLabel.TextSize = 10
    KeyActiveLabel.Font = Enum.Font.GothamMedium
    KeyActiveLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeyActiveLabel.ZIndex = 3

    local Tabs = {
        {Name = "Silent Aim", Icon = "◉"},
        {Name = "ESP", Icon = "◈"},
        {Name = "Player", Icon = "●"},
        {Name = "Vehicle", Icon = "🚗"},
        {Name = "Misc", Icon = "✦"},
        {Name = "Config", Icon = "⚙"}
    }
    local TabButtons = {}

    local SideAvatar = Instance.new("ImageLabel")
    SideAvatar.Name = "PlayerAvatar"
    SideAvatar.Size = UDim2.new(0, 42, 0, 42)
    SideAvatar.Position = UDim2.new(.5, 0, 1, -52)
    SideAvatar.AnchorPoint = Vector2.new(.5, 0)
    SideAvatar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SideAvatar.BackgroundTransparency = .9
    SideAvatar.BorderSizePixel = 0
    SideAvatar.ZIndex = 3
    SideAvatar.Parent = Sidebar

    local SideAvatarCorner = Instance.new("UICorner")
    SideAvatarCorner.CornerRadius = UDim.new(1, 0)
    SideAvatarCorner.Parent = SideAvatar

    local SideAvatarStroke = Instance.new("UIStroke")
    SideAvatarStroke.Color = ThemeColor
    SideAvatarStroke.Transparency = .35
    SideAvatarStroke.Thickness = 1.2
    SideAvatarStroke.Parent = SideAvatar
    table.insert(DynamicColorElements, {Type = "Stroke", Element = SideAvatarStroke})

    task.spawn(function()
        local ok, image = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.AvatarBust, Enum.ThumbnailSize.Size420x420)
        end)
        if ok and image then SideAvatar.Image = image end
    end)

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -195, 1, -25)
    Content.Position = UDim2.new(0, 190, 0, 12)
    Content.BackgroundTransparency = 1
    Content.ZIndex = 2
    Content.Parent = Main

    local ContentTitle = Instance.new("TextLabel")
    ContentTitle.Size = UDim2.new(1, -70, 0, 32)
    ContentTitle.Position = UDim2.new(0, 15, 0, 18)
    ContentTitle.BackgroundTransparency = 1
    ContentTitle.Text = "Silent Aim"
    ContentTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    ContentTitle.TextSize = 22
    ContentTitle.Font = Enum.Font.GothamMedium
    ContentTitle.TextXAlignment = Enum.TextXAlignment.Left
    ContentTitle.ZIndex = 2
    ContentTitle.Parent = Content

    local ContentDesc = Instance.new("TextLabel")
    ContentDesc.Size = UDim2.new(1, -30, 0, 25)
    ContentDesc.Position = UDim2.new(0, 15, 0, 52)
    ContentDesc.BackgroundTransparency = 1
    ContentDesc.Text = "Silent Aim settings"
    ContentDesc.TextColor3 = Color3.fromRGB(145, 150, 175)
    ContentDesc.TextSize = 12
    ContentDesc.Font = Enum.Font.GothamMedium
    ContentDesc.TextXAlignment = Enum.TextXAlignment.Left
    ContentDesc.ZIndex = 2
    ContentDesc.Parent = Content

    local TabContainers = {}

    local function CreateTabScroll(name)
        local frame = Instance.new("ScrollingFrame")
        frame.Name = name .. "Scroll"
        frame.Size = UDim2.new(1, -30, 0, 245)
        frame.Position = UDim2.new(0, 15, 0, 90)
        frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        frame.BackgroundTransparency = .96
        frame.BorderSizePixel = 0
        frame.ScrollBarThickness = 3
        frame.ScrollBarImageColor3 = ThemeColor
        frame.Visible = false
        frame.ZIndex = 2
        frame.Parent = Content

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 20)
        corner.Parent = frame

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.Parent = frame

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 10)
        pad.PaddingLeft = UDim.new(0, 12)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = frame

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)

        TabContainers[name] = frame
        return frame
    end

    local SilentScroll = CreateTabScroll("Silent Aim")
    local ESPScroll = CreateTabScroll("ESP")
    local PlayerScroll = CreateTabScroll("Player")
    local VehicleScroll = CreateTabScroll("Vehicle")
    local MiscScroll = CreateTabScroll("Misc")
    local ConfigScroll = CreateTabScroll("Config")

    local function MakeToggle(parent, titleText, defaultVal, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 42)
        row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        row.BackgroundTransparency = 0.95
        row.ZIndex = 3
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(1, -60, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = titleText
        label.TextColor3 = Color3.fromRGB(240, 240, 245)
        label.TextSize = 13
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 3

        local toggle = Instance.new("TextButton", row)
        toggle.Size = UDim2.new(0, 36, 0, 20)
        toggle.Position = UDim2.new(1, -46, 0.5, -10)
        toggle.BackgroundColor3 = defaultVal and ThemeColor or Color3.fromRGB(35, 32, 45)
        toggle.Text = ""
        toggle.ZIndex = 3
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

        local circle = Instance.new("Frame", toggle)
        circle.Size = UDim2.new(0, 14, 0, 14)
        circle.Position = defaultVal and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BorderSizePixel = 0
        circle.ZIndex = 4
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local current = defaultVal
        table.insert(DynamicColorElements, {
            Type = "Toggle",
            Element = toggle,
            State = function() return current end
        })

        toggle.MouseButton1Click:Connect(function()
            current = not current
            if current then playToggleSound() end
            TweenService:Create(toggle, TweenInfo.new(0.18), {BackgroundColor3 = current and ThemeColor or Color3.fromRGB(35, 32, 45)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.18), {Position = current and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
            if callback then callback(current) end
        end)
    end

    local function MakeSlider(parent, name, defaultVal, minVal, maxVal, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 48)
        row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        row.BackgroundTransparency = 0.95
        row.ZIndex = 3
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(1, -20, 0, 16)
        label.Position = UDim2.new(0, 12, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. tostring(defaultVal)
        label.TextColor3 = Color3.fromRGB(240, 240, 245)
        label.TextSize = 12
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 3

        local bar = Instance.new("Frame", row)
        bar.Size = UDim2.new(1, -24, 0, 6)
        bar.Position = UDim2.new(0, 12, 0, 28)
        bar.BackgroundColor3 = Color3.fromRGB(35, 32, 45)
        bar.ZIndex = 3
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1), 0, 1, 0)
        fill.BackgroundColor3 = ThemeColor
        fill.ZIndex = 3
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        table.insert(DynamicColorElements, {Type = "Background", Element = fill})

        local dot = Instance.new("Frame", fill)
        dot.Size = UDim2.new(0, 16, 0, 16)
        dot.Position = UDim2.new(1, -8, 0.5, -8)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BorderSizePixel = 0
        dot.ZIndex = 4
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local function applySlider(input)
            local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local calc = minVal + ((maxVal - minVal) * pos)
            calc = math.floor(calc * 10 + 0.5) / 10
            fill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = name .. ": " .. tostring(calc)
            if callback then callback(calc) end
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                applySlider(input)
            end
        end)

        dot.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                applySlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                applySlider(input)
            end
        end)
    end

    -- PESTAÑA SILENT AIM
    MakeToggle(SilentScroll, "Silent Aim", SilentAimEnabled, function(v) SilentAimEnabled = v; CurrentLockedTarget = nil end)
    
    -- SELECTOR DE DESTINO EXACTO DE YA.TXT
    local PartRow = Instance.new("Frame")
    PartRow.Size = UDim2.new(1, 0, 0, 44)
    PartRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PartRow.BackgroundTransparency = 0.95
    PartRow.ZIndex = 3
    PartRow.Parent = SilentScroll
    Instance.new("UICorner", PartRow).CornerRadius = UDim.new(0, 10)

    local PartLabel = Instance.new("TextLabel", PartRow)
    PartLabel.Size = UDim2.new(0, 80, 1, 0)
    PartLabel.Position = UDim2.new(0, 12, 0, 0)
    PartLabel.BackgroundTransparency = 1
    PartLabel.Text = "Destino:"
    PartLabel.TextColor3 = Color3.fromRGB(240, 240, 245)
    PartLabel.TextSize = 12
    PartLabel.Font = Enum.Font.GothamMedium
    PartLabel.TextXAlignment = Enum.TextXAlignment.Left
    PartLabel.ZIndex = 3

    local parts = {
        {Name = "Head", Display = "⚠️ Head"},
        {Name = "Neck", Display = "Neck"},
        {Name = "Chest", Display = "Chest"}
    }
    local partButtons = {}
    for i, pData in ipairs(parts) do
        local pBtn = Instance.new("TextButton", PartRow)
        pBtn.Size = UDim2.new(0, 62, 0, 26)
        pBtn.Position = UDim2.new(1, -200 + ((i - 1) * 66), 0.5, -13)
        pBtn.BackgroundColor3 = (pData.Name == TargetHitPart) and ThemeColor or Color3.fromRGB(35, 32, 45)
        pBtn.Text = pData.Display
        pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        pBtn.TextSize = 10
        pBtn.Font = Enum.Font.GothamMedium
        pBtn.ZIndex = 3
        Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 6)
        
        pBtn.MouseButton1Click:Connect(function()
            if pData.Name == "Head" then
                ShowWarningModal(
                    "RIESGO DE BLACKLIST",
                    "La opción Head NO tiene bypass incluido. Apuntar a la cabeza de forma continua conlleva riesgo de blacklist en el juego. ¿Deseas activarla aun así?",
                    "ENTENDIDO Y ACTIVAR",
                    function()
                        TargetHitPart = "Head"
                        for _, btn in pairs(partButtons) do
                            btn.BackgroundColor3 = Color3.fromRGB(35, 32, 45)
                        end
                        pBtn.BackgroundColor3 = ThemeColor
                    end
                )
            else
                TargetHitPart = pData.Name
                for _, btn in pairs(partButtons) do
                    btn.BackgroundColor3 = Color3.fromRGB(35, 32, 45)
                end
                pBtn.BackgroundColor3 = ThemeColor
            end
        end)
        partButtons[pData.Name] = pBtn
    end

    MakeToggle(SilentScroll, "Target Line", SettingsVisual.TargetLine, function(v) 
        SettingsVisual.TargetLine = v
        if not v then
            CurrentTarget = nil
            TargetLine.Visible = false
            TargetMarker.Visible = false
        end
    end)
    MakeToggle(SilentScroll, "Mostrar FOV", SettingsVisual.FOV, function(v) SettingsVisual.FOV = v end)
    MakeSlider(SilentScroll, "Radio FOV", SettingsVisual.FOVRadius, 20, 800, function(v) 
        SettingsVisual.FOVRadius = v
        SettingsVisual.FOVMin = v - 5
        SettingsVisual.FOVMax = v + 5
    end)

    -- PESTAÑA ESP
    MakeToggle(ESPScroll, "ESP Box", SettingsVisual.Box, function(v) SettingsVisual.Box = v end)
    MakeToggle(ESPScroll, "ESP Lines", SettingsVisual.Lines, function(v) SettingsVisual.Lines = v end)
    MakeToggle(ESPScroll, "ESP Highlight", PlayerESP_Highlight, function(v) PlayerESP_Highlight = v end)
    MakeToggle(ESPScroll, "ESP Nombres", PlayerESP_Name, function(v) PlayerESP_Name = v end)
    MakeToggle(ESPScroll, "ESP Salud", PlayerESP_Health, function(v) PlayerESP_Health = v end)
    MakeToggle(ESPScroll, "ESP Distancia", PlayerESP_Dist, function(v) PlayerESP_Dist = v end)
    MakeToggle(ESPScroll, "ESP Armas", WeaponESPEnabled, function(v) 
        WeaponESPEnabled = v 
        if not v then
            for _, bg in pairs(WeaponBillboardCache) do bg:Destroy() end
            WeaponBillboardCache = {}
            WeaponCacheTokens = {}
        end
    end)
    MakeToggle(ESPScroll, "ESP Ítems", ItemESPEnabled, function(v) ItemESPEnabled = v end)

    -- PESTAÑA PLAYER
    MakeToggle(PlayerScroll, "Anti-Kill", AutoSafeDamageEnabled, function(v)
        AutoSafeDamageEnabled = v
        if not v then
            AutoSafeActive = false
            TargetAutoSafeY = nil
            SavedAutoSafeY = nil
            FrozenCameraCFrame = nil
        end
    end)
    MakeToggle(PlayerScroll, "Salto Infinito", InfiniteJumpEnabled, function(v) InfiniteJumpEnabled = v end)
    MakeSlider(PlayerScroll, "Potencia de Salto", JumpPowerBypassValue, 40, 150, function(v) JumpPowerBypassValue = v end)
    MakeToggle(PlayerScroll, "Stamina Infinita", InfStaminaEnabled, function(v) toggleInfStamina(v) end)
    MakeToggle(PlayerScroll, "Speed Hack", SpeedHackEnabled, function(v) SpeedHackEnabled = v end)
    MakeSlider(PlayerScroll, "Velocidad Speed", SpeedValue, 1, 20, function(v) SpeedValue = v end)

    -- PESTAÑA VEHICLE CON LETRAS ANCHAS, SWITCHES Y FÍSICA A 5000
    local function MakeVehicleOption(name, defaultVal, defaultToggle, onValChange, onToggleChange)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 52)
        row.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        row.BackgroundTransparency = 0.95
        row.ZIndex = 3
        row.Parent = VehicleScroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(1, -60, 0, 16)
        label.Position = UDim2.new(0, 12, 0, 6)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. tostring(defaultVal)
        label.TextColor3 = Color3.fromRGB(240, 240, 245)
        label.TextSize = 12
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 3

        local toggle = Instance.new("TextButton", row)
        toggle.Size = UDim2.new(0, 32, 0, 16)
        toggle.Position = UDim2.new(1, -44, 0, 6)
        toggle.BackgroundColor3 = defaultToggle and ThemeColor or Color3.fromRGB(35, 32, 45)
        toggle.Text = ""
        toggle.ZIndex = 3
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

        local circle = Instance.new("Frame", toggle)
        circle.Size = UDim2.new(0, 12, 0, 12)
        circle.Position = defaultToggle and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
        circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        circle.BorderSizePixel = 0
        circle.ZIndex = 4
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

        local currentToggle = defaultToggle
        table.insert(DynamicColorElements, {
            Type = "Toggle",
            Element = toggle,
            State = function() return currentToggle end
        })

        local function updateSwitch(state)
            TweenService:Create(toggle, TweenInfo.new(0.18), {BackgroundColor3 = state and ThemeColor or Color3.fromRGB(35, 32, 45)}):Play()
            TweenService:Create(circle, TweenInfo.new(0.18), {Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)}):Play()
        end

        toggle.MouseButton1Click:Connect(function()
            currentToggle = not currentToggle
            if currentToggle then playToggleSound() end
            updateSwitch(currentToggle)
            if onToggleChange then onToggleChange(currentToggle) end
        end)

        local bar = Instance.new("Frame", row)
        bar.Size = UDim2.new(1, -24, 0, 6)
        bar.Position = UDim2.new(0, 12, 0, 32)
        bar.BackgroundColor3 = Color3.fromRGB(35, 32, 45)
        bar.ZIndex = 3
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(math.clamp(defaultVal / 5000, 0, 1), 0, 1, 0)
        fill.BackgroundColor3 = ThemeColor
        fill.ZIndex = 3
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        table.insert(DynamicColorElements, {Type = "Background", Element = fill})

        local dot = Instance.new("Frame", fill)
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.Position = UDim2.new(1, -7, 0.5, -7)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.BorderSizePixel = 0
        dot.ZIndex = 4
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local dragging = false
        local function applySlider(input)
            local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local calc = math.floor((pos * 5000) * 10 + 0.5) / 10
            fill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = name .. ": " .. tostring(calc)
            if onValChange then onValChange(calc) end
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                applySlider(input)
            end
        end)

        dot.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                applySlider(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                applySlider(input)
            end
        end)

        return {
            SetVal = function(val)
                fill.Size = UDim2.new(math.clamp(val / 5000, 0, 1), 0, 1, 0)
                label.Text = name .. ": " .. tostring(val)
                if onValChange then onValChange(val) end
            end
        }
    end

    local vAccRef = MakeVehicleOption("Acceleration", VehAcceleration, VehAcceleration_Enabled, function(v) VehAcceleration = v end, function(v) VehAcceleration_Enabled = v end)
    local vBrkRef = MakeVehicleOption("Braking", VehBraking, VehBraking_Enabled, function(v) VehBraking = v end, function(v) VehBraking_Enabled = v end)
    local vDecRef = MakeVehicleOption("Deceleration", VehDeceleration, VehDeceleration_Enabled, function(v) VehDeceleration = v end, function(v) VehDeceleration_Enabled = v end)
    local vFwdRef = MakeVehicleOption("Forward Max Speed", VehForwardMaxSpeed, VehForwardMaxSpeed_Enabled, function(v) VehForwardMaxSpeed = v end, function(v) VehForwardMaxSpeed_Enabled = v end)
    local vRevRef = MakeVehicleOption("Reverse Max Speed", VehReverseMaxSpeed, VehReverseMaxSpeed_Enabled, function(v) VehReverseMaxSpeed = v end, function(v) VehReverseMaxSpeed_Enabled = v end)
    local vSusRef = MakeVehicleOption("Suspension", VehSuspension, VehSuspension_Enabled, function(v) VehSuspension = v end, function(v) VehSuspension_Enabled = v end)

    local ModeRow = Instance.new("Frame")
    ModeRow.Size = UDim2.new(1, 0, 0, 38)
    ModeRow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ModeRow.BackgroundTransparency = 0.95
    ModeRow.ZIndex = 3
    ModeRow.Parent = VehicleScroll
    Instance.new("UICorner", ModeRow).CornerRadius = UDim.new(0, 10)

    local function CreateModeButton(name, posX, onClick)
        local btn = Instance.new("TextButton", ModeRow)
        btn.Size = UDim2.new(0.31, 0, 0, 28)
        btn.Position = UDim2.new(posX, 0, 0.5, -14)
        btn.BackgroundColor3 = Color3.fromRGB(28, 25, 38)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(240, 240, 255)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamMedium
        btn.ZIndex = 4
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseButton1Click:Connect(function()
            playToggleSound()
            onClick()
        end)
    end

    CreateModeButton("Normal", 0.02, function()
        vAccRef.SetVal(30)
        vBrkRef.SetVal(50)
        vDecRef.SetVal(15)
        vFwdRef.SetVal(140)
        vRevRef.SetVal(50)
        vSusRef.SetVal(2)
    end)

    CreateModeButton("Profesional", 0.35, function()
        vAccRef.SetVal(75)
        vBrkRef.SetVal(120)
        vDecRef.SetVal(35)
        vFwdRef.SetVal(320)
        vRevRef.SetVal(90)
        vSusRef.SetVal(2.4)
    end)

    CreateModeButton("Experto", 0.67, function()
        vAccRef.SetVal(140)
        vBrkRef.SetVal(380)
        vDecRef.SetVal(130)
        vFwdRef.SetVal(650)
        vRevRef.SetVal(170)
        vSusRef.SetVal(1.5)
    end)

    -- PESTAÑA MISC
    MakeToggle(MiscScroll, "Optimizar FPS", PotatoBoostEnabled, function(v) togglePotatoGraphics(v) end)
    MakeToggle(MiscScroll, "Skip Cajas", SkipCratesEnabled, function(v) SkipCratesEnabled = v end)
    MakeToggle(MiscScroll, "Gun Mods", GunModsActive, function(v) GunModsActive = v end)
    MakeSlider(MiscScroll, "Fire Rate", FireRateVal, 100, 10000, function(v) FireRateVal = v end)
    MakeSlider(MiscScroll, "Accuracy", AccuracyVal, 0.1, 1, function(v) AccuracyVal = v end)
    MakeSlider(MiscScroll, "Recoil", RecoilVal, 0, 10, function(v) RecoilVal = v end)
    MakeSlider(MiscScroll, "Reload Time", ReloadVal, 0.05, 5, function(v) ReloadVal = v end)
    MakeToggle(MiscScroll, "Automatic", AutomaticVal, function(v) AutomaticVal = v end)
    MakeToggle(MiscScroll, "Melee Aura", MeleeAuraEnabled, function(v) 
        MeleeAuraEnabled = v 
        updateMeleeTools()
    end)
    MakeToggle(MiscScroll, "Auto Attack", AutoAttackEnabled, function(v) AutoAttackEnabled = v end)
    MakeToggle(MiscScroll, "Auto Pickup", AutoPickupEnabled, function(v) AutoPickupEnabled = v end)
    MakeSlider(MiscScroll, "Radio Pickup", AutoPickupRadius, 20, 500, function(v) AutoPickupRadius = v end)
    MakeToggle(MiscScroll, "Auto Interactuar", AutoInteractEnabled, function(v) AutoInteractEnabled = v end)
    MakeToggle(MiscScroll, "Panel TP Flotante", false, function(v) FloatingSnapGui.Enabled = v end)
    MakeToggle(MiscScroll, "Ghost Astral", false, function(v) AstralProjectionGui.Enabled = v end)

    -- PESTAÑA CONFIG
    MakeToggle(ConfigScroll, "Traspasar Paredes", WallbangEnabled, function(v) WallbangEnabled = v end)
    MakeToggle(ConfigScroll, "Ocultar Mi Nombre", HideNameEnabled, function(v)
        HideNameEnabled = v
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local bb = root and root:FindFirstChild("CharacterBillboardGui")
            if bb and bb:FindFirstChild("PlayerName") then bb.PlayerName.Visible = not v end
        end)
    end)

    local SaveCfgBtn = Instance.new("TextButton", ConfigScroll)
    SaveCfgBtn.Size = UDim2.new(1, 0, 0, 36)
    SaveCfgBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 48)
    SaveCfgBtn.Text = "💾 GUARDAR MI CONFIGURACIÓN"
    SaveCfgBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
    SaveCfgBtn.TextSize = 12
    SaveCfgBtn.Font = Enum.Font.GothamMedium
    SaveCfgBtn.ZIndex = 3
    Instance.new("UICorner", SaveCfgBtn).CornerRadius = UDim.new(0, 10)

    SaveCfgBtn.MouseButton1Click:Connect(function()
        local ok = SaveConfigurationSafe()
        if ok then
            SaveCfgBtn.Text = "¡GUARDADO CORRECTAMENTE!"
            SaveCfgBtn.TextColor3 = Color3.fromRGB(70, 255, 140)
        else
            SaveCfgBtn.Text = "ERROR AL GUARDAR"
            SaveCfgBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
        task.wait(2)
        SaveCfgBtn.Text = "💾 GUARDAR MI CONFIGURACIÓN"
        SaveCfgBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
    end)

    local function SelectTab(selected)
        for _, data in ipairs(TabButtons) do
            if data.Name == selected.Name then
                TweenService:Create(data.Button, TweenInfo.new(.2), {
                    BackgroundTransparency = .72,
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                }):Play()
            else
                TweenService:Create(data.Button, TweenInfo.new(.2), {
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.fromRGB(145, 150, 170)
                }):Play()
            end
        end

        for name, scroll in pairs(TabContainers) do
            scroll.Visible = (name == selected.Name)
        end

        ContentTitle.Text = selected.Name
        ContentDesc.Text = selected.Name .. " settings"
    end

    for i, data in ipairs(Tabs) do
        local Button = Instance.new("TextButton")
        Button.Name = data.Name
        Button.Size = UDim2.new(1, -25, 0, 36)
        Button.Position = UDim2.new(0, 12, 0, 72 + ((i - 1) * 40))
        Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Button.BackgroundTransparency = 1
        Button.BorderSizePixel = 0
        Button.Text = "   " .. data.Icon .. "     " .. data.Name
        Button.TextColor3 = Color3.fromRGB(145, 150, 170)
        Button.TextSize = 12
        Button.Font = Enum.Font.GothamMedium
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.AutoButtonColor = false
        Button.ZIndex = 3
        Button.Parent = Sidebar

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(0, 10)
        Corner.Parent = Button

        table.insert(TabButtons, {Name = data.Name, Button = Button})

        Button.MouseButton1Click:Connect(function()
            SelectTab(data)
        end)
    end

    SelectTab(Tabs[1])

    local Minimize = Instance.new("TextButton")
    Minimize.Size = UDim2.new(0, 32, 0, 32)
    Minimize.Position = UDim2.new(1, -48, 0, 18)
    Minimize.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Minimize.BackgroundTransparency = .9
    Minimize.BorderSizePixel = 0
    Minimize.Text = "—"
    Minimize.TextColor3 = Color3.fromRGB(220, 220, 230)
    Minimize.TextSize = 16
    Minimize.Font = Enum.Font.GothamMedium
    Minimize.ZIndex = 3
    Minimize.Parent = Main
    Instance.new("UICorner", Minimize).CornerRadius = UDim.new(1, 0)

    -- BOTÓN FLOTANTE: CÍRCULO PEQUEÑO (44px)
    local BALL_SIZE = 44
    local SIDE_X = 25
    local SNOW_AMOUNT = 22
    local SNOW_MIN_SPEED = 0.035
    local SNOW_MAX_SPEED = 0.075
    local COLORS = {
        Color3.fromRGB(175, 55, 255),
        Color3.fromRGB(85, 95, 255),
        Color3.fromRGB(0, 215, 255),
        Color3.fromRGB(125, 65, 255),
    }

    local OpenButton = Instance.new("ImageButton")
    OpenButton.Name = "FloatingOpenCircle"
    OpenButton.Size = UDim2.new(0, BALL_SIZE, 0, BALL_SIZE)
    OpenButton.Position = UDim2.new(0, SIDE_X, 0.5, -(BALL_SIZE / 2))
    OpenButton.BackgroundColor3 = Color3.fromRGB(8, 8, 13)
    OpenButton.BorderSizePixel = 0
    OpenButton.Image = "rbxassetid://105275560374583"
    OpenButton.ImageTransparency = 0
    OpenButton.ScaleType = Enum.ScaleType.Crop
    OpenButton.AutoButtonColor = false
    OpenButton.ClipsDescendants = true
    OpenButton.Visible = false
    OpenButton.Active = true
    OpenButton.Draggable = true
    OpenButton.ZIndex = 100
    OpenButton.Parent = ScreenGui

    local BallCorner = Instance.new("UICorner")
    BallCorner.CornerRadius = UDim.new(1, 0)
    BallCorner.Parent = OpenButton

    local SnowContainer = Instance.new("Frame")
    SnowContainer.Name = "SnowInside"
    SnowContainer.Size = UDim2.new(1, 0, 1, 0)
    SnowContainer.BackgroundTransparency = 1
    SnowContainer.BorderSizePixel = 0
    SnowContainer.ClipsDescendants = true
    SnowContainer.ZIndex = 10
    SnowContainer.Parent = OpenButton

    local SnowCorner = Instance.new("UICorner")
    SnowCorner.CornerRadius = UDim.new(1, 0)
    SnowCorner.Parent = SnowContainer

    local Particles = {}
    local function CreateSnow()
        local particle = Instance.new("Frame")
        local size = math.random(1, 2)
        particle.Size = UDim2.new(0, size, 0, size)
        particle.Position = UDim2.new(math.random(5, 95) / 100, 0, math.random(-100, 100) / 100, 0)
        particle.BackgroundColor3 = COLORS[math.random(1, #COLORS)]
        particle.BackgroundTransparency = math.random(0, 35) / 100
        particle.BorderSizePixel = 0
        particle.ZIndex = 11
        particle.Parent = SnowContainer
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = particle
        
        table.insert(Particles, {
            Object = particle,
            X = particle.Position.X.Scale,
            Y = particle.Position.Y.Scale,
            Speed = math.random(SNOW_MIN_SPEED * 1000, SNOW_MAX_SPEED * 1000) / 1000,
            Drift = math.random(-8, 8) / 1000,
            Wave = math.random(1, 5),
            Time = math.random() * 10,
        })
    end

    for i = 1, SNOW_AMOUNT do
        CreateSnow()
    end

    local function ResetSnow(data, randomStart)
        local object = data.Object
        if not object or not object.Parent then return end
        data.X = math.random(5, 95) / 100
        data.Y = randomStart and math.random(-100, 100) / 100 or math.random(-25, -5) / 100
        data.Speed = math.random(SNOW_MIN_SPEED * 1000, SNOW_MAX_SPEED * 1000) / 1000
        data.Drift = math.random(-8, 8) / 1000
        data.Wave = math.random(1, 5)
        data.Time = math.random() * 10
        object.Position = UDim2.new(data.X, 0, data.Y, 0)
        object.BackgroundColor3 = COLORS[math.random(1, #COLORS)]
        object.BackgroundTransparency = math.random(0, 35) / 100
    end

    RunService.RenderStepped:Connect(function(deltaTime)
        for _, data in ipairs(Particles) do
            local object = data.Object
            if object and object.Parent then
                data.Time = data.Time + deltaTime
                data.Y = data.Y + data.Speed * deltaTime
                local wave = math.sin(data.Time * 2.5) * data.Wave * 0.00025
                data.X = data.X + data.Drift * deltaTime + wave
                if data.X < 0.02 then data.X = 0.02; data.Drift = math.abs(data.Drift) end
                if data.X > 0.98 then data.X = 0.98; data.Drift = -math.abs(data.Drift) end
                object.Position = UDim2.new(data.X, 0, data.Y, 0)
                if data.Y > 1.05 then ResetSnow(data, false) end
            end
        end
    end)

    local InnerLED = Instance.new("Frame", OpenButton)
    InnerLED.Name = "InnerLED"
    InnerLED.Size = UDim2.new(1, -4, 1, -4)
    InnerLED.Position = UDim2.new(0, 2, 0, 2)
    InnerLED.BackgroundTransparency = 1
    InnerLED.BorderSizePixel = 0
    InnerLED.ZIndex = 20
    Instance.new("UICorner", InnerLED).CornerRadius = UDim.new(1, 0)
    local LEDStroke = Instance.new("UIStroke", InnerLED)
    LEDStroke.Name = "BrightLED"
    LEDStroke.Thickness = 1.5
    LEDStroke.Transparency = 0.05

    local GlowRing = Instance.new("Frame", OpenButton)
    GlowRing.Name = "GlowRing"
    GlowRing.Size = UDim2.new(1, -8, 1, -8)
    GlowRing.Position = UDim2.new(0, 4, 0, 4)
    GlowRing.BackgroundTransparency = 1
    GlowRing.BorderSizePixel = 0
    GlowRing.ZIndex = 19
    Instance.new("UICorner", GlowRing).CornerRadius = UDim.new(1, 0)
    local GlowStroke = Instance.new("UIStroke", GlowRing)
    GlowStroke.Name = "SoftGlow"
    GlowStroke.Thickness = 1.5
    GlowStroke.Transparency = 0.55

    task.spawn(function()
        local index = 1
        while ScreenGui.Parent do
            local nextIndex = index + 1
            if nextIndex > #COLORS then nextIndex = 1 end
            local current = COLORS[index]
            local nextColor = COLORS[nextIndex]
            LEDStroke.Color = current
            GlowStroke.Color = current
            local tweenInfo = TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            TweenService:Create(LEDStroke, tweenInfo, {Color = nextColor}):Play()
            TweenService:Create(GlowStroke, tweenInfo, {Color = nextColor}):Play()
            task.wait(1.0)
            index = nextIndex
        end
    end)

    Minimize.MouseButton1Click:Connect(function()
        TweenService:Create(Background, TweenInfo.new(.65, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play()
        for _, orb in ipairs(OrbFolder:GetChildren()) do
            for _, obj in ipairs(orb:GetDescendants()) do
                if obj:IsA("Frame") then
                    TweenService:Create(obj, TweenInfo.new(.65, Enum.EasingStyle.Sine), {BackgroundTransparency = 1}):Play()
                end
            end
        end
        TweenService:Create(Blur, TweenInfo.new(.65, Enum.EasingStyle.Sine), {Size = 0}):Play()
        TweenService:Create(Main, TweenInfo.new(.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
        task.wait(.4)
        Main.Visible = false
        OpenButton.Visible = true
        OpenButton.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(OpenButton, TweenInfo.new(.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, BALL_SIZE, 0, BALL_SIZE)}):Play()
    end)

    OpenButton.MouseButton1Click:Connect(function()
        TweenService:Create(OpenButton, TweenInfo.new(.2, Enum.EasingStyle.Sine), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(.2)
        OpenButton.Visible = false
        Main.Visible = true
        Main.Size = UDim2.new(0, 0, 0, 0)
        Main.BackgroundTransparency = 0.22
        TweenService:Create(Main, TweenInfo.new(.55, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 650, 0, 410), BackgroundTransparency = 0.22}):Play()
        TweenService:Create(Background, TweenInfo.new(.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
        TweenService:Create(Blur, TweenInfo.new(.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = 22}):Play()

        for _, orb in ipairs(OrbFolder:GetChildren()) do
            for _, obj in ipairs(orb:GetDescendants()) do
                if obj:IsA("Frame") then
                    local target = .84
                    if obj.Name == "Core" then target = .78 end
                    TweenService:Create(obj, TweenInfo.new(.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = target}):Play()
                end
            end
        end
    end)
end

--========================================================--
-- VALIDACIÓN CON PANDAAUTH V4 / KEY
--========================================================--

--NO KEY 😂
