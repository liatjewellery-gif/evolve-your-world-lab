-- Lava Stone (Super Rare): a little volcano king. Dark cracked rock body with glowing
-- lava cracks, lava dripping from the crater, a big smoke cloud on top, golden crown
-- with red gems, angry glowing eyes and a gold-tooth grin, white fur collar,
-- royal red cape with a flame emblem, gold chain, and red-gold sneakers.
local Rig = require(script.Parent.Parent.Rig)
local C, V = Color3.fromRGB, Vector3.new

local ROCK = C(48, 40, 42)
local ROCK2 = C(68, 56, 54)
local LAVA = C(255, 120, 20)
local LAVA2 = C(255, 190, 40)
local GOLD = C(240, 185, 45)
local RED = C(150, 18, 24)
local WHITE = C(250, 250, 245)
local NEON = Enum.Material.Neon
local METAL = Enum.Material.Metal
local BASALT = Enum.Material.Basalt

return function(): Model
	local r = Rig.new("LavaStone", 2.0)
	r:symJoint("LegL", V(-0.6, 1.6, 0))
	r:symJoint("ArmL", V(-1.25, 3.05, 0))
	r:joint("Head", V(0, 5.1, 0))
	r:joint("Cape", V(0, 3.05, 0.9))

	-- sneakers
	r:sym({ sz = V(1.02, 0.75, 1.45), p = V(-0.6, 0.42, -0.15), c = C(200, 30, 35), j = "LegL" })
	r:sym({ sz = V(1.08, 0.26, 1.52), p = V(-0.6, 0.14, -0.15), c = WHITE, j = "LegL" })
	r:sym({ sz = V(0.82, 0.42, 0.6), p = V(-0.6, 0.38, -0.72), c = WHITE, j = "LegL" })
	r:sym({ sz = V(0.2, 0.28, 0.9), p = V(-1.08, 0.45, -0.12), c = GOLD, m = METAL, j = "LegL" })
	r:sym({ s = "box", sz = V(0.5, 0.06, 0.08), p = V(-0.6, 0.78, -0.42), c = LAVA2, m = NEON, j = "LegL" })
	r:sym({ s = "box", sz = V(0.5, 0.06, 0.08), p = V(-0.6, 0.78, -0.22), c = LAVA2, m = NEON, j = "LegL" })
	r:sym({ sz = V(0.72, 0.95, 0.72), p = V(-0.6, 1.1, 0), c = ROCK, m = BASALT, j = "LegL" })

	-- the volcano body: stacked rock rings getting smaller
	local rings = { { 2.7, 0.8, 1.9 }, { 2.45, 0.75, 2.6 }, { 2.2, 0.75, 3.3 }, { 1.9, 0.7, 3.95 }, { 1.6, 0.6, 4.55 }, { 1.38, 0.45, 5.05 } }
	for k, ring in rings do
		r:add({ s = "cyl", sz = V(ring[1], ring[2], ring[1]), p = V(0, ring[3], 0), c = (k % 2 == 0) and ROCK2 or ROCK, m = BASALT })
	end
	-- glowing lava cracks all around
	local rng = Random.new(7)
	for i = 1, 22 do
		local a = rng:NextNumber(0, math.pi * 2)
		local y = rng:NextNumber(1.8, 5.0)
		local rad = 1.38 - (y - 1.8) * 0.2
		r:add({ s = "box", sz = V(0.07, rng:NextNumber(0.4, 0.9), 0.05), p = V(math.sin(a) * rad, y, math.cos(a) * rad), r = V(0, math.deg(a), rng:NextNumber(-35, 35)), c = (i % 3 == 0) and LAVA2 or LAVA, m = NEON })
	end
	-- crater with lava and drips
	r:add({ s = "cyl", sz = V(1.2, 0.16, 1.2), p = V(0, 5.3, 0), c = LAVA, m = NEON, j = "Head" })
	for i = 1, 8 do
		local a = (i / 8) * math.pi * 2
		r:add({ sz = V(0.24, 0.55 + (i % 3) * 0.2, 0.2), p = V(math.sin(a) * 0.68, 5.0 - (i % 3) * 0.1, math.cos(a) * 0.68), c = (i % 2 == 0) and LAVA2 or LAVA, m = NEON, j = "Head" })
	end
	-- smoke cloud
	r:add({ sz = V(0.9, 1.0, 0.9), p = V(0, 5.8, 0), c = C(85, 70, 68), j = "Head" })
	r:add({ sz = V(2.7, 1.4, 2.5), p = V(0, 6.65, 0), c = C(70, 60, 60), j = "Head" })
	r:sym({ sz = V(1.6, 1.25, 1.6), p = V(-1.0, 6.95, 0.2), c = C(62, 52, 54), j = "Head" })
	r:add({ sz = V(1.5, 1.2, 1.5), p = V(0, 7.35, -0.3), c = C(80, 68, 66), j = "Head" })
	r:add({ sz = V(1.3, 1.1, 1.3), p = V(0.2, 7.5, 0.5), c = C(58, 50, 52), j = "Head" })
	r:add({ sz = V(2.3, 0.35, 2.1), p = V(0, 6.05, 0), c = LAVA, m = NEON, t = 0.35, j = "Head" })
	-- golden crown
	r:add({ s = "cyl", sz = V(1.62, 0.36, 1.62), p = V(0, 5.32, 0), c = GOLD, m = METAL, refl = 0.15, j = "Head" })
	r:ring(7, function(i, a)
		return { sz = V(0.24, 0.62, 0.24), p = V(math.sin(a) * 0.78, 5.72, math.cos(a) * 0.78), c = GOLD, m = METAL, j = "Head" }
	end)
	r:add({ s = "box", sz = V(0.3, 0.3, 0.1), p = V(0, 5.35, -0.82), r = V(0, 0, 45), c = C(255, 30, 40), m = NEON, j = "Head" })
	r:sym({ s = "ball", sz = V(0.15, 0, 0), p = V(-0.5, 5.33, -0.62), c = C(255, 30, 40), m = NEON, j = "Head" })

	-- angry face
	r:sym({ sz = V(0.58, 0.44, 0.2), p = V(-0.45, 3.85, -1.0), r = V(0, 0, -15), c = LAVA2, m = NEON })
	r:sym({ sz = V(0.24, 0.24, 0.1), p = V(-0.4, 3.82, -1.09), c = C(30, 10, 5) })
	r:sym({ s = "box", sz = V(0.75, 0.2, 0.18), p = V(-0.45, 4.18, -1.0), r = V(0, 0, -22), c = C(15, 12, 12) })
	r:add({ sz = V(1.25, 0.52, 0.2), p = V(0, 3.22, -1.1), c = C(25, 10, 8) })
	r:add({ s = "box", sz = V(1.0, 0.18, 0.08), p = V(0, 3.32, -1.18), c = LAVA2, m = NEON })
	for k = -2, 2 do
		r:add({ s = "box", sz = V(0.02, 0.18, 0.09), p = V(k * 0.2, 3.32, -1.19), c = C(160, 110, 20) })
	end

	-- white fur collar with black dots
	r:ring(13, function(i, a)
		return { sz = V(0.75, 0.6, 0.65), p = V(math.sin(a) * 1.22, 2.95, math.cos(a) * 1.22), c = WHITE }
	end)
	for i = 1, 6 do
		local a = i * 1.05
		r:add({ s = "ball", sz = V(0.1, 0, 0), p = V(math.sin(a) * 1.5, 3.0, math.cos(a) * 1.5), c = C(10, 10, 10) })
	end
	-- gold chain with a red gem
	for i = -5, 5 do
		local x = i * 0.17
		r:add({ s = "ball", sz = V(0.15, 0, 0), p = V(x, 2.62 + (x * x) * 0.5, -1.3 + math.abs(x) * 0.12), c = GOLD, m = METAL })
	end
	r:add({ sz = V(0.55, 0.65, 0.18), p = V(0, 2.3, -1.34), c = GOLD, m = METAL })
	r:add({ s = "box", sz = V(0.34, 0.34, 0.12), p = V(0, 2.3, -1.42), r = V(0, 0, 45), c = C(255, 30, 40), m = NEON })

	-- royal cape
	r:add({ s = "box", sz = V(2.75, 2.6, 0.15), p = V(0, 1.8, 1.28), r = V(10, 0, 0), c = RED, j = "Cape" })
	r:add({ s = "box", sz = V(2.8, 0.2, 0.2), p = V(0, 0.56, 1.48), r = V(10, 0, 0), c = GOLD, m = METAL, j = "Cape" })
	r:sym({ s = "box", sz = V(0.15, 2.5, 0.2), p = V(-1.33, 1.8, 1.3), r = V(10, 0, 0), c = GOLD, m = METAL, j = "Cape" })
	r:add({ sz = V(0.7, 1.0, 0.1), p = V(0, 1.9, 1.42), r = V(10, 0, 0), c = LAVA, m = NEON, j = "Cape" })
	r:add({ sz = V(0.34, 0.55, 0.1), p = V(0, 1.75, 1.47), r = V(10, 0, 0), c = LAVA2, m = NEON, j = "Cape" })

	-- rocky arms with gold bracelets
	r:sym({ sz = V(0.78, 1.3, 0.78), p = V(-1.45, 2.45, 0), r = V(0, 0, -12), c = ROCK, m = BASALT, j = "ArmL" })
	r:sym({ s = "cyl", sz = V(0.9, 0.26, 0.9), p = V(-1.52, 2.0, 0), c = GOLD, m = METAL, j = "ArmL" })
	r:sym({ sz = V(0.9, 0.82, 0.9), p = V(-1.56, 1.6, 0), c = ROCK2, m = BASALT, j = "ArmL" })
	r:sym({ s = "box", sz = V(0.05, 0.4, 0.05), p = V(-1.4, 2.5, -0.4), r = V(0, 0, 25), c = LAVA, m = NEON, j = "ArmL" })

	r:emitter("Head", { Name = "WalkSmoke", Rate = 0, Texture = Rig.TEX.smoke, LightEmission = 0, Lifetime = NumberRange.new(2, 2), Speed = NumberRange.new(1.5, 3), SpreadAngle = Vector2.new(35, 35), Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1.2), NumberSequenceKeypoint.new(1, 3.5) }), Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) }), Color = ColorSequence.new(C(90, 80, 80)), EmissionDirection = Enum.NormalId.Top })
	r:emitter("Head", { Rate = 3, Texture = Rig.TEX.fire, Lifetime = NumberRange.new(0.6, 1), Speed = NumberRange.new(1, 2), Size = NumberSequence.new(0.4, 0), Color = ColorSequence.new(LAVA2, LAVA), EmissionDirection = Enum.NormalId.Top })
	r:light("Body", LAVA, 1.2, 10)
	return r:finish("LavaStone", "bully")
end
