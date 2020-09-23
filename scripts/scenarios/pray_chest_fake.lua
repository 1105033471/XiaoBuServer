chestfunctions = require("scenarios/chestfunctions")

local loots = {
    {
        item = "log",
        -- initfn = function(inst) inst.no_finiteuse = true inst:RemoveComponent("finiteuses") end,
        count = function() return math.random(20, 40) end,  -- 写成函数可以保证每次调用的结果都不一样
    },
    {
        item = "bluegem",
        chance = 0.25,
    },
    {
        item = "redgem",
        chance = 0.25,
    },
    {
        item = "purplegem",
        chance = 0.25,
    },
    {
        item = "orangegem",
        chance = 0.4,
    },
    {
        item = "yellowgem",
        chance = 0.4,
    },
    {
        item = "greengem",
        chance = 0.4,
    },
}

local function GetDesc(inst, viewer)
    return "通往那个世界"
end

local function triggertrap(inst, data)  -- 触发陷阱
    local player = data.doer

    player.SoundEmitter:PlaySound("dontstarve/maxwell/appear_adventure")
    
    inst.not_triggered = false
    inst:RemoveEventCallback("onopen", triggertrap)
end

local function OnCreate(inst, scenariorunner)
    inst:RemoveComponent("workable")
    inst:RemoveComponent("machine")

    inst.components.inspectable.getspecialdescription = GetDesc

    chestfunctions.AddChestItems(inst, loots)

    inst.not_triggered = true
    inst:ListenForEvent("onopen", triggertrap)
end

local function OnLoad(inst, scenariorunner)
    --Anything that needs to happen every time the game loads.
    inst:RemoveComponent("workable")
    inst:RemoveComponent("machine")
    
    inst.components.inspectable.getspecialdescription = GetDesc
    -- print("load scenario")
    if inst.not_triggered then
        inst:ListenForEvent("onopen", triggertrap)
    end
end

local function OnDestroy(inst)
    --Stop any event listeners here.
    inst:RemoveEventCallback("onopen", triggertrap)
end

return
{
    OnCreate = OnCreate,
    OnLoad = OnLoad,
    OnDestroy = OnDestroy
}
