local assets=
{
	Asset("ANIM", "anim/dropped.zip"),
	Asset("ATLAS", "images/inventoryimages/dug_reeds.xml"),
	Asset("IMAGE", "images/inventoryimages/dug_reeds.tex"),

}

local function ondeploy(inst, pt)
	local tree = SpawnPrefab("new_reeds")
	if tree then 
		tree.Transform:SetPosition(pt.x, pt.y, pt.z)
		tree.AnimState:PlayAnimation("picked")
		
		tree.components.pickable:OnTransplant()
		tree.components.pickable:MakeEmpty()
		
		tree.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
		
		inst.components.stackable:Get():Remove()
	end 
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("dropped")
	inst.AnimState:SetBuild("dropped")
	inst.AnimState:PlayAnimation("dropped_reeds")

	if not TheWorld.ismastersim then
		return inst
	end

	inst.entity:SetPristine()

	inst:AddComponent("pickable")
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
	
	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "dug_reeds"
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/dug_reeds.xml"
	inst.components.inventoryitem.imagename = "dug_reeds"
	
	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	
	MakeMediumBurnable(inst)		-- 燃烧
	MakeSmallPropagator(inst)		-- 燃烧时火焰蔓延
	
	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = ondeploy
	inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
	-- inst.components.deployable.spacing = 2		-- 用默认的种植距离就好了
	
	return inst
end

return
Prefab( "dug_reeds", fn, assets),
MakePlacer( "common/dug_reeds_placer", "grass", "reeds", "picked")