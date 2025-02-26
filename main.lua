TO = {}

SMODS.Atlas({
	key = "modicon",
	path = "TwitchOverlay.png",
	px = 34,
	py = 34,
	enable = true,
})
local getUIBox = assert(SMODS.load_file("test.lua", "TwitchOverlay"))()

local update_selecting_hadn_ref = Game.update_selecting_hand
function Game:update_selecting_hand(dt)
	if not G.STATE_COMPLETE then
		for i = 1, #G.hand.cards do
			sendMessageToConsole("Info", nil, string.format("Card [%s]\n", G.hand.cards[i].base.name)) --base.id  = value
		end
		tprint(G.hand.cards[1].base)
	end
	update_selecting_hadn_ref(self, dt)
end

local set_edition_ref = Card.set_edition
function Card:set_edition(edition, immediate, silent)
	-- This is valid to get when editon changed
	set_edition_ref(self, edition, immediate, silent)
end

local set_ability_ref = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
	if center.set == "Enhanced" and center.name ~= "Default Base" then
		print("new")
	end
	set_ability_ref(self, center, initial, delay_sprites)
end

--[[
-- you can call localize from anywhere, you just need the key and set of the card you're trying to localize
-- you can probably create a local localization object and use that instead, might need to setup your own localization function tho.
-- the localization function is in functions/misc_functions.lua line 1689
--]]

local generate_card_ui_ref = generate_card_ui
generate_card_ui = function(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
	local return_val =
		generate_card_ui_ref(_c, full_UI_table, specific_vars, card_type, badges, hide_desc, main_start, main_end, card)
	return return_val
end

local function getTextFromNode(node)
	if node.n == G.UIT.T then
		return node.config.text
	elseif node.n == G.UIT.O then
		local text = ""
		for _, v in ipairs(node.config.object.config.string) do
			text = text .. v
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
	for _, line in ipairs(uiBox.name) do
		name = name .. getTextFromNode(line) .. "\n"
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

local calculate_context_ref = SMODS.calculate_context
function SMODS:calculate_context(context, return_table)
	if G.shop_jokers ~= nil and G.shop_jokers.cards ~= nil then
		local currentlyAvailableJokers = {}
		for i, card in ipairs(G.shop_jokers.cards) do
			local uiBox = getUIBox(card:generate_UIBox_ability_table())
			local currentCardData = getDataFromCards(uiBox)
			currentlyAvailableJokers[i] = currentCardData
		end
		print(JSON.encode(jsonify(currentlyAvailableJokers)))
	end
	calculate_context_ref(self, context, return_table)
end

function getFullDescription(parsed, loc_vars)
	local full = ""
	for _, lines in ipairs(parsed) do
		full = full .. "\n"
		for _, part in ipairs(lines) do
			for _, subpart in ipairs(part.strings) do
				full = full
					.. (
						type(subpart) == "string" and subpart
						or loc_vars ~= nil and loc_vars[tonumber(subpart[1])]
						or "OHNO"
					)
			end
		end
	end
	return full
end

local update_shop_ref = Game.update_shop
local shop_test
function Game:update_shop(dt)
	if not G.STATE_COMPLETE then
		G.GAME.dollars = 99999999
		if G.load_shop_jokers ~= nil then
			if G.load_shop_jokers.cards ~= nil then
				local key = G.load_shop_jokers.cards[1].save_fields.center
				local set = G.load_shop_jokers.cards[1].ability.set
			end
		end
	end

	update_shop_ref(self, dt)
end
function tprint(tbl, indent)
	if not indent then
		indent = 0
	end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			tprint(v, indent + 1)
		elseif type(v) == "boolean" then
			print(formatting .. tostring(v))
		elseif type(v) == "userdata" then
			print(formatting .. tostring(v))
		else
			print(formatting .. v)
		end
	end
end

function starts_with(str, start)
	return str:sub(1, #start) == start
end
