--[[
	Map: builds the whole world from code.
	  - grass ground, the red carpet with gold edges
	  - the black box where items come out, and the portal at the end where they vanish
	  - 10 bases (5 on each side of the carpet), each with:
	      gate + name sign, collect pad, "new machine" pad, green tanks, the big sphere
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Util = require(Shared.Util)

local C, V = Color3.fromRGB, Vector3.new
local part, cylinder = Util.part, Util.cylinder

local Map = {}

Map.FLOOR_Y = 0.6

local function setupLighting()
	Lighting.ClockTime = 14.5
	Lighting.Brightness = 2.2
	Lighting.Ambient = C(90, 90, 110)
	Lighting.OutdoorAmbient = C(140, 140, 160)
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.EnvironmentSpecularScale = 0.6
	Lighting.GlobalShadows = true
	local bloom = Instance.new("BloomEffect")
	bloom.Intensity = 0.6
	bloom.Size = 28
	bloom.Threshold = 1.6
	bloom.Parent = Lighting
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Saturation = 0.15
	cc.Contrast = 0.06
	cc.Parent = Lighting
	local atm = Instance.new("Atmosphere")
	atm.Density = 0.28
	atm.Color = C(200, 220, 255)
	atm.Decay = C(120, 140, 200)
	atm.Glare = 0.2
	atm.Haze = 1.2
	atm.Parent = Lighting
end

function Map.buildWorld(): Folder
	setupLighting()
	local world = Instance.new("Folder")
	world.Name = "World"
	world.Parent = workspace

	part({ Name = "Ground", Size = V(420, 2, 260), CFrame = CFrame.new(0, -1, 0), Color = C(95, 175, 75), Material = Enum.Material.Grass, Parent = world })

	-- red carpet with gold edges
	local len = Config.CarpetEndX - Config.CarpetStartX + 10
	local midX = (Config.CarpetEndX + Config.CarpetStartX) / 2
	part({ Name = "RedCarpet", Size = V(len, 0.2, 12), CFrame = CFrame.new(midX, 0.1, 0), Color = C(200, 20, 35), Material = Enum.Material.Fabric, Parent = world })
	for _, z in { -6.3, 6.3 } do
		part({ Name = "CarpetEdge", Size = V(len, 0.35, 0.6), CFrame = CFrame.new(midX, 0.17, z), Color = C(245, 195, 60), Material = Enum.Material.Metal, Parent = world })
	end
	-- golden posts with velvet ropes along the carpet
	for x = Config.CarpetStartX + 10, Config.CarpetEndX - 10, 20 do
		for _, z in { -7.4, 7.4 } do
			cylinder(CFrame.new(x, 1.5, z), 0.5, 3, { Name = "Post", Color = C(245, 195, 60), Material = Enum.Material.Metal, CanCollide = false, Parent = world })
			part({ Shape = Enum.PartType.Ball, Size = V(0.8, 0.8, 0.8), CFrame = CFrame.new(x, 3.2, z), Color = C(245, 195, 60), Material = Enum.Material.Metal, CanCollide = false, Parent = world })
		end
	end

	-- the black box where everything comes out
	local bx = Config.CarpetStartX - 6
	local box = part({ Name = "BlackBox", Size = V(14, 14, 18), CFrame = CFrame.new(bx, 7, 0), Color = C(12, 12, 16), Material = Enum.Material.SmoothPlastic, Parent = world })
	part({ Name = "BoxDoor", Size = V(0.4, 9, 11), CFrame = CFrame.new(bx + 7.05, 4.6, 0), Color = C(5, 5, 8), Material = Enum.Material.Neon, Parent = world })
	part({ Name = "BoxTrim", Size = V(0.5, 0.5, 12), CFrame = CFrame.new(bx + 7.1, 9.3, 0), Color = C(200, 20, 35), Material = Enum.Material.Neon, Parent = world })
	for _, z in { -5.8, 5.8 } do
		part({ Name = "BoxTrim", Size = V(0.5, 9.2, 0.5), CFrame = CFrame.new(bx + 7.1, 4.7, z), Color = C(200, 20, 35), Material = Enum.Material.Neon, Parent = world })
	end
	local smoke = Instance.new("ParticleEmitter")
	smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
	smoke.Rate = 6
	smoke.Lifetime = NumberRange.new(1.5, 2.5)
	smoke.Speed = NumberRange.new(1, 2)
	smoke.Size = NumberSequence.new(2, 5)
	smoke.Transparency = NumberSequence.new(0.6, 1)
	smoke.Color = ColorSequence.new(C(40, 40, 50))
	smoke.EmissionDirection = Enum.NormalId.Right
	smoke.Parent = box
	local bb = Util.billboard(box, UDim2.fromOffset(300, 70), V(0, 9.5, 0), 250)
	Util.label(bb, "EVOLVE YOUR WORLD", C(255, 215, 70), UDim2.fromScale(1, 1), UDim2.fromScale(0, 0))

	-- the portal at the end of the carpet where unsold items disappear
	local ex = Config.CarpetEndX + 4
	local ring = part({ Name = "ExitPortal", Size = V(0.6, 10, 10), CFrame = CFrame.new(ex, 5, 0), Color = C(120, 60, 220), Material = Enum.Material.Neon, Transparency = 0.35, Parent = world })
	local sparkle = Instance.new("ParticleEmitter")
	sparkle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	sparkle.Rate = 20
	sparkle.Lifetime = NumberRange.new(1, 1.5)
	sparkle.Speed = NumberRange.new(2, 4)
	sparkle.LightEmission = 1
	sparkle.Color = ColorSequence.new(C(200, 150, 255), C(120, 200, 255))
	sparkle.Parent = ring

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.Size = V(8, 0.4, 8)
	spawn.CFrame = CFrame.new(0, 0.2, 18)
	spawn.Transparency = 1
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = world

	return world
end

-- Where tank number i stands, in the base's own coordinates (-Z points at the carpet).
function Map.tankLocal(i: number): Vector3
	local x = (i % 2 == 1) and -17 or 17
	local row = math.floor((i - 1) / 2)
	return V(x, Map.FLOOR_Y, -12 + row * 8.5)
end

function Map.sphereLocal(R: number): Vector3
	return V(0, Map.FLOOR_Y + 7 + R, 10)
end

function Map.buildTank(plot: Model, i: number): Model
	local cf = plot:GetPivot() * CFrame.new(Map.tankLocal(i))
	local tank = Instance.new("Model")
	tank.Name = "Tank" .. i
	tank:SetAttribute("Index", i)
	tank:SetAttribute("ItemId", "")
	tank:SetAttribute("Active", false)

	local metal = C(70, 75, 90)
	local base = cylinder(cf * CFrame.new(0, 0.6, 0), 5.2, 1.2, { Name = "Base", Color = metal, Material = Enum.Material.DiamondPlate, Parent = tank })
	cylinder(cf * CFrame.new(0, 1.25, 0), 5.4, 0.2, { Name = "Ring", Color = C(80, 255, 120), Material = Enum.Material.Neon, CanCollide = false, Parent = tank })
	local glass = cylinder(cf * CFrame.new(0, 4.8, 0), 4.5, 7, { Name = "Glass", Color = C(200, 255, 220), Material = Enum.Material.Glass, Transparency = 0.7, CanCollide = true, CastShadow = false, Parent = tank })
	cylinder(cf * CFrame.new(0, 4.6, 0), 4.1, 6.5, { Name = "Liquid", Color = C(60, 255, 100), Material = Enum.Material.Neon, Transparency = 0.82, CanCollide = false, CastShadow = false, Parent = tank })
	local cap = cylinder(cf * CFrame.new(0, 8.7, 0), 5.2, 0.9, { Name = "Cap", Color = metal, Material = Enum.Material.Metal, Parent = tank })
	cylinder(cf * CFrame.new(0, 9.35, 0), 1.6, 0.6, { Name = "Emitter", Color = C(80, 255, 120), Material = Enum.Material.Neon, Parent = tank })
	for _, a in { 0, 120, 240 } do
		local r = math.rad(a)
		part({ Name = "Pipe", Size = V(0.35, 7, 0.35), CFrame = cf * CFrame.new(math.cos(r) * 2.45, 4.8, math.sin(r) * 2.45), Color = metal, Material = Enum.Material.Metal, Parent = tank })
	end
	local out = Instance.new("Attachment")
	out.Name = "BeamOut"
	out.Position = cap.CFrame:PointToObjectSpace(cf * Vector3.new(0, 9.8, 0))
	out.Parent = cap

	local bubbles = Instance.new("ParticleEmitter")
	bubbles.Name = "Bubbles"
	bubbles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	bubbles.Rate = 6
	bubbles.Lifetime = NumberRange.new(1.5, 2.5)
	bubbles.Speed = NumberRange.new(1.5, 3)
	bubbles.SpreadAngle = Vector2.new(10, 10)
	bubbles.Size = NumberSequence.new(0.25, 0.4)
	bubbles.Transparency = NumberSequence.new(0.3, 1)
	bubbles.Color = ColorSequence.new(C(180, 255, 190))
	bubbles.LightEmission = 0.6
	bubbles.EmissionDirection = Enum.NormalId.Top
	bubbles.Parent = base

	-- the wire that holds the sleeping character
	part({ Name = "Wire", Size = V(0.12, 2.2, 0.12), CFrame = cf * CFrame.new(0, 7.2, 0), Color = C(25, 25, 30), CanCollide = false, Parent = tank })

	-- the launch button in front of the tank (towards the middle of the base)
	local inward = (Map.tankLocal(i).X < 0) and 1 or -1
	local bcf = cf * CFrame.new(inward * 4.3, 0, 0)
	cylinder(bcf * CFrame.new(0, 0.9, 0), 1.6, 1.8, { Name = "ButtonStand", Color = metal, Material = Enum.Material.Metal, Parent = tank })
	local button = cylinder(bcf * CFrame.new(0, 1.95, 0), 1.3, 0.35, { Name = "Button", Color = C(255, 40, 40), Material = Enum.Material.Neon, Parent = tank })

	local activate = Instance.new("ProximityPrompt")
	activate.Name = "Activate"
	activate.ActionText = "Launch Beam"
	activate.ObjectText = "Tank " .. i
	activate.HoldDuration = 0.2
	activate.MaxActivationDistance = 9
	activate.RequiresLineOfSight = false
	activate.Enabled = false
	activate:SetAttribute("OwnerOnly", true)
	activate.Parent = button

	local sell = Instance.new("ProximityPrompt")
	sell.Name = "Sell"
	sell.ActionText = "Sell"
	sell.HoldDuration = 1.2
	sell.KeyboardKeyCode = Enum.KeyCode.F
	sell.MaxActivationDistance = 9
	sell.RequiresLineOfSight = false
	sell.UIOffset = Vector2.new(0, 60)
	sell.Enabled = false
	sell:SetAttribute("OwnerOnly", true)
	sell.Parent = glass

	tank.PrimaryPart = base
	tank.Parent = plot:FindFirstChild("Tanks")
	return tank
end

function Map.buildSphere(plot: Model, R: number)
	local old = plot:FindFirstChild("SphereRig")
	if old then
		old:Destroy()
	end
	local rig = Instance.new("Model")
	rig.Name = "SphereRig"
	local pcf = plot:GetPivot()
	local center = (pcf * CFrame.new(Map.sphereLocal(R))).Position

	cylinder(pcf * CFrame.new(0, Map.FLOOR_Y + 3.5, 10), 6, 7, { Name = "Pedestal", Color = C(60, 65, 80), Material = Enum.Material.Metal, Parent = rig })
	cylinder(pcf * CFrame.new(0, Map.FLOOR_Y + 6.9, 10), 7.5, 0.5, { Name = "PedestalRing", Color = C(120, 220, 255), Material = Enum.Material.Neon, Parent = rig })
	local sphere = part({ Name = "Sphere", Shape = Enum.PartType.Ball, Size = V(R * 2, R * 2, R * 2), CFrame = CFrame.new(center), Color = C(150, 225, 255), Material = Enum.Material.Glass, Transparency = 0.78, CanCollide = false, CastShadow = false, Parent = rig })
	part({ Name = "Shell", Shape = Enum.PartType.Ball, Size = V(R * 2 - 0.5, R * 2 - 0.5, R * 2 - 0.5), CFrame = CFrame.new(center), Color = C(120, 210, 255), Material = Enum.Material.ForceField, Transparency = 0.1, CanCollide = false, CastShadow = false, Parent = rig })
	cylinder(CFrame.new(center), R * 2 + 0.7, 0.18, { Name = "Equator", Color = C(150, 235, 255), Material = Enum.Material.Neon, CanCollide = false, Parent = rig })
	local groundY = center.Y - R * 0.32
	cylinder(CFrame.new(center.X, groundY - 0.3, center.Z), R * 1.75, 0.6, { Name = "Land", Color = C(105, 85, 60), Material = Enum.Material.Ground, CanCollide = false, Parent = rig })
	cylinder(CFrame.new(center.X, groundY - 0.02, center.Z), R * 1.7, 0.08, { Name = "Soil", Color = C(125, 100, 70), Material = Enum.Material.Ground, CanCollide = false, Parent = rig })
	local inner = Instance.new("Attachment")
	inner.Name = "Center"
	inner.Parent = sphere
	local glow = Instance.new("PointLight")
	glow.Color = C(150, 220, 255)
	glow.Range = R * 1.6
	glow.Brightness = 1.2
	glow.Parent = sphere
	rig.Parent = plot

	plot:SetAttribute("SphereR", R)
	plot:SetAttribute("SphereCenter", center)
	plot:SetAttribute("GroundY", groundY)
end

function Map.buildPlot(index: number, cf: CFrame): Model
	local plot = Instance.new("Model")
	plot.Name = "Plot" .. index
	plot:SetAttribute("Index", index)
	plot:SetAttribute("OwnerUserId", 0)
	plot:SetAttribute("OwnerName", "")
	plot:SetAttribute("Machines", Config.StartMachines)
	plot:SetAttribute("Pending", 0)

	local S = Config.PlotSize
	local floor = part({ Name = "Floor", Size = V(S.X, 1, S.Z), CFrame = cf * CFrame.new(0, Map.FLOOR_Y - 0.5, 0), Color = C(200, 205, 220), Material = Enum.Material.Concrete, Parent = plot })
	plot.PrimaryPart = floor
	plot.WorldPivot = cf
	part({ Name = "FloorInlay", Size = V(S.X - 4, 0.05, S.Z - 4), CFrame = cf * CFrame.new(0, Map.FLOOR_Y + 0.02, 0), Color = C(225, 230, 240), Material = Enum.Material.Marble, CanCollide = false, Parent = plot })

	-- low walls on the sides and back, open in front
	local wallC = C(120, 200, 255)
	for _, x in { -S.X / 2 + 0.5, S.X / 2 - 0.5 } do
		part({ Name = "Wall", Size = V(1, 3, S.Z), CFrame = cf * CFrame.new(x, Map.FLOOR_Y + 1.5, 0), Color = C(235, 240, 250), Material = Enum.Material.SmoothPlastic, Parent = plot })
		part({ Name = "WallTrim", Size = V(1.1, 0.25, S.Z), CFrame = cf * CFrame.new(x, Map.FLOOR_Y + 3.1, 0), Color = wallC, Material = Enum.Material.Neon, Parent = plot })
	end
	part({ Name = "Wall", Size = V(S.X, 3, 1), CFrame = cf * CFrame.new(0, Map.FLOOR_Y + 1.5, S.Z / 2 - 0.5), Color = C(235, 240, 250), Material = Enum.Material.SmoothPlastic, Parent = plot })
	part({ Name = "WallTrim", Size = V(S.X, 0.25, 1.1), CFrame = cf * CFrame.new(0, Map.FLOOR_Y + 3.1, S.Z / 2 - 0.5), Color = wallC, Material = Enum.Material.Neon, Parent = plot })

	-- gate with the owner's name
	local gz = -S.Z / 2 + 0.5
	for _, x in { -9, 9 } do
		part({ Name = "GatePost", Size = V(1.6, 11, 1.6), CFrame = cf * CFrame.new(x, Map.FLOOR_Y + 5.5, gz), Color = C(60, 65, 80), Material = Enum.Material.Metal, Parent = plot })
		part({ Name = "GateLight", Size = V(1.7, 0.4, 1.7), CFrame = cf * CFrame.new(x, Map.FLOOR_Y + 11.2, gz), Color = wallC, Material = Enum.Material.Neon, Parent = plot })
	end
	local beam = part({ Name = "GateTop", Size = V(20, 2.2, 1.6), CFrame = cf * CFrame.new(0, Map.FLOOR_Y + 10, gz), Color = C(60, 65, 80), Material = Enum.Material.Metal, Parent = plot })
	local sign = Util.billboard(beam, UDim2.fromOffset(360, 90), V(0, 3.2, 0), 200)
	sign.Name = "Sign"
	local name = Util.label(sign, "EMPTY BASE", C(255, 255, 255), UDim2.fromScale(1, 1), UDim2.fromScale(0, 0))
	name.Name = "OwnerName"
	name.TextTransparency = 0.5

	-- collect pad
	local pcf = cf * CFrame.new(-13, Map.FLOOR_Y + 0.2, -21)
	local pad = cylinder(pcf, 6, 0.4, { Name = "CollectPad", Color = C(60, 255, 110), Material = Enum.Material.Neon, Parent = plot })
	cylinder(pcf * CFrame.new(0, -0.05, 0), 7, 0.3, { Name = "CollectRim", Color = C(245, 195, 60), Material = Enum.Material.Metal, Parent = plot })
	local pbb = Util.billboard(pad, UDim2.fromOffset(220, 110), V(0, 4.5, 0), 90)
	pbb.Name = "Info"
	Util.label(pbb, "COLLECT", C(255, 255, 255), UDim2.fromScale(1, 0.4), UDim2.fromScale(0, 0))
	local amount = Util.label(pbb, "$0", C(90, 255, 120), UDim2.fromScale(1, 0.6), UDim2.fromScale(0, 0.4))
	amount.Name = "Amount"

	-- new machine pad
	local scf = cf * CFrame.new(13, Map.FLOOR_Y + 0.2, -21)
	local shop = cylinder(scf, 6, 0.4, { Name = "MachinePad", Color = C(70, 150, 255), Material = Enum.Material.Neon, Parent = plot })
	cylinder(scf * CFrame.new(0, -0.05, 0), 7, 0.3, { Name = "MachineRim", Color = C(245, 195, 60), Material = Enum.Material.Metal, Parent = plot })
	local sbb = Util.billboard(shop, UDim2.fromOffset(240, 110), V(0, 4.5, 0), 90)
	sbb.Name = "Info"
	Util.label(sbb, "NEW MACHINE", C(255, 255, 255), UDim2.fromScale(1, 0.4), UDim2.fromScale(0, 0))
	local price = Util.label(sbb, "", C(120, 200, 255), UDim2.fromScale(1, 0.6), UDim2.fromScale(0, 0.4))
	price.Name = "Price"
	local buy = Instance.new("ProximityPrompt")
	buy.Name = "BuyMachine"
	buy.ActionText = "Buy Machine"
	buy.HoldDuration = 0.5
	buy.MaxActivationDistance = 8
	buy.RequiresLineOfSight = false
	buy:SetAttribute("OwnerOnly", true)
	buy.Parent = shop

	local tanks = Instance.new("Folder")
	tanks.Name = "Tanks"
	tanks.Parent = plot

	plot.Parent = workspace:WaitForChild("Plots")
	Map.buildSphere(plot, Config.sphereRadius(Config.StartMachines))
	for i = 1, Config.StartMachines do
		Map.buildTank(plot, i)
	end
	return plot
end

function Map.buildPlots(): { Model }
	local folder = Instance.new("Folder")
	folder.Name = "Plots"
	folder.Parent = workspace
	local plots = {}
	local idx = 0
	for _, side in { -1, 1 } do
		for _, x in Config.PlotXs do
			idx += 1
			local center = V(x, 0, side * Config.PlotZ)
			local cf = CFrame.lookAt(center, center + V(0, 0, -side))
			table.insert(plots, Map.buildPlot(idx, cf))
		end
	end
	return plots
end

-- Points a walker follows from the carpet into a base, to tank i.
function Map.pathToTank(plot: Model, i: number): { Vector3 }
	local cf = plot:GetPivot()
	local S = Config.PlotSize
	local side = (cf.Position.Z > 0) and 1 or -1
	local tl = Map.tankLocal(i)
	local inward = (tl.X < 0) and 1 or -1
	return {
		V(cf.Position.X, 0, side * 4),
		(cf * CFrame.new(0, 0, -S.Z / 2 - 3)).Position,
		(cf * CFrame.new(0, Map.FLOOR_Y, -S.Z / 2 + 6)).Position,
		(cf * CFrame.new(tl.X + inward * 7, Map.FLOOR_Y, tl.Z)).Position,
		(cf * CFrame.new(tl.X + inward * 3, Map.FLOOR_Y, tl.Z)).Position,
	}
end

function Map.spawnPoint(plot: Model): CFrame
	local cf = plot:GetPivot()
	return cf * CFrame.new(0, Map.FLOOR_Y + 3, -Config.PlotSize.Z / 2 + 4) * CFrame.Angles(0, math.pi, 0)
end

return Map
