local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Minato King Legacy Farm", "DarkTheme")

-- Variáveis
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local farmEnabled = false
local autoBoss = false
local autoQuest = false
local autoRace = false
local flyEnabled = false

-- POSIÇÕES ATUALIZADAS (King Legacy Update 9.4+)
local POSICOES = {
    -- Farm Level
    ["Bandit"] = CFrame.new(-3052, 73, 3363),
    ["Gorilla"] = CFrame.new(-1221, 73, 3749),
    ["Snow Bandit"] = CFrame.new(1387, 87, -1298),
    
    -- Bosses
    ["Thunder God"] = CFrame.new(-2851, 73, 4392),
    ["Vice Amiral"] = CFrame.new(2859, 73, 4495),
    ["Dough King"] = CFrame.new(5535, 73, -4529),
    
    -- Quests
    ["Luffy Quest"] = CFrame.new(-1230, 73, 3330),
    ["Race V2"] = CFrame.new(-1230, 73, 3330),
    ["Daily"] = CFrame.new(70, 73, 70),
}

-- TABS
local FarmTab = Window:NewTab("🌟 Farm")
local BossTab = Window:NewTab("👑 Bosses")
local QuestTab = Window:NewTab("📜 Quests")
local MoveTab = Window:NewTab("🚀 Movement")

-- FARM TAB
FarmTab:NewToggle("Auto Farm Level", "Farma level infinito", function(state)
    farmEnabled = state
end)

FarmTab:NewToggle("Auto Collect Items", "Pega fruits/coins", function(state)
    getgenv().autoCollect = state
end)

FarmTab:NewButton("Teleport Farm", "Vai pro melhor spot", function()
    rootPart.CFrame = POSICOES["Bandit"]
end)

-- BOSS TAB
BossTab:NewToggle("Auto Boss Farm", "Mata todos bosses", function(state)
    autoBoss = state
end)

BossTab:NewButton("TP Thunder God", "Boss fácil", function()
    rootPart.CFrame = POSICOES["Thunder God"]
end)

-- QUEST TAB
QuestTab:NewToggle("Auto Daily Quests", "Missões diárias", function(state)
    autoQuest = state
end)

QuestTab:NewToggle("Race V2 Auto", "Completa raça V2", function(state)
    autoRace = state
end)

-- MOVEMENT
MoveTab:NewToggle("Fly", "Voa livre", function(state)
    flyEnabled = state
end)

MoveTab:NewSlider("Speed", "Velocidade", 500, 16, function(s)
    pcall(function() humanoid.WalkSpeed = s end)
end)

MoveTab:NewButton("Save Pos", "Salva posição", function()
    getgenv().savePos = rootPart.CFrame
end)

MoveTab:NewButton("Load Pos", "Volta posição", function()
    if getgenv().savePos then
        rootPart.CFrame = getgenv().savePos
    end
end)

-- FUNÇÕES
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
            -- Ataque auto
            for i = 1, 10 do
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,true,game,1)
                wait(0.05)
                game:GetService("VirtualInputManager"):SendMouseButtonEvent(0,0,0,false,game,1)
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
                -- Simula clique E
                keypress(0x45)
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

print("✅ MINATO FARM HUB v2 CARREGADO!")
print("🎮 Ative 'Auto Farm Level' primeiro!")
print("🛫 Fly: WASD + Space/Shift")
