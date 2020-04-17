local assets=
{
	Asset("ANIM", "anim/phoenixspear_ice.zip"),
	Asset("ANIM", "anim/phoenixspear_fire.zip"),
	Asset("ANIM", "anim/swap_phoenixspear_ice.zip"),
	Asset("ANIM", "anim/swap_phoenixspear_fire.zip"),
	Asset("ATLAS", "images/inventoryimages/phoenixspear_ice.xml"),
	Asset("ATLAS", "images/inventoryimages/phoenixspear_fire.xml"),
}

local prefabs = {
}

local function onequip_ice(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_phoenixspear_ice", "swap_phoenixspear_ice")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onequip_fire(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_phoenixspear_fire", "swap_phoenixspear_fire")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
end

local function valuecheckice(inst)
	if inst:HasTag("icebuff") then		-- 强化之后移除trader属性
		inst:RemoveComponent("trader")
		inst:AddComponent("tool")		-- 强化后的冰霜凤凰剑可以当铲子
		inst.components.tool:SetAction(ACTIONS.DIG, 1)
		inst.components.weapon:SetRange(1.2)
	end
end

local function valuecheckfire(inst)
	if inst:HasTag("firebuff") then		-- 强化之后移除trader属性
		inst:RemoveComponent("trader")
		inst.components.weapon:SetRange(1.2)
	end
end

local function AcceptTestIce(inst, item)
	if item == nil then
		return false
	elseif item.prefab ~= "phoenixspear_fire" then
		return false
	else
		return true
	end
end

local function OnGetItemFromPlayerIce(inst, giver, item)
	inst:AddTag("icebuff")
    inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
	valuecheckice(inst)
end

local function AcceptTestFire(inst, item)
	if item == nil then
		return false
	elseif item.prefab ~= "phoenixspear_ice" then
		return false
	else
		return true
	end
end

local function OnGetItemFromPlayerFire(inst, giver, item)
	inst:AddTag("firebuff")
    inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
	valuecheckfire(inst)
end

local function onattack(inst, attacker, target)
	if inst:HasTag("firebuff") then
		local chance = math.random()
		if chance > 0.6 then	-- 40% 概率给予火焰伤害
			local fx = SpawnPrefab("firesplash_fx")		-- 火焰特效
			fx.Transform:SetScale(0.4, 0.4, 0.4)
			fx.Transform:SetPosition(target:GetPosition():Get())
			-- if target.components.burnable then
				-- target.components.burnable:Ignite()
			-- end
			target.components.health:DoDelta(-20)	-- 火焰伤害 20
		end
	elseif inst:HasTag("icebuff") then
		local chance = math.random()
        if target.components.health.maxhealth <= 200 then
            chance = 1
        end
		if chance > 0.4 then		-- 60% 给与冰冻效果
			local fx = SpawnPrefab("groundpoundring_fx")		-- 圆环扩散的特效
			local pos = Vector3(target.Transform:GetWorldPosition())
			fx.Transform:SetScale(0.3, 0.3, 0.3)
			fx.Transform:SetPosition(pos:Get())
			
            if target.components.freezable then
                target.components.freezable:AddColdness(0.5)
                target.components.freezable:SpawnShatterFX()
            end
			target.components.health:DoDelta(-2)				-- 冰冻造成2点伤害
			
			local prefab = "icespike_fx_"..math.random(1,4)		-- 冰冻特效
			local fx = SpawnPrefab(prefab)
			fx.Transform:SetScale(1, 0.6, 1)
			fx.Transform:SetPosition(target:GetPosition():Get())
		end
	end
end

local function OnRefuseItemIce(inst, giver, item)
	if item then
		giver.components.talker:Say("我觉得我能找到更合适的材料\n比如......火焰凤凰剑？")
	end
end

local function OnRefuseItemFire(inst, giver, item)
	if item then
		giver.components.talker:Say("我觉得我能找到更合适的材料\n比如......冰霜凤凰剑？")
	end
end

local function OnLoad(inst, data)
	if data then
		if data.icebuff then
			inst:AddTag("icebuff")
		elseif data.firebuff then
			inst:AddTag("firebuff")
		end
	end
end

local function onsave(inst, data)
	if inst:HasTag("icebuff") then
		data.icebuff = true
	elseif inst:HasTag("firebuff") then
		data.firebuff = true
	end
end

local function fn_ice()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
	inst.entity:AddNetwork() 
    inst.entity:AddSoundEmitter()
	
    anim:SetBank("phoenixspear_ice")
    anim:SetBuild("phoenixspear_ice")
    anim:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	
	inst:AddTag("godweapon")
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(54)
	inst.components.weapon:SetOnAttack(onattack)
    
    inst:AddComponent("inspectable")
	
	inst:AddComponent("tradable")
	-- inst:AddComponent("fueled")		-- 可以添加燃料
	
	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(AcceptTestIce)
	inst.components.trader.onaccept = OnGetItemFromPlayerIce
	inst.components.trader.onrefuse = OnRefuseItemIce
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/phoenixspear_ice.xml"

	inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip_ice )
    inst.components.equippable:SetOnUnequip( onunequip )
	-- inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT
	
	inst.OnLoad = OnLoad
	inst.OnSave = onsave
	
	inst:DoTaskInTime(0, function() valuecheckice(inst) end)
    
    return inst
end

local function fn_fire()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
	inst.entity:AddNetwork() 
    inst.entity:AddSoundEmitter()
		
    anim:SetBank("phoenixspear_fire")
    anim:SetBuild("phoenixspear_fire")
    anim:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	
	inst:AddTag("godweapon")
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(54)
	inst.components.weapon:SetOnAttack(onattack)
    
    inst:AddComponent("inspectable")
	
	inst:AddComponent("tradable")	-- 可以给其他物品
	
	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(AcceptTestFire)
	inst.components.trader.onaccept = OnGetItemFromPlayerFire
	inst.components.trader.onrefuse = OnRefuseItemFire
	
	-- inst:AddComponent("fueled")		-- 可以添加燃料
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/phoenixspear_fire.xml"

	inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip_fire )
    inst.components.equippable:SetOnUnequip( onunequip )
	-- inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT
	
	inst.OnLoad = OnLoad
	inst.OnSave = onsave
	
	inst:DoTaskInTime(0, function() valuecheckfire(inst) end)
    
    return inst
end

return
Prefab("phoenixspear_ice", fn_ice, assets, prefabs),
Prefab("phoenixspear_fire", fn_fire, assets, prefabs)