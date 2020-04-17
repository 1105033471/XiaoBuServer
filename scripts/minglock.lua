local _G = GLOBAL
local TheSim = _G.TheSim
local TheNet = _G.TheNet

local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()
local EQUIPSLOTS = _G.EQUIPSLOTS

modimport("mingconfig/lockconfig.lua")		-- 加载配置文件

if IsServer then
    modimport("scripts/gd_global.lua")
    modimport("scripts/manager_players.lua")
    modimport("scripts/manager_walls.lua")
    modimport("scripts/manager_beefalos.lua")
    modimport("scripts/manager_others.lua")
    modimport("scripts/manager_permission.lua")
    modimport("scripts/manager_shelters.lua")
    modimport("scripts/player_start.lua")
    modimport("scripts/gd_speech.lua")

    local test_mode = GetLockConfig("test_mode") --测试模式

    local admin_option = GetLockConfig("admin_option") --管理员受权限控制

    local is_allow_build_near = GetLockConfig("is_allow_build_near") --防止违规建筑

    local cant_destroyby_monster = GetLockConfig("cant_destroyby_monster") --防止怪物摧毁

    local portal_clear = GetLockConfig("portal_clear") --防止玩家封门

    local pack_pickup = GetLockConfig("pack_pickup") --背包拾取增强

    local ancient_altar_no_destroy = GetLockConfig("ancient_altar_no_destroy") --完整远古祭坛防拆毁

    local trap_teeth_player = GetLockConfig("trap_teeth_player") --犬牙陷阱攻击无权限玩家

    local eyeturret_player = GetLockConfig("eyeturret_player") --眼球塔攻击无权限玩家

    local house_plain_nodestroy = GetLockConfig("house_plain_nodestroy") --防止玩家破坏野外猪人房兔人房鱼人房
    -- local config_item = _G.require("config_item")

    -- 物品范围权限
    local item_ScopePermission = 12
    --local tile_map = {}

    --重要地点附近自动清理操作
    local function portalnearautodeletefn(inst)
        if _G.TheWorld.ismastersim then
            if not inst.components.near_autodelete then
                inst:AddComponent("near_autodelete")
                if trap_teeth_player then
                    inst.components.near_autodelete:AddCustomPrefab("trap_teeth")
                end
                if eyeturret_player then
                    inst.components.near_autodelete:AddCustomPrefab("eyeturret")
                end
                inst.components.near_autodelete:SetScope(portal_clear)
                inst.components.near_autodelete:start()
            end
        end
    end

    if portal_clear == true or (type(portal_clear) == "number" and portal_clear > 0) then
        for k, v in pairs(config_item.item_clear_auto) do
            AddPrefabPostInit(v, portalnearautodeletefn)
        end
    --AddPrefabPostInit("multiplayer_portal", portalnearautodeletefn)
    end

    --玩家下线或者跳世界强制掉落无权使用的背包 --引用 河蟹防熊锁(兼容版)
    AddComponentPostInit(
        "playerspawner",
        function(PlayerSpawner, inst)
            --玩家跳世界
            inst:ListenForEvent(
                "ms_playerdespawnandmigrate",
                function(inst, date)
                    player = date.player

                    --掉落
                    if player and player.components.inventory then
                        if player.components.inventory:EquipHasTag("backpack") then
                            equip_items =
                                FindEquipItems(
                                player,
                                function(m_inst)
                                    return m_inst:HasTag("backpack")
                                end
                            )

                            if #equip_items >= 1 then
                                for k, v in pairs(equip_items) do
                                    --无使用权限则掉落
                                    if CheckItemPermission(player, v, true) then
                                        return true
                                    else
                                        player.components.inventory:DropItem(v)
                                    end
                                end
                            end
                        end
                    end
                end
            )

            --玩家下线
            inst:ListenForEvent(
                "ms_playerdespawn",
                function(inst, player)
                    --掉落
                    if player and player.components.inventory then
                        if player.components.inventory:EquipHasTag("backpack") then
                            equip_items =
                                FindEquipItems(
                                player,
                                function(m_inst)
                                    return m_inst:HasTag("backpack")
                                end
                            )

                            if #equip_items >= 1 then
                                for k, v in pairs(equip_items) do
                                    --无使用权限则掉落
                                    if CheckItemPermission(player, v, true) then
                                        return true
                                    else
                                        player.components.inventory:DropItem(v)
                                    end
                                end
                            end
                        end
                    end
                end
            )
        end
    )

    --安置物品，为每个安置的新物品都添加Tag(种植物/墙) --引用 河蟹防熊锁(兼容版)
    AddComponentPostInit(
        "deployable",
        function(Deployable, inst) 

            local old_Deploy = Deployable.Deploy 

            function Deployable:Deploy(pt, deployer,...) 
                local ret = old_Deploy(self, pt, deployer,...) 
                if ret then 

                    if _G.TheWorld.ismastersim == false then
                        return ret
                    end

                    if not inst:HasTag("deployedplant") then 
                        local act_pos = pt 
                        local prefab = inst.prefab 

                        local x, y, z = GetSplitPosition(act_pos)
                        -- 安置物为墙
                        if string.find(prefab, "wall_") or string.find(inst.prefab, "fence_") then
                            x = math.floor(x) + .5
                            z = math.floor(z) + .5
                        end
                        -- 安置物为小木牌
                        if string.find(inst.prefab, "minisign") then                       
                            local ents = TheSim:FindEntities(x, y, z, 3, nil, {"INLIMBO"}, {"backpack", "sign"}, {"player"})
                            for _, findobj in pairs(ents) do
                                if findobj ~= nil and findobj.ownerlist == nil then
                                    testActPrint(nil, deployer, findobj, "deploy", "安置物设置权限") 
                                    SetItemPermission(findobj, deployer)
                                end
                            end
                        -- 其他的安置物(不包括作物)
                        else
                            local ents = TheSim:FindEntities(x, y, z, 1, nil, {"INLIMBO"}, nil, {"player"})
                            for _, findobj in pairs(ents) do
                                if findobj ~= nil and findobj.ownerlist == nil then
                                    testActPrint(nil, deployer, findobj, "deploy", "安置物设置权限")
                                    SetItemPermission(findobj, deployer)
                                end
                            end
                        end
                    end                   
                end

                return ret 
            end
        end
    ) 

    --安置东西前的判断 --引用 河蟹防熊锁(兼容版)
    local old_DEPLOY = _G.ACTIONS.DEPLOY.fn
    _G.ACTIONS.DEPLOY.fn = function(act)
        testActPrint(act)
        if _G.TheWorld.ismastersim == false then
            return old_DEPLOY(act)
        end

        if not is_allow_build_near and not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false) then
            if not CheckBuilderScopePermission(act.doer, act.target, "离别人建筑太近了，我做不到，需要权限！", item_ScopePermission) then
                return false
            end
        end
        
        return old_DEPLOY(act) 
    end 

    --放置物品(农场/圣诞树)
    local old_PLANT = _G.ACTIONS.PLANT.fn
    _G.ACTIONS.PLANT.fn = function(act)
        testActPrint(act)
        if act.doer.components.inventory ~= nil then
            local seed = act.doer.components.inventory:RemoveItem(act.invobject)
            if seed ~= nil then
                --种植农场,沃姆伍德更新之后参数有改变
                if act.target.components.grower ~= nil and act.target.components.grower:PlantItem(seed, act.doer) then
                    for obj, bValue in pairs(act.target.components.grower.crops) do
                        if bValue then
                            SetItemPermission(obj, nil, act.doer)
                        end
                    end
                    return true
                elseif
                    act.target:HasTag("winter_treestand") and act.target.components.burnable ~= nil and
                        not (act.target.components.burnable:IsBurning() or act.target.components.burnable:IsSmoldering())
                 then
                    --种植圣诞树
                    --act.target:PushEvent("plantwintertreeseed", { seed = seed })
                    local x, y, z = act.target.Transform:GetWorldPosition()
                    --act.target:Remove()
                    local tree = _G.SpawnPrefab(seed.components.winter_treeseed.winter_tree)
                    -- tree.ownerlist = act.target.ownerlist
                    if act.target.ownerlist ~= nil then
                        SetItemPermission(tree, act.target.ownerlist.master)
                    end
                    act.target:Remove()
                    tree.Transform:SetPosition(x, y, z)
                    tree.components.growable:StartGrowing()

                    act.doer:DoTaskInTime(
                        0,
                        function()
                            SetItemPermission(tree, act.doer)
                        end
                    )

                    return true
                else
                    act.doer.components.inventory:GiveItem(seed)
                end
            end
        end
        --print("打印对象PLANT")
        --_G.dumptable(act, 1, 10)
        --_G.ddump(act)
        -- if _G.TheWorld.ismastersim == false then return old_PLANT(act) end

        -- if  act.target and (act.target.ownerlist == nil or act.target:HasTag("userid_"..act.doer.userid) or (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin())) then
        --     return old_PLANT(act)
        -- else
        --     doer_num = ""
        --     for n,p in pairs(AllPlayers) do
        --         if act.doer.userid == p.userid then
        --             doer_num = n
        --         end
        --     end

        -- 	local found = false
        --     for owner_userid,_ in pairs(act.target.ownerlist) do
        --         for _,p in pairs(AllPlayers) do
        --             if owner_userid == p.userid then
        -- 			    found = true
        -- 			    act.doer:DoTaskInTime(0, function ()
        -- 						act.doer.components.talker:Say(GetSayMsg("permission_no", p.name, GetItemOldName(act.target)))
        --                 end)

        --                 p.components.talker:Say(GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
        --             end
        --         end
        --     end
        -- 	if not found then
        --         act.doer.components.talker:Say(get_msg(22))
        --     end
        --     return false
        -- end
    end

    --用晾肉架
    local old_DRY = _G.ACTIONS.DRY.fn
    _G.ACTIONS.DRY.fn = function(act)
        testActPrint(act)
        --_G.dumptable(act, 1, 10)
        if _G.TheWorld.ismastersim == false then
            return old_DRY(act)
        end
        --print(act.doer.name.."--dry--"..GetItemOldName(act.target))

        act.doer:DoTaskInTime(
            0,
            function()
                SetItemPermission(act.target, nil, act.doer)
            end
        )
        return old_DRY(act)
    end

    --------------------检测Tag来防熊---------------------
    --------------------------------------------------------
    --防采肉架上的肉干和蜂箱蜂蜜
    local old_HARVEST = _G.ACTIONS.HARVEST.fn
    _G.ACTIONS.HARVEST.fn = function(act)
        testActPrint(act)

        -- 有权限时直接处理
        if
            CheckItemPermission(act.doer, act.target, nil, true) or act.target.prefab == "cookpot" or
                act.target:HasTag("readyforharvest") or
                act.target:HasTag("rotten") or
                act.target:HasTag("withered")
         then --锅里的东西和已经长好/腐烂/枯萎的农作物
            return old_HARVEST(act)
        elseif
            act.target == nil or (act.target.ownerlist == nil and true or act.target.ownerlist.master == nil) or
                tablelength(act.target.ownerlist) == 0 or
                act.doer:HasTag("player") == false
         then
            -- 不存在权限则判断周围建筑物
            if CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("buildings_get_cant")) then
                return old_HARVEST(act)
            end
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("item_get_cant", master.name, GetItemOldName(act.target)))
                PlayerSay(master, GetSayMsg("item_get", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --防止玩家挖别人东西
    local old_DIG = _G.ACTIONS.DIG.fn
    _G.ACTIONS.DIG.fn = function(act)
        testActPrint(act)

        local leader = GetItemLeader(act.doer)

        -- 有权限时直接处理/患病的植物直接处理/种地上的种子直接处理
        if
            CheckItemPermission(leader, act.target) or
                (act.target and act.target.components.diseaseable and act.target.components.diseaseable:IsDiseased()) or
                (act.target and act.target:HasTag("notreadyforharvest"))
         then
            -- 普通树，判断周围建筑范围(12码)内是否有超过4颗属于同一主人的树
            return old_DIG(act)
        elseif
            act.target and
                (act.target.prefab == "evergreen" or act.target.prefab == "deciduoustree" or
                    act.target.prefab == "twiggytree" or
                    act.target.prefab == "pinecone_sapling" or
                    act.target.prefab == "acorn_sapling" or
                    act.target.prefab == "twiggy_nut_sapling" or
                    act.target.prefab == "rock_avocado_fruit_sprout_sapling")
         then
            if act.target.ownerlist ~= nil and act.target.ownerlist.master ~= nil then
                local x, y, z = act.target.Transform:GetWorldPosition()
                local ents = TheSim:FindEntities(x, y, z, item_ScopePermission, {"tree"})
                local tree_num = 1
                if leader and leader.userid then
                    for _, obj in pairs(ents) do
                        if
                            obj and obj ~= act.target and obj:HasTag("tree") and obj.ownerlist and
                                obj.ownerlist.master == act.target.ownerlist.master
                         then
                            tree_num = tree_num + 1
                        end
                    end
                end

                if tree_num >= 5 then
                    local doer_num = GetPlayerIndex(act.doer.userid)
                    local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(leader, GetSayMsg("trees_dig_cant", master.name))
                        PlayerSay(master, GetSayMsg("item_dig", act.doer.name, GetItemOldName(act.target), doer_num))
                    else
                        PlayerSay(leader, GetSayMsg("trees_dig_cant"))
                    end

                    return false
                end
            end

            return old_DIG(act)
        elseif
            act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or
                (cant_destroyby_monster and leader:HasTag("player") == false)
         then
            -- 不存在权限则判断周围建筑物
            --if CheckBuilderScopePermission(leader, act.target, GetSayMsg("buildings_dig_cant")) then return old_DIG(act) end
            return old_DIG(act)
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("item_dig_cant", master.name))
                PlayerSay(master, GetSayMsg("item_dig", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --能被允许所有人采摘的作物(自行编辑)
    local allow_pick = {"reeds","flower_cave","flower_cave_double","flower_cave_triple","cave_banana_tree","cactus","oasis_cactus","wormlight_plant","lichen",} 

    --有权限才能采摘的作物(自行编辑) 
    local permission_pick = {}

    --防止玩家采别人东西(草/树枝/浆果/花)
    local old_PICK = _G.ACTIONS.PICK.fn
    _G.ACTIONS.PICK.fn = function(act)
        testActPrint(act)

        --上面表中的作物直接允许
        if act.target and (table.contains(allow_pick, act.target.prefab) == true) then 
            return old_PICK(act)
        end

        if (act.target and string.find(act.target.prefab, "flower")) or (act.target and (table.contains(permission_pick, act.target.prefab) == true)) then 
            -- 有权限时直接处理
            if CheckItemPermission(act.doer, act.target) then
                return old_PICK(act)
            elseif
                act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or
                    act.doer:HasTag("player") == false
             then
                -- 不存在权限则判断周围建筑物
                --if CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("buildings_pick_cant")) then return old_PICK(act) end
                return old_PICK(act)
            elseif act.doer:HasTag("player") then
                -- 主人不为自己并且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("item_pick_cant", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_pick", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end

            return false
        end

        return old_PICK(act)
    end

    --防止玩家开采别人东西(大理石树)
    local old_MINE = _G.ACTIONS.MINE.fn
    _G.ACTIONS.MINE.fn = function(act)
        testActPrint(act)

        local leader = GetItemLeader(act.doer)

        -- 有权限时直接处理
        if CheckItemPermission(leader, act.target) then
            return old_MINE(act)
        elseif
            act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or
                (cant_destroyby_monster and leader:HasTag("player") == false)
         then
            -- 不存在权限则判断周围建筑物
            --if CheckBuilderScopePermission(leader, act.target, GetSayMsg("buildings_pick_cant")) then return old_MINE(act) end
            return old_MINE(act)
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("item_pick_cant", master.name, GetItemOldName(act.target)))
                PlayerSay(master, GetSayMsg("item_pick", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --防止玩家拿别人陷阱(狗牙/捕鸟器/蜜蜂地雷)
    local old_PICKUP = _G.ACTIONS.PICKUP.fn
    _G.ACTIONS.PICKUP.fn = function(act)
        testActPrint(act)

        --防偷(狗牙/捕鸟器/蜜蜂地雷) - 暂时只防狗牙被偷
        -- or act.target.prefab == "beemine" or act.target.prefab == "birdtrap"
        if act.target and (act.target.prefab == "trap_teeth") then
            -- 有权限时直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_PICKUP(act)
            elseif act.doer:HasTag("player") then
                -- 主人不为自己并且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("item_get_cant", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_get", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end

            return false
        end

        --return old_PICKUP(act)
        if
            pack_pickup and act.doer.components.inventory ~= nil and act.target ~= nil and
                act.target.components.inventoryitem ~= nil and
                (act.target.components.inventoryitem.canbepickedup or
                    (act.target.components.inventoryitem.canbepickedupalive and not act.doer:HasTag("player"))) and
                not (act.target:IsInLimbo() or
                    (act.target.components.burnable ~= nil and act.target.components.burnable:IsBurning()) or
                    (act.target.components.projectile ~= nil and act.target.components.projectile:IsThrown()))
         then
            act.doer:PushEvent("onpickupitem", {item = act.target})

            --special case for trying to carry two backpacks
            if
                not act.target.components.inventoryitem.cangoincontainer and act.target.components.equippable and
                    act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot)
             then
                -- 背包拾取增强
                if
                    pack_pickup and act.target.components.container ~= nil and
                        act.doer.components.inventory.activeitem == nil
                 then
                    act.target.components.inventoryitem.cangoincontainer = true
                    act.target.components.inventoryitem:OnPutInInventory(act.doer)
                    act.doer.components.inventory:SetActiveItem(act.target)
                    act.target.components.inventoryitem.cangoincontainer = false
                else
                    local item =
                        act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot)
                    if item.components.inventoryitem and item.components.inventoryitem.cangoincontainer then
                        --act.doer.components.inventory:SelectActiveItemFromEquipSlot(act.target.components.equippable.equipslot)
                        act.doer.components.inventory:GiveItem(
                            act.doer.components.inventory:Unequip(act.target.components.equippable.equipslot)
                        )
                    else
                        act.doer.components.inventory:DropItem(
                            act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot)
                        )
                    end
                    act.doer.components.inventory:Equip(act.target)
                end
                return true
            end

            if
                act.doer:HasTag("player") and act.target.components.equippable and
                    not act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot)
             then
                act.doer.components.inventory:Equip(act.target)
            else
                act.doer.components.inventory:GiveItem(act.target, nil, act.target:GetPosition())
            end
            return true
        else
            return old_PICKUP(act)
        end
    end

    --[[
    --防止玩家重置别人陷阱(狗牙)
    local old_RESETMINE = _G.ACTIONS.RESETMINE.fn
    _G.ACTIONS.RESETMINE.fn = function(act)
        testActPrint(act)

        --防重置(狗牙)
        -- or act.target.prefab == "beemine" or act.target.prefab == "birdtrap"
        if act.target and (act.target.prefab == "trap_teeth") then
            -- 有权限时直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_RESETMINE(act)
            elseif act.doer:HasTag("player") then
                -- 主人不为自己并且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end

            return false
        end

        return old_RESETMINE(act)
    end
    --]]

    --[[
    --防砍别人家的树(圣诞树等)
    local old_CHOP = _G.ACTIONS.CHOP.fn
    _G.ACTIONS.CHOP.fn = function(act)
        testActPrint(act)

        if act.target then
            -- 普通树，判断周围建筑范围(12码)内是否有超过4颗属于同一主人的树
            if
                act.target.prefab == "evergreen" or act.target.prefab == "deciduoustree" or
                    act.target.prefab == "twiggytree" or act.target.prefab == "moon_tree" or act.target.prefab == "livingtree_halloween"
             then
                --防砍(圣诞树等)
                local leader = GetItemLeader(act.doer)

                if CheckItemPermission(leader, act.target) then
                    return old_CHOP(act)
                elseif act.target.ownerlist and act.target.ownerlist.master ~= nil then
                    local x, y, z = act.target.Transform:GetWorldPosition()
                    local ents = TheSim:FindEntities(x, y, z, item_ScopePermission, {"tree"})
                    local tree_num = 1
                    if leader and leader.userid then
                        for _, obj in pairs(ents) do
                            if
                                obj and obj ~= act.target and obj:HasTag("tree") and obj.ownerlist and
                                    obj.ownerlist.master == act.target.ownerlist.master
                             then
                                tree_num = tree_num + 1
                            end
                        end
                    end

                    if tree_num >= 5 then
                        local doer_num = GetPlayerIndex(act.doer.userid)
                        local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                        if master ~= nil then
                            PlayerSay(leader, GetSayMsg("trees_chop_cant", master.name))
                            PlayerSay(master, GetSayMsg("item_chop", leader.name, GetItemOldName(act.target), doer_num))
                        else
                            PlayerSay(leader, GetSayMsg("trees_chop_cant"))
                        end

                        return false
                    end
                end
            elseif
                act.target.prefab == "winter_tree" or act.target.prefab == "winter_deciduoustree" or
                    act.target.prefab == "winter_twiggytree"
             then
                local leader = GetItemLeader(act.doer)

                -- 有权限时直接处理
                if CheckItemPermission(leader, act.target) then
                    return old_CHOP(act)
                elseif
                    act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or
                        (cant_destroyby_monster and leader:HasTag("player") == false)
                 then
                    -- 不存在权限则判断周围建筑物
                    --if CheckBuilderScopePermission(leader, act.target, get_msg(28)) then return old_CHOP(act) end
                    return old_CHOP(act)
                elseif act.doer:HasTag("player") then
                    -- 主人不为自己并且物品受权限控制
                    local doer_num = GetPlayerIndex(act.doer.userid)
                    local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(act.doer, GetSayMsg("item_chop_cant", master.name, GetItemOldName(act.target)))
                        PlayerSay(master, GetSayMsg("item_chop", act.doer.name, GetItemOldName(act.target), doer_num))
                    else
                        PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                    end
                end

                return false
            end
        end

        return old_CHOP(act)
    end
    --]]

    --打开建筑容器函数
    local old_RUMMAGE = _G.ACTIONS.RUMMAGE.fn
    _G.ACTIONS.RUMMAGE.fn = function(act)
        testActPrint(act)
        --防装饰(圣诞树等)
        if
            act.target and
                (act.target.prefab == "winter_tree" or act.target.prefab == "winter_deciduoustree" or
                    act.target.prefab == "winter_twiggytree")
         then
            -- 有权限时直接处理
            if CheckItemPermission(act.doer, act.target) then
                return old_RUMMAGE(act)
            elseif
                act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or
                    act.doer:HasTag("player") == false
             then
                -- 不存在权限则判断周围建筑物
                if CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("tree_open_cant")) then
                    return old_RUMMAGE(act)
                end
            elseif act.doer:HasTag("player") then
                -- 主人不为自己并且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("tree_open_cant", master.name))
                    PlayerSay(master, GetSayMsg("item_open", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end

            return false
        end

        return old_RUMMAGE(act)
    end

    --防止玩家砸别人物品
    local old_HAMMER = _G.ACTIONS.HAMMER.fn
    _G.ACTIONS.HAMMER.fn = function(act)
        testActPrint(act)
        --print(act.doer.name.."--HAMMER--"..act.target.prefab)
        if act.doer:HasTag("beaver") then
            return false
        end

        -- 远古祭坛只有管理员能拆
        if
            ancient_altar_no_destroy and act.target and act.target.prefab == "ancient_altar" and
                not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false)
         then
            PlayerSay(act.doer, GetSayMsg("noadmin_hammer_cant", GetItemOldName(act.target)))
            return false
        end

        --  未开启墙增强..直接可砸
        -- if table.contains(walls_state_config.walls_normal, act.target and act.target.prefab or "") then
        if walls_state_config.walls_normal[act.target and act.target.prefab or ""] then
            return old_HAMMER(act)
        end

        -- 防止玩家拆毁野外的猪人房/兔人房/鱼人房
        if
            house_plain_nodestroy and act.target and (act.target.ownerlist == nil or act.target.ownerlist.master == nil) and
                (act.target.prefab == "rabbithouse" or act.target.prefab == "pighouse" or act.target.prefab == "mermhouse") and
                not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false)
         then
            PlayerSay(act.doer, GetSayMsg("noadmin_hammer_cant", GetItemOldName(act.target)))
            return false
        end

        -- 有权限时直接处理
        if CheckItemPermission(act.doer, act.target, true) then
            if cant_destroyby_monster and act.target.cant_destroyedby_monster then
                act.target.components.workable = act.target.components.hammerworkable
            end

            local ret = old_HAMMER(act)

            if (cant_destroyby_monster and act.target.cant_destroyedby_monster) then
                act.target.components.workable = act.target.components.gd_workable
            end
            return ret
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            --if not cant_destroyby_monster then
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                PlayerSay(master, GetSayMsg("item_smash", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        --end
        end

        return false
    end

    --防止玩家作祟别人东西
    local old_HAUNT = _G.ACTIONS.HAUNT.fn
    _G.ACTIONS.HAUNT.fn = function(act)
        testActPrint(act)

        -- 有权限时直接处理
        if CheckItemPermission(act.doer, act.target, true) then
            return old_HAUNT(act)
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                PlayerSay(master, GetSayMsg("item_haunt", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --防止玩家魔法攻击别人的建筑
    local old_CASTSPELL = _G.ACTIONS.CASTSPELL.fn
    _G.ACTIONS.CASTSPELL.fn = function(act)
        testActPrint(act, act.target, act.invobject)
        --For use with magical staffs
        local staff = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local act_pos = act:GetActionPoint()
        if
            staff and staff.components.spellcaster and
                staff.components.spellcaster:CanCast(act.doer, act.target, act_pos)
         then
            if act.target then
                -- 不存在权限则判断周围6码内建筑物
                -- if CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("buildings_spell_cant"), 6, act_pos) then
                -- 	staff.components.spellcaster:CastSpell(act.target, act_pos)
                -- 	return true
                -- end
                -- 有权限时直接处理
                if CheckItemPermission(act.doer, act.target, true) then
                    staff.components.spellcaster:CastSpell(act.target, act_pos)
                    return true
                elseif act.doer:HasTag("player") then
                    -- 主人不为自己并且物品受权限控制
                    local doer_num = GetPlayerIndex(act.doer.userid)
                    local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                        PlayerSay(master, GetSayMsg("item_spell", act.doer.name, GetItemOldName(act.target), doer_num))
                    else
                        PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                    end
                end
            else
                staff.components.spellcaster:CastSpell(act.target, act_pos)
                return true
            end
        end
        return false
    end

    --别人建筑附近不能建造建筑
    local old_BUILD = _G.ACTIONS.BUILD.fn
    _G.ACTIONS.BUILD.fn = function(act)
        testActPrint(act, act.doer, act.recipe)
        if _G.TheWorld.ismastersim == false then
            return old_BUILD(act)
        end

        if admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false then --管理员直接可造
            return old_BUILD(act)
        end

        if not table.contains(config_item.cant_destroy_buildings, act.recipe) then --非建筑的话直接可造
            --print(act.doer.name.."--BUILD--"..act.recipe)
            return old_BUILD(act)
        end

        if not is_allow_build_near then
            if not CheckBuilderScopePermission(act.doer, act.target, "离别人建筑太近了，不能建造，需要权限！", item_ScopePermission) then
                return false
            end
        end
        return old_BUILD(act)
    end

    --防挖别人的地皮
    local old_TERRAFORM = _G.ACTIONS.TERRAFORM.fn
    _G.ACTIONS.TERRAFORM.fn = function(act)
        testActPrint(act)
        if _G.TheWorld.ismastersim == false then
            return old_TERRAFORM(act)
        end
        if admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false then
            return old_TERRAFORM(act)
        end

        if act.target and CheckItemPermission(act.doer, act.target) or act.doer:HasTag("player") == false then
            -- 不存在权限则判断周围建筑物
            return old_TERRAFORM(act)
        elseif CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("buildings_dig_cant")) then
            return old_TERRAFORM(act)
        end

        return false
    end

    --右键开锁控制
    local old_TURNON = _G.ACTIONS.TURNON.fn
    _G.ACTIONS.TURNON.fn = function(act)
        testActPrint(act)
        if _G.TheWorld.ismastersim == false then
            return old_TURNON(act)
        end

        if act.target then
            if act.target.prefab == "firesuppressor" then
                -- 有权限时直接处理
                if CheckItemPermission(act.doer, act.target, true) then
                    return old_TURNON(act)
                elseif act.doer:HasTag("player") then
                    -- 主人不为自己并且物品受权限控制
                    local doer_num = GetPlayerIndex(act.doer.userid)
                    local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                        PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                    else
                        PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                    end
                end

                return false
            elseif
                act.target.prefab == "treasurechest" or act.target.prefab == "icebox" or
                    act.target.prefab == "dragonflychest" or
                    act.target.prefab == "cellar" or
                    act.target.prefab == "chesterchest" or
                    act.target.prefab == "venus_icebox" or
                    act.target.prefab == "researchlab2" or
                    act.target.prefab == "storeroom"
             then
                if act.target.ownerlist ~= nil and act.target.ownerlist.master == act.doer.userid then
                    PlayerSay(act.doer, "已开锁！任何人都能打开")
                    return old_TURNON(act)
                else
                    PlayerSay(act.doer, "可惜，我不能给它上锁和开锁！")
                    return false
                end
            end
        end

        return old_TURNON(act)
    end

    --右键上锁控制
    local old_TURNOFF = _G.ACTIONS.TURNOFF.fn
    _G.ACTIONS.TURNOFF.fn = function(act)
        testActPrint(act)
        if _G.TheWorld.ismastersim == false then
            return old_TURNOFF(act)
        end

        if act.target then
            if act.target.prefab == "firesuppressor" then
                -- 有权限时直接处理
                if CheckItemPermission(act.doer, act.target, true) then
                    return old_TURNOFF(act)
                elseif act.doer:HasTag("player") then
                    -- 主人不为自己并且物品受权限控制
                    local doer_num = GetPlayerIndex(act.doer.userid)
                    local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                        PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                    else
                        PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                    end
                end

                return false
            elseif
                act.target and
                    (act.target.prefab == "treasurechest" or act.target.prefab == "icebox" or
                        act.target.prefab == "dragonflychest" or
                        act.target.prefab == "cellar" or
                        act.target.prefab == "chesterchest" or
                        act.target.prefab == "venus_icebox" or
                        act.target.prefab == "researchlab2" or
                        act.target.prefab == "storeroom")
             then
                if act.target.saved_ownerlist ~= nil and act.target.saved_ownerlist.master == act.doer.userid then
                    PlayerSay(act.doer, "已上锁！只有自己能打开")
                    return old_TURNOFF(act)
                else
                    PlayerSay(act.doer, "可惜，我不能给它上锁和开锁！")
                    return false
                end
            end
        end

        return old_TURNOFF(act)
    end

    --开关门
    local old_ACTIVATE = _G.ACTIONS.ACTIVATE.fn
    _G.ACTIONS.ACTIVATE.fn = function(act)
        testActPrint(act)

        -- 有权限时直接处理
        if
            CheckItemPermission(act.doer, act.target, true) or
                CheckWallActionPermission(act.target and act.target.prefab, 3)
         then
            return old_ACTIVATE(act)
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --危险的书
    local old_READ = _G.ACTIONS.READ.fn
    _G.ACTIONS.READ.fn = function(act)
        testActPrint(act, act.doer, act.target or act.invobject)

        local targ = act.target or act.invobject
        if targ ~= nil and (targ.prefab == "book_brimstone" or targ.prefab == "book_tentacles") then
            if
                not is_allow_build_near and
                    not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false)
             then
                if not CheckBuilderScopePermission(act.doer, targ, "我不能在别人建筑附近这么做，需要权限！", item_ScopePermission) then
                    return false
                end
            end
        end
        return old_READ(act)
    end

    --危险的道具
    local old_FAN = _G.ACTIONS.FAN.fn
    _G.ACTIONS.FAN.fn = function(act)
        testActPrint(act, act.doer, act.invobject)

        -- 幸运风扇
        if act.invobject and act.invobject.prefab == "perdfan" then
            if
                not is_allow_build_near and
                    not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false)
             then
                if not CheckBuilderScopePermission(act.doer, act.target, "我不能在别人建筑附近这么做，需要权限！", item_ScopePermission) then
                    return false
                end
            end
        end
        return old_FAN(act)
    end

    --瞬移权限
    local old_BLINK = _G.ACTIONS.BLINK.fn
    _G.ACTIONS.BLINK.fn = function(act)
        testActPrint(act, act.doer, act.invobject)
        local act_pos = act:GetActionPoint()
        --		懒惰的探索者
        if act.invobject and act.invobject.prefab == "orangestaff" then
            --		沃拓克斯灵魂跳跃
            if
                not is_allow_build_near and
                    not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false)
             then
                if not CheckBuilderScopePermission(act.doer, act.target, "我不能在别人建筑附近这么做，需要权限！", item_ScopePermission) then
                    return false
                end
            end
        elseif
            act.doer ~= nil and act.doer.sg ~= nil and act.doer.sg.currentstate.name == "portal_jumpin_pre" and
                act_pos ~= nil and
                act.doer.components.inventory ~= nil and
                act.doer.components.inventory:Has("wortox_soul", 1)
         then
            if
                not is_allow_build_near and
                    not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false)
             then
                if not CheckBuilderScopePermission(act.doer, act.target, "我不能在别人建筑附近这么做，需要权限！", item_ScopePermission) then
                    return false
                end
            end
        end
        return old_BLINK(act)
    end

    --防捕别人家的虫
    local old_NET = _G.ACTIONS.NET.fn
    _G.ACTIONS.NET.fn = function(act)
        testActPrint(act)

        -- 萤火虫
        if act.invobject.prefab == "fireflies" then
            if
                not is_allow_build_near and
                    not (admin_option and act.doer.Network and act.doer.Network:IsServerAdmin() and test_mode == false)
             then
                if
                    not CheckBuilderScopePermission(
                        act.doer,
                        act.target,
                        GetSayMsg("buildings_net_cant", act.doer.name, GetItemOldName(act.target)),
                        item_ScopePermission
                    )
                 then
                    return false
                end
            end
        end

        return old_NET(act)
    end

    --检测点燃动作是否有效
    local old_LIGHT = _G.ACTIONS.LIGHT.fn
    _G.ACTIONS.LIGHT.fn = function(act)
        testActPrint(act)

        -- 有权限时直接处理
        if CheckItemPermission(act.doer, act.target, true) then
            return old_LIGHT(act)
        elseif
            act.target == nil or act.target.ownerlist == nil or tablelength(act.target.ownerlist) == 0 or
                (cant_destroyby_monster and act.doer:HasTag("player") == false)
         then
            -- 不存在权限则判断周围建筑物
            if CheckBuilderScopePermission(act.doer, act.target, GetSayMsg("buildings_light_cant")) then
                return old_LIGHT(act)
            end
        elseif act.doer:HasTag("player") then
            -- 主人不为自己并且物品受权限控制
            local doer_num = GetPlayerIndex(act.doer.userid)
            local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
            if master ~= nil then
                PlayerSay(act.doer, GetSayMsg("item_light_cant", master.name))
                PlayerSay(master, GetSayMsg("item_light", act.doer.name, GetItemOldName(act.target), doer_num))
            else
                PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
            end
        end

        return false
    end

    --防止玩家打开别人的容器
    AddComponentPostInit(
        "container",
        function(Container, target)
            local old_OpenFn = Container.Open
            function Container:Open(doer)
                testActPrint(nil, doer, target, "Open", "打开容器")

                -- 有权限时直接处理
                if CheckItemPermission(doer, target, true) or target.prefab == "cookpot" then
                    return old_OpenFn(self, doer)
                elseif doer:HasTag("player") then
                    -- 主人不为自己并且物品受权限控制
                    local doer_num = GetPlayerIndex(doer.userid)
                    local master = target.ownerlist and GetPlayerById(target.ownerlist.master) or nil
                    if master ~= nil then
                        PlayerSay(doer, GetSayMsg("permission_no", master.name, GetItemOldName(target)))
                        PlayerSay(master, GetSayMsg("item_open", doer.name, GetItemOldName(target), doer_num))
                    else
                        PlayerSay(doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(target.ownerlist)))
                    end
                end
            end
        end
    )

    -- 查看物品
    local old_LOOKAT = _G.ACTIONS.LOOKAT.fn
    _G.ACTIONS.LOOKAT.fn = function(act)
        testActPrint(act)

        if act.target and act.target.prefab == "beefalo" and act.target.ownerlist ~= nil then
            -- PlayerSay(act.doer, "这头牛的当前状态: \n" .. GetBeefaloInfoString(act.target, act.target.components.rideable:IsBeingRidden()))
            local colour = {0.6, 0.9, 0.8, 1}
            -- colour[1],colour[2],colour[3] = _G.HexToPercentColor("#E80607")
            PlayerColorSay(
                act.doer,
                "这头牛的当前状态: \n" .. GetBeefaloInfoString(act.target, act.target.components.rideable:IsBeingRidden()),
                colour
            )
            return true
        end

        return old_LOOKAT(act)
    end

    --防止玩家降别人的锚
    local old_LOWER_ANCHOR = _G.ACTIONS.LOWER_ANCHOR.fn
    _G.ACTIONS.LOWER_ANCHOR.fn = function(act)
        testActPrint(act)
        if act.target.components.anchor ~= nil then
            --有权限直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_LOWER_ANCHOR(act)
            elseif act.doer:HasTag("player") then
                --主人不为自己且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end
        end
    end

    --防止玩家升别人的锚
    local old_RAISE_ANCHOR = _G.ACTIONS.RAISE_ANCHOR.fn
    _G.ACTIONS.RAISE_ANCHOR.fn = function(act)
        testActPrint(act)
        if act.target.components.anchor ~= nil then
            --有权限直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_RAISE_ANCHOR(act)
            elseif act.doer:HasTag("player") then
                --主人不为自己且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end
        end
    end

    --防止玩家升别人的船帆
    local old_RAISE_SAIL = _G.ACTIONS.RAISE_SAIL.fn
    _G.ACTIONS.RAISE_SAIL.fn = function(act)
        testActPrint(act)
        if act.target.components.mast ~= nil then
            --有权限直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_RAISE_SAIL(act)
            elseif act.doer:HasTag("player") then
                --主人不为自己且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end
        end
    end

    --防止玩家降别人的船帆
    local old_LOWER_SAIL = _G.ACTIONS.LOWER_SAIL.fn
    _G.ACTIONS.LOWER_SAIL.fn = function(act)
        testActPrint(act)
        if act.target.components.mast ~= nil then
            --有权限直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_LOWER_SAIL(act)
            elseif act.doer:HasTag("player") then
                --主人不为自己且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end
        end
    end

    --防止玩家使用别人的舵
    local old_STEER_BOAT = _G.ACTIONS.STEER_BOAT.fn
    _G.ACTIONS.STEER_BOAT.fn = function(act)
        testActPrint(act)
        if act.target.components.steeringwheel ~= nil then
            --有权限直接处理
            if CheckItemPermission(act.doer, act.target, true) then
                return old_STEER_BOAT(act)
            elseif act.doer:HasTag("player") then
                --主人不为自己且物品受权限控制
                local doer_num = GetPlayerIndex(act.doer.userid)
                local master = act.target.ownerlist and GetPlayerById(act.target.ownerlist.master) or nil
                if master ~= nil then
                    PlayerSay(act.doer, GetSayMsg("permission_no", master.name, GetItemOldName(act.target)))
                    PlayerSay(master, GetSayMsg("item_use", act.doer.name, GetItemOldName(act.target), doer_num))
                else
                    PlayerSay(act.doer, GetSayMsg("player_leaved", GetPlayerNameByOwnerlist(act.target.ownerlist)))
                end
            end
        end
    end

	--船防火
    AddPrefabPostInit("burnable_locator_medium",function(inst)
        inst:RemoveComponent("burnable")
    end)

    --船放下锚无敌
    AddPrefabPostInit("boat",function(inst_1)
        inst_1:ListenForEvent("on_collide", function(inst_2,data) 
            local x,y,z = inst_1.Transform:GetWorldPosition() 
            local ents = TheSim:FindEntities(x, y, z, 4.5, nil, {"INLIMBO"}, {"anchor_lowered"}, {"player"}) 

            if(#ents > 0) then                                        
                local health_damage = 20 * math.abs(data.hit_dot_velocity) 
                inst_1.components.health:DoDelta(health_damage)                        
            end
        end)
    end) 
end