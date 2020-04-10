local _G = GLOBAL
local TheNet = _G.TheNet
local SpawnPrefab = _G.SpawnPrefab
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

if IsServer then
    -------------------------- 为树苗变的树和安置的作物加上权限 --------------------------------------------
 
    --世界收到推送事件后给树加权限,被监听对象在gd_global.lua中 2020.2.3
    AddPrefabPostInit(
        "world", 
        function(world) 
            --树的权限
            world:ListenForEvent("tree_permission", 
            function(inst, data) 
                world:DoTaskInTime(0.1 , 
                function() --延迟一会等树生成
                    --TheNet:Announce("接收到一个推送事件") 
                    local x,y,z = data.x, data.y, data.z 
                    local ents = TheSim:FindEntities(x, y, z, 1, nil, {"INLIMBO"}, nil, {"player"}) 
                    for _, findobj in pairs(ents) do
                        if findobj ~= nil and findobj.ownerlist == nil and findobj.components.inventoryitem == nil then 
                            --print(findobj.prefab)
                            SetItemPermission(findobj, data.master) 
                        end
                    end
                end
                )               
            end
            )
            
            --作物的权限
            world:ListenForEvent("itemplanted", 
            function(inst, data)  
                local x,y,z = data.pos.x, data.pos.y, data.pos.z 
                local deployer = data.doer 

                local ents = TheSim:FindEntities(x, y, z, 1, nil, {"INLIMBO"}, nil, {"player"})
                for _, findobj in pairs(ents) do
                    if findobj ~= nil and findobj.ownerlist == nil then
                        testActPrint(nil, deployer, findobj, "deploy", "安置物设置权限")
                        SetItemPermission(findobj, deployer)
                    end
                end
            end
            )
		end
    )

    -------------------------- 为光源添加所有者,防止作祟 --------------------------------------------
    local lightTable = {
        "yellowstaff", -- 晨星
        "opalstaff" -- 极光
    }

    local function LightSetSpellFn(inst)
        local function createlight(staff, target, pos)
            testActPrint(nil, staff.components.inventoryitem.owner, staff, "createlight", "召唤光源")

            local light = SpawnPrefab(staff.prefab == "opalstaff" and "staffcoldlight" or "stafflight")
            SetItemPermission(light, staff.components.inventoryitem.owner)
            light.Transform:SetPosition(pos:Get())
            staff.components.finiteuses:Use(1)

            local caster = staff.components.inventoryitem.owner
            if caster ~= nil and caster.components.sanity ~= nil then
                caster.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
            end
        end

        inst.components.spellcaster:SetSpellFn(createlight)
    end

    for k, name in pairs(lightTable) do
        AddPrefabPostInit(name, LightSetSpellFn)
    end

    ---------------------------------  重写玩家建造方法  ---------------------------------
    -- 重写玩家建造方法
    AddPlayerPostInit(
        function(player)
            if player.components.builder ~= nil then
                -- 建造新的物品，为每个建造的新物品都添加权限
                local old_onBuild = player.components.builder.onBuild
                player.components.builder.onBuild = function(doer, prod)
                    testActPrint(nil, doer, prod, "OnBuild", "建造")

                    if old_onBuild ~= nil then
                        old_onBuild(doer, prod)
                    end

                    -- 仓库物品除了背包以外都不需要加Tag
                    if prod and (not prod.components.inventoryitem or prod.components.container) then
                        SetItemPermission(prod, doer)
                    end
                end
            end
        end
    )

    --------------------------右键开解锁--------------------------------------------
    local rightLockTable = {
        "treasurechest",
        "icebox",
        "cellar",
        "dragonflychest",
		"storeroom",-- 地窖
		"venus_icebox",--萝卜冰箱
		"chesterchest",--切斯特箱子
		"researchlab2",--二本科技
    }

    local function addRightLock(inst)
        local function turnon(inst)
            inst.on = true
            --print("箱子开锁--------------")
            --让物品对所有人可用
            inst.saved_ownerlist = inst.ownerlist
            inst.ownerlist = nil
            inst.components.machine.ison = true
        end

        local function turnoff(inst)
            inst.on = false
            --print("箱子上锁--------------")
            --让物品只有自己能打开
            if inst.saved_ownerlist ~= nil then
                inst.ownerlist = inst.saved_ownerlist
                inst.saved_ownerlist = nil
            end
            -- --移除该物品所有的tag（包括自己的）
            -- if inst.saveTaglist ~= nil then
            -- 	for owner_userid,_ in pairs(inst.saveTaglist) do
            -- 		--print("removeTag----------userid_"..owner_userid)
            -- 		inst:RemoveTag("userid_"..owner_userid)
            -- 	end
            -- 	inst.saveTaglist = nil
            -- end
            -- --只添加自己的tag
            -- if inst.ownerlist ~= nil then
            -- 	for owner_userid,_ in pairs(inst.ownerlist) do
            -- 		inst:AddTag("userid_"..owner_userid)
            -- 		inst.saveTaglist = {}
            -- 		inst.saveTaglist[owner_userid] = 1
            -- 	end
            -- end
            inst.components.machine.ison = false
        end

        if inst.prefab then
            inst:AddComponent("machine")
            inst.components.machine.cooldowntime = 1
            inst.components.machine.turnonfn = turnon
            inst.components.machine.turnofffn = turnoff
        end
    end

    for k, name in pairs(rightLockTable) do
        AddPrefabPostInit(name, addRightLock)
    end

    -----权限保存与加载----
    for k, v in pairs(_G.AllRecipes) do
        local recipename = v.name
        SavePermission(recipename)
    end

    for key, value in pairs(config_item.save_state_table) do
        SavePermission(value)
    end

    for key, value in pairs(config_item.deploys_cant_table) do
        SavePermission(key)
    end

    for key, value in pairs(config_item.winter_trees_table) do
        SavePermission(key)
    end
end
