local DEBUG_MODE = true

-----------------------------------------------------------------------
------------------------[[    Utility    ]]----------------------------
-----------------------------------------------------------------------
local function DebugPrint(str)
    if DEBUG_MODE then
        print(str)
    end
end

-----------------------------------------------------------------------
------------------------[[    TUNING    ]]-----------------------------
-----------------------------------------------------------------------
--饥饿自动吃食物
local HUNGRY_FLOOR = 10         -- 饱食度的下限，饱食度低于此值时将会自动吃东西

local PRIOR_FOOD = {            -- 优先吃这里的食物，如果都没有则吃身上的第一个料理
    "bonestew",                 -- 肉汤
    "meatballs",                -- 肉丸
    "baconeggs",                -- 培根煎蛋
    "honeyham",                 -- 蜜汁火腿
    "turkeydinner",             -- 火鸡大餐
    "honeynuggets",             -- 甜蜜金砖
    "frogglebunwich",           -- 蛙腿三明治
}

-----------------------------------------------------------------------
------------------------[[    Main    ]]-------------------------------
-----------------------------------------------------------------------
local preparedfood = require("preparedfoods")

local foods = {}
local foodname_wathgrithr = {}        -- 女武神能吃的料理

for _, food in pairs(preparedfood) do
    if food.health >= 0 and food.sanity >= 0 then        -- 过滤负面作用的食物
        table.insert(foods, food.name)
        if food.foodtype == FOODTYPE.MEAT or food.foodtype == FOODTYPE.GOODIES then
            table.insert(foodname_wathgrithr, food.name)
        end
    end
end

local function CanEatFood(player, food)
    return table.contains(player.prefab ~= "wathgrithr" and foods or foodname_wathgrithr, food.prefab)
end

local function FindInvWithTestAndDo(Inv, testfn, dofn)
    if Inv and testfn and type(testfn) == "function" then
        for i = 1, Inv:GetNumSlots() do
            local slotItem = Inv:GetItemInSlot(i)
            if testfn(slotItem) and dofn and type(dofn) == "function" then
                return dofn(slotItem)
            end
        end
    end
end

local function TryToEatFood()
    if ThePlayer.replica.hunger:GetCurrent() < HUNGRY_FLOOR then
        DebugPrint("饱食度过低，准备吃东西")
        local playerInventory = ThePlayer.replica.inventory
        local backpack = playerInventory:GetEquippedItem(EQUIPSLOTS.BACK or EQUIPSLOTS.BODY)

        -- 先看看身上或者背包里有没有高优先级的食物
        for k, target_food in pairs(PRIOR_FOOD) do
            for i = 1, playerInventory:GetNumSlots() do
                local slotItem = playerInventory:GetItemInSlot(i)
                if slotItem and slotItem.prefab == target_food then
                    -- 过滤新鲜度低于50%的食物
                    -- local perish_percent = slotItem.replica.inventoryitem.classified.perish:value() / 62
                    -- if perish_percent >= 0.5 then

                    DebugPrint("吃身上的高优先级东西："..slotItem.prefab)
                    playerInventory:UseItemFromInvTile(slotItem)
                    Sleep(1)
                    return
                end
            end

            if backpack and backpack.replica.container then
                for i = 1, backpack.replica.container:GetNumSlots() do
                    local slotItem = backpack.replica.container:GetItemInSlot(i)
                    if slotItem and slotItem.prefab == target_food then
                        DebugPrint("吃背包的高优先级东西："..slotItem.prefab)
                        playerInventory:UseItemFromInvTile(slotItem)
                        Sleep(1)
                        return
                    end
                end
            end
        end

        -- 尝试吃身上的食物
        for i = 1, playerInventory:GetNumSlots() do
            local slotItem = playerInventory:GetItemInSlot(i)
            if slotItem and slotItem:HasTag("preparedfood") then
                if CanEatFood(ThePlayer, slotItem) then
                    DebugPrint("吃身上的料理："..slotItem.prefab)
                    playerInventory:UseItemFromInvTile(slotItem)
                    Sleep(1)
                    return
                end
            end
        end

        -- 尝试吃背包的食物
        if backpack and backpack.replica.container then
            for i = 1, backpack.replica.container:GetNumSlots() do
                local slotItem = backpack.replica.container:GetItemInSlot(i)
                if slotItem and slotItem:HasTag("preparedfood") then
                    if CanEatFood(ThePlayer, slotItem) then
                        DebugPrint("吃背包的料理："..slotItem.prefab)
                        playerInventory:UseItemFromInvTile(slotItem)
                        Sleep(1)
                        return 
                    end
                end
            end
        end
        DebugPrint("身上没有料理可以吃")

        -- 非料理的食物不适用于沃利
        if ThePlayer.prefab == "warly" then
            return
        end

        -- 尝试吃身上的鱼
        for i = 1, playerInventory:GetNumSlots() do
            local slotItem = playerInventory:GetItemInSlot(i)
            if slotItem and slotItem.prefab == "fish" then
                DebugPrint("吃身上的鱼："..slotItem.prefab)
                playerInventory:UseItemFromInvTile(slotItem)
                Sleep(1)
                return
            end
        end

        -- 尝试吃背包的鱼
        if backpack and backpack.replica.container then
            for i = 1, backpack.replica.container:GetNumSlots() do
                local slotItem = backpack.replica.container:GetItemInSlot(i)
                if slotItem and slotItem.prefab == "fish" then
                    DebugPrint("吃背包的鱼："..slotItem.prefab)
                    playerInventory:UseItemFromInvTile(slotItem)
                    Sleep(1)
                    return 
                end
            end
        end
        DebugPrint("身上没有鱼可以吃")
    end
end

local function TryToKillFish()
    local playerInventory = ThePlayer.replica.inventory
    local backpack = playerInventory:GetEquippedItem(EQUIPSLOTS.BACK or EQUIPSLOTS.BODY)

    -- 杀身上的鱼
    for i = 1, playerInventory:GetNumSlots() do
        local slotItem = playerInventory:GetItemInSlot(i)
        if slotItem and (slotItem.prefab == "pondfish" or slotItem.prefab == "pondeel") then
            DebugPrint("杀身上的鱼："..slotItem.prefab)
            Sleep(0.3)
            playerInventory:UseItemFromInvTile(slotItem)
            Sleep(1)
            return
        end
    end

    -- 杀背包的鱼
    if backpack and backpack.replica.container then
        for i = 1, backpack.replica.container:GetNumSlots() do
            local slotItem = backpack.replica.container:GetItemInSlot(i)
            if slotItem and (slotItem.prefab == "pondfish" or slotItem.prefab == "pondeel") then
                if CanEatFood(ThePlayer, slotItem) then
                    DebugPrint("杀背包的鱼："..slotItem.prefab)
                    Sleep(0.3)
                    playerInventory:UseItemFromInvTile(slotItem)
                    Sleep(1)
                    return 
                end
            end
        end
    end

    DebugPrint("身上没有鱼可以杀")
end

function Bu_AutoFishing_Start()
    -- 再次按下 F5 关闭钓鱼线程
    if ThePlayer.bu_fishingThread then
        ThePlayer.bu_fishingThread:SetList(nil)
        ThePlayer.bu_fishingThread = nil
        ThePlayer.components.talker:Say("自动钓鱼： 关闭")
        return
    end

    ThePlayer.components.talker:Say("自动钓鱼： 开启")
    -- 获取鱼竿制作给服务器发送的rpc_id
    local rpc_id
    for k,v in pairs(AllRecipes) do
        if v.name == "fishingrod" then
            rpc_id = v.rpc_id
        end 
    end
    if rpc_id == nil then return end
    
    local pos = ThePlayer:GetPosition()
    local playerController = ThePlayer.components.playercontroller
    local handItem = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local playerInventory = ThePlayer.replica.inventory
    
    -- 获取身上或背包里的鱼竿
    local function getFishingrod()
        local searchResult = nil
        for i=1,playerInventory:GetNumSlots() do
            local slotItem = playerInventory:GetItemInSlot(i)
            if slotItem and slotItem.prefab == "fishingrod" then
                searchResult = slotItem
                break
            end
        end
        local backpack = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.BACK or EQUIPSLOTS.BODY)
        if backpack and not searchResult then
            for i=1,backpack.replica.container:GetNumSlots() do
                local slotItem = backpack.replica.container:GetItemInSlot(i)
                if slotItem and slotItem.prefab == "fishingrod" then
                    searchResult = slotItem
                    break
                end
            end
        end
        return searchResult
    end
    
    -- 装备鱼竿
    local need_sleep = false
    if handItem == nil then
        local fishingrod = getFishingrod()
        if not fishingrod and ThePlayer.replica.builder:CanBuild("fishingrod") then
            SendRPCToServer(RPC.MakeRecipeFromMenu, rpc_id)
            need_sleep = true
        end
    elseif handItem.prefab ~= "fishingrod" then
        local fishingrod = getFishingrod()
        if not fishingrod then
            return
        end
        playerInventory:UseItemFromInvTile(fishingrod)
    end
    
    -- 开启钓鱼线程
    ThePlayer.bu_fishingThread = ThePlayer:StartThread(function()
        local continueFish = true
        local generic_action = nil
        if need_sleep then
            Sleep(1.3)
        end
        while continueFish do
            local playerInventory = ThePlayer.replica.inventory
            local backpack = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.BACK or EQUIPSLOTS.BODY)
            local handItem = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            DebugPrint("循环继续")
            if not handItem or handItem.prefab ~= "fishingrod" then
                local fishingrod = getFishingrod()
                -- 如果身上没有鱼竿，并且能够制作鱼竿，则向服务器发送制作请求
                if not fishingrod and ThePlayer.replica.builder:CanBuild("fishingrod") then
                    Sleep(1.3)
                    DebugPrint("如果身上没有鱼竿，并且能够制作鱼竿，则向服务器发送制作请求")
                    SendRPCToServer(RPC.MakeRecipeFromMenu, rpc_id)
                    Sleep(1.3)
                end

                DebugPrint("身上有鱼竿:")
                -- 身上有鱼竿则装备
                local handItem = ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if not handItem or handItem.prefab ~= "fishingrod" then
                    DebugPrint("手上没有鱼竿: "..tostring(handItem))
                    local fishingrod = getFishingrod()
                    if not fishingrod then
                        return
                    end
                    playerInventory:UseItemFromInvTile(fishingrod)
                end
            end

            -- 获取20码内的池塘
            local pond = FindEntity(ThePlayer,20,function(guy)
                return (guy.prefab == "pond" or guy.prefab == "pond_mos" or guy.prefab == "pond_cave"
                or guy.prefab == "oasislake") and guy:GetDistanceSqToPoint(pos:Get()) < 14*14
                end,nil,{ "INLIMBO", "noauradamage" })
            if pond ~= nil and continueFish then
                DebugPrint("找到池塘")
                local pondPos = pond:GetPosition()
                local controlmods = playerController:EncodeControlMods() 
                local leftMouseBtn = ThePlayer.components.playeractionpicker:DoGetMouseActions(pondPos, pond) 
                if leftMouseBtn then
                    local strings = leftMouseBtn and leftMouseBtn:GetActionString() or ""
                    if strings == STRINGS.ACTIONS.REEL.REEL or strings == STRINGS.ACTIONS.FISH then
                        if strings == STRINGS.ACTIONS.FISH and generic_action == nil then
                            generic_action = leftMouseBtn
                        end
                        -- TryToKillFish()
                        DebugPrint("是 reel 或 fish")
                        playerController:DoAction(leftMouseBtn)
                        Sleep(0.2)
                        SendRPCToServer(RPC.LeftClick, leftMouseBtn.action.code, pondPos.x, pondPos.z, pond, false, controlmods, false, leftMouseBtn.action.mod_name)
                    elseif strings == STRINGS.ACTIONS.REEL.GENERIC then
                        DebugPrint("是 generic")
                        playerController:DoAction(leftMouseBtn)
                        Sleep(0.1)
                        SendRPCToServer(RPC.LeftClick, leftMouseBtn.action.code, pondPos.x, pondPos.z, pond, false, controlmods, false, leftMouseBtn.action.mod_name)
                        TryToEatFood()
                    elseif generic_action ~= nil then    -- 其他，发送generic动作
                        DebugPrint("是 其他")
                        -- TryToKillFish()
                        playerController:DoAction(generic_action)
                        Sleep(0.1)
                        SendRPCToServer(RPC.LeftClick, generic_action.action.code, pondPos.x, pondPos.z, pond, false, controlmods, false, generic_action.action.mod_name)
                        -- TryToEatFood()
                    end
                else
                    print("无法点击池塘！")
                    Sleep(1)
                    TryToKillFish()
                end
            else
                -- 找不到附近的池塘，结束钓鱼
                continueFish = false
                ThePlayer.bu_fishingThread:SetList(nil)
                ThePlayer.bu_fishingThread = nil
            end
            Sleep(0.1)
        end
    end)
end
