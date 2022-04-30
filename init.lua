--formspecs
local function get_formspec_bench()
	return "size[10,10]"..
		"image[4,2;1,1;sfinv_crafting_arrow.png]"..
		"list[context;input;2,2;1,1;1]"..
		"list[context;result;6,1;3,3]"..
		"list[current_player;main;1,5;8,4;]"
end
local function get_formspec_working()
	return "size[10,10]"..
		"label[4,2;Decrafting in process...]"..
		"list[current_player;main;1,5;8,4;]"
end
local function contains(element)
	for _, value in ipairs(minetest.registered_items) do
		if value == element then
			return true
		end
	end
	return false
end
--workbench
local function decraft(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local timer = minetest.get_node_timer(pos)
		local stack = inv:get_stack("input", 2)
		local stuff =  minetest.get_craft_recipe(stack:get_name())
		local realstuff = {}
		if stuff.items ~= nil and ItemStack(stuff.output):get_count() <= stack:get_count() then --make sure the item item can be decrafted and that you're not decrafting 1 diamond into a diamond block
			for _, col in ipairs(stuff.items) do
				if col:sub(1, 6) ~= "group:" then -- make sure it's not "group:" cause i'm too lazy to deal with that right now
					table.insert(realstuff, col)
				end
			end
			if inv:is_empty("result") then
				inv:set_list("result", realstuff) --set result
				inv:remove_item("input", stack:get_name().." "..stack:get_count()) --remove input
				meta:set_string("formspec", get_formspec_working())
				timer:start(5)
			end
		end
end
minetest.register_node("decraft:table", {
		description = "Decrafting Workbench",
		tiles = {"unmake_top.png", "unmake_top.png", "unmake_side.png", "unmake_side.png", "unmake_side.png", "unmake_side.png"},
		groups = {oddly_breakable_by_hand = 1},
		on_construct = function(pos, node)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			inv:set_size("result", 3*3)
			inv:set_size("input", 2*1)
			meta:set_string("formspec", get_formspec_bench())
		end,
		on_timer = function(pos)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			meta:set_string("formspec", get_formspec_bench())
			return false
		end,
		on_metadata_inventory_put = function(pos, listname, index, stack, player)
			decraft(pos)
		end
})
minetest.register_craft({
		output = "decraft:table",
		recipe = {
			{"default:sword_steel", "default:pick_steel", "default:axe_steel"},
			{"default:sandstone_block", "default:bronzeblock", "default:sandstone_block"},
			{"default:sandstone_block", "default:bronzeblock", "default:sandstone_block"}
		}
})
