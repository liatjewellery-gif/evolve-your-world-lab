-- Builds any of the 12 characters by id.
--   Characters.build(id)            -> walking model with a Humanoid (server, red carpet)
--   Characters.buildStatic(id, k)   -> anchored model, no Humanoid (tanks, sphere, intro)
local ItemData = require(script.Parent.ItemData)

local Characters = {}
local builders: { [string]: () -> Model } = {}

for _, child in script:GetChildren() do
	if child:IsA("ModuleScript") then
		builders[child.Name] = require(child) :: any
	end
end

local cache: { [string]: Model } = {}

local function template(id: string): Model
	local m = cache[id]
	if not m then
		local b = builders[id]
		assert(b, "No character builder for " .. tostring(id))
		m = b()
		local scale = ItemData.byId[id] and ItemData.byId[id].scale or 1
		if scale ~= 1 then
			local hip = m:GetAttribute("Hip") :: number
			m:ScaleTo(scale)
			m:SetAttribute("Hip", hip * scale)
			local hum = m:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.HipHeight = (hip - 1) * scale
			end
		end
		cache[id] = m
	end
	return m
end

function Characters.build(id: string): Model
	return template(id):Clone()
end

-- A model that does not walk by physics. Its joints still move, so it can be animated
-- by the Gait module while we move it with PivotTo.
function Characters.buildStatic(id: string, scale: number?): Model
	local m = template(id):Clone()
	local hum = m:FindFirstChildOfClass("Humanoid")
	if hum then
		hum:Destroy()
	end
	local root = m.PrimaryPart :: BasePart
	root.Anchored = true
	local k = scale or 1
	if k ~= 1 then
		local hip = m:GetAttribute("Hip") :: number
		m:ScaleTo(m:GetScale() * k)
		m:SetAttribute("Hip", hip * k)
	end
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			d.CanCollide = false
			d.CanQuery = false
			d.CanTouch = false
		end
	end
	return m
end

-- Puts a model so its feet stand on groundPos, facing yaw (radians).
function Characters.place(m: Model, groundPos: Vector3, yaw: number)
	local hip = (m:GetAttribute("Hip") :: number?) or 2
	m:PivotTo(CFrame.new(groundPos + Vector3.new(0, hip, 0)) * CFrame.Angles(0, yaw, 0))
end

return Characters
