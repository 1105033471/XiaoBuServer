local assets = {
    Asset("ANIM", "anim/skinstaff.zip"),
    Asset("ANIM", "anim/swap_skinstaff.zip"),
    Asset("ATLAS", "images/inventoryimages/skinstaff.xml"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_skinstaff", "skinstaff")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function collect(inst, target, pos)
    local user = inst.components.inventoryitem.owner
    
    -- 其他物品的接口
    if target ~= nil and target.reskin_func ~= nil then
        target.reskin_func(target, user)
        return
    end

    local r = 8
    local x,y,z = pos:Get()
    local ents = TheSim:FindEntities(x, y, z, r, { "_inventoryitem" }, { "INLIMBO", "FX", "fire", "NOCLICK" })
    for _,v in ipairs(ents)do
        local pt = v:GetPosition()
        if v.components.health then
            local pd = v:GetPersistData()
            local new = SpawnPrefab(v.prefab) --崩了别怪我
            if new then
                new:SetPersistData(pd, {})
                if user.components.inventory:GiveItem(new) then
                    SpawnPrefab("sand_puff").Transform:SetPosition(pt:Get())
                    v:Remove()
                else
                    new:Remove()
                end
            end
        elseif v.prefab ~= "bullkelp_beachedroot" and not v:HasTag("trap") then -- 海带茎(海带茎为啥不行。。)和陷阱除外
            if user.components.inventory:GiveItem(v) then
                SpawnPrefab("sand_puff").Transform:SetPosition(pt:Get())
            end
        end
    end

    local doer = inst.components.inventoryitem.owner
    if doer then
        if doer.components.hunger then
            doer.components.hunger:DoDelta(-10)
        end
        if doer.components.sanity then
            doer.components.sanity:DoDelta(-10)
        end
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("skinstaff")
    inst.AnimState:SetBuild("skinstaff")
    inst.AnimState:PlayAnimation("idle")
    
    MakeInventoryFloatable(inst)
    
    inst:AddTag("godweapon")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("tradable")
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(30)
    inst.components.weapon:SetRange(12)
    inst.components.weapon:SetProjectile("tz_projectile_bai")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skinstaff.xml"
    inst.components.inventoryitem.imagename = "skinstaff"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    
    MakeHauntableLaunch(inst)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(collect)
    inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.canuseontargets = true
    
    return inst
end

return Prefab( "skinstaff", fn, assets)