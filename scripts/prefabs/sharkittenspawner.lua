local assets =
{
    Asset("ANIM", "anim/sharkitten_den.zip"),
}

local prefabs =
{
    "sharkitten",
    "tigershark",
}

local function ReturnChildren(inst)
    for k,child in pairs(inst.components.childspawner.childrenoutside) do
        if child.components.homeseeker then
            child.components.homeseeker:GoHome()
        end
        child:PushEvent("gohome")
    end
end

local function GetNearbySpawnPoint(target)
    local properties = {target:GetPosition(), 0, 40, 12}

    -- local offset = FindWaterOffset(unpack(properties))

    -- if not offset then
    local offset = FindWalkableOffset(unpack(properties))
    -- end

    return (offset and target:GetPosition() + offset) or nil
end

local function SummonShark(inst, doer)
    --Try to spawn a shark to protect this area.
    if TheWorld.ismastersim then
        local tigershark = c_findnext("tigershark")
        if tigershark ~= nil then          -- 当世界中存在虎鲨时，忽略召唤
            tigershark.components.combat:SuggestTarget(doer)
            return
        end

        local shark = SpawnPrefab("tigershark")
        if shark then
            local spawnpt = GetNearbySpawnPoint(doer)
            if spawnpt then
                shark.Transform:SetPosition(spawnpt:Get())
                shark.components.combat:SuggestTarget(doer)
            end
        end
    end
end

local function SpawnKittens(inst, num)
    for i = 1, num do
        local kitten = SpawnPrefab("sharkitten")
        kitten.Transform:SetPosition(inst:GetPosition():Get())
        inst.components.herd:AddMember(kitten)
    end
end

local function OnIsDay(inst, isday)
    if isday then
        inst.components.childspawner:StartSpawning()
    else
        inst.components.childspawner:StopSpawning()
        ReturnChildren(inst)
    end
end

local function ActivateSpawner(inst)
    -- if not inst.spawneractive then
        -- inst.spawneractive = true
            --inst.components.named:SetName(STRINGS.NAMES["SHARKITTENSPAWNER_ACTIVE"])
            --Queue up an animation change for next time this is off screen

        inst.activatefn = function()
            inst.AnimState:PlayAnimation("idle_active")
            --Start task to periodically blink if there are children inside
            inst.blink_task = inst:DoPeriodicTask(math.random() * 10 + 10, function()
                if inst.components.childspawner and inst.components.childspawner.childreninside > 0 then
                    inst.AnimState:PlayAnimation("blink")
                    inst.AnimState:PushAnimation("idle_active")
                end
            end)
    
            --inst:WatchWorldState("dusktime", inst.dusktime_fn, GetWorld())
            -- inst:WatchWorldState("iscaveday", OnIsDay)
        end

        -- if isload then
        inst.activatefn()
        -- end
    -- end
end

-- local function DeactiveateSpawner(inst, isload)
--     if inst.spawneractive then
--         inst.spawneractive = false
--         --inst.components.named:SetName(STRINGS.NAMES["SHARKITTENSPAWNER_INACTIVE"])
--         inst.deactivatefn = function()
--             --Queue up an animation change for the next time this is off screen
--             inst.AnimState:PlayAnimation("idle_inactive")
--             --Start task to periodically blink if there are children inside
--             if inst.blink_task then
--                 inst.blink_task:Cancel()
--                 inst.blink_task = nil
--             end

--             inst:StopWatchingWorldState("iscaveday", OnIsDay)
--         end

--         if isload then
--             inst.deactivatefn()
--         end
--     end
-- end

-- local function OnSeasonChange(inst, world, data)
--     if data.season == SEASONS.GREEN then
--         --Start the spawning.
--         ActivateSpawner(inst)
--     else
--         --Stop
--         DeactiveateSpawner(inst)
--     end
-- end

-- local function getstatus(inst)
--     if not inst.spawneractive then 
--         return "INACTIVE"
--     end
-- end

local function OnSave(inst, data)
    -- data.spawneractive = inst.spawneractive
end

local function OnLoad(inst, data)
    -- if data and data.spawneractive then
    --     inst.spawneractive = data.spawneractive
    -- end
    -- if data and data.spawneractive then
    --     ActivateSpawner(inst, true)
    -- else
    --     DeactiveateSpawner(inst, true)
    -- end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
    
    inst.MiniMapEntity:SetIcon("sharkitten_den.png")

    inst.AnimState:SetBuild("sharkitten_den")
    inst.AnimState:SetBank("sharkittenden")
    inst.AnimState:PlayAnimation("idle_inactive")

    inst:AddTag("sharkhome")
    inst:AddTag("tigersharkhome")

    MakeObstaclePhysics(inst, 2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "sharkitten"
    inst.components.childspawner:SetRegenPeriod(60 * 4)     -- TUNING.SHARKITTEN_REGEN_PERIOD)    -- 5 day
    inst.components.childspawner:SetSpawnPeriod(60 * 4)     -- TUNING.SHARKITTEN_SPAWN_PERIOD)    -- 30sec
    inst.components.childspawner:SetMaxChildren(4)
    inst.components.childspawner:StartRegen()

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetOnPlayerNear(SummonShark)     -- 玩家靠近后自动召唤
    inst.components.playerprox:SetDist(7.5, 10)
    inst.components.playerprox.period = 1

    inst:AddComponent("inspectable")
    -- inst.components.inspectable.getstatus = getstatus

    --inst:AddComponent("named")
    --inst.components.named:SetName(STRINGS.NAMES["SHARKITTENSPAWNER_INACTIVE"])

    inst.SpawnKittens = SpawnKittens
    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    --inst:ListenForEvent("seasonChange", function(...) OnSeasonChange(inst, ...) end, GetWorld())
    inst:WatchWorldState("iscaveday", OnIsDay)
    ActivateSpawner(inst)
    inst.components.childspawner:StartSpawning()

	return inst
end

return Prefab("sharkittenspawner", fn, assets, prefabs)