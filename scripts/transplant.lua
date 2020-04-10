table.insert(PrefabFiles, "new_reeds")
table.insert(PrefabFiles, "dug_reeds")

table.insert(Assets, Asset("ATLAS", "images/inventoryimages/dug_reeds.xml"))

AddPrefabPostInit("reeds", function(inst)		-- 添加芦苇标签，为生成芦苇根做铺垫
	inst:AddTag("reeds")
	
	if not TheWorld.ismastersim then
		return inst
	end
	inst:AddComponent("lootdropper")
	inst:RemoveComponent("burnable")		-- 芦苇不可燃烧
	
	local old_pickedfn = inst.components.pickable.onpickedfn
	local function onpickedfn(inst)
		old_pickedfn(inst)
		local x, y, z = inst.Transform:GetWorldPosition()
		local MAX_SEEDS = 40
		local ents = TheSim:FindEntities(x, y, z, 30, {"reeds"}, nil, nil)
		local count = ents == nil and 0 or #ents		-- 附近30码的芦苇丛数量
		
		local chance = 0.05 * (MAX_SEEDS - count) / MAX_SEEDS
		-- print("chance = "..chance)
		if math.random() < chance then
			inst.components.lootdropper:SpawnLootPrefab("dug_reeds")
		end
	end
	inst.components.pickable.onpickedfn = onpickedfn
end)