-- Frosty Fangolini (Secret): a blocky white saber-tooth ice tiger with blue stripes,
-- glowing ice-crystal spikes along its back, glowing blue eyes, huge saber fangs, ice
-- claws, and a tail ending in an ice crystal. Snowflakes swirl around it.
local Rig = require(script.Parent.Parent.Rig)
local C, V = Color3.fromRGB, Vector3.new

local FUR = C(236, 242, 252)
local FUR2 = C(215, 225, 242)
local STRIPE = C(40, 95, 225)
local ICE = C(120, 215, 255)
local ICE2 = C(180, 240, 255)
local NEON = Enum.Material.Neon
local GLASS = Enum.Material.Glass

local function shard(r, p: Vector3, len: number, tilt: Vector3, j: string?, k: number)
	r:add({ s = "box", sz = V(0.45, len, 0.45), p = p, r = tilt + V(0, 45, 0), c = (k % 2 == 0) and ICE or ICE2, m = (k % 3 == 0) and NEON or GLASS, t = (k % 3 == 0) and 0 or 0.08, j = j })
end

return function(): Model
	local r = Rig.new("FrostyFangolini", 2.5)
	r:symJoint("LegFL", V(-0.8, 2.4, -1.35))
	r:symJoint("LegBL", V(-0.8, 2.4, 1.65))
	r:joint("Head", V(0, 3.5, -2.0))
	r:joint("Tail", V(0, 3.35, 2.3))

	-- body
	r:add({ s = "box", sz = V(2.2, 1.9, 4.2), p = V(0, 3.0, 0.2), c = FUR })
	r:add({ s = "box", sz = V(1.8, 0.45, 3.9), p = V(0, 2.1, 0.2), c = FUR2 })
	r:add({ s = "box", sz = V(2.3, 1.7, 0.9), p = V(0, 3.1, -1.6), c = FUR })
	-- blue stripes
	for k = 0, 6 do
		local z = -1.4 + k * 0.55
		r:sym({ s = "box", sz = V(0.06, 1.15, 0.22), p = V(-1.12, 3.15, z), r = V(18 * ((k % 2 == 0) and 1 or -1), 0, 0), c = STRIPE })
		r:add({ s = "box", sz = V(1.4, 0.06, 0.2), p = V(0, 3.96, z + 0.2), c = STRIPE })
	end
	-- ice spikes along the back
	for k = 0, 8 do
		local z = -1.9 + k * 0.5
		local len = 1.3 - math.abs(k - 3) * 0.12
		shard(r, V(0, 4.3 + len * 0.3, z), len, V(-20, 0, 0), nil, k)
		if k % 2 == 1 then
			shard(r, V(-0.5, 4.15, z), len * 0.6, V(-15, 0, 25), nil, k + 1)
			shard(r, V(0.5, 4.15, z), len * 0.6, V(-15, 0, -25), nil, k + 1)
		end
	end

	-- legs with ice claws
	for _, j in { "LegFL", "LegBL" } do
		local z = (j == "LegFL") and -1.35 or 1.65
		r:sym({ s = "box", sz = V(0.88, 1.75, 0.95), p = V(-0.8, 1.55, z), c = FUR, j = j })
		r:sym({ s = "box", sz = V(0.9, 0.08, 0.4), p = V(-0.8, 1.8, z - 0.2), r = V(20, 0, 0), c = STRIPE, j = j })
		r:sym({ s = "box", sz = V(1.1, 0.55, 1.25), p = V(-0.8, 0.28, z - 0.1), c = FUR2, j = j })
		for k = -1, 1 do
			r:sym({ s = "box", sz = V(0.18, 0.4, 0.18), p = V(-0.8 + k * 0.33, 0.25, z - 0.82), r = V(-35, 45, 0), c = ICE, m = NEON, j = j })
		end
	end

	-- head with saber fangs
	r:add({ s = "box", sz = V(1.75, 1.55, 1.55), p = V(0, 3.9, -2.5), c = FUR, j = "Head" })
	r:add({ s = "box", sz = V(1.05, 0.7, 0.75), p = V(0, 3.45, -3.25), c = FUR2, j = "Head" })
	r:add({ s = "box", sz = V(0.45, 0.28, 0.2), p = V(0, 3.75, -3.63), c = C(25, 25, 35), j = "Head" })
	r:add({ s = "box", sz = V(0.85, 0.42, 0.35), p = V(0, 3.0, -3.2), c = C(170, 25, 40), j = "Head" })
	r:add({ s = "box", sz = V(0.8, 0.15, 0.4), p = V(0, 2.75, -3.15), c = FUR2, j = "Head" })
	r:sym({ sz = V(0.22, 1.0, 0.22), p = V(-0.32, 2.8, -3.38), r = V(-8, 0, 5), c = C(250, 250, 245), j = "Head" })
	r:sym({ s = "box", sz = V(0.12, 0.2, 0.1), p = V(-0.12, 3.12, -3.4), c = C(250, 250, 245), j = "Head" })
	r:sym({ s = "box", sz = V(0.4, 0.2, 0.1), p = V(-0.42, 4.15, -3.29), r = V(0, 0, -15), c = ICE, m = NEON, j = "Head" })
	r:sym({ s = "box", sz = V(0.5, 0.08, 0.06), p = V(-0.45, 4.35, -3.3), r = V(0, 0, -20), c = STRIPE, j = "Head" })
	r:sym({ s = "box", sz = V(0.06, 0.45, 0.1), p = V(-0.7, 3.95, -3.29), r = V(0, 0, 25), c = STRIPE, j = "Head" })
	r:add({ s = "box", sz = V(0.12, 0.5, 0.08), p = V(0, 4.4, -3.29), c = STRIPE, j = "Head" })
	r:sym({ s = "box", sz = V(0.42, 0.48, 0.28), p = V(-0.68, 4.8, -2.4), c = FUR, j = "Head" })
	r:sym({ s = "box", sz = V(0.3, 0.2, 0.3), p = V(-0.68, 5.05, -2.4), c = STRIPE, j = "Head" })
	for k = -1, 1 do
		shard(r, V(k * 0.35, 4.95, -2.3), 0.7 - math.abs(k) * 0.2, V(-20, 0, k * -20), "Head", k + 2)
	end

	-- tail with an ice crystal tip
	r:add({ s = "box", sz = V(0.4, 0.4, 1.0), p = V(0, 3.45, 2.9), r = V(-20, 0, 0), c = FUR, j = "Tail" })
	r:add({ s = "box", sz = V(0.36, 0.36, 0.9), p = V(0, 3.95, 3.45), r = V(-50, 0, 0), c = FUR, j = "Tail" })
	r:add({ s = "box", sz = V(0.42, 0.08, 0.42), p = V(0, 3.65, 3.1), r = V(-20, 0, 0), c = STRIPE, j = "Tail" })
	for k = 0, 4 do
		local a = k / 5 * math.pi * 2
		shard(r, V(math.sin(a) * 0.15, 4.55, 3.75 + math.cos(a) * 0.15), 0.8, V(math.cos(a) * 25, 0, math.sin(a) * 25), "Tail", k)
	end

	-- swirling snowflakes
	r:emitter("Body", { Rate = 18, Lifetime = NumberRange.new(1.5, 2.5), Speed = NumberRange.new(0.5, 2), SpreadAngle = Vector2.new(180, 180), Acceleration = Vector3.new(0, -1.5, 0), RotSpeed = NumberRange.new(-90, 90), Size = NumberSequence.new(0.35, 0.1), Color = ColorSequence.new(C(255, 255, 255), ICE) })
	r:light("Body", ICE, 1.5, 12)
	return r:finish("FrostyFangolini", "quad")
end
