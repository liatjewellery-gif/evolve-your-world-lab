-- Galaxy Dragon (Secret): a blocky deep-purple dragon full of glowing galaxy patches and
-- stars, pale belly plates, glowing cyan eyes, crystal horns and back spikes, cyan
-- claws, big galaxy wings, and a crystal tail tip. It breathes fire.
local Rig = require(script.Parent.Parent.Rig)
local C, V = Color3.fromRGB, Vector3.new

local SCALE = C(72, 36, 135)
local SCALE2 = C(100, 48, 175)
local BELLY = C(205, 175, 225)
local PINK = C(255, 95, 225)
local BLUE = C(95, 155, 255)
local CYAN = C(95, 235, 255)
local HORN = C(195, 95, 255)
local MEMBRANE = C(170, 70, 235)
local NEON = Enum.Material.Neon
local GLASS = Enum.Material.Glass

local function crystal(r, p: Vector3, len: number, tilt: Vector3, j: string?, k: number)
	r:add({ s = "box", sz = V(0.42, len, 0.42), p = p, r = tilt + V(0, 45, 0), c = (k % 2 == 0) and HORN or PINK, m = (k % 3 == 0) and GLASS or NEON, t = (k % 3 == 0) and 0.05 or 0, j = j })
end

local function galaxyDots(r, center: Vector3, half: Vector3, count: number, seed: number, j: string?)
	local rng = Random.new(seed)
	local cols = { PINK, BLUE, C(255, 255, 255), CYAN }
	for i = 1, count do
		local side = rng:NextInteger(1, 3)
		local p = center + V(rng:NextNumber(-1, 1) * half.X, rng:NextNumber(-1, 1) * half.Y, rng:NextNumber(-1, 1) * half.Z)
		if side == 1 then
			p = V(center.X + half.X * (rng:NextNumber() < 0.5 and -1 or 1), p.Y, p.Z)
		elseif side == 2 then
			p = V(p.X, center.Y + half.Y, p.Z)
		end
		local s = rng:NextNumber(0.12, 0.35)
		r:add({ s = "box", sz = V(s, s, s), p = p, r = V(45, 45, 0), c = cols[(i % #cols) + 1], m = NEON, t = (i % 4 == 0) and 0.3 or 0, j = j })
	end
end

local function wing(r, j: string, side: number)
	-- side = -1 for left, +1 for right
	local base = V(side * 1.15, 4.35, -0.6)
	local spars = { { 150, 4.4 }, { 172, 4.0 }, { 195, 3.4 } }
	for k, s in spars do
		local ang = math.rad(s[1])
		local dir = V(math.cos(ang) * -side, math.sin(ang), 0)
		-- mirror so both wings spread outward
		dir = V(side * math.abs(dir.X), dir.Y, 0)
		local len = s[2]
		local mid = base + dir * (len / 2)
		local rz = math.deg(math.atan2(dir.Y, dir.X))
		r:add({ s = "box", sz = V(len, 0.24, 0.24), p = mid, r = V(0, 0, rz), c = SCALE, j = j })
		r:add({ s = "box", sz = V(0.3, 0.3, 0.3), p = base + dir * len, r = V(45, 0, 45), c = CYAN, m = NEON, j = j })
		-- membrane panel hanging below each spar
		local down = V(-dir.Y * side * -1, -math.abs(dir.X), 0).Unit
		local panelMid = mid + down * 0.75 + V(0, 0, 0.05)
		r:add({ s = "box", sz = V(len * 0.92, 1.5, 0.08), p = panelMid, r = V(0, 0, rz), c = MEMBRANE, m = NEON, t = 0.3, j = j })
		local rng = Random.new(30 + k + (side > 0 and 10 or 0))
		for _ = 1, 6 do
			local f = rng:NextNumber(0.15, 0.85)
			local o = rng:NextNumber(-0.5, 0.5)
			local p = base + dir * (len * f) + down * (0.75 + o)
			r:add({ s = "ball", sz = V(rng:NextNumber(0.08, 0.18), 0, 0), p = p + V(0, 0, -0.06), c = (rng:NextNumber() < 0.5) and C(255, 255, 255) or PINK, m = NEON, j = j })
		end
	end
	r:add({ sz = V(1.6, 0.6, 0.12), p = base + V(side * 1.2, -0.9, -0.02), c = C(255, 140, 235), m = NEON, t = 0.55, j = j })
end

return function(): Model
	local r = Rig.new("GalaxyDragon", 2.8)
	r:symJoint("LegFL", V(-0.85, 2.6, -1.4))
	r:symJoint("LegBL", V(-0.85, 2.6, 1.7))
	r:joint("Neck", V(0, 3.9, -1.9))
	r:joint("Head", V(0, 5.1, -2.85), "Neck")
	r:joint("Tail", V(0, 3.4, 2.4))
	r:joint("WingL", V(-1.15, 4.35, -0.6))
	r:joint("WingR", V(1.15, 4.35, -0.6))

	-- body
	r:add({ s = "box", sz = V(2.4, 2.1, 4.4), p = V(0, 3.3, 0.2), c = SCALE })
	r:add({ s = "box", sz = V(2.0, 0.4, 4.0), p = V(0, 4.4, 0.2), c = SCALE2 })
	galaxyDots(r, V(0, 3.3, 0.2), V(1.21, 1.05, 2.1), 40, 1)
	for k = 0, 5 do
		r:add({ s = "box", sz = V(1.5, 0.32, 0.3), p = V(0, 2.4 + k * 0.32, -2.0), c = BELLY })
	end
	r:add({ s = "box", sz = V(1.6, 0.3, 3.4), p = V(0, 2.22, 0.3), c = BELLY })
	for k = 0, 8 do
		crystal(r, V(0, 4.85 + (k % 2) * 0.15, -1.6 + k * 0.48), 1.05 - math.abs(k - 3) * 0.08, V(-25, 0, 0), nil, k)
	end

	-- legs with armour plates, cyan gems and claws
	for _, j in { "LegFL", "LegBL" } do
		local z = (j == "LegFL") and -1.4 or 1.7
		r:sym({ s = "box", sz = V(1.05, 1.95, 1.05), p = V(-0.85, 1.6, z), c = SCALE, j = j })
		r:sym({ s = "box", sz = V(1.15, 1.1, 1.15), p = V(-0.95, 2.4, z), r = V(0, 0, 0), c = SCALE2, j = j })
		r:sym({ s = "box", sz = V(0.32, 0.32, 0.08), p = V(-1.54, 2.4, z), r = V(0, 90, 45), c = CYAN, m = NEON, j = j })
		r:sym({ s = "box", sz = V(1.25, 0.55, 1.35), p = V(-0.85, 0.28, z - 0.1), c = SCALE2, j = j })
		for k = -1, 1 do
			r:sym({ s = "box", sz = V(0.2, 0.45, 0.2), p = V(-0.85 + k * 0.38, 0.25, z - 0.88), r = V(-35, 45, 0), c = CYAN, m = NEON, j = j })
		end
	end

	-- neck and head
	r:add({ s = "box", sz = V(1.25, 1.7, 1.25), p = V(0, 4.5, -2.35), r = V(25, 0, 0), c = SCALE, j = "Neck" })
	for k = 0, 3 do
		r:add({ s = "box", sz = V(0.9, 0.28, 0.2), p = V(0, 3.9 + k * 0.32, -2.85 - k * 0.12), r = V(25, 0, 0), c = BELLY, j = "Neck" })
	end
	r:add({ s = "box", sz = V(1.65, 1.35, 1.8), p = V(0, 5.4, -3.3), c = SCALE, j = "Head" })
	r:add({ s = "box", sz = V(1.15, 0.8, 1.25), p = V(0, 5.2, -4.35), c = SCALE2, j = "Head" })
	r:add({ s = "box", sz = V(1.05, 0.32, 1.15), p = V(0, 4.62, -4.2), r = V(12, 0, 0), c = SCALE, j = "Head" })
	r:add({ s = "box", sz = V(0.95, 0.28, 1.05), p = V(0, 4.85, -4.2), c = C(170, 25, 50), j = "Head" })
	for k = -2, 2 do
		r:add({ s = "box", sz = V(0.12, 0.2, 0.12), p = V(k * 0.2, 4.7, -4.85), c = C(255, 255, 250), j = "Head" })
	end
	r:sym({ s = "box", sz = V(0.12, 0.22, 0.12), p = V(-0.45, 4.95, -4.95), c = C(255, 255, 250), j = "Head" })
	r:sym({ s = "box", sz = V(0.1, 0.1, 0.06), p = V(-0.25, 5.45, -5.0), c = C(20, 10, 30), j = "Head" })
	r:sym({ s = "box", sz = V(0.45, 0.24, 0.12), p = V(-0.55, 5.72, -4.02), r = V(0, -20, -12), c = CYAN, m = NEON, j = "Head" })
	r:sym({ s = "box", sz = V(0.55, 0.12, 0.14), p = V(-0.55, 5.92, -4.0), r = V(0, -20, -20), c = SCALE2, j = "Head" })
	galaxyDots(r, V(0, 5.4, -3.2), V(0.83, 0.68, 0.7), 10, 2, "Head")
	-- crystal horns and crest
	r:sym({ s = "box", sz = V(0.32, 1.3, 0.32), p = V(-0.5, 6.4, -2.95), r = V(35, 45, -15), c = HORN, m = NEON, j = "Head" })
	r:sym({ s = "box", sz = V(0.24, 0.85, 0.24), p = V(-0.75, 6.1, -2.5), r = V(45, 45, -30), c = PINK, m = NEON, j = "Head" })
	r:sym({ s = "box", sz = V(0.22, 0.6, 0.22), p = V(-0.85, 5.6, -2.6), r = V(0, 45, -70), c = HORN, m = GLASS, j = "Head" })
	for k = 0, 2 do
		crystal(r, V(0, 6.2 - k * 0.1, -3.5 + k * 0.4), 0.6, V(-20, 0, 0), "Head", k)
	end
	-- fire breath from the mouth
	local mouth = Instance.new("Attachment")
	mouth.Name = "Mouth"
	mouth.Parent = r.joints.Head
	mouth.WorldPosition = V(0, 4.85, -4.9)
	local breath = Instance.new("ParticleEmitter")
	breath.Name = "Breath"
	breath.Texture = Rig.TEX.fire
	breath.Rate = 0
	breath.LightEmission = 1
	breath.EmissionDirection = Enum.NormalId.Front
	breath.Speed = NumberRange.new(14, 20)
	breath.SpreadAngle = Vector2.new(14, 14)
	breath.Lifetime = NumberRange.new(0.5, 0.8)
	breath.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 3) })
	breath.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })
	breath.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, C(255, 230, 120)), ColorSequenceKeypoint.new(0.4, C(255, 110, 220)), ColorSequenceKeypoint.new(1, C(120, 60, 255)) })
	breath.Parent = mouth

	-- wings
	wing(r, "WingL", -1)
	wing(r, "WingR", 1)

	-- tail with a crystal tip
	r:add({ s = "box", sz = V(1.2, 1.1, 1.3), p = V(0, 3.2, 2.95), r = V(-8, 0, 0), c = SCALE, j = "Tail" })
	r:add({ s = "box", sz = V(0.9, 0.85, 1.2), p = V(0, 2.95, 3.95), r = V(-4, 0, 0), c = SCALE2, j = "Tail" })
	r:add({ s = "box", sz = V(0.65, 0.6, 1.1), p = V(0, 2.8, 4.85), c = SCALE, j = "Tail" })
	for k = 0, 3 do
		crystal(r, V(0, 3.8 - k * 0.25, 2.9 + k * 0.7), 0.7 - k * 0.08, V(-30, 0, 0), "Tail", k)
	end
	for k = 0, 4 do
		local a = k / 5 * math.pi * 2
		crystal(r, V(math.sin(a) * 0.2, 2.8 + math.cos(a) * 0.2, 5.55), 0.9, V(-90 + math.cos(a) * 25, 0, math.sin(a) * 25), "Tail", k)
	end

	r:emitter("Body", { Rate = 10, Lifetime = NumberRange.new(1, 2), Speed = NumberRange.new(0.5, 1.5), SpreadAngle = Vector2.new(180, 180), Size = NumberSequence.new(0.3, 0), Color = ColorSequence.new(PINK, BLUE) })
	r:light("Body", C(170, 90, 255), 2, 14)
	return r:finish("GalaxyDragon", "dragon")
end
