TO = {}

SMODS.Atlas({
	key = "TO",
	path = "TwitchOverlay.png",
	px = 34,
	py = 34,
})

local update_selecting_hadn_ref = Game.update_selecting_hand
function Game:update_selecting_hand(dt)
	if not G.STATE_COMPLETE then
		sendMessageToConsole("Info", string.format("jokers [%s]", dump(G.GAME.used_jokers)))
		for i = 1, #G.hand.cards do
			sendMessageToConsole("Info", nil, string.format("Card [%s]", dump(G.hand.cards[i].base))) --base.id  = value
		end
	end
	update_selecting_hadn_ref(self, dt)
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
