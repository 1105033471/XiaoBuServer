local assets =
{
    Asset("ANIM", "anim/treeroot.zip"),
    
    Asset("ATLAS", "images/inventoryimages/treeroot.xml")
}

local prefabs =
{

}

local NUM_TYPES = 2         -- 两种类型

local function SetType(inst, t_type)
    if inst.t_type ~= t_type then
        inst.t_type = t_type
        local anim_t = "f"..tostring(t_type)
        -- print("play animation: "..anim_t)
        inst.AnimState:PlayAnimation(anim_t)
    end
end

local function onsave(inst, data)
    data.t_type = inst.t_type
end

local function onload(inst, data)
    if data ~= nil and
        data.t_type ~= nil and
        data.t_type >= 1 and
        data.t_type <= NUM_TYPES then
        SetType(inst, data.t_type)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("treeroot")
    inst.AnimState:SetBuild("treeroot")
    SetType(inst, 1)

    MakeInventoryFloatable(inst)
    
    -- inst:AddTag("deployedplant")
    inst:AddTag("treeroot")

    if not TheWorld.ismastersim then
        return inst
    end
    
    SetType(inst, math.random(NUM_TYPES))
    
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/treeroot.xml"

    -- inst:AddComponent("deployable")            -- 种植
    -- inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    -- inst.components.deployable.ondeploy = ondeploy
    
    -- MakeHauntableIgnite(inst)            -- 作祟后不移动的标准组件
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL  -- 燃料燃烧时间

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)
    
    MakeHauntableLaunch(inst)                -- 作祟后会移动的标准组件
    
    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return
Prefab("treeroot", fn, assets, prefabs)