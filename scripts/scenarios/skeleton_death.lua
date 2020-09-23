local function GetDesc(inst, viewer)
    return "他死于神灵的惩罚"
end

local function HookHammered(inst)
    local old_fn = GetUpvalueHelper(GetUpvalueHelper(require("prefabs/skeleton").fn, "common_fn"), "onhammered")
    inst.components.workable.onfinish = function(inst, worker)
        if worker and worker:HasTag("player") and not worker:HasTag("playerghost") then
            worker:PushEvent("death")
            worker.deathpkname = "神罚"
        end
        if old_fn then old_fn(inst, worker) end
    end
end

local function OnCreate(inst, scenariorunner)
    inst.components.inspectable.getspecialdescription = GetDesc

    HookHammered(inst)
end

local function OnLoad(inst, scenariorunner)
    --Anything that needs to happen every time the game loads.
    inst.components.inspectable.getspecialdescription = GetDesc

    HookHammered(inst)
end

local function OnDestroy(inst)
    --Stop any event listeners here.
    -- inst:RemoveEventCallback("workfinished", onhammered)
end

return
{
    OnCreate = OnCreate,
    OnLoad = OnLoad,
    OnDestroy = OnDestroy
}
