local assets =
{
	Asset("ANIM", "anim/coffeebeans.zip"),
	Asset("ATLAS", "images/inventoryimages/coffeebeans.xml"),
	Asset("ATLAS", "images/inventoryimages/coffeebeans_cooked.xml"),
}

local prefabs = 
{
	"spoiled_food",
}

local function coffeebeansfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBuild("coffeebeans")
	inst.AnimState:SetBank("coffeebeans")
	inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 1
	inst.components.edible.hungervalue = 12.5
	inst.components.edible.sanityvalue = 0
	inst.components.edible.foodtype = FOODTYPE.GENERIC
	
	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "coffeebeans"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/coffeebeans.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("cookable")
	inst.components.cookable.product = "coffeebeans_cooked"

	MakeHauntableWork(inst)
	MakeSnowCovered(inst)

	return inst
end


local function coffeebeans_cookedfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBuild("coffeebeans")
	inst.AnimState:SetBank("coffeebeans")
	inst.AnimState:PlayAnimation("cooked")

	MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "coffeebeans_cooked"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/coffeebeans_cooked.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 3
	inst.components.edible.hungervalue = 12.5
	inst.components.edible.sanityvalue = -5
	inst.components.edible.foodtype = FOODTYPE.GENERIC

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
Prefab( "coffeebeans", coffeebeansfn, assets, prefabs),
Prefab( "coffeebeans_cooked", coffeebeans_cookedfn, assets, prefabs) 
