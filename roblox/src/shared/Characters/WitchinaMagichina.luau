-- Witchina Magichina (Mythic): a chibi witch. Long lavender hair, a huge purple witch hat
-- with a ruffled brim, a big bow, hanging gold stars and a crooked tip, glowing purple
-- eyes and a fang smile, purple frilly dress with gold stars, a belt full of glowing
-- potions, striped stockings, black boots with bows, a staff with a purple crystal,
-- and a glowing potion always in her hand.
local Rig = require(script.Parent.Parent.Rig)
local C, V = Color3.fromRGB, Vector3.new

local PURPLE = C(105, 45, 160)
local PURPLE_D = C(58, 24, 92)
local LILAC = C(195, 145, 235)
local FRILL = C(238, 220, 252)
local HAIR = C(212, 172, 238)
local HAIR2 = C(190, 150, 225)
local SKIN = C(252, 218, 192)
local GOLD = C(245, 195, 70)
local POTION = C(200, 80, 255)
local NEON = Enum.Material.Neon
local GLASS = Enum.Material.Glass
local METAL = Enum.Material.Metal

local function star(r, p: Vector3, s: number, j: string?)
	r:add({ s = "box", sz = V(s, s, 0.06), p = p, c = GOLD, m = NEON, j = j })
	r:add({ s = "box", sz = V(s, s, 0.06), p = p, r = V(0, 0, 45), c = GOLD, m = NEON, j = j })
end

local function bottle(r, p: Vector3, s: number, j: string?)
	r:add({ sz = V(0.4 * s, 0.5 * s, 0.4 * s), p = p, c = POTION, m = NEON, j = j })
	r:add({ sz = V(0.52 * s, 0.64 * s, 0.52 * s), p = p, c = C(230, 210, 255), m = GLASS, t = 0.55, j = j })
	r:add({ s = "cyl", sz = V(0.18 * s, 0.28 * s, 0.18 * s), p = p + V(0, 0.4 * s, 0), c = C(230, 210, 255), m = GLASS, t = 0.4, j = j })
	r:add({ s = "cyl", sz = V(0.2 * s, 0.14 * s, 0.2 * s), p = p + V(0, 0.58 * s, 0), c = C(140, 90, 50), j = j })
end

return function(): Model
	local r = Rig.new("WitchinaMagichina", 2.0)
	r:symJoint("LegL", V(-0.45, 1.8, 0))
	r:symJoint("ArmL", V(-1.0, 3.8, 0))
	r:joint("Head", V(0, 3.9, 0))

	-- boots with bows and buckles
	r:sym({ s = "box", sz = V(0.85, 0.75, 1.2), p = V(-0.45, 0.4, -0.1), c = C(35, 25, 42), j = "LegL" })
	r:sym({ s = "box", sz = V(0.9, 0.15, 1.25), p = V(-0.45, 0.08, -0.1), c = C(20, 15, 25), j = "LegL" })
	r:sym({ sz = V(0.3, 0.22, 0.12), p = V(-0.6, 0.72, -0.72), c = LILAC, j = "LegL" })
	r:sym({ sz = V(0.3, 0.22, 0.12), p = V(-0.3, 0.72, -0.72), c = LILAC, j = "LegL" })
	r:sym({ s = "box", sz = V(0.2, 0.2, 0.06), p = V(-0.45, 0.45, -0.72), c = GOLD, m = METAL, j = "LegL" })
	-- striped stockings
	for k = 0, 3 do
		r:sym({ s = "box", sz = V(0.62, 0.22, 0.62), p = V(-0.45, 0.88 + k * 0.22, 0), c = (k % 2 == 0) and PURPLE or LILAC, j = "LegL" })
	end

	-- frilly skirt in layers with gold stars
	r:add({ s = "cyl", sz = V(2.55, 0.55, 2.35), p = V(0, 1.85, 0), c = FRILL })
	r:add({ s = "cyl", sz = V(2.35, 0.7, 2.15), p = V(0, 2.25, 0), c = PURPLE_D })
	r:add({ s = "cyl", sz = V(2.0, 0.45, 1.85), p = V(0, 2.62, 0), c = PURPLE })
	r:ring(10, function(i, a)
		return { s = "box", sz = V(0.18, 0.18, 0.05), p = V(math.sin(a) * 1.17, 2.15, math.cos(a) * 1.07), r = V(0, math.deg(a), 45), c = GOLD, m = NEON }
	end)
	-- bodice with lacing
	r:add({ s = "box", sz = V(1.6, 1.25, 1.05), p = V(0, 3.25, 0), c = PURPLE })
	for k = 0, 3 do
		r:add({ s = "box", sz = V(0.5, 0.05, 0.04), p = V(0, 2.9 + k * 0.22, -0.54), r = V(0, 0, (k % 2 == 0) and 25 or -25), c = LILAC })
	end
	r:sym({ sz = V(0.45, 0.32, 0.18), p = V(-0.25, 3.85, -0.5), r = V(0, 0, 15), c = LILAC })
	star(r, V(0, 3.85, -0.6), 0.18)
	-- belt with glowing potions and a pouch
	r:add({ s = "box", sz = V(1.7, 0.3, 1.12), p = V(0, 2.68, 0), c = C(95, 60, 40) })
	r:add({ s = "box", sz = V(0.3, 0.28, 0.06), p = V(0, 2.68, -0.58), c = GOLD, m = METAL })
	bottle(r, V(-0.92, 2.55, -0.25), 1)
	bottle(r, V(-0.85, 2.55, 0.25), 0.8)
	r:add({ s = "box", sz = V(0.5, 0.55, 0.3), p = V(0.95, 2.5, -0.15), c = C(110, 70, 45) })
	star(r, V(0.95, 2.52, -0.31), 0.16)

	-- arms with puffy sleeves; staff in the left hand, potion in the right
	r:sym({ sz = V(0.82, 0.72, 0.82), p = V(-1.05, 3.65, 0), c = FRILL, j = "ArmL" })
	r:sym({ s = "box", sz = V(0.7, 1.0, 0.7), p = V(-1.1, 3.0, 0), c = PURPLE, j = "ArmL" })
	r:sym({ s = "cyl", sz = V(0.85, 0.22, 0.85), p = V(-1.1, 2.55, 0), c = FRILL, j = "ArmL" })
	r:sym({ s = "box", sz = V(0.55, 0.5, 0.55), p = V(-1.1, 2.25, 0), c = SKIN, j = "ArmL" })
	r:add({ s = "cyl", sz = V(0.18, 4.4, 0.18), p = V(-1.1, 2.3, -0.42), c = C(60, 35, 25), j = "ArmL" })
	r:add({ s = "box", sz = V(0.42, 0.95, 0.42), p = V(-1.1, 4.95, -0.42), r = V(0, 45, 0), c = POTION, m = NEON, j = "ArmL" })
	for k = 0, 5 do
		local a = k * 1.1
		r:add({ s = "ball", sz = V(0.12, 0, 0), p = V(-1.1 + math.cos(a) * 0.3, 4.35 + k * 0.1, -0.42 + math.sin(a) * 0.3), c = GOLD, m = METAL, j = "ArmL" })
	end
	r:add({ sz = V(0.45, 0.2, 0.12), p = V(-1.1, 4.4, -0.62), c = LILAC, j = "ArmL" })
	bottle(r, V(1.12, 1.95, -0.2), 1.2, "ArmR")

	-- head
	r:add({ s = "box", sz = V(1.6, 1.5, 1.4), p = V(0, 4.75, 0), c = SKIN, j = "Head" })
	r:eye(V(-0.38, 4.75, -0.71), 0.46, C(175, 70, 255), "Head", { glow = true, tall = 1.2 })
	r:eye(V(0.38, 4.75, -0.71), 0.46, C(175, 70, 255), "Head", { glow = true, tall = 1.2 })
	r:add({ sz = V(0.45, 0.2, 0.08), p = V(0, 4.3, -0.71), c = C(120, 30, 60), j = "Head" })
	r:add({ s = "box", sz = V(0.07, 0.1, 0.04), p = V(0.1, 4.36, -0.75), c = C(255, 255, 255), j = "Head" })
	r:sym({ sz = V(0.28, 0.16, 0.06), p = V(-0.58, 4.42, -0.71), c = C(255, 160, 190), j = "Head" })
	-- long lavender hair
	r:add({ sz = V(2.0, 2.6, 1.0), p = V(0, 4.0, 0.6), c = HAIR, j = "Head" })
	r:sym({ sz = V(0.6, 2.3, 1.0), p = V(-0.92, 4.0, -0.05), c = HAIR2, j = "Head" })
	r:sym({ sz = V(0.55, 0.6, 0.55), p = V(-0.95, 2.85, 0.1), c = HAIR, j = "Head" })
	r:add({ sz = V(1.9, 0.7, 1.6), p = V(0, 5.45, 0.05), c = HAIR, j = "Head" })
	for k = -2, 2 do
		r:add({ sz = V(0.5, 0.55, 0.35), p = V(k * 0.33, 5.3, -0.7), r = V(15, 0, k * 10), c = (k % 2 == 0) and HAIR or HAIR2, j = "Head" })
	end

	-- the big witch hat
	r:add({ s = "cyl", sz = V(3.6, 0.14, 3.6), p = V(0, 5.6, 0), c = FRILL, j = "Head" })
	r:add({ s = "cyl", sz = V(3.4, 0.16, 3.4), p = V(0, 5.68, 0), c = PURPLE_D, j = "Head" })
	r:ring(14, function(i, a)
		return { s = "box", sz = V(0.12, 0.12, 0.05), p = V(math.sin(a) * 1.6, 5.77, math.cos(a) * 1.6), r = V(0, math.deg(a), 45), c = GOLD, m = NEON, j = "Head" }
	end)
	local cone = { { 1.85, 0.6, 5.98, 0, 0 }, { 1.5, 0.55, 6.5, 0, 0.05 }, { 1.15, 0.5, 6.98, 0.05, 0.15 }, { 0.82, 0.45, 7.4, 0.15, 0.3 }, { 0.52, 0.4, 7.75, 0.3, 0.48 } }
	for _, cc in cone do
		r:add({ s = "cyl", sz = V(cc[1], cc[2], cc[1]), p = V(cc[4], cc[3], cc[5]), c = PURPLE_D, j = "Head" })
	end
	r:add({ s = "ball", sz = V(0.32, 0, 0), p = V(0.48, 8.0, 0.66), c = PURPLE_D, j = "Head" })
	star(r, V(0.55, 7.75, 0.82), 0.2, "Head")
	r:add({ s = "cyl", sz = V(1.9, 0.32, 1.9), p = V(0, 6.0, 0), c = LILAC, j = "Head" })
	r:sym({ sz = V(0.7, 0.5, 0.25), p = V(-0.5, 6.05, -0.92), r = V(0, 0, 20), c = LILAC, j = "Head" })
	r:add({ sz = V(0.3, 0.3, 0.2), p = V(0, 6.05, -0.95), c = PURPLE, j = "Head" })
	r:add({ s = "box", sz = V(0.06, 0.4, 0.06), p = V(0.12, 7.0, -0.58), r = V(-10, 0, 0), c = LILAC, j = "Head" })
	r:add({ s = "box", sz = V(0.06, 0.4, 0.06), p = V(-0.1, 6.6, -0.75), r = V(-10, 0, 0), c = LILAC, j = "Head" })
	-- gold stars hanging from the brim
	for _, p in { V(-1.45, 5.25, -0.55), V(1.5, 5.15, -0.3), V(1.2, 5.3, 0.9), V(-1.0, 5.2, 1.2) } do
		r:add({ s = "box", sz = V(0.03, 0.45, 0.03), p = p + V(0, 0.32, 0), c = GOLD, j = "Head" })
		star(r, p, 0.2, "Head")
	end
	-- crescent moon on the back of the hat
	r:add({ sz = V(0.5, 0.5, 0.08), p = V(0, 6.1, 0.97), c = GOLD, m = NEON, j = "Head" })
	r:add({ sz = V(0.42, 0.42, 0.09), p = V(0.12, 6.15, 0.98), c = LILAC, j = "Head" })

	r:emitter("ArmR", { Rate = 8, Lifetime = NumberRange.new(0.8, 1.4), Speed = NumberRange.new(0.5, 1.2), SpreadAngle = Vector2.new(60, 60), Size = NumberSequence.new(0.25, 0), Color = ColorSequence.new(POTION, C(255, 200, 255)), EmissionDirection = Enum.NormalId.Top })
	r:emitter("Body", { Rate = 4, Lifetime = NumberRange.new(1, 1.6), Speed = NumberRange.new(0.3, 0.8), SpreadAngle = Vector2.new(180, 180), Size = NumberSequence.new(0.22, 0), Color = ColorSequence.new(GOLD, LILAC) })
	r:light("ArmR", POTION, 1.4, 10)
	return r:finish("WitchinaMagichina", "potion")
end
