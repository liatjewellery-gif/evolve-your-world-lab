-- Zombino Rotolino (Epic): a blocky zombie. Cracked stone head covered in moss with red
-- mushrooms and leaf sprouts, green face with glowing yellow eyes and a toothy mouth
-- dripping slime, torn grey jacket with an orange tie and ribs showing, green blocky
-- arms, torn shorts with a bone sticking out, big muddy brown boots, flies buzzing around.
local Rig = require(script.Parent.Parent.Rig)
local C, V = Color3.fromRGB, Vector3.new

local ZGREEN = C(115, 195, 70)
local ZGREEN2 = C(90, 165, 55)
local STONE = C(155, 152, 145)
local MOSS = C(85, 145, 40)
local JACKET = C(72, 72, 78)
local TIE = C(235, 125, 30)
local BONE = C(240, 225, 190)
local BOOT = C(115, 72, 40)
local SLIME = C(140, 255, 60)
local NEON = Enum.Material.Neon
local SLATE = Enum.Material.Slate
local GRASS = Enum.Material.Grass

local function mushroom(r, p: Vector3, s: number)
	r:add({ s = "cyl", sz = V(0.18 * s, 0.35 * s, 0.18 * s), p = p, c = BONE, j = "Head" })
	r:add({ sz = V(0.62 * s, 0.38 * s, 0.62 * s), p = p + V(0, 0.22 * s, 0), c = C(220, 40, 40), j = "Head" })
	r:add({ s = "ball", sz = V(0.12 * s, 0, 0), p = p + V(0.12 * s, 0.38 * s, -0.08 * s), c = C(255, 255, 255), j = "Head" })
	r:add({ s = "ball", sz = V(0.1 * s, 0, 0), p = p + V(-0.14 * s, 0.34 * s, 0.1 * s), c = C(255, 255, 255), j = "Head" })
end

return function(): Model
	local r = Rig.new("ZombinoRotolino", 2.0)
	r:symJoint("LegL", V(-0.55, 1.85, 0))
	r:symJoint("ArmL", V(-1.35, 3.55, 0))
	r:joint("Head", V(0, 3.8, 0))
	r:joint("Flies", V(0, 4.8, 0))

	-- big muddy boots
	r:sym({ s = "box", sz = V(1.1, 0.75, 1.45), p = V(-0.55, 0.4, -0.15), c = BOOT, j = "LegL" })
	r:sym({ s = "box", sz = V(1.15, 0.2, 1.5), p = V(-0.55, 0.1, -0.15), c = C(70, 45, 25), j = "LegL" })
	r:sym({ s = "box", sz = V(1.15, 0.12, 0.5), p = V(-0.55, 0.65, 0.1), c = C(90, 58, 30), j = "LegL" })
	r:sym({ sz = V(0.5, 0.18, 0.4), p = V(-0.75, 0.75, -0.6), c = MOSS, m = GRASS, j = "LegL" })
	-- green legs, torn shorts, a bone
	r:sym({ s = "box", sz = V(0.75, 1.0, 0.75), p = V(-0.55, 1.25, 0), c = ZGREEN, j = "LegL" })
	r:sym({ s = "box", sz = V(0.98, 0.55, 0.98), p = V(-0.55, 1.75, 0), c = C(60, 60, 66), j = "LegL" })
	r:add({ s = "box", sz = V(0.22, 0.55, 0.22), p = V(-0.35, 1.2, -0.38), r = V(0, 0, 15), c = BONE, j = "LegL" })
	r:add({ s = "ball", sz = V(0.25, 0, 0), p = V(-0.28, 1.48, -0.4), c = BONE, j = "LegL" })
	r:add({ s = "box", sz = V(0.5, 0.35, 0.05), p = V(0.5, 1.15, -0.39), r = V(0, 0, 20), c = ZGREEN2, j = "LegR" })

	-- torn jacket, shirt, tie and ribs
	r:add({ s = "box", sz = V(2.0, 1.85, 1.1), p = V(0, 2.95, 0), c = JACKET })
	r:add({ s = "box", sz = V(0.85, 1.7, 0.05), p = V(0, 2.95, -0.56), c = C(200, 170, 110) })
	r:add({ s = "box", sz = V(0.3, 1.05, 0.06), p = V(0, 2.8, -0.6), c = TIE })
	r:add({ s = "box", sz = V(0.36, 0.25, 0.07), p = V(0, 3.45, -0.6), r = V(0, 0, 45), c = TIE })
	for k = 0, 2 do
		r:add({ s = "box", sz = V(0.55, 0.08, 0.06), p = V(0.45, 2.55 + k * 0.22, -0.6), c = BONE })
	end
	r:add({ s = "box", sz = V(0.4, 0.4, 0.05), p = V(-0.6, 2.45, -0.57), r = V(0, 0, 15), c = ZGREEN2 })
	r:add({ s = "box", sz = V(0.5, 0.5, 0.05), p = V(0.3, 3.0, 0.57), r = V(0, 0, 10), c = TIE })
	for k = 0, 3 do
		r:add({ s = "box", sz = V(0.3, 0.35, 0.05), p = V(-0.75 + k * 0.5, 2.06, -0.56), r = V(0, 0, 45), c = JACKET })
	end
	r:add({ sz = V(0.7, 0.3, 0.35), p = V(-0.75, 3.85, -0.2), c = MOSS, m = GRASS })
	r:add({ sz = V(0.5, 0.3, 0.3), p = V(0.8, 3.8, 0.3), c = MOSS, m = GRASS })

	-- arms reaching forward like a zombie (the Gait lifts them)
	r:sym({ s = "box", sz = V(0.88, 0.8, 0.88), p = V(-1.4, 3.3, 0), c = JACKET, j = "ArmL" })
	r:sym({ s = "box", sz = V(0.75, 1.3, 0.75), p = V(-1.4, 2.35, 0), c = ZGREEN, j = "ArmL" })
	r:sym({ s = "box", sz = V(0.85, 0.6, 0.85), p = V(-1.4, 1.45, 0), c = ZGREEN2, j = "ArmL" })
	for k = -1, 1 do
		r:sym({ s = "box", sz = V(0.18, 0.4, 0.18), p = V(-1.4 + k * 0.25, 1.05, -0.25), c = ZGREEN, j = "ArmL" })
	end

	-- head: cracked mossy stone on top, green face below
	r:add({ s = "box", sz = V(2.0, 1.75, 1.75), p = V(0, 4.8, 0), c = STONE, m = SLATE, j = "Head" })
	r:add({ s = "box", sz = V(1.9, 0.95, 0.1), p = V(0, 4.32, -0.88), c = ZGREEN, j = "Head" })
	r:sym({ s = "box", sz = V(0.1, 0.95, 1.6), p = V(-0.99, 4.3, 0), c = ZGREEN2, j = "Head" })
	r:sym({ s = "box", sz = V(0.62, 0.58, 0.08), p = V(-0.45, 4.72, -0.92), c = C(20, 25, 15), j = "Head" })
	r:sym({ s = "ball", sz = V(0.46, 0, 0), p = V(-0.45, 4.72, -0.92), c = C(255, 240, 60), m = NEON, j = "Head" })
	r:add({ s = "box", sz = V(1.15, 0.52, 0.08), p = V(0, 4.08, -0.93), c = C(60, 10, 15), j = "Head" })
	for k = -2, 2 do
		r:add({ s = "box", sz = V(0.15, 0.16, 0.05), p = V(k * 0.22, 4.27, -0.97), c = BONE, j = "Head" })
		r:add({ s = "box", sz = V(0.14, 0.13, 0.05), p = V(k * 0.22 + 0.1, 3.9, -0.97), c = BONE, j = "Head" })
	end
	r:add({ sz = V(0.15, 0.55, 0.12), p = V(-0.4, 3.75, -0.95), c = SLIME, m = NEON, j = "Head" })
	r:add({ sz = V(0.12, 0.4, 0.1), p = V(0.35, 3.8, -0.95), c = SLIME, m = NEON, j = "Head" })
	r:add({ sz = V(0.12, 0.35, 0.1), p = V(-0.8, 3.95, -0.92), c = SLIME, m = NEON, j = "Head" })
	-- stitches and cracks
	r:add({ s = "box", sz = V(0.06, 0.6, 0.04), p = V(0.6, 5.35, -0.89), r = V(0, 0, 10), c = C(120, 30, 30), j = "Head" })
	for k = 0, 2 do
		r:add({ s = "box", sz = V(0.22, 0.05, 0.04), p = V(0.6, 5.15 + k * 0.18, -0.9), c = C(120, 30, 30), j = "Head" })
	end
	r:add({ s = "box", sz = V(0.05, 0.5, 0.04), p = V(-0.5, 5.4, -0.89), r = V(0, 0, -30), c = C(100, 98, 92), j = "Head" })
	-- moss, mushrooms and sprouts on top
	r:add({ s = "box", sz = V(1.3, 0.2, 1.0), p = V(-0.25, 5.72, -0.2), c = MOSS, m = GRASS, j = "Head" })
	r:add({ s = "box", sz = V(0.8, 0.18, 0.9), p = V(0.5, 5.7, 0.45), c = MOSS, m = GRASS, j = "Head" })
	r:add({ s = "box", sz = V(0.7, 0.5, 0.12), p = V(-0.65, 5.3, -0.88), c = MOSS, m = GRASS, j = "Head" })
	mushroom(r, V(0.55, 5.9, -0.3), 1.2)
	mushroom(r, V(-0.75, 5.85, 0.4), 0.9)
	mushroom(r, V(1.0, 4.9, 0.3), 0.8)
	r:add({ s = "box", sz = V(0.06, 0.4, 0.06), p = V(0, 5.95, 0.2), c = MOSS, j = "Head" })
	r:sym({ sz = V(0.4, 0.12, 0.25), p = V(-0.18, 6.15, 0.2), r = V(0, 0, 30), c = C(130, 210, 60), j = "Head" })

	-- buzzing flies (spin around the head)
	for k = 0, 4 do
		local a = k / 5 * math.pi * 2
		r:add({ s = "ball", sz = V(0.16, 0, 0), p = V(math.cos(a) * 1.7, 4.6 + (k % 3) * 0.35, math.sin(a) * 1.7), c = C(20, 20, 20), j = "Flies" })
		r:add({ sz = V(0.18, 0.04, 0.1), p = V(math.cos(a) * 1.7, 4.7 + (k % 3) * 0.35, math.sin(a) * 1.7), c = C(220, 230, 255), t = 0.4, j = "Flies" })
	end

	r:emitter("Head", { Rate = 2, Lifetime = NumberRange.new(0.6, 0.9), Speed = NumberRange.new(0.5, 1), Acceleration = Vector3.new(0, -8, 0), Size = NumberSequence.new(0.18, 0.05), Color = ColorSequence.new(SLIME), EmissionDirection = Enum.NormalId.Front })
	r:light("Head", SLIME, 0.7, 8)
	return r:finish("ZombinoRotolino", "limp")
end
