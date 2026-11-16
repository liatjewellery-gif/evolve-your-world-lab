--[[
	Gait: makes every character walk in its own style by turning its joints.
	Runs on the client (smooth, no lag). Call Gait.update(model, dt, speed, t) every frame.

	cute    - bouncy happy walk (Grass and Flowers, Magic Tree)
	strut   - millionaire walk, chest out, big arm swing (Blue Crystal)
	bully   - wide swaggering walk (Lava Stone)
	skip    - slow skipping, cape flying (Giraffe)
	tiny    - quick little steps (Cosmic Meteor)
	quad    - four legs, swinging tail and mane (Solario, Frosty)
	dragon  - four legs plus flapping wings (Galaxy Dragon)
	phone   - walking while looking at the phone (Drippo Bloxino)
	limp    - zombie limp with arms forward (Zombino Rotolino)
	potion  - walking holding up a potion (Witchina Magichina)
]]

local Gait = {}

type State = { motors: { [string]: Motor6D }, phase: number, amount: number, gait: string, seed: number }
local states: { [Model]: State } = setmetatable({}, { __mode = "k" }) :: any

local sin, cos, abs, min = math.sin, math.cos, math.abs, math.min
local A = CFrame.Angles

local function state(model: Model): State
	local s = states[model]
	if not s then
		local motors = {}
		for _, d in model:GetDescendants() do
			if d:IsA("Motor6D") then
				motors[d.Name] = d
			end
		end
		s = {
			motors = motors,
			phase = 0,
			amount = 0,
			gait = (model:GetAttribute("Gait") :: string?) or "cute",
			seed = math.random() * 10,
		}
		states[model] = s
	end
	return s
end

local function set(m: { [string]: Motor6D }, name: string, cf: CFrame)
	local motor = m[name]
	if motor then
		motor.Transform = cf
	end
end

-- how fast the legs cycle for each gait (per stud moved)
local STRIDE = {
	cute = 1.15, strut = 0.95, bully = 0.9, skip = 0.7, tiny = 2.0,
	quad = 0.75, dragon = 0.6, phone = 1.0, limp = 0.9, potion = 1.0,
}

function Gait.update(model: Model, dt: number, speed: number, t: number, opts: { [string]: any }?)
	local s = state(model)
	local m = s.motors
	local target = min(speed / 8, 1)
	s.amount += (target - s.amount) * min(dt * 8, 1)
	local a = s.amount
	s.phase += dt * speed * (STRIDE[s.gait] or 1)
	local ph = s.phase
	local tt = t + s.seed
	local breathe = sin(tt * 2) * 0.03
	local g = s.gait

	-- things every model may have
	set(m, "Halo", A(0, tt * 1.5, 0))
	set(m, "Flies", A(0, tt * 5, 0) * A(sin(tt * 3) * 0.1, 0, 0))
	set(m, "Flame", A(sin(tt * 9) * 0.06, 0, cos(tt * 7) * 0.06))
	set(m, "Cape", A(-(0.12 + 0.35 * a + sin(tt * 7) * 0.08 * (0.3 + a)), 0, sin(tt * 3) * 0.04))
	set(m, "Mane", A(sin(tt * 2.1) * 0.04, 0, sin(tt * 1.7) * 0.06 * (0.5 + a)))
	set(m, "Tail", A(sin(tt * 2.5) * 0.15, sin(tt * 3 + ph) * (0.25 + 0.2 * a), 0))

	if g == "quad" or g == "dragon" then
		local sw = sin(ph) * 0.55 * a
		set(m, "LegFL", A(sw, 0, 0))
		set(m, "LegBR", A(sw, 0, 0))
		set(m, "LegFR", A(-sw, 0, 0))
		set(m, "LegBL", A(-sw, 0, 0))
		set(m, "Body", CFrame.new(0, abs(sin(ph)) * 0.12 * a + breathe, 0) * A(sin(ph * 2) * 0.02 * a, 0, sin(ph) * 0.03 * a))
		set(m, "Head", A(sin(ph * 2) * 0.05 * a + sin(tt * 0.9) * 0.04, sin(tt * 0.7) * 0.12, 0))
		set(m, "Neck", A(sin(tt * 1.1) * 0.05, 0, 0))
		if g == "dragon" then
			local flap = sin(tt * (2.2 + a * 2)) * (0.35 + 0.25 * a)
			set(m, "WingL", A(0, 0, flap - 0.1))
			set(m, "WingR", A(0, 0, -flap + 0.1))
		end
		return
	end

	local sw = sin(ph)
	local legAmp, armAmp, bounce = 0.6, 0.5, 0.15
	local body = CFrame.identity
	local head = A(sin(tt * 1.3) * 0.04, sin(tt * 0.8) * 0.08, sin(tt * 1.1) * 0.03)
	local armL, armR

	if g == "cute" then
		legAmp, armAmp, bounce = 0.55, 0.6, 0.3
		head *= A(0, 0, sin(ph) * 0.08 * a)
	elseif g == "strut" then
		legAmp, armAmp, bounce = 0.55, 0.85, 0.12
		body = A(-0.08 * a, sin(ph) * 0.12 * a, sin(ph) * 0.06 * a)
		head *= A(-0.08 * a, 0, 0)
	elseif g == "bully" then
		legAmp, armAmp, bounce = 0.5, 0.45, 0.1
		body = A(0, sin(ph) * 0.18 * a, sin(ph) * 0.14 * a)
		armL = A(-sw * 0.45 * a, 0, -0.35 * a)
		armR = A(sw * 0.45 * a, 0, 0.35 * a)
	elseif g == "skip" then
		legAmp, armAmp, bounce = 0.35, 0.5, 0.0
		local hop = abs(sin(ph)) * 0.65 * a
		body = CFrame.new(0, hop, 0) * A(-0.06 * a, 0, 0)
		armL = A(-0.4 * a - sw * 0.3 * a, 0, -0.3 * a)
		armR = A(-0.4 * a + sw * 0.3 * a, 0, 0.3 * a)
	elseif g == "tiny" then
		legAmp, armAmp, bounce = 0.45, 0.5, 0.22
		body = A(0, 0, sin(ph) * 0.1 * a)
	elseif g == "phone" then
		legAmp, armAmp, bounce = 0.55, 0.5, 0.1
		armR = A(2.05, 0, -0.25)
		head *= A(-0.3, 0, 0)
	elseif g == "potion" then
		legAmp, armAmp, bounce = 0.5, 0.35, 0.12
		armR = A(0.95 + sin(tt * 2) * 0.05, 0, 0.15)
		armL = A(0.25 - sw * 0.15 * a, 0, 0)
	elseif g == "limp" then
		legAmp, bounce = 0.0, 0.0
		local good = sw * 0.55 * a
		local drag = math.max(0, -sw) * 0.18 * a
		set(m, "LegL", A(good, 0, 0))
		set(m, "LegR", A(drag, 0, 0.05 * a))
		body = CFrame.new(0, math.max(0, sw) * 0.25 * a, 0) * A(0.06, sin(ph) * 0.1 * a, 0.12 * a + sin(ph) * 0.1 * a)
		armL = A(1.3 + sin(tt * 2.3) * 0.08, 0, 0.05)
		armR = A(1.15 + sin(tt * 2.0 + 1) * 0.08, 0, -0.05)
		head *= A(0, 0, 0.15 + sin(tt * 1.7) * 0.06)
	end

	if legAmp > 0 then
		set(m, "LegL", A(sw * legAmp * a, 0, 0))
		set(m, "LegR", A(-sw * legAmp * a, 0, 0))
	end
	set(m, "ArmL", armL or A(-sw * armAmp * a, 0, -0.05))
	set(m, "ArmR", armR or A(sw * armAmp * a, 0, 0.05))
	set(m, "Body", CFrame.new(0, abs(sw) * bounce * a + breathe, 0) * body)
	set(m, "Head", head)
end

-- Sleeping pose for the tank: everything relaxed, slowly breathing.
function Gait.sleep(model: Model, t: number)
	local s = state(model)
	local m = s.motors
	local tt = t + s.seed
	set(m, "Body", CFrame.new(0, sin(tt * 0.9) * 0.05, 0))
	set(m, "Head", A(-0.25 + sin(tt * 0.9) * 0.03, 0, 0.1))
	set(m, "ArmL", A(0.1, 0, -0.15))
	set(m, "ArmR", A(0.1, 0, 0.15))
	set(m, "Cape", A(-0.05, 0, 0))
	set(m, "Tail", A(0, sin(tt * 0.5) * 0.1, 0))
	set(m, "WingL", A(0, 0, 0.5))
	set(m, "WingR", A(0, 0, -0.5))
	set(m, "Halo", A(0, tt * 0.5, 0))
	set(m, "Flies", A(0, tt * 3, 0))
end

return Gait
