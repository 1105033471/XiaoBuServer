if TheNet:GetIsServer() or TheNet:IsDedicated() then
    -- 需要清理的物品
    -- @max        地图上存在的最大数量
    -- @stack      标识为true时表示仅清理无堆叠的物品
    -- @reclean    标识为数字,表示超过第n次清理时物品还存在则强制清理(第一次找到物品并未清理的计数为1)
    local function GetLevelPrefabs()
        local levelPrefabs = {
            ------------------------  生物  ------------------------
            hound           = { max = 10 },    -- 狗
            firehound       = { max = 5 },    -- 火狗
            spider_warrior  = { max = 5 },    -- 蜘蛛战士
            spider          = { max = 10 },    -- 蜘蛛
            flies           = { max = 10 },    -- 苍蝇
            mosquito        = { max = 10 },    -- 蚊子
            bee             = { max = 10 },    -- 蜜蜂
            killerbee       = { max = 10 },    -- 杀人蜂
            frog            = { max = 10 },    -- 青蛙
            beefalo         = { max = 90 },   -- 牛
            grassgekko      = { max = 15 },   -- 草蜥蜴
            lightninggoat   = { max = 25 },    -- 羊
            deer            = { max = 10 },   -- 鹿
            bunnyman        = { max = 5 },    -- 兔人
            slurtle         = { max = 5 },     -- 鼻涕虫
            snurtle         = { max = 5 },     -- 蜗牛

            ------------------------  地面物体  ------------------------
            evergreen_sparse    = { max = 200, reclean = 2 },                        -- 常青树
            twiggytree          = { max = 100, reclean = 2 },                        -- 树枝树
            marsh_tree          = { max = 30, reclean = 2 },                         -- 针刺树
            rock_petrified_tree = { max = 200, reclean = 2 },                        -- 石化树
            -- skeleton_player     = { max = 10, reclean = 2 },                         -- 玩家尸体
            spiderden           = { max = 30, reclean = 2 },                         -- 蜘蛛巢
            burntground         = { max = 20, reclean = 2 },                         -- 陨石痕跡

            ------------------------  可拾取物品  ------------------------
            seeds           = { max = 10, stack = false, reclean = 3 },         -- 种子
            log             = { max = 40, stack = false, reclean = 3 },         -- 木头
            pinecone        = { max = 10, stack = false, reclean = 3 },         -- 松果
            cutgrass        = { max = 30, stack = false, reclean = 3 },         -- 草
            cutreeds        = { max = 20, stack = false, reclean = 2 },         -- 芦苇
            twigs           = { max = 30, stack = false, reclean = 3 },         -- 树枝
            rocks           = { max = 30, stack = false, reclean = 3 },         -- 石头
            nitre           = { max = 30, stack = false, reclean = 3 },         -- 硝石
            flint           = { max = 30, stack = false, reclean = 3 },         -- 燧石
            poop            = { max = 20 , stack = false, reclean = 3 },        -- 屎
            guano           = { max = 5 , stack = false, reclean = 3 },         -- 鸟屎
            charcoal        = { max = 40 , stack = false, reclean = 3 },        -- 木炭
            manrabbit_tail  = { max = 20 , stack = false, reclean = 3 },        -- 兔毛
            silk            = { max = 40 , stack = false, reclean = 3 },        -- 蜘蛛丝
            spidergland     = { max = 40 , stack = false, reclean = 3 },        -- 蜘蛛腺体
            stinger         = { max = 5 , stack = false, reclean = 3 },         -- 蜂刺
            houndstooth     = { max = 30 , stack = false, reclean = 3 },        -- 狗牙
            mosquitosack    = { max = 20 , stack = false, reclean = 3 },        -- 蚊子血袋
            glommerfuel     = { max = 20 , stack = false, reclean = 3 },        -- 格罗姆粘液
            slurtleslime    = { max = 6 , stack = false, reclean = 3 },         -- 鼻涕虫粘液
            slurtle_shellpieces = { max = 20, stack = false, reclean = 3 },     -- 鼻涕虫壳碎片
            lucky_goldnugget = { max = 20, stack = false, reclean = 3 },        -- 金元宝
            goose_feather = { max = 10, stack = false, reclean = 2 },                        -- 鹅毛
            feather_robin = { max = 5, stack = false, reclean = 2 },                         -- 红羽毛
            feather_canary = { max = 5, reclean = 2 },                                       -- 金羽毛
            spoiled_fish_small = { max = 3, reclean = 2 },                                   -- 腐烂的小鱼
            oar = { max = 3, reclean = 2 },                                                  -- 浆
            lureplantbulb = { max = 3, reclean = 2 },                                        -- 食人花
            redgem = { max = 10, reclean = 2 },                                              -- 红宝石
            bulegem = { max = 10, reclean = 2 },                                             -- 蓝宝石
            amulet = { max = 5, reclean = 2 },                                               -- 生命护符
            giftwrap = { max = 3, reclean = 2 },                                             -- 礼物包裹
            armorwood = { max = 3, reclean = 2 },                                            -- 木甲
            phlegm = { max = 3, stack = false, reclean = 2 },                                -- 钢羊痰
            rope = { max = 3, reclean = 2 },                                                 -- 绳子
            shroom_skin = { max = 3, reclean = 2 },                                          -- 蘑菇皮
            tentaclespots = { max = 3, reclean = 2 },                                        -- 触手皮
            sewing_kit = { max = 3, reclean = 2 },                                           -- 缝纫包
            nightmarefuel = { max = 3, reclean = 2 },                                        -- 噩梦燃料
            livinglog = { max = 3, reclean = 2 },                                            -- 活木
            waxpaper = { max = 3, reclean = 2 },                                             -- 蜡纸
            coontail = { max = 3, reclean = 2 },                                             -- 猫尾巴
            

            --------------------------  食物   ------------------------------(最后都变成腐烂食物)
            -- cave_banana = { max = 3 },      -- 洞穴香蕉

            spoiled_food    = { max = 10, reclean = 2 },                                  -- 腐烂食物
            winter_food1    = { max = 2, reclean = 2 },        -- 维多利亚面包
            winter_food2    = { max = 2, reclean = 2 },        -- 维多利亚面包
            winter_food3    = { max = 2, reclean = 2 },        -- 维多利亚面包
            winter_food4    = { max = 2, reclean = 2 },        -- 维多利亚面包
            winter_food5    = { max = 2, reclean = 2 },        -- 维多利亚面包
            winter_food6    = { max = 2, reclean = 2 },        -- 维多利亚面包
            winter_food7    = { max = 2, reclean = 2 },        -- 维多利亚面包
            winter_food8    = { max = 2, reclean = 2 },        -- 维多利亚面包

            winter_ornament_plain1 = { max = 2, stack = true, reclean = 2 }, -- 节日小饰品
            winter_ornament_plain2 = { max = 2, stack = true, reclean = 2 },
            winter_ornament_plain4 = { max = 2, stack = true, reclean = 2 },
            winter_ornament_plain5 = { max = 2, stack = true, reclean = 2 },
            winter_ornament_plain6 = { max = 2, stack = true, reclean = 2 },
            winter_ornament_plain7 = { max = 2, stack = true, reclean = 2 },
            winter_ornament_plain8 = { max = 2, stack = true, reclean = 2 },

            trinket_3   = { max = 2, stack = true, reclean = 2 },            -- 戈尔迪乌姆之结
            trinket_4   = { max = 2, stack = true, reclean = 2 },
            trinket_6   = { max = 2, stack = true, reclean = 2 },
            trinket_8   = { max = 2, stack = true, reclean = 2 },

            blueprint   = { max = 3, reclean = 2 },    -- 蓝图
            axe         = { max = 3, reclean = 2 },    -- 斧子
            torch       = { max = 3, reclean = 2 },    -- 火炬
            pickaxe     = { max = 3, reclean = 2 },    -- 镐子
            hammer      = { max = 3, reclean = 2 },    -- 锤子
            shovel      = { max = 3, reclean = 2 },    -- 铲子
            tentaclespike = { max = 3, reclean = 2 },      -- 触手棒
            razor       = { max = 3, reclean = 2 },    -- 剃刀
            pitchfork   = { max = 3, reclean = 2 },    -- 草叉
            bugnet      = { max = 3, reclean = 2 },    -- 捕虫网
            fishingrod  = { max = 3, reclean = 2 },    -- 鱼竿
            spear       = { max = 3, reclean = 2 },    -- 矛
            earmuffshat = { max = 3, reclean = 2 },    -- 兔耳罩
            winterhat   = { max = 3, reclean = 2 },    -- 冬帽
            spiderhat    = { max = 10, reclean = 2 },   -- 蜘蛛帽
            heatrock    = { max = 3, reclean = 2 },    -- 热能石
            trap        = { max = 10 },   -- 动物陷阱
            birdtrap    = { max = 5, reclean = 2 },   -- 鸟陷阱
            compass     = { max = 3, reclean = 2 },    -- 指南針
            wathgrithrhat = { max = 3, reclean = 2 },    -- 女武神帽子
            icestaff = { max = 3, reclean = 2 },         -- 冰杖


            chesspiece_deerclops_sketch     = { max = 2, reclean = 2 },    -- 四季 boss 棋子图
            chesspiece_bearger_sketch       = { max = 2, reclean = 2 },
            chesspiece_moosegoose_sketch    = { max = 2, reclean = 2 },
            chesspiece_dragonfly_sketch     = { max = 2, reclean = 2 },

            winter_ornament_boss_bearger    = { max = 2, stack = true, reclean = 2 },    -- 四季 boss 和蛤蟆、蜂后的挂饰
            winter_ornament_boss_beequeen   = { max = 2, stack = true, reclean = 2 },
            winter_ornament_boss_deerclops  = { max = 2, stack = true, reclean = 2 },
            winter_ornament_boss_dragonfly  = { max = 2, stack = true, reclean = 2 },
            winter_ornament_boss_moose      = { max = 2, stack = true, reclean = 2 },
            winter_ornament_boss_toadstool  = { max = 2, stack = true, reclean = 2 },

            -- armor_sanity   = { max = 3, reclean = 2  },    -- 影甲
            -- shadowheart    = { max = 3, reclean = 2 },    -- 影心
        }

        return levelPrefabs
    end

    local function RemoveItem(inst)
        if inst.components.health ~= nil and not inst:HasTag("wall") then
            if inst.components.lootdropper ~= nil then
                inst.components.lootdropper.DropLoot = function(pt) end
            end
            inst.components.health:SetPercent(0)
        else
            inst:Remove()
        end
    end

    local function Clean(inst)
        TheNet:Announce("正在自动清理垃圾")
        print("开始清理...")
        local this_max_prefabs = GetLevelPrefabs()
        local countList = {}

        for _,v in pairs(Ents) do
            if v.prefab ~= nil then
                repeat
                    local thisPrefab = v.prefab
                    if this_max_prefabs[thisPrefab] ~= nil then
                        if v.reclean == nil then
                            v.reclean = 1
                        else
                            v.reclean = v.reclean + 1
                        end

                        local bNotClean = true
                        if this_max_prefabs[thisPrefab].reclean ~= nil then
                            bNotClean = this_max_prefabs[thisPrefab].reclean > v.reclean
                        end

                        if this_max_prefabs[thisPrefab].stack and 
                           bNotClean and 
                           v.components and 
                           v.components.stackable and 
                           v.components.stackable:StackSize() > 1 then 
                                break 
                        end
                    else 
                        break
                    end

                    -- 不可见物品(在包裹内等)
                    if v.inlimbo then break end

                    if countList[thisPrefab] == nil then
                        countList[thisPrefab] = { name = v.name, count = 1, currentcount = 1 }
                    else
                        countList[thisPrefab].count = countList[thisPrefab].count + 1
                        countList[thisPrefab].currentcount = countList[thisPrefab].currentcount + 1
                    end

                    if this_max_prefabs[thisPrefab].max >= countList[thisPrefab].count then break end

                    if (v.components.hunger ~= nil and v.components.hunger.current > 0) or (v.components.domesticatable ~= nil and v.components.domesticatable.domestication > 0) then
                        break
                    end

                    RemoveItem(v)
                    countList[thisPrefab].currentcount = countList[thisPrefab].currentcount - 1
                until true
            end
        end

        for k,v in pairs(this_max_prefabs) do
            if countList[k] ~= nil and countList[k].count > v.max then
                print(string.format("清理了   %s(%s)   %d   %d   %d", countList[k].name, k, countList[k].count, countList[k].count - countList[k].currentcount, countList[k].currentcount))
            end
        end
    end

    local function CleanDelay(inst)
        TheNet:Announce("服务器将于 30 秒后清理！")
        inst:DoTaskInTime(30, Clean)
    end

    AddPrefabPostInit("world", function(inst)
        inst:DoPeriodicTask(5 * TUNING.TOTAL_DAY_TIME, CleanDelay)    -- 周期性清理物品
    end)
end