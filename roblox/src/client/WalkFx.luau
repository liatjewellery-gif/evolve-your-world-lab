-- The special walk effects from Adam's doc, for items walking on the red carpet:
--   Grass and Flowers  sparkle trail that vanishes after 3 seconds
--   Magic Tree         leaves soil behind that disappears after 5 seconds
--   Blue Crystal       millionaire walk that drops money
--   Lava Stone         smoke every 3 seconds that vanishes after 2 seconds
--   Galaxy Dragon      breathes fire while walking
-- (The others have their effects built into the model: snowflakes, sun glow, flames, flies...)
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Fx = require(script.Parent.Fx)

local WalkFx = {}

type S = { timer: number, timer2: number, setup: boolean }
local states: { [Model]: S } = setmetatable({}, { __mode = "k" }) :: any

local function groundUnder(m: Model): Vector3
	local root = m.PrimaryPart :: BasePart
	local hip = (m:GetAttribute("Hip") :: number?) or 2
	return root.Position - Vector3.new(0, hip - 0.12, 0)
end

local function soil(m: Model)
	local pos = groundUnder(m) + Vector3.new((math.random() - 0.5) * 0.8, 0, (math.random() - 0.5) * 0.8)
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Cylinder
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Material = Enum.Material.Ground
	p.Color = Color3.fromRGB(110 + math.random(0, 25), 75, 40)
	local d = 0.9 + math.random() * 0.8
	p.Size = Vector3.new(0.12, d, d)
	p.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2)
	p.Parent = Fx.folder
	TweenService:Create(p, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 4), { Transparency = 1 }):Play()
	Debris:AddItem(p, 5.1)
end

local function money(m: Model)
	local root = m.PrimaryPart :: BasePart
	local start = root.Position + Vector3.new((math.random() - 0.5) * 1.5, 1, (math.random() - 0.5) * 1.5)
	local ground = groundUnder(m)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Size = Vector3.new(0.9, 0.05, 0.45)
	p.Color = Color3.fromRGB(95, 200, 95)
	p.Material = Enum.Material.SmoothPlastic
	p.CFrame = CFrame.new(start) * CFrame.Angles(math.random() * 6, math.random() * 6, math.random() * 6)
	p.Parent = Fx.folder
	local sg = Instance.new("SurfaceGui")
	sg.Face = Enum.NormalId.Top
	sg.PixelsPerStud = 40
	sg.Parent = p
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Text = "$"
	t.TextScaled = true
	t.Font = Enum.Font.FredokaOne
	t.TextColor3 = Color3.fromRGB(30, 110, 30)
	t.Parent = sg
	local landed = CFrame.new(Vector3.new(start.X, ground.Y + 0.05, start.Z)) * CFrame.Angles(0, math.random() * 6, 0)
	TweenService:Create(p, TweenInfo.new(0.6, Enum.EasingStyle.Bounce), { CFrame = landed }):Play()
	TweenService:Create(p, TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 3), { Transparency = 1 }):Play()
	TweenService:Create(t, TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 3), { TextTransparency = 1 }):Play()
	Debris:AddItem(p, 3.7)
end

local function sparkleTrail(m: Model)
	local root = m.PrimaryPart :: BasePart
	local hip = (m:GetAttribute("Hip") :: number?) or 2
	local a0 = Instance.new("Attachment")
	a0.Position = Vector3.new(-0.7, -hip + 0.25, 0)
	a0.Parent = root
	local a1 = Instance.new("Attachment")
	a1.Position = Vector3.new(0.7, -hip + 0.25, 0)
	a1.Parent = root
	local trail = Instance.new("Trail")
	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Lifetime = 3
	trail.LightEmission = 1
	trail.FaceCamera = false
	trail.Color = ColorSequence.new(Color3.fromRGB(255, 140, 210), Color3.fromRGB(140, 255, 120))
	trail.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.2), NumberSequenceKeypoint.new(1, 1) })
	trail.Parent = root
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = Fx.TEX.sparkle
	pe.Rate = 14
	pe.Lifetime = NumberRange.new(2.5, 3)
	pe.Speed = NumberRange.new(0, 0.3)
	pe.LightEmission = 1
	pe.Size = NumberSequence.new(0.4, 0)
	pe.Color = ColorSequence.new(Color3.fromRGB(255, 180, 230), Color3.fromRGB(255, 240, 140))
	pe.Parent = a0
end

function WalkFx.update(m: Model, dt: number, speed: number)
	local s = states[m]
	if not s then
		s = { timer = 0, timer2 = 0, setup = false }
		states[m] = s
	end
	local id = m:GetAttribute("ItemId")
	if not s.setup then
		s.setup = true
		if id == "GrassAndFlowers" then
			sparkleTrail(m)
		end
	end
	local moving = speed > 1
	s.timer += dt
	s.timer2 += dt
	if id == "MagicTree" and moving and s.timer > 0.3 then
		s.timer = 0
		soil(m)
	elseif id == "BlueCrystal" and moving and s.timer > 0.28 then
		s.timer = 0
		money(m)
	elseif id == "LavaStone" and s.timer > 3 then
		s.timer = 0
		local smoke = m:FindFirstChild("WalkSmoke", true) :: ParticleEmitter?
		if smoke then
			smoke:Emit(26)
		end
	elseif id == "GalaxyDragon" and s.timer > 4 then
		s.timer = 0
		local breath = m:FindFirstChild("Breath", true) :: ParticleEmitter?
		if breath then
			for k = 0, 5 do
				task.delay(k * 0.1, function()
					breath:Emit(14)
				end)
			end
		end
	end
end

return WalkFx
