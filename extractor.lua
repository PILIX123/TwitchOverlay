local function makeCleanUI(orig)
	local new = {}
	for k, v in pairs(orig) do
		if type(v) == "userdata" then
			v = nil
		end
		if type(v) ~= "table" then
			new[k] = v
		else
			if v.is and v:is(Object) then
				if v:is(DynaText) then
					new[k] = { objectName = "DynaText", config = v.config }
				elseif v:is(Moveable) then
					new[k] = { objectName = "Moveable" }
				else
					error("Unknown Object")
				end
			else
				new[k] = makeCleanUI(v)
			end
		end
	end
	return new
end

-- return require("debugplus-util").stringifyTable(makeCleanUI(dp.hovered:generate_UIBox_ability_table()), 20)

-- return JSON.encode(makeCleanUI(dp.hovered:generate_UIBox_ability_table()))
-- return JSON.encode(makeCleanUI(G.UIDEF.card_h_popup(dp.hovered)))
return makeCleanUI
