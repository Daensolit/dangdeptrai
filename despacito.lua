local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Hack Arsenal - HACKGAMEVIP",
   LoadingTitle = "Đang Tải Arsenal Hack...",
   LoadingSubtitle = "Made By Daensolit",
   ShowText = "Menu",
   Theme = "Default",
   ToggleUIKeybind = Enum.KeyCode.K,
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = true,
   KeySettings = {
      Title = "HACKGAMEVIP Key System",
      Subtitle = "Liên hệ Admin để lấy Key",
      Note = "Nhập đúng Key để vào menu",
      FileName = "HGV_Arsenal_Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"daensolit2025", "vippro123", "keyfree"}
   }
})

local Tab = Window:CreateTab("Arsenal Hack", 4483362458)

-- Cái này là setting sẵn
local ESPEnabled = false
local AimbotEnabled = false
local AimbotFOV = 150
local SmoothFactor = 5
local AutoFire = false
local TargetPart = "Head"

-- UI
Tab:CreateToggle({ Name = "ESP", CurrentValue = false, Callback = function(v) ESPEnabled = v end })
Tab:CreateToggle({ Name = "Aimbot", CurrentValue = false, Callback = function(v) AimbotEnabled = v end })

Tab:CreateSlider({
   Name = "Aimbot FOV",
   Range = {30, 400}, Increment = 10, Suffix = "px",
   CurrentValue = AimbotFOV,
   Callback = function(v)
      AimbotFOV = v
      if FOVCircle then FOVCircle.Radius = v end
   end
})

Tab:CreateSlider({
   Name = "Smooth Aimbot",
   Range = {1, 10}, Increment = 1,
   CurrentValue = SmoothFactor,
   Callback = function(v) SmoothFactor = v end
})

Tab:CreateToggle({ Name = "Auto Fire", CurrentValue = false, Callback = function(v) AutoFire = v end })
Tab:CreateDropdown({ Name = "Aim Target", Options = {"Head", "Neck", "HumanoidRootPart"}, CurrentOption = "Head", Callback = function(opt) TargetPart = opt end })

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Setup vẽ
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
      for _, obj in ipairs(objs) do if obj.Remove then obj:Remove() end end
   end
   drawings = {}
end

-- Enemy Check
local function isEnemy(p)
   if p == LocalPlayer then return false end
   if not p.Character or not p.Character:FindFirstChild("Humanoid") then return false end
   if p.Team ~= nil and LocalPlayer.Team ~= nil and p.Team == LocalPlayer.Team then return false end
   return true
end

-- Check nhận diện
local function isVisible(part)
   if not part or not part:IsA("BasePart") then return false end
   local origin = Camera.CFrame.Position
   local dir = (part.Position - origin)
   local rayParams = RaycastParams.new()
   rayParams.FilterType = Enum.RaycastFilterType.Blacklist
   rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
   rayParams.IgnoreWater = true
   local result = workspace:Raycast(origin, dir, rayParams)
   return not result or result.Instance:IsDescendantOf(part.Parent)
end

local function getClosestVisibleEnemy()
   local closest, shortest = nil, AimbotFOV
   for _, p in ipairs(Players:GetPlayers()) do
      if isEnemy(p) and p.Character:FindFirstChild(TargetPart) then
         local part = p.Character[TargetPart]
         local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
         if onScreen and isVisible(part) then
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - Camera.ViewportSize / 2).Magnitude
            if dist < shortest then
               closest, shortest = part, dist
            end
         end
      end
   end
   return closest
end

-- AutoFire
local function pressMouse()
   if UserInputService.TouchEnabled then
      local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
      if tool and tool:FindFirstChild("Handle") then tool:Activate() end
   else
      mouse1press() wait() mouse1release()
   end
end

RunService.RenderStepped:Connect(function()
   FOVCircle.Position = Camera.ViewportSize / 2
   FOVCircle.Visible = AimbotEnabled and ESPEnabled
   FOVCircle.Radius = AimbotFOV

   if not ESPEnabled then clearDrawings() return end
   clearDrawings()

   for _, p in ipairs(Players:GetPlayers()) do
      if isEnemy(p) and p.Character:FindFirstChild("HumanoidRootPart") then
         local head = p.Character.Head
         local hrp = p.Character.HumanoidRootPart
         local part = p.Character:FindFirstChild(TargetPart) or hrp
         local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
         local headPos = Camera:WorldToViewportPoint(head.Position)
         local height = (headPos - pos).Y
         local width = height / 2
         local boxPos = Vector2.new(pos.X - width/2, pos.Y - height/2)

         if onScreen then
            local vis = isVisible(part)

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
         if AutoFire then pressMouse() end
      end
   end
end)
