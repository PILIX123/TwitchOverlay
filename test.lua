local function makeCleanUI(orig, json)
	local new = {}
	for k, v in pairs(orig) do
		if json ~= nil and json == true and type(k) == "number" then
			k = tostring(k)
		end
		if type(v) ~= "table" then
			new[k] = v
		else
			if v.is and v:is(Object) then
				if v:is(DynaText) then
					new[k] = { objectName = "DynaText", config = v.config }
				else
					error("Unknown Object", v)
				end
			else
				new[k] = makeCleanUI(v, json ~= nil and json)
			end
		end
	end
	return new
end

-- return require("debugplus-util").stringifyTable(makeCleanUI(dp.hovered:generate_UIBox_ability_table()), 20)
--print(JSON.encode(makeCleanUI(G.shop_jokers.cards[1]:generate_UIBox_ability_table())))
return makeCleanUI
