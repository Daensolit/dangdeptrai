local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Hack Arsenal - HACKGAMEVIP",
   LoadingTitle = "Đang Tải Arsenal Hack...",
   LoadingSubtitle = "Made By Daensolit",
   ShowText = "Menu",
   Theme = "Default",
   ToggleUIKeybind = Enum.KeyCode.K,
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Arsenal Hack", 4483362458)

local ESPEnabled = false
local AimbotEnabled = false
local AimbotFOV = 150
local SmoothFactor = 5
local AutoFire = false
local TargetPart = "Head"

Tab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Callback = function(Value) ESPEnabled = Value end
})

Tab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Callback = function(Value) AimbotEnabled = Value end
})

Tab:CreateSlider({
   Name = "Aimbot FOV",
   Range = {30, 400},
   Increment = 10,
   Suffix = "px",
   CurrentValue = AimbotFOV,
   Callback = function(Value) AimbotFOV = Value end
})

Tab:CreateSlider({
   Name = "Smooth Aimbot",
   Range = {1, 10},
   Increment = 1,
   CurrentValue = SmoothFactor,
   Callback = function(Value) SmoothFactor = Value end
})

Tab:CreateToggle({
   Name = "Auto Fire",
   CurrentValue = false,
   Callback = function(Value) AutoFire = Value end
})

Tab:CreateDropdown({
   Name = "Aim Target",
   Options = {"Head", "Neck", "HumanoidRootPart"},
   CurrentOption = "Head",
   Callback = function(Option) TargetPart = Option end
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Transparency = 0.6
FOVCircle.Filled = false
FOVCircle.Radius = AimbotFOV

local drawings = {}

local function clearDrawings()
   for _, objs in pairs(drawings) do
      for _, d in ipairs(objs) do if d.Remove then d:Remove() end end
   end
   drawings = {}
end

local function isVisible(part)
   local origin = Camera.CFrame.Position
   local direction = (part.Position - origin).Unit * 1000
   local rayParams = RaycastParams.new()
   rayParams.FilterType = Enum.RaycastFilterType.Blacklist
   rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
   local result = workspace:Raycast(origin, direction, rayParams)
   return result and result.Instance and part:IsDescendantOf(result.Instance:FindFirstAncestorOfClass("Model"))
end

local function getClosestVisibleEnemy()
   local closest = nil
   local shortest = AimbotFOV
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

-- AutoFire fix
local function pressMouse()
   if UserInputService.TouchEnabled then
      -- Mobile không dùng mouse1press được
      local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
      if tool and tool:FindFirstChild("Handle") then
         tool:Activate()
      end
   else
      -- PC
      mouse1press()
      wait()
      mouse1release()
   end
end

RunService.RenderStepped:Connect(function()
   FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
   FOVCircle.Visible = AimbotEnabled and ESPEnabled
   FOVCircle.Radius = AimbotFOV

   if not ESPEnabled then
      clearDrawings()
      return
   end

   clearDrawings()

   for _, p in ipairs(Players:GetPlayers()) do
      if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("HumanoidRootPart") then
         local head = p.Character.Head
         local hrp = p.Character.HumanoidRootPart
         local target = p.Character:FindFirstChild(TargetPart)

         local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
         local headPos = Camera:WorldToViewportPoint(head.Position)
         local height = (headPos - pos).Y
         local width = height / 2
         local boxPos = Vector2.new(pos.X - width/2, pos.Y - height/2)

         if onscreen then
            local vis = isVisible(target)
            local box = Drawing.new("Square")
            box.Size = Vector2.new(width, height)
            box.Position = boxPos
            box.Color = vis and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            box.Thickness = 1.5
            box.Filled = false
            box.Visible = true

            local name = Drawing.new("Text")
            name.Text = p.Name
            name.Size = 13
            name.Center = true
            name.Outline = true
            name.Color = Color3.new(1, 1, 1)
            name.Position = Vector2.new(pos.X, pos.Y - height/2 - 15)
            name.Visible = true

            local line = Drawing.new("Line")
            line.From = Vector2.new(Camera.ViewportSize.X/2, 0)
            line.To = Vector2.new(pos.X, pos.Y - height/2)
            line.Color = Color3.new(1, 1, 1)
            line.Thickness = 1.5
            line.Transparency = 0.7
            line.Visible = true

            drawings[p] = {box, name, line}
         end
      end
   end

   if AimbotEnabled and ESPEnabled then
      local target = getClosestVisibleEnemy()
      if target and isVisible(target) then
         local direction = (target.Position - Camera.CFrame.Position).Unit
         local newPos = Camera.CFrame.Position + direction
         Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, newPos), SmoothFactor / 10)

         if AutoFire then
            pressMouse()
         end
      end
   end
end)
