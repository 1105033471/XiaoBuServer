local assets =
{
    Asset("ANIM", "anim/cave_chocolate.zip"),
	
	Asset("ATLAS", "images/inventoryimages/cave_chocolate.xml"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cave_chocolate")
    inst.AnimState:SetBuild("cave_chocolate")
    inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst:AddComponent("inspectable")
	
	inst:AddComponent("tradable")
	
	inst:AddComponent("edible")
    inst.components.edible.healthvalue = 2
    inst.components.edible.hungervalue = 15
	inst.components.edible.sanityvalue = 5
	
	inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/cave_chocolate.xml"

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("cave_chocolate", fn, assets)