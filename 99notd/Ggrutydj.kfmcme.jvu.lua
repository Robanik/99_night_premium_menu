--// 99 Nights in the Forest Script with Rayfield GUI v7 //--
-- Created by ROBANIK, enhanced heart animation, added Auto tab for tree chopping
-- Credit: BY ROBANIK

-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Window Setup
local Window = Rayfield:CreateWindow({
    Name = "99 Nights Bring Hub",
    LoadingTitle = "gptr 1.5 flash Edition",
    LoadingSubtitle = "by ROBANIK",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "99NightsForest",
        FileName = "gptr_bring_v7"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Variables for Original Home Tab
local teleportTargets = {
    "Alien", "Alien Chest", "Alien Shelf", "Alpha Wolf", "Alpha Wolf Pelt", "Anvil Base", "Apple", "Bandage", "Bear", "Berry",
    "Bolt", "Broken Fan", "Broken Microwave", "Bunny", "Bunny Foot", "Cake", "Carrot", "Chair Set", "Chest", "Chilli",
    "Coal", "Coin Stack", "Crossbow Cultist", "Cultist", "Cultist Gem", "Deer", "Fuel Canister", "Giant Sack", "Good Axe", "Iron Body",
    "Item Chest", "Item Chest2", "Item Chest3", "Item Chest4", "Item Chest6", "Laser Fence Blueprint", "Laser Sword", "Leather Body", "Log", "Lost Child",
    "Lost Child2", "Lost Child3", "Lost Child4", "Medkit", "Meat? Sandwich", "Morsel", "Old Car Engine", "Old Flashlight", "Old Radio", "Oil Barrel",
    "Raygun", "Revolver", "Revolver Ammo", "Rifle", "Rifle Ammo", "Riot Shield", "Sapling", "Seed Box", "Sheet Metal", "Spear",
    "Steak", "Stronghold Diamond Chest", "Tyre", "UFO Component", "UFO Junk", "Washing Machine", "Wolf", "Wolf Corpse", "Wolf Pelt"
}
local AimbotTargets = {"Alien", "Alpha Wolf", "Wolf", "Crossbow Cultist", "Cultist", "Bunny", "Bear", "Polar Bear"}
local espEnabled = false
local npcESPEnabled = false
local ignoreDistanceFrom = Vector3.new(0, 0, 0)
local minDistance = 50
local AutoTreeFarmEnabled = false

-- Click simulation
local VirtualInputManager = game:GetService("VirtualInputManager")
function mouse1click()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Aimbot FOV Circle
local AimbotEnabled = false
local FOVRadius = 100
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(128, 255, 0)
FOVCircle.Thickness = 1
FOVCircle.Radius = FOVRadius
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.Visible = false

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

-- ESP Function
local function createESP(item)
    local adorneePart
    if item:IsA("Model") then
        if item:FindFirstChildWhichIsA("Humanoid") then return end
        adorneePart = item:FindFirstChildWhichIsA("BasePart")
    elseif item:IsA("BasePart") then
        adorneePart = item
    else
        return
    end

    if not adorneePart then return end

    local distance = (adorneePart.Position - ignoreDistanceFrom).Magnitude
    if distance < minDistance then return end

    if not item:FindFirstChild("ESP_Billboard") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Billboard"
        billboard.Adornee = adorneePart
        billboard.Size = UDim2.new(0, 50, 0, 20)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 2, 0)

        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = item.Name
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        billboard.Parent = item
    end

    if not item:FindFirstChild("ESP_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = Color3.fromRGB(255, 85, 0)
        highlight.OutlineColor = Color3.fromRGB(0, 100, 0)
        highlight.FillTransparency = 0.25
        highlight.OutlineTransparency = 0
        highlight.Adornee = item:IsA("Model") and item or adorneePart
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = item
    end
end

local function toggleESP(state)
    espEnabled = state
    for _, item in pairs(workspace:GetDescendants()) do
        if table.find(teleportTargets, item.Name) then
            if espEnabled then
                createESP(item)
            else
                if item:FindFirstChild("ESP_Billboard") then item.ESP_Billboard:Destroy() end
                if item:FindFirstChild("ESP_Highlight") then item.ESP_Highlight:Destroy() end
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(desc)
    if espEnabled and table.find(teleportTargets, desc.Name) then
        task.wait(0.1)
        createESP(desc)
    end
end)

-- ESP for NPCs
local npcBoxes = {}

local function createNPCESP(npc)
    if not npc:IsA("Model") or npc:FindFirstChild("HumanoidRootPart") == nil then return end

    local root = npc:FindFirstChild("HumanoidRootPart")
    if npcBoxes[npc] then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Transparency = 1
    box.Color = Color3.fromRGB(255, 85, 0)
    box.Filled = false
    box.Visible = true

    local nameText = Drawing.new("Text")
    nameText.Text = npc.Name
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Size = 16
    nameText.Center = true
    nameText.Outline = true
    nameText.Visible = true

    npcBoxes[npc] = {box = box, name = nameText}

    -- Cleanup on remove
    npc.AncestryChanged:Connect(function(_, parent)
        if not parent and npcBoxes[npc] then
            npcBoxes[npc].box:Remove()
            npcBoxes[npc].name:Remove()
            npcBoxes[npc] = nil
        end
    end)
end

local function toggleNPCESP(state)
    npcESPEnabled = state
    if not state then
        for npc, visuals in pairs(npcBoxes) do
            if visuals.box then visuals.box:Remove() end
            if visuals.name then visuals.name:Remove() end
        end
        npcBoxes = {}
    else
        for _, obj in ipairs(workspace:GetDescendants()) do
            if table.find(AimbotTargets, obj.Name) and obj:IsA("Model") then
                createNPCESP(obj)
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(desc)
    if table.find(AimbotTargets, desc.Name) and desc:IsA("Model") then
        task.wait(0.1)
        if npcESPEnabled then
            createNPCESP(desc)
        end
    end
end)

-- Auto Tree Farm Logic with timeout
local badTrees = {}

task.spawn(function()
    while true do
        if AutoTreeFarmEnabled then
            local trees = {}
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Trunk" and obj.Parent and obj.Parent.Name == "Small Tree" then
                    local distance = (obj.Position - ignoreDistanceFrom).Magnitude
                    if distance > minDistance and not badTrees[obj:GetFullName()] then
                        table.insert(trees, obj)
                    end
                end
            end

            table.sort(trees, function(a, b)
                return (a.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <
                       (b.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            end)

            for _, trunk in ipairs(trees) do
                if not AutoTreeFarmEnabled then break end
                LocalPlayer.Character:PivotTo(trunk.CFrame + Vector3.new(0, 3, 0))
                task.wait(0.2)
                local startTime = tick()
                while AutoTreeFarmEnabled and trunk and trunk.Parent and trunk.Parent.Name == "Small Tree" do
                    mouse1click()
                    task.wait(0.2)
                    if tick() - startTime > 12 then
                        badTrees[trunk:GetFullName()] = true
                        break
                    end
                end
                task.wait(0.3)
            end
        end
        task.wait(1.5)
    end
end)

-- Optimized Aimbot Logic
local lastAimbotCheck = 0
local aimbotCheckInterval = 0.02
local smoothness = 0.2

RunService.RenderStepped:Connect(function()
    if not AimbotEnabled or not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        FOVCircle.Visible = false
        return
    end

    local currentTime = tick()
    if currentTime - lastAimbotCheck < aimbotCheckInterval then return end
    lastAimbotCheck = currentTime

    local mousePos = UserInputService:GetMouseLocation()
    local closestTarget, shortestDistance = nil, math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if table.find(AimbotTargets, obj.Name) and obj:IsA("Model") then
            local head = obj:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDistance and dist <= FOVRadius then
                        shortestDistance = dist
                        closestTarget = head
                    end
                end
            end
        end
    end

    if closestTarget then
        local currentCF = camera.CFrame
        local targetCF = CFrame.new(camera.CFrame.Position, closestTarget.Position)
        camera.CFrame = currentCF:Lerp(targetCF, smoothness)
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

-- Fly Logic
local flying, flyConnection = false, nil
local speed = 60

local function startFlying()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bodyGyro = Instance.new("BodyGyro", hrp)
    local bodyVelocity = Instance.new("BodyVelocity", hrp)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = hrp.CFrame
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    flyConnection = RunService.RenderStepped:Connect(function()
        local moveVec = Vector3.zero
        local camCF = camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec -= camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec -= camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec += camCF.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec -= camCF.UpVector end
        bodyVelocity.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * speed or Vector3.zero
        bodyGyro.CFrame = camCF
    end)
end

local function stopFlying()
    if flyConnection then flyConnection:Disconnect() end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
        end
    end
end

local function toggleFly(state)
    flying = state
    if flying then startFlying() else stopFlying() end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        toggleFly(not flying)
    end
end)

RunService.RenderStepped:Connect(function()
    for npc, visuals in pairs(npcBoxes) do
        local box = visuals.box
        local name = visuals.name

        if npc and npc:FindFirstChild("HumanoidRootPart") then
            local hrp = npc.HumanoidRootPart
            local size = Vector2.new(60, 80)
            local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                box.Position = Vector2.new(screenPos.X - size.X / 2, screenPos.Y - size.Y / 2)
                box.Size = size
                box.Visible = true

                name.Position = Vector2.new(screenPos.X, screenPos.Y - size.Y / 2 - 15)
                name.Visible = true
            else
                box.Visible = false
                name.Visible = false
            end
        else
            box:Remove()
            name:Remove()
            npcBoxes[npc] = nil
        end
    end
end)

-- Variables for Bring Tab
local presets = {
    Food = {"Carrot", "Corn", "Pumpkin", "Berry", "Apple", "Morsel", "Steak", "Ribs", "Cake", "Chili", "Stew", "Hearty Stew", "Meat? Sandwich", "Seafood Chowder", "Steak Dinner", "Pumpkin Soup", "BBQ Ribs", "Carrot Cake", "Jar o' Jelly"},
    Fish = {"Mackerel", "Salmon", "Clownfish", "Jellyfish", "Char", "Eel", "Swordfish", "Shark", "Lava Eel", "Lionfish"},
    Seeds = {"Chili Seeds", "Flower Seeds", "Berry Seeds", "Firefly Seeds"},
    Tools = {"Old Sack", "Good Sack", "Infernal Sack", "Giant Sack", "Old Axe", "Good Axe", "Ice Axe", "Strong Axe", "Chainsaw", "Admin Axe", "Old Rod", "Good Rod", "Strong Rod", "Old Flashlight", "Strong Flashlight", "Hammer", "Paint Brush"},
    Weapons = {"Spear", "Morningstar", "Katana", "Laser Sword", "Ice Sword", "Trident", "Poison Spear", "Infernal Sword", "Revolver", "Rifle", "Tactical Shotgun", "Snowball", "Frozen Shuriken", "Kunai", "Ray Gun", "Laser Cannon", "Flamethrower", "Blowpipe", "Admin Gun", "Friendly Gun", "Crossbow", "Wildfire", "Infernal Crossbow", "Revolver Ammo", "Rifle Ammo", "Shotgun Ammo", "Fuel Canister"},
    Armor = {"Leather Body", "Poison Armor", "Iron Body", "Thorn Body", "Riot Shield", "Alien Armor", "Earmuffs", "Beanie", "Arctic Fox Hat", "Polar Bear Hat", "Mammoth Helmet", "Frog Boots"},
    Resources = {"Wood", "Scrap", "Cultist Gem", "Forest Gem", "Forest Gem Fragment", "Mossy Coin", "Flower", "Sapling", "Bolt", "Sheet Metal", "UFO Junk", "UFO Component", "Broken Fan", "Old Radio", "Broken Microwave", "Tyre", "Metal Chair", "Old Car Engine", "Washing Machine", "Cultist Experiment", "Cultist Prototype", "UFO Scrap", "Bunny Foot", "Wolf Pelt", "Alpha Wolf Pelt", "Bear Pelt", "Arctic Fox Pelt", "Polar Bear Pelt", "Mammoth Tusk", "Scorpion Shell"},
    Fuel = {"Log", "Chair", "Biofuel", "Coal", "Fuel Canister", "Oil Barrel", "Cultist Corpse", "Crossbow Cultist Corpse", "Juggernaut Cultist Corpse", "Alien Corpse", "Elite Alien Corpse", "Wolf Corpse", "Alpha Wolf Corpse", "Bear Corpse"},
    Medical = {"Bandage", "Medkit"},
    Blueprints = {"Crafting Blueprint", "Defense Blueprint", "Furniture Blueprint"},
    Keys = {"Red Key", "Blue Key", "Yellow Key", "Grey Key", "Frog Key"},
    Junk = {"Old Boot", "Hologram Emitter", "Feather", "Basketball"},
    Special = {"Old Flashlight", "Admin Axe", "Admin Gun", "Friendly Gun"}
}

-- Bring Functions
local function bringItems(selectedItems)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local targetCFrame = rootPart.CFrame * CFrame.new(0, 5, 0)
    local itemsFolder = game:GetService("Workspace"):FindFirstChild("Items")
    if not itemsFolder then
        Rayfield:Notify({Title = "Error", Content = "Items folder not found in Workspace!", Duration = 3, Image = 4483362458})
        return
    end
    local brought = 0
    for _, itemName in pairs(selectedItems) do
        local success, item = pcall(function() return itemsFolder:FindFirstChild(itemName) end)
        if success and item and item:FindFirstChild("Main") then
            local mainPart = item.Main
            local prompt = item:FindFirstChild("ProximityPrompt")
            if prompt then fireproximityprompt(prompt) end
            mainPart.CFrame = targetCFrame
            brought = brought + 1
            wait(0.05)
        else
            Rayfield:Notify({Title = "Warning", Content = "Item '" .. itemName .. "' not found or invalid structure.", Duration = 2, Image = 4483362458})
        end
    end
    Rayfield:Notify({Title = "Bring Complete", Content = "Brought " .. brought .. " items to player!", Duration = 3, Image = 4483362458})
end

local function bringAllItems()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local targetCFrame = rootPart.CFrame * CFrame.new(0, 5, 0)
    local itemsFolder = game:GetService("Workspace"):FindFirstChild("Items")
    if not itemsFolder then
        Rayfield:Notify({Title = "Error", Content = "Items folder not found in Workspace!", Duration = 3, Image = 4483362458})
        return
    end
    local brought = 0
    for _, item in pairs(itemsFolder:GetChildren()) do
        local mainPart = item:FindFirstChild("Main")
        if mainPart then
            local prompt = item:FindFirstChild("ProximityPrompt")
            if prompt then fireproximityprompt(prompt) end
            mainPart.CFrame = targetCFrame
            brought = brought + 1
            wait(0.05)
        end
    end
    Rayfield:Notify({Title = "Bring All Complete", Content = "Brought " .. brought .. " items to player!", Duration = 3, Image = 4483362458})
end

-- Heart Animation Function
local function createHeartAnimation()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local centerPos = rootPart.Position
    local itemsFolder = game:GetService("Workspace"):FindFirstChild("Items")
    if not itemsFolder then
        Rayfield:Notify({Title = "Error", Content = "Items folder not found in Workspace!", Duration = 3, Image = 4483362458})
        return
    end
    local heartPoints = {
        {x=-4,z=0},{x=-3.5,z=1},{x=-3,z=2},{x=-2.5,z=2.5},{x=-2,z=3},{x=-1.5,z=3.2},{x=-1,z=3},
        {x=0,z=2.5},
        {x=1,z=3},{x=1.5,z=3.2},{x=2,z=3},{x=2.5,z=2.5},{x=3,z=2},{x=3.5,z=1},{x=4,z=0},
        {x=3.5,z=-1},{x=3,z=-2},{x=2.5,z=-2.5},{x=2,z=-3},{x=1.5,z=-3.2},{x=1,z=-3},
        {x=0,z=-2.5},{x=-1,z=-3},{x=-1.5,z=-3.2},{x=-2,z=-3},{x=-2.5,z=-2.5},{x=-3,z=-2},{x=-3.5,z=-1},
        {x=-2.5,z=1.5},{x=-1.5,z=2},{x=1.5,z=2},{x=2.5,z=1.5},{x=-2,z=-1.5},{x=-1,z=-1.5},{x=1,z=-1.5},{x=2,z=-1.5}
    }
    local items = itemsFolder:GetChildren()
    local brought = 0
    local index = 1
    for _, item in pairs(items) do
        if brought >= #heartPoints then break end
        local mainPart = item:FindFirstChild("Main")
        if mainPart then
            local prompt = item:FindFirstChild("ProximityPrompt")
            if prompt then fireproximityprompt(prompt) end
            local point = heartPoints[index]
            mainPart.CFrame = CFrame.new(centerPos + Vector3.new(point.x * 4, 5 + math.random(-1, 1), point.z * 4)) * CFrame.Angles(0, math.rad(math.random(-15, 15)), 0)
            brought = brought + 1
            index = index + 1
            wait(0.05)
        end
    end
    Rayfield:Notify({Title = "Heart Animation Complete", Content = "Formed larger heart with " .. brought .. " items!", Duration = 4, Image = 4483362458})
end
