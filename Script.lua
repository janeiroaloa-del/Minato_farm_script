-- 🔥 Minato King Legacy Farm Hub v2.2 (Corrigido + ESP Players) - Delta OK

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer

-- Kavo UI corrigida (fonte oficial, funciona em 2026)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Minato King Legacy Farm v2.2", "DarkTheme")

-- Variáveis
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local farmEnabled = false
local autoBoss = false
local autoQuest = false
local autoRace = false
local flyEnabled = false
local espEnabled = false

-- POSIÇÕES (mantidas e atualizadas)
local POSICOES = {
    ["Bandit"] = CFrame.new(-3052, 73, 3363),
    ["Gorilla"] = CFrame.new(-1221, 73, 3749),
    ["Thunder God"] = CFrame.new(-2851, 73, 4392),
    ["Vice Amiral"] = CFrame.new(2859, 73, 4495),
    ["Daily"] = CFrame.new(70, 73, 70),
    ["Race V2"] = CFrame.new(-1230, 73, 3330),
}

-- TABS
local FarmTab = Window:NewTab("Farm")
local BossTab = Window:NewTab("Bosses")
local QuestTab = Window:NewTab("Quests")
local MoveTab = Window:NewTab("Movement")
local ESPTab = Window:NewTab("ESP")  -- Nova tab para ESP

-- Toggles existentes
FarmTab:NewToggle("Auto Farm Level", "Farma level infinito", function(state)
    farmEnabled = state
end)

FarmTab:NewToggle("Auto Collect Items", "Pega fruits/coins", function(state)
    getgenv().autoCollect = state
end)

FarmTab:NewButton("Teleport Farm", "Vai pro melhor spot", function()
    rootPart.CFrame = POSICOES["Bandit"]
end)

BossTab:NewToggle("Auto Boss Farm", "Mata todos bosses", function(state)
    autoBoss = state
end)

BossTab:NewButton("TP Thunder God", "Boss fácil", function()
    rootPart.CFrame = POSICOES["Thunder God"]
end)

QuestTab:NewToggle("Auto Daily Quests", "Missões diárias", function(state)
    autoQuest = state
end)

QuestTab:NewToggle("Race V2 Auto", "Completa raça V2", function(state)
    autoRace = state
end)

MoveTab:NewToggle("Fly", "Voa livre", function(state)
    flyEnabled = state
end)

MoveTab:NewSlider("Speed", "Velocidade", 500, 16, function(s)
    pcall(function() humanoid.WalkSpeed = s end)
end)

-- ESP Toggle
ESPTab:NewToggle("Player ESP (Nome, Lv, PvP, Vida)", "Mostra info acima da cabeça", function(state)
    espEnabled = state
    if state then
        enableAllESP()
        print("ESP Ativado")
    else
        disableAllESP()
        print("ESP Desativado")
    end
end)

-- FUNÇÕES DE MOVIMENTO/FARM (mantidas do seu script)
local function tweenTo(pos, speed)
    speed = speed or 200
    local distance = (rootPart.Position - pos.Position).Magnitude
    local tweenInfo = TweenInfo.new(distance/speed, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = pos})
    tween:Play()
    tween.Completed:Wait()
end

local function collectItems()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("fruit") or obj.Name:lower():find("drop") or obj.Name:lower():find("coin")) then
            if (obj.Position - rootPart.Position).Magnitude < 100 then
                tweenTo(CFrame.new(obj.Position + Vector3.new(0,10,0)))
                fireclickdetector(obj:FindFirstChildOfClass("ClickDetector"))
            end
        end
    end
end

local function farmMobs()
    for _, enemy in pairs(workspace.Enemies:GetChildren()) do
        if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            tweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0,5,-3))
            for i = 1, 10 do
                VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
                wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
            end
            return true
        end
    end
    return false
end

local function farmBosses()
    local bosses = {"Thunder God", "Vice Amiral", "Dough King"}
    for _, bossName in pairs(bosses) do
        for _, boss in pairs(workspace.Enemies:GetChildren()) do
            if boss.Name:find(bossName) and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                tweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0,5,-3))
                return true
            end
        end
    end
    return false
end

-- LOOP PRINCIPAL
spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if flyEnabled then
                local bv = rootPart:FindFirstChild("FlyBV") or Instance.new("BodyVelocity")
                bv.Name = "FlyBV"
                bv.MaxForce = Vector3.new(9e9,9e9,9e9)
                bv.Velocity = Vector3.new(0,0,0)
                bv.Parent = rootPart
                
                local cam = workspace.CurrentCamera
                local move = humanoid.MoveDirection
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move + Vector3.new(0,-1,0) end
                bv.Velocity = (cam.CFrame:VectorToWorldSpace(move)) * 50
            end
            
            if farmEnabled then
                if not farmMobs() then
                    tweenTo(POSICOES["Bandit"])
                end
            end
            
            if autoBoss and not farmBosses() then
                tweenTo(POSICOES["Thunder God"])
            end
            
            if getgenv().autoCollect then
                collectItems()
            end
            
            -- Noclip
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    end
end)

-- Quest Loop
spawn(function()
    while task.wait(10) do
        pcall(function()
            if autoQuest then
                tweenTo(POSICOES["Daily"])
                wait(2)
                keypress(0x45) -- E
                wait(1)
                keyrelease(0x45)
            end
            
            if autoRace then
                tweenTo(POSICOES["Race V2"])
                wait(3)
            end
        end)
    end
end)

-- Anti-AFK
spawn(function()
    while task.wait(300) do
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end
end)

-- Respawn fix
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
end)

-- ======================================
-- ESP PLAYERS (integrado)
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
    for _, plr in pairs(Players:GetPlayers()) do
        createESP(plr)
    end
end

local function disableAllESP()
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

Players.PlayerAdded:Connect(function(plr)
    if espEnabled then
        createESP(plr)
    end
end)

print("MINATO FARM HUB v2.2 CORRIGIDO + ESP CARREGADO!")
print("Ative 'Auto Farm Level' e vá na tab ESP para ligar o visual!")
print("Fly: WASD + Space/Shift | INSERT para GUI (se Kavo suportar)")   Callback = function(Value)
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
