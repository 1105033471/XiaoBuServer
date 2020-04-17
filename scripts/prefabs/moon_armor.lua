local assets =
{
    Asset("ANIM", "anim/armor_greengem.zip"),
    Asset("ATLAS", "images/inventoryimages/armor_greengem.xml"),
    Asset("IMAGE", "images/inventoryimages/armor_greengem.tex"),
}

local prefabs = {
    "forcefieldfx",
}

local function StopPoison(inst)
    inst:RemoveTag("poisoned")
    inst.components.health:StopRegen()
    inst.AnimState:SetMultColour(1,1,1,1)
end

local function turnoff(inst)
    if inst._light ~= nil then
        if inst._light:IsValid() then
            inst._light:Remove()
        end
        inst._light = nil
    end
end

local function ruinshat_fxanim(inst)
    inst._fx.AnimState:PlayAnimation("hit")
    inst._fx.AnimState:PushAnimation("idle_loop")
end

local function ruinshat_oncooldown(inst)
    inst._task = nil
end

local function ruinshat_unproc(inst)
    if inst:HasTag("forcefield") then
        inst:RemoveTag("forcefield")
        if inst._fx ~= nil then
            inst._fx:kill_fx()
            inst._fx = nil
        end
        inst:RemoveEventCallback("armordamaged", ruinshat_fxanim)

        inst.components.armor:SetAbsorption(TUNING.ARMOR_RUINSHAT_ABSORPTION)
        inst.components.armor.ontakedamage = nil

        if inst._task ~= nil then
            inst._task:Cancel()
        end
        inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_COOLDOWN, ruinshat_oncooldown)
    end
end

local function ruinshat_proc(inst, owner)
    inst:AddTag("forcefield")
    if inst._fx ~= nil then
        inst._fx:kill_fx()
    end
    inst._fx = SpawnPrefab("forcefieldfx")
    inst._fx.entity:SetParent(owner.entity)
    inst._fx.Transform:SetPosition(0, 0.2, 0)
    inst:ListenForEvent("armordamaged", ruinshat_fxanim)

    inst.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION)
    
    -- inst.components.armor.ontakedamage = function(inst, damage_amount)
        -- if owner ~= nil and owner.components.sanity ~= nil then
            -- owner.components.sanity:DoDelta(-damage_amount * TUNING.ARMOR_RUINSHAT_DMG_AS_SANITY, false)
        -- end
    -- end

    if inst._task ~= nil then
        inst._task:Cancel()
    end
    inst._task = inst:DoTaskInTime(TUNING.ARMOR_RUINSHAT_DURATION, ruinshat_unproc)
end

local function tryproc(inst, owner, data)
    if inst._task == nil and
        not data.redirected and
        math.random() < TUNING.ARMOR_RUINSHAT_PROC_CHANCE then
        ruinshat_proc(inst, owner)
    end
end

local function OnBlocked(owner, data)
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_scalemail")
    if data.attacker and data.attacker.components.health and not data.attacker:HasTag("poisoned") then 
        data.attacker:AddTag("poisoned")
        data.attacker.components.health:StartRegen(-4, 1, false)    -- 血量Delta,  优先度,   是否叠加
        data.attacker.AnimState:SetMultColour(2,2,0,2)
        data.attacker:DoTaskInTime(5, StopPoison)
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "armor_greengem", "swap_body")
    
    inst:ListenForEvent("blocked", OnBlocked, owner)
    inst:ListenForEvent("attacked", OnBlocked, owner)
    
    if inst._light == nil or not inst._light:IsValid() then
        inst._light = SpawnPrefab("yellowamuletlight")
    end
    
    -- if TheWorld.ismastersim then return end
    
    inst._light.entity:SetParent(owner.entity)
    inst._light.Light:SetRadius(5)
    inst._light.Light:SetFalloff(.9)
    inst._light.Light:SetIntensity(.8)
    inst._light.Light:SetColour(223 / 255, 208 / 255, 69 / 255)
    
    inst.onattach(owner)
    -- inst.Light:Enable(true)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
    inst:RemoveEventCallback("attacked", OnBlocked, owner)
    
    -- if TheWorld.ismastersim then return end
    
    turnoff(inst)
    inst.ondetach()
    -- inst.Light:Enable(false)
end

local function ruins_onremove(inst)
    if inst._fx ~= nil then
        inst._fx:kill_fx()
        inst._fx = nil
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddLight()
    
    inst.Light:SetFalloff(0.4)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(1.8)
    inst.Light:SetColour(155/255, 175/255, 195/255)
    inst.Light:Enable(false)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("armor_grass")
    inst.AnimState:SetBuild("armor_greengem")
    inst.AnimState:PlayAnimation("anim")

    inst.foleysound = "dontstarve/movement/foley/jewlery"

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/armor_greengem.xml"
    inst.components.inventoryitem.imagename = "armor_greengem"

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(2000, 0.9)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    -- inst.components.equippable.walkspeedmult = 1.1
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    -- inst:AddTag("waterproofer")
    -- inst:AddComponent("waterproofer")
    -- inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)
    
    inst.OnRemoveEntity = ruins_onremove        -- 在inst:Remove()的时候会调用
    
    inst._fx = nil
    inst._task = nil
    inst._owner = nil
    inst.procfn = function(owner, data) tryproc(inst, owner, data) end
    inst.onattach = function(owner)
        if inst._owner ~= nil then
            inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
            inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
        end
        inst:ListenForEvent("attacked", inst.procfn, owner)
        inst:ListenForEvent("onremove", inst.ondetach, owner)
        inst._owner = owner
        inst._fx = nil
    end
    inst.ondetach = function()
        ruinshat_unproc(inst)
        if inst._owner ~= nil then
            inst:RemoveEventCallback("attacked", inst.procfn, inst._owner)
            inst:RemoveEventCallback("onremove", inst.ondetach, inst._owner)
            inst._owner = nil
            inst._fx = nil
        end
    end
    
    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("moon_armor", fn, assets)
