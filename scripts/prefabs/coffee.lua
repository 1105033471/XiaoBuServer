local assets =
{
	Asset("ANIM", "anim/coffee.zip"),
	Asset("ANIM", "anim/feijoada.zip"),
	Asset("ANIM", "anim/tomato_soup.zip"),
	Asset("ATLAS", "images/inventoryimages/coffee.xml"),
	Asset("ATLAS", "images/inventoryimages/feijoada.xml"),
	Asset("ATLAS", "images/inventoryimages/tomato_soup.xml"),
}

local prefabs = 
{
	"spoiled_food",
}

local CAFFEINE_SPEED_MODIFIER = 1.55
local CAFFEINE_DURATION = 5 * 60
local function StartCaffeineFn(inst, eater)
	if eater.components.talker then
		eater.components.talker:Say("我变得像风一样了!")
	end
	if eater.components.locomotor ~= nil and eater.components.caffeinated ~= nil then
		eater.components.caffeinated:Caffeinate(CAFFEINE_SPEED_MODIFIER, CAFFEINE_DURATION)
	end
end

local function onEatTomatoSoup(inst, eater)
	local flower = SpawnPrefab(math.random() > 0.95 and "flower_rose" or "flower")
	if eater and eater.components and eater.components.talker then
		eater.components.talker:Say("美好的一天从这道美味开始！")
		flower.Transform:SetPosition(eater.Transform:GetWorldPosition())
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBuild("coffee")
	inst.AnimState:SetBank("coffee")
	inst.AnimState:PlayAnimation("idle", false)

	inst:AddTag("preparedfood")
	MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 1
	inst.components.edible.hungervalue = 10
	inst.components.edible.foodtype = FOODTYPE.GOODIES
	inst.components.edible.sanityvalue = -5
	inst.components.edible.temperaturedelta = 5
	inst.components.edible.temperatureduration = 60
	inst.components.edible:SetOnEatenFn(StartCaffeineFn)

	inst:AddComponent("inspectable")
	inst.wet_prefix = "soggy"
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/coffee.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	MakeHauntableLaunchAndPerish(inst)
	AddHauntableCustomReaction(inst, function(inst, haunter) return false end, true, false, true)

	inst:AddComponent("bait")
	inst:AddComponent("tradable")

	return inst
end

local function feijoadafn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	inst.AnimState:SetBuild("feijoada")
	inst.AnimState:SetBank("feijoada")
	inst.AnimState:PlayAnimation("idle", false)

	inst:AddTag("preparedfood")
	MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 80
	inst.components.edible.hungervalue = 75
	inst.components.edible.foodtype = FOODTYPE.MEAT
	inst.components.edible.sanityvalue = 15

	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/feijoada.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	MakeHauntableLaunchAndPerish(inst)     
	inst:AddComponent("bait")
	inst:AddComponent("tradable")		
	return inst
end

local function tomato_soupfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	inst.AnimState:SetBuild("tomato_soup")
	inst.AnimState:SetBank("tomato_soup")
	inst.AnimState:PlayAnimation("idle", false)

	inst:AddTag("preparedfood")
	MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("edible")
	inst.components.edible.healthvalue = 20
	inst.components.edible.hungervalue = 30
	inst.components.edible.foodtype = FOODTYPE.GENERIC
	inst.components.edible.sanityvalue = 50
	inst.components.edible:SetOnEatenFn(onEatTomatoSoup)

	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/tomato_soup.xml"

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	MakeHauntableLaunchAndPerish(inst)     
	inst:AddComponent("bait")
	inst:AddComponent("tradable")		
	return inst
end

return
Prefab( "coffee", fn, assets, prefabs ),
Prefab( "feijoada", feijoadafn, assets, prefabs ),
Prefab( "tomato_soup", tomato_soupfn, assets, prefabs )
