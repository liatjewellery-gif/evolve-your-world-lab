-- Small visual effects used everywhere on the client: the laser beam, "+$" popups,
-- sparkle poofs, and a tiny scheduler for smooth grow/shrink animations.
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Fx = {}

local folder = Instance.new("Folder")
folder.Name = "LocalFx"
folder.Parent = workspace
Fx.folder = folder

Fx.TEX = {
	sparkle = "rbxasset://textures/particles/sparkles_main.dds",
	smoke = "rbxasset://textures/particles/smoke_main.dds",
	fire = "rbxasset://textures/particles/fire_main.dds",
}

function Fx.anchor(pos: Vector3, parent: Instance?): (BasePart, Attachment)
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.Transparency = 1
	p.Size = Vector3.new(0.2, 0.2, 0.2)
	p.CFrame = CFrame.new(pos)
	p.Parent = parent or folder
	local a = Instance.new("Attachment")
	a.Parent = p
	return p, a
end

function Fx.ball(pos: Vector3, size: number, color: Color3, parent: Instance?): BasePart
	local p = Instance.new("Part")
	p.Shape = Enum.PartType.Ball
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Material = Enum.Material.Neon
	p.Color = color
	p.Size = Vector3.new(size, size, size)
	p.CFrame = CFrame.new(pos)
	p.Parent = parent or folder
	return p
end

function Fx.burst(pos: Vector3, colors: ColorSequence, count: number, speed: number, size: number?)
	local holder = Fx.anchor(pos)
	local pe = Instance.new("ParticleEmitter")
	pe.Texture = Fx.TEX.sparkle
	pe.Rate = 0
	pe.LightEmission = 1
	pe.Lifetime = NumberRange.new(0.6, 1.2)
	pe.Speed = NumberRange.new(speed * 0.5, speed)
	pe.SpreadAngle = Vector2.new(180, 180)
	pe.Size = NumberSequence.new(size or 0.6, 0)
	pe.Color = colors
	pe.Drag = 2
	pe.Parent = holder
	pe:Emit(count)
	Debris:AddItem(holder, 2)
end

-- The laser from a tank into the sphere.
function Fx.beam(from: Attachment, to: Vector3, colors: ColorSequence, onHit: (() -> ())?)
	local endPart, endAtt = Fx.anchor(to)
	local beam = Instance.new("Beam")
	beam.Attachment0 = from
	beam.Attachment1 = endAtt
	beam.Color = colors
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.FaceCamera = true
	beam.Segments = 24
	beam.Width0 = 0.2
	beam.Width1 = 0.2
	beam.CurveSize0 = 4
	beam.CurveSize1 = -2
	beam.Transparency = NumberSequence.new(0)
	beam.Parent = endPart
	local core = beam:Clone()
	core.Color = ColorSequence.new(Color3.new(1, 1, 1))
	core.Parent = endPart

	local start = from.WorldPosition
	local orb = Fx.ball(start, 1.2, colors.Keypoints[1].Value)
	local light = Instance.new("PointLight")
	light.Color = colors.Keypoints[1].Value
	light.Range = 14
	light.Brightness = 3
	light.Parent = orb

	local t0 = os.clock()
	local hit = false
	local conn
	conn = RunService.RenderStepped:Connect(function()
		local t = os.clock() - t0
		local grow = math.min(t / 0.25, 1)
		beam.Width0 = 0.4 + grow * 1.2
		beam.Width1 = 0.6 + grow * 2.2
		core.Width0 = beam.Width0 * 0.35
		core.Width1 = beam.Width1 * 0.35
		beam.CurveSize0 = 4 * math.max(0, 1 - t)
		beam.CurveSize1 = -2 * math.max(0, 1 - t)
		local k = math.clamp(t / 0.6, 0, 1)
		orb.CFrame = CFrame.new(start:Lerp(to, k))
		orb.Size = Vector3.one * (1.2 + math.sin(t * 30) * 0.2)
		if k >= 1 and not hit then
			hit = true
			orb.Transparency = 1
			Fx.burst(to, colors, 60, 14, 1.2)
			local flash = Fx.ball(to, 2, colors.Keypoints[#colors.Keypoints].Value)
			TweenService:Create(flash, TweenInfo.new(0.6), { Size = Vector3.one * 14, Transparency = 1 }):Play()
			Debris:AddItem(flash, 0.7)
			if onHit then
				task.spawn(onHit)
			end
		end
		if t > 1.0 then
			local f = math.clamp((t - 1.0) / 0.6, 0, 1)
			beam.Transparency = NumberSequence.new(f)
			core.Transparency = NumberSequence.new(f)
		end
		if t > 1.7 then
			conn:Disconnect()
			endPart:Destroy()
			orb:Destroy()
		end
	end)
end

-- "+$5" floating up and fading.
function Fx.popup(pos: Vector3, text: string, color: Color3, size: number?)
	local holder = Fx.anchor(pos)
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.fromOffset(size or 160, (size or 160) * 0.35)
	bb.AlwaysOnTop = true
	bb.LightInfluence = 0
	bb.MaxDistance = 140
	bb.Adornee = holder
	bb.Parent = holder
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromScale(1, 1)
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.Text = text
	t.TextColor3 = color
	t.TextStrokeTransparency = 0
	t.Parent = bb
	TweenService:Create(holder, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = CFrame.new(pos + Vector3.new(0, 4, 0)) }):Play()
	TweenService:Create(t, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0.7), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	Debris:AddItem(holder, 1.3)
end

-- Smooth scaling of a model over time (grow in, shrink away, regrow).
type ScaleJob = { model: Model, from: number, to: number, t0: number, dur: number, done: (() -> ())? }
local jobs: { ScaleJob } = {}

function Fx.scaleModel(model: Model, from: number, to: number, dur: number, done: (() -> ())?)
	for i = #jobs, 1, -1 do
		if jobs[i].model == model then
			table.remove(jobs, i)
		end
	end
	model:ScaleTo(math.max(from, 0.02))
	table.insert(jobs, { model = model, from = from, to = to, t0 = os.clock(), dur = dur, done = done })
end

RunService.RenderStepped:Connect(function()
	local now = os.clock()
	for i = #jobs, 1, -1 do
		local j = jobs[i]
		if not j.model.Parent then
			table.remove(jobs, i)
		else
			local k = math.clamp((now - j.t0) / j.dur, 0, 1)
			local e = 1 - (1 - k) ^ 3
			if j.to > j.from then
				-- a little overshoot when growing
				e = k < 1 and (1 + 2.2 * (k - 1) ^ 3 + 1.2 * (k - 1) ^ 2) or 1
			end
			j.model:ScaleTo(math.max(j.from + (j.to - j.from) * e, 0.02))
			if k >= 1 then
				table.remove(jobs, i)
				if j.done then
					task.spawn(j.done)
				end
			end
		end
	end
end)

return Fx
