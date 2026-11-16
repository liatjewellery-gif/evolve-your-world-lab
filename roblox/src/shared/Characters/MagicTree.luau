-- Magic Tree (Rare): blocky bark body with glowing orange cracks, green vines with white
-- flowers, pink mushroom friends at the feet, purple crystals on the shoulders,
-- a glowing target on the chest, star eyes, leafy crown with horns, golden crystal
-- earrings, pixel sunglasses and a little yellow sprout sitting on top.
local Rig = require(script.Parent.Parent.Rig)
local C, V = Color3.fromRGB, Vector3.new

local BARK = C(130, 78, 40)
local BARK_D = C(95, 55, 28)
local BARK_L = C(160, 100, 58)
local CRACK = C(255, 165, 50)
local VINE = C(110, 180, 50)
local LEAF = C(115, 185, 55)
local LEAF2 = C(140, 205, 70)
local LEAF3 = C(85, 155, 45)
local WHITE = C(255, 255, 255)
local NEON = Enum.Material.Neon
local WOOD = Enum.Material.Wood

local function flower(r, p: Vector3, j: string?)
	r:add({ s = "ball", sz = V(0.36, 0, 0), p = p, c = WHITE, j = j })
	r:add({ s = "ball", sz = V(0.15, 0, 0), p = p + V(0, 0, -0.15), c = C(255, 200, 60), j = j })
end

local function mushroom(r, p: Vector3, j: string)
	r:add({ sz = V(0.38, 0.45, 0.38), p = p, c = C(250, 225, 170), j = j })
	r:add({ sz = V(0.9, 0.48, 0.9), p = p + V(0, 0.32, 0), c = C(240, 115, 205), j = j })
	for _, d in { V(0, 0.55, 0), V(0.22, 0.45, -0.25), V(-0.25, 0.45, -0.18), V(0.28, 0.42, 0.2) } do
		r:add({ s = "ball", sz = V(0.13, 0, 0), p = p + d, c = WHITE, j = j })
	end
	r:add({ s = "ball", sz = V(0.07, 0, 0), p = p + V(-0.08, 0.02, -0.19), c = C(20, 20, 20), j = j })
	r:add({ s = "ball", sz = V(0.07, 0, 0), p = p + V(0.08, 0.02, -0.19), c = C(20, 20, 20), j = j })
end

return function(): Model
	local r = Rig.new("MagicTree", 2.2)
	r:symJoint("LegL", V(-0.65, 1.9, 0))
	r:symJoint("ArmL", V(-1.35, 3.75, 0))
	r:joint("Head", V(0, 4.0, 0))

	-- legs like tree trunks with roots
	r:sym({ s = "box", sz = V(1.0, 1.6, 1.0), p = V(-0.65, 1.15, 0), c = BARK, m = WOOD, j = "LegL" })
	r:sym({ sz = V(1.35, 0.62, 1.55), p = V(-0.65, 0.3, -0.12), c = BARK_D, m = WOOD, j = "LegL" })
	for k = -1, 1 do
		r:sym({ sz = V(0.32, 0.3, 0.55), p = V(-0.65 + k * 0.38, 0.17, -0.85), c = BARK, j = "LegL" })
	end
	r:sym({ s = "box", sz = V(0.07, 1.0, 0.05), p = V(-0.5, 1.15, -0.52), r = V(0, 0, 9), c = CRACK, m = NEON, j = "LegL" })
	r:sym({ s = "box", sz = V(0.06, 0.6, 0.05), p = V(-0.85, 1.4, -0.52), r = V(0, 0, -14), c = CRACK, m = NEON, j = "LegL" })
	for k, y in { 0.75, 1.25, 1.7 } do
		r:sym({ sz = V(1.15, 0.2, 1.15), p = V(-0.65, y, 0), r = V(0, k * 40, (k % 2 == 0) and 12 or -12), c = VINE, j = "LegL" })
	end
	flower(r, V(-0.95, 1.3, -0.55), "LegL")
	flower(r, V(0.4, 0.95, -0.55), "LegR")
	mushroom(r, V(-1.35, 0.23, -0.55), "LegL")
	mushroom(r, V(1.35, 0.23, -0.55), "LegR")

	-- trunk body
	r:add({ s = "box", sz = V(2.3, 2.2, 1.5), p = V(0, 2.95, 0), c = BARK, m = WOOD })
	r:add({ s = "box", sz = V(2.2, 0.5, 1.45), p = V(0, 3.95, 0), c = BARK_L, m = WOOD })
	for _, d in { { -0.7, 2.6, 6 }, { 0.75, 2.4, -8 }, { 0.5, 3.4, 15 }, { -0.4, 3.55, -12 } } do
		r:add({ s = "box", sz = V(0.07, 0.75, 0.05), p = V(d[1], d[2], -0.76), r = V(0, 0, d[3]), c = CRACK, m = NEON })
	end
	-- glowing target on the chest, heart on the back
	r:add({ s = "cyl", sz = V(0.95, 0.06, 0.95), p = V(0, 3.15, -0.77), r = V(90, 0, 0), c = CRACK, m = NEON })
	r:add({ s = "cyl", sz = V(0.65, 0.07, 0.65), p = V(0, 3.15, -0.79), r = V(90, 0, 0), c = BARK_D })
	r:add({ s = "cyl", sz = V(0.38, 0.08, 0.38), p = V(0, 3.15, -0.81), r = V(90, 0, 0), c = CRACK, m = NEON })
	r:add({ s = "ball", sz = V(0.16, 0, 0), p = V(0, 3.15, -0.84), c = BARK_D })
	r:sym({ sz = V(0.38, 0.32, 0.08), p = V(-0.15, 3.1, 0.77), r = V(0, 0, 35), c = CRACK, m = NEON })
	-- leaf skirt
	r:ring(12, function(i, a)
		return { sz = V(0.85, 1.0, 0.3), p = V(math.sin(a) * 1.25, 2.0, math.cos(a) * 0.85), r = V(-32, math.deg(a), 0), c = (i % 2 == 0) and LEAF or LEAF3 }
	end)
	-- vines across the chest with flowers
	r:add({ sz = V(2.5, 0.22, 0.3), p = V(0, 3.55, -0.75), r = V(0, 0, 22), c = VINE })
	r:add({ sz = V(2.5, 0.22, 0.3), p = V(0, 2.55, -0.75), r = V(0, 0, -18), c = VINE })
	flower(r, V(-0.85, 3.2, -0.82))
	flower(r, V(0.9, 3.85, -0.8))
	flower(r, V(0.6, 2.45, -0.85))
	-- purple crystals on the shoulders
	for k, d in { V(0, 0, 0), V(0.3, -0.1, 0.25), V(-0.25, -0.1, -0.2) } do
		r:sym({ s = "box", sz = V(0.3, 0.75 - k * 0.1, 0.3), p = V(-1.25, 4.3, 0) + d, r = V(15 * k, 45, 20 - k * 12), c = C(200, 130, 255), m = (k == 1) and NEON or Enum.Material.Glass, t = (k == 1) and 0.1 or 0.15 })
	end

	-- arms
	r:sym({ s = "box", sz = V(0.9, 1.7, 0.9), p = V(-1.55, 2.95, 0), c = BARK, m = WOOD, j = "ArmL" })
	r:sym({ s = "box", sz = V(1.0, 0.8, 1.0), p = V(-1.6, 1.85, 0), c = BARK_D, m = WOOD, j = "ArmL" })
	r:sym({ sz = V(1.05, 0.2, 1.05), p = V(-1.55, 3.3, 0), r = V(0, 30, 14), c = VINE, j = "ArmL" })
	r:sym({ s = "box", sz = V(0.06, 0.7, 0.05), p = V(-1.4, 2.7, -0.47), r = V(0, 0, 10), c = CRACK, m = NEON, j = "ArmL" })

	-- face
	r:add({ sz = V(2.25, 1.95, 1.8), p = V(0, 4.95, 0), c = BARK_L, j = "Head" })
	r:eye(V(-0.5, 5.0, -0.8), 0.72, C(255, 170, 30), "Head", { glow = true })
	r:eye(V(0.5, 5.0, -0.8), 0.72, C(255, 170, 30), "Head", { glow = true })
	r:sym({ s = "box", sz = V(0.12, 0.42, 0.04), p = V(-0.5, 4.97, -1.06), r = V(0, 0, 45), c = C(255, 245, 160), m = NEON, j = "Head" })
	r:sym({ s = "box", sz = V(0.12, 0.42, 0.04), p = V(-0.5, 4.97, -1.06), r = V(0, 0, -45), c = C(255, 245, 160), m = NEON, j = "Head" })
	r:sym({ sz = V(0.4, 0.22, 0.08), p = V(-0.82, 4.55, -0.82), c = C(240, 120, 140), j = "Head" })
	r:add({ sz = V(0.5, 0.22, 0.1), p = V(0, 4.45, -0.88), c = C(60, 25, 15), j = "Head" })
	r:add({ sz = V(0.26, 0.32, 0.1), p = V(0, 4.3, -0.9), c = C(255, 110, 140), j = "Head" })

	-- leafy crown
	r:ring(11, function(i, a)
		return { sz = V(1.05, 0.72, 0.85), p = V(math.sin(a) * 1.25, 5.75 + (i % 2) * 0.12, math.cos(a) * 1.1), r = V(-20, math.deg(a), 0), c = (i % 3 == 0) and LEAF3 or LEAF, j = "Head" }
	end)
	r:ring(8, function(i, a)
		return { sz = V(1.0, 0.7, 0.85), p = V(math.sin(a + 0.4) * 0.75, 6.2, math.cos(a + 0.4) * 0.65), r = V(-12, math.deg(a), 0), c = (i % 2 == 0) and LEAF2 or LEAF, j = "Head" }
	end)
	r:add({ sz = V(1.4, 0.8, 1.3), p = V(0, 6.5, 0), c = LEAF2, j = "Head" })
	for k = -2, 2 do
		r:add({ sz = V(0.7, 0.55, 0.4), p = V(k * 0.42, 5.55 - math.abs(k) * 0.05, -0.95), r = V(25, 0, k * 8), c = (k % 2 == 0) and LEAF or LEAF2, j = "Head" })
	end
	flower(r, V(-0.95, 6.0, -0.75), "Head")
	flower(r, V(0.65, 6.35, -0.55), "Head")
	flower(r, V(1.3, 5.75, 0.2), "Head")
	flower(r, V(-0.3, 6.6, 0.6), "Head")
	-- horns
	r:sym({ sz = V(0.38, 0.95, 0.38), p = V(-1.3, 5.75, 0.1), r = V(0, 0, 35), c = BARK_D, j = "Head" })
	r:sym({ sz = V(0.3, 0.8, 0.3), p = V(-1.62, 6.35, 0.1), r = V(0, 0, -12), c = BARK_D, j = "Head" })
	-- golden crystal earrings
	r:sym({ s = "box", sz = V(0.05, 0.4, 0.05), p = V(-1.18, 4.95, -0.15), c = C(200, 150, 40), j = "Head" })
	r:sym({ s = "box", sz = V(0.34, 0.34, 0.34), p = V(-1.18, 4.55, -0.15), r = V(45, 0, 45), c = C(255, 205, 50), m = NEON, j = "Head" })
	-- pixel sunglasses resting on the leaves
	r:add({ s = "box", sz = V(0.95, 0.3, 0.1), p = V(0.6, 5.95, -0.95), r = V(0, 0, -10), c = C(15, 15, 15), j = "Head" })
	r:add({ s = "box", sz = V(0.2, 0.1, 0.02), p = V(0.42, 6.0, -1.01), r = V(0, 0, -10), c = WHITE, j = "Head" })
	-- little sprout friend on top
	r:add({ sz = V(1.05, 0.72, 0.92), p = V(0, 7.05, 0), c = C(250, 222, 125), j = "Head" })
	r:add({ s = "ball", sz = V(0.1, 0, 0), p = V(-0.18, 7.1, -0.44), c = C(30, 20, 10), j = "Head" })
	r:add({ s = "ball", sz = V(0.1, 0, 0), p = V(0.18, 7.1, -0.44), c = C(30, 20, 10), j = "Head" })
	r:add({ sz = V(0.18, 0.08, 0.05), p = V(0, 6.95, -0.45), c = C(220, 90, 90), j = "Head" })
	r:add({ s = "box", sz = V(0.06, 0.3, 0.06), p = V(0, 7.5, 0), c = LEAF3, j = "Head" })
	r:sym({ sz = V(0.34, 0.12, 0.2), p = V(-0.16, 7.65, 0), r = V(0, 0, 28), c = LEAF2, j = "Head" })
	-- green bow with a star on the back of the head
	r:sym({ sz = V(0.75, 0.55, 0.3), p = V(-0.42, 5.0, 0.95), r = V(0, 0, 15), c = LEAF2, j = "Head" })
	r:add({ s = "box", sz = V(0.32, 0.32, 0.1), p = V(0, 5.0, 1.08), r = V(0, 0, 45), c = C(255, 220, 70), m = NEON, j = "Head" })

	r:light("Body", CRACK, 0.8, 8)
	return r:finish("MagicTree", "cute")
end
