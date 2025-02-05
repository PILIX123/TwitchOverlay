TO = {}

SMODS.Atlas({
	key = "modicon",
	path = "TwitchOverlay.png",
	px = 34,
	py = 34,
})

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
	for i = 1, #return_val.main do
		for y = 1, #return_val.main[i] do
			print(return_val.main[i][y].config.text)
		end
	end
	return return_val
end

local calculate_context_ref = SMODS.calculate_context
function SMODS:calculate_context(context, return_table)
	print(G.shop_jokers.cards[1].label)
	calculate_context_ref(self, context, return_table)
end

local update_shop_ref = Game.update_shop
local shop_test
function Game:update_shop(dt)
	update_shop_ref(self, dt)
	if not G.STATE_COMPLETE then
		G.GAME.dollars = 99999999
	end

	setShop()
end

function setShop()
	if G.shop_jokers.cards ~= shop_test then
		shop_test = G.shop_jokers.cards
		print("gibberish")
	end
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
