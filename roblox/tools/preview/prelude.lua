-- Minimal Roblox shims so the real Rig + character builders run in plain Lua 5.1.
local sin, cos = math.sin, math.cos
local Vmt = {}
local function V(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, Vmt) end
Vmt.__add = function(a, b) return V(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
Vmt.__sub = function(a, b) return V(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
Vmt.__unm = function(a) return V(-a.X, -a.Y, -a.Z) end
Vmt.__mul = function(a, b)
	if type(a) == "number" then return V(a * b.X, a * b.Y, a * b.Z) end
	if type(b) == "number" then return V(a.X * b, a.Y * b, a.Z * b) end
	return V(a.X * b.X, a.Y * b.Y, a.Z * b.Z)
end
Vmt.__div = function(a, b) return V(a.X / b, a.Y / b, a.Z / b) end
Vmt.__index = function(t, k)
	if k == "Magnitude" then return math.sqrt(t.X * t.X + t.Y * t.Y + t.Z * t.Z) end
	if k == "Unit" then local m = math.sqrt(t.X * t.X + t.Y * t.Y + t.Z * t.Z); if m == 0 then return V(0,0,0) end return V(t.X / m, t.Y / m, t.Z / m) end
	return nil
end
local Vector3 = { new = V, one = V(1, 1, 1), zero = V(0, 0, 0) }
local Vector2 = { new = function(x, y) return { X = x, Y = y } end }

-- CFrame: rotation matrix (row-major r[1..9]) + position
local CFmt = {}
local function CF(r, p) return setmetatable({ r = r, p = p }, CFmt) end
local function mulR(a, b)
	local r = {}
	for i = 0, 2 do
		for j = 0, 2 do
			r[i * 3 + j + 1] = a[i * 3 + 1] * b[j + 1] + a[i * 3 + 2] * b[3 + j + 1] + a[i * 3 + 3] * b[6 + j + 1]
		end
	end
	return r
end
local function rotV(r, v)
	return V(r[1] * v.X + r[2] * v.Y + r[3] * v.Z, r[4] * v.X + r[5] * v.Y + r[6] * v.Z, r[7] * v.X + r[8] * v.Y + r[9] * v.Z)
end
local I = { 1, 0, 0, 0, 1, 0, 0, 0, 1 }
local function Rx(a) return { 1, 0, 0, 0, cos(a), -sin(a), 0, sin(a), cos(a) } end
local function Ry(a) return { cos(a), 0, sin(a), 0, 1, 0, -sin(a), 0, cos(a) } end
local function Rz(a) return { cos(a), -sin(a), 0, sin(a), cos(a), 0, 0, 0, 1 } end
CFmt.__mul = function(a, b)
	if getmetatable(b) == CFmt then
		return CF(mulR(a.r, b.r), a.p + rotV(a.r, b.p))
	end
	return a.p + rotV(a.r, b)
end
CFmt.__add = function(a, v) return CF(a.r, a.p + v) end
CFmt.__index = function(t, k)
	if k == "Position" then return rawget(t, "p") end
	if k == "Rotation" then return CF(rawget(t, "r"), V(0, 0, 0)) end
	if k == "Inverse" then
		return function(self)
			local r = self.r
			local rt = { r[1], r[4], r[7], r[2], r[5], r[8], r[3], r[6], r[9] }
			return CF(rt, -rotV(rt, self.p))
		end
	end
	return nil
end
local CFrame = {}
CFrame.new = function(x, y, z)
	if type(x) == "table" then return CF(I, x) end
	return CF(I, V(x or 0, y or 0, z or 0))
end
CFrame.Angles = function(x, y, z) return CF(mulR(mulR(Rx(x), Ry(y)), Rz(z)), V(0, 0, 0)) end
CFrame.fromOrientation = function(x, y, z) return CF(mulR(mulR(Ry(y), Rx(x)), Rz(z)), V(0, 0, 0)) end
CFrame.identity = CF(I, V(0, 0, 0))

local Color3 = {
	fromRGB = function(r, g, b) return { R = r / 255, G = g / 255, B = b / 255 } end,
	new = function(r, g, b) return { R = r, G = g, B = b } end,
}

local Enum = setmetatable({}, { __index = function(_, cat)
	return setmetatable({}, { __index = function(_, item) return item end })
end })

local function stub(...) return { __stub = true } end
local NumberRange = { new = stub }
local NumberSequence = { new = stub }
local ColorSequence = { new = stub }
local NumberSequenceKeypoint = { new = stub }
local ColorSequenceKeypoint = { new = stub }
local UDim2 = { new = stub, fromScale = stub, fromOffset = stub }

local ALL = {}
local Imt = {}
Imt.__index = function(t, k)
	local props = rawget(t, "__props")
	if props[k] ~= nil then return props[k] end
	local methods = {
		SetAttribute = function(self, n, v) rawget(self, "__attr")[n] = v end,
		GetAttribute = function(self, n) return rawget(self, "__attr")[n] end,
		ScaleTo = function() end,
		Clone = function(self) return self end,
		GetChildren = function(self) return rawget(self, "__children") end,
	}
	return methods[k]
end
Imt.__newindex = function(t, k, v)
	rawget(t, "__props")[k] = v
	if k == "Parent" and type(v) == "table" and rawget(v, "__children") then
		table.insert(rawget(v, "__children"), t)
	end
end
local Instance = {
	new = function(class)
		local o = setmetatable({ __props = { ClassName = class, Name = class }, __attr = {}, __children = {} }, Imt)
		table.insert(ALL, o)
		return o
	end,
}

local function Random_new(seed)
	local s = (seed or 1) % 2147483647
	if s <= 0 then s = s + 2147483646 end
	local R = {}
	local function nxt()
		s = (s * 16807) % 2147483647
		return s / 2147483647
	end
	function R:NextNumber(a, b)
		if a == nil then return nxt() end
		return a + (b - a) * nxt()
	end
	function R:NextInteger(a, b) return a + math.floor(nxt() * (b - a + 1)) end
	return R
end
local Random = { new = Random_new }

local tableClone = function(t) local c = {} for k, v in pairs(t) do c[k] = v end return c end
local Config = { ItemWalkSpeed = 11.2 }
