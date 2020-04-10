local assets=
{
	Asset("ANIM", "anim/flyinghunter.zip"),
	Asset("ANIM", "anim/swap_flyinghunter.zip"),
	Asset("ATLAS", "images/inventoryimages/flyinghunter.xml"),
	Asset("IMAGE", "images/inventoryimages/flyinghunter.tex"),
}

local prefabs = {
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_flyinghunter", "swap_flyinghunter")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
end

local function onattack(inst, attacker, target, skipsanity, owner)
	local chance = 40
	local damage = inst.components.weapon.damage
	if target and target:HasTag("flyingboss") then
		target.components.combat:GetAttacked(attacker, damage)	-- 再次造成一次伤害
		if math.random(1, 100) <= chance then
			target.components.combat:GetAttacked(attacker, damage)	-- 再次造成一次伤害
			local snap = SpawnPrefab("impact")		-- 攻击特效
			snap.Transform:SetScale(3, 3, 3)
			snap.Transform:SetPosition(target.Transform:GetWorldPosition())
			if target.SoundEmitter ~= nil then
				target.SoundEmitter:PlaySound("dontstarve/common/whip_large")
			end
		end
	end
end

local function valuecheck(inst)
    inst.components.weapon:SetDamage(50 + inst.components.flyinghunterstatus:GetExtraDamage())
	inst.components.equippable.walkspeedmult = inst.components.flyinghunterstatus:GetSpeed()
end

local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    elseif item:HasTag("bossheart") then
        return true
    else
		return false
	end
end

local function OnGemGiven(inst, giver, item)
    inst.components.flyinghunterstatus:DoDeltaLevel()
    inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
	giver.components.talker:Say("攻击力提升   +1.5\n移速提升   +0.5%")
	valuecheck(inst)
end

local function OnRefuseItem(inst, giver, item)
	if item then
		giver.components.talker:Say("不，它需要更强大的物品")
	end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
	inst.entity:AddNetwork() 
    inst.entity:AddSoundEmitter()
	
    anim:SetBank("flyinghunter")
    anim:SetBuild("flyinghunter")
    anim:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	
	inst:AddTag("godweapon")
	
	if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("tradable")
    inst:AddComponent("flyinghunterstatus")
		
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(50)
	inst.components.weapon:SetRange(1.5)
    inst.components.weapon:SetOnAttack(onattack)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/flyinghunter.xml"

	inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGemGiven
	inst.components.trader.onrefuse = OnRefuseItem

    inst:DoTaskInTime(0, function() valuecheck(inst) end)
    
    return inst
end


return Prefab("flyinghunter", fn, assets, prefabs) 