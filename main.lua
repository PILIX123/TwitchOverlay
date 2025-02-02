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
		sendMessageToConsole("Info", string.format("jokers [%s]", dump(G.GAME.used_jokers)))
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

local test = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
	if center.set == "Enhanced" and center.name ~= "Default Base" then
		print("new") -- currently prints both cards and other type
	end
	test(self, center, initial, delay_sprites)
end

local called = false

local update_play_tarot_ref = Game.update_play_tarot
function Game:update_play_tarot(dt)
	update_play_tarot_ref(self, dt)

	--[[if not called then
		tprint(G.hand.cards[1].ability) -- ability.effect for the cars effect
		called = true
	end]]
	--
end

local update_shop_ref = Game.update_shop
function Game:update_shop(dt)
	if not G.STATE_COMPLETE then
		G.GAME.dollars = 99999999
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

function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

function starts_with(str, start)
	return str:sub(1, #start) == start
end
