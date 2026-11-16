-- Saves and loads each player's progress (money, machines, what is in every tank).
-- In Roblox Studio, saving only works after:
--   Game Settings > Security > "Enable Studio Access to API Services" = ON
-- Without it the game still runs, it just starts fresh every time.

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("Shared").Config)

local Data = {}

export type TankSave = { id: string, active: boolean }
export type Save = {
	money: number,
	pending: number,
	machines: number,
	tanks: { [string]: TankSave },
	tutorial: number,
	introSeen: boolean,
	lastSeen: number,
}

local store: DataStore? = nil
local ok = pcall(function()
	store = DataStoreService:GetDataStore(Config.DataStoreName)
end)
if not ok then
	warn("[EvolveYourWorld] DataStore not available - progress will not be saved (turn on API Services in Game Settings)")
end

function Data.default(): Save
	return {
		money = Config.StartMoney,
		pending = 0,
		machines = Config.StartMachines,
		tanks = {},
		tutorial = 1,
		introSeen = false,
		lastSeen = os.time(),
	}
end

function Data.load(userId: number): (Save, boolean)
	local s = store
	if not s then
		return Data.default(), true
	end
	for attempt = 1, 3 do
		local success, result = pcall(function()
			return s:GetAsync("u_" .. userId)
		end)
		if success then
			if type(result) == "table" then
				local d = Data.default()
				for k, v in result do
					(d :: any)[k] = v
				end
				return d, false
			end
			return Data.default(), true
		end
		warn("[EvolveYourWorld] load failed, attempt " .. attempt .. ": " .. tostring(result))
		task.wait(1)
	end
	return Data.default(), true
end

function Data.save(userId: number, save: Save)
	local s = store
	if not s then
		return
	end
	save.lastSeen = os.time()
	local success, err = pcall(function()
		s:SetAsync("u_" .. userId, save)
	end)
	if not success then
		warn("[EvolveYourWorld] save failed: " .. tostring(err))
	end
end

return Data
