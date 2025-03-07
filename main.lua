TO = {}

SMODS.Atlas({
	key = "modicon",
	path = "TwitchOverlay.png",
	px = 34,
	py = 34,
	enable = true,
	_disable = false,
})
local getUIBox = assert(SMODS.load_file("test.lua", "TwitchOverlay"))()

--[[
-- you can call localize from anywhere, you just need the key and set of the card you're trying to localize
-- you can probably create a local localization object and use that instead, might need to setup your own localization function tho.
-- the localization function is in functions/misc_functions.lua line 1689
--]]

local function getTextFromNode(node)
	if node.n == G.UIT.T then
		return node.config.text
	elseif node.n == G.UIT.O then
		local text = ""
		if node.config.object.config.random_element then
			if type(node.config.object.config.string[1]) == "string" then
				text = text
			else
				text = text .. " (random value between 0 and 23) mult"
			end
		else
			for _, v in ipairs(node.config.object.config.string) do
				text = text .. v
			end
		end
		return text
	elseif node.n == G.UIT.C then
		local text = ""
		for _, colNode in ipairs(node.nodes) do
			text = text .. getTextFromNode(colNode)
		end
		return text
	else
		error("not supported type")
	end
end

local function getDataFromCards(uiBox)
	local data = {}

	local sideBoxes = {}
	for i, box in ipairs(uiBox.info) do
		sideBoxes[i] = {}
		local currentText = ""
		sideBoxes[i].name = box.name
		for _, line in ipairs(box) do
			for _, node in ipairs(line) do
				currentText = currentText .. getTextFromNode(node)
			end
			currentText = currentText .. "\n"
		end
		sideBoxes[i].currentText = currentText
	end
	data.sideBoxes = sideBoxes
	local description = ""
	for _, line in ipairs(uiBox.main) do
		for _, part in ipairs(line) do
			description = description .. getTextFromNode(part)
		end
		description = description .. "\n"
	end
	data.description = description
	local name = ""
	if type(uiBox.name) == "table" then
		for _, line in ipairs(uiBox.name) do
			name = name .. getTextFromNode(line) .. "\n"
		end
	else
		name = "Stone card"
	end
	data.name = name
	return data
end

local function jsonify(table)
	local new = {}
	for k, v in pairs(table) do
		if type(k) == "number" then
			k = tostring(k)
		end

		if type(v) ~= "table" then
			new[k] = v
		else
			new[k] = jsonify(v)
		end
	end
	return new
end

local function getAllCardContents(table)
	local currentlyAvailableJokers = {}

	for i, card in ipairs(table) do
		local uiBox = getUIBox(card:generate_UIBox_ability_table())
		local currentCardData = getDataFromCards(uiBox)
		currentlyAvailableJokers[i] = currentCardData
	end
	return currentlyAvailableJokers
end

local emplace_ref = nil
local emplace_func = function(self, card, location, stay_flipped)
	emplace_ref(self, card, location, stay_flipped)
	print(JSON.encode(jsonify(getAllCardContents(self.cards))))
end

local remove_ref = nil
local remove_func = function(self, card, discarded_only)
	remove_ref(self, card, discarded_only)
	print(JSON.encode(jsonify(getAllCardContents(self.cards))))
end

local update_ref = Game.update
function Game:update(dt)
	update_ref(self, dt)
end

local set_edition_ref = Card.set_edition
function Card:set_edition(edition, immediate, silent)
	set_edition_ref(self, edition, immediate, silent)
	if edition ~= nil and immediate ~= nil then
		local uiBox = getUIBox(self:generate_UIBox_ability_table())
		local currentCaed = getDataFromCards(uiBox)
		print(JSON.encode(jsonify(currentCaed)))
	end
end

local newJokerEmplaceSet = false
local newTarotEmplaceSet = false
local update_selecting_hadn_ref = Game.update_selecting_hand
function Game:update_selecting_hand(dt)
	if G.jokers ~= nil and newJokerEmplaceSet == false then
		emplace_ref = G.jokers.emplace
		remove_ref = G.jokers.remove_card
		G.jokers.emplace = emplace_func
		G.jokers.remove_card = remove_func
		newJokerEmplaceSet = true
	end
	if G.consumeables ~= nil and newTarotEmplaceSet == false then
		emplace_ref = G.consumeables.emplace
		remove_ref = G.consumeables.remove_card
		G.consumeables.emplace = emplace_func
		G.consumeables.remove_card = remove_func
		newTarotEmplaceSet = true
	end
	if not G.STATE_COMPLETE then
		local currentHand = getAllCardContents(G.hand.cards)
		print(JSON.encode(jsonify(currentHand)))
	end
	update_selecting_hadn_ref(self, dt)
end

local set_ability_ref = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
	set_ability_ref(self, center, initial, delay_sprites)
	if initial == nil and center.set == "Enhanced" then
		local uiBox = getUIBox(self:generate_UIBox_ability_table())
		local currentCard = getDataFromCards(uiBox)
		print(JSON.encode(jsonify(currentCard)))
	end
end

local gotBaffoonContent = false
local update_baffoon_pack_ref = Game.update_buffoon_pack
function Game:update_buffoon_pack(dt)
	if
		G.pack_cards ~= nil
		and G.pack_cards.cards ~= nil
		and G.pack_cards.cards[1] ~= nil
		and gotBaffoonContent == false
	then
		gotBaffoonContent = true
		local boosterContent = getAllCardContents(G.pack_cards.cards)
		print(JSON.encode(jsonify(boosterContent)))
	end

	return update_baffoon_pack_ref(self, dt)
end

local gotCelestialContent = false
local update_celestial_pack_ref = Game.update_celestial_pack
function Game:update_celestial_pack(dt)
	if
		G.pack_cards ~= nil
		and G.pack_cards.cards ~= nil
		and G.pack_cards.cards[1] ~= nil
		and gotCelestialContent == false
	then
		gotCelestialContent = true
		local boosterContent = getAllCardContents(G.pack_cards.cards)
		print(JSON.encode(jsonify(boosterContent)))
	end

	return update_celestial_pack_ref(self, dt)
end

local gotTarotContent = false
local update_arcana_pack_ref = Game.update_arcana_pack
function Game:update_celestial_pack(dt)
	if
		G.pack_cards ~= nil
		and G.pack_cards.cards ~= nil
		and G.pack_cards.cards[1] ~= nil
		and gotTarotContent == false
	then
		gotTarotContent = true
		local boosterContent = getAllCardContents(G.pack_cards.cards)
		print(JSON.encode(jsonify(boosterContent)))
	end

	return update_arcana_pack_ref(self, dt)
end

local gotStandardContent = false
local update_standard_pack_ref = Game.update_standard_pack
function Game:update_celestial_pack(dt)
	if
		G.pack_cards ~= nil
		and G.pack_cards.cards ~= nil
		and G.pack_cards.cards[1] ~= nil
		and gotStandardContent == false
	then
		gotStandardContent = true
		local boosterContent = getAllCardContents(G.pack_cards.cards)
		print(JSON.encode(jsonify(boosterContent)))
	end

	return update_standard_pack_ref(self, dt)
end

local gotSpectralContent = false
local update_spectral_pack_ref = Game.update_spectral_pack
function Game:update_celestial_pack(dt)
	if
		G.pack_cards ~= nil
		and G.pack_cards.cards ~= nil
		and G.pack_cards.cards[1] ~= nil
		and gotSpectralContent == false
	then
		gotSpectralContent = true
		local boosterContent = getAllCardContents(G.pack_cards.cards)
		print(JSON.encode(jsonify(boosterContent)))
	end

	return update_spectral_pack_ref(self, dt)
end

local gotModdedContent = false
local update_pack_ref = SMODS.Booster.update_pack
function SMODS.Booster.update_pack(dt)
	if
		G.pack_cards ~= nil
		and G.pack_cards.cards ~= nil
		and G.pack_cards.cards[1] ~= nil
		and gotModdedContent == false
	then
		gotModdedContent = true
		local boosterContent = getAllCardContents(G.pack_cards.cards)
		print(JSON.encode(jsonify(boosterContent)))
	end
	return update_pack_ref(dt)
end

-- local calculate_context_ref = SMODS.calculate_context
-- function SMODS.calculate_context(context, return_table)
-- 	if context.reroll_shop then
-- 		-- if G.shop_jokers ~= nil and G.shop_jokers.cards ~= nil then
-- 		-- 	local currentlyAvailableJokers = getAllCardContents(G.shop_jokers.cards)
-- 		-- 	print(JSON.encode(jsonify(currentlyAvailableJokers)))
-- 		-- end
-- 		if G.shop_vouchers ~= nil and G.shop_vouchers.cards ~= nil then
-- 			local currentlyAvailabkleVouchers = getAllCardContents(G.shop_vouchers.cards)
-- 			print(JSON.encode(jsonify(currentlyAvailabkleVouchers)))
-- 		end
-- 		if G.shop_booster ~= nil and G.shop_booster.cards ~= nil then
-- 			local currentlyAvailableBoosters = getAllCardContents(G.shop_booster.cards)
-- 			print(JSON.encode(jsonify(currentlyAvailableBoosters)))
-- 		end
-- 	end
-- 	return calculate_context_ref(context, return_table)
-- end
--
--
--[[
-- I just need to figure out when each event needs to be set.
-- right now when coming back from a blind emplace do not trigger
-- also when loading from save is not set for jokers and consumeables
--]]

local function getDataFromSaveState(table)
	local availableCards = {}

	if table ~= nil then
		for i, cards in ipairs(table.cards) do
			local card = Card(0, 0, G.CARD_W, G.CARD_H, G.P_CENTERS.j_joker, G.P_CENTERS.c_base)
			card:load(cards)
			local uiBox = getUIBox(card:generate_UIBox_ability_table())
			local currentCard = getDataFromCards(uiBox)
			availableCards[i] = currentCard
			card:remove()
		end
	end
	return availableCards
end

-- probably need to set emplace for jokers and consumeables here

local start_run_ref = Game.start_run
function Game:start_run(args)
	if
		args.savetext ~= nil
		and args.savetext.cardAreas ~= nil
		and args.savetext.cardAreas.shop_booster ~= nil
		and args.savetext.cardAreas.shop_jokers ~= nil
		and args.savetext.cardAreas.shop_vouchers ~= nil
	then
		local availableCards = getDataFromSaveState(args.savetext.cardAreas.shop_jokers)
		local availableVouchers = getDataFromSaveState(args.savetext.cardAreas.shop_vouchers)
		local availableBooster = getDataFromSaveState(args.savetext.cardAreas.shop_booster)
		print(JSON.encode(jsonify(availableCards)))
		print(JSON.encode(jsonify(availableVouchers)))
		print(JSON.encode(jsonify(availableBooster)))
	end
	start_run_ref(self, args)
end

local newShopJokerEmplaceSet = false
local newShopVouchersEmplaceSet = false
local newShopBoosterEmplaceSet = false
local loadShopJokersEmplaceSet = false
local update_shop_ref = Game.update_shop
function Game:update_shop(dt)
	if G.shop_jokers ~= nil and newShopJokerEmplaceSet == false then
		emplace_ref = G.shop_jokers.emplace
		G.shop_jokers.emplace = emplace_func
		newShopJokerEmplaceSet = true
	end
	if G.shop_vouchers ~= nil and newShopVouchersEmplaceSet == false then
		emplace_ref = G.shop_vouchers.emplace
		G.shop_vouchers.emplace = emplace_func
		newShopVouchersEmplaceSet = true
	end
	if G.shop_booster ~= nil and newShopBoosterEmplaceSet == false then
		emplace_ref = G.shop_booster.emplace
		G.shop_booster.emplace = emplace_func
		newShopBoosterEmplaceSet = true
	end
	-- if G.load_shop_jokers ~= nil and loadShopJokersEmplaceSet == false then
	-- 	emplace_ref = G.load_shop_jokers.emplace
	-- 	G.load_shop_jokers.emplace = emplace_func
	-- 	loadShopJokersEmplaceSet = true
	-- end

	if not G.STATE_COMPLETE then
		G.GAME.dollars = 99999999
		if
			G.load_shop_vouchers ~= nil
			and G.load_shop_vouchers.cards ~= nil
			and G.load_shop_vouchers.cards[1].generate_UIBox_ability_table ~= nil
		then
			local currentlyAvailabkleVouchers = getAllCardContents(G.load_shop_vouchers.cards)
			print(JSON.encode(jsonify(currentlyAvailabkleVouchers)))
		else
			if
				G.shop_vouchers ~= nil
				and G.shop_vouchers.cards ~= nil
				and G.shop_vouchers.cards[1].generate_UIBox_ability_table ~= nil
			then
				local currentlyAvailableVouchers = getAllCardContents(G.shop_vouchers.cards)
				print(JSON.encode(jsonify(currentlyAvailableVouchers)))
			end
		end
		if
			G.load_shop_jokers ~= nil
			and G.load_shop_jokers.cards ~= nil
			and G.load_shop_jokers.cards[1].generate_UIBox_ability_table ~= nil
		then
			local currentlyAvailableJokers = getAllCardContents(G.shop_jokers.cards)
			print(JSON.encode(jsonify(currentlyAvailableJokers)))
		else
			if
				G.shop_jokers ~= nil
				and G.shop_jokers.cards ~= nil
				and G.shop_jokers.cards[1].generate_UIBox_ability_table ~= nil
			then
				local currentlyAvailableJokers = getAllCardContents(G.shop_jokers.cards)
				print(JSON.encode(jsonify(currentlyAvailableJokers)))
			end
		end
		if
			G.load_shop_booster ~= nil
			and G.load_shop_booster.cards ~= nil
			and G.load_shop_booster.cards[1] ~= nil
			and G.load_shop_booster.cards[1].generate_UIBox_ability_table ~= nil
		then
			local currentlyAvailableBoosters = getAllCardContents(G.load_shop_booster.cards)
			print(JSON.encode(jsonify(currentlyAvailableBoosters)))
		else
			if
				G.shop_booster ~= nil
				and G.shop_booster.cards ~= nil
				and G.shop_booster.cards[1].generate_UIBox_ability_table ~= nil
			then
				local currentlyAvailableBoosters = getAllCardContents(G.shop_booster.cards)
				print(JSON.encode(jsonify(currentlyAvailableBoosters)))
			end
		end
	end
	update_shop_ref(self, dt)
end
