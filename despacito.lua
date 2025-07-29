repeat wait() until game:IsLoaded() and game.Players.LocalPlayer

-- Detect PC vs Mobile
local UserInputService = game:GetService("UserInputService")
local isMobile = UserInputService.TouchEnabled

-- UI Library (Kavo UI)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/o5u3/UILib/main/Kavo"))()
local Window = Library.CreateLib("HACKGAMEVIP - by Daensolit", "Midnight")

-- Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPEnabled = false
local AimbotEnabled = false
local AimbotFOV = 150
local SmoothFactor = 5
local AutoFire = false
local TargetPart = "Head"

-- Drawing Circle
local Drawing = Drawing or getgenv().Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = AimbotFOV
FOVCircle.Transparency = 0.6
FOVCircle.Filled = false
FOVCircle.Color = Color3.fromRGB(255,255,255)
FOVCircle.Visible = false

-- UI Tabs
local Tab = Window:NewTab("Arsenal Hack")
local Section = Tab:NewSection("Aimbot & ESP")

Section:NewToggle("ESP", "Hiện Box kẻ địch", function(v) ESPEnabled = v end)
Section:NewToggle("Aimbot", "Tự aim", function(v) AimbotEnabled = v end)
Section:NewSlider("FOV", "Vòng ngắm", 400, 30, function(v)
    AimbotFOV = v
    FOVCircle.Radius = v
end)
Section:NewSlider("Smooth", "Mượt khi aim", 10, 1, function(v)
    SmoothFactor = v
end)
Section:NewToggle("Auto Fire", "Tự bắn khi thấy địch", function(v) AutoFire = v end)
Section:NewDropdown("Aim Target", "Chọn bộ phận", {"Head", "Neck", "HumanoidRootPart"}, function(opt)
    TargetPart = opt
end)

-- Reinit nếu reset nhân vật
LocalPlayer.CharacterAdded:Connect(function()
    wait(1)
    Camera = workspace.CurrentCamera
end)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    wait(1)
    Camera = workspace.CurrentCamera
end)

-- Helper
local drawings = {}
local function clearDrawings()
    for _, v in pairs(drawings) do
        for _, d in pairs(v) do
            if d.Remove then d:Remove() end
        end
    end
    drawings = {}
end

local function isVisible(part)
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * 1000
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    local result = workspace:Raycast(origin, direction, rayParams)
    return result and result.Instance and part:IsDescendantOf(result.Instance:FindFirstAncestorOfClass("Model"))
end

local function getClosestEnemy()
    local closest, shortest = nil, AimbotFOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild(TargetPart) then
            local part = p.Character[TargetPart]
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen and isVisible(part) then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = part
                end
            end
        end
    end
    return closest
end

-- Main loop
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = AimbotFOV
    FOVCircle.Visible = AimbotEnabled and ESPEnabled

    if not ESPEnabled then clearDrawings() return end
    clearDrawings()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local head = p.Character:FindFirstChild("Head")
            local target = p.Character:FindFirstChild(TargetPart)
            if hrp and head and target then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local headPos = Camera:WorldToViewportPoint(head.Position)
                local height = (headPos - pos).Y
                local width = height / 2
                local boxPos = Vector2.new(pos.X - width/2, pos.Y - height/2)

                if onScreen then
                    local vis = isVisible(target)
                    local box = Drawing.new("Square")
                    box.Size = Vector2.new(width, height)
                    box.Position = boxPos
                    box.Color = vis and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)
                    box.Thickness = 1.5
                    box.Filled = false
                    box.Visible = true

                    local text = Drawing.new("Text")
                    text.Text = p.Name
                    text.Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
                    text.Size = 13
                    text.Center = true
                    text.Outline = true
                    text.Color = Color3.new(1,1,1)
                    text.Visible = true

                    local line = Drawing.new("Line")
                    line.From = Vector2.new(Camera.ViewportSize.X/2, 0)
                    line.To = Vector2.new(pos.X, pos.Y - height/2)
                    line.Color = Color3.fromRGB(255,255,255)
                    line.Thickness = 1.5
                    line.Transparency = 0.7
                    line.Visible = true

                    drawings[p] = {box, text, line}
                end
            end
        end
    end

    if AimbotEnabled and ESPEnabled then
        local target = getClosestEnemy()
        if target then
            local dir = (target.Position - Camera.CFrame.Position).Unit
            local pos = Camera.CFrame.Position + dir
            if isMobile then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            else
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), SmoothFactor / 10)
            end

            if AutoFire then
                mouse1press()
                wait()
                mouse1release()
            end
        end
    end
end)
