-- Мобильная версия Unknown Threat ESP на Rayfield (исправленная для Delta X)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Drawings = {}
local Settings = {
    Enabled = true,
    BoxESP = false,
    BoxStyle = "Corner",
    BoxThickness = 1,
    SkeletonESP = false,
    SkeletonThickness = 1.5,
    NameESP = false,
    HealthESP = false,
    HealthBarWidth = 4,
    ShowHealthText = false,
    TracerESP = false,
    TracerOrigin = "Bottom",
    TracerThickness = 1,
    PointESP = false,
    PointSize = 5,
    MaxDistance = 400,
    TeamCheck = false,
    RainbowEnabled = false,
    RainbowSpeed = 1,
    ShowDistance = false,
}

local Colors = {
    Seeker = Color3.fromRGB(255, 0, 0),
    Killer = Color3.fromRGB(255, 0, 0),
    Hider = Color3.fromRGB(255, 200, 0),
    Innocent = Color3.fromRGB(0, 255, 0),
    Traitor = Color3.fromRGB(255, 0, 255),
    Police = Color3.fromRGB(0, 100, 255),
    Swat = Color3.fromRGB(0, 80, 200),
    Sheriff = Color3.fromRGB(0, 150, 255),
    Juggernaut = Color3.fromRGB(255, 165, 0),
    NoRole = Color3.fromRGB(255, 255, 255),
    Unknown = Color3.fromRGB(150, 150, 150),
    Rainbow = nil,
}

local function GetWorkspaceSettingsFolder()
    local folder = workspace:FindFirstChild("ESP_Settings")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "ESP_Settings"
        folder.Parent = workspace
    end
    return folder
end

local function SaveWorkspaceSetting(key, value)
    local folder = GetWorkspaceSettingsFolder()
    local obj = folder:FindFirstChild(key)
    local typeVal = type(value)
    if typeVal == "boolean" then
        if not obj or not obj:IsA("BoolValue") then
            if obj then obj:Destroy() end
            obj = Instance.new("BoolValue")
            obj.Name = key
            obj.Parent = folder
        end
        obj.Value = value
    elseif typeVal == "number" then
        if not obj or not obj:IsA("NumberValue") then
            if obj then obj:Destroy() end
            obj = Instance.new("NumberValue")
            obj.Name = key
            obj.Parent = folder
        end
        obj.Value = value
    elseif typeVal == "string" then
        if not obj or not obj:IsA("StringValue") then
            if obj then obj:Destroy() end
            obj = Instance.new("StringValue")
            obj.Name = key
            obj.Parent = folder
        end
        obj.Value = value
    elseif typeVal == "Color3" then
        if not obj or not obj:IsA("Color3Value") then
            if obj then obj:Destroy() end
            obj = Instance.new("Color3Value")
            obj.Name = key
            obj.Parent = folder
        end
        obj.Value = value
    end
end

local function LoadSettingsFromWorkspace()
    local folder = GetWorkspaceSettingsFolder()
    for _, child in ipairs(folder:GetChildren()) do
        local key = child.Name
        if Settings[key] ~= nil then
            if child:IsA("BoolValue") then
                Settings[key] = child.Value
            elseif child:IsA("NumberValue") then
                Settings[key] = child.Value
            elseif child:IsA("StringValue") then
                Settings[key] = child.Value
            elseif child:IsA("Color3Value") then
                if Colors[key] ~= nil then
                    Colors[key] = child.Value
                else
                    Settings[key] = child.Value
                end
            end
        elseif Colors[key] ~= nil then
            if child:IsA("Color3Value") then
                Colors[key] = child.Value
            end
        end
    end
end

LoadSettingsFromWorkspace()

local function GetPlayerRole(player)
    local character = player.Character
    if not character then return "NoRole" end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return "NoRole" end
    local roleAttr = player:GetAttribute("Role")
    local deathRole = player:GetAttribute("DeathRole")
    local roleStr = nil
    if roleAttr ~= nil and roleAttr ~= "" and tostring(roleAttr) ~= "nil" then
        roleStr = tostring(roleAttr):upper()
    end
    if not roleStr and deathRole ~= nil and deathRole ~= "" and tostring(deathRole) ~= "nil" then
        roleStr = tostring(deathRole):upper()
    end
    if not roleStr then
        return "NoRole"
    end
    if roleStr:find("SEEKER") then return "Seeker" end
    if roleStr:find("KILLER") then return "Killer" end
    if roleStr:find("HIDER") then return "Hider" end
    if roleStr:find("INNOCENT") then return "Innocent" end
    if roleStr:find("TRAITOR") then return "Traitor" end
    if roleStr:find("POLICE") then return "Police" end
    if roleStr:find("SWAT") then return "Swat" end
    if roleStr:find("SHERIFF") then return "Sheriff" end
    if roleStr:find("JUGGERNAUT") then return "Juggernaut" end
    return "Unknown"
end

local function IsTeammate(player)
    local localRole = GetPlayerRole(LocalPlayer)
    local targetRole = GetPlayerRole(player)
    if localRole == "Unknown" or targetRole == "Unknown" then return false end
    if localRole == "NoRole" or targetRole == "NoRole" then return false end
    local function isGood(role)
        return role == "Hider" or role == "Innocent" or role == "Police" or role == "Swat" or role == "Sheriff" or role == "Juggernaut"
    end
    local function isBad(role)
        return role == "Seeker" or role == "Killer" or role == "Traitor"
    end
    if isGood(localRole) and isGood(targetRole) then return true end
    if isBad(localRole) and isBad(targetRole) then return true end
    return false
end

local function GetPlayerColor(player)
    if Settings.RainbowEnabled then
        return Colors.Rainbow
    end
    local role = GetPlayerRole(player)
    return Colors[role] or Colors.Unknown
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    local esp = {
        Box = {
            Left = Drawing.new("Line"),
            Right = Drawing.new("Line"),
            Top = Drawing.new("Line"),
            Bottom = Drawing.new("Line"),
            TL = Drawing.new("Line"),
            TR = Drawing.new("Line"),
            BL = Drawing.new("Line"),
            BR = Drawing.new("Line"),
        },
        Name = Drawing.new("Text"),
        Health = {
            Outline = Drawing.new("Square"),
            Fill = Drawing.new("Square"),
            Text = Drawing.new("Text"),
        },
        Tracer = Drawing.new("Line"),
        Point = Drawing.new("Circle"),
        Skeleton = {},
    }
    for _, line in pairs(esp.Box) do
        line.Visible = false
        line.Color = Color3.fromRGB(255,255,255)
        line.Thickness = Settings.BoxThickness
    end
    esp.Name.Visible = false
    esp.Name.Center = true
    esp.Name.Size = 14
    esp.Name.Font = 2
    esp.Name.Outline = true
    esp.Name.Color = Color3.fromRGB(255,255,255)
    for _, obj in pairs(esp.Health) do
        obj.Visible = false
        if obj == esp.Health.Fill then
            obj.Filled = true
        elseif obj == esp.Health.Text then
            obj.Center = true
            obj.Size = 12
            obj.Font = 2
            obj.Outline = true
        end
    end
    esp.Tracer.Visible = false
    esp.Tracer.Color = Color3.fromRGB(255,255,255)
    esp.Tracer.Thickness = Settings.TracerThickness
    esp.Point.Visible = false
    esp.Point.Radius = Settings.PointSize
    esp.Point.Thickness = 1
    esp.Point.Filled = true
    esp.Point.NumSides = 20
    local boneNames = {
        "Head", "UpperTorso", "LowerTorso",
        "LeftUpperArm", "LeftLowerArm", "LeftHand",
        "RightUpperArm", "RightLowerArm", "RightHand",
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
        "RightUpperLeg", "RightLowerLeg", "RightFoot"
    }
    for _, name in ipairs(boneNames) do
        local line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.fromRGB(255,255,255)
        line.Thickness = Settings.SkeletonThickness
        esp.Skeleton[name] = line
    end
    Drawings[player] = esp
end

local function RemoveESP(player)
    local esp = Drawings[player]
    if esp then
        for _, line in pairs(esp.Box) do line:Remove() end
        esp.Name:Remove()
        for _, obj in pairs(esp.Health) do obj:Remove() end
        esp.Tracer:Remove()
        esp.Point:Remove()
        for _, line in pairs(esp.Skeleton) do line:Remove() end
        Drawings[player] = nil
    end
end

local function GetBonePositions(character)
    local bones = {}
    local function getPart(name, alt)
        local part = character:FindFirstChild(name)
        if not part and alt then part = character:FindFirstChild(alt) end
        return part
    end
    bones.Head = getPart("Head")
    bones.UpperTorso = getPart("UpperTorso", "Torso")
    bones.LowerTorso = getPart("LowerTorso", "Torso")
    bones.LeftUpperArm = getPart("LeftUpperArm", "Left Arm")
    bones.LeftLowerArm = getPart("LeftLowerArm", "Left Arm")
    bones.LeftHand = getPart("LeftHand", "Left Arm")
    bones.RightUpperArm = getPart("RightUpperArm", "Right Arm")
    bones.RightLowerArm = getPart("RightLowerArm", "Right Arm")
    bones.RightHand = getPart("RightHand", "Right Arm")
    bones.LeftUpperLeg = getPart("LeftUpperLeg", "Left Leg")
    bones.LeftLowerLeg = getPart("LeftLowerLeg", "Left Leg")
    bones.LeftFoot = getPart("LeftFoot", "Left Leg")
    bones.RightUpperLeg = getPart("RightUpperLeg", "Right Leg")
    bones.RightLowerLeg = getPart("RightLowerLeg", "Right Leg")
    bones.RightFoot = getPart("RightFoot", "Right Leg")
    return bones
end

local function GetTracerOrigin()
    local origin = Settings.TracerOrigin
    if origin == "Bottom" then
        return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
    elseif origin == "Top" then
        return Vector2.new(Camera.ViewportSize.X/2, 0)
    elseif origin == "Mouse" then
        return UserInputService:GetMouseLocation()
    else
        return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    end
end

local function UpdateESP(player)
    if not Settings.Enabled then return end
    local esp = Drawings[player]
    if not esp then return end

    local character = player.Character
    if not character then
        for _, line in pairs(esp.Box) do line.Visible = false end
        esp.Name.Visible = false
        for _, obj in pairs(esp.Health) do obj.Visible = false end
        esp.Tracer.Visible = false
        esp.Point.Visible = false
        for _, line in pairs(esp.Skeleton) do line.Visible = false end
        return
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        for _, line in pairs(esp.Box) do line.Visible = false end
        esp.Name.Visible = false
        for _, obj in pairs(esp.Health) do obj.Visible = false end
        esp.Tracer.Visible = false
        esp.Point.Visible = false
        for _, line in pairs(esp.Skeleton) do line.Visible = false end
        return
    end

    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        for _, line in pairs(esp.Box) do line.Visible = false end
        esp.Name.Visible = false
        for _, obj in pairs(esp.Health) do obj.Visible = false end
        esp.Tracer.Visible = false
        esp.Point.Visible = false
        for _, line in pairs(esp.Skeleton) do line.Visible = false end
        return
    end

    local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude

    if not onScreen or distance > Settings.MaxDistance then
        for _, line in pairs(esp.Box) do line.Visible = false end
        esp.Name.Visible = false
        for _, obj in pairs(esp.Health) do obj.Visible = false end
        esp.Tracer.Visible = false
        esp.Point.Visible = false
        for _, line in pairs(esp.Skeleton) do line.Visible = false end
        return
    end

    if Settings.TeamCheck and IsTeammate(player) then
        for _, line in pairs(esp.Box) do line.Visible = false end
        esp.Name.Visible = false
        for _, obj in pairs(esp.Health) do obj.Visible = false end
        esp.Tracer.Visible = false
        esp.Point.Visible = false
        for _, line in pairs(esp.Skeleton) do line.Visible = false end
        return
    end

    local color = GetPlayerColor(player)

    local size = character:GetExtentsSize()
    local cf = rootPart.CFrame
    local top = Camera:WorldToViewportPoint((cf * CFrame.new(0, size.Y/2, 0)).Position)
    local bottom = Camera:WorldToViewportPoint((cf * CFrame.new(0, -size.Y/2, 0)).Position)

    if top.Z < 0 or bottom.Z < 0 then
        for _, line in pairs(esp.Box) do line.Visible = false end
        return
    end

    local screenSize = bottom.Y - top.Y
    local boxWidth = screenSize * 0.65
    local boxPos = Vector2.new(top.X - boxWidth/2, top.Y)
    local boxSize = Vector2.new(boxWidth, screenSize)

    if Settings.BoxESP then
        local b = esp.Box
        if Settings.BoxStyle == "Corner" then
            local cornerSize = boxWidth * 0.2
            b.TL.From = boxPos
            b.TL.To = boxPos + Vector2.new(cornerSize, 0)
            b.TL.Visible = true
            b.TR.From = boxPos + Vector2.new(boxSize.X, 0)
            b.TR.To = boxPos + Vector2.new(boxSize.X - cornerSize, 0)
            b.TR.Visible = true
            b.BL.From = boxPos + Vector2.new(0, boxSize.Y)
            b.BL.To = boxPos + Vector2.new(cornerSize, boxSize.Y)
            b.BL.Visible = true
            b.BR.From = boxPos + Vector2.new(boxSize.X, boxSize.Y)
            b.BR.To = boxPos + Vector2.new(boxSize.X - cornerSize, boxSize.Y)
            b.BR.Visible = true
            b.Left.From = boxPos
            b.Left.To = boxPos + Vector2.new(0, cornerSize)
            b.Left.Visible = true
            b.Right.From = boxPos + Vector2.new(boxSize.X, 0)
            b.Right.To = boxPos + Vector2.new(boxSize.X, cornerSize)
            b.Right.Visible = true
            b.Top.From = boxPos + Vector2.new(0, boxSize.Y)
            b.Top.To = boxPos + Vector2.new(0, boxSize.Y - cornerSize)
            b.Top.Visible = true
            b.Bottom.From = boxPos + Vector2.new(boxSize.X, boxSize.Y)
            b.Bottom.To = boxPos + Vector2.new(boxSize.X, boxSize.Y - cornerSize)
            b.Bottom.Visible = true
        else
            b.Left.From = boxPos
            b.Left.To = boxPos + Vector2.new(0, boxSize.Y)
            b.Left.Visible = true
            b.Right.From = boxPos + Vector2.new(boxSize.X, 0)
            b.Right.To = boxPos + Vector2.new(boxSize.X, boxSize.Y)
            b.Right.Visible = true
            b.Top.From = boxPos
            b.Top.To = boxPos + Vector2.new(boxSize.X, 0)
            b.Top.Visible = true
            b.Bottom.From = boxPos + Vector2.new(0, boxSize.Y)
            b.Bottom.To = boxPos + Vector2.new(boxSize.X, boxSize.Y)
            b.Bottom.Visible = true
            b.TL.Visible = false
            b.TR.Visible = false
            b.BL.Visible = false
            b.BR.Visible = false
        end
        for _, line in pairs(esp.Box) do
            if line.Visible then
                line.Color = color
                line.Thickness = Settings.BoxThickness
            end
        end
    else
        for _, line in pairs(esp.Box) do line.Visible = false end
    end

    if Settings.NameESP then
        local text = player.DisplayName
        if Settings.ShowDistance then
            text = text .. " (" .. math.floor(distance) .. "m)"
        end
        esp.Name.Text = text
        esp.Name.Position = Vector2.new(top.X, top.Y - 20)
        esp.Name.Color = color
        esp.Name.Visible = true
    else
        esp.Name.Visible = false
    end

    if Settings.HealthESP then
        local health = humanoid.Health
        local maxHealth = humanoid.MaxHealth
        local healthPercent = health / maxHealth
        local barHeight = screenSize * 0.8
        local barWidth = Settings.HealthBarWidth
        local barPos = Vector2.new(boxPos.X - barWidth - 2, boxPos.Y + (screenSize - barHeight)/2)

        esp.Health.Outline.Size = Vector2.new(barWidth, barHeight)
        esp.Health.Outline.Position = barPos
        esp.Health.Outline.Visible = true

        esp.Health.Fill.Size = Vector2.new(barWidth - 2, barHeight * healthPercent)
        esp.Health.Fill.Position = Vector2.new(barPos.X + 1, barPos.Y + barHeight * (1 - healthPercent))
        esp.Health.Fill.Color = Color3.fromRGB(255 - (255 * healthPercent), 255 * healthPercent, 0)
        esp.Health.Fill.Visible = true

        if Settings.ShowHealthText then
            esp.Health.Text.Text = math.floor(health)
            esp.Health.Text.Position = Vector2.new(barPos.X + barWidth + 2, barPos.Y + barHeight/2)
            esp.Health.Text.Visible = true
        else
            esp.Health.Text.Visible = false
        end
    else
        for _, obj in pairs(esp.Health) do obj.Visible = false end
    end

    if Settings.TracerESP then
        esp.Tracer.From = GetTracerOrigin()
        esp.Tracer.To = Vector2.new(pos.X, pos.Y)
        esp.Tracer.Color = color
        esp.Tracer.Visible = true
    else
        esp.Tracer.Visible = false
    end

    if Settings.PointESP then
        local head = character:FindFirstChild("Head")
        local headPos
        if head then
            headPos = Camera:WorldToViewportPoint(head.Position)
        else
            headPos = Camera:WorldToViewportPoint(rootPart.Position + Vector3.new(0, 2, 0))
        end
        esp.Point.Position = Vector2.new(headPos.X, headPos.Y)
        esp.Point.Color = color
        esp.Point.Radius = Settings.PointSize
        esp.Point.Visible = true
    else
        esp.Point.Visible = false
    end

    if Settings.SkeletonESP then
        local bones = GetBonePositions(character)
        local function drawLine(fromPart, toPart, line)
            if not fromPart or not toPart then
                line.Visible = false
                return
            end
            local fromPos = Camera:WorldToViewportPoint((fromPart.CFrame * CFrame.new(0,0,0)).Position)
            local toPos = Camera:WorldToViewportPoint((toPart.CFrame * CFrame.new(0,0,0)).Position)
            if fromPos.Z < 0 or toPos.Z < 0 then
                line.Visible = false
                return
            end
            line.From = Vector2.new(fromPos.X, fromPos.Y)
            line.To = Vector2.new(toPos.X, toPos.Y)
            line.Color = color
            line.Thickness = Settings.SkeletonThickness
            line.Visible = true
        end

        local skel = esp.Skeleton
        drawLine(bones.Head, bones.UpperTorso, skel.Head)
        drawLine(bones.UpperTorso, bones.LowerTorso, skel.UpperTorso)
        drawLine(bones.UpperTorso, bones.LeftUpperArm, skel.LeftUpperArm)
        drawLine(bones.LeftUpperArm, bones.LeftLowerArm, skel.LeftLowerArm)
        drawLine(bones.LeftLowerArm, bones.LeftHand, skel.LeftHand)
        drawLine(bones.UpperTorso, bones.RightUpperArm, skel.RightUpperArm)
        drawLine(bones.RightUpperArm, bones.RightLowerArm, skel.RightLowerArm)
        drawLine(bones.RightLowerArm, bones.RightHand, skel.RightHand)
        drawLine(bones.LowerTorso, bones.LeftUpperLeg, skel.LeftUpperLeg)
        drawLine(bones.LeftUpperLeg, bones.LeftLowerLeg, skel.LeftLowerLeg)
        drawLine(bones.LeftLowerLeg, bones.LeftFoot, skel.LeftFoot)
        drawLine(bones.LowerTorso, bones.RightUpperLeg, skel.RightUpperLeg)
        drawLine(bones.RightUpperLeg, bones.RightLowerLeg, skel.RightLowerLeg)
        drawLine(bones.RightLowerLeg, bones.RightFoot, skel.RightFoot)
    else
        for _, line in pairs(esp.Skeleton) do line.Visible = false end
    end
end

local function CleanupESP()
    for player, esp in pairs(Drawings) do
        for _, line in pairs(esp.Box) do line:Remove() end
        esp.Name:Remove()
        for _, obj in pairs(esp.Health) do obj:Remove() end
        esp.Tracer:Remove()
        esp.Point:Remove()
        for _, line in pairs(esp.Skeleton) do line:Remove() end
    end
    Drawings = {}
end

-- Создаём окно Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Unknown Threat ESP",
    LoadingTitle = "Unknown Threat ESP",
    LoadingSubtitle = "by Great | discord.gg/nTMYauyf59",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "UnknownThreatESP",
       FileName = "Settings"
    },
    Discord = {
       Enabled = false,
       Invite = "",
       RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
       Title = "Unknown Threat ESP",
       Subtitle = "Key System",
       Note = "No key required",
       FileName = "Key",
       SaveKey = false,
       GrabKeyFromSite = false,
       Key = {"Hello"}
    }
})

-- Создаём вкладки
local MainTab = Window:CreateTab("Main", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)
local ConfigTab = Window:CreateTab("Config", 4483362458)

-- Вкладка Main
local MainSection = MainTab:CreateSection("ESP Toggles")

MainSection:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = Settings.Enabled,
    Flag = "Enabled",
    Callback = function(v)
        Settings.Enabled = v
        SaveWorkspaceSetting("Enabled", v)
        if not v then
            for _, esp in pairs(Drawings) do
                for _, line in pairs(esp.Box) do line.Visible = false end
                esp.Name.Visible = false
                for _, obj in pairs(esp.Health) do obj.Visible = false end
                esp.Tracer.Visible = false
                esp.Point.Visible = false
                for _, line in pairs(esp.Skeleton) do line.Visible = false end
            end
        end
    end
})

MainSection:CreateToggle({
    Name = "Box ESP",
    CurrentValue = Settings.BoxESP,
    Flag = "BoxESP",
    Callback = function(v)
        Settings.BoxESP = v
        SaveWorkspaceSetting("BoxESP", v)
    end
})

MainSection:CreateToggle({
    Name = "Skeleton ESP",
    CurrentValue = Settings.SkeletonESP,
    Flag = "SkeletonESP",
    Callback = function(v)
        Settings.SkeletonESP = v
        SaveWorkspaceSetting("SkeletonESP", v)
    end
})

MainSection:CreateToggle({
    Name = "Name ESP",
    CurrentValue = Settings.NameESP,
    Flag = "NameESP",
    Callback = function(v)
        Settings.NameESP = v
        SaveWorkspaceSetting("NameESP", v)
    end
})

MainSection:CreateToggle({
    Name = "Health Bar",
    CurrentValue = Settings.HealthESP,
    Flag = "HealthESP",
    Callback = function(v)
        Settings.HealthESP = v
        SaveWorkspaceSetting("HealthESP", v)
    end
})

MainSection:CreateToggle({
    Name = "Tracer ESP",
    CurrentValue = Settings.TracerESP,
    Flag = "TracerESP",
    Callback = function(v)
        Settings.TracerESP = v
        SaveWorkspaceSetting("TracerESP", v)
    end
})

MainSection:CreateToggle({
    Name = "Head Point",
    CurrentValue = Settings.PointESP,
    Flag = "PointESP",
    Callback = function(v)
        Settings.PointESP = v
        SaveWorkspaceSetting("PointESP", v)
    end
})

MainSection:CreateToggle({
    Name = "Team Check",
    CurrentValue = Settings.TeamCheck,
    Flag = "TeamCheck",
    Callback = function(v)
        Settings.TeamCheck = v
        SaveWorkspaceSetting("TeamCheck", v)
    end
})

MainSection:CreateToggle({
    Name = "Show Distance",
    CurrentValue = Settings.ShowDistance,
    Flag = "ShowDistance",
    Callback = function(v)
        Settings.ShowDistance = v
        SaveWorkspaceSetting("ShowDistance", v)
    end
})

-- Вкладка Visuals
local VisualsSection = VisualsTab:CreateSection("Box Settings")

VisualsSection:CreateDropdown({
    Name = "Box Style",
    Options = {"Corner", "Full"},
    CurrentOption = Settings.BoxStyle,
    Flag = "BoxStyle",
    Callback = function(v)
        Settings.BoxStyle = v
        SaveWorkspaceSetting("BoxStyle", v)
    end
})

VisualsSection:CreateSlider({
    Name = "Box Thickness",
    Range = {1, 3},
    Increment = 1,
    CurrentValue = Settings.BoxThickness,
    Flag = "BoxThickness",
    Callback = function(v)
        Settings.BoxThickness = v
        SaveWorkspaceSetting("BoxThickness", v)
        for _, esp in pairs(Drawings) do
            for _, line in pairs(esp.Box) do
                line.Thickness = v
            end
        end
    end
})

local TracerSection = VisualsTab:CreateSection("Tracer Settings")

TracerSection:CreateDropdown({
    Name = "Tracer Origin",
    Options = {"Bottom", "Top", "Mouse", "Center"},
    CurrentOption = Settings.TracerOrigin,
    Flag = "TracerOrigin",
    Callback = function(v)
        Settings.TracerOrigin = v
        SaveWorkspaceSetting("TracerOrigin", v)
    end
})

TracerSection:CreateSlider({
    Name = "Tracer Thickness",
    Range = {1, 3},
    Increment = 1,
    CurrentValue = Settings.TracerThickness,
    Flag = "TracerThickness",
    Callback = function(v)
        Settings.TracerThickness = v
        SaveWorkspaceSetting("TracerThickness", v)
        for _, esp in pairs(Drawings) do
            esp.Tracer.Thickness = v
        end
    end
})

local HealthSection = VisualsTab:CreateSection("Health Settings")

HealthSection:CreateSlider({
    Name = "Health Bar Width",
    Range = {2, 10},
    Increment = 1,
    CurrentValue = Settings.HealthBarWidth,
    Flag = "HealthBarWidth",
    Callback = function(v)
        Settings.HealthBarWidth = v
        SaveWorkspaceSetting("HealthBarWidth", v)
    end
})

HealthSection:CreateToggle({
    Name = "Show Health Number",
    CurrentValue = Settings.ShowHealthText,
    Flag = "ShowHealthText",
    Callback = function(v)
        Settings.ShowHealthText = v
        SaveWorkspaceSetting("ShowHealthText", v)
    end
})

local PointSection = VisualsTab:CreateSection("Point Settings")

PointSection:CreateSlider({
    Name = "Point Size",
    Range = {2, 15},
    Increment = 1,
    CurrentValue = Settings.PointSize,
    Flag = "PointSize",
    Callback = function(v)
        Settings.PointSize = v
        SaveWorkspaceSetting("PointSize", v)
        for _, esp in pairs(Drawings) do
            esp.Point.Radius = v
        end
    end
})

local SkeletonSection = VisualsTab:CreateSection("Skeleton Settings")

SkeletonSection:CreateSlider({
    Name = "Skeleton Thickness",
    Range = {1, 3},
    Increment = 0.5,
    CurrentValue = Settings.SkeletonThickness,
    Flag = "SkeletonThickness",
    Callback = function(v)
        Settings.SkeletonThickness = v
        SaveWorkspaceSetting("SkeletonThickness", v)
        for _, esp in pairs(Drawings) do
            for _, line in pairs(esp.Skeleton) do
                line.Thickness = v
            end
        end
    end
})

-- Вкладка Settings
local SettingsSection = SettingsTab:CreateSection("General")

SettingsSection:CreateSlider({
    Name = "Max Distance",
    Range = {50, 2000},
    Increment = 10,
    CurrentValue = Settings.MaxDistance,
    Flag = "MaxDistance",
    Callback = function(v)
        Settings.MaxDistance = v
        SaveWorkspaceSetting("MaxDistance", v)
    end
})

SettingsSection:CreateToggle({
    Name = "Rainbow Mode",
    CurrentValue = Settings.RainbowEnabled,
    Flag = "RainbowEnabled",
    Callback = function(v)
        Settings.RainbowEnabled = v
        SaveWorkspaceSetting("RainbowEnabled", v)
    end
})

SettingsSection:CreateSlider({
    Name = "Rainbow Speed",
    Range = {0.1, 5},
    Increment = 0.1,
    CurrentValue = Settings.RainbowSpeed,
    Flag = "RainbowSpeed",
    Callback = function(v)
        Settings.RainbowSpeed = v
        SaveWorkspaceSetting("RainbowSpeed", v)
    end
})

local ColorsSection = SettingsTab:CreateSection("Role Colors")

ColorsSection:CreateColorPicker({
    Name = "Seeker / Killer",
    Color = Colors.Seeker,
    Flag = "SeekerColor",
    Callback = function(v)
        Colors.Seeker = v
        Colors.Killer = v
        SaveWorkspaceSetting("SeekerColor", v)
        SaveWorkspaceSetting("Killer", v)
    end
})

ColorsSection:CreateColorPicker({
    Name = "Hider",
    Color = Colors.Hider,
    Flag = "HiderColor",
    Callback = function(v)
        Colors.Hider = v
        SaveWorkspaceSetting("HiderColor", v)
    end
})

ColorsSection:CreateColorPicker({
    Name = "Innocent",
    Color = Colors.Innocent,
    Flag = "InnocentColor",
    Callback = function(v)
        Colors.Innocent = v
        SaveWorkspaceSetting("InnocentColor", v)
    end
})

ColorsSection:CreateColorPicker({
    Name = "Traitor",
    Color = Colors.Traitor,
    Flag = "TraitorColor",
    Callback = function(v)
        Colors.Traitor = v
        SaveWorkspaceSetting("TraitorColor", v)
    end
})

ColorsSection:CreateColorPicker({
    Name = "Police / SWAT / Sheriff",
    Color = Colors.Police,
    Flag = "PoliceColor",
    Callback = function(v)
        Colors.Police = v
        Colors.Swat = v
        Colors.Sheriff = v
        SaveWorkspaceSetting("PoliceColor", v)
        SaveWorkspaceSetting("Swat", v)
        SaveWorkspaceSetting("Sheriff", v)
    end
})

ColorsSection:CreateColorPicker({
    Name = "Juggernaut",
    Color = Colors.Juggernaut,
    Flag = "JuggernautColor",
    Callback = function(v)
        Colors.Juggernaut = v
        SaveWorkspaceSetting("JuggernautColor", v)
    end
})

ColorsSection:CreateColorPicker({
    Name = "No Role (Spawn)",
    Color = Colors.NoRole,
    Flag = "NoRoleColor",
    Callback = function(v)
        Colors.NoRole = v
        SaveWorkspaceSetting("NoRoleColor", v)
    end
})

ColorsSection:CreateColorPicker({
    Name = "Unknown (fallback)",
    Color = Colors.Unknown,
    Flag = "UnknownColor",
    Callback = function(v)
        Colors.Unknown = v
        SaveWorkspaceSetting("UnknownColor", v)
    end
})

-- Вкладка Config
local ConfigSection = ConfigTab:CreateSection("Save & Load")

ConfigSection:CreateButton({
    Name = "Unload ESP",
    Callback = function()
        CleanupESP()
        if Window and Window.Destroy then
            Window:Destroy()
        end
        Drawings = nil
        Settings = nil
    end
})

-- Основной цикл
task.spawn(function()
    while task.wait(0.05) do
        Colors.Rainbow = Color3.fromHSV(tick() * Settings.RainbowSpeed % 1, 1, 1)
    end
end)

local renderConnection
renderConnection = RunService.RenderStepped:Connect(function()
    if not Settings.Enabled then
        for _, esp in pairs(Drawings) do
            for _, line in pairs(esp.Box) do line.Visible = false end
            esp.Name.Visible = false
            for _, obj in pairs(esp.Health) do obj.Visible = false end
            esp.Tracer.Visible = false
            esp.Point.Visible = false
            for _, line in pairs(esp.Skeleton) do line.Visible = false end
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not Drawings[player] then
                CreateESP(player)
            end
            UpdateESP(player)
        end
    end
end)

Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

Rayfield:Notify({
    Title = "Unknown Threat ESP",
    Content = "Loaded! Settings saved. Join discord.gg/nTMYauyf59",
    Duration = 4
})
