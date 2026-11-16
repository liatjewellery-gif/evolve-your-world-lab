-- Grass and Flowers (Common): yellow smiling face inside big pink petals,
-- white flower crown, leafy green dress with glowing gold vines,
-- green leaf gloves and white sneakers with pink flowers.
local Rig = require(script.Parent.Parent.Rig)
local C, V = Color3.fromRGB, Vector3.new

local PINK = C(255, 105, 185)
local PINK_LIGHT = C(255, 175, 220)
local PINK_DARK = C(235, 70, 160)
local FACE = C(255, 205, 60)
local LEAF = C(70, 150, 50)
local LEAF2 = C(95, 175, 60)
local LEAF3 = C(55, 125, 40)
local GOLD = C(255, 215, 90)
local WHITE = C(255, 255, 255)
local NEON = Enum.Material.Neon

return function(): Model
	local r = Rig.new("GrassAndFlowers", 2.0)
	r:symJoint("LegL", V(-0.55, 1.7, 0))
	r:symJoint("ArmL", V(-1.15, 3.3, 0))
	r:joint("Head", V(0, 3.6, 0))
	r:joint("Halo", V(0, 2.6, 0))

	-- sneakers
	r:sym({ sz = V(0.95, 0.7, 1.35), p = V(-0.55, 0.38, -0.15), c = WHITE, j = "LegL" })
	r:sym({ sz = V(1.02, 0.25, 1.42), p = V(-0.55, 0.14, -0.15), c = C(255, 205, 225), j = "LegL" })
	r:sym({ sz = V(0.97, 0.22, 1.0), p = V(-0.55, 0.66, 0.05), c = LEAF2, j = "LegL" })
	r:sym({ s = "ball", sz = V(0.36, 0, 0), p = V(-0.55, 0.58, -0.74), c = PINK, j = "LegL" })
	r:sym({ s = "ball", sz = V(0.16, 0, 0), p = V(-0.55, 0.6, -0.9), c = C(255, 230, 80), j = "LegL" })
	r:sym({ sz = V(0.2, 0.08, 0.5), p = V(-0.55, 0.72, -0.35), c = PINK_LIGHT, j = "LegL" })
	-- legs
	r:sym({ sz = V(0.55, 1.2, 0.55), p = V(-0.55, 1.15, 0), c = LEAF3, j = "LegL" })

	-- leafy dress
	r:add({ sz = V(2.0, 2.2, 1.6), p = V(0, 2.6, 0), c = LEAF })
	r:ring(11, function(i, a)
		return { sz = V(0.75, 1.3, 0.35), p = V(math.sin(a) * 1.0, 1.95, math.cos(a) * 0.82), r = V(-28, math.deg(a), 0), c = (i % 2 == 0) and LEAF3 or LEAF }
	end)
	r:ring(9, function(i, a)
		a += 0.3
		return { sz = V(0.65, 1.1, 0.3), p = V(math.sin(a) * 0.95, 3.0, math.cos(a) * 0.78), r = V(-18, math.deg(a), 0), c = (i % 2 == 0) and LEAF2 or LEAF }
	end)
	-- little white flowers on the dress
	for _, p in { V(-0.5, 2.95, -0.82), V(0.55, 2.45, -0.88), V(0.05, 1.95, -1.0), V(-0.7, 1.9, -0.85), V(0.75, 3.15, -0.6), V(0, 2.9, 0.85) } do
		r:add({ s = "ball", sz = V(0.34, 0, 0), p = p, c = WHITE })
		r:add({ s = "ball", sz = V(0.14, 0, 0), p = p + V(0, 0, -0.14), c = C(255, 220, 70) })
	end
	-- glowing golden vines spiralling up the body
	for i = 1, 16 do
		local a = i * 0.85
		r:add({ sz = V(0.22, 0.16, 0.16), p = V(math.sin(a) * 1.03, 1.75 + i * 0.1, math.cos(a) * 0.82), c = GOLD, m = NEON })
	end

	-- arms with leaf gloves
	r:sym({ sz = V(0.6, 1.2, 0.6), p = V(-1.3, 2.75, 0), r = V(0, 0, -10), c = LEAF2, j = "ArmL" })
	r:sym({ sz = V(0.5, 0.6, 0.3), p = V(-1.35, 3.1, -0.25), r = V(0, 0, -10), c = LEAF, j = "ArmL" })
	r:sym({ sz = V(0.72, 0.68, 0.72), p = V(-1.42, 2.05, 0), c = LEAF, j = "ArmL" })
	r:sym({ sz = V(0.28, 0.4, 0.28), p = V(-1.2, 2.15, -0.3), r = V(0, 0, 20), c = LEAF, j = "ArmL" })

	-- face
	r:add({ sz = V(2.3, 2.1, 1.9), p = V(0, 4.75, 0), c = FACE, j = "Head" })
	r:sym({ sz = V(0.45, 0.25, 0.1), p = V(-0.78, 4.42, -0.86), c = C(255, 140, 150), j = "Head" })
	r:eye(V(-0.45, 4.95, -0.82), 0.64, C(120, 65, 20), "Head")
	r:eye(V(0.45, 4.95, -0.82), 0.64, C(120, 65, 20), "Head")
	r:sym({ sz = V(0.46, 0.12, 0.12), p = V(-0.45, 5.48, -0.8), r = V(0, 0, -12), c = C(110, 60, 25), j = "Head" })
	r:add({ sz = V(0.78, 0.58, 0.22), p = V(0, 4.3, -0.9), c = C(130, 20, 30), j = "Head" })
	r:add({ sz = V(0.46, 0.25, 0.15), p = V(0, 4.15, -0.97), c = C(255, 110, 130), j = "Head" })
	r:add({ s = "box", sz = V(0.34, 0.1, 0.05), p = V(0, 4.53, -0.99), c = WHITE, j = "Head" })

	-- big pink petals (two layers)
	r:ring(10, function(i, a)
		return { sz = V(1.2, 1.95, 0.45), p = V(math.sin(a) * 1.55, 4.75 + math.cos(a) * 1.45, 0.4), r = V(0, 0, -math.deg(a)), c = PINK, j = "Head" }
	end)
	r:ring(10, function(i, a)
		return { sz = V(0.65, 1.0, 0.3), p = V(math.sin(a) * 1.85, 4.75 + math.cos(a) * 1.75, 0.22), r = V(0, 0, -math.deg(a)), c = PINK_LIGHT, j = "Head" }
	end)
	r:ring(10, function(i, a)
		a += math.pi / 10
		return { sz = V(1.1, 1.8, 0.4), p = V(math.sin(a) * 1.45, 4.75 + math.cos(a) * 1.35, 0.7), r = V(0, 0, -math.deg(a)), c = PINK_DARK, j = "Head" }
	end)
	r:add({ sz = V(0.9, 0.6, 0.5), p = V(0, 4.75, 0.95), c = LEAF, j = "Head" })

	-- flower crown
	for i = -3, 3 do
		local p = V(i * 0.32, 5.72 - math.abs(i) * 0.09, -0.4 + math.abs(i) * 0.05)
		r:add({ sz = V(0.36, 0.18, 0.3), p = p + V(0.15, -0.05, 0.1), c = LEAF2, j = "Head" })
		r:add({ s = "ball", sz = V(0.4, 0, 0), p = p, c = WHITE, j = "Head" })
		r:add({ s = "ball", sz = V(0.17, 0, 0), p = p + V(0, 0.02, -0.16), c = C(255, 210, 50), j = "Head" })
	end

	-- golden sparkle ring around the body (spins in the Gait module)
	r:ring(18, function(i, a)
		return { s = "ball", sz = V(0.18, 0, 0), p = V(math.cos(a) * 1.55, 2.6 + math.sin(a * 2) * 0.15, math.sin(a) * 1.55), c = GOLD, m = NEON, j = "Halo" }
	end)

	r:emitter("Body", { Rate = 4, Lifetime = NumberRange.new(1, 1.6), Speed = NumberRange.new(0.5, 1.2), SpreadAngle = Vector2.new(180, 180), Size = NumberSequence.new(0.25, 0), Color = ColorSequence.new(PINK_LIGHT, GOLD) })
	r:light("Head", C(255, 200, 120), 0.6, 8)
	return r:finish("GrassAndFlowers", "cute")
end
