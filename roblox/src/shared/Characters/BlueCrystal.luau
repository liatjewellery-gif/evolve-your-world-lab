-- Blue Crystal (Epic): the millionaire. Faceted glowing blue crystal body and spiky crystal
-- head, gold crown with blue gems, black "$" sunglasses in gold frames, big smile,
-- white fur collar, royal blue cape with a diamond emblem, gold "$" chain,
-- gold bracelets and white-blue-gold "$" sneakers.
local Rig = require(script.Parent.Parent.Rig)
local C, V = Color3.fromRGB, Vector3.new

local CRY = C(80, 165, 255)
local CRY_L = C(165, 225, 255)
local CRY_D = C(35, 95, 225)
local GOLD = C(245, 190, 45)
local WHITE = C(250, 250, 255)
local NAVY = C(25, 35, 140)
local NEON = Enum.Material.Neon
local GLASS = Enum.Material.Glass
local METAL = Enum.Material.Metal

local function dollar(part: BasePart, color: Color3)
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Front
	sg.LightInfluence = 0
	sg.PixelsPerStud = 60
	sg.Parent = part
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = "$"
	t.TextScaled = true
	t.Font = Enum.Font.FredokaOne
	t.TextColor3 = color
	t.Parent = sg
end

return function(): Model
	local r = Rig.new("BlueCrystal", 2.1)
	r:symJoint("LegL", V(-0.55, 1.75, 0))
	r:symJoint("ArmL", V(-1.2, 3.5, 0))
	r:joint("Head", V(0, 3.9, 0))
	r:joint("Cape", V(0, 3.7, 0.85))

	-- sneakers
	r:sym({ sz = V(1.0, 0.72, 1.42), p = V(-0.55, 0.4, -0.15), c = WHITE, j = "LegL" })
	r:sym({ sz = V(1.05, 0.26, 1.5), p = V(-0.55, 0.14, -0.15), c = GOLD, m = METAL, j = "LegL" })
	r:sym({ sz = V(0.85, 0.3, 0.9), p = V(-0.55, 0.62, 0.15), c = NAVY, j = "LegL" })
	local tongue = r:add({ s = "box", sz = V(0.36, 0.36, 0.06), p = V(-0.55, 0.62, -0.74), c = GOLD, j = "LegL" })
	dollar(tongue, WHITE)
	local tongue2 = r:add({ s = "box", sz = V(0.36, 0.36, 0.06), p = V(0.55, 0.62, -0.74), c = GOLD, j = "LegR" })
	dollar(tongue2, WHITE)
	r:sym({ sz = V(0.6, 1.25, 0.6), p = V(-0.55, 1.2, 0), c = CRY, m = GLASS, t = 0.05, j = "LegL" })

	-- faceted crystal body with a glowing core
	r:add({ sz = V(1.5, 1.6, 1.1), p = V(0, 2.85, 0), c = CRY_L, m = NEON, t = 0.25 })
	r:add({ sz = V(2.0, 2.1, 1.6), p = V(0, 2.85, 0), c = CRY, m = GLASS, t = 0.12 })
	local rng = Random.new(11)
	for i = 1, 14 do
		local a = rng:NextNumber(0, math.pi * 2)
		local y = rng:NextNumber(2.0, 3.7)
		r:add({ s = "box", sz = V(0.75, 0.75, 0.4), p = V(math.sin(a) * 0.9, y, math.cos(a) * 0.68), r = V(rng:NextNumber(0, 90), math.deg(a), 45), c = (i % 3 == 0) and CRY_D or ((i % 3 == 1) and CRY_L or CRY), m = GLASS, t = 0.1 })
	end

	-- gold "$" chain
	for i = -5, 5 do
		local x = i * 0.15
		r:add({ s = "ball", sz = V(0.14, 0, 0), p = V(x, 3.45 + x * x * 0.55, -0.82 + math.abs(x) * 0.1), c = GOLD, m = METAL })
	end
	local pendant = r:add({ s = "box", sz = V(0.75, 0.95, 0.16), p = V(0, 2.95, -0.98), c = GOLD, m = METAL, refl = 0.2 })
	dollar(pendant, WHITE)

	-- white fur collar
	r:ring(12, function(i, a)
		return { sz = V(0.7, 0.55, 0.6), p = V(math.sin(a) * 1.05, 3.75, math.cos(a) * 0.95), c = WHITE }
	end)

	-- royal blue cape
	r:add({ s = "box", sz = V(2.6, 2.9, 0.15), p = V(0, 2.2, 1.2), r = V(8, 0, 0), c = NAVY, j = "Cape" })
	r:add({ s = "box", sz = V(2.66, 0.2, 0.2), p = V(0, 0.8, 1.4), r = V(8, 0, 0), c = GOLD, m = METAL, j = "Cape" })
	r:sym({ s = "box", sz = V(0.16, 2.8, 0.2), p = V(-1.25, 2.2, 1.23), r = V(8, 0, 0), c = GOLD, m = METAL, j = "Cape" })
	r:add({ s = "box", sz = V(0.62, 0.62, 0.1), p = V(0, 2.35, 1.34), r = V(8, 0, 45), c = CRY_L, m = NEON, j = "Cape" })
	r:sym({ sz = V(0.25, 0.7, 0.08), p = V(-0.6, 2.3, 1.34), r = V(8, 0, -25), c = GOLD, m = METAL, j = "Cape" })

	-- arms
	r:sym({ sz = V(0.72, 1.3, 0.72), p = V(-1.35, 2.85, 0), r = V(0, 0, -8), c = CRY, m = GLASS, t = 0.08, j = "ArmL" })
	r:sym({ s = "cyl", sz = V(0.8, 0.22, 0.8), p = V(-1.42, 2.3, 0), c = GOLD, m = METAL, j = "ArmL" })
	r:sym({ sz = V(0.82, 0.75, 0.82), p = V(-1.45, 1.9, 0), c = CRY_L, m = GLASS, t = 0.08, j = "ArmL" })

	-- spiky crystal head
	r:add({ sz = V(1.4, 1.3, 1.2), p = V(0, 4.9, 0), c = CRY_L, m = NEON, t = 0.3, j = "Head" })
	r:add({ sz = V(2.0, 1.9, 1.8), p = V(0, 4.9, 0), c = CRY, m = GLASS, t = 0.1, j = "Head" })
	for i = 1, 11 do
		local a = math.rad(55 + (i - 1) * 25)
		r:add({ s = "box", sz = V(0.42, 1.35, 0.42), p = V(math.sin(a) * 1.0, 5.1 + (i % 2) * 0.2, math.cos(a) * 0.9), r = V(42, math.deg(a), 45), c = (i % 2 == 0) and CRY_L or CRY, m = GLASS, t = 0.1, j = "Head" })
	end
	for _, d in { V(-0.45, 5.85, 0.1), V(0.45, 5.85, 0.1), V(0, 5.95, 0.45) } do
		r:add({ s = "box", sz = V(0.35, 0.9, 0.35), p = d, r = V(10, 45, d.X * 30), c = CRY_L, m = GLASS, t = 0.1, j = "Head" })
	end
	-- smile
	r:add({ sz = V(0.95, 0.55, 0.16), p = V(0, 4.4, -0.88), c = C(40, 15, 40), j = "Head" })
	r:add({ sz = V(0.5, 0.28, 0.12), p = V(0, 4.25, -0.93), c = C(255, 120, 150), j = "Head" })
	r:add({ s = "box", sz = V(0.6, 0.1, 0.05), p = V(0, 4.6, -0.95), c = WHITE, j = "Head" })
	-- "$" sunglasses
	for _, x in { -0.45, 0.45 } do
		r:add({ sz = V(0.85, 0.65, 0.12), p = V(x, 4.95, -0.9), c = GOLD, m = METAL, j = "Head" })
		local lens = r:add({ s = "box", sz = V(0.62, 0.48, 0.06), p = V(x, 4.95, -0.98), c = C(10, 10, 15), j = "Head" })
		dollar(lens, C(255, 205, 50))
	end
	r:add({ s = "box", sz = V(0.3, 0.08, 0.08), p = V(0, 5.05, -0.95), c = GOLD, m = METAL, j = "Head" })
	r:sym({ s = "box", sz = V(0.08, 0.08, 0.9), p = V(-0.88, 5.0, -0.5), c = GOLD, m = METAL, j = "Head" })
	-- gold crown with blue gems
	r:add({ s = "cyl", sz = V(1.5, 0.42, 1.5), p = V(0, 6.05, 0), c = GOLD, m = METAL, refl = 0.15, j = "Head" })
	r:ring(6, function(i, a)
		return { sz = V(0.28, 0.75, 0.28), p = V(math.sin(a) * 0.72, 6.5, math.cos(a) * 0.72), c = GOLD, m = METAL, j = "Head" }
	end)
	r:ring(6, function(i, a)
		return { s = "box", sz = V(0.2, 0.2, 0.08), p = V(math.sin(a) * 0.77, 6.05, math.cos(a) * 0.77), r = V(0, math.deg(a), 45), c = CRY_L, m = NEON, j = "Head" }
	end)

	r:emitter("Body", { Rate = 6, Lifetime = NumberRange.new(0.8, 1.4), Speed = NumberRange.new(0.5, 1.5), SpreadAngle = Vector2.new(180, 180), Size = NumberSequence.new(0.3, 0), Color = ColorSequence.new(CRY_L, WHITE) })
	r:light("Body", CRY, 1.2, 10)
	return r:finish("BlueCrystal", "strut")
end
