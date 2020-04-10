local assets =
{
	Asset("ANIM", "anim/sweet_potato.zip"),
	Asset("ATLAS", "images/inventoryimages/sweet_potato.xml"),
	Asset("ATLAS", "images/inventoryimages/sweet_potato_cooked.xml"),
}

local prefabs =
{
    "spoiled_food",
}

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("sweet_potato")
	inst.AnimState:SetBuild("sweet_potato")
	inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
	
    inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 1
	inst.components.edible.sanityvalue = 0
	inst.components.edible.hungervalue = 12.5

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("tradable")
			
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "sweet_potato"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/sweet_potato.xml"
	
	inst:AddComponent("cookable")
	inst.components.cookable.product = "sweet_potato_cooked"

	inst:AddComponent("bait")

	return inst
end

local function onpicked(inst)
    inst:Remove()
end

local function planted_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("sweet_potato")
	inst.AnimState:SetBuild("sweet_potato")
	inst.AnimState:PlayAnimation("planted")

    inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
    inst.components.pickable:SetUp("sweet_potato", 10)
    inst.components.pickable.onpickedfn = onpicked
    inst.components.pickable.quickpick = true

    MakeSmallBurnable(inst)
	
    MakeSmallPropagator(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	return inst
end


local function cooked_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("sweet_potato")
	inst.AnimState:SetBuild("sweet_potato")
	inst.AnimState:PlayAnimation("cooked", true)
	
	MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
	
	inst.entity:SetPristine()
	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 3
	inst.components.edible.sanityvalue = 0
	inst.components.edible.hungervalue = 12.5

	inst:AddComponent("tradable")
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
	
	inst:AddComponent("inspectable")
	
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "sweet_potato_cooked"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/sweet_potato_cooked.xml"

	inst:AddComponent("bait")

	return inst
end

return
Prefab( "sweet_potato", fn, assets, prefabs),
Prefab( "sweet_potato_planted", planted_fn, assets, prefabs),
Prefab( "sweet_potato_cooked", cooked_fn, assets, prefabs)