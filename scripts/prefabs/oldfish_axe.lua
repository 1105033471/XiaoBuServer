local assets = {
	Asset("ANIM", "anim/oldfish_axe.zip"),
	Asset("ANIM", "anim/swap_oldfish_axe.zip"),
	Asset("IMAGE", "images/inventoryimages/oldfish_axe.tex"),
	Asset("ATLAS", "images/inventoryimages/oldfish_axe.xml"),
}

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_oldfish_axe", "swap_oldfish_axe")
	if inst.components.oldfishaxestate.level >= 1 then
		inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
	end
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function AcceptTest(inst, item)
	if item == nil then
        return false
    elseif inst.components.oldfishaxestate == nil then
        return false
    elseif inst.components.oldfishaxestate.level == 0 and item:HasTag("godweapon") then
        return true
    elseif inst.components.oldfishaxestate.level == 1 and item.prefab == "mandrakesoup" then
        return true
    else
		return false
	end
end

local function valuecheck(inst)
	-- 校对攻击力和攻击距离等属性
	local damage = 10
	local range = 1
	if inst.components.oldfishaxestate.level > 0 then	-- 献祭成功后获得大幅攻击力提升
		damage = 80
		range = 2
		inst:AddComponent("tool")
		inst.components.tool:SetAction(ACTIONS.CHOP, 5)
	end
	if inst.components.oldfishaxestate.level > 1 then
		inst:RemoveComponent("trader")
	end
	inst.components.weapon:SetDamage(damage)
	inst.components.weapon:SetRange(range)
end

local function OnGetItemFromPlayer(inst, giver, item)
	if inst.components.oldfishaxestate.level == 0 then
		inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/livinglog_burn")
		local tmp = math.random()
		if inst.components.oldfishaxestate.give_count >= 5 then		-- 五次失败后，下次必定成功
			tmp = 1
		end
		if tmp > 0.4 then
			inst.components.oldfishaxestate:DoGiveGodweapon()
			TheNet:Announce(giver:GetDisplayName().."成功将【"..item:GetDisplayName().."】献祭给【"..inst:GetDisplayName().."】！")
			inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
		else
			giver.components.talker:Say("献祭失败!")
			inst.components.oldfishaxestate.give_count = inst.components.oldfishaxestate.give_count + 1
		end
		local give_count = inst.components.oldfishaxestate.give_count
		if give_count == 5 then			-- 失败五次后，给予全服公告嘲笑^_^
			TheNet:Announce(giver:GetDisplayName().."在向"..inst:GetDisplayName().."献祭时又失败啦(累计失败 5 次)！让我们恭喜他！")
		end
	elseif inst.components.oldfishaxestate.level == 1 then
		if inst.components.oldfishaxestate.soup_count < 9 then
			inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
			inst.components.oldfishaxestate:DoGiveSoup(1)
			giver.components.talker:Say("强化成功!\n曼德拉汤 "..inst.components.oldfishaxestate.soup_count.."/10")
		else
			inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
			giver.components.talker:Say("进阶成功！")
			inst.components.oldfishaxestate:DoGiveSoup(1)
		end
	end
	valuecheck(inst)
end

local function onattack(inst, attacker, target)
	if not (target:HasTag("wall") or target:HasTag("lureplant")) then		-- 吸血效果对墙体和食人花无效
		if inst.components.oldfishaxestate.level >= 1 then		-- 嗜血效果
			attacker.components.health:DoDelta(0.2 * inst.components.oldfishaxestate.soup_count)
		end
	end
end

local function OnRefuseItem(inst, giver, item)
	if item then
		if inst.components.oldfishaxestate.level == 0 then
			giver.components.talker:Say("需要献祭一把神器才能激活它")
		elseif inst.components.oldfishaxestate.level == 1 then
			giver.components.talker:Say("它现在需要曼德拉汤")
		end
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("oldfish_axe")
	inst.AnimState:SetBuild("oldfish_axe")
	inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	
	inst.entity:SetPristine()
	inst:AddTag("godweapon")
	
	if not TheWorld.ismastersim then
		return inst
	end

	-- Modified
	
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(10)
	inst.components.weapon:SetRange(1)
	inst.components.weapon:SetOnAttack(onattack)
	
	inst:AddComponent("tradable")

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/oldfish_axe.xml"

	-- inst:AddComponent("fuel")
	-- inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
	
	inst:AddComponent("oldfishaxestate")

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(AcceptTest)
	inst.components.trader.onaccept = OnGetItemFromPlayer
	inst.components.trader.onrefuse = OnRefuseItem

	MakeHauntableLaunch(inst)
	
	inst:DoTaskInTime(0, function() valuecheck(inst) end)

	return inst
end

return Prefab("oldfish_axe", fn, assets)