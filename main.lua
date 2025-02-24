TO = {}

SMODS.Atlas({
	key = "modicon",
	path = "TwitchOverlay.png",
	px = 34,
	py = 34,
	enable = true,
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
	return return_val
end

local calculate_context_ref = SMODS.calculate_context
function SMODS:calculate_context(context, return_table)
	if G.jokers ~= nil and G.jokers.cards ~= nil then
		-- print(G.jokers.cards[1].ability)
	end
	if G.shop_jokers ~= nil and G.shop_jokers.cards ~= nil then
		local key = function(i)
			return G.shop_jokers.cards[i].config.center.key
		end
		local set = function(i)
			return G.shop_jokers.cards[i].config.center.set
		end
		local parsed = function(i)
			return G.localization.descriptions[set(i)][key(i)].text_parsed
		end
		local label = function(i)
			return G.shop_jokers.cards[i].label
		end
		local centerConfig = function(i)
			return G.shop_jokers.cards[i].config.center.config
		end
		local loc_vars = function(i)
			return get_loc_vars(label(i), set(i), centerConfig(i))
		end
		for i = 1, #G.shop_jokers.cards do
			local full = getFullDescription(parsed(i), loc_vars(i))
			print(full)
			print(label(i))
		end
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
				print(G.localization.descriptions[set][key].text_parsed)
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

function get_loc_vars(label, set, config)
	local loc_vars = nil
	if set == "Joker" then -- all remaining jokers
		if label == "Joker" then
			loc_vars = { config.mult ~= nil and config.mult or 0 }
		elseif
			label == "Jolly Joker"
			or label == "Zany Joker"
			or label == "Mad Joker"
			or label == "Crazy Joker"
			or label == "Droll Joker"
		then
			loc_vars = { config.t_mult, localize(config.type, "poker_hands") }
		elseif
			label == "Sly Joker"
			or label == "Wily Joker"
			or label == "Clever Joker"
			or label == "Devious Joker"
			or label == "Crafty Joker"
		then
			loc_vars = { config.t_chips, localize(config.type, "poker_hands") }
		elseif label == "Half Joker" then
			loc_vars = { config.extra.mult, config.extra.size }
		elseif label == "Fortune Teller" then
			loc_vars = { config.extra, (G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.tarot or 0) }
		elseif label == "Steel Joker" then
			loc_vars = { config.extra, 1 + config.extra * (config.steel_tally or 0) }
		elseif label == "Chaos the Clown" then
			loc_vars = { config.extra }
		elseif label == "Space Joker" then
			loc_vars = { "" .. (G.GAME and G.GAME.probabilities.normal or 1), config.extra }
		elseif label == "Stone Joker" then
			loc_vars = { config.extra, config.extra * (config.stone_tally or 0) }
		elseif label == "Drunkard" then
			loc_vars = { config.d_size }
		elseif label == "Green Joker" then
			loc_vars = { config.extra.hand_add, config.extra.discard_sub, config.mult ~= nil and config.mult or 0 }
		elseif label == "Credit Card" then
			loc_vars = { config.extra }
		elseif
			label == "Greedy Joker"
			or label == "Lusty Joker"
			or label == "Wrathful Joker"
			or label == "Gluttonous Joker"
		then
			loc_vars = { config.extra.s_mult, localize(config.extra.suit, "suits_singular") }
		elseif label == "Blue Joker" then
			loc_vars = { config.extra, config.extra * ((G.deck and G.deck.cards) and #G.deck.cards or 52) }
		elseif label == "Sixth Sense" then
			loc_vars = {}
		elseif label == "Mime" then
		elseif label == "Hack" then
			loc_vars = { config.extra + 1 }
		elseif label == "Pareidolia" then
		elseif label == "Faceless Joker" then
			loc_vars = { config.extra.dollars, config.extra.faces }
		elseif label == "Oops! All 6s" then
		elseif label == "Juggler" then
			loc_vars = { config.h_size }
		elseif label == "Golden Joker" then
			loc_vars = { config.extra }
		elseif label == "Joker Stencil" then
			loc_vars = { config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1 }
		elseif label == "Four Fingers" then
		elseif label == "Ceremonial Dagger" then
			loc_vars = { config.mult ~= nil and config.mult or 0 }
		elseif label == "Banner" then
			loc_vars = { config.extra }
		elseif label == "Misprint" then
			local r_mults = {}
			for i = config.extra.min, config.extra.max do
				r_mults[#r_mults + 1] = tostring(i)
			end
			local loc_mult = " " .. (localize("k_mult")) .. " "
			main_start = {
				{ n = G.UIT.T, config = { text = "  +", colour = G.C.MULT, scale = 0.32 } },
				{
					n = G.UIT.O,
					config = {
						object = DynaText({
							string = r_mults,
							colours = { G.C.RED },
							pop_in_rate = 9999999,
							silent = true,
							random_element = true,
							pop_delay = 0.5,
							scale = 0.32,
							min_cycle_time = 0,
						}),
					},
				},
				{
					n = G.UIT.O,
					config = {
						object = DynaText({
							string = {
								{ string = "rand()", colour = G.C.JOKER_GREY },
								{
									string = "#@"
										.. (G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.id or 11)
										.. (
											G.deck
												and G.deck.cards[1]
												and G.deck.cards[#G.deck.cards].base.suit:sub(1, 1)
											or "D"
										),
									colour = G.C.RED,
								},
								loc_mult,
								loc_mult,
								loc_mult,
								loc_mult,
								loc_mult,
								loc_mult,
								loc_mult,
								loc_mult,
								loc_mult,
								loc_mult,
								loc_mult,
								loc_mult,
								loc_mult,
							},
							colours = { G.C.UI.TEXT_DARK },
							pop_in_rate = 9999999,
							silent = true,
							random_element = true,
							pop_delay = 0.2011,
							scale = 0.32,
							min_cycle_time = 0,
						}),
					},
				},
			}
		elseif label == "Mystic Summit" then
			loc_vars = { config.extra.mult, config.extra.d_remaining }
		elseif label == "Marble Joker" then
		elseif label == "Loyalty Card" then
			loc_vars = {
				config.extra.Xmult,
				config.extra.every + 1,
				localize({
					type = "variable",
					key = (config.loyalty_remaining == 0 and "loyalty_active" or "loyalty_inactive"),
					vars = { config.loyalty_remaining },
				}),
			}
		elseif label == "8 Ball" then
			loc_vars = { "" .. (G.GAME and G.GAME.probabilities.normal or 1), config.extra }
		elseif label == "Dusk" then
			loc_vars = { config.extra + 1 }
		elseif label == "Raised Fist" then
		elseif label == "Fibonacci" then
			loc_vars = { config.extra }
		elseif label == "Scary Face" then
			loc_vars = { config.extra }
		elseif label == "Abstract Joker" then
			loc_vars = { config.extra, (G.jokers and G.jokers.cards and #G.jokers.cards or 0) * config.extra }
		elseif label == "Delayed Gratification" then
			loc_vars = { config.extra }
		elseif label == "Gros Michel" then
			loc_vars = {
				config.extra.mult,
				"" .. (G.GAME and G.GAME.probabilities.normal or 1),
				config.extra.odds,
			}
		elseif label == "Even Steven" then
			loc_vars = { config.extra }
		elseif label == "Odd Todd" then
			loc_vars = { config.extra }
		elseif label == "Scholar" then
			loc_vars = { config.extra.mult, config.extra.chips }
		elseif label == "Business Card" then
			loc_vars = { "" .. (G.GAME and G.GAME.probabilities.normal or 1), config.extra }
		elseif label == "Supernova" then
		elseif label == "Spare Trousers" then
			loc_vars = { config.extra, localize("Two Pair", "poker_hands"), config.mult ~= nil and config.mult or 0 }
		elseif label == "Superposition" then
			loc_vars = { config.extra }
		elseif label == "Ride the Bus" then
			loc_vars = { config.extra, config.mult ~= nil and config.mult or 0 }
		elseif label == "Egg" then
			loc_vars = { config.extra }
		elseif label == "Burglar" then
			loc_vars = { config.extra }
		elseif label == "Blackboard" then
			loc_vars = { config.extra, localize("Spades", "suits_plural"), localize("Clubs", "suits_plural") }
		elseif label == "Runner" then
			loc_vars = { config.extra.chips, config.extra.chip_mod }
		elseif label == "Ice Cream" then
			loc_vars = { config.extra.chips, config.extra.chip_mod }
		elseif label == "DNA" then
			loc_vars = { config.extra }
		elseif label == "Splash" then
		elseif label == "Constellation" then
			loc_vars =
				{ config.extra, config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1 }
		elseif label == "Hiker" then
			loc_vars = { config.extra }
		elseif label == "To Do List" then
			loc_vars = {
				config.extra.dollars,
				localize(
					config.to_do_poker_hand ~= nil and config.to_do_poker_hand
						or config.extra.poker_hand and config.extra.poker_hand,
					"poker_hands"
				),
			}
		elseif label == "Smeared Joker" then
		elseif label == "Blueprint" then
			-- config.blueprint_compat_ui = config.blueprint_compat_ui or ""
			-- config.blueprint_compat_check = nil
			-- main_end = (self.area and self.area == G.jokers)
			-- 		and {
			-- 			{
			-- 				n = G.UIT.C,
			-- 				config = { align = "bm", minh = 0.4 },
			-- 				nodes = {
			-- 					{
			-- 						n = G.UIT.C,
			-- 						config = {
			-- 							ref_table = self,
			-- 							align = "m",
			-- 							colour = G.C.JOKER_GREY,
			-- 							r = 0.05,
			-- 							padding = 0.06,
			-- 							func = "blueprint_compat",
			-- 						},
			-- 						nodes = {
			-- 							{
			-- 								n = G.UIT.T,
			-- 								config = {
			-- 									ref_table = config,
			-- 									ref_value = "blueprint_compat_ui",
			-- 									colour = G.C.UI.TEXT_LIGHT,
			-- 									scale = 0.32 * 0.8,
			-- 								},
			-- 							},
			-- 						},
			-- 					},
			-- 				},
			-- 			},
			-- 		}
			-- 	or nil
		elseif label == "Cartomancer" then
		elseif label == "Astronomer" then
			loc_vars = { config.extra }
		elseif label == "Golden Ticket" then
			loc_vars = { config.extra }
		elseif label == "Mr. Bones" then
		elseif label == "Acrobat" then
			loc_vars = { config.extra }
		elseif label == "Sock and Buskin" then
			loc_vars = { config.extra + 1 }
		elseif label == "Swashbuckler" then
			loc_vars = { config.mult ~= nil and config.mult or 0 }
		elseif label == "Troubadour" then
			loc_vars = { config.extra.h_size, -config.extra.h_plays }
		elseif label == "Certificate" then
			loc_vars = { config.extra }
		elseif label == "Throwback" then
			loc_vars =
				{ config.extra, config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1 }
		elseif label == "Hanging Chad" then
			loc_vars = { config.extra }
		elseif label == "Rough Gem" then
			loc_vars = { config.extra }
		elseif label == "Bloodstone" then
			loc_vars = {
				"" .. (G.GAME and G.GAME.probabilities.normal or 1),
				config.extra.odds,
				config.extra.Xmult,
			}
		elseif label == "Arrowhead" then
			loc_vars = { config.extra }
		elseif label == "Onyx Agate" then
			loc_vars = { config.extra }
		elseif label == "Glass Joker" then
			loc_vars =
				{ config.extra, config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1 }
		elseif label == "Showman" then
		elseif label == "Flower Pot" then
			loc_vars = { config.extra }
		elseif label == "Wee Joker" then
			loc_vars = { config.extra.chips, config.extra.chip_mod }
		elseif label == "Merry Andy" then
			loc_vars = { config.d_size, config.h_size }
		elseif label == "The Idol" then
			loc_vars = {
				config.extra,
				localize(G.GAME.current_round.idol_card.rank, "ranks"),
				localize(G.GAME.current_round.idol_card.suit, "suits_plural"),
				colours = { G.C.SUITS[G.GAME.current_round.idol_card.suit] },
			}
		elseif label == "Seeing Double" then
			loc_vars = { config.extra }
		elseif label == "Matador" then
			loc_vars = { config.extra }
		elseif label == "Hit the Road" then
			loc_vars =
				{ config.extra, config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1 }
		elseif
			label == "The Duo"
			or label == "The Trio"
			or label == "The Family"
			or label == "The Order"
			or label == "The Tribe"
		then
			loc_vars = {
				config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1,
				localize(config.type, "poker_hands"),
			}
		elseif label == "Cavendish" then
			loc_vars = {
				config.extra.Xmult,
				"" .. (G.GAME and G.GAME.probabilities.normal or 1),
				config.extra.odds,
			}
		elseif label == "Card Sharp" then
			loc_vars = { config.extra.Xmult }
		elseif label == "Red Card" then
			loc_vars = { config.extra, config.mult ~= nil and config.mult or 0 }
		elseif label == "Madness" then
			loc_vars =
				{ config.extra, config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1 }
		elseif label == "Square Joker" then
			loc_vars = { config.extra.chips, config.extra.chip_mod }
		elseif label == "Seance" then
			loc_vars = { localize(config.extra.poker_hand, "poker_hands") }
		elseif label == "Riff-raff" then
			loc_vars = { config.extra }
		elseif label == "Vampire" then
			loc_vars =
				{ config.extra, config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1 }
		elseif label == "Shortcut" then
		elseif label == "Hologram" then
			loc_vars =
				{ config.extra, config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1 }
		elseif label == "Vagabond" then
			loc_vars = { config.extra }
		elseif label == "Baron" then
			loc_vars = { config.extra }
		elseif label == "Cloud 9" then
			loc_vars = { config.extra, config.extra * (config.nine_tally or 0) }
		elseif label == "Rocket" then
			loc_vars = { config.extra.dollars, config.extra.increase }
		elseif label == "Obelisk" then
			loc_vars =
				{ config.extra, config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1 }
		elseif label == "Midas Mask" then
		elseif label == "Luchador" then
			-- local has_message = (G.GAME and self.area and (self.area == G.jokers))
			-- if has_message then
			-- 	local disableable = G.GAME.blind
			-- 		and ((not G.GAME.blind.disabled) and (G.GAME.blind:get_type() == "Boss"))
			-- 	main_end = {
			-- 		{
			-- 			n = G.UIT.C,
			-- 			config = { align = "bm", minh = 0.4 },
			-- 			nodes = {
			-- 				{
			-- 					n = G.UIT.C,
			-- 					config = {
			-- 						ref_table = self,
			-- 						align = "m",
			-- 						colour = disableable and G.C.GREEN or G.C.RED,
			-- 						r = 0.05,
			-- 						padding = 0.06,
			-- 					},
			-- 					nodes = {
			-- 						{
			-- 							n = G.UIT.T,
			-- 							config = {
			-- 								text = " "
			-- 									.. localize(disableable and "k_active" or "ph_no_boss_active")
			-- 									.. " ",
			-- 								colour = G.C.UI.TEXT_LIGHT,
			-- 								scale = 0.32 * 0.9,
			-- 							},
			-- 						},
			-- 					},
			-- 				},
			-- 			},
			-- 		},
			-- 	}
			-- end
		elseif label == "Photograph" then
			loc_vars = { config.extra }
		elseif label == "Gift Card" then
			loc_vars = { config.extra }
		elseif label == "Turtle Bean" then
			loc_vars = { config.extra.h_size, config.extra.h_mod }
		elseif label == "Erosion" then
			loc_vars = {
				config.extra,
				math.max(0, config.extra * (G.playing_cards and (G.GAME.starting_deck_size - #G.playing_cards) or 0)),
				G.GAME.starting_deck_size,
			}
		elseif label == "Reserved Parking" then
			loc_vars = {
				config.extra.dollars,
				"" .. (G.GAME and G.GAME.probabilities.normal or 1),
				config.extra.odds,
			}
		elseif label == "Mail-In Rebate" then
			loc_vars = { config.extra, localize(G.GAME.current_round.mail_card.rank, "ranks") }
		elseif label == "To the Moon" then
			loc_vars = { config.extra }
		elseif label == "Hallucination" then
			loc_vars = { G.GAME.probabilities.normal, config.extra }
		elseif label == "Lucky Cat" then
			loc_vars =
				{ config.extra, config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1 }
		elseif label == "Baseball Card" then
			loc_vars = { config.extra }
		elseif label == "Bull" then
			loc_vars = { config.extra, config.extra * math.max(0, G.GAME.dollars) or 0 }
		elseif label == "Diet Cola" then
			loc_vars = { localize({ type = "name_text", set = "Tag", key = "tag_double", nodes = {} }) }
		elseif label == "Trading Card" then
			loc_vars = { config.extra }
		elseif label == "Flash Card" then
			loc_vars = { config.extra, config.mult ~= nil and config.mult or 0 }
		elseif label == "Popcorn" then
			loc_vars = { config.mult ~= nil and config.mult or 0, config.extra }
		elseif label == "Ramen" then
			print(config)
			loc_vars =
				{ config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1, config.extra }
		elseif label == "Ancient Joker" then
			loc_vars = {
				config.extra,
				localize(G.GAME.current_round.ancient_card.suit, "suits_singular"),
				colours = { G.C.SUITS[G.GAME.current_round.ancient_card.suit] },
			}
		elseif label == "Walkie Talkie" then
			loc_vars = { config.extra.chips, config.extra.mult }
		elseif label == "Seltzer" then
			loc_vars = { config.extra }
		elseif label == "Castle" then
			loc_vars = {
				config.extra.chip_mod,
				localize(G.GAME.current_round.castle_card.suit, "suits_singular"),
				config.extra.chips,
				colours = { G.C.SUITS[G.GAME.current_round.castle_card.suit] },
			}
		elseif label == "Smiley Face" then
			loc_vars = { config.extra }
		elseif label == "Campfire" then
			loc_vars =
				{ config.extra, config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1 }
		elseif label == "Stuntman" then
			loc_vars = { config.extra.chip_mod, config.extra.h_size }
		elseif label == "Invisible Joker" then
			loc_vars = { config.extra, config.invis_rounds }
		elseif label == "Brainstorm" then
			-- config.blueprint_compat_ui = config.blueprint_compat_ui or ""
			-- config.blueprint_compat_check = nil
			-- main_end = (self.area and self.area == G.jokers)
			-- 		and {
			-- 			{
			-- 				n = G.UIT.C,
			-- 				config = { align = "bm", minh = 0.4 },
			-- 				nodes = {
			-- 					{
			-- 						n = G.UIT.C,
			-- 						config = {
			-- 							ref_table = self,
			-- 							align = "m",
			-- 							colour = G.C.JOKER_GREY,
			-- 							r = 0.05,
			-- 							padding = 0.06,
			-- 							func = "blueprint_compat",
			-- 						},
			-- 						nodes = {
			-- 							{
			-- 								n = G.UIT.T,
			-- 								config = {
			-- 									ref_table = config,
			-- 									ref_value = "blueprint_compat_ui",
			-- 									colour = G.C.UI.TEXT_LIGHT,
			-- 									scale = 0.32 * 0.8,
			-- 								},
			-- 							},
			-- 						},
			-- 					},
			-- 				},
			-- 			},
			-- 		}
			-- 	or nil
		elseif label == "Satellite" then
			local planets_used = 0
			for k, v in pairs(G.GAME.consumeable_usage) do
				if v.set == "Planet" then
					planets_used = planets_used + 1
				end
			end
			loc_vars = { config.extra, planets_used * config.extra }
		elseif label == "Shoot the Moon" then
			loc_vars = { config.extra }
		elseif label == "Driver's License" then
			loc_vars = { config.extra, config.driver_tally or "0" }
		elseif label == "Burnt Joker" then
		elseif label == "Bootstraps" then
			loc_vars = {
				config.extra.mult,
				config.extra.dollars,
				config.extra.mult * math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0)) / config.extra.dollars),
			}
		elseif label == "Caino" then
			loc_vars = { config.extra, config.caino_xmult }
		elseif label == "Triboulet" then
			loc_vars = { config.extra }
		elseif label == "Yorick" then
			loc_vars = {
				config.extra.xmult,
				config.extra.discards,
				config.yorick_discards,
				config.x_mult ~= nil and config.x_mult or config.Xmult ~= nil and config.Xmult or 1,
			}
		elseif label == "Chicot" then
		elseif label == "Perkeo" then
			loc_vars = { config.extra }
		end
	end
	-- if set == "Joker" then
	-- 	if label == "Stone Joker" or label == "Marble Joker" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
	-- 	elseif label == "Steel Joker" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.m_steel
	-- 	elseif label == "Glass Joker" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.m_glass
	-- 	elseif label == "Golden Ticket" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
	-- 	elseif label == "Lucky Cat" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.m_lucky
	-- 	elseif label == "Midas Mask" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
	-- 	elseif label == "Invisible Joker" then
	-- 		if G.jokers and G.jokers.cards then
	-- 			for k, v in ipairs(G.jokers.cards) do
	-- 				if (v.edition and v.edition.negative) and G.localization.descriptions.Other.remove_negative then
	-- 					main_end = {}
	-- 					localize({ type = "other", key = "remove_negative", nodes = main_end, vars = {} })
	-- 					main_end = main_end[1]
	-- 					break
	-- 				end
	-- 			end
	-- 		end
	-- 	elseif label == "Diet Cola" then
	-- 		info_queue[#info_queue + 1] = { key = "tag_double", set = "Tag" }
	-- 	elseif label == "Perkeo" then
	-- 		info_queue[#info_queue + 1] = { key = "e_negative_consumable", set = "Edition", config = { extra = 1 } }
	-- 	end
	-- 	if specific_vars and specific_vars.pinned then
	-- 		info_queue[#info_queue + 1] = { key = "pinned_left", set = "Other" }
	-- 	end
	-- 	if specific_vars and specific_vars.sticker then
	-- 		info_queue[#info_queue + 1] = { key = string.lower(specific_vars.sticker) .. "_sticker", set = "Other" }
	-- 	end
	-- 	localize({
	-- 		type = "descriptions",
	-- 		key = _c.key,
	-- 		set = set,
	-- 		nodes = desc_nodes,
	-- 		vars = specific_vars or {},
	-- 	})
	-- elseif set == "Tag" then
	-- 	if label == "Negative Tag" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
	-- 	elseif label == "Foil Tag" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.e_foil
	-- 	elseif label == "Holographic Tag" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.e_holo
	-- 	elseif label == "Polychrome Tag" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
	-- 	elseif label == "Charm Tag" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.p_arcana_mega_1
	-- 	elseif label == "Meteor Tag" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.p_celestial_mega_1
	-- 	elseif label == "Ethereal Tag" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.p_spectral_normal_1
	-- 	elseif label == "Standard Tag" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.p_standard_mega_1
	-- 	elseif label == "Buffoon Tag" then
	-- 		info_queue[#info_queue + 1] = G.P_CENTERS.p_buffoon_mega_1
	-- 	end
	-- 	localize({ type = "descriptions", key = _c.key, set = "Tag", nodes = desc_nodes, vars = specific_vars or {} })
	if set == "Voucher" then
		if label == "Overstock" or label == "Overstock Plus" then
		elseif label == "Tarot Merchant" or label == "Tarot Tycoon" then
			loc_vars = { config.extra_disp }
		elseif label == "Planet Merchant" or label == "Planet Tycoon" then
			loc_vars = { config.extra_disp }
		elseif label == "Hone" or label == "Glow Up" then
			loc_vars = { config.extra }
		elseif label == "Reroll Surplus" or label == "Reroll Glut" then
			loc_vars = { config.extra }
		elseif label == "Grabber" or label == "Nacho Tong" then
			loc_vars = { config.extra }
		elseif label == "Wasteful" or label == "Recyclomancy" then
			loc_vars = { config.extra }
		elseif label == "Seed Money" or label == "Money Tree" then
			loc_vars = { config.extra / 5 }
		elseif label == "Blank" or label == "Antimatter" then
		elseif label == "Hieroglyph" or label == "Petroglyph" then
			loc_vars = { config.extra }
		elseif label == "Director's Cut" or label == "Retcon" then
			loc_vars = { config.extra }
		elseif label == "Paint Brush" or label == "Palette" then
			loc_vars = { config.extra }
		elseif label == "Telescope" or label == "Observatory" then
			loc_vars = { config.extra }
		elseif label == "Clearance Sale" or label == "Liquidation" then
			loc_vars = { config.extra }
		end
	elseif set == "Edition" then
		loc_vars = { config.extra }
		-- elseif set == "Enhanced" then
		-- 	if _c.effect == "Mult Card" then
		-- 		loc_vars = { config.mult ~= nil and config.mult or 0 }
		-- 	elseif _c.effect == "Wild Card" then
		-- 	elseif _c.effect == "Glass Card" then
		-- 		loc_vars = { config.Xmult, G.GAME.probabilities.normal, config.extra }
		-- 	elseif _c.effect == "Steel Card" then
		-- 		loc_vars = { config.h_x_mult }
		-- 	elseif _c.effect == "Stone Card" then
		-- 		loc_vars = { ((specific_vars and specific_vars.bonus_chips) or config.bonus) }
		-- 	elseif _c.effect == "Gold Card" then
		-- 		loc_vars = { config.h_dollars }
		-- 	elseif _c.effect == "Lucky Card" then
		-- 		loc_vars = { G.GAME.probabilities.normal, config.mult ~= nil and config.mult or 0, 5, config.p_dollars, 15 }
		-- 	end
		-- 	localize({ type = "descriptions", key = _c.key, set = set, nodes = desc_nodes, vars = loc_vars })
		-- 	if label ~= "Stone Card" and ((specific_vars and specific_vars.bonus_chips) or config.bonus) then
		-- 		localize({
		-- 			type = "other",
		-- 			key = "card_extra_chips",
		-- 			nodes = desc_nodes,
		-- 			vars = { ((specific_vars and specific_vars.bonus_chips) or config.bonus) },
		-- 		})
		-- 	end
	elseif set == "Booster" then
		local desc_override = "p_arcana_normal"
		if label == "Arcana Pack" then
			desc_override = "p_arcana_normal"
			loc_vars = { config.choose, config.extra }
		elseif label == "Jumbo Arcana Pack" then
			desc_override = "p_arcana_jumbo"
			loc_vars = { config.choose, config.extra }
		elseif label == "Mega Arcana Pack" then
			desc_override = "p_arcana_mega"
			loc_vars = { config.choose, config.extra }
		elseif label == "Celestial Pack" then
			desc_override = "p_celestial_normal"
			loc_vars = { config.choose, config.extra }
		elseif label == "Jumbo Celestial Pack" then
			desc_override = "p_celestial_jumbo"
			loc_vars = { config.choose, config.extra }
		elseif label == "Mega Celestial Pack" then
			desc_override = "p_celestial_mega"
			loc_vars = { config.choose, config.extra }
		elseif label == "Spectral Pack" then
			desc_override = "p_spectral_normal"
			loc_vars = { config.choose, config.extra }
		elseif label == "Jumbo Spectral Pack" then
			desc_override = "p_spectral_jumbo"
			loc_vars = { config.choose, config.extra }
		elseif label == "Mega Spectral Pack" then
			desc_override = "p_spectral_mega"
			loc_vars = { config.choose, config.extra }
		elseif label == "Standard Pack" then
			desc_override = "p_standard_normal"
			loc_vars = { config.choose, config.extra }
		elseif label == "Jumbo Standard Pack" then
			desc_override = "p_standard_jumbo"
			loc_vars = { config.choose, config.extra }
		elseif label == "Mega Standard Pack" then
			desc_override = "p_standard_mega"
			loc_vars = { config.choose, config.extra }
		elseif label == "Buffoon Pack" then
			desc_override = "p_buffoon_normal"
			loc_vars = { config.choose, config.extra }
		elseif label == "Jumbo Buffoon Pack" then
			desc_override = "p_buffoon_jumbo"
			loc_vars = { config.choose, config.extra }
		elseif label == "Mega Buffoon Pack" then
			desc_override = "p_buffoon_mega"
			loc_vars = { config.choose, config.extra }
		end
		local name_override = desc_override
		-- if not full_UI_table.name then
		-- 	full_UI_table.name =
		-- 		localize({ type = "name", set = "Other", key = name_override, nodes = full_UI_table.name })
		-- end
		-- elseif set == "Spectral" then
		-- 	if label == "Familiar" or label == "Grim" or label == "Incantation" then
		-- 		loc_vars = { config.extra }
		-- 	elseif label == "Immolate" then
		-- 		loc_vars = { config.extra.destroy, config.extra.dollars }
		-- 	elseif label == "Hex" then
		-- 		info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
		-- 	elseif label == "Talisman" then
		-- 		info_queue[#info_queue + 1] = { key = "gold_seal", set = "Other" }
		-- 	elseif label == "Deja Vu" then
		-- 		info_queue[#info_queue + 1] = { key = "red_seal", set = "Other" }
		-- 	elseif label == "Trance" then
		-- 		info_queue[#info_queue + 1] = { key = "blue_seal", set = "Other" }
		-- 	elseif label == "Medium" then
		-- 		info_queue[#info_queue + 1] = { key = "purple_seal", set = "Other" }
		-- 	elseif label == "Ankh" then
		-- 		if G.jokers and G.jokers.cards then
		-- 			for k, v in ipairs(G.jokers.cards) do
		-- 				if (v.edition and v.edition.negative) and G.localization.descriptions.Other.remove_negative then
		-- 					info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
		-- 					main_end = {}
		-- 					localize({ type = "other", key = "remove_negative", nodes = main_end, vars = {} })
		-- 					main_end = main_end[1]
		-- 					break
		-- 				end
		-- 			end
		-- 		end
		-- 	elseif label == "Cryptid" then
		-- 		loc_vars = { config.extra }
		-- 	end
		-- 	if label == "Ectoplasm" then
		-- 		info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
		-- 		loc_vars = { G.GAME.ecto_minus or 1 }
		-- 	end
		-- 	if label == "Aura" then
		-- 		info_queue[#info_queue + 1] = G.P_CENTERS.e_foil
		-- 		info_queue[#info_queue + 1] = G.P_CENTERS.e_holo
		-- 		info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
		-- 	end
		-- 	localize({ type = "descriptions", key = _c.key, set = set, nodes = desc_nodes, vars = loc_vars })
	elseif set == "Planet" then
		loc_vars = {
			G.GAME.hands[config.hand_type].level,
			localize(config.hand_type, "poker_hands"),
			G.GAME.hands[config.hand_type].l_mult,
			G.GAME.hands[config.hand_type].l_chips,
			colours = {
				(G.GAME.hands[config.hand_type].level == 1 and G.C.UI.TEXT_DARK or G.C.HAND_LEVELS[math.min(
					7,
					G.GAME.hands[config.hand_type].level
				)]),
			},
		}
	elseif set == "Tarot" then
		if label == "The Fool" then
			local fool_c = G.GAME.last_tarot_planet and G.P_CENTERS[G.GAME.last_tarot_planet] or nil
			local last_tarot_planet = fool_c and localize({ type = "name_text", key = fool_c.key, set = fool_c.set })
				or localize("k_none")
			local colour = (not fool_c or fool_c.name == "The Fool") and G.C.RED or G.C.GREEN
			main_end = {
				{
					n = G.UIT.C,
					config = { align = "bm", padding = 0.02 },
					nodes = {
						{
							n = G.UIT.C,
							config = { align = "m", colour = colour, r = 0.05, padding = 0.05 },
							nodes = {
								{
									n = G.UIT.T,
									config = {
										text = " " .. last_tarot_planet .. " ",
										colour = G.C.UI.TEXT_LIGHT,
										scale = 0.3,
										shadow = true,
									},
								},
							},
						},
					},
				},
			}
			loc_vars = { last_tarot_planet }
			-- if not (not fool_c or fool_c.name == "The Fool") then
			-- 	info_queue[#info_queue + 1] = fool_c
			-- end
		elseif label == "The Magician" then
			loc_vars = {
				config.max_highlighted,
				localize({ type = "name_text", set = "Enhanced", key = config.mod_conv }),
			}
			-- info_queue[#info_queue + 1] = G.P_CENTERS[config.mod_conv]
		elseif label == "The High Priestess" then
			loc_vars = { config.planets }
		elseif label == "The Empress" then
			loc_vars = {
				config.max_highlighted,
				localize({ type = "name_text", set = "Enhanced", key = config.mod_conv }),
			}
			-- info_queue[#info_queue + 1] = G.P_CENTERS[config.mod_conv]
		elseif label == "The Emperor" then
			loc_vars = { config.tarots }
		elseif label == "The Hierophant" then
			loc_vars = {
				config.max_highlighted,
				localize({ type = "name_text", set = "Enhanced", key = config.mod_conv }),
			}
			-- info_queue[#info_queue + 1] = G.P_CENTERS[config.mod_conv]
		elseif label == "The Lovers" then
			loc_vars = {
				config.max_highlighted,
				localize({ type = "name_text", set = "Enhanced", key = config.mod_conv }),
			}
			-- info_queue[#info_queue + 1] = G.P_CENTERS[config.mod_conv]
		elseif label == "The Chariot" then
			loc_vars = {
				config.max_highlighted,
				localize({ type = "name_text", set = "Enhanced", key = config.mod_conv }),
			}
			-- info_queue[#info_queue + 1] = G.P_CENTERS[config.mod_conv]
		elseif label == "Justice" then
			loc_vars = {
				config.max_highlighted,
				localize({ type = "name_text", set = "Enhanced", key = config.mod_conv }),
			}
			-- info_queue[#info_queue + 1] = G.P_CENTERS[config.mod_conv]
		elseif label == "The Hermit" then
			loc_vars = { config.extra }
		elseif label == "The Wheel of Fortune" then
			loc_vars = { G.GAME.probabilities.normal, config.extra }
			-- info_queue[#info_queue + 1] = G.P_CENTERS.e_foil
			-- info_queue[#info_queue + 1] = G.P_CENTERS.e_holo
			-- info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
		elseif label == "Strength" then
			loc_vars = { config.max_highlighted }
		elseif label == "The Hanged Man" then
			loc_vars = { config.max_highlighted }
		elseif label == "Death" then
			loc_vars = { config.max_highlighted }
		elseif label == "Temperance" then
			local _money = 0
			if G.jokers then
				for i = 1, #G.jokers.cards do
					if G.jokers.cards[i].ability.set == "Joker" then
						_money = _money + G.jokers.cards[i].sell_cost
					end
				end
			end
			loc_vars = { config.extra, math.min(config.extra, _money) }
		elseif label == "The Devil" then
			loc_vars = {
				config.max_highlighted,
				localize({ type = "name_text", set = "Enhanced", key = config.mod_conv }),
			}
			-- info_queue[#info_queue + 1] = G.P_CENTERS[config.mod_conv]
		elseif label == "The Tower" then
			loc_vars = {
				config.max_highlighted,
				localize({ type = "name_text", set = "Enhanced", key = config.mod_conv }),
			}
			-- info_queue[#info_queue + 1] = G.P_CENTERS[config.mod_conv]
		elseif label == "The Star" then
			loc_vars = {
				config.max_highlighted,
				localize(config.suit_conv, "suits_plural"),
				colours = { G.C.SUITS[config.suit_conv] },
			}
		elseif label == "The Moon" then
			loc_vars = {
				config.max_highlighted,
				localize(config.suit_conv, "suits_plural"),
				colours = { G.C.SUITS[config.suit_conv] },
			}
		elseif label == "The Sun" then
			loc_vars = {
				config.max_highlighted,
				localize(config.suit_conv, "suits_plural"),
				colours = { G.C.SUITS[config.suit_conv] },
			}
		elseif label == "Judgement" then
		elseif label == "The World" then
			loc_vars = {
				config.max_highlighted,
				localize(config.suit_conv, "suits_plural"),
				colours = { G.C.SUITS[config.suit_conv] },
			}
		end
	end

	return loc_vars
end
