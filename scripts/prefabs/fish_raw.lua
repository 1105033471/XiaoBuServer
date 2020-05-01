local fish_raw_assets = 
{
	Asset("ANIM", "anim/fish_raw.zip")
}

local cooked_assets = 
{
	Asset("ANIM", "anim/fish_med_cooked.zip")
}

local function fish_raw_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	
	MakeInventoryPhysics(inst)
	
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("fish_raw")
	inst.AnimState:SetBuild("fish_raw")
	inst.AnimState:PlayAnimation("idle")
	
	MakeInventoryFloatable(inst, "idle_water", "idle")

	inst:AddTag("catfood")
	inst:AddTag("fishmeat")
	inst:AddTag("packimfood")
	inst:AddTag("meat")
    
    if not TheWorld.ismastersim then
        return inst
    end
    
	inst:AddComponent("edible")
	-- inst.components.edible.ismeat = true     -- 单机才有
	inst.components.edible.foodtype = FOODTYPE.MEAT
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)       -- 3 day
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
			
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/fish_raw.xml"
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT    -- 1
    -- inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD    -- 单机才有
	inst.data = {}

	-- inst:AddComponent("appeasement")
	-- inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL

	inst.components.edible.healthvalue = TUNING.HEALING_TINY    -- 1
	inst.components.edible.hungervalue = TUNING.CALORIES_MED    -- 25
	
	inst:AddComponent("cookable")
	inst.components.cookable.product = "fish_med_cooked"
    
	inst:AddComponent("dryable")
	inst.components.dryable:SetProduct("meat_dried")        -- 肉干
	inst.components.dryable:SetDryTime(TUNING.DRY_FAST)     -- 1 day
--	inst.components.dryable:SetOverrideSymbol("fishraw")

	inst:AddComponent("bait")

	return inst
end

local function cookedfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	
	MakeInventoryPhysics(inst)
	
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("fish_med_cooked")
	inst.AnimState:SetBuild("fish_med_cooked")
	inst.AnimState:PlayAnimation("cooked", true)

	MakeInventoryFloatable(inst, "idle_cooked_water", "cooked")

	inst:AddTag("meat")
	inst:AddTag("fishmeat")
	inst:AddTag("catfood")
	inst:AddTag("packimfood")
    
    if not TheWorld.ismastersim then
        return inst
    end
    
	inst:AddComponent("edible")
	-- inst.components.edible.ismeat = true
	inst.components.edible.foodtype = FOODTYPE.MEAT
	-- inst.components.edible.foodstate = "COOKED"
	inst.components.edible.healthvalue = TUNING.HEALING_MED     -- 20
	inst.components.edible.hungervalue = TUNING.CALORIES_MED    -- 25
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)    -- 6 day
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food" 
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/fish_med_cooked.xml"
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT    -- 1
    -- inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
	-- inst.data = {}
	inst:AddComponent("bait")

	return inst
end

return
Prefab( "fish_raw", fish_raw_fn, fish_raw_assets),
Prefab( "fish_med_cooked", cookedfn, cooked_assets)