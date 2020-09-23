local assets =
{
    Asset("ANIM", "anim/ruins_torch.zip"),
}

local prefabs =
{
    "maxwelllight_flame",
}

local function changelevels(inst, order)
    for i=1, #order do
        inst.components.burnable:SetFXLevel(order[i])
        Sleep(0.05)
    end
end

local function light(inst)    
    inst.task = inst:StartThread(function() changelevels(inst, inst.lightorder) end)    
end

-- 熄灭
local function extinguish(inst)
    if inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
end

local function onoccupiedlighttask(inst)
    if (TheWorld.state.phase == "day" or TheWorld.state.phase == "dusk") and inst.count_player <= 0 then    -- 如果白天，没有玩家在旁边，则熄火
        extinguish(inst)
    elseif TheWorld.state.phase == "night" and not inst.components.burnable:IsBurning() then -- 如果晚上，并且没点亮，则点亮
        inst.components.burnable:Ignite()
    end
end

local function player_increment(inst)
    inst.count_player = inst.count_player + 1
    if not inst.components.burnable:IsBurning() then
        inst.components.burnable:Ignite()
    end
end

local function player_decrement(inst)
    inst.count_player = inst.count_player - 1
    if inst.count_player <= 0 then
        inst.count_player = 0

        if TheWorld.state.phase == "day" or TheWorld.state.phase == "dusk" then
            extinguish(inst)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("pigtorch")
    inst.AnimState:SetBuild("ruins_torch")
    inst.AnimState:PlayAnimation("idle")

    MakeObstaclePhysics(inst, .1)

    inst:AddTag("structure")
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("burnable")
    inst.lightorder = {5,6,7,8,7}
    inst.components.burnable:AddBurnFX("maxwelllight_flame", Vector3(-11,-4,0), "fire_marker")
    inst.components.burnable:SetOnIgniteFn(light)
    
    inst:AddComponent("inspectable")

    inst:AddComponent("playerprox")
    inst.count_player = 0
    inst.components.playerprox:SetDist(17, 20)
    inst.components.playerprox:SetOnPlayerNear(player_increment)
    inst.components.playerprox:SetOnPlayerFar(player_decrement)

    inst:AddComponent("lootdropper")

    inst:WatchWorldState("phase", onoccupiedlighttask)

    return inst
end

return Prefab( "maxwelllight", fn, assets, prefabs),
MakePlacer( "maxwelllight_area_placer", "pigtorch", "ruins_torch", "idle" ) 
