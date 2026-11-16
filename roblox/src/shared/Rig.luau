--[[
	Rig: a small toolkit for building characters out of smooth parts.

	Every character is built standing on the ground (y = 0), facing -Z (the front).
	Parts are attached to named joints ("Body", "Head", "LegL", "ArmR", "Tail", "Cape", ...).
	The Gait module moves those joints to make each character walk in its own way.

	Shapes:
	  "ell"  smooth ellipsoid (a sphere you can stretch) - the main shape, keeps things round
	  "ball" perfect sphere
	  "box"  block
	  "cyl"  vertical cylinder: sz = (diameter X, height, diameter Z)
	  "wedge" wedge part
]]

local Config = require(script.Parent.Config)

local Rig = {}
Rig.__index = Rig

local rad = math.rad

export type Spec = {
	s: string?, -- shape
	sz: Vector3, -- size
	p: Vector3, -- position (ground space)
	r: Vector3?, -- rotation in degrees (x, y, z)
	c: Color3?, -- colour
	m: Enum.Material?, -- material
	t: number?, -- transparency
	j: string?, -- joint name (default "Body")
	n: string?, -- part name
	refl: number?,
}

local function newPart(shape: string): BasePart
	local p: BasePart
	if shape == "wedge" then
		p = Instance.new("WedgePart")
	else
		p = Instance.new("Part")
	end
	p.Anchored = false
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Massless = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	return p
end

function Rig.new(name: string, hip: number)
	local self = setmetatable({}, Rig)
	local model = Instance.new("Model")
	model.Name = name
	local root = newPart("box")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2, 2, 1)
	root.Transparency = 1
	root.Massless = false
	root.CFrame = CFrame.new(0, hip, 0)
	root.Parent = model
	model.PrimaryPart = root
	self.model = model
	self.root = root
	self.hip = hip
	self.joints = {} :: { [string]: BasePart }
	self:joint("Body", Vector3.new(0, hip, 0))
	return self
end

-- A joint is an invisible pivot that the Gait module can rotate.
function Rig:joint(name: string, pos: Vector3, parent: string?): BasePart
	local parentPart: BasePart
	if name == "Body" then
		parentPart = self.root
	else
		parentPart = self.joints[parent or "Body"]
	end
	local p = newPart("box")
	p.Name = name
	p.Size = Vector3.new(0.2, 0.2, 0.2)
	p.Transparency = 1
	p.CFrame = CFrame.new(pos)
	p.Parent = self.model
	local m = Instance.new("Motor6D")
	m.Name = name
	m.Part0 = parentPart
	m.Part1 = p
	m.C0 = parentPart.CFrame:Inverse() * p.CFrame
	m.C1 = CFrame.identity
	m.Parent = parentPart
	self.joints[name] = p
	return p
end

function Rig:add(s: Spec): BasePart
	local shape = s.s or "ell"
	local p = newPart(shape)
	local cf = CFrame.new(s.p)
	if s.r then
		cf *= CFrame.fromOrientation(rad(s.r.X), rad(s.r.Y), rad(s.r.Z))
	end
	if shape == "ell" then
		p.Size = s.sz
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Sphere
		mesh.Parent = p
	elseif shape == "ball" then
		p.Shape = Enum.PartType.Ball
		p.Size = Vector3.new(s.sz.X, s.sz.X, s.sz.X)
	elseif shape == "cyl" then
		p.Shape = Enum.PartType.Cylinder
		p.Size = Vector3.new(s.sz.Y, s.sz.X, s.sz.Z)
		cf *= CFrame.Angles(0, 0, math.pi / 2)
	else
		p.Size = s.sz
	end
	p.Color = s.c or Color3.new(1, 1, 1)
	p.Material = s.m or Enum.Material.SmoothPlastic
	p.Transparency = s.t or 0
	if s.refl then
		p.Reflectance = s.refl
	end
	p.Name = s.n or "Part"
	p.CFrame = cf
	p.Parent = self.model
	local jp = self.joints[s.j or "Body"]
	local w = Instance.new("WeldConstraint")
	w.Part0 = jp
	w.Part1 = p
	w.Parent = p
	return p
end

local function mirrorSpec(s: Spec): Spec
	local m = table.clone(s)
	m.p = Vector3.new(-s.p.X, s.p.Y, s.p.Z)
	if s.r then
		m.r = Vector3.new(s.r.X, -s.r.Y, -s.r.Z)
	end
	if s.j then
		local j = s.j :: string
		if string.sub(j, -1) == "L" then
			m.j = string.sub(j, 1, -2) .. "R"
		elseif string.sub(j, -1) == "R" then
			m.j = string.sub(j, 1, -2) .. "L"
		end
	end
	return m
end

-- Adds the part and its mirror on the other side (left/right).
function Rig:sym(s: Spec): (BasePart, BasePart)
	return self:add(s), self:add(mirrorSpec(s))
end

-- Mirrors a joint too: "ArmL" at x=-1 also makes "ArmR" at x=+1.
function Rig:symJoint(name: string, pos: Vector3, parent: string?)
	self:joint(name, pos, parent)
	local other = string.sub(name, 1, -2) .. "R"
	local otherParent = parent
	if parent and string.sub(parent, -1) == "L" then
		otherParent = string.sub(parent, 1, -2) .. "R"
	end
	self:joint(other, Vector3.new(-pos.X, pos.Y, pos.Z), otherParent)
end

-- Ring of parts around a centre (petals, mane spikes, crown points...).
-- make(i, angle) returns a Spec.
function Rig:ring(count: number, make: (number, number) -> Spec)
	for i = 1, count do
		local a = (i - 1) / count * math.pi * 2
		self:add(make(i, a))
	end
end

-- Cartoon eye: white, coloured iris, black pupil, white shine.
-- pos is the centre of the eye surface, size the eye width.
function Rig:eye(pos: Vector3, size: number, iris: Color3, j: string?, opts: { [string]: any }?)
	local o = opts or {}
	local glow = o.glow
	local h = size * (o.tall or 1.15)
	if not o.noWhite then
		self:add({ sz = Vector3.new(size, h, size * 0.5), p = pos, c = Color3.new(1, 1, 1), j = j })
	end
	self:add({
		sz = Vector3.new(size * 0.72, h * 0.72, size * 0.4),
		p = pos + Vector3.new(0, -h * 0.04, -size * 0.12),
		c = iris,
		m = glow and Enum.Material.Neon or Enum.Material.SmoothPlastic,
		j = j,
	})
	if not o.noPupil then
		self:add({
			sz = Vector3.new(size * 0.36, h * 0.38, size * 0.3),
			p = pos + Vector3.new(0, -h * 0.04, -size * 0.2),
			c = Color3.fromRGB(15, 10, 10),
			j = j,
		})
	end
	self:add({
		s = "ball",
		sz = Vector3.new(size * 0.2, 0, 0),
		p = pos + Vector3.new(size * 0.14, h * 0.17, -size * 0.27),
		c = Color3.new(1, 1, 1),
		m = Enum.Material.Neon,
		j = j,
	})
end

function Rig:light(j: string, color: Color3, brightness: number, range: number)
	local l = Instance.new("PointLight")
	l.Color = color
	l.Brightness = brightness
	l.Range = range
	l.Shadows = false
	l.Parent = self.joints[j]
end

-- Built-in particle textures work without uploading anything.
Rig.TEX = {
	sparkle = "rbxasset://textures/particles/sparkles_main.dds",
	smoke = "rbxasset://textures/particles/smoke_main.dds",
	fire = "rbxasset://textures/particles/fire_main.dds",
}

function Rig:emitter(j: string, props: { [string]: any }): ParticleEmitter
	local pe = Instance.new("ParticleEmitter")
	pe.LightEmission = 1
	pe.Texture = Rig.TEX.sparkle
	for k, v in props do
		(pe :: any)[k] = v
	end
	pe.Parent = self.joints[j]
	return pe
end

function Rig:finish(id: string, gait: string, scale: number?): Model
	local model = self.model
	model:SetAttribute("ItemId", id)
	model:SetAttribute("Gait", gait)
	local k = scale or 1
	model:SetAttribute("Hip", self.hip * k)
	local hum = Instance.new("Humanoid")
	hum.WalkSpeed = Config.ItemWalkSpeed
	hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	hum.BreakJointsOnDeath = false
	hum.RequiresNeck = false
	hum.Parent = model
	if k ~= 1 then
		model:ScaleTo(k)
	end
	hum.HipHeight = (self.hip - 1) * k
	return model
end

return Rig
