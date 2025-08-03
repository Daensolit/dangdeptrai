local IsLibInRunning = true
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Grow A Garden Script",
   Icon = 0,
   LoadingTitle = "HACKGAMEVIP",
   LoadingSubtitle = "By HACKGAMEVIP",
   ShowText = "HACKGAMEVIP",
   Theme = "Default",

   ToggleUIKeybind = "K",

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "HACKGAMEVIP"
   },

   Discord = {
      Enabled = true,
      Invite = "https://discord.gg/kuKzAwstP3",
      RememberJoins = true
   },

   KeySystem = false,
   KeySettings = {
      Title = "",
      Subtitle = "",
      Note = "",
      FileName = "",
      SaveKey = false,
      GrabKeyFromSite = false,
      Key = {}
   }
})

local Farm = Window:CreateTab("Tự Động Cày Cuốc", 7733661326)
local Other = Window:CreateTab("Khác", 7733661326)

local player = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tycoon
for _, v in pairs(Workspace.Farm:GetChildren()) do
    if v.Important.Data.Owner.Value == player.Name then
        tycoon = v
        break
    end
end
local farmable = tycoon.Important.Plant_Locations:GetChildren()

local list_proximity_seeds = {}

local function scanPlantType(plant, plantType)
    if list_proximity_seeds[plantType] then return end
    for _, child in pairs(plant:GetDescendants()) do
        if child:IsA("ProximityPrompt") then
            local relativeCFrame = plant:GetPivot():ToObjectSpace(child.Parent.CFrame)
            list_proximity_seeds[plantType] = relativeCFrame
            break
        end
    end
end

for _, plant in pairs(tycoon.Important.Plants_Physical:GetChildren()) do
    scanPlantType(plant, plant.Name)
end

tycoon.Important.Plants_Physical.ChildAdded:Connect(function(plant)
    scanPlantType(plant, plant.Name)
end)

local Label = Farm:CreateLabel("Trồng Trọt")

local auto_plant_seeds = false
local Toggle_APS = Farm:CreateToggle({
    Name = "Tự Động Trồng Trọt",
    CurrentValue = false,
    Callback = function(Value)
        auto_plant_seeds = Value
    end,
})

local auto_harvest_crops = false
local Toggle_AHC = Farm:CreateToggle({
    Name = "Tự Động Thu Hoạch",
    CurrentValue = false,
    Callback = function(Value)
        auto_harvest_crops = Value
    end,
})

local Label = Farm:CreateLabel("Hạt Giống")

local function GetSeeds(isName)
    local seeds = {}
    for _, v in pairs(player.PlayerGui.Seed_Shop.Frame.ScrollingFrame:GetChildren()) do
        if #v:GetChildren() >= 1 then
            if isName then
                table.insert(seeds, v.Name)
            else
                table.insert(seeds, v)
            end
        end
    end
    if isName then table.sort(seeds) end
    return seeds
end

local list_seeds = {}
local Dropdown_S = Farm:CreateDropdown({
    Name = "Hạt Giống",
    Options = GetSeeds(true),
    CurrentOption = {""},
    MultipleOptions = true,
    Callback = function(Option)
        list_seeds = {}
        for i, v in pairs(Option) do list_seeds[i] = v end
    end,
})

local Button_BS = Farm:CreateButton({
    Name = "Mua Hạt Giống",
    Callback = function()
        for i=1, #list_seeds do
            if list_seeds[i] ~= "" then
                local args = { list_seeds[i] }
                ReplicatedStorage.GameEvents.BuySeedStock:FireServer(unpack(args))
            end
        end
    end,
})

local auto_buy_seeds = false
local Toggle_ABS = Farm:CreateToggle({
    Name = "Tự Động Mua Hạt Giống",
    CurrentValue = false,
    Callback = function(Value)
        auto_buy_seeds = Value
    end,
})

local Label = Farm:CreateLabel("Kiếm Tiền")

local auto_sell = false
local Toggle_AS = Farm:CreateToggle({
    Name = "Tự Động Bán",
    CurrentValue = false,
    Callback = function(Value)
        auto_sell = Value
    end,
})

local delay_auto_sell = 5
local Input_ATS = Farm:CreateInput({
    Name = "Độ Trễ Tự Động Bán",
    CurrentValue = "5",
    PlaceholderText = "",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        delay_auto_sell = tonumber(Text)
    end,
})

local Button_DL = Other:CreateButton({
    Name = "Xóa Giao Diện",
    Callback = function()
        Rayfield:Destroy()
        IsLibInRunning = false
    end,
})

local seeds_list = GetSeeds(false)
local function isSeedsInList(seeds)
    for _, v in pairs(list_seeds) do
        if v == seeds then
            return true
        end
    end
    return false
end

local loop_auto_sell = 0

while IsLibInRunning do
    if auto_plant_seeds then
        for _, v in pairs(player.Backpack:GetChildren()) do
            if v.Name:find("Seed") then
                local new_parent = Workspace:FindFirstChild(player.Name)
                local last_parent = v.Parent
                v.Parent = new_parent
                local seeds = string.match(v.Name, "^(.+) Seed %[X%d+%]")
                local seedCount = tonumber(string.match(v.Name, "%[X(%d+)%]"))
                local farm = farmable[math.random(1, #farmable)]
                local size = farm.Size
                local cframe = farm.CFrame
                local localX = (math.random() - 0.5) * size.X
                local localY = size.Y
                local localZ = (math.random() - 0.5) * size.Z
                local localPos = Vector3.new(localX, localY, localZ)
                local worldPos = cframe * localPos
                local args = {
                    Vector3.new(worldPos.X, worldPos.Y, worldPos.Z),
                    seeds
                }
                ReplicatedStorage.GameEvents.Plant_RE:FireServer(unpack(args))
                wait(0.1)
                for _, i in pairs(new_parent:GetChildren()) do
                    if i.Name:find("Seed") then i.Parent = last_parent end
                end
            end
        end
    end
    if auto_harvest_crops then
        local plants = tycoon.Important.Plants_Physical:GetChildren()
        for _, plant in pairs(plants) do
            local relativeCFrame = list_proximity_seeds[plant.Name]
            if relativeCFrame then
                local prompt = plant:FindFirstChild("ProximityPrompt", true)
                if prompt and prompt.Parent ~= nil then
                    local last_cframe = player.Character.HumanoidRootPart.CFrame
                    local absoluteCFrame = plant:GetPivot() * relativeCFrame
                    player.Character.HumanoidRootPart.CFrame = absoluteCFrame * CFrame.new(0, 3, 0)
                    fireproximityprompt(prompt)
                    wait(0.1)
                    player.Character.HumanoidRootPart.CFrame = last_cframe
                end
            end
        end
    end
    if auto_buy_seeds then
        for _, v in pairs(seeds_list) do
            if v.Main_Frame.Stock_Text.Text ~= "X0 Stock" and isSeedsInList(v.Name) then
                local args = { v.Name }
                ReplicatedStorage.GameEvents.BuySeedStock:FireServer(unpack(args))
            end
        end
    end
    if auto_sell then
        if loop_auto_sell >= (delay_auto_sell / 0.1) then
            local last_cframe = player.Character.HumanoidRootPart.CFrame
            player.Character.HumanoidRootPart.CFrame = CFrame.new(86.5806351, 2.99999976, 0.426780432)
            wait(0.25)
            ReplicatedStorage.GameEvents.Sell_Inventory:FireServer()
            player.Character.HumanoidRootPart.CFrame = last_cframe
            loop_auto_sell = 0
        else
            loop_auto_sell = loop_auto_sell + 1
        end
    end
    wait(0.1)
end