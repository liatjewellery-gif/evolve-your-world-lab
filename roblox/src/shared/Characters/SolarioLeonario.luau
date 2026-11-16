-- Solario Leonario (Secret): a blocky sandstone sun lion. Huge glowing golden crystal
-- mane, glowing eyes, metal headband with a big blue gem, sun emblems on its sides,
-- gold bands with blue gems on its legs, and a tail ending in a crystal flame.
local Rig = require(script.Parent.Parent.Rig)
local C, V = Color3.fromRGB, Vector3.new

local SAND = C(238, 208, 140)
local SAND2 = C(220, 185, 118)
local SAND3 = C(250, 225, 170)
local MANE = C(255, 170, 20)
local MANE2 = C(255, 215, 60)
local MANE3 = C(255, 135, 10)
local GOLD = C(240, 185, 40)
local GEM = C(60, 175, 255)
local NEON = Enum.Material.Neon
local GLASS = Enum.Material.Glass
local METAL = Enum.Material.Metal
local SAND_M = Enum.Material.Sandstone

local function gem(r, p: Vector3, j: string?, size: number?)
	local s = size or 0.3
	r:add({ s = "box", sz = V(s + 0.12, s + 0.12, 0.1), p = p, r = V(0, 0, 45), c = GOLD, m = METAL, j = j })
	r:add({ s = "box", sz = V(s, s, 0.12), p = p + V(0, 0, -0.03), r = V(0, 0, 45), c = GEM, m = NEON, j = j })
end

return function(): Model
	local r = Rig.new("SolarioLeonario", 2.6)
	r:symJoint("LegFL", V(-0.75, 2.45, -1.3))
	r:symJoint("LegBL", V(-0.75, 2.45, 1.6))
	r:joint("Head", V(0, 3.6, -1.9))
	r:joint("Mane", V(0, 4.0, -2.2), "Head")
	r:joint("Tail", V(0, 3.5, 2.25))

	-- blocky body with stone seams
	r:add({ s = "box", sz = V(2.2, 1.9, 4.0), p = V(0, 3.05, 0.2), c = SAND, m = SAND_M })
	for k = 0, 4 do
		r:sym({ s = "box", sz = V(0.05, 1.8, 0.05), p = V(-1.11, 3.05, -1.4 + k * 0.8), c = SAND2 })
	end
	r:sym({ s = "box", sz = V(0.05, 0.05, 3.9), p = V(-1.11, 3.4, 0.2), c = SAND2 })
	r:add({ s = "box", sz = V(1.9, 0.3, 3.7), p = V(0, 4.05, 0.2), c = SAND3, m = SAND_M })
	-- sun emblems on both sides
	r:sym({ s = "cyl", sz = V(1.0, 0.08, 1.0), p = V(-1.13, 3.05, 0.6), r = V(0, 0, 90), c = MANE2, m = NEON })
	for i = 1, 8 do
		local a = i / 8 * math.pi * 2
		r:sym({ s = "box", sz = V(0.06, 0.32, 0.12), p = V(-1.14, 3.05 + math.cos(a) * 0.68, 0.6 + math.sin(a) * 0.68), r = V(math.deg(a), 0, 0), c = MANE, m = NEON })
	end
	gem(r, V(-1.16, 3.6, -0.9))
	gem(r, V(1.16, 3.6, -0.9))

	-- four legs with paws, gold bands and blue gems
	for _, j in { "LegFL", "LegBL" } do
		local z = (j == "LegFL") and -1.3 or 1.6
		r:sym({ s = "box", sz = V(0.82, 1.7, 0.85), p = V(-0.75, 1.55, z), c = SAND, m = SAND_M, j = j })
		r:sym({ s = "box", sz = V(1.05, 0.55, 1.2), p = V(-0.75, 0.28, z - 0.15), c = SAND3, m = SAND_M, j = j })
		for k = -1, 1 do
			r:sym({ s = "box", sz = V(0.26, 0.3, 0.25), p = V(-0.75 + k * 0.32, 0.2, z - 0.82), c = SAND2, j = j })
		end
		r:sym({ s = "box", sz = V(0.92, 0.26, 0.95), p = V(-0.75, 1.0, z), c = GOLD, m = METAL, j = j })
		r:sym({ s = "box", sz = V(0.22, 0.22, 0.1), p = V(-0.75, 1.0, z - 0.5), r = V(0, 0, 45), c = GEM, m = NEON, j = j })
	end

	-- blocky head
	r:add({ s = "box", sz = V(1.6, 1.5, 1.4), p = V(0, 4.0, -2.45), c = SAND, m = SAND_M, j = "Head" })
	r:add({ s = "box", sz = V(0.95, 0.62, 0.62), p = V(0, 3.6, -3.15), c = SAND3, m = SAND_M, j = "Head" })
	r:add({ s = "box", sz = V(0.42, 0.24, 0.2), p = V(0, 3.86, -3.46), c = C(30, 20, 15), j = "Head" })
	r:add({ s = "box", sz = V(0.06, 0.25, 0.04), p = V(0, 3.62, -3.47), c = C(60, 40, 25), j = "Head" })
	r:add({ s = "box", sz = V(0.6, 0.05, 0.04), p = V(0, 3.48, -3.47), c = C(60, 40, 25), j = "Head" })
	r:sym({ s = "box", sz = V(0.42, 0.22, 0.1), p = V(-0.4, 4.25, -3.16), c = C(255, 230, 90), m = NEON, j = "Head" })
	r:sym({ s = "box", sz = V(0.45, 0.1, 0.12), p = V(-0.4, 4.42, -3.17), r = V(0, 0, -12), c = SAND2, j = "Head" })
	-- headband with a big blue gem
	r:add({ s = "box", sz = V(1.7, 0.3, 1.5), p = V(0, 4.6, -2.45), c = C(110, 105, 110), m = METAL, j = "Head" })
	gem(r, V(0, 4.62, -3.22), "Head", 0.38)

	-- huge crystal mane (spins slightly in the wind through the Gait module)
	local function shard(i: number, a: number, rad: number, z: number, len: number)
		local cols = { MANE, MANE2, MANE3 }
		return { s = "box", sz = V(0.5, len, 0.4), p = V(math.sin(a) * rad, 4.0 + math.cos(a) * rad, z), r = V(0, 0, -math.deg(a)), c = cols[(i % 3) + 1], m = (i % 2 == 0) and NEON or GLASS, t = (i % 2 == 0) and 0 or 0.05, j = "Mane" }
	end
	r:ring(16, function(i, a)
		return shard(i, a, 1.2, -2.0, 1.6)
	end)
	r:ring(13, function(i, a)
		return shard(i + 1, a + 0.2, 1.05, -1.55, 1.9)
	end)
	r:ring(10, function(i, a)
		return shard(i + 2, a + 0.1, 0.85, -1.15, 1.5)
	end)
	for k = -2, 2 do
		r:add({ s = "box", sz = V(0.4, 1.1, 0.35), p = V(k * 0.32, 2.75, -2.35), r = V(-10, 0, k * 10), c = (k % 2 == 0) and MANE2 or MANE, m = NEON, j = "Mane" })
	end

	-- tail with a crystal flame
	r:add({ s = "box", sz = V(0.36, 0.36, 0.95), p = V(0, 3.75, 2.75), r = V(-35, 0, 0), c = SAND, j = "Tail" })
	r:add({ s = "box", sz = V(0.34, 0.34, 0.9), p = V(0, 4.3, 3.15), r = V(-65, 0, 0), c = SAND, j = "Tail" })
	r:add({ s = "box", sz = V(0.5, 0.25, 0.5), p = V(0, 4.75, 3.32), c = GOLD, m = METAL, j = "Tail" })
	for k = 0, 4 do
		local a = k / 5 * math.pi * 2
		r:add({ s = "box", sz = V(0.28, 0.85, 0.28), p = V(math.sin(a) * 0.18, 5.15, 3.35 + math.cos(a) * 0.18), r = V(math.cos(a) * 20, 45, math.sin(a) * 20), c = (k % 2 == 0) and MANE2 or MANE, m = NEON, j = "Tail" })
	end
	r:add({ s = "box", sz = V(0.2, 0.2, 0.2), p = V(0, 4.78, 3.06), r = V(45, 0, 45), c = GEM, m = NEON, j = "Tail" })

	r:emitter("Mane", { Rate = 10, Lifetime = NumberRange.new(0.8, 1.5), Speed = NumberRange.new(1, 2.5), SpreadAngle = Vector2.new(180, 180), Size = NumberSequence.new(0.35, 0), Color = ColorSequence.new(MANE2, C(255, 255, 200)) })
	r:light("Mane", C(255, 200, 80), 2.5, 16)
	return r:finish("SolarioLeonario", "quad", 1.0)
end
