local assets =
{
    Asset("ANIM", "anim/dragon_heart_gem.zip"),
    Asset("ANIM", "anim/beequeen_heart_gem.zip"),
    Asset("ANIM", "anim/malbatross_heart_gem.zip"),
	
	Asset("ATLAS", "images/inventoryimages/dragon_heart_gem.xml"),
	Asset("ATLAS", "images/inventoryimages/beequeen_heart_gem.xml"),
	Asset("ATLAS", "images/inventoryimages/malbatross_heart_gem.xml"),
}

local function OnEaten(inst, eater)
	if eater and eater.components and eater.components.talker then
		eater.components.talker:Say("味道不错，但这或许有其他用途")
	end
	-- 三种 buff  todo
end

local function fn_dragon()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("dragon_heart_gem")
    inst.AnimState:SetBuild("dragon_heart_gem")
    inst.AnimState:PlayAnimation("idle")
	
	MakeInventoryFloatable(inst)
	
    inst.entity:SetPristine()
	inst:AddTag("bossheart")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	
	inst:AddComponent("tradable")
	
	inst:AddComponent("edible")
    inst.components.edible.healthvalue = 50
    inst.components.edible.hungervalue = 50
	inst.components.edible.sanityvalue = 50
	inst.components.edible:SetOnEatenFn(OnEaten)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/dragon_heart_gem.xml"

    MakeHauntableLaunch(inst)

    return inst
end

local function fn_beequeen()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("beequeen_heart_gem")
    inst.AnimState:SetBuild("beequeen_heart_gem")
    inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	
    inst.entity:SetPristine()
	inst:AddTag("bossheart")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	
	inst:AddComponent("tradable")
	
	inst:AddComponent("edible")
    inst.components.edible.healthvalue = 50
    inst.components.edible.hungervalue = 50
	inst.components.edible.sanityvalue = 50
	inst.components.edible:SetOnEatenFn(OnEaten)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/beequeen_heart_gem.xml"

    MakeHauntableLaunch(inst)

    return inst
end

local function fn_malbatross()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("malbatross_heart_gem")
    inst.AnimState:SetBuild("malbatross_heart_gem")
    inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	
    inst.entity:SetPristine()
	inst:AddTag("bossheart")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	
	inst:AddComponent("tradable")
	
	inst:AddComponent("edible")
    inst.components.edible.healthvalue = 50
    inst.components.edible.hungervalue = 50
	inst.components.edible.sanityvalue = 50
	inst.components.edible:SetOnEatenFn(OnEaten)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/malbatross_heart_gem.xml"

    MakeHauntableLaunch(inst)

    return inst
end

return
Prefab("dragon_heart_gem", fn_dragon, assets),
Prefab("beequeen_heart_gem", fn_beequeen, assets),
Prefab("malbatross_heart_gem", fn_malbatross, assets)