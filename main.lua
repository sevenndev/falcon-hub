--------------------------------------------------------------------

-- Main Scripts Starts From Here

-- Lib


local UILib = loadstring(game:HttpGet('https://raw.githubusercontent.com/inceldom/kinx/main/ui'))()

local win = UILib:Window("Falcon Hub",Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightShift)

local Main = win:Tab("Main")
--------------------------------------------------------------------

-- Sections

local client = game.Players.LocalPlayer
local char = client.Character

local noclip = false
local flynoclip = false

Main:Slider("WalkSpeed",0,1000,30, function(t)
	game:GetService("Players").LocalPlayer.Character.Humanoid.WalkSpeed = t
end)

Main:Slider("Jump Power",0,1000,30, function(t)
	game:GetService("Players").LocalPlayer.Character.Humanoid.JumpPower = t
end)

Main:Toggle("NoClip",false, function(t)
    noclip = t
end)

local flysettings = {
    enabled = false,
    speed = 5
}

Main:Toggle("Fly",false, function(t)
    flysettings.enabled = t
end)

Main:Slider("Fly Speed",0,10,5, function(t)
    flysettings.speed = t
end)

local holding = {
    ["w"] = false,
    ["a"] = false,
    ["s"] = false,
    ["d"] = false,
    ["e"] = false,
    ["q"] = false
}

game:GetService("UserInputService").InputBegan:Connect(function(key)
    if holding[tostring(key.KeyCode.Name):lower()] ~= nil then
        holding[tostring(key.KeyCode.Name):lower()] = true
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(key)
    if holding[tostring(key.KeyCode.Name):lower()] ~= nil then
        holding[tostring(key.KeyCode.Name):lower()] = false
    end
end)

coroutine.resume(coroutine.create(function()
    while wait() do
        local stat, err = pcall(function()
            char = client.Character
            if flysettings.enabled then
                flynoclip = true
                if holding["w"] then
                    char.HumanoidRootPart.CFrame = char.Torso.CFrame:ToWorldSpace(CFrame.new(0,0,-1 * flysettings.speed))
                end
                if holding["a"] then
                    char.HumanoidRootPart.CFrame = char.Torso.CFrame:ToWorldSpace(CFrame.new(flysettings.speed,0,0))
                end
                if holding["s"] then
                    char.HumanoidRootPart.CFrame = char.Torso.CFrame:ToWorldSpace(CFrame.new(0,0,flysettings.speed))
                end
                if holding["d"] then
                    char.HumanoidRootPart.CFrame = char.Torso.CFrame:ToWorldSpace(CFrame.new(-1 * flysettings.speed,0,0))
                end
                if holding["e"] then
                    char.HumanoidRootPart.CFrame = char.Torso.CFrame:ToWorldSpace(CFrame.new(0,flysettings.speed,0))
                end
                if holding["q"] then
                    char.HumanoidRootPart.CFrame = char.Torso.CFrame:ToWorldSpace(CFrame.new(0,-1 * flysettings.speed,0))
                end
            else
                flynoclip = false
            end
        end)
        if not stat then warn(err) end
    end
end))



game:GetService("RunService").RenderStepped:Connect(function()
    if noclip or flynoclip then
        game.Players.LocalPlayer.Character.Humanoid:ChangeState(11)
    end
end)

local infjumpenabled = false

game:GetService("UserInputService").JumpRequest:Connect(function()
	if infjumpenabled then
		game:GetService("Players").LocalPlayer.Character.Humanoid:ChangeState("Jumping")
	end
end)

-- Enables/Disables inf jump. Essentially its the main toggle.
Main:Toggle("Infinite Jump",false, function(t)
	infjumpenabled = t
end)

Main:Slider("Max Slope Angle",1,89,89, function(t)
    game:GetService("Players").LocalPlayer.Character.Humanoid.MaxSlopeAngle = t
end)

Main:Slider("FOV",0,120,120, function(t)
    workspace.Camera.FieldOfView = t
end)

Main:Slider("Gravity",0,500,196, function(t)
    workspace.Gravity = t
end)

Main:Toggle("Xray",false, function(t)
    if t then
        for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and not v.Parent.Parent:FindFirstChild("Humanoid") then
				v.Transparency = v.Transparency + 0.5
			end
		end
    else
        for i,v in pairs(workspace:GetDescendants()) do
			if v:IsA("BasePart") and not v.Parent.Parent:FindFirstChild("Humanoid") then
				v.Transparency = v.Transparency - 0.5
			end
		end
    end
end)

Main:Button("Give Btools", function()
    tool1 = Instance.new("HopperBin",game.Players.LocalPlayer.Backpack)
	tool2 = Instance.new("HopperBin",game.Players.LocalPlayer.Backpack)
	tool1.BinType = "Clone"
	tool2.BinType = "Hammer"
end)

---------------------------------------------------------------------------------------------------

-- Aimbot
-- Add page
local Aimbot = win:Tab("Aimbot")

local aimbotsettings = {
    enabled = false,
    freeforall = false,
    radius = 2500,
    wallcheck = true
}

local players = game:GetService("Players")
local client = players.LocalPlayer
local inputservice = game:GetService("UserInputService")
local mouse = client:GetMouse()
local runservice = game:GetService("RunService")
local aim = false

function GetMouse()
    return Vector2.new(mouse.X, mouse.Y)
end

inputservice.InputBegan:Connect(function(key)
    if key.UserInputType == Enum.UserInputType.MouseButton2 then
        aim = true
    end
end)

inputservice.InputEnded:Connect(function(key)
    if key.UserInputType == Enum.UserInputType.MouseButton2 then
        aim = false
    end
end)

function FreeForAll(targetplayer)
    if aimbotsettings.freeforall == false then
        if client.Team == targetplayer.Team then return false
        else return true end
    else return true end
end

function NotObstructing(destination, ignore)
    if aimbotsettings.wallcheck then
        Origin = workspace.CurrentCamera.CFrame.p
        CheckRay = Ray.new(Origin, destination- Origin)
        Hit = workspace:FindPartOnRayWithIgnoreList(CheckRay, ignore)
        return Hit == nil
    else
        return true
    end
end

function GetClosestToCuror()
    MousePos = GetMouse()
    Radius = aimbotsettings.radius
    Closest = math.huge
    Target = nil
    for _,v in pairs(game:GetService("Players"):GetPlayers()) do
        if FreeForAll(v) then
            if v.Character:FindFirstChild("Head") and v ~= game.Players.LocalPlayer then
                Point,OnScreen = workspace.CurrentCamera:WorldToViewportPoint(v.Character.Head.Position)
                clientchar = client.Character
                if OnScreen and NotObstructing(v.Character.Head.Position,{clientchar,v.Character}) then
                    Distance = (Vector2.new(Point.X,Point.Y) - MousePos).magnitude
                    if Distance < math.min(Radius,Closest) then
                        Closest = Distance
                        Target = v
                    end
                end
            end
        end
    end
    return Target
end 

runservice.RenderStepped:Connect(function()
    if aimbotsettings.enabled == false or aim == false then return end
    ClosestPlayer = GetClosestToCuror()
    if ClosestPlayer then
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.p,ClosestPlayer.Character.Head.CFrame.p)
    end
end)

-- Enables/Disables aimbot. Essentially its the main toggle.
Aimbot:Toggle("Enabled",false, function(t)
    aimbotsettings.enabled = t
end)

-- Enables/Disables wallcheck. It locks on only if the enemy is not obstructed by a part.
Aimbot:Toggle("Wall Check",true, function(t)
    aimbotsettings.wallcheck = t
end)

-- Determines if it should only lock onto players who are on the same team or not. Sometimes can get fucked so turning it on is the way to go.
Aimbot:Toggle("Free For All",false, function(t)
    aimbotsettings.freeforall = t
end)

-- Customize the aimbot pixel range. Pretty much how far away your cursor has to be to lock onto a target.
-- I did it with a slider but I also left the code if you want to instead do it with a textbox.

Aimbot:Slider("Aimbot Pixel Range",0,10000,2500, function(t)
    aimbotsettings.radius = tonumber(t)
end)

---------------------------------------------------------------------------------------------------

-- ESP
-- Add UI

local ESPSection = win:Tab("ESP")

local ESPEnabled = false
local DistanceEnabled = true
local TracersEnabled = true

pcall(function()
	
	Camera = game:GetService("Workspace").CurrentCamera
	RunService = game:GetService("RunService")
	camera = workspace.CurrentCamera
	Bottom = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)

	function GetPoint(vector3)
		local vector, onScreen = camera:WorldToScreenPoint(vector3)
		return {Vector2.new(vector.X,vector.Y),onScreen,vector.Z}
	end
	
	function MakeESP(model)
		local CurrentParent = model.Parent
	
		local TopL = Drawing.new("Line")
		local BottomL = Drawing.new("Line")
		local LeftL = Drawing.new("Line")
		local RightL = Drawing.new("Line")
		local Tracer = Drawing.new("Line")
		local Display = Drawing.new("Text")

        coroutine.resume(coroutine.create(function()
			while model.Parent == CurrentParent do
				
				local Distance = (Camera.CFrame.Position - model.HumanoidRootPart.Position).Magnitude
                local GetP = GetPoint(model.Head.Position)
                local headps = model.Head.CFrame
                
				if ESPEnabled and GetP[2] then
					
                    -- Calculate Cords
                    local topright = headps * CFrame.new(3,0.5, 0)
                    local topleft = headps * CFrame.new(-3,0.5, 0)
                    local bottomleft = headps * CFrame.new(-3,-7,0)
                    local bottomright = headps * CFrame.new(3,-7,0)
					topright = GetPoint(topright.p)[1]
					topleft = GetPoint(topleft.p)[1]
					bottomleft = GetPoint(bottomleft.p)[1]
					bottomright = GetPoint(bottomright.p)[1]

                    local teamcolor = game:GetService("Players")[model.Name].TeamColor.Color or Color3.fromRGB(0,0,0)
                    TopL.Color, BottomL.Color, RightL.Color, LeftL.Color = teamcolor, teamcolor, teamcolor, teamcolor
                    TopL.From, BottomL.From, RightL.From, LeftL.From = topleft, bottomleft, topright, topleft
                    TopL.To, BottomL.To, RightL.To, LeftL.To = topright, bottomright, bottomright, bottomleft
					TopL.Visible, BottomL.Visible, RightL.Visible, LeftL.Visible = true, true, true, true
				else
					TopL.Visible, BottomL.Visible, RightL.Visible, LeftL.Visible = false, false, false, false
                end
                
				if ESPEnabled and TracersEnabled and GetP[2] then
					Tracer.Color = game:GetService("Players")[model.Name].TeamColor.Color or Color3.fromRGB(0,0,0)
					Tracer.From = Bottom
					Tracer.To = GetPoint(headps.p)[1]
					Tracer.Thickness = 1.5
					Tracer.Visible = true
				else
					Tracer.Visible = false
                end
                
				if ESPEnabled and DistanceEnabled and GetP[2] then
					Display.Visible = true
					Display.Position = GetPoint(headps.p + Vector3.new(0,0.5,0))[1]
					Display.Center = true
					Display.Text = tostring(math.floor(Distance)).." studs"
				else
					Display.Visible = false
                end
                
				RunService.RenderStepped:Wait()
			end
	
			TopL:Remove()
			BottomL:Remove()
			RightL:Remove()
			LeftL:Remove()
			Tracer:Remove()
			Display:Remove()
        
        end))
    end
    
	for _, Player in next, game:GetService("Players"):GetChildren() do
		if Player.Name ~= game.Players.LocalPlayer.Name then
			MakeESP(Player.Character)
			Player.CharacterAdded:Connect(function()
				delay(0.5, function()
					MakeESP(Player.Character)
				end)
			end)
		end	
	end
	
	game:GetService("Players").PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            delay(0.5, function()
                MakeESP(player.Character)
            end)
		end)
	end)
	
end)


-- Enables/Disables ESP. Main toggle
ESPSection:Toggle("Enabled",false, function(t)
    ESPEnabled = t
end)

-- Toggles tracers
ESPSection:Toggle("Tracers",false, function(t)
    TracersEnabled = t
end)

-- Toggles distance display
ESPSection:Toggle("Distance Display",false, function(t)
    DistanceEnabled = t
end)

---------------------------------------------------------------------------------------------------

-- Other Func
-- Add UI
local Settings = win:Tab("Settings")

Settings:Label("UI Toggle Key:  Right Shift")

Settings:Button("Copy Discord Invite", function()
    setclipboard("https://dsc.gg/knightx")
    UILib:Notification("Notification", "Copied!", "Okay")
end)

local ScriptHub = win:Tab("ScriptHub")

ScriptHub:Label("SwagMode DaHood Script: ")

ScriptHub:Button("Execute Script", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/lerkermer/lua-projects/master/SwagModeV002'))()
end)

ScriptHub:Label("Faded DaHood Script: ")

ScriptHub:Button("Execute Script", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/NighterEpic/Faded/main/YesEpic", true))()
end)

ScriptHub:Label("Artic DaHood Script: ")

ScriptHub:Button("Execute Script", function()
    loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/PolarWasHere/Arctic/main/Arctic"))()
end)

ScriptHub:Label("CC Aimbot V2 Script: ")

ScriptHub:Button("Execute Script", function()
    loadstring(game:HttpGet(('https://gitlab.com/marsscripts/marsscripts/-/raw/master/CCAimbotV2'),true))()
end)

ScriptHub:Label("Owlhub Script: ")

ScriptHub:Button("Execute Script", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/CriShoux/OwlHub/master/OwlHub.txt"))();
end)

ScriptHub:Label("Infinite Yield Script: ")

ScriptHub:Button("Execute Script", function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end)

ScriptHub:Label("Reviz Admin Script: ")

ScriptHub:Button("Execute Script", function()
    loadstring(game:HttpGet("https://pastebin.com/raw/RqaZUrBZ", true))()
end)

ScriptHub:Label("Coco Hub Script: ")

ScriptHub:Button("Execute Script", function()
    loadstring(game:HttpGet(('https://raw.githubusercontent.com/MarsQQ/CocoHub/master/CocoZHub'),true))()
end)
