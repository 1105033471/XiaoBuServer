local assets =
{
	Asset("ANIM", "anim/armor_obsidian.zip"),
	
	Asset("ATLAS", "images/inventoryimages/armor_obsidian.xml"),
    Asset("IMAGE", "images/inventoryimages/armor_obsidian.tex"),
}
--[[
local function OnBlocked(owner, data)
    if (data.weapon == nil or (not data.weapon:HasTag("projectile") and data.weapon.projectile == nil))
        and data.attacker and data.attacker.components.burnable 
        and (data.attacker.components.combat == nil or (data.attacker.components.combat.defaultdamage > 0)) then

        data.attacker.components.burnable:Ignite()
    end
end]]

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_obsidian", "swap_body")

    -- inst:ListenForEvent("blocked", OnBlocked, owner)
    -- inst:ListenForEvent("attacked", OnBlocked, owner)

    -- if owner.components.health then
        -- owner.components.health.fire_damage_scale = owner.components.health.fire_damage_scale - TUNING.ARMORDRAGONFLY_FIRE_RESIST
    -- end
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")

    -- inst:RemoveEventCallback("blocked", OnBlocked, owner)
    -- inst:RemoveEventCallback("attacked", OnBlocked, owner)
    
    -- if owner.components.health then
        -- owner.components.health.fire_damage_scale = owner.components.health.fire_damage_scale + TUNING.ARMORDRAGONFLY_FIRE_RESIST
    -- end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
	inst.entity:AddNetwork()
 
    inst.AnimState:SetBank("armor_obsidian")
    inst.AnimState:SetBuild("armor_obsidian")
    inst.AnimState:PlayAnimation("anim")

	MakeInventoryFloatable(inst)
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/volcanoinventory.xml"		-- ÎïÆ·À¸ÌùÍ¼
	inst.caminho = "images/inventoryimages/volcanoinventory.xml"

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0.2)	-- ·ÀË®20%
	
	inst:AddComponent("insulator")
	inst.components.insulator:SetInsulation(120)	-- ±£Å¯120
	
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(3150, 0.95)		-- ÄÍ¾Ã3150£¬·ÀÓù95%
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
	inst.components.equippable.dapperness = 3/54	-- »Øsan +3
    
    return inst
end

return Prefab( "armorobsidian", fn, assets) 
