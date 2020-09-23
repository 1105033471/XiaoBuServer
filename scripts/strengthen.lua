-- 修改海象刷新时间
TUNING.WALRUS_REGEN_PERIOD = TUNING.TOTAL_DAY_TIME*1.5
TUNING.WALRUS_ATTACK_PERIOD = 2

-- 加强巨鹿
TUNING.DEERCLOPS_HEALTH = 7000
TUNING.DEERCLOPS_DAMAGE = 200
TUNING.DEERCLOPS_DAMAGE_PLAYER_PERCENT = .9
TUNING.DEERCLOPS_ATTACK_RANGE = 10
TUNING.DEERCLOPS_AOE_RANGE = 6
TUNING.DEERCLOPS_ATTACK_PERIOD = 3
AddPrefabPostInit("deerclops", function(inst)
	if  inst.components.health  then
		inst.components.health.absorb = .3
    end
    
    -- 几率掉落宝石
    if inst.components.lootdropper then
        inst.components.lootdropper:AddRandomLoot("redgem", 1)
        inst.components.lootdropper:AddRandomLoot("bluegem", 1)
        inst.components.lootdropper:AddRandomLoot("purplegem", 1)
        
        inst.components.lootdropper:AddRandomLoot("greengem", .6)
        inst.components.lootdropper:AddRandomLoot("yellowgem", .6)
        inst.components.lootdropper:AddRandomLoot("orangegem", .6)
        inst.components.lootdropper.numrandomloot = 2
    end
end)

-- 加强熊大
TUNING.BEARGER_HEALTH = 8000
TUNING.BEARGER_DAMAGE = 180
TUNING.BEARGER_ATTACK_RANGE = 7
TUNING.BEARGER_ATTACK_PERIOD = 2
TUNING.BEARGER_ANGRY_WALK_SPEED = 8
AddPrefabPostInit("bearger", function(inst)
    if  inst.components.health  then
        inst.components.health.absorb = .3
    end
    if  inst.components.combat  then
        inst.components.combat.playerdamagepercent = .9
    end
    if inst.components.lootdropper then
        inst.components.lootdropper:AddRandomLoot("redgem", 1)
        inst.components.lootdropper:AddRandomLoot("bluegem", 1)
        inst.components.lootdropper:AddRandomLoot("purplegem", 1)
        
        inst.components.lootdropper:AddRandomLoot("greengem", .6)
        inst.components.lootdropper:AddRandomLoot("yellowgem", .6)
        inst.components.lootdropper:AddRandomLoot("orangegem", .6)
        inst.components.lootdropper.numrandomloot = 2
    end
end)

-- 加强龙鹰
TUNING.DRAGONFLY_DAMAGE = 200
TUNING.DRAGONFLY_ATTACK_PERIOD =  2
TUNING.DRAGONFLY_SPEED = 6
AddPrefabPostInit("dragonfly", function(inst)
    if  inst.components.health  then
        inst.components.health.absorb = .3
    end
    if inst.components.lootdropper then
        inst.components.lootdropper:AddRandomLoot("redgem", 1)
        inst.components.lootdropper:AddRandomLoot("bluegem", 1)
        inst.components.lootdropper:AddRandomLoot("purplegem", 1)
        
        inst.components.lootdropper:AddRandomLoot("greengem", .6)
        inst.components.lootdropper:AddRandomLoot("yellowgem", .6)
        inst.components.lootdropper:AddRandomLoot("orangegem", .6)
        inst.components.lootdropper.numrandomloot = 2
    end
end)

-- 加强鹿鹅
TUNING.MOOSE_HEALTH = 7000
TUNING.MOOSE_DAMAGE = 120
TUNING.MOOSE_ATTACK_RANGE = 5
TUNING.MOOSE_ATTACK_PERIOD = 2
AddPrefabPostInit("moose", function(inst)
    if inst.components.health then
        inst.components.health.absorb = .5
    end
    if inst.components.combat then
        inst.components.combat.playerdamagepercent = .9
    end
    if inst.components.lootdropper then
        inst.components.lootdropper:AddRandomLoot("redgem", 1)
        inst.components.lootdropper:AddRandomLoot("bluegem", 1)
        inst.components.lootdropper:AddRandomLoot("purplegem", 1)
        
        inst.components.lootdropper:AddRandomLoot("greengem", .6)
        inst.components.lootdropper:AddRandomLoot("yellowgem", .6)
        inst.components.lootdropper:AddRandomLoot("orangegem", .6)
        inst.components.lootdropper.numrandomloot = 2
    end
end)

-- 蜂后
TUNING.BEEQUEEN_MIN_GUARDS_PER_SPAWN = 5
TUNING.BEEQUEEN_MAX_GUARDS_PER_SPAWN = 6
TUNING.BEEQUEEN_TOTAL_GUARDS = 10
AddPrefabPostInit("beequeen", function(inst)
    if inst.components.health then
        inst.components.health.absorb = .2
    end
    if inst.components.lootdropper then
        inst.components.lootdropper:AddRandomLoot("redgem", 1)
        inst.components.lootdropper:AddRandomLoot("bluegem", 1)
        inst.components.lootdropper:AddRandomLoot("purplegem", 1)
        
        inst.components.lootdropper:AddRandomLoot("greengem", .6)
        inst.components.lootdropper:AddRandomLoot("yellowgem", .6)
        inst.components.lootdropper:AddRandomLoot("orangegem", .6)
        inst.components.lootdropper.numrandomloot = 2
    end
end)

-- 远古守护者
TUNING.MINOTAUR_DAMAGE = 150
TUNING.MINOTAUR_RUN_SPEED = 25
AddPrefabPostInit("minotaur", function(inst)
    if inst.components.health then
        inst.components.health.absorb = .4
    end
    if inst.components.lootdropper then
        inst.components.lootdropper:AddRandomLoot("redgem", 1)
        inst.components.lootdropper:AddRandomLoot("bluegem", 1)
        inst.components.lootdropper:AddRandomLoot("purplegem", 1)
        
        inst.components.lootdropper:AddRandomLoot("greengem", .6)
        inst.components.lootdropper:AddRandomLoot("yellowgem", .6)
        inst.components.lootdropper:AddRandomLoot("orangegem", .6)
        inst.components.lootdropper.numrandomloot = 2
    end
end)

-- 蚁狮
TUNING.ANTLION_HEALTH = 10000
AddPrefabPostInit("antlion", function(inst)
    if inst.components.health then
        inst.components.health.absorb = .3
    end
    if inst.components.lootdropper then
        inst.components.lootdropper:AddRandomLoot("redgem", 1)
        inst.components.lootdropper:AddRandomLoot("bluegem", 1)
        inst.components.lootdropper:AddRandomLoot("purplegem", 1)
        
        inst.components.lootdropper:AddRandomLoot("greengem", .6)
        inst.components.lootdropper:AddRandomLoot("yellowgem", .6)
        inst.components.lootdropper:AddRandomLoot("orangegem", .6)
        inst.components.lootdropper.numrandomloot = 2
    end
end)

-- 邪天翁
TUNING.MALBATROSS_HEALTH = 10000
TUNING.MALBATROSS_ATTACK_PERIOD = 3
AddPrefabPostInit("malbatross", function(inst)
    if inst.components.health then
        inst.components.health.absorb = .3
    end
    if inst.components.lootdropper then
        inst.components.lootdropper:AddRandomLoot("redgem", 1)
        inst.components.lootdropper:AddRandomLoot("bluegem", 1)
        inst.components.lootdropper:AddRandomLoot("purplegem", 1)
        
        inst.components.lootdropper:AddRandomLoot("greengem", .6)
        inst.components.lootdropper:AddRandomLoot("yellowgem", .6)
        inst.components.lootdropper:AddRandomLoot("orangegem", .6)
        inst.components.lootdropper.numrandomloot = 2
    end
end)

-- 蜘蛛女王
TUNING.SPIDERQUEEN_ATTACKPERIOD = 2
AddPrefabPostInit("spiderqueen", function(inst)
    if inst.components.health then
        inst.components.health.absorb = .3
    end
end)

-- 高鸟
TUNING.TALLBIRD_HEALTH = 1200
TUNING.TALLBIRD_ATTACK_PERIOD = 1
AddPrefabPostInit("tallbird", function(inst)
    if inst.components.health then
        inst.components.health.absorb = .2
    end
end)

-- 大象(夏)
TUNING.KOALEFANT_HEALTH = 1500
TUNING.KOALEFANT_DAMAGE = 100
AddPrefabPostInit("koalefant_summer", function(inst)
    if inst.components.health then
        inst.components.health.absorb = .2
    end
end)

-- 大象(冬)
AddPrefabPostInit("koalefant_winter", function(inst)
    if inst.components.health then
        inst.components.health.absorb = .2
    end
end)

-- 座狼
AddPrefabPostInit("warg", function(inst)
    if inst.components.health then
        inst.components.health.absorb = .3
    end
end)

-- 钢羊
AddPrefabPostInit("spat", function(inst)
    if inst.components.health then
        inst.components.health.absorb = .2
    end
end)

-- 电羊
TUNING.LIGHTNING_GOAT_ATTACK_PERIOD = 1
AddPrefabPostInit("lightninggoat", function(inst)
    if inst.components.health  then
        inst.components.health.absorb = .2
    end
end)

-- 自动复活
local function Clear(player)
    player.resurrect = nil
    if player:HasTag("playerghost") then
        local random_time = math.random(5,10)
		player:DoTaskInTime(3, function()
			player.components.talker:Say("resurrect time left: "..tostring(random_time-2).." seconds")
		end)
        player.resurrect = player:DoTaskInTime(random_time, function(player)
            ExecuteConsoleCommand('local player = UserToPlayer("'..player.userid..'") player:PushEvent("respawnfromghost")')
        end)
    end
end

AddPlayerPostInit(function(player)
    player:ListenForEvent("death", function(player, data)
        if player.resurrect == nil then     -- 冷却完毕
            -- print(" try to resurrect")
			local random_time = math.random(5,10)
			player:DoTaskInTime(3, function()
				player.components.talker:Say("将在 "..tostring(random_time-3).."秒 后复活")
			end)
            player.resurrect = player:DoTaskInTime(random_time, function(player)
                ExecuteConsoleCommand('local player = UserToPlayer("'..player.userid..'") player:PushEvent("respawnfromghost")')
            end)
        else    -- 尚未冷却完毕

        end
    end)
    player:DoPeriodicTask(TUNING.TOTAL_DAY_TIME, Clear)    -- 复活冷却：1游戏天数
end)

-- 人物死亡装备不掉落
AddComponentPostInit("inventory", function(Inventory, inst)
    local function DropLifeItem(inst, backpack)
        -- 掉落装备的护符
        local amulet = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.NECK or EQUIPSLOTS.BODY)
        if amulet and amulet.prefab == "amulet" then
            inst.components.inventory:DropItem(amulet)
            return
        end

        for i = 1, inst.components.inventory:GetNumSlots() do  -- 掉落身上的护符
            local slotItem = inst.components.inventory:GetItemInSlot(i)
            if slotItem and slotItem.prefab == "amulet" then
                inst.components.inventory:DropItem(inst.components.inventory:GetItemInSlot(i), true)
                return
            end
        end

        if backpack then
            for i = 1, backpack.components.container:GetNumSlots() do  -- 掉落背包的护符
                local slotItem = backpack.components.container:GetItemInSlot(i)
                if slotItem and slotItem.prefab == "amulet" then
                    backpack.components.container:DropItemBySlot(i)
                    return
                end
            end
        end

        for i = 1, inst.components.inventory:GetNumSlots() do  -- 掉落身上的救赎之心
            local slotItem = inst.components.inventory:GetItemInSlot(i)
            if slotItem and slotItem.prefab == "reviver" then
                inst.components.inventory:DropItem(inst.components.inventory:GetItemInSlot(i), true)
                return
            end
        end

        if backpack then
            for i = 1, backpack.components.container:GetNumSlots() do  -- 掉落背包的救赎之心
                local slotItem = backpack.components.container:GetItemInSlot(i)
                if slotItem and slotItem.prefab == "reviver" then
                    backpack.components.container:DropItemBySlot(i)
                    return
                end
            end
        end
    end

    local function DropRandomItem(inst)
        local slot = math.random(1, inst.components.inventory:GetNumSlots())
        inst.components.inventory:DropItem(inst.components.inventory:GetItemInSlot(slot), true)
    end

    Inventory.oldDropEverythingFn = Inventory.DropEverything
    function Inventory:DropEverything(ondeath, keepequip)
        if not inst:HasTag("player") then   -- 非玩家，原版掉落机制
            return Inventory:oldDropEverythingFn(ondeath, keepequip)
        else        -- 玩家
            local backpack = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BACK or EQUIPSLOTS.BODY)
            DropLifeItem(inst, backpack)    -- 掉落身上可复活的物品
            if inst.components.inventory:IsFull() then  -- 身上东西满了
                DropRandomItem(inst)    -- 随机掉落一个物品
            end
            return true
        end
    end
end)