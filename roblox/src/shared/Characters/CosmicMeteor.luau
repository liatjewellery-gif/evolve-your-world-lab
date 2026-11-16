-- Cosmic Meteor (Epic): a round rocky meteor with craters, glowing orange-purple galaxy
-- cracks, little golden stars, big purple eyes with sparkles, a fierce little grin with
-- fangs, stubby arms and legs, and purple-orange flames blazing off the top.
local Rig = require(script.Parent.Parent.Rig)
local C, V = Color3.fromRGB, Vector3.new

local ROCK = C(72, 64, 82)
local ROCK2 = C(55, 48, 64)
local GALAXY = C(165, 70, 255)
local GALAXY2 = C(90, 120, 255)
local CRACK = C(255, 140, 40)
local STAR = C(255, 215, 70)
local NEON = Enum.Material.Neon
local SLATE = Enum.Material.Slate

local CENTER = V(0, 2.65, 0)
local RAD = 1.5

-- point on the ball surface, and a rotation that faces outward
local function onBall(dir: Vector3, out: number): (Vector3, Vector3)
	dir = dir.Unit
	local p = CENTER + dir * (RAD + out)
	local rx = -math.deg(math.asin(dir.Y))
	local ry = math.deg(math.atan2(dir.X, dir.Z))
	return p, V(rx, ry, 0)
end

local function avoidFace(dir: Vector3): boolean
	-- keep the front (where the face is) clean
	return dir.Unit.Z < -0.55 and math.abs(dir.Unit.Y) < 0.6
end

return function(): Model
	local r = Rig.new("CosmicMeteor", 1.9)
	r:symJoint("LegL", V(-0.6, 1.3, 0))
	r:symJoint("ArmL", V(-1.45, 2.55, 0))
	r:joint("Flame", V(0, 3.9, 0.3))

	r:add({ s = "ball", sz = V(RAD * 2, 0, 0), p = CENTER, c = ROCK, m = SLATE })
	local rng = Random.new(21)
	-- craters
	for _ = 1, 16 do
		local d = V(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), rng:NextNumber(-1, 1))
		if d.Magnitude > 0.2 and not avoidFace(d) then
			local p, rot = onBall(d, -0.08)
			local s = rng:NextNumber(0.35, 0.65)
			r:add({ s = "cyl", sz = V(s + 0.12, 0.14, s + 0.12), p = p, r = rot + V(90, 0, 0), c = ROCK })
			r:add({ s = "cyl", sz = V(s, 0.16, s), p = p, r = rot + V(90, 0, 0), c = ROCK2 })
		end
	end
	-- galaxy patches and glowing cracks
	for i = 1, 26 do
		local d = V(rng:NextNumber(-1, 1), rng:NextNumber(-1, 1), rng:NextNumber(-1, 1))
		if d.Magnitude > 0.2 and not avoidFace(d) then
			local p, rot = onBall(d, -0.02)
			if i % 3 == 0 then
				r:add({ sz = V(0.7, 0.5, 0.12), p = p, r = rot + V(0, 0, rng:NextNumber(0, 180)), c = (i % 2 == 0) and GALAXY or GALAXY2, m = NEON })
			else
				r:add({ s = "box", sz = V(0.06, rng:NextNumber(0.4, 0.8), 0.06), p = p, r = rot + V(0, 0, rng:NextNumber(0, 180)), c = CRACK, m = NEON })
			end
		end
	end
	-- golden stars
	for _, d in { V(0.9, -0.4, -0.5), V(-0.8, 0.3, 0.6), V(0.7, 0.6, 0.5), V(-0.95, -0.5, -0.2), V(0.1, -0.7, 0.8) } do
		local p, rot = onBall(d, 0.02)
		r:add({ s = "box", sz = V(0.32, 0.32, 0.08), p = p, r = rot + V(0, 0, 45), c = STAR, m = NEON })
		r:add({ s = "box", sz = V(0.32, 0.32, 0.08), p = p, r = rot, c = STAR, m = NEON })
	end

	-- face
	r:eye(V(-0.55, 2.9, -1.32), 0.8, C(165, 60, 235), nil, { glow = true })
	r:eye(V(0.55, 2.9, -1.32), 0.8, C(165, 60, 235), nil, { glow = true })
	r:sym({ sz = V(0.7, 0.24, 0.3), p = V(-0.55, 3.42, -1.28), r = V(0, 0, -20), c = ROCK2 })
	r:sym({ sz = V(0.32, 0.18, 0.08), p = V(-0.9, 2.45, -1.2), c = C(255, 130, 160) })
	r:add({ sz = V(0.7, 0.48, 0.2), p = V(0, 2.2, -1.43), c = C(60, 10, 20) })
	r:add({ sz = V(0.4, 0.22, 0.12), p = V(0, 2.1, -1.5), c = C(255, 110, 120) })
	r:sym({ sz = V(0.12, 0.22, 0.08), p = V(-0.18, 2.37, -1.52), c = C(255, 255, 255) })

	-- stubby arms and legs
	r:sym({ sz = V(0.8, 0.95, 0.8), p = V(-1.65, 2.2, -0.1), r = V(0, 0, -20), c = ROCK, m = SLATE, j = "ArmL" })
	r:sym({ sz = V(0.3, 0.3, 0.1), p = V(-1.75, 2.1, -0.5), c = GALAXY, m = NEON, j = "ArmL" })
	r:sym({ sz = V(0.8, 0.9, 0.85), p = V(-0.6, 0.78, -0.05), c = ROCK, m = SLATE, j = "LegL" })
	r:sym({ sz = V(0.98, 0.45, 1.15), p = V(-0.6, 0.25, -0.2), c = ROCK2, m = SLATE, j = "LegL" })
	r:sym({ s = "box", sz = V(0.06, 0.35, 0.06), p = V(-0.45, 0.8, -0.45), r = V(0, 0, 20), c = CRACK, m = NEON, j = "LegL" })

	-- blazing flames on top
	r:add({ sz = V(1.0, 1.5, 1.0), p = V(0, 4.25, 0.45), r = V(25, 0, 0), c = C(255, 140, 30), m = NEON, j = "Flame" })
	r:add({ sz = V(0.75, 1.7, 0.75), p = V(-0.45, 4.45, 0.7), r = V(32, 0, 18), c = GALAXY, m = NEON, j = "Flame" })
	r:add({ sz = V(0.65, 1.35, 0.65), p = V(0.5, 4.35, 0.62), r = V(30, 0, -15), c = C(255, 200, 60), m = NEON, j = "Flame" })
	r:add({ sz = V(0.45, 1.1, 0.45), p = V(0.05, 4.9, 1.0), r = V(45, 0, 0), c = C(255, 110, 220), m = NEON, j = "Flame" })
	local fire = Instance.new("Fire")
	fire.Color = C(255, 120, 40)
	fire.SecondaryColor = GALAXY
	fire.Size = 4
	fire.Heat = 6
	fire.Parent = r.joints.Flame

	r:emitter("Flame", { Rate = 8, Lifetime = NumberRange.new(0.8, 1.5), Speed = NumberRange.new(1, 2.5), SpreadAngle = Vector2.new(40, 40), Size = NumberSequence.new(0.3, 0), Color = ColorSequence.new(STAR, C(255, 140, 255)), EmissionDirection = Enum.NormalId.Top })
	r:light("Body", GALAXY, 1.3, 10)
	return r:finish("CosmicMeteor", "tiny")
end
