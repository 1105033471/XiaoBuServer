local assets=
{
    Asset("ANIM", "anim/conch.zip"),

	Asset("ATLAS", "images/inventoryimages/conch.xml"),
    Asset("IMAGE", "images/inventoryimages/conch.tex"),
}

local function OnPlayConch(inst, musician)
	inst.components.fueled:DoDelta(-20)
    -- 召唤出一些东西
end

local function check(inst)
    if inst.components.fueled:GetPercent() > 0 then
        inst:AddTag("canuseconch")
    else
        inst:RemoveTag("canuseconch")
    end
end

local function fn()
    local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("conch")
    inst.AnimState:SetBuild("conch")
    inst.AnimState:PlayAnimation("idle")

    -- inst:AddTag("conch")     -- 这个标签在sg里用，控制右键演奏的动作选择

    --tool (from tool component) added to pristine state for optimization
    inst:AddTag("tool")

    -- inst:AddTag("canuseconch")  -- 能演奏

	MakeInventoryFloatable(inst)
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    -- inst:AddComponent("stackable")
	-- inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/conch.xml"
    
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)        -- 演奏的动作

    inst:AddComponent("instrument")                     -- 演奏的效果
    inst.components.instrument:SetOnPlayedFn(OnPlayConch)
    
    -- inst:AddComponent("finiteuses")
    -- inst.components.finiteuses:SetMaxUses(5)
    -- inst.components.finiteuses:SetUses(5)
    -- -- inst.components.finiteuses:SetOnFinished(inst.Remove)
    -- inst.components.finiteuses:SetConsumption(ACTIONS.PLAY, 1)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled.accepting = false        -- 不能修
    inst.components.fueled:InitializeFuelLevel(100)

	inst:ListenForEvent("percentusedchange", check)
	inst:DoTaskInTime(0, check)

    -- inst:ListenForEvent("percentusedchange", check)     -- 每次使用时更新
	-- inst:DoTaskInTime(0, check)

    return inst
end

return Prefab( "conch", fn, assets)
