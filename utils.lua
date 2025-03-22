---@param name_table table
---@return string | nil
local function get_name(name_table)
	if name_table and type(name_table) == "table" then
		if (((name_table[1] or {}).nodes[1] or {}).config or {}).object then
			return name_table[1].nodes[1].config.object.string
		else
			local text = ""
			for _, v in ipairs(name_table) do
				for _, vv in ipairs(v) do
					if vv.config and type(vv.config.text) == "string" then
						text = text .. vv.config.text
					end
				end
			end
			return text
		end
	end
end

---@param info_boxes table
---@return table
local function get_side_box(info_boxes)
	local parsed_boxes = {}
	for _, box in ipairs(info_boxes) do
		local parsed_box = { name = box.name, text = "" }
		for _, line in ipairs(box) do
			for _, sub in ipairs(line) do
				local text
				if sub.config and type(sub.config.text) == "string" then
					text = sub.config.text
				elseif
					sub.nodes
					and sub.nodes[1]
					and sub.nodes[1].config
					and type(sub.nodes[1].config.text) == "string"
				then
					text = sub.nodes[1].config.text
				end
				parsed_box.text = parsed_box.text .. text
			end
			parsed_box.text = parsed_box.text .. "\n"
		end
		parsed_boxes[#parsed_boxes + 1] = parsed_box
	end
	return parsed_boxes
end

---@param badges table
---@return table
local function get_badges(badges)
	local badges_name = {}
	for k, v in pairs(badges) do
		if type(k) == "number" then
			badges_name[#badges_name + 1] = v
		end
		if k == "card_type" then
			badges_name[#badges_name + 1] = v
		end
	end
	return badges_name
end

---@param table table
---@param append_to string
---@return string
local function recursive_data(table, append_to)
	for _, v in pairs(table) do
		if v.config and v.config.text and type(v.config.text) == "string" then
			append_to = append_to .. v.config.text
		elseif v.config and v.config.object and v.config.object.config and v.config.object.config.string then
			for _, vv in ipairs(v.config.object.config.string) do
				if vv.string then
					append_to = append_to .. vv.string
				else
					append_to = append_to .. vv
				end
				append_to = append_to .. "\n"
			end
		elseif v.nodes then
			append_to = recursive_data(v.nodes, append_to)
		end
	end
	append_to = append_to .. "\n"
	return append_to
end

---@param main table
---@return string
local function get_desc(main)
	local current_desc = ""
	for _, v in ipairs(main) do
		for _, vv in ipairs(v) do
			if vv.config.text and type(vv.config.text) == "string" then
				current_desc = current_desc .. vv.config.text
			end
		end
		current_desc = current_desc .. "\n"
	end
	return current_desc
end

--- For getting description out of jokers
--- @param joker Card
--- @return table
local function find_joker_desc_strings(joker)
	local AUT = joker:generate_UIBox_ability_table()
	local name = get_name(AUT.name)
	local info_boxes = get_side_box(AUT.info)
	local badges = get_badges(AUT.badges)
	local desc = get_desc(AUT.main)

	print(AUT)
	local modded_badges = {}
	if AUT.card_type ~= "Locked" and AUT.card_type ~= "Undiscovered" then
		SMODS.create_mod_badges(joker.config.center, modded_badges)
		if joker.base then
			SMODS.create_mod_badges(SMODS.Ranks[joker.base.value], modded_badges)
			SMODS.create_mod_badges(SMODS.Suits[joker.base.suit], modded_badges)
		end
		if joker.config and joker.config.tag then
			SMODS.create_mod_badges(SMODS.Tags[joker.config.tag.key], modded_badges)
		end
		modded_badges.mod_set = nil
	end
	local modded_badges_string = recursive_data(modded_badges, "")

	if joker.ability.set ~= "Joker" then
		return {
			name = name,
			info_boxes = info_boxes,
			badges = badges,
			modded_badges = modded_badges_string,
			description = desc,
		}
	end
	local rarity = SMODS.Rarity:get_rarity_badge(joker.config.center.rarity)

	print(desc)
	return {
		name = name,
		rarity = rarity,
		info_boxes = info_boxes,
		badges = badges,
		modded_badges = modded_badges_string,
		description = desc,
	}
end

local UTILS = { find_joker_desc_strings = find_joker_desc_strings, recursive = recursive_data }
return UTILS
