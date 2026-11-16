local Util = {}

local SUFFIX = { "", "K", "M", "B", "T", "Qd" }

-- 1234 -> "$1.2K", 2500000 -> "$2.5M"
function Util.money(n: number): string
	n = math.floor(n + 0.5)
	if n < 1000 then
		return "$" .. tostring(n)
	end
	local i = 1
	local v = n
	while v >= 1000 and i < #SUFFIX do
		v /= 1000
		i += 1
	end
	local s
	if v >= 100 then
		s = string.format("%d", math.floor(v))
	elseif v >= 10 then
		s = string.format("%.1f", math.floor(v * 10) / 10)
	else
		s = string.format("%.2f", math.floor(v * 100) / 100)
	end
	if string.find(s, ".", 1, true) then
		s = string.gsub(s, "0+$", "")
		s = string.gsub(s, "%.$", "")
	end
	return "$" .. s .. SUFFIX[i]
end

function Util.part(props: { [string]: any }): BasePart
	local class = props.ClassName or "Part"
	local p = Instance.new(class) :: BasePart
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for k, v in props do
		if k ~= "ClassName" and k ~= "Parent" then
			(p :: any)[k] = v
		end
	end
	if props.Parent then
		p.Parent = props.Parent
	end
	return p
end

-- Vertical cylinder: diameter d, height h, centred at cf.
function Util.cylinder(cf: CFrame, d: number, h: number, props: { [string]: any }): BasePart
	props.Shape = Enum.PartType.Cylinder
	props.Size = Vector3.new(h, d, d)
	props.CFrame = cf * CFrame.Angles(0, 0, math.pi / 2)
	return Util.part(props)
end

function Util.billboard(adornee: Instance, size: UDim2, offset: Vector3, maxDist: number?): BillboardGui
	local bb = Instance.new("BillboardGui")
	bb.Size = size
	bb.StudsOffset = offset
	bb.AlwaysOnTop = false
	bb.LightInfluence = 0
	bb.MaxDistance = maxDist or 120
	bb.Adornee = adornee :: any
	bb.Parent = adornee
	return bb
end

function Util.label(parent: Instance, text: string, color: Color3, size: UDim2, pos: UDim2): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = size
	t.Position = pos
	t.Font = Enum.Font.FredokaOne
	t.TextScaled = true
	t.Text = text
	t.TextColor3 = color
	t.TextStrokeTransparency = 0
	t.TextStrokeColor3 = Color3.new(0, 0, 0)
	t.Parent = parent
	return t
end

return Util
