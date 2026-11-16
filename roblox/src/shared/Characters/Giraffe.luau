-- Giraffe (Legendary, "Golden Giraffe"): golden-yellow giraffe with brown spots, big
-- shiny eyes with lashes, happy open smile, gold crown with emeralds, green cape with
-- gold trim and a golden leaf emblem, emerald brooch, white-gold sneakers.
local Rig = require(script.Parent.Parent.Rig)
local C, V = Color3.fromRGB, Vector3.new

local SKIN = C(248, 200, 95)
local SPOT = C(185, 112, 42)
local SNOUT = C(252, 228, 160)
local GOLD = C(245, 195, 50)
local GREEN = C(40, 110, 45)
local EMERALD = C(40, 220, 90)
local WHITE = C(252, 252, 250)
local NEON = Enum.Material.Neon
local METAL = Enum.Material.Metal

local function spots(r, center: Vector3, radius: Vector3, count: number, seed: number, j: string?)
	local rng = Random.new(seed)
	for _ = 1, count do
		local a = rng:NextNumber(0, math.pi * 2)
		local y = rng:NextNumber(-0.8, 0.8)
		local ring = math.sqrt(1 - y * y)
		local dir = V(math.sin(a) * ring, y, math.cos(a) * ring)
		local p = center + V(dir.X * radius.X, dir.Y * radius.Y, dir.Z * radius.Z) * 0.97
		local rx = -math.deg(math.asin(dir.Y))
		local ry = math.deg(math.atan2(dir.X, dir.Z))
		local s = rng:NextNumber(0.28, 0.42)
		r:add({ sz = V(s, s * 0.8, 0.1), p = p, r = V(rx, ry, rng:NextNumber(0, 90)), c = SPOT, j = j })
	end
end

return function(): Model
	local r = Rig.new("Giraffe", 2.3)
	r:symJoint("LegL", V(-0.5, 1.95, 0))
	r:symJoint("ArmL", V(-0.9, 3.45, 0))
	r:joint("Neck", V(0, 3.5, 0))
	r:joint("Head", V(0, 5.8, 0), "Neck")
	r:joint("Cape", V(0, 3.6, 0.6))

	-- sneakers
	r:sym({ sz = V(0.98, 0.72, 1.38), p = V(-0.5, 0.4, -0.15), c = WHITE, j = "LegL" })
	r:sym({ sz = V(1.03, 0.26, 1.45), p = V(-0.5, 0.14, -0.15), c = GOLD, m = METAL, j = "LegL" })
	r:sym({ sz = V(0.85, 0.3, 0.8), p = V(-0.5, 0.65, 0.15), c = GOLD, m = METAL, j = "LegL" })
	r:sym({ s = "box", sz = V(0.3, 0.2, 0.05), p = V(-0.98, 0.45, -0.1), r = V(0, 90, 0), c = GOLD, j = "LegL" })
	r:sym({ s = "box", sz = V(0.45, 0.06, 0.08), p = V(-0.5, 0.78, -0.45), c = WHITE, j = "LegL" })
	-- legs
	r:sym({ sz = V(0.5, 1.35, 0.5), p = V(-0.5, 1.3, 0), c = SKIN, j = "LegL" })
	r:sym({ sz = V(0.24, 0.2, 0.08), p = V(-0.5, 1.45, -0.24), c = SPOT, j = "LegL" })

	-- body
	r:add({ sz = V(1.75, 1.95, 1.45), p = V(0, 2.8, 0), c = SKIN })
	r:add({ sz = V(1.2, 1.4, 0.4), p = V(0, 2.7, -0.55), c = SNOUT })
	spots(r, V(0, 2.8, 0), V(0.87, 0.97, 0.72), 12, 3)

	-- long neck with a mane
	r:add({ sz = V(0.72, 2.7, 0.72), p = V(0, 4.65, 0), c = SKIN, j = "Neck" })
	spots(r, V(0, 4.65, 0), V(0.36, 1.2, 0.36), 7, 5, "Neck")
	for k = 0, 5 do
		r:add({ sz = V(0.2, 0.42, 0.3), p = V(0, 3.75 + k * 0.38, 0.38), c = SPOT, j = "Neck" })
	end

	-- head
	r:add({ sz = V(1.6, 1.4, 1.5), p = V(0, 6.4, 0), c = SKIN, j = "Head" })
	r:add({ sz = V(1.15, 0.85, 0.95), p = V(0, 6.05, -0.6), c = SNOUT, j = "Head" })
	r:sym({ sz = V(0.12, 0.08, 0.06), p = V(-0.2, 6.25, -1.06), c = C(120, 70, 30), j = "Head" })
	r:add({ sz = V(0.62, 0.38, 0.15), p = V(0, 5.84, -1.0), c = C(150, 30, 40), j = "Head" })
	r:add({ sz = V(0.35, 0.18, 0.1), p = V(0, 5.76, -1.04), c = C(255, 120, 130), j = "Head" })
	r:add({ s = "box", sz = V(0.26, 0.08, 0.04), p = V(0, 5.98, -1.06), c = WHITE, j = "Head" })
	r:eye(V(-0.42, 6.55, -0.62), 0.56, C(120, 70, 25), "Head")
	r:eye(V(0.42, 6.55, -0.62), 0.56, C(120, 70, 25), "Head")
	for k = 0, 2 do
		r:sym({ s = "box", sz = V(0.04, 0.2, 0.04), p = V(-0.62 - k * 0.07, 6.88 + k * 0.02, -0.6), r = V(0, 0, 30 + k * 15), c = C(40, 25, 15), j = "Head" })
	end
	r:sym({ sz = V(0.3, 0.2, 0.08), p = V(-0.68, 6.2, -0.58), c = C(255, 150, 120), j = "Head" })
	spots(r, V(0, 6.5, 0.1), V(0.8, 0.7, 0.72), 5, 9, "Head")
	-- ears
	r:sym({ sz = V(0.36, 0.72, 0.22), p = V(-0.88, 6.8, 0.05), r = V(0, 0, 60), c = SKIN, j = "Head" })
	r:sym({ sz = V(0.2, 0.5, 0.1), p = V(-0.9, 6.8, -0.04), r = V(0, 0, 60), c = C(255, 160, 160), j = "Head" })
	-- ossicones
	r:sym({ s = "cyl", sz = V(0.18, 0.62, 0.18), p = V(-0.32, 7.3, 0.15), c = C(200, 130, 60), j = "Head" })
	r:sym({ s = "ball", sz = V(0.32, 0, 0), p = V(-0.32, 7.65, 0.15), c = C(130, 75, 35), j = "Head" })
	-- crown with emeralds
	r:add({ s = "cyl", sz = V(0.95, 0.36, 0.95), p = V(0, 7.18, -0.15), c = GOLD, m = METAL, refl = 0.15, j = "Head" })
	r:ring(5, function(i, a)
		return { sz = V(0.2, 0.55, 0.2), p = V(math.sin(a) * 0.45, 7.55, -0.15 + math.cos(a) * 0.45), c = GOLD, m = METAL, j = "Head" }
	end)
	r:add({ s = "box", sz = V(0.22, 0.22, 0.08), p = V(0, 7.18, -0.64), r = V(0, 0, 45), c = EMERALD, m = NEON, j = "Head" })

	-- arms
	r:sym({ sz = V(0.45, 1.3, 0.45), p = V(-1.0, 2.75, 0), r = V(0, 0, -10), c = SKIN, j = "ArmL" })
	r:sym({ sz = V(0.52, 0.48, 0.52), p = V(-1.1, 2.0, 0), c = SNOUT, j = "ArmL" })

	-- green cape with gold trim, collar and emerald brooch
	r:ring(10, function(i, a)
		return { sz = V(0.6, 0.45, 0.5), p = V(math.sin(a) * 0.62, 3.65, math.cos(a) * 0.6), c = GREEN }
	end)
	r:add({ sz = V(0.62, 0.62, 0.22), p = V(0, 3.6, -0.7), c = GOLD, m = METAL })
	r:add({ sz = V(0.42, 0.5, 0.18), p = V(0, 3.6, -0.78), c = EMERALD, m = NEON })
	r:add({ s = "box", sz = V(2.4, 2.45, 0.12), p = V(0, 2.4, 0.95), r = V(8, 0, 0), c = GREEN, j = "Cape" })
	r:add({ s = "box", sz = V(2.46, 0.18, 0.16), p = V(0, 1.2, 1.12), r = V(8, 0, 0), c = GOLD, m = METAL, j = "Cape" })
	r:sym({ s = "box", sz = V(0.14, 2.4, 0.16), p = V(-1.17, 2.4, 0.97), r = V(8, 0, 0), c = GOLD, m = METAL, j = "Cape" })
	r:add({ s = "box", sz = V(0.06, 0.9, 0.06), p = V(0, 2.35, 1.07), r = V(8, 0, 0), c = GOLD, m = NEON, j = "Cape" })
	for k = 0, 2 do
		r:sym({ sz = V(0.38, 0.16, 0.06), p = V(-0.2, 2.1 + k * 0.28, 1.06 - k * 0.04), r = V(8, 0, 30), c = GOLD, m = NEON, j = "Cape" })
	end

	r:emitter("Body", { Rate = 5, Lifetime = NumberRange.new(1, 1.8), Speed = NumberRange.new(0.4, 1.2), SpreadAngle = Vector2.new(180, 180), Size = NumberSequence.new(0.3, 0), Color = ColorSequence.new(C(255, 230, 120), GOLD) })
	r:light("Body", C(255, 210, 110), 0.7, 9)
	return r:finish("Giraffe", "skip")
end
