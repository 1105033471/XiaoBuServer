local assets = {
	Asset("ANIM", "anim/tz_icesword.zip"),
	Asset("ANIM", "anim/swap_tz_icesword.zip"),
	Asset("IMAGE", "images/inventoryimages/tz_icesword.tex"),
	Asset("ATLAS", "images/inventoryimages/tz_icesword.xml"),
}

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_tz_icesword", "swap_tz_icesword")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("tz_icesword")
	inst.AnimState:SetBuild("tz_icesword")
	inst.AnimState:PlayAnimation("idle")

	MakeInventoryFloatable(inst)
	
	inst.entity:SetPristine()
	inst:AddTag("godweapon")

	if not TheWorld.ismastersim then
		return inst
	end

	-- Modified
	inst:AddComponent("tradable")
	
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(60)
	inst.components.weapon:SetRange(1.5)

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/tz_icesword.xml"

	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	-- inst:AddComponent("trader")
	-- inst.components.trader:SetAcceptTest(AcceptTest)
	-- inst.components.trader.onaccept = OnGetItemFromPlayer

	MakeHauntableLaunch(inst)

	return inst
end

return Prefab("tz_icesword", fn, assets)