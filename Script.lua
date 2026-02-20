-- 🔥 Minato King Legacy ULTIMATE HUB v4.1 (com ESP Players)
-- Delta 100% | GUI Rayfield + Auto Farm + ESP (Nome, Level, PvP, Vida)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

-- Carrega Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Minato King Legacy HUB v4.1",
   LoadingTitle = "Carregando Minato HUB...",
   LoadingSubtitle = "by Minato Palmas",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "MinatoKLHub",
      FileName = "MinatoConfig"
   },
   KeySystem = false
})

Rayfield:Notify({
   Title = "Minato HUB",
   Content = "Carregado com sucesso! Pressione INSERT para abrir",
   Duration = 4,
   Image = 4483362458
})

-- Character setup
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Configs
local configs = {
    farmEnabled = false,
    bossEnabled = false,
    flyEnabled = false,
    noclipEnabled = false,
    speed = 100,
    infJump = false,
    espEnabled = false
}

-- POSIÇÕES (Update 9+)
local Teleports = {
    ["🏴 Bandit Farm"] = CFrame.new(-3052, 73, 3363),
    ["🐒 Gorilla Farm"] = CFrame.new(-1221, 73, 3749),
    ["⚡ Thunder God"] = CFrame.new(-2851, 73, 4392),
    ["👮 Vice Admiral"] = CFrame.new(2859, 73, 4495),
    ["📜 Daily Quest"] = CFrame.new(70, 73, 70),
    ["🏃 Race V2"] = CFrame.new(-1230, 73, 3330),
    ["💰 Spawn"] = CFrame.new(0, 73, 0)
}

-- TABS
local FarmTab = Window:CreateTab("🌟 Farm", 4483362458)
local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)
local TeleportTab = Window:CreateTab("📍 Teleports", 4483362458)
local PlayerTab = Window:CreateTab("👤 Player", 4483362458)
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)  -- Nova tab para ESP
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

-- FARM TAB
FarmTab:CreateToggle({
   Name = "Auto Farm Level",
   CurrentValue = false,
   Flag = "AutoFarm",
   Callback = function(Value)
      configs.farmEnabled = Value
   end,
})

FarmTab:CreateToggle({
   Name = "Auto Collect Items",
   CurrentValue = false,
   Flag = "AutoCollect",
   Callback = function(Value)
      configs.autoCollect = Value
   end,
})

-- COMBAT TAB
CombatTab:CreateToggle({
   Name = "Auto Boss Farm",
   CurrentValue = false,
   Flag = "AutoBoss",
   Callback = function(Value)
      configs.bossEnabled = Value
   end,
})

-- TELEPORTS TAB
local TeleportSection = TeleportTab:CreateSection("Ilhas & NPCs")
for name, cframe in pairs(Teleports) do
   TeleportTab:CreateButton({
      Name = name,
      Callback = function()
         rootPart.CFrame = cframe
         Rayfield:Notify({Title = "Teleport", Content = name .. " carregado!", Duration = 2})
      end,
   })
end

-- PLAYER TAB
PlayerTab:CreateSlider({
   Name = "Walk Speed",
   Range = {16, 500},
   Increment = 10,
   CurrentValue = 100,
   Flag = "WalkSpeed",
   Callback = function(Value)
      configs.speed = Value
      humanoid.WalkSpeed = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Fly (WASD + Space/Shift)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      configs.flyEnabled = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Noclip",
   Callback = function(Value)
      configs.noclipEnabled = Value
   end,
})

PlayerTab:CreateToggle({
   Name = "Infinite Jump",
   CurrentValue = false,
   Flag = "InfJump",
   Callback = function(Value)
      configs.infJump = Value
   end,
})

-- ESP TAB
local ESPSection = ESPTab:CreateSection("Player ESP")
ESPTab:CreateToggle({
   Name = "ESP Players (Nome, Level, PvP, Vida)",
   CurrentValue = false,
   Flag = "ESP_Toggle",
   Callback = function(Value)
      configs.espEnabled = Value
      if Value then
         enableAllESP()
         Rayfield:Notify({Title = "ESP", Content = "Ativado - Level, PvP e Vida", Duration = 3})
      else
         disableAllESP()
         Rayfield:Notify({Title = "ESP", Content = "Desativado", Duration = 3})
      end
   end,
})

-- MISC TAB
MiscTab:CreateButton({
   Name = "Rejoin Server",
   Callback = function()
      game:GetService("TeleportService"):Teleport(game.PlaceId, player)
   end,
})

-- FUNÇÕES DE MOVIMENTO E FARM (mantidas)
local function tweenTo(cframe)
   local distance = (rootPart.Position - cframe.Position).Magnitude
   local tween = TweenService:Create(rootPart, TweenInfo.new(distance/300, Enum.EasingStyle.Linear), {CFrame = cframe})
   tween:Play()
   tween.Completed:Wait()
end

local function getNearestEnemy()
   local closest, dist = nil, 150
   pcall(function()
      for _, enemy in pairs(workspace.Enemies:GetChildren()) do
         if enemy:FindFirstChild("HumanoidRootPart") and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            local distance = (enemy.HumanoidRootPart.Position - rootPart.Position).Magnitude
            if distance < dist then
               closest = enemy
               dist = distance
            end
         end
      end
   end)
   return closest
end

-- MAIN LOOP
RunService.Heartbeat:Connect(function()
   pcall(function()
      humanoid.WalkSpeed = configs.speed
      
      if configs.noclipEnabled then
         for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
         end
      end
      
      if configs.flyEnabled then
         local bv = rootPart:FindFirstChild("FlyBV") or Instance.new("BodyVelocity")
         bv.Name = "FlyBV"
         bv.MaxForce = Vector3.new(4000, 4000, 4000)
         bv.Velocity = Vector3.new(0, 0, 0)
         bv.Parent = rootPart
         
         local cam = workspace.CurrentCamera
         local move = humanoid.MoveDirection
         if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
         if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move += Vector3.new(0,-1,0) end
         bv.Velocity = cam.CFrame:VectorToWorldSpace(move) * 50
      end
      
      if configs.farmEnabled then
         local enemy = getNearestEnemy()
         if enemy then
            tweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0,5,-5))
            for i = 1, 5 do
               VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
               task.wait(0.1)
               VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
            end
         end
      end
   end)
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
   if configs.infJump then
      humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
   end
end)

-- Hotkey Insert para abrir/fechar GUI
UserInputService.InputBegan:Connect(function(input)
   if input.KeyCode == Enum.KeyCode.Insert then
      Rayfield:Toggle()
   end
end)

-- Anti-AFK
spawn(function()
   while task.wait(300) do
      VirtualUser:CaptureController()
      VirtualUser:ClickButton2(Vector2.new())
   end
end)

-- Respawn handler
player.CharacterAdded:Connect(function(newChar)
   character = newChar
   humanoid = newChar:WaitForChild("Humanoid")
   rootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- ======================================
-- ESP PLAYERS - Nome, Level, PvP, Vida
-- ======================================

local function createESP(plr)
   if plr == player then return end
   
   local function applyESP(char)
      local head = char:WaitForChild("Head", 5)
      local humanoid = char:WaitForChild("Humanoid", 5)
      if not head or not humanoid then return end
      
      local billboard = Instance.new("BillboardGui")
      billboard.Name = "Minato_ESP"
      billboard.Adornee = head
      billboard.Size = UDim2.new(0, 220, 0, 120)
      billboard.StudsOffset = Vector3.new(0, 5, 0)
      billboard.AlwaysOnTop = true
      billboard.LightInfluence = 0
      billboard.MaxDistance = 1200
      billboard.Parent = head
      
      local text = Instance.new("TextLabel")
      text.Size = UDim2.new(1, 0, 1, 0)
      text.BackgroundTransparency = 1
      text.TextColor3 = Color3.fromRGB(255, 255, 255)
      text.TextStrokeTransparency = 0.4
      text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
      text.Font = Enum.Font.GothamBold
      text.TextSize = 15
      text.TextXAlignment = Enum.TextXAlignment.Center
      text.Parent = billboard
      
      spawn(function()
         while billboard.Parent and task.wait(0.4) do
            local levelText = "Lv: ?"
            local pvpText = "PvP: ?"
            local healthText = "Vida: ?/?"
            
            local leaderstats = plr:FindFirstChild("leaderstats")
            if leaderstats then
               local levelVal = leaderstats:FindFirstChild("Level")
               if levelVal and levelVal:IsA("IntValue") then
                  levelText = "Lv: " .. levelVal.Value
               end
            end
            
            local pvpVal = plr:FindFirstChild("PVP") or plr:FindFirstChild("PvPEnabled") or plr:FindFirstChild("InPVP")
            if pvpVal and pvpVal:IsA("BoolValue") then
               pvpText = "PvP: " .. (pvpVal.Value and "Ativado" or "Desativado")
            elseif pvpVal then
               pvpText = "PvP: " .. tostring(pvpVal.Value)
            end
            
            healthText = "Vida: " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
            
            local color = (pvpVal and pvpVal.Value) and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(100, 255, 100)
            text.TextColor3 = color
            
            text.Text = plr.Name .. "\n" .. levelText .. "\n" .. pvpText .. "\n" .. healthText
         end
      end)
   end
   
   if plr.Character then applyESP(plr.Character) end
   plr.CharacterAdded:Connect(applyESP)
end

local function enableAllESP()
   configs.espEnabled = true
   for _, plr in pairs(Players:GetPlayers()) do
      createESP(plr)
   end
end

local function disableAllESP()
   configs.espEnabled = false
   for _, plr in pairs(Players:GetPlayers()) do
      if plr.Character then
         local head = plr.Character:FindFirstChild("Head")
         if head then
            local esp = head:FindFirstChild("Minato_ESP")
            if esp then esp:Destroy() end
         end
      end
   end
end

-- Players novos
Players.PlayerAdded:Connect(function(plr)
   if configs.espEnabled then
      createESP(plr)
   end
end)

print("🎉 Minato HUB v4.1 CARREGADO com ESP!")
print("INSERT = Abrir/Fechar GUI | Vá na tab ESP para ativar")
