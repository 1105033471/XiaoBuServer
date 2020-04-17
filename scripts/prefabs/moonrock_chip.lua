local assets = 
{
	Asset("ANIM", "anim/moonrock_chip.zip"),
	Asset("ATLAS", "images/inventoryimages/moonrock_chip.xml"),
}

local prefabs = {

}

local function fn()

	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("moonrock_chip")
    inst.AnimState:SetBuild("moonrock_chip")
	inst.AnimState:PlayAnimation("idle")
    
    MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
    
    inst.entity:SetPristine()
    
	if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/moonrock_chip.xml"
    inst.components.inventoryitem.imagename = "moonrock_chip"
    
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    MakeHauntableLaunch(inst)
    
    return inst
end

return Prefab("moonrock_chip", fn, assets, prefabs)
