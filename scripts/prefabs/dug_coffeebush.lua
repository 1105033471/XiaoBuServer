local assets =
{
	Asset("ANIM", "anim/coffeebush.zip"),
	Asset("ATLAS", "images/inventoryimages/dug_coffeebush.xml"),
}

local function ondeploy(inst, pt, deployer)
	local tree = SpawnPrefab("coffeebush")
	if tree ~= nil then
		tree.Transform:SetPosition(pt:Get())
		inst.components.stackable:Get():Remove()
		-- if workable_type == "pickable" then
			tree.components.pickable:OnTransplant()
		-- elseif workable_type == "hackable" then
		--     tree.components.hackable:OnTransplant()
		-- end
		if deployer ~= nil and deployer.SoundEmitter ~= nil then
			--V2C: WHY?!! because many of the plantables don't
			--     have SoundEmitter, and we don't want to add
			--     one just for this sound!
			deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
		end

	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	--inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("coffeebush")
	inst.AnimState:SetBuild("coffeebush")
	inst.AnimState:PlayAnimation("dropped")

	--MakeDragonflyBait(inst, 3)
	MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "dug_coffeebush"
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/dug_coffeebush.xml"

	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

	MakeMediumBurnable(inst, TUNING.LARGE_BURNTIME)
	MakeSmallPropagator(inst)

	MakeHauntableLaunchAndIgnite(inst)

	inst:AddComponent("deployable")
	--inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)PLANT
	inst.components.deployable.ondeploy = ondeploy
	inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
	--inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.MEDIUM) 

	MakeHauntableWork(inst)
	MakeSnowCovered(inst)
	---------------------
	return inst
end

return
Prefab("dug_coffeebush", fn, assets),
MakePlacer("common/dug_coffeebush_placer", "coffeebush", "coffeebush", "idle_dead")--最后3个参数  build bank 预览动画