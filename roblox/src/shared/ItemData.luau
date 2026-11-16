-- The 12 items of EVOLVE YOUR WORLD, exactly as Adam wrote them in the doc.
-- chance  = how often it comes out of the black box (Adam's percent; higher = more often)
-- price   = cost in game dollars
-- income  = dollars per second while its beam is on
-- beam    = colours of the laser from the tank to the sphere

local C = Color3.fromRGB

export type Item = {
	id: string,
	name: string,
	kind: string,
	rarity: string,
	chance: number,
	price: number,
	income: number,
	beam: { Color3 },
	walk: string,
	sphere: string,
	scale: number,
}

local Rarity = {
	Common = C(170, 220, 150),
	Rare = C(80, 160, 255),
	["Super Rare"] = C(255, 120, 60),
	Epic = C(190, 90, 255),
	Legendary = C(255, 205, 40),
	Mythic = C(255, 60, 120),
	Secret = C(255, 255, 255),
}

local list: { Item } = {
	{
		id = "GrassAndFlowers", name = "Grass and Flowers", kind = "Material", rarity = "Common",
		chance = 100, price = 1, income = 1,
		beam = { C(255, 120, 200), C(120, 230, 90) },
		walk = "Cute walk, leaves a sparkle trail that vanishes after 3 seconds",
		sphere = "Grass over the whole sphere and 5 flowers",
		scale = 1,
	},
	{
		id = "MagicTree", name = "Magic Tree", kind = "Material", rarity = "Rare",
		chance = 90, price = 50, income = 3,
		beam = { C(40, 120, 40), C(120, 220, 80), C(190, 255, 120) },
		walk = "Cute walk, leaves soil behind that disappears after 5 seconds",
		sphere = "10 trees of all kinds, leaves sometimes fall and grow back",
		scale = 1,
	},
	{
		id = "LavaStone", name = "Lava Stone", kind = "Material", rarity = "Super Rare",
		chance = 80, price = 400, income = 12,
		beam = { C(255, 50, 20), C(30, 10, 10), C(255, 120, 0) },
		walk = "Bully walk, puffs smoke every 3 seconds that vanishes after 2 seconds",
		sphere = "3 volcanoes that blow smoke every minute",
		scale = 1,
	},
	{
		id = "DrippoBloxino", name = "Drippo Bloxino", kind = "Creature", rarity = "Super Rare",
		chance = 80, price = 2500, income = 45,
		beam = { C(15, 15, 20), C(60, 60, 80), C(15, 15, 20) },
		walk = "Walks like a person, always on the phone",
		sphere = "Each person builds 3 buildings",
		scale = 1,
	},
	{
		id = "BlueCrystal", name = "Blue Crystal", kind = "Material", rarity = "Epic",
		chance = 70, price = 12000, income = 150,
		beam = { C(150, 230, 255), C(40, 120, 255) },
		walk = "Millionaire walk, leaves money behind",
		sphere = "Adds 10 sparkling blue crystals",
		scale = 1,
	},
	{
		id = "ZombinoRotolino", name = "Zombino Rotolino", kind = "Creature", rarity = "Epic",
		chance = 75, price = 50000, income = 450,
		beam = { C(60, 200, 40), C(20, 80, 20) },
		walk = "Limps, with flies around",
		sphere = "A zombie that walks and bites things (they grow back)",
		scale = 1,
	},
	{
		id = "CosmicMeteor", name = "Cosmic Meteor", kind = "Material", rarity = "Epic",
		chance = 45, price = 200000, income = 1400,
		beam = { C(130, 130, 140), C(170, 70, 255), C(255, 210, 60) },
		walk = "Cute little steps",
		sphere = "A meteor falls every 5 seconds",
		scale = 1,
	},
	{
		id = "Giraffe", name = "Giraffe", kind = "Material", rarity = "Legendary",
		chance = 65, price = 1000000, income = 5000,
		beam = { C(255, 150, 30), C(255, 230, 60) },
		walk = "Slow skipping, cape flying in the wind",
		sphere = "5 giraffes that eat from the trees, or just wander",
		scale = 1,
	},
	{
		id = "WitchinaMagichina", name = "Witchina Magichina", kind = "Creature", rarity = "Mythic",
		chance = 40, price = 6000000, income = 22000,
		beam = { C(150, 60, 255), C(220, 140, 255) },
		walk = "Walks holding a potion",
		sphere = "Stands and brews potions; sometimes throws one and plants glow purple",
		scale = 1,
	},
	{
		id = "FrostyFangolini", name = "Frosty Fangolini", kind = "Creature", rarity = "Secret",
		chance = 20, price = 40000000, income = 110000,
		beam = { C(240, 255, 255), C(120, 210, 255), C(40, 140, 255) },
		walk = "Walks on 4 legs, snowflakes all around",
		sphere = "Wanders and runs; steam when it passes a volcano",
		scale = 1.25,
	},
	{
		id = "SolarioLeonario", name = "Solario Leonario", kind = "Creature", rarity = "Secret",
		chance = 20, price = 250000000, income = 550000,
		beam = { C(255, 240, 120), C(255, 190, 20) },
		walk = "Glows like the sun, 4 legs, mane swaying in the wind",
		sphere = "A lion that rests, walks, and hunts giraffes",
		scale = 1.25,
	},
	{
		id = "GalaxyDragon", name = "Galaxy Dragon", kind = "Creature", rarity = "Secret",
		chance = 10, price = 1000000000, income = 1800000,
		beam = { C(40, 10, 90), C(170, 60, 255), C(80, 160, 255), C(255, 120, 230) },
		walk = "Walks and breathes fire",
		sphere = "Hovers with wings; burns falling meteors into fireworks",
		scale = 1.35,
	},
}

local ItemData = {
	list = list,
	byId = {} :: { [string]: Item },
	rarityColor = Rarity,
	totalChance = 0,
}

for _, item in list do
	ItemData.byId[item.id] = item
	ItemData.totalChance += item.chance
end

function ItemData.beamSequence(id: string): ColorSequence
	local cols = ItemData.byId[id].beam
	if #cols == 1 then
		return ColorSequence.new(cols[1])
	end
	local keys = {}
	for i, c in cols do
		table.insert(keys, ColorSequenceKeypoint.new((i - 1) / (#cols - 1), c))
	end
	return ColorSequence.new(keys)
end

-- Pick a random item: bigger chance = comes out more often.
function ItemData.roll(rng: Random): Item
	local x = rng:NextNumber() * ItemData.totalChance
	for _, item in list do
		x -= item.chance
		if x <= 0 then
			return item
		end
	end
	return list[1]
end

return ItemData
