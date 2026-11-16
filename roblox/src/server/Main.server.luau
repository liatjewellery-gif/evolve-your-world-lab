--[[
	EVOLVE YOUR WORLD - the server.

	How the game works (from Adam's doc):
	 1. Every second a material or creature comes out of the black box and walks down the red carpet.
	 2. Walk up to it and buy it. It walks to your base (other players can still buy it on the way;
	    then you get your money back).
	 3. It goes into a free green tank and sleeps there, hanging from a wire.
	 4. Press the red button next to the tank: a laser beam shoots into the sphere, and the item's
	    world grows inside the sphere. From then on it earns money every second.
	 5. The money collects on the green pad. Stand on the pad to take it.
	 6. Sell an item from its tank (you get 90% back). Buy more machines on the blue pad
	    (machine 7 to 10, each one also makes the sphere bigger).
	 7. Everything is saved. While you are away you still earn 10%, for up to 2 hours.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local PhysicsService = game:GetService("PhysicsService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local ItemData = require(Shared.ItemData)
local Util = require(Shared.Util)
local Characters = require(Shared.Characters)
local Map = require(script.Parent.Map)
local Data = require(script.Parent.Data)

-- remotes -----------------------------------------------------------------------------
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
local Notify = Instance.new("RemoteEvent")
Notify.Name = "Notify"
Notify.Parent = remotes
local Collected = Instance.new("RemoteEvent")
Collected.Name = "Collected"
Collected.Parent = remotes
local Bought = Instance.new("RemoteEvent")
Bought.Name = "Bought"
Bought.Parent = remotes
remotes.Parent = ReplicatedStorage

-- collision: walkers don't bump into players or each other ----------------------------
PhysicsService:RegisterCollisionGroup("Walkers")
PhysicsService:RegisterCollisionGroup("Players")
PhysicsService:CollisionGroupSetCollidable("Walkers", "Walkers", false)
PhysicsService:CollisionGroupSetCollidable("Walkers", "Players", false)

-- world --------------------------------------------------------------------------------
Map.buildWorld()
local plots = Map.buildPlots()
local walkers = Instance.new("Folder")
walkers.Name = "Brainrots"
walkers.Parent = workspace

type PState = {
	player: Player,
	plot: Model,
	save: Data.Save,
	money: NumberValue,
	reserved: { [number]: Model },
	loaded: boolean,
}
local states: { [Player]: PState } = {}

local function notify(player: Player, text: string, kind: string?)
	Notify:FireClient(player, text, kind or "info")
end

local function setMoney(st: PState, value: number)
	st.save.money = value
	st.money.Value = value
end

local function tankOf(plot: Model, i: number): Model?
	return (plot:FindFirstChild("Tanks") :: Folder):FindFirstChild("Tank" .. i) :: Model?
end

local function incomeOf(st: PState): number
	local total = 0
	for _, t in st.save.tanks do
		if t.active and ItemData.byId[t.id] then
			total += ItemData.byId[t.id].income
		end
	end
	return total
end

local function updateShop(plot: Model)
	local shop = plot:FindFirstChild("MachinePad") :: BasePart
	local label = (shop:FindFirstChild("Info") :: BillboardGui):FindFirstChild("Price") :: TextLabel
	local prompt = shop:FindFirstChild("BuyMachine") :: ProximityPrompt
	local m = plot:GetAttribute("Machines") :: number
	if m >= Config.MaxMachines then
		label.Text = "MAX"
		prompt.Enabled = false
	else
		label.Text = Util.money(Config.MachinePrices[m + 1])
		prompt.ObjectText = "Machine " .. (m + 1)
		prompt.Enabled = true
	end
end

local function updatePad(plot: Model)
	local pad = plot:FindFirstChild("CollectPad") :: BasePart
	local label = (pad:FindFirstChild("Info") :: BillboardGui):FindFirstChild("Amount") :: TextLabel
	label.Text = Util.money(plot:GetAttribute("Pending") :: number)
end

-- tanks --------------------------------------------------------------------------------
local function fitSleeper(tank: Model, plot: Model, id: string)
	local old = tank:FindFirstChild("Sleeper")
	if old then
		old:Destroy()
	end
	local info = tank:FindFirstChild("Info")
	if info then
		info:Destroy()
	end
	if id == "" then
		return
	end
	local m = Characters.buildStatic(id)
	m.Name = "Sleeper"
	local i = tank:GetAttribute("Index") :: number
	local tl = Map.tankLocal(i)
	local inward = plot:GetPivot():VectorToWorldSpace(Vector3.new((tl.X < 0) and 1 or -1, 0, 0))
	local yaw = math.atan2(-inward.X, -inward.Z)
	m:PivotTo(CFrame.new(m:GetPivot().Position) * CFrame.Angles(0, yaw, 0))
	local size = m:GetExtentsSize()
	local k = math.min(5.2 / size.Y, 3.6 / math.max(size.X, size.Z))
	m:ScaleTo(m:GetScale() * k)
	local center = (plot:GetPivot() * CFrame.new(tl + Vector3.new(0, 4.6, 0))).Position
	local bb = m:GetBoundingBox()
	m:PivotTo(m:GetPivot() + (center - bb.Position))
	m:SetAttribute("Base", m:GetPivot())
	m.Parent = tank

	local item = ItemData.byId[id]
	local cap = tank:FindFirstChild("Cap") :: BasePart
	local gui = Util.billboard(cap, UDim2.fromOffset(200, 64), Vector3.new(0, 3.2, 0), 70)
	gui.Name = "Info"
	gui.Parent = tank
	gui.Adornee = cap
	Util.label(gui, item.name, ItemData.rarityColor[item.rarity], UDim2.fromScale(1, 0.55), UDim2.fromScale(0, 0))
	local inc = Util.label(gui, Util.money(item.income) .. "/s", Color3.fromRGB(110, 255, 120), UDim2.fromScale(1, 0.45), UDim2.fromScale(0, 0.55))
	inc.Name = "Income"
end

local function setTank(plot: Model, i: number, id: string, active: boolean)
	local tank = tankOf(plot, i)
	if not tank then
		return
	end
	local changed = tank:GetAttribute("ItemId") ~= id
	tank:SetAttribute("ItemId", id)
	tank:SetAttribute("Active", active and id ~= "")
	if changed then
		fitSleeper(tank, plot, id)
	end
	local button = tank:FindFirstChild("Button") :: BasePart
	local activate = button:FindFirstChild("Activate") :: ProximityPrompt
	local sell = (tank:FindFirstChild("Glass") :: BasePart):FindFirstChild("Sell") :: ProximityPrompt
	activate.Enabled = id ~= "" and not active
	sell.Enabled = id ~= ""
	if id ~= "" then
		local item = ItemData.byId[id]
		activate.ObjectText = item.name
		sell.ObjectText = item.name .. "  +" .. Util.money(item.price * Config.SellReturn)
	end
	button.Color = (id ~= "" and not active) and Color3.fromRGB(255, 40, 40) or Color3.fromRGB(60, 255, 110)
	if id == "" then
		button.Color = Color3.fromRGB(120, 120, 130)
	end
end

local function hookTank(plot: Model, tank: Model)
	local i = tank:GetAttribute("Index") :: number
	local button = tank:FindFirstChild("Button") :: BasePart
	local activate = button:FindFirstChild("Activate") :: ProximityPrompt
	local sell = (tank:FindFirstChild("Glass") :: BasePart):FindFirstChild("Sell") :: ProximityPrompt

	activate.Triggered:Connect(function(player)
		local st = states[player]
		if not st or st.plot ~= plot or not st.loaded then
			return
		end
		local t = st.save.tanks[tostring(i)]
		if not t or t.active then
			return
		end
		t.active = true
		setTank(plot, i, t.id, true)
		local item = ItemData.byId[t.id]
		notify(player, item.name .. " launched into your world! +" .. Util.money(item.income) .. " every second", "good")
		if st.save.tutorial ~= 0 then
			st.save.tutorial = 0
			player:SetAttribute("Tutorial", 0)
		end
	end)

	sell.Triggered:Connect(function(player)
		local st = states[player]
		if not st or st.plot ~= plot or not st.loaded then
			return
		end
		local t = st.save.tanks[tostring(i)]
		if not t then
			return
		end
		local item = ItemData.byId[t.id]
		local back = math.floor(item.price * Config.SellReturn)
		st.save.tanks[tostring(i)] = nil
		setTank(plot, i, "", false)
		setMoney(st, st.save.money + back)
		notify(player, "Sold " .. item.name .. " for " .. Util.money(back), "money")
	end)
end

local function makeTank(plot: Model, i: number)
	if tankOf(plot, i) then
		return
	end
	local tank = Map.buildTank(plot, i)
	hookTank(plot, tank)
end

local function setMachines(st: PState, n: number)
	local plot = st.plot
	st.save.machines = n
	for i = 1, n do
		makeTank(plot, i)
	end
	plot:SetAttribute("Machines", n)
	Map.buildSphere(plot, Config.sphereRadius(n))
	updateShop(plot)
end

local function grantMachine(st: PState)
	if st.save.machines >= Config.MaxMachines then
		return
	end
	setMachines(st, st.save.machines + 1)
	notify(st.player, "New machine! Your sphere got bigger.", "good")
end

-- walkers on the red carpet ------------------------------------------------------------
local rng = Random.new()
local tokenCounter = 0

local function newToken(m: Model): number
	tokenCounter += 1
	m:SetAttribute("Walk", tokenCounter)
	return tokenCounter
end

local function flat(v: Vector3): Vector3
	return Vector3.new(v.X, 0, v.Z)
end

-- Walks through the points. Returns false if the walk was replaced or the model is gone.
local function walkPath(m: Model, points: { Vector3 }, token: number): boolean
	local hum = m:FindFirstChildOfClass("Humanoid")
	local root = m.PrimaryPart
	if not hum or not root then
		return false
	end
	for _, p in points do
		local started = os.clock()
		local lastIssue = 0
		while true do
			if not m.Parent or m:GetAttribute("Walk") ~= token then
				return false
			end
			local d = (flat(root.Position) - flat(p)).Magnitude
			if d < 1.6 then
				break
			end
			if os.clock() - lastIssue > 3 then
				hum:MoveTo(p)
				lastIssue = os.clock()
			end
			if os.clock() - started > 40 then
				-- stuck: hop to the point
				m:PivotTo(CFrame.new(p + Vector3.new(0, (m:GetAttribute("Hip") :: number) + 0.5, 0)) * root.CFrame.Rotation)
				break
			end
			task.wait(0.1)
		end
	end
	return true
end

local function walkerLabel(m: Model, item: ItemData.Item)
	local root = m.PrimaryPart :: BasePart
	local size = m:GetExtentsSize()
	local hip = m:GetAttribute("Hip") :: number
	local bb = Util.billboard(root, UDim2.fromOffset(230, 118), Vector3.new(0, size.Y - hip + 2.2, 0), 75)
	bb.Name = "Tag"
	local owner = Util.label(bb, "", Color3.fromRGB(255, 255, 255), UDim2.fromScale(1, 0.18), UDim2.fromScale(0, 0))
	owner.Name = "Owner"
	Util.label(bb, item.name, Color3.fromRGB(255, 255, 255), UDim2.fromScale(1, 0.26), UDim2.fromScale(0, 0.18))
	local rar = Util.label(bb, item.rarity, ItemData.rarityColor[item.rarity], UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.44))
	rar.Name = "Rarity"
	Util.label(bb, Util.money(item.price), Color3.fromRGB(255, 230, 80), UDim2.fromScale(1, 0.2), UDim2.fromScale(0, 0.64))
	Util.label(bb, Util.money(item.income) .. "/s", Color3.fromRGB(110, 255, 120), UDim2.fromScale(1, 0.16), UDim2.fromScale(0, 0.84))
end

local function freeTank(st: PState): number?
	for i = 1, st.save.machines do
		if not st.save.tanks[tostring(i)] and not st.reserved[i] then
			return i
		end
	end
	return nil
end

local function arrive(player: Player, m: Model, slot: number)
	local st = states[player]
	local id = m:GetAttribute("ItemId") :: string
	m:Destroy()
	if not st then
		return
	end
	st.reserved[slot] = nil
	st.save.tanks[tostring(slot)] = { id = id, active = false }
	setTank(st.plot, slot, id, false)
	notify(player, ItemData.byId[id].name .. " is in tank " .. slot .. ". Press the red button to launch the beam!", "info")
end

local function buy(player: Player, m: Model)
	local st = states[player]
	if not st or not st.loaded or not m.Parent then
		return
	end
	local state = m:GetAttribute("State")
	if state ~= "Carpet" and state ~= "ToBase" then
		return
	end
	local prevOwner = m:GetAttribute("OwnerUserId") :: number
	if prevOwner == player.UserId then
		return
	end
	local item = ItemData.byId[m:GetAttribute("ItemId") :: string]
	if st.save.money < item.price then
		notify(player, "Not enough money! " .. item.name .. " costs " .. Util.money(item.price), "bad")
		return
	end
	local slot = freeTank(st)
	if not slot then
		notify(player, "All your machines are full! Sell something or buy a new machine.", "bad")
		return
	end
	setMoney(st, st.save.money - item.price)

	if prevOwner ~= 0 then
		local prev = Players:GetPlayerByUserId(prevOwner)
		local prevSlot = m:GetAttribute("Slot") :: number?
		if prev and states[prev] then
			local pst = states[prev]
			setMoney(pst, pst.save.money + item.price)
			if prevSlot then
				pst.reserved[prevSlot] = nil
			end
			notify(prev, player.DisplayName .. " bought your " .. item.name .. " on the way! You got your money back.", "bad")
		end
	end

	st.reserved[slot] = m
	m:SetAttribute("State", "ToBase")
	m:SetAttribute("OwnerUserId", player.UserId)
	m:SetAttribute("Slot", slot)
	local tag = (m.PrimaryPart :: BasePart):FindFirstChild("Tag")
	if tag then
		(tag:FindFirstChild("Owner") :: TextLabel).Text = player.DisplayName .. "'s"
	end
	if st.save.tutorial == 1 then
		st.save.tutorial = 2
		player:SetAttribute("Tutorial", 2)
	end
	Bought:FireClient(player, item.id)
	notify(player, "You got " .. item.name .. "! It is walking to your base.", "good")

	local token = newToken(m)
	task.spawn(function()
		local ok = walkPath(m, Map.pathToTank(st.plot, slot), token)
		if ok and m.Parent and m:GetAttribute("OwnerUserId") == player.UserId and states[player] == st then
			arrive(player, m, slot)
		end
	end)
end

local function setGroup(m: Instance, group: string)
	for _, d in m:GetDescendants() do
		if d:IsA("BasePart") then
			d.CollisionGroup = group
		end
	end
end

local function spawnWalker(item: ItemData.Item)
	local m = Characters.build(item.id)
	m.Name = item.id
	m:SetAttribute("State", "Carpet")
	m:SetAttribute("OwnerUserId", 0)
	m:SetAttribute("Price", item.price)
	local root = m.PrimaryPart :: BasePart
	root.CanCollide = true
	setGroup(m, "Walkers")
	walkerLabel(m, item)

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "Buy"
	prompt.ActionText = "Buy  " .. Util.money(item.price)
	prompt.ObjectText = item.name
	prompt.HoldDuration = 0.25
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = root
	prompt.Triggered:Connect(function(player)
		buy(player, m)
	end)

	Characters.place(m, Vector3.new(Config.CarpetStartX, 0.2, 0), -math.pi / 2)
	m.Parent = walkers
	pcall(function()
		root:SetNetworkOwner(nil)
	end)

	local token = newToken(m)
	task.spawn(function()
		local ok = walkPath(m, { Vector3.new(Config.CarpetEndX, 0, 0) }, token)
		if ok and m.Parent and m:GetAttribute("State") == "Carpet" then
			m:SetAttribute("State", "Gone")
			task.wait(0.4)
			m:Destroy()
		end
	end)
end

task.spawn(function()
	task.wait(2)
	while true do
		spawnWalker(ItemData.roll(rng))
		task.wait(Config.SpawnInterval)
	end
end)

-- plots: shop pad, collect pad ---------------------------------------------------------
for _, plot in plots do
	for _, tank in (plot:FindFirstChild("Tanks") :: Folder):GetChildren() do
		hookTank(plot, tank :: Model)
	end
	updateShop(plot)
	updatePad(plot)

	local shop = plot:FindFirstChild("MachinePad") :: BasePart
	local buyMachine = shop:FindFirstChild("BuyMachine") :: ProximityPrompt
	buyMachine.Triggered:Connect(function(player)
		local st = states[player]
		if not st or st.plot ~= plot or not st.loaded then
			return
		end
		local nextN = st.save.machines + 1
		if nextN > Config.MaxMachines then
			return
		end
		local price = Config.MachinePrices[nextN]
		if st.save.money >= price then
			setMoney(st, st.save.money - price)
			grantMachine(st)
		else
			local product = Config.MachineRobuxProducts[nextN]
			if product and product ~= 0 then
				MarketplaceService:PromptProductPurchase(player, product)
			else
				notify(player, "You need " .. Util.money(price) .. " for machine " .. nextN, "bad")
			end
		end
	end)

	local pad = plot:FindFirstChild("CollectPad") :: BasePart
	local debounce: { [Player]: number } = {}
	pad.Touched:Connect(function(hit)
		local char = hit:FindFirstAncestorOfClass("Model")
		local player = char and Players:GetPlayerFromCharacter(char)
		if not player then
			return
		end
		local st = states[player]
		if not st or st.plot ~= plot or not st.loaded then
			return
		end
		if debounce[player] and os.clock() - debounce[player] < 0.6 then
			return
		end
		debounce[player] = os.clock()
		local amount = st.save.pending
		if amount < 1 then
			return
		end
		st.save.pending = 0
		plot:SetAttribute("Pending", 0)
		updatePad(plot)
		setMoney(st, st.save.money + amount)
		Collected:FireClient(player, amount, pad.Position)
	end)
end

-- income every second -------------------------------------------------------------------
task.spawn(function()
	while true do
		task.wait(1)
		for _, st in states do
			if st.loaded then
				local inc = incomeOf(st)
				if inc > 0 then
					st.save.pending += inc
					st.plot:SetAttribute("Pending", st.save.pending)
					st.plot:SetAttribute("Income", inc)
					updatePad(st.plot)
				else
					st.plot:SetAttribute("Income", 0)
				end
			end
		end
	end
end)

-- robux machines ------------------------------------------------------------------------
MarketplaceService.ProcessReceipt = function(info)
	local player = Players:GetPlayerByUserId(info.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	local st = states[player]
	if not st or not st.loaded then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	for _, pid in Config.MachineRobuxProducts do
		if pid ~= 0 and pid == info.ProductId then
			grantMachine(st)
			Data.save(player.UserId, st.save)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

-- players --------------------------------------------------------------------------------
local function freePlot(): Model?
	for _, plot in plots do
		if plot:GetAttribute("OwnerUserId") == 0 then
			return plot
		end
	end
	return nil
end

local function resetPlot(plot: Model)
	for _, tank in (plot:FindFirstChild("Tanks") :: Folder):GetChildren() do
		local i = tank:GetAttribute("Index") :: number
		setTank(plot, i, "", false)
		if i > Config.StartMachines then
			tank:Destroy()
		end
	end
	plot:SetAttribute("OwnerUserId", 0)
	plot:SetAttribute("OwnerName", "")
	plot:SetAttribute("Machines", Config.StartMachines)
	plot:SetAttribute("Pending", 0)
	plot:SetAttribute("Income", 0)
	Map.buildSphere(plot, Config.sphereRadius(Config.StartMachines))
	local sign = (plot:FindFirstChild("GateTop") :: BasePart):FindFirstChild("Sign") :: BillboardGui
	local label = sign:FindFirstChild("OwnerName") :: TextLabel
	label.Text = "EMPTY BASE"
	label.TextTransparency = 0.5
	updateShop(plot)
	updatePad(plot)
end

local function onCharacter(st: PState, char: Model)
	char:WaitForChild("HumanoidRootPart", 10)
	task.wait(0.1)
	setGroup(char, "Players")
	char.DescendantAdded:Connect(function(d)
		if d:IsA("BasePart") then
			d.CollisionGroup = "Players"
		end
	end)
	char:PivotTo(Map.spawnPoint(st.plot))
end

Players.PlayerAdded:Connect(function(player)
	local plot = freePlot()
	if not plot then
		task.wait(2)
		notify(player, "This server is full (10 bases). Try another server!", "bad")
		return
	end
	plot:SetAttribute("OwnerUserId", player.UserId)
	plot:SetAttribute("OwnerName", player.DisplayName)

	local ls = Instance.new("Folder")
	ls.Name = "leaderstats"
	local money = Instance.new("NumberValue")
	money.Name = "Money"
	money.Parent = ls
	ls.Parent = player

	local st: PState = {
		player = player,
		plot = plot,
		save = Data.default(),
		money = money,
		reserved = {},
		loaded = false,
	}
	states[player] = st
	player:SetAttribute("PlotIndex", plot:GetAttribute("Index"))

	player.CharacterAdded:Connect(function(char)
		onCharacter(st, char)
	end)
	if player.Character then
		task.spawn(onCharacter, st, player.Character)
	end

	local save, isNew = Data.load(player.UserId)
	if not player.Parent then
		return
	end
	st.save = save
	setMoney(st, save.money)
	setMachines(st, math.clamp(save.machines, Config.StartMachines, Config.MaxMachines))
	for k, t in save.tanks do
		local i = tonumber(k)
		if i and ItemData.byId[t.id] then
			setTank(plot, i, t.id, t.active)
		else
			save.tanks[k] = nil
		end
	end

	local sign = (plot:FindFirstChild("GateTop") :: BasePart):FindFirstChild("Sign") :: BillboardGui
	local label = sign:FindFirstChild("OwnerName") :: TextLabel
	label.Text = player.DisplayName .. "'s Base"
	label.TextTransparency = 0

	local away = 0
	if not isNew then
		local seconds = math.clamp(os.time() - save.lastSeen, 0, Config.OfflineMaxSeconds)
		away = math.floor(incomeOf(st) * Config.OfflineRate * seconds)
		save.pending += away
	end
	plot:SetAttribute("Pending", save.pending)
	updatePad(plot)

	player:SetAttribute("Tutorial", save.tutorial)
	player:SetAttribute("FirstJoin", not save.introSeen)
	save.introSeen = true
	st.loaded = true

	if away > 0 then
		task.delay(4, function()
			notify(player, "While you were away you earned " .. Util.money(away) .. "! Go to the green pad.", "money")
		end)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local st = states[player]
	if not st then
		return
	end
	if st.loaded then
		Data.save(player.UserId, st.save)
	end
	states[player] = nil
	for _, m in walkers:GetChildren() do
		if m:GetAttribute("OwnerUserId") == player.UserId then
			m:Destroy()
		end
	end
	resetPlot(st.plot)
end)

task.spawn(function()
	while true do
		task.wait(Config.AutosaveSeconds)
		for player, st in states do
			if st.loaded then
				Data.save(player.UserId, st.save)
			end
		end
	end
end)

game:BindToClose(function()
	for player, st in states do
		if st.loaded then
			Data.save(player.UserId, st.save)
		end
	end
end)
