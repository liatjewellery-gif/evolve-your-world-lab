-- EVOLVE YOUR WORLD: all the numbers of the game in one place.
-- Change a number here and the whole game follows it.

local Config = {
	PlayerWalkSpeed = 16,
	-- Every material and creature walks 30% slower than the player (Adam's rule).
	ItemWalkSpeed = 16 * 0.7,

	-- Red carpet: a new item comes out of the black box every second.
	SpawnInterval = 1,
	CarpetStartX = -124,
	CarpetEndX = 126,

	StartMoney = 1,

	-- Machines (green tanks): start with 6 (3 each side), up to 10 (5 each side).
	StartMachines = 6,
	MaxMachines = 10,
	MachinePrices = {
		[7] = 25000,
		[8] = 1000000,
		[9] = 50000000,
		[10] = 500000000,
	},
	-- Robux: create a Developer Product for each machine in the Creator Hub
	-- (Monetization > Developer Products) and paste its number here.
	-- While it is 0 the game only tells the player they need more money.
	MachineRobuxProducts = {
		[7] = 0,
		[8] = 0,
		[9] = 0,
		[10] = 0,
	},

	-- Selling gives back 90% of the price (10% loss).
	SellReturn = 0.9,

	-- Money keeps growing while you are offline: 10% of normal, for at most 2 hours.
	OfflineRate = 0.10,
	OfflineMaxSeconds = 2 * 60 * 60,

	DataStoreName = "EvolveYourWorld_v1",
	AutosaveSeconds = 60,

	-- 10 bases, 5 on each side of the red carpet.
	PlotXs = { -96, -48, 0, 48, 96 },
	PlotZ = 46,
	PlotSize = Vector3.new(44, 1, 58),

	-- The big sphere grows with every new machine.
	SphereBaseRadius = 9,
	SphereGrowPerMachine = 1.2,
}

function Config.sphereRadius(machines: number): number
	return Config.SphereBaseRadius + math.max(0, machines - Config.StartMachines) * Config.SphereGrowPerMachine
end

return Config
