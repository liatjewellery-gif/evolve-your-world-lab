--[[
	SphereWorld: what grows inside each base's sphere (runs on every player's computer,
	so it is smooth and costs the server nothing).

	When a tank turns Active, the laser shoots into the sphere and the item's world appears:
	  Grass and Flowers  grass over the whole sphere + 5 flowers
	  Magic Tree         10 trees of all kinds; leaves fall and grow back
	  Lava Stone         3 volcanoes that blow smoke every minute
	  Blue Crystal       10 sparkling blue crystals
	  Giraffe            5 giraffes; they eat from trees (the tree grows back) or wander
	  Cosmic Meteor      a meteor falls every 5 seconds (just pretty)
	  Solario Leonario   a lion that rests, walks, and hunts giraffes (they come back)
	  Drippo Bloxino     a person who builds 3 buildings
	  Zombino Rotolino   a zombie that bites trees, flowers and buildings (they grow back)
	  Frosty Fangolini   an ice tiger that wanders and runs; steam when passing a volcano
	  Witchina Magichina brews potions; throws one and nearby plants glow purple and grow
	  Galaxy Dragon      hovers with wings; burns falling meteors into fireworks
	When the tank is sold, that item's world disappears.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ItemData = require(Shared.ItemData)
local Characters = require(Shared.Characters)
local Gait = require(Shared.Gait)
local Fx = require(script.Parent.Fx)

local C, V = Color3.fromRGB, Vector3.new
local SphereWorld = {}

--------------------------------------------------------------------------------------------
-- types

type Thing = {
	model: Model,
	pos: Vector3,
	alive: boolean,
	kind: string,
	bite: ((Thing) -> ())?,
	glow: ((Thing) -> ())?,
	steam: ((Thing) -> ())?,
}

type Handle = {
	id: string,
	folder: Folder,
	things: { Thing },
	update: ((Handle, number, number) -> ())?,
	data: { [string]: any },
}

type World = {
	plot: Model,
	folder: Folder,
	center: Vector3,
	R: number,
	u: number,
	groundY: number,
	items: { [number]: Handle },
	trees: { Thing },
	flowers: { Thing },
	buildings: { Thing },
	volcanoes: { Thing },
	giraffes: { any },
	dragons: { any },
	meteors: { any },
	lawn: Instance?,
	rng: Random,
}

local worlds: { [Model]: World } = {}

--------------------------------------------------------------------------------------------
-- helpers

local function newPart(props: { [string]: any }): BasePart
	local p = Instance.new(props.ClassName or "Part") :: BasePart
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for k, v in props do
		if k ~= "ClassName" and k ~= "Parent" and k ~= "Ell" then
			(p :: any)[k] = v
		end
	end
	if props.Ell then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = p
	end
	p.Parent = props.Parent
	return p
end

local function cyl(parent: Instance, cf: CFrame, d: number, h: number, color: Color3, mat: Enum.Material?): BasePart
	return newPart({ Shape = Enum.PartType.Cylinder, Size = V(h, d, d), CFrame = cf * CFrame.Angles(0, 0, math.pi / 2), Color = color, Material = mat or Enum.Material.SmoothPlastic, Parent = parent })
end

local function model(parent: Instance, name: string, pivot: Vector3): Model
	local m = Instance.new("Model")
	m.Name = name
	m.WorldPivot = CFrame.new(pivot)
	m.Parent = parent
	return m
end

local function point(W: World, margin: number?): Vector3
	local maxR = W.R * 0.72 - (margin or 0)
	local r = math.sqrt(W.rng:NextNumber()) * maxR
	local a = W.rng:NextNumber(0, math.pi * 2)
	return V(W.center.X + math.cos(a) * r, W.groundY, W.center.Z + math.sin(a) * r)
end

local function clampInside(W: World, p: Vector3, margin: number): Vector3
	local flat = V(p.X - W.center.X, 0, p.Z - W.center.Z)
	local maxR = W.R * 0.74 - margin
	if flat.Magnitude > maxR then
		flat = flat.Unit * maxR
	end
	return V(W.center.X + flat.X, W.groundY, W.center.Z + flat.Z)
end

local function grow(m: Model, dur: number?)
	Fx.scaleModel(m, 0.02, 1, dur or 1.2)
end

local function emitter(parent: Instance, props: { [string]: any }): ParticleEmitter
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = Fx.TEX.sparkle
	pe.LightEmission = 1
	for k, v in props do
		(pe :: any)[k] = v
	end
	pe.Parent = parent
	return pe
end

local function removeFrom(list: { any }, x: any)
	local i = table.find(list, x)
	if i then
		table.remove(list, i)
	end
end

-- Temporarily destroy a thing and let it grow back (used by the zombie and giraffes).
local function biteThing(th: Thing, full: boolean)
	if not th.alive then
		return
	end
	if full then
		th.alive = false
		Fx.burst(th.pos + V(0, 0.6, 0), ColorSequence.new(C(120, 200, 80), C(110, 80, 50)), 18, 5, 0.4)
		Fx.scaleModel(th.model, 1, 0.03, 0.35, function()
			task.delay(4.5, function()
				if th.model.Parent then
					Fx.scaleModel(th.model, 0.03, 1, 1.5, function()
						th.alive = true
					end)
				end
			end)
		end)
	else
		Fx.scaleModel(th.model, 1, 0.82, 0.4, function()
			task.delay(2.5, function()
				if th.model.Parent then
					Fx.scaleModel(th.model, 0.82, 1, 1.5)
				end
			end)
		end)
	end
end

-- Witch potion: glow purple and grow for a few seconds.
local function glowThing(th: Thing)
	if not th.alive or th.model:GetAttribute("Glowing") then
		return
	end
	th.model:SetAttribute("Glowing", true)
	local saved = {}
	for _, d in th.model:GetDescendants() do
		if d:IsA("BasePart") then
			saved[d] = { d.Color, d.Material }
			d.Color = d.Color:Lerp(C(190, 90, 255), 0.65)
			d.Material = Enum.Material.Neon
		end
	end
	local light = Instance.new("PointLight")
	light.Color = C(190, 90, 255)
	light.Range = 6
	light.Brightness = 2
	light.Parent = th.model:FindFirstChildWhichIsA("BasePart")
	Fx.scaleModel(th.model, 1, 1.3, 0.5)
	task.delay(4, function()
		for part, s in saved do
			if part.Parent then
				part.Color = s[1]
				part.Material = s[2]
			end
		end
		light:Destroy()
		if th.model.Parent then
			th.model:SetAttribute("Glowing", nil)
			Fx.scaleModel(th.model, 1.3, 1, 0.8)
		end
	end)
end

--------------------------------------------------------------------------------------------
-- creatures inside the sphere (small copies of the real characters)

local heightCache: { [string]: number } = {}
local function templateHeight(id: string): number
	local h = heightCache[id]
	if not h then
		local m = Characters.buildStatic(id)
		h = m:GetExtentsSize().Y
		m:Destroy()
		heightCache[id] = h
	end
	return h
end

type Mini = { model: Model, pos: Vector3, yaw: number, k: number, target: Vector3?, speed: number, hidden: boolean, state: string, timer: number, data: { [string]: any } }

local function mini(W: World, parent: Instance, id: string, height: number, pos: Vector3?): Mini
	local k = height / templateHeight(id)
	local m = Characters.buildStatic(id, k)
	m.Parent = parent
	local p = pos or point(W, W.u)
	local mm: Mini = { model = m, pos = p, yaw = W.rng:NextNumber(0, math.pi * 2), k = k, target = nil, speed = 0, hidden = false, state = "idle", timer = W.rng:NextNumber(0, 3), data = {} }
	Characters.place(m, p, mm.yaw)
	return mm
end

local function lerpAngle(a: number, b: number, t: number): number
	local d = (b - a + math.pi) % (math.pi * 2) - math.pi
	return a + d * t
end

-- Moves a mini toward its target. Returns true when it has arrived.
local function stepMini(W: World, mm: Mini, dt: number, t: number, speed: number, lift: number?): boolean
	local arrived = false
	local moving = 0
	if mm.target then
		local to = mm.target :: Vector3
		local d = V(to.X - mm.pos.X, 0, to.Z - mm.pos.Z)
		local dist = d.Magnitude
		if dist < 0.15 * W.u + 0.05 then
			arrived = true
			mm.target = nil
		else
			local step = math.min(speed * dt, dist)
			mm.pos = clampInside(W, mm.pos + d.Unit * step, W.u * 0.5)
			mm.yaw = lerpAngle(mm.yaw, math.atan2(-d.X, -d.Z), math.min(dt * 6, 1))
			moving = speed
		end
	end
	if not mm.hidden then
		Characters.place(mm.model, mm.pos + V(0, lift or 0, 0), mm.yaw)
		Gait.update(mm.model, dt, moving / mm.k, t)
	end
	return arrived
end

local function hideMini(W: World, mm: Mini, seconds: number)
	mm.hidden = true
	Fx.burst(mm.model:GetPivot().Position, ColorSequence.new(C(255, 240, 150), C(255, 255, 255)), 30, 6, 0.5)
	mm.model:PivotTo(CFrame.new(0, -500, 0))
	task.delay(seconds, function()
		if mm.model.Parent then
			mm.pos = point(W, W.u)
			mm.hidden = false
			Characters.place(mm.model, mm.pos, mm.yaw)
			Fx.burst(mm.pos + V(0, 1, 0), ColorSequence.new(C(255, 240, 150), C(255, 255, 255)), 20, 4, 0.4)
		end
	end)
end

--------------------------------------------------------------------------------------------
-- builders for each item

local TREE_KINDS = { "apple", "pine", "round", "blossom", "birch", "magic", "orange", "willow" }

local function makeTree(W: World, parent: Instance, pos: Vector3, kind: string): Thing
	local u = W.u
	local m = model(parent, "Tree", pos)
	local trunkC = (kind == "birch") and C(235, 235, 225) or C(120 + W.rng:NextInteger(-10, 10), 78, 42)
	local h = u * W.rng:NextNumber(1.3, 1.8)
	cyl(m, CFrame.new(pos + V(0, h / 2, 0)), u * 0.32, h, trunkC, Enum.Material.Wood)
	local top = pos + V(0, h, 0)
	if kind == "pine" then
		for k = 0, 3 do
			cyl(m, CFrame.new(top + V(0, k * u * 0.45 - u * 0.2, 0)), u * (1.6 - k * 0.35), u * 0.5, C(40, 120 + k * 10, 55))
		end
	elseif kind == "willow" then
		newPart({ Ell = true, Size = V(u * 2, u * 1.3, u * 2), CFrame = CFrame.new(top), Color = C(120, 190, 90), Parent = m })
		for k = 0, 7 do
			local a = k / 8 * math.pi * 2
			newPart({ Ell = true, Size = V(u * 0.3, u * 1.4, u * 0.3), CFrame = CFrame.new(top + V(math.cos(a) * u * 0.85, -u * 0.6, math.sin(a) * u * 0.85)), Color = C(110, 180, 80), Parent = m })
		end
	else
		local leaf = ({ apple = C(70, 160, 60), round = C(110, 190, 70), blossom = C(255, 170, 210), birch = C(150, 210, 90), magic = C(90, 230, 210), orange = C(60, 140, 55) })[kind] or C(80, 170, 60)
		local mat = (kind == "magic") and Enum.Material.Neon or Enum.Material.Grass
		newPart({ Ell = true, Size = V(u * 1.9, u * 1.6, u * 1.9), CFrame = CFrame.new(top + V(0, u * 0.3, 0)), Color = leaf, Material = mat, Parent = m })
		newPart({ Ell = true, Size = V(u * 1.2, u * 1.0, u * 1.2), CFrame = CFrame.new(top + V(u * 0.6, u * 0.05, u * 0.2)), Color = leaf:Lerp(C(255, 255, 255), 0.1), Material = mat, Parent = m })
		newPart({ Ell = true, Size = V(u * 1.1, u * 1.0, u * 1.1), CFrame = CFrame.new(top + V(-u * 0.55, u * 0.1, -u * 0.3)), Color = leaf:Lerp(C(0, 0, 0), 0.1), Material = mat, Parent = m })
		if kind == "apple" or kind == "orange" then
			local fruit = (kind == "apple") and C(220, 30, 40) or C(255, 150, 30)
			for k = 0, 5 do
				local a = k / 6 * math.pi * 2
				newPart({ Shape = Enum.PartType.Ball, Size = V(u * 0.24, u * 0.24, u * 0.24), CFrame = CFrame.new(top + V(math.cos(a) * u * 0.85, u * (0.1 + (k % 2) * 0.35), math.sin(a) * u * 0.85)), Color = fruit, Parent = m })
			end
		elseif kind == "magic" then
			emitter(m:FindFirstChildWhichIsA("BasePart") :: BasePart, { Rate = 3, Lifetime = NumberRange.new(1, 2), Speed = NumberRange.new(0.2, 0.6), Size = NumberSequence.new(0.2, 0), Color = ColorSequence.new(C(160, 255, 230)) })
		end
	end
	local th: Thing = { model = m, pos = pos, alive = true, kind = "tree" }
	th.bite = function(self: Thing)
		biteThing(self, false)
	end
	th.glow = glowThing
	grow(m, 1.0 + W.rng:NextNumber() * 0.8)
	return th
end

local function makeFlower(W: World, parent: Instance, pos: Vector3): Thing
	local u = W.u
	local m = model(parent, "Flower", pos)
	local h = u * W.rng:NextNumber(0.6, 0.9)
	cyl(m, CFrame.new(pos + V(0, h / 2, 0)), u * 0.08, h, C(70, 160, 50))
	newPart({ Ell = true, Size = V(u * 0.35, u * 0.12, u * 0.2), CFrame = CFrame.new(pos + V(u * 0.15, h * 0.4, 0)) * CFrame.Angles(0, 0, 0.5), Color = C(90, 180, 60), Parent = m })
	local top = pos + V(0, h, 0)
	local cols = { C(255, 105, 180), C(255, 150, 210), C(255, 80, 150), C(250, 250, 255), C(255, 200, 80) }
	local col = cols[W.rng:NextInteger(1, #cols)]
	for k = 0, 5 do
		local a = k / 6 * math.pi * 2
		newPart({ Ell = true, Size = V(u * 0.32, u * 0.08, u * 0.18), CFrame = CFrame.new(top + V(math.cos(a) * u * 0.17, 0, math.sin(a) * u * 0.17)) * CFrame.Angles(0, -a, 0.2), Color = col, Parent = m })
	end
	newPart({ Shape = Enum.PartType.Ball, Size = V(u * 0.18, u * 0.18, u * 0.18), CFrame = CFrame.new(top + V(0, u * 0.03, 0)), Color = C(255, 220, 60), Parent = m })
	local th: Thing = { model = m, pos = pos, alive = true, kind = "flower" }
	th.bite = function(self: Thing)
		biteThing(self, true)
	end
	th.glow = glowThing
	grow(m, 0.8)
	return th
end

local BUILD: { [string]: (World, Handle) -> () } = {}

BUILD.GrassAndFlowers = function(W, h)
	local u = W.u
	if not W.lawn or not W.lawn.Parent then
		W.lawn = cyl(W.folder, CFrame.new(W.center.X, W.groundY + 0.02, W.center.Z), W.R * 1.68, 0.08, C(95, 185, 70), Enum.Material.Grass)
		local lawn = W.lawn :: BasePart
		lawn.Transparency = 1
		TweenService:Create(lawn, TweenInfo.new(1.5), { Transparency = 0 }):Play()
		h.data.lawn = lawn
	end
	for _ = 1, 45 do
		local p = point(W, 0)
		newPart({ Ell = true, Size = V(u * 0.12, u * W.rng:NextNumber(0.3, 0.55), u * 0.12), CFrame = CFrame.new(p) * CFrame.Angles(W.rng:NextNumber(-0.3, 0.3), 0, W.rng:NextNumber(-0.3, 0.3)), Color = C(80, 170 + W.rng:NextInteger(0, 50), 60), Parent = h.folder })
	end
	for _ = 1, 5 do
		local th = makeFlower(W, h.folder, point(W, u * 0.4))
		table.insert(h.things, th)
		table.insert(W.flowers, th)
	end
	h.update = function(self, dt, t)
		for i, th in self.things do
			if th.alive and th.model.Parent and not th.model:GetAttribute("Glowing") then
				local pv = th.model:GetPivot()
				th.model:PivotTo(CFrame.new(pv.Position) * CFrame.Angles(math.sin(t * 1.5 + i) * 0.06, 0, math.cos(t * 1.3 + i) * 0.06))
			end
		end
	end
end

BUILD.MagicTree = function(W, h)
	for i = 1, 10 do
		local th = makeTree(W, h.folder, point(W, W.u * 1.2), TREE_KINDS[(i - 1) % #TREE_KINDS + 1])
		table.insert(h.things, th)
		table.insert(W.trees, th)
	end
	h.data.next = 3
	h.update = function(self, dt, t)
		self.data.next -= dt
		if self.data.next <= 0 then
			self.data.next = W.rng:NextNumber(3, 6)
			local th = self.things[W.rng:NextInteger(1, #self.things)]
			if th.alive and th.model.Parent then
				-- leaves fall, and the tree grows them back
				for _ = 1, 4 do
					local start = th.pos + V(W.rng:NextNumber(-1, 1) * W.u, W.u * 2, W.rng:NextNumber(-1, 1) * W.u)
					local leaf = newPart({ Ell = true, Size = V(W.u * 0.3, W.u * 0.05, W.u * 0.2), CFrame = CFrame.new(start), Color = C(120, 190, 60), Parent = Fx.folder })
					local land = V(start.X + W.rng:NextNumber(-1, 1) * W.u, W.groundY + 0.05, start.Z + W.rng:NextNumber(-1, 1) * W.u)
					TweenService:Create(leaf, TweenInfo.new(2.2, Enum.EasingStyle.Sine), { CFrame = CFrame.new(land) * CFrame.Angles(0, W.rng:NextNumber(0, 6), 0) }):Play()
					TweenService:Create(leaf, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 2.5), { Transparency = 1 }):Play()
					Debris:AddItem(leaf, 3.6)
				end
				biteThing(th, false)
			end
		end
	end
end

BUILD.LavaStone = function(W, h)
	local u = W.u
	for _ = 1, 3 do
		local pos = point(W, u * 2)
		local m = model(h.folder, "Volcano", pos)
		local layers = 5
		for k = 0, layers - 1 do
			local d = u * (2.8 - k * 0.45)
			cyl(m, CFrame.new(pos + V(0, u * (0.25 + k * 0.45), 0)), d, u * 0.5, (k % 2 == 0) and C(70, 55, 50) or C(90, 70, 60), Enum.Material.Basalt)
		end
		local top = pos + V(0, u * (0.25 + layers * 0.45), 0)
		local crater = cyl(m, CFrame.new(top - V(0, u * 0.2, 0)), u * 0.75, u * 0.12, C(255, 120, 20), Enum.Material.Neon)
		for k = 0, 3 do
			local a = k / 4 * math.pi * 2 + 0.4
			newPart({ Size = V(u * 0.12, u * 1.2, u * 0.08), CFrame = CFrame.new(top + V(math.cos(a) * u * 0.6, -u * 0.6, math.sin(a) * u * 0.6)) * CFrame.Angles(0, -a, math.rad(25) * ((k % 2 == 0) and 1 or -1)), Color = C(255, 140, 30), Material = Enum.Material.Neon, Parent = m })
		end
		local light = Instance.new("PointLight")
		light.Color = C(255, 120, 30)
		light.Range = u * 4
		light.Brightness = 1.5
		light.Parent = crater
		local smoke = emitter(crater, { Texture = Fx.TEX.smoke, LightEmission = 0, Rate = 0, Lifetime = NumberRange.new(3, 4), Speed = NumberRange.new(u * 1.2, u * 2), SpreadAngle = Vector2.new(20, 20), Size = NumberSequence.new(u * 0.8, u * 2.6), Transparency = NumberSequence.new(0.2, 1), Color = ColorSequence.new(C(80, 75, 75)), EmissionDirection = Enum.NormalId.Right })
		emitter(crater, { Texture = Fx.TEX.fire, Rate = 3, Lifetime = NumberRange.new(0.5, 0.9), Speed = NumberRange.new(u * 0.5, u), Size = NumberSequence.new(u * 0.3, 0), Color = ColorSequence.new(C(255, 200, 60), C(255, 80, 20)), EmissionDirection = Enum.NormalId.Right })
		local steam = emitter(crater, { Texture = Fx.TEX.smoke, LightEmission = 0.3, Rate = 0, Lifetime = NumberRange.new(1.5, 2.5), Speed = NumberRange.new(u, u * 2), SpreadAngle = Vector2.new(60, 60), Size = NumberSequence.new(u, u * 3), Transparency = NumberSequence.new(0.1, 1), Color = ColorSequence.new(C(240, 245, 255)), EmissionDirection = Enum.NormalId.Right })
		local th: Thing = { model = m, pos = pos, alive = true, kind = "volcano" }
		th.steam = function(_self: Thing)
			steam:Emit(30)
		end
		grow(m, 1.6)
		table.insert(h.things, th)
		table.insert(W.volcanoes, th)
		task.delay(2, function()
			smoke:Emit(25)
		end)
		h.data[th] = smoke
	end
	h.data.timer = 0
	h.update = function(self, dt)
		self.data.timer += dt
		if self.data.timer >= 60 then
			self.data.timer = 0
			for _, th in self.things do
				local s = self.data[th] :: ParticleEmitter
				s:Emit(40)
			end
		end
	end
end

BUILD.BlueCrystal = function(W, h)
	local u = W.u
	local shards = {}
	for _ = 1, 10 do
		local pos = point(W, u * 0.5)
		local m = model(h.folder, "Crystal", pos)
		for k = 1, 3 do
			local len = u * W.rng:NextNumber(0.7, 1.5)
			local tilt = CFrame.Angles(W.rng:NextNumber(-0.4, 0.4), W.rng:NextNumber(0, 6), W.rng:NextNumber(-0.4, 0.4))
			local p = newPart({ Size = V(u * 0.32, len, u * 0.32), CFrame = CFrame.new(pos) * tilt * CFrame.new(0, len / 2, 0) * CFrame.Angles(0, math.pi / 4, 0), Color = (k == 1) and C(170, 230, 255) or C(70, 150, 255), Material = (k == 1) and Enum.Material.Neon or Enum.Material.Glass, Transparency = (k == 1) and 0 or 0.1, Parent = m })
			if k == 1 then
				table.insert(shards, p)
				emitter(p, { Rate = 2, Lifetime = NumberRange.new(0.5, 1), Speed = NumberRange.new(0, 0.3), Size = NumberSequence.new(u * 0.35, 0), Color = ColorSequence.new(C(255, 255, 255), C(170, 230, 255)) })
			end
		end
		grow(m, 0.6 + W.rng:NextNumber() * 0.8)
	end
	h.update = function(_self, _dt, t)
		for i, p in shards do
			p.Transparency = 0.15 + math.sin(t * 3 + i * 1.7) * 0.15
		end
	end
end

local function wanderTarget(W: World, mm: Mini, range: number)
	local p = mm.pos + V(W.rng:NextNumber(-1, 1) * range, 0, W.rng:NextNumber(-1, 1) * range)
	mm.target = clampInside(W, p, W.u)
end

BUILD.Giraffe = function(W, h)
	local u = W.u
	local list = {}
	for _ = 1, 5 do
		local mm = mini(W, h.folder, "Giraffe", u * 2.1)
		table.insert(list, mm)
		table.insert(W.giraffes, mm)
	end
	h.data.list = list
	h.update = function(_self, dt, t)
		for _, mm in list do
			if mm.hidden then
				continue
			end
			mm.timer -= dt
			local speed = u * 0.9
			if mm.state == "flee" then
				speed = u * 2.2
			end
			local arrived = stepMini(W, mm, dt, t, speed)
			if mm.state == "eat" then
				if mm.timer <= 0 then
					mm.state = "idle"
					mm.timer = W.rng:NextNumber(1, 3)
				end
			elseif arrived or (mm.target == nil and mm.timer <= 0) then
				if mm.state == "toTree" and mm.data.tree then
					local tree = mm.data.tree :: Thing
					mm.yaw = math.atan2(-(tree.pos.X - mm.pos.X), -(tree.pos.Z - mm.pos.Z))
					mm.state = "eat"
					mm.timer = 2.5
					if tree.alive and tree.bite then
						tree.bite(tree)
					end
					mm.data.tree = nil
				else
					mm.state = "walk"
					mm.timer = W.rng:NextNumber(1, 4)
					local trees = {}
					for _, tr in W.trees do
						if tr.alive then
							table.insert(trees, tr)
						end
					end
					if #trees > 0 and W.rng:NextNumber() < 0.6 then
						local tree = trees[W.rng:NextInteger(1, #trees)]
						local dir = V(mm.pos.X - tree.pos.X, 0, mm.pos.Z - tree.pos.Z)
						if dir.Magnitude < 0.01 then
							dir = V(1, 0, 0)
						end
						mm.target = clampInside(W, tree.pos + dir.Unit * u * 1.1, u)
						mm.data.tree = tree
						mm.state = "toTree"
					else
						wanderTarget(W, mm, u * 4)
					end
				end
			end
		end
	end
end

BUILD.SolarioLeonario = function(W, h)
	local u = W.u
	local lion = mini(W, h.folder, "SolarioLeonario", u * 1.7)
	lion.state = "rest"
	lion.timer = 4
	h.update = function(_self, dt, t)
		lion.timer -= dt
		if lion.state == "hunt" then
			local prey = lion.data.prey :: Mini?
			if not prey or prey.hidden or not prey.model.Parent then
				lion.state = "rest"
				lion.timer = 5
				lion.target = nil
			else
				prey.state = "flee"
				local away = V(prey.pos.X - lion.pos.X, 0, prey.pos.Z - lion.pos.Z)
				if away.Magnitude > 0.01 then
					prey.target = clampInside(W, prey.pos + away.Unit * u * 3, u)
				end
				lion.target = prey.pos
				stepMini(W, lion, dt, t, u * 2.8)
				if (prey.pos - lion.pos).Magnitude < u * 0.9 then
					prey.state = "idle"
					prey.target = nil
					hideMini(W, prey, 4)
					lion.state = "rest"
					lion.timer = W.rng:NextNumber(6, 10)
					lion.target = nil
				elseif lion.timer < -8 then
					prey.state = "idle"
					lion.state = "rest"
					lion.timer = 5
				end
				return
			end
		end
		local arrived = stepMini(W, lion, dt, t, u * 0.9)
		if lion.timer <= 0 then
			local prey = {}
			for _, g in W.giraffes do
				if not g.hidden then
					table.insert(prey, g)
				end
			end
			if #prey > 0 and W.rng:NextNumber() < 0.5 then
				lion.state = "hunt"
				lion.data.prey = prey[W.rng:NextInteger(1, #prey)]
				lion.timer = 0
			elseif lion.state == "rest" then
				lion.state = "walk"
				lion.timer = W.rng:NextNumber(4, 7)
				wanderTarget(W, lion, u * 5)
			else
				lion.state = "rest"
				lion.timer = W.rng:NextNumber(5, 9)
				lion.target = nil
			end
		elseif arrived and lion.state == "walk" then
			wanderTarget(W, lion, u * 5)
		end
	end
end

BUILD.DrippoBloxino = function(W, h)
	local u = W.u
	local guy = mini(W, h.folder, "DrippoBloxino", u * 1.5)
	local sites = {}
	for _ = 1, 3 do
		table.insert(sites, point(W, u * 1.5))
	end
	h.data.built = 0
	guy.state = "toSite"
	guy.target = sites[1] + V(u * 1.2, 0, 0)
	local cols = { C(90, 140, 230), C(240, 240, 245), C(250, 200, 90), C(220, 90, 90), C(120, 200, 160) }
	local function build(pos: Vector3)
		local m = model(h.folder, "Building", pos)
		local floors = W.rng:NextInteger(3, 6)
		local col = cols[W.rng:NextInteger(1, #cols)]
		local w = u * W.rng:NextNumber(0.9, 1.3)
		for f = 0, floors - 1 do
			newPart({ Size = V(w, u * 0.5, w), CFrame = CFrame.new(pos + V(0, u * (0.25 + f * 0.5), 0)), Color = col, Parent = m })
			for _, side in { -1, 1 } do
				newPart({ Size = V(w * 0.7, u * 0.22, 0.05), CFrame = CFrame.new(pos + V(0, u * (0.27 + f * 0.5), side * (w / 2 + 0.02))), Color = C(150, 220, 255), Material = Enum.Material.Neon, Transparency = 0.2, Parent = m })
			end
		end
		newPart({ Size = V(w * 1.1, u * 0.12, w * 1.1), CFrame = CFrame.new(pos + V(0, u * (floors * 0.5 + 0.06), 0)), Color = C(60, 60, 70), Parent = m })
		local th: Thing = { model = m, pos = pos, alive = true, kind = "building" }
		th.bite = function(self: Thing)
			biteThing(self, true)
		end
		Fx.scaleModel(m, 0.03, 1, 4)
		table.insert(h.things, th)
		table.insert(W.buildings, th)
	end
	h.update = function(_self, dt, t)
		guy.timer -= dt
		local arrived = stepMini(W, guy, dt, t, u * 0.9)
		if guy.state == "toSite" and arrived then
			h.data.built += 1
			build(sites[h.data.built])
			guy.state = "building"
			guy.timer = 4.5
			guy.yaw = math.atan2(1, 0)
		elseif guy.state == "building" and guy.timer <= 0 then
			if h.data.built < #sites then
				guy.state = "toSite"
				guy.target = sites[h.data.built + 1] + V(u * 1.2, 0, 0)
			else
				guy.state = "walk"
			end
		elseif guy.state == "walk" and (arrived or guy.target == nil) and guy.timer <= 0 then
			guy.timer = W.rng:NextNumber(2, 5)
			wanderTarget(W, guy, u * 4)
		end
	end
end

BUILD.ZombinoRotolino = function(W, h)
	local u = W.u
	local z = mini(W, h.folder, "ZombinoRotolino", u * 1.6)
	z.timer = 4
	h.update = function(_self, dt, t)
		z.timer -= dt
		local arrived = stepMini(W, z, dt, t, u * 0.7)
		local victim = z.data.victim :: Thing?
		if victim and arrived then
			if victim.alive and victim.bite then
				Fx.burst(victim.pos + V(0, u, 0), ColorSequence.new(C(140, 255, 60), C(60, 120, 30)), 20, 6, 0.4)
				if victim.kind == "tree" then
					biteThing(victim, true)
				else
					victim.bite(victim)
				end
			end
			z.data.victim = nil
			z.timer = W.rng:NextNumber(3, 6)
		elseif z.timer <= 0 and z.target == nil then
			local options = {}
			for _, list in { W.trees, W.flowers, W.buildings } do
				for _, th in list do
					if th.alive then
						table.insert(options, th)
					end
				end
			end
			if #options > 0 and W.rng:NextNumber() < 0.7 then
				local best, bestD = nil, math.huge
				for _, th in options do
					local d = (th.pos - z.pos).Magnitude + W.rng:NextNumber(0, u * 3)
					if d < bestD then
						best, bestD = th, d
					end
				end
				local v = best :: Thing
				local dir = V(z.pos.X - v.pos.X, 0, z.pos.Z - v.pos.Z)
				if dir.Magnitude < 0.01 then
					dir = V(1, 0, 0)
				end
				z.target = clampInside(W, v.pos + dir.Unit * u * 0.9, u * 0.5)
				z.data.victim = v
			else
				wanderTarget(W, z, u * 4)
				z.timer = W.rng:NextNumber(3, 5)
			end
		end
	end
end

BUILD.FrostyFangolini = function(W, h)
	local u = W.u
	local tiger = mini(W, h.folder, "FrostyFangolini", u * 1.6)
	tiger.data.run = false
	tiger.data.cool = 0
	h.update = function(_self, dt, t)
		tiger.timer -= dt
		tiger.data.cool -= dt
		local speed = tiger.data.run and u * 3.2 or u * 1.0
		local arrived = stepMini(W, tiger, dt, t, speed)
		if arrived or (tiger.target == nil and tiger.timer <= 0) then
			tiger.data.run = W.rng:NextNumber() < 0.45
			tiger.timer = W.rng:NextNumber(0.5, 2.5)
			wanderTarget(W, tiger, tiger.data.run and u * 8 or u * 4)
		end
		if tiger.data.cool <= 0 then
			for _, v in W.volcanoes do
				if (v.pos - tiger.pos).Magnitude < u * 2.6 and v.steam then
					v.steam(v)
					tiger.data.cool = 6
					break
				end
			end
		end
	end
end

BUILD.WitchinaMagichina = function(W, h)
	local u = W.u
	local spot = point(W, u * 2)
	local witch = mini(W, h.folder, "WitchinaMagichina", u * 1.6, spot)
	local potPos = spot + V(0, 0, -u * 1.1)
	local pot = model(h.folder, "Cauldron", potPos)
	newPart({ Shape = Enum.PartType.Ball, Size = V(u * 1.1, u * 1.1, u * 1.1), CFrame = CFrame.new(potPos + V(0, u * 0.45, 0)), Color = C(30, 28, 35), Material = Enum.Material.Metal, Parent = pot })
	local brew = cyl(pot, CFrame.new(potPos + V(0, u * 0.88, 0)), u * 0.85, u * 0.08, C(190, 80, 255), Enum.Material.Neon)
	emitter(brew, { Rate = 6, Lifetime = NumberRange.new(0.8, 1.4), Speed = NumberRange.new(u * 0.3, u * 0.8), Size = NumberSequence.new(u * 0.25, 0), Color = ColorSequence.new(C(220, 140, 255), C(140, 60, 255)), EmissionDirection = Enum.NormalId.Right })
	local light = Instance.new("PointLight")
	light.Color = C(190, 80, 255)
	light.Range = u * 4
	light.Parent = brew
	witch.yaw = math.atan2(-(potPos.X - spot.X), -(potPos.Z - spot.Z))
	witch.timer = 6
	h.update = function(_self, dt, t)
		witch.timer -= dt
		stepMini(W, witch, dt, t, 0)
		brew.Size = V(u * 0.08, u * (0.85 + math.sin(t * 4) * 0.04), u * (0.85 + math.sin(t * 4) * 0.04))
		if witch.timer <= 0 then
			witch.timer = W.rng:NextNumber(8, 12)
			-- throw a potion
			local from = witch.pos + V(0, u * 1.5, 0)
			local to = point(W, u)
			local ball = Fx.ball(from, u * 0.35, C(200, 90, 255), h.folder)
			local t0 = os.clock()
			local conn
			conn = game:GetService("RunService").RenderStepped:Connect(function()
				local k = math.clamp((os.clock() - t0) / 1.0, 0, 1)
				local p = from:Lerp(to, k) + V(0, math.sin(k * math.pi) * u * 3, 0)
				ball.CFrame = CFrame.new(p)
				if k >= 1 then
					conn:Disconnect()
					ball:Destroy()
					Fx.burst(to + V(0, 0.3, 0), ColorSequence.new(C(220, 140, 255), C(140, 60, 255)), 40, 8, 0.6)
					for _, list in { W.trees, W.flowers } do
						for _, th in list do
							if (th.pos - to).Magnitude < u * 3.5 and th.glow then
								th.glow(th)
							end
						end
					end
				end
			end)
		end
	end
end

BUILD.CosmicMeteor = function(W, h)
	local u = W.u
	h.data.timer = 1
	h.update = function(self, dt)
		self.data.timer -= dt
		if self.data.timer > 0 then
			return
		end
		self.data.timer = 5
		local land = point(W, u)
		local from = V(W.center.X + W.rng:NextNumber(-1, 1) * W.R * 0.3, W.center.Y + W.R * 0.62, W.center.Z + W.rng:NextNumber(-1, 1) * W.R * 0.3)
		local rock = newPart({ Shape = Enum.PartType.Ball, Size = V(u * 0.7, u * 0.7, u * 0.7), CFrame = CFrame.new(from), Color = C(80, 70, 90), Material = Enum.Material.Slate, Parent = h.folder })
		local fire = Instance.new("Fire")
		fire.Size = u * 1.2
		fire.Heat = 4
		fire.Color = C(255, 130, 40)
		fire.SecondaryColor = C(170, 70, 255)
		fire.Parent = rock
		local a0 = Instance.new("Attachment")
		a0.Position = V(0, u * 0.3, 0)
		a0.Parent = rock
		local a1 = Instance.new("Attachment")
		a1.Position = V(0, -u * 0.3, 0)
		a1.Parent = rock
		local trail = Instance.new("Trail")
		trail.Attachment0 = a0
		trail.Attachment1 = a1
		trail.Lifetime = 0.5
		trail.LightEmission = 1
		trail.Color = ColorSequence.new(C(255, 210, 80), C(170, 70, 255))
		trail.Transparency = NumberSequence.new(0, 1)
		trail.Parent = rock
		local meteor = { part = rock, alive = true, pos = from }
		table.insert(W.meteors, meteor)
		local t0 = os.clock()
		local conn
		conn = game:GetService("RunService").RenderStepped:Connect(function()
			if not rock.Parent or not meteor.alive then
				conn:Disconnect()
				removeFrom(W.meteors, meteor)
				return
			end
			local k = math.clamp((os.clock() - t0) / 1.3, 0, 1)
			meteor.pos = from:Lerp(land + V(0, u * 0.35, 0), k * k)
			rock.CFrame = CFrame.new(meteor.pos) * CFrame.Angles(k * 8, k * 5, 0)
			if k >= 1 then
				conn:Disconnect()
				meteor.alive = false
				removeFrom(W.meteors, meteor)
				Fx.burst(land + V(0, 0.3, 0), ColorSequence.new(C(255, 210, 80), C(170, 70, 255)), 35, 7, 0.6)
				local ring = cyl(Fx.folder, CFrame.new(land + V(0, 0.05, 0)), u * 0.5, 0.05, C(255, 170, 60), Enum.Material.Neon)
				TweenService:Create(ring, TweenInfo.new(0.8), { Size = V(0.05, u * 3, u * 3), Transparency = 1 }):Play()
				Debris:AddItem(ring, 0.9)
				fire.Enabled = false
				TweenService:Create(rock, TweenInfo.new(1.5), { Transparency = 1 }):Play()
				Debris:AddItem(rock, 1.6)
			end
		end)
	end
end

BUILD.GalaxyDragon = function(W, h)
	local u = W.u
	local dragon = mini(W, h.folder, "GalaxyDragon", u * 2.2)
	local d = { mini = dragon, angle = W.rng:NextNumber(0, 6), cool = 0 }
	table.insert(W.dragons, d)
	h.data.dragon = d
	h.update = function(_self, dt, t)
		d.cool -= dt
		d.angle += dt * 0.35
		local r = W.R * 0.4
		local pos = V(W.center.X + math.cos(d.angle) * r, W.groundY, W.center.Z + math.sin(d.angle) * r)
		local lift = W.R * 0.35 + math.sin(t * 1.3) * u * 0.3
		local dir = V(-math.sin(d.angle), 0, math.cos(d.angle))
		local yaw = math.atan2(-dir.X, -dir.Z)
		-- breathe fire at a falling meteor and turn it into fireworks
		if d.cool <= 0 then
			for _, meteor in W.meteors do
				if meteor.alive and W.rng:NextNumber() < 0.7 then
					d.cool = 2.5
					local to = meteor.pos - (pos + V(0, lift, 0))
					yaw = math.atan2(-to.X, -to.Z)
					local breath = dragon.model:FindFirstChild("Breath", true) :: ParticleEmitter?
					if breath then
						breath:Emit(40)
					end
					local target = meteor
					task.delay(0.35, function()
						if target.alive then
							target.alive = false
							local at = target.pos
							target.part:Destroy()
							for _, col in { C(255, 90, 220), C(90, 160, 255), C(255, 220, 80), C(120, 255, 160) } do
								Fx.burst(at, ColorSequence.new(col, C(255, 255, 255)), 25, 12, 0.6)
							end
							local flash = Fx.ball(at, u, C(255, 255, 255))
							TweenService:Create(flash, TweenInfo.new(0.4), { Size = Vector3.one * u * 4, Transparency = 1 }):Play()
							Debris:AddItem(flash, 0.5)
						end
					end)
					break
				end
			end
		end
		dragon.pos = pos
		dragon.yaw = lerpAngle(dragon.yaw, yaw, math.min(dt * 4, 1))
		Characters.place(dragon.model, pos + V(0, lift, 0), dragon.yaw)
		Gait.update(dragon.model, dt, 5, t)
	end
end

--------------------------------------------------------------------------------------------
-- managing each base's world

local function destroyHandle(W: World, h: Handle)
	for _, th in h.things do
		removeFrom(W.trees, th)
		removeFrom(W.flowers, th)
		removeFrom(W.buildings, th)
		removeFrom(W.volcanoes, th)
	end
	if h.data.list then
		for _, g in h.data.list do
			removeFrom(W.giraffes, g)
		end
	end
	if h.data.dragon then
		removeFrom(W.dragons, h.data.dragon)
	end
	if h.data.lawn then
		local still = false
		for _, other in W.items do
			if other ~= h and other.id == "GrassAndFlowers" then
				still = true
				other.data.lawn = h.data.lawn
			end
		end
		if not still then
			(h.data.lawn :: Instance):Destroy()
			W.lawn = nil
		end
	end
	Fx.burst(W.center, ItemData.beamSequence(h.id), 30, 8, 0.8)
	h.folder:Destroy()
end

local function addItem(W: World, i: number, id: string)
	local folder = Instance.new("Folder")
	folder.Name = id .. "_" .. i
	folder.Parent = W.folder
	local h: Handle = { id = id, folder = folder, things = {}, update = nil, data = {} }
	W.items[i] = h
	local b = BUILD[id]
	if b then
		local ok, err = pcall(b, W, h)
		if not ok then
			warn("[SphereWorld] " .. id .. ": " .. tostring(err))
		end
	end
end

local function sync(W: World, plot: Model, animate: boolean)
	local tanks = plot:FindFirstChild("Tanks")
	if not tanks then
		return
	end
	local want: { [number]: string } = {}
	for _, tank in tanks:GetChildren() do
		local i = tank:GetAttribute("Index") :: number?
		if i and tank:GetAttribute("Active") and tank:GetAttribute("ItemId") ~= "" then
			want[i] = tank:GetAttribute("ItemId") :: string
		end
	end
	for i, h in W.items do
		if want[i] ~= h.id then
			W.items[i] = nil
			destroyHandle(W, h)
		end
	end
	for i, id in want do
		if not W.items[i] then
			local tank = tanks:FindFirstChild("Tank" .. i)
			local cap = tank and tank:FindFirstChild("Cap")
			local out = cap and cap:FindFirstChild("BeamOut") :: Attachment?
			if animate and out then
				W.items[i] = { id = id, folder = Instance.new("Folder"), things = {}, data = { pending = true } }
				Fx.beam(out, W.center, ItemData.beamSequence(id), function()
					if W.items[i] and W.items[i].data.pending and W.items[i].id == id then
						W.items[i] = nil
						addItem(W, i, id)
					end
				end)
			else
				addItem(W, i, id)
			end
		end
	end
end

local function makeWorld(plot: Model): World?
	local center = plot:GetAttribute("SphereCenter") :: Vector3?
	local R = plot:GetAttribute("SphereR") :: number?
	local groundY = plot:GetAttribute("GroundY") :: number?
	if not center or not R or not groundY then
		return nil
	end
	local folder = Instance.new("Folder")
	folder.Name = plot.Name
	folder.Parent = Fx.folder
	return {
		plot = plot,
		folder = folder,
		center = center,
		R = R,
		u = R / 9,
		groundY = groundY,
		items = {},
		trees = {},
		flowers = {},
		buildings = {},
		volcanoes = {},
		giraffes = {},
		dragons = {},
		meteors = {},
		lawn = nil,
		rng = Random.new(),
	}
end

function SphereWorld.attach(plot: Model)
	local function rebuild()
		local old = worlds[plot]
		if old then
			old.folder:Destroy()
			worlds[plot] = nil
		end
		local W = makeWorld(plot)
		if W then
			worlds[plot] = W
			sync(W, plot, false)
		end
	end
	local function watchTank(tank: Instance)
		tank:GetAttributeChangedSignal("Active"):Connect(function()
			local W = worlds[plot]
			if W then
				sync(W, plot, true)
			end
		end)
		tank:GetAttributeChangedSignal("ItemId"):Connect(function()
			local W = worlds[plot]
			if W then
				sync(W, plot, true)
			end
		end)
	end
	local tanks = plot:WaitForChild("Tanks")
	for _, tank in tanks:GetChildren() do
		watchTank(tank)
	end
	tanks.ChildAdded:Connect(watchTank)
	plot:GetAttributeChangedSignal("SphereR"):Connect(function()
		task.defer(rebuild)
	end)
	rebuild()
end

function SphereWorld.update(dt: number, t: number)
	for _, W in worlds do
		for _, h in W.items do
			if h.update then
				local ok, err = pcall(h.update, h, dt, t)
				if not ok then
					warn("[SphereWorld] " .. h.id .. ": " .. tostring(err))
					h.update = nil
				end
			end
		end
	end
end

function SphereWorld.worldOf(plot: Model): World?
	return worlds[plot]
end

-- For the first-time intro: a tiny demo world in a sphere, cleaned up afterwards.
function SphereWorld.demo(plot: Model, id: string): () -> ()
	local W = makeWorld(plot)
	if not W then
		return function() end
	end
	local Wd = W :: World
	addItem(Wd, 99, id)
	local conn = game:GetService("RunService").RenderStepped:Connect(function(dt)
		local h = Wd.items[99]
		if h and h.update then
			pcall(h.update, h, dt, os.clock())
		end
	end)
	return function()
		conn:Disconnect()
		Wd.folder:Destroy()
	end
end

return SphereWorld
