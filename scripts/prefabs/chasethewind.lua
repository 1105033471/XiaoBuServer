local assets=
{
	Asset("ANIM", "anim/chasethewind.zip"),
	Asset("ANIM", "anim/swap_chasethewind.zip"),
	Asset("ATLAS", "images/inventoryimages/chasethewind.xml"),
	Asset("IMAGE", "images/inventoryimages/chasethewind.tex"),
}

local prefabs = {
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_chasethewind", "swap_chasethewind")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
end

local function repair(inst)
    local repair = inst.components.finiteuses.current/inst.components.finiteuses.total + .2
    if repair >= 1 then repair = 1 end
    inst.components.finiteuses:SetUses(math.floor(repair*inst.components.finiteuses.total))
    inst.components.chasethewindstatus.use = inst.components.finiteuses.current
end

local function valuecheck(inst)
    local level = inst.components.chasethewindstatus.level + inst.components.chasethewindstatus.level2
    inst.components.weapon:SetDamage(27 + math.floor(level/5))

    if inst.components.chasethewindstatus.level2 > 0 then
        inst.components.equippable.walkspeedmult = 1.25
    else
        inst.components.equippable.walkspeedmult = 1.15
    end
    
    if inst.components.finiteuses then
        inst.components.finiteuses:SetMaxUses(200+level*5)
        inst.components.finiteuses:SetUses(inst.components.chasethewindstatus.use)
    end

    if (inst.components.chasethewindstatus.level + inst.components.chasethewindstatus.level2) >= 315 then
        inst.components.finiteuses.current = inst.components.finiteuses.total
        inst:RemoveComponent("finiteuses")
        inst:RemoveComponent("trader")
	inst:AddTag("hide_percentage")
    end
end

local function onattack(inst, attacker, target, skipsanity, owner)
	local chance = 20
    local damage = inst.components.weapon.damage
    if target and attacker and math.random(1,100) <= chance and not target:HasTag("wall") then
        target.components.combat:GetAttacked(attacker, damage)	-- 再次造成一次伤害
        local snap = SpawnPrefab("impact")
        snap.Transform:SetScale(3, 3, 3)
        snap.Transform:SetPosition(target.Transform:GetWorldPosition())
        if target.SoundEmitter ~= nil then
            target.SoundEmitter:PlaySound("dontstarve/common/whip_large")
        end
    end
    if inst.components.finiteuses then
        inst.components.chasethewindstatus.use = inst.components.finiteuses.current
    end
end

local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    elseif item.prefab == "goldnugget" and inst.components.chasethewindstatus.level < 165 then
        return true
    elseif item.prefab == "moonrocknugget" and inst.components.chasethewindstatus.level >= 165 and inst.components.chasethewindstatus.level2 < 150 then
        return true
	else
		return false
    end
end

local function OnGemGiven(inst, giver, item)
	if item.prefab == "goldnugget" then
		inst.components.chasethewindstatus:DoDeltaLevel(1)
		local goldnugget_count = inst.components.chasethewindstatus.level
		if goldnugget_count < 165 then
			giver.components.talker:Say("金块 "..tostring(goldnugget_count).."/165")
			inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
		else
			giver.components.talker:Say("进阶成功，下阶需要材料为\n月石")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
		end
	elseif item.prefab == "moonrocknugget" then
		inst.components.chasethewindstatus:DoDeltaLevel2(1)
		local moon_count = inst.components.chasethewindstatus.level2
		if moon_count < 150 then
			giver.components.talker:Say("月石 "..tostring(moon_count).."/150")
			inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
		else
			giver.components.talker:Say("进阶成功！(满级)")
			inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
		end
	end
	
    valuecheck(inst)
    
	if inst.components.chasethewindstatus.level2 < 150 then
        repair(inst)
    end
end

local function OnRefuseItem(inst, giver, item)
	if item then
		if inst.components.chasethewindstatus.level < 165 then
			giver.components.talker:Say("或许他需要金块")
		elseif inst.components.chasethewindstatus.level2 < 150 then
			giver.components.talker:Say("或许他需要月石")
		end
	end
end

-- local function OnFinished(inst)
	-- inst.components.weapon:SetDamage(1)
-- end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
	inst.entity:AddNetwork() 
    inst.entity:AddSoundEmitter()
	
    anim:SetBank("chasethewind")
    anim:SetBuild("chasethewind")
    anim:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	
	inst:AddTag("godweapon")
	
	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("tradable")
    inst:AddComponent("chasethewindstatus")
	
	-- inst:AddComponent("tool")
    -- inst.components.tool:SetAction(ACTIONS.CHOP, 1)
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(27)
    inst.components.weapon:SetOnAttack(onattack)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/chasethewind.xml"

	inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(200+inst.components.chasethewindstatus.level*5)
    inst.components.finiteuses:SetUses(inst.components.chasethewindstatus.use)

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGemGiven
	inst.components.trader.onrefuse = OnRefuseItem

    inst:DoTaskInTime(0, function() valuecheck(inst) end)
    
    return inst
end


return Prefab("chasethewind", fn, assets, prefabs) 