local assets =
{
    Asset("ANIM", "anim/waterdrop.zip"),
	Asset("ANIM", "anim/lifeplant.zip"),
	
    Asset("ATLAS", "images/inventoryimages/waterdrop.xml")
}

local prefabs =
{
	"lifeplant"
}

local function ondeploy(inst, pt, deployer)
	-- inst = inst.components.stackable:Get()			-- 叠加数量-1
    inst.Physics:Teleport(pt:Get())
    
	local plant = SpawnPrefab("lifeplant")
	plant.Transform:SetPosition(inst.Transform:GetWorldPosition())
    plant.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("waterdrop")
    inst.AnimState:SetBuild("waterdrop")
    inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst, "idle_water", "idle")
	
    -- inst:AddTag("deployedplant")
    inst:AddTag("waterdrop")

    if not TheWorld.ismastersim then
        return inst
    end
	
	-- inst:AddComponent("stackable")
    -- inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/waterdrop.xml"

	inst:AddComponent("deployable")			-- 种植
	inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
	inst.components.deployable.ondeploy = ondeploy
	
	-- MakeHauntableIgnite(inst)			-- 作祟后不移动的标准组件
	
	MakeHauntableLaunch(inst)				-- 作祟后会移动的标准组件

    return inst
end

return
Prefab("waterdrop", fn, assets, prefabs),
MakePlacer("common/waterdrop_placer", "lifeplant", "lifeplant", "idle_loop")