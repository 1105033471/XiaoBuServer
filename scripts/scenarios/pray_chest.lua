chestfunctions = require("scenarios/chestfunctions")

local loots = {
    {
        item = "fishingrod",
        initfn = function(inst) print("ming_fishingrod initfn") inst.no_finiteuse = true inst:RemoveComponent("finiteuses") end,
        count = 1,
    },
    --{
    --    item = "conch",
    --    count = 1,
    --},
}

local test_tbl = {
    {
        item = "nightmarefuel",
        count = 1,
    },
    nil,
    {
        item = "nightmarefuel",
        count = 1,
    },
    nil,
    {
        item = "conch",
        count = 1,
    },
    nil,
    {
        item = "nightmarefuel",
        count = 1,
    },
    nil,
    {
        item = "nightmarefuel",
        count = 1,
    },
}

local function GetDesc(inst, viewer)
    return "通往那个世界"
end

local function itemTest(inst, data)
    local res = true    -- 测试结果

    for i = 1, #test_tbl do
        local trueItem = inst.components.container:GetItemInSlot(i)
        local testItem = test_tbl[i]
        if trueItem ~= nil and testItem ~= nil then -- 都有东西，再检测东西是否一致
            if trueItem.prefab ~= testItem.item then    -- 东西不一致，测试失败
                res = false
                break
            end
        elseif (trueItem ~= nil and testItem == nil) or (trueItem == nil and testItem ~= nil) then  -- 不一致
            res = false
            break
        end
    end

    if res then -- 测试通过，将物品移除并恢复海螺的耐久
        local change_list = {1, 3, 7, 9}
        for k, i in pairs(change_list) do
            local item_lost = inst.components.container:RemoveItemBySlot(i)
            if item_lost.components.stackable and item_lost.components.stackable:StackSize() > 1 then
                local new_item = SpawnPrefab(item_lost.prefab)
                new_item.components.stackable:SetStackSize(item_lost.components.stackable:StackSize() - 1)
                inst.components.container:GiveItem(new_item, i)
            end
            item_lost:Remove()
        end
        local conch = inst.components.container:RemoveItemBySlot(5)
        conch.components.fueled:InitializeFuelLevel(100)
        inst.components.container:GiveItem(conch, 5)
    end

end

local function OnCreate(inst, scenariorunner)
    inst:RemoveComponent("workable")
    inst:RemoveComponent("machine")
    inst:RemoveComponent("burnable")

    inst.components.inspectable.getspecialdescription = GetDesc

    chestfunctions.AddChestItems(inst, loots)

    -- inst:ListenForEvent("onopen", triggertrap)
    inst:ListenForEvent("onclose", itemTest)
end

local function OnLoad(inst, scenariorunner)
    --Anything that needs to happen every time the game loads.
    inst:RemoveComponent("workable")
    inst:RemoveComponent("machine")
    inst:RemoveComponent("burnable")

    inst.components.inspectable.getspecialdescription = GetDesc

    -- inst:ListenForEvent("onopen", triggertrap)
    inst:ListenForEvent("onclose", itemTest)
end

local function OnDestroy(inst)
    --Stop any event listeners here.
    -- inst:RemoveEventCallback("onopen", triggertrap)
    inst:RemoveEventCallback("onclose", itemTest)
end

return
{
    OnCreate = OnCreate,
    OnLoad = OnLoad,
    OnDestroy = OnDestroy
}
