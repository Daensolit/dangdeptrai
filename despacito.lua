local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Hack Arsenal - HACKGAMEVIP",
   LoadingTitle = "Đang Tải Arsenal Hacks...",
   LoadingSubtitle = "Made By Daensolit",
   ShowText = "Menu",
   Theme = "Default",
   ToggleUIKeybind = "K",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Arsenal Hack", 4483362458)

local ESPEnabled = false
local AimbotEnabled = false
local AimbotFOV = 150

Tab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Callback = function(Value)
      ESPEnabled = Value
   end
})

Tab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Callback = function(Value)
      AimbotEnabled = Value
   end
})

Tab:CreateSlider({
   Name = "Aimbot FOV",
   Range = {30, 400},
   Increment = 10,
   Suffix = "px",
   CurrentValue = AimbotFOV,
   Callback = function(Value)
      AimbotFOV = Value
      FOVCircle.Radius = Value
   end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Drawing = Drawing or getgenv().Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.new(1, 1, 1)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 64
FOVCircle.Radius = AimbotFOV
FOVCircle.Transparency = 0.6
FOVCircle.Filled = false

local drawings = {}

local function clearDrawings()
   for _, v in pairs(drawings) do
      for _, obj in pairs(v) do
         if obj.Remove then obj:Remove() end
      end
   end
   drawings = {}
end

local function getClosestEnemy()
   local closest, shortest = nil, AimbotFOV
   for _, p in ipairs(Players:GetPlayers()) do
      if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Head") then
         local head = p.Character.Head
         local pos, onscreen = Camera:WorldToViewportPoint(head.Position)
         if onscreen then
            local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
            if dist < shortest then
               shortest = dist
               closest = head
            end
         end
      end
   end
   return closest
end

RunService.RenderStepped:Connect(function()
   FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
   FOVCircle.Visible = AimbotEnabled

   if not ESPEnabled then
      clearDrawings()
      return
   end

   clearDrawings()

   for _, p in ipairs(Players:GetPlayers()) do
      if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team and p.Character and p.Character:FindFirstChild("Head") and p.Character:FindFirstChild("HumanoidRootPart") then
         local head = p.Character.Head
         local hrp = p.Character.HumanoidRootPart
         local pos, onscreen = Camera:WorldToViewportPoint(hrp.Position)
         local headPos = Camera:WorldToViewportPoint(head.Position)
         local size = Vector2.new(50, 100)

         if onscreen then
            local box = Drawing.new("Square")
            box.Size = size
            box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
            box.Color = Color3.fromRGB(255, 0, 0)
            box.Thickness = 1.5
            box.Transparency = 0.9
            box.Visible = true

            local name = Drawing.new("Text")
            name.Text = p.Name
            name.Size = 13
            name.Center = true
            name.Outline = true
            name.Color = Color3.new(1, 1, 1)
            name.Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 15)
            name.Visible = true

            local line = Drawing.new("Line")
            line.From = Vector2.new(Camera.ViewportSize.X/2, 0)
            line.To = Vector2.new(pos.X, pos.Y - size.Y/2)
            line.Color = Color3.new(1, 1, 1)
            line.Thickness = 1.5
            line.Transparency = 0.7
            line.Visible = true

            drawings[p] = {box, name, line}
         end
      end
   end

   if AimbotEnabled then
      local target = getClosestEnemy()
      if target then
         Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
      end
   end
end)
