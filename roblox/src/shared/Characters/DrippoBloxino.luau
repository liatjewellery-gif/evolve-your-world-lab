-- Drippo Bloxino (Super Rare): a stylish blocky boy. Messy brown hair, white sunglasses
-- on his head, a little silver crown, white headphones with blue stars, blue eyes and a
-- cheeky smile with a band-aid, black-and-white jacket over a blue crown shirt, silver
-- chains, black cargo pants, blue-white sneakers - and his phone, always in his hand.
local Rig = require(script.Parent.Parent.Rig)
local C, V = Color3.fromRGB, Vector3.new

local SKIN = C(250, 205, 160)
local HAIR = C(110, 65, 35)
local HAIR2 = C(135, 82, 45)
local BLACK = C(28, 28, 34)
local GREY = C(215, 218, 225)
local BLUE = C(40, 95, 225)
local WHITE = C(250, 250, 255)
local SILVER = C(200, 205, 215)
local NEON = Enum.Material.Neon
local METAL = Enum.Material.Metal

return function(): Model
	local r = Rig.new("DrippoBloxino", 2.0)
	r:symJoint("LegL", V(-0.5, 2.0, 0))
	r:symJoint("ArmL", V(-1.45, 3.8, 0))
	r:joint("Head", V(0, 4.0, 0))

	-- sneakers
	r:sym({ s = "box", sz = V(1.02, 0.55, 1.45), p = V(-0.5, 0.32, -0.15), c = WHITE, j = "LegL" })
	r:sym({ s = "box", sz = V(1.06, 0.18, 1.5), p = V(-0.5, 0.09, -0.15), c = GREY, j = "LegL" })
	r:sym({ s = "box", sz = V(1.04, 0.3, 0.7), p = V(-0.5, 0.45, 0.2), c = C(25, 40, 110), j = "LegL" })
	r:sym({ s = "box", sz = V(0.3, 0.3, 0.06), p = V(-0.5, 0.45, -0.88), r = V(0, 0, 45), c = BLUE, m = NEON, j = "LegL" })
	-- cargo pants
	r:sym({ s = "box", sz = V(0.95, 1.55, 1.0), p = V(-0.5, 1.33, 0), c = BLACK, j = "LegL" })
	r:sym({ s = "box", sz = V(0.18, 0.55, 0.6), p = V(-1.03, 1.25, 0), c = C(45, 45, 55), j = "LegL" })
	r:sym({ s = "box", sz = V(0.06, 1.2, 0.08), p = V(-0.98, 1.4, -0.35), c = BLUE, j = "LegL" })
	-- chain on the pants
	for k = 0, 5 do
		r:add({ s = "ball", sz = V(0.12, 0, 0), p = V(-0.9 + k * 0.05, 1.85 - k * 0.12, -0.55), c = SILVER, m = METAL, j = "LegL" })
	end

	-- torso: blue shirt with a crown, black-white open jacket, hood
	r:add({ s = "box", sz = V(2.0, 2.0, 1.0), p = V(0, 3.0, 0), c = BLUE })
	r:add({ s = "box", sz = V(0.65, 0.3, 0.05), p = V(0, 3.15, -0.52), c = WHITE })
	for k = -1, 1 do
		r:add({ s = "box", sz = V(0.15, 0.22, 0.05), p = V(k * 0.24, 3.38, -0.52), c = WHITE })
	end
	r:sym({ s = "box", sz = V(0.62, 2.0, 1.06), p = V(-0.7, 3.0, 0), c = BLACK })
	r:sym({ s = "box", sz = V(0.06, 1.9, 0.08), p = V(-0.38, 3.0, -0.54), c = WHITE })
	r:add({ s = "box", sz = V(0.4, 0.4, 0.05), p = V(-0.72, 3.4, -0.54), c = WHITE })
	r:add({ s = "box", sz = V(0.12, 0.45, 0.05), p = V(0.75, 3.2, -0.54), r = V(0, 0, 25), c = WHITE })
	r:add({ s = "box", sz = V(2.06, 0.28, 1.08), p = V(0, 2.1, 0), c = BLUE })
	r:add({ s = "box", sz = V(2.08, 0.08, 1.1), p = V(0, 2.1, 0), c = WHITE })
	r:add({ sz = V(2.05, 0.75, 1.3), p = V(0, 4.05, 0.32), c = GREY })
	r:add({ s = "box", sz = V(0.9, 0.06, 0.06), p = V(0, 3.95, -0.45), c = SILVER, m = METAL })
	for i = -4, 4 do
		local x = i * 0.1
		r:add({ s = "ball", sz = V(0.1, 0, 0), p = V(x, 3.6 + x * x * 1.2, -0.55), c = SILVER, m = METAL })
	end
	r:add({ s = "box", sz = V(0.18, 0.22, 0.05), p = V(0, 3.45, -0.57), c = SILVER, m = METAL })
	-- crossbody bag on the back
	r:add({ s = "box", sz = V(1.0, 0.6, 0.35), p = V(0, 2.65, 0.65), c = BLACK })
	r:add({ s = "box", sz = V(0.12, 2.2, 0.06), p = V(0, 3.1, 0.53), r = V(0, 0, 40), c = BLACK })

	-- arms: white short sleeves, skin, bracelet and a phone in the right hand
	r:sym({ s = "box", sz = V(1.0, 0.9, 1.05), p = V(-1.5, 3.45, 0), c = GREY, j = "ArmL" })
	r:sym({ s = "box", sz = V(0.25, 0.4, 0.06), p = V(-1.5, 3.5, -0.54), r = V(0, 0, 20), c = BLACK, j = "ArmL" })
	r:sym({ s = "box", sz = V(0.9, 1.25, 0.9), p = V(-1.5, 2.4, 0), c = SKIN, j = "ArmL" })
	r:add({ s = "box", sz = V(0.95, 0.2, 0.95), p = V(-1.5, 2.15, 0), c = SILVER, m = METAL, j = "ArmL" })
	r:add({ s = "box", sz = V(0.95, 0.22, 0.95), p = V(1.5, 2.15, 0), c = BLACK, j = "ArmR" })
	r:add({ s = "box", sz = V(0.55, 0.1, 0.9), p = V(1.5, 1.72, -0.3), c = BLACK, j = "ArmR" })
	r:add({ s = "box", sz = V(0.47, 0.02, 0.78), p = V(1.5, 1.78, -0.3), c = C(90, 180, 255), m = NEON, j = "ArmR" })

	-- head
	r:add({ s = "box", sz = V(1.7, 1.6, 1.5), p = V(0, 4.85, 0), c = SKIN, j = "Head" })
	r:eye(V(-0.38, 4.85, -0.74), 0.48, C(40, 110, 230), "Head", { tall = 1.3 })
	r:eye(V(0.38, 4.85, -0.74), 0.48, C(40, 110, 230), "Head", { tall = 1.3 })
	r:add({ sz = V(0.5, 0.25, 0.08), p = V(0, 4.38, -0.76), c = C(120, 30, 40), j = "Head" })
	r:add({ s = "box", sz = V(0.08, 0.1, 0.04), p = V(0.12, 4.46, -0.8), c = WHITE, j = "Head" })
	r:sym({ sz = V(0.3, 0.18, 0.06), p = V(-0.62, 4.5, -0.75), c = C(255, 150, 140), j = "Head" })
	r:add({ s = "box", sz = V(0.38, 0.14, 0.04), p = V(-0.6, 4.55, -0.77), r = V(0, 0, 30), c = C(235, 200, 160), j = "Head" })
	-- messy spiky hair
	r:add({ s = "box", sz = V(1.85, 0.55, 1.65), p = V(0, 5.72, 0.02), c = HAIR, j = "Head" })
	local rng = Random.new(4)
	for i = 1, 16 do
		local a = (i / 16) * math.pi * 2
		r:add({ sz = V(0.7, 0.55, 0.85), p = V(math.sin(a) * 0.8, 5.9 + rng:NextNumber(0, 0.35), math.cos(a) * 0.72), r = V(rng:NextNumber(-30, 30), math.deg(a), rng:NextNumber(-30, 30)), c = (i % 2 == 0) and HAIR or HAIR2, j = "Head" })
	end
	for k = -2, 2 do
		r:add({ sz = V(0.45, 0.6, 0.35), p = V(k * 0.35, 5.45, -0.72), r = V(25, 0, k * -12), c = (k % 2 == 0) and HAIR2 or HAIR, j = "Head" })
	end
	r:add({ sz = V(1.7, 1.0, 0.6), p = V(0, 5.2, 0.7), c = HAIR, j = "Head" })
	-- white sunglasses pushed up
	r:add({ s = "box", sz = V(1.7, 0.36, 0.12), p = V(0, 5.88, -0.78), c = WHITE, j = "Head" })
	r:sym({ s = "box", sz = V(0.6, 0.26, 0.06), p = V(-0.4, 5.88, -0.85), c = C(20, 20, 25), j = "Head" })
	-- small silver crown
	r:add({ s = "cyl", sz = V(0.65, 0.22, 0.65), p = V(-0.45, 6.3, 0.05), r = V(0, 0, 15), c = SILVER, m = METAL, j = "Head" })
	r:ring(4, function(i, a)
		return { s = "ball", sz = V(0.14, 0, 0), p = V(-0.45 + math.sin(a) * 0.3, 6.5, 0.05 + math.cos(a) * 0.3), c = SILVER, m = METAL, j = "Head" }
	end)
	-- headphones with blue stars
	r:add({ s = "box", sz = V(0.25, 0.25, 0.4), p = V(0, 6.2, -0.05), c = WHITE, j = "Head" })
	r:sym({ s = "box", sz = V(0.25, 0.9, 0.4), p = V(-0.95, 5.8, -0.05), r = V(0, 0, -20), c = WHITE, j = "Head" })
	r:sym({ s = "cyl", sz = V(0.95, 0.35, 0.95), p = V(-0.98, 4.85, 0), r = V(0, 0, 90), c = WHITE, j = "Head" })
	r:sym({ s = "box", sz = V(0.3, 0.3, 0.05), p = V(-1.17, 4.85, 0), r = V(0, 90, 45), c = BLUE, m = NEON, j = "Head" })
	r:sym({ s = "box", sz = V(0.3, 0.3, 0.05), p = V(-1.17, 4.85, 0), r = V(0, 90, 0), c = BLUE, m = NEON, j = "Head" })
	-- star clip in the hair
	r:add({ s = "box", sz = V(0.28, 0.28, 0.06), p = V(0.65, 5.5, -0.78), r = V(0, 0, 45), c = BLUE, m = NEON, j = "Head" })

	r:emitter("Body", { Rate = 3, Lifetime = NumberRange.new(0.8, 1.2), Speed = NumberRange.new(0.3, 0.8), SpreadAngle = Vector2.new(180, 180), Size = NumberSequence.new(0.25, 0), Color = ColorSequence.new(C(120, 170, 255)) })
	r:light("Body", C(90, 150, 255), 0.6, 8)
	return r:finish("DrippoBloxino", "phone")
end
