--[[
	EVOLVE YOUR WORLD - what each player sees.
	  - money bottom-left
	  - messages at the top
	  - every walking item animates in its own style with its walk effect
	  - sleeping items breathe in the tanks
	  - the world inside every sphere (SphereWorld)
	  - "+$" above your sphere every second
	  - first time only: an intro animation, then an arrow that shows what to do
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Util = require(Shared.Util)
local ItemData = require(Shared.ItemData)
local Gait = require(Shared.Gait)
local Characters = require(Shared.Characters)
local Fx = require(script.Parent.Fx)
local WalkFx = require(script.Parent.WalkFx)
local SphereWorld = require(script.Parent.SphereWorld)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local plotsFolder = workspace:WaitForChild("Plots")
local walkers = workspace:WaitForChild("Brainrots")

local C, V = Color3.fromRGB, Vector3.new

--------------------------------------------------------------------------------------------
-- UI

local gui = Instance.new("ScreenGui")
gui.Name = "EvolveUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local moneyFrame = Instance.new("Frame")
moneyFrame.AnchorPoint = Vector2.new(0, 1)
moneyFrame.Position = UDim2.new(0, 18, 1, -18)
moneyFrame.Size = UDim2.fromOffset(260, 74)
moneyFrame.BackgroundColor3 = C(20, 30, 25)
moneyFrame.BackgroundTransparency = 0.25
moneyFrame.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = moneyFrame
local stroke = Instance.new("UIStroke")
stroke.Color = C(90, 255, 120)
stroke.Thickness = 3
stroke.Parent = moneyFrame
local moneyLabel = Util.label(moneyFrame, "$0", C(110, 255, 130), UDim2.new(1, -24, 1, -12), UDim2.fromOffset(12, 6))
moneyLabel.TextXAlignment = Enum.TextXAlignment.Left

local toastHolder = Instance.new("Frame")
toastHolder.BackgroundTransparency = 1
toastHolder.AnchorPoint = Vector2.new(0.5, 0)
toastHolder.Position = UDim2.new(0.5, 0, 0, 70)
toastHolder.Size = UDim2.fromOffset(620, 300)
toastHolder.Parent = gui
local layout = Instance.new("UIListLayout")
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 6)
layout.Parent = toastHolder

local KIND_COLOR = {
	info = C(255, 255, 255),
	good = C(120, 255, 140),
	bad = C(255, 110, 110),
	money = C(255, 225, 90),
}

local function toast(text: string, kind: string?)
	local f = Instance.new("Frame")
	f.Size = UDim2.fromOffset(600, 44)
	f.BackgroundColor3 = C(15, 15, 25)
	f.BackgroundTransparency = 0.3
	f.Parent = toastHolder
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 12)
	c.Parent = f
	local t = Util.label(f, text, KIND_COLOR[kind or "info"] or KIND_COLOR.info, UDim2.new(1, -20, 1, -8), UDim2.fromOffset(10, 4))
	task.delay(4, function()
		TweenService:Create(f, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(t, TweenInfo.new(0.5), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
		task.wait(0.55)
		f:Destroy()
	end)
end

local sounds = {}
local function sound(name: string, id: string, vol: number)
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = vol
	s.Parent = gui
	sounds[name] = s
end
sound("ping", "rbxasset://sounds/electronicpingshort.wav", 0.6)
sound("click", "rbxasset://sounds/button.wav", 0.6)
local function play(name: string)
	local s = sounds[name]
	if s then
		s:Play()
	end
end

-- money display, counting up smoothly
local shownMoney = 0
local function watchMoney()
	local ls = player:WaitForChild("leaderstats")
	local value = ls:WaitForChild("Money") :: NumberValue
	shownMoney = value.Value
	moneyLabel.Text = Util.money(shownMoney)
	RunService.RenderStepped:Connect(function(dt)
		local target = value.Value
		if math.abs(target - shownMoney) < 1 then
			shownMoney = target
		else
			shownMoney += (target - shownMoney) * math.min(dt * 8, 1)
		end
		moneyLabel.Text = Util.money(shownMoney)
	end)
	value.Changed:Connect(function(v)
		if v > shownMoney then
			moneyFrame.Size = UDim2.fromOffset(280, 80)
			TweenService:Create(moneyFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), { Size = UDim2.fromOffset(260, 74) }):Play()
		end
	end)
end
task.spawn(watchMoney)

;(remotes:WaitForChild("Notify") :: RemoteEvent).OnClientEvent:Connect(function(text: string, kind: string?)
	toast(text, kind)
	if kind == "good" then
		play("ping")
	end
end)

;(remotes:WaitForChild("Collected") :: RemoteEvent).OnClientEvent:Connect(function(amount: number, pos: Vector3)
	play("ping")
	Fx.popup(pos + V(0, 3, 0), "+" .. Util.money(amount), C(110, 255, 130), 260)
	Fx.burst(pos + V(0, 1, 0), ColorSequence.new(C(120, 255, 140), C(255, 230, 90)), 50, 10, 0.8)
end)

;(remotes:WaitForChild("Bought") :: RemoteEvent).OnClientEvent:Connect(function()
	play("click")
end)

--------------------------------------------------------------------------------------------
-- my base

local function myPlot(): Model?
	local idx = player:GetAttribute("PlotIndex")
	if not idx then
		return nil
	end
	return plotsFolder:FindFirstChild("Plot" .. idx) :: Model?
end

-- Prompts that only the owner should see (launch, sell, buy machine).
local function filterPrompts()
	local mine = myPlot()
	for _, plot in plotsFolder:GetChildren() do
		if plot ~= mine then
			for _, d in plot:GetDescendants() do
				if d:IsA("ProximityPrompt") and d:GetAttribute("OwnerOnly") and d.Enabled then
					d.Enabled = false
				end
			end
		end
	end
	-- you can't buy your own item again while it walks home
	for _, m in walkers:GetChildren() do
		local root = (m :: Model).PrimaryPart
		local prompt = root and root:FindFirstChild("Buy") :: ProximityPrompt?
		if prompt then
			local mineWalker = m:GetAttribute("OwnerUserId") == player.UserId
			if mineWalker and prompt.Enabled then
				prompt.Enabled = false
			end
		end
	end
end
task.spawn(function()
	while true do
		filterPrompts()
		task.wait(0.4)
	end
end)

--------------------------------------------------------------------------------------------
-- spheres

for _, plot in plotsFolder:GetChildren() do
	task.spawn(SphereWorld.attach, plot :: Model)
end
plotsFolder.ChildAdded:Connect(function(plot)
	task.spawn(SphereWorld.attach, plot :: Model)
end)

-- "+$" above every sphere that is making money
task.spawn(function()
	while true do
		task.wait(1)
		for _, plot in plotsFolder:GetChildren() do
			local inc = plot:GetAttribute("Income") :: number?
			local center = plot:GetAttribute("SphereCenter") :: Vector3?
			local R = plot:GetAttribute("SphereR") :: number?
			if inc and inc > 0 and center and R then
				local mine = plot == myPlot()
				Fx.popup(center + V(0, R + 1.5, 0), "+" .. Util.money(inc), mine and C(110, 255, 130) or C(200, 255, 200), mine and 200 or 130)
			end
		end
	end
end)

--------------------------------------------------------------------------------------------
-- tutorial arrow

local arrowPart, arrowAtt = Fx.anchor(V(0, -100, 0))
arrowPart.Name = "TutorialTarget"
local arrowGui = Instance.new("BillboardGui")
arrowGui.Size = UDim2.fromOffset(260, 120)
arrowGui.AlwaysOnTop = true
arrowGui.LightInfluence = 0
arrowGui.StudsOffset = V(0, 3, 0)
arrowGui.Adornee = arrowPart
arrowGui.Enabled = false
arrowGui.Parent = gui
local arrowText = Util.label(arrowGui, "", C(255, 230, 60), UDim2.fromScale(1, 0.45), UDim2.fromScale(0, 0))
local arrowSign = Util.label(arrowGui, "▼", C(255, 230, 60), UDim2.fromScale(1, 0.55), UDim2.fromScale(0, 0.45))

local pathBeam = Instance.new("Beam")
pathBeam.Color = ColorSequence.new(C(255, 230, 60))
pathBeam.LightEmission = 1
pathBeam.FaceCamera = true
pathBeam.Width0 = 0.5
pathBeam.Width1 = 0.5
pathBeam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 0.6) })
pathBeam.Segments = 1
pathBeam.Enabled = false
pathBeam.Attachment1 = arrowAtt
pathBeam.Parent = arrowPart

local function tutorialTarget(): (Vector3?, string)
	local step = player:GetAttribute("Tutorial")
	if step == 1 then
		local char = player.Character
		local best, bestD = nil, math.huge
		for _, m in walkers:GetChildren() do
			if m:GetAttribute("ItemId") == "GrassAndFlowers" and m:GetAttribute("State") == "Carpet" and (m :: Model).PrimaryPart then
				local p = ((m :: Model).PrimaryPart :: BasePart).Position
				local d = char and char.PrimaryPart and (p - (char.PrimaryPart :: BasePart).Position).Magnitude or 0
				if d < bestD then
					best, bestD = p, d
				end
			end
		end
		return best, "Buy Grass and Flowers!"
	elseif step == 2 then
		local plot = myPlot()
		if plot then
			for _, tank in (plot:WaitForChild("Tanks")):GetChildren() do
				if tank:GetAttribute("ItemId") ~= "" and not tank:GetAttribute("Active") then
					local b = tank:FindFirstChild("Button") :: BasePart?
					if b then
						return b.Position, "Press the red button!"
					end
				end
			end
		end
		for _, m in walkers:GetChildren() do
			if m:GetAttribute("OwnerUserId") == player.UserId and (m :: Model).PrimaryPart then
				return ((m :: Model).PrimaryPart :: BasePart).Position, "It's walking to your base!"
			end
		end
	end
	return nil, ""
end

--------------------------------------------------------------------------------------------
-- intro, first time only

local introRunning = false

local function intro()
	local plot = myPlot()
	local tries = 0
	while not plot and tries < 50 do
		task.wait(0.1)
		tries += 1
		plot = myPlot()
	end
	if not plot then
		return
	end
	local p = plot :: Model
	local center = p:GetAttribute("SphereCenter") :: Vector3
	local R = p:GetAttribute("SphereR") :: number
	local tank = p:WaitForChild("Tanks"):WaitForChild("Tank1") :: Model
	local cap = tank:WaitForChild("Cap") :: BasePart
	local out = cap:WaitForChild("BeamOut") :: Attachment
	introRunning = true

	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Scriptable
	local overlay = Util.label(gui, "Welcome to EVOLVE YOUR WORLD!", C(255, 230, 80), UDim2.new(0.8, 0, 0, 70), UDim2.new(0.1, 0, 0.12, 0))
	local t0 = os.clock()
	local orbit = RunService.RenderStepped:Connect(function()
		local t = os.clock() - t0
		local fwd = p:GetPivot().LookVector
		local eye = center + fwd * R * 2.8 + V(math.sin(t * 0.25) * R * 1.6, R * 0.7, 0)
		cam.CFrame = CFrame.lookAt(eye, center - V(0, R * 0.25, 0))
	end)

	task.wait(1.6)
	overlay.Text = "Put an item into a tank..."
	local demo = Characters.buildStatic("GrassAndFlowers", 0.75)
	demo.Parent = Fx.folder
	local tankPos = tank:GetPivot().Position
	local d0 = os.clock()
	local drop = RunService.RenderStepped:Connect(function(dt)
		local k = math.clamp((os.clock() - d0) / 1.2, 0, 1)
		local y = tankPos.Y + 12 - k * 9
		Characters.place(demo, V(tankPos.X, y - 2, tankPos.Z), os.clock())
		Gait.sleep(demo, os.clock())
	end)
	task.wait(1.4)
	overlay.Text = "...press the red button..."
	task.wait(0.8)
	local cleanup: (() -> ())? = nil
	Fx.beam(out, center, ItemData.beamSequence("GrassAndFlowers"), function()
		cleanup = SphereWorld.demo(p, "GrassAndFlowers")
	end)
	task.wait(0.9)
	overlay.Text = "...and your world grows inside the sphere!"
	task.wait(2.2)
	local cleanup2 = SphereWorld.demo(p, "MagicTree")
	Fx.beam(out, center, ItemData.beamSequence("MagicTree"))
	task.wait(2.5)
	overlay.Text = "Every item makes money every second. Collect it on the green pad!"
	task.wait(3)
	drop:Disconnect()
	orbit:Disconnect()
	demo:Destroy()
	if cleanup then
		cleanup()
	end
	cleanup2()
	overlay:Destroy()
	cam.CameraType = Enum.CameraType.Custom
	introRunning = false
	toast("You start with $1. Follow the yellow arrow!", "good")
end

task.spawn(function()
	task.wait(2.5)
	if player:GetAttribute("FirstJoin") then
		intro()
	end
end)

--------------------------------------------------------------------------------------------
-- every frame: walking animations, walk effects, sleeping items, sphere worlds, arrow

local t = 0
RunService.RenderStepped:Connect(function(dt)
	t += dt

	for _, m in walkers:GetChildren() do
		local model = m :: Model
		local root = model.PrimaryPart
		if root then
			local v = root.AssemblyLinearVelocity
			local speed = Vector3.new(v.X, 0, v.Z).Magnitude
			Gait.update(model, dt, speed, t)
			WalkFx.update(model, dt, speed)
		end
	end

	for _, plot in plotsFolder:GetChildren() do
		local tanks = plot:FindFirstChild("Tanks")
		if tanks then
			for _, tank in tanks:GetChildren() do
				local sleeper = tank:FindFirstChild("Sleeper") :: Model?
				if sleeper then
					local base = sleeper:GetAttribute("Base") :: CFrame?
					if base then
						local i = (tank:GetAttribute("Index") :: number?) or 0
						sleeper:PivotTo(base * CFrame.new(0, math.sin(t * 1.4 + i) * 0.25, 0) * CFrame.Angles(0, math.sin(t * 0.5 + i) * 0.15, 0))
					end
					Gait.sleep(sleeper, t)
				end
			end
		end
	end

	SphereWorld.update(dt, t)

	local target, text = tutorialTarget()
	if target and not introRunning then
		arrowPart.CFrame = CFrame.new(target + V(0, 2 + math.abs(math.sin(t * 4)) * 0.8, 0))
		arrowGui.Enabled = true
		arrowText.Text = text
		arrowSign.Position = UDim2.fromScale(0, 0.45 + math.abs(math.sin(t * 4)) * 0.08)
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local a = hrp:FindFirstChild("TutorialFrom") :: Attachment?
			if not a then
				local na = Instance.new("Attachment")
				na.Name = "TutorialFrom"
				na.Parent = hrp
				a = na
			end
			pathBeam.Attachment0 = a
			pathBeam.Enabled = true
		end
	else
		arrowGui.Enabled = false
		pathBeam.Enabled = false
	end
end)
