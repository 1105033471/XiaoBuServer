local assets =
{
    Asset("ANIM", "anim/grass.zip"),
    Asset("ANIM", "anim/reeds.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local prefabs =
{
    "cutreeds",
}

local function onpickedfn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
    inst.AnimState:PlayAnimation("picking")
    inst.AnimState:PushAnimation("picked")
	-- modified --
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 30, {"reeds"}, nil, nil)
	local count = ents == nil and 0 or #ents		-- 附近30码的芦苇丛数量
	
	local chance = 0.05*(40-count)/40
	
	-- print("chance = "..chance)
	if math.random() < chance then
		inst.components.lootdropper:SpawnLootPrefab("dug_reeds")
	end
end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)
end

local function makeemptyfn(inst)
    inst.AnimState:PlayAnimation("picked")
end

local function DigUp(inst)
	if inst.components.lootdropper and inst.components.pickable then
		if inst.components.pickable:CanBePicked() then
			inst.components.lootdropper:SpawnLootPrefab("cutreeds")
		end
		
		inst.components.lootdropper:SpawnLootPrefab("dug_reeds")
	end
	inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("reeds.png")

    inst:AddTag("plant")
	inst:AddTag("reeds")	-- 添加芦苇标签

    inst.AnimState:SetBank("grass")
    inst.AnimState:SetBuild("reeds")
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.AnimState:SetTime(math.random() * 2)
    local color = 0.75 + math.random() * 0.25
    inst.AnimState:SetMultColour(color, color, color, 1)

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_reeds"
    inst.components.pickable:SetUp("cutreeds", TUNING.REEDS_REGROW_TIME)
    inst.components.pickable.onregenfn = onregenfn
    inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.SetRegenTime = 120

    inst:AddComponent("inspectable")
	
	--------- modified -------
	inst:AddComponent("lootdropper")
	
	inst:AddComponent("workable")		-- 只有芦苇根才能移植，自然生成的不可以
	inst.components.workable:SetWorkAction(ACTIONS.DIG)
	inst.components.workable:SetOnFinishCallback(DigUp)
	inst.components.workable:SetWorkLeft(1)
	--------- end -----------
	
    ---------------------        
    -- inst:AddComponent("fuel")
    -- inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    -- MakeSmallBurnable(inst, TUNING.SMALL_FUEL)
    MakeSmallPropagator(inst)
    MakeNoGrowInWinter(inst)
    MakeHauntableIgnite(inst)
    ---------------------   

    return inst
end

return Prefab("new_reeds", fn, assets, prefabs)
