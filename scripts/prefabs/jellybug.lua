local assets =
{
	Asset("ANIM", "anim/jellybug.zip"),
	Asset("ATLAS", "images/inventoryimages/jellybug.xml"),
	Asset("ATLAS", "images/inventoryimages/jellybug_cooked.xml"),
}

local prefabs = 
{
	"spoiled_food",
}

local function jellybugfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBuild("jellybug")
	inst.AnimState:SetBank("jellybug")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:PushAnimation("idle", true)

	MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")
	inst:AddComponent("edible")
    inst.components.edible.healthvalue = -1
    inst.components.edible.hungervalue = 9.4
    inst.components.edible.sanityvalue = -5

    inst.components.edible.foodtype = FOODTYPE.MEAT
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "jellybug"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/jellybug.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("cookable")
	inst.components.cookable.product = "jellybug_cooked"

	MakeHauntableWork(inst)
	MakeSnowCovered(inst)

	return inst
end

local function jellybug_cookedfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBuild("jellybug")
	inst.AnimState:SetBank("jellybug")
	inst.AnimState:PlayAnimation("cooked")

	MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "jellybug_cooked"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/jellybug_cooked.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("edible")
    inst.components.edible.healthvalue = -1
    inst.components.edible.hungervalue = 12.5
    inst.components.edible.sanityvalue = 0

    inst.components.edible.foodtype = FOODTYPE.MEAT

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"
	inst:AddComponent("bait")

	MakeHauntableWork(inst)
	MakeSnowCovered(inst)

	return inst
end
return
Prefab( "jellybug", jellybugfn, assets, prefabs ),
Prefab( "jellybug_cooked", jellybug_cookedfn, assets, prefabs ) 
