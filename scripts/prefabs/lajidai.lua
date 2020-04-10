require "prefabs/winter_ornaments"

local function OnStartBundling(inst)--, doer)
    inst.components.stackable:Get():Remove()
end

local function MakeWrap(name, containerprefab, tag, cheapfuel)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
    }

    local prefabs =
    {
        name,
        containerprefab,
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation("idle")

		MakeInventoryFloatable(inst)
	
        if tag ~= nil then
            inst:AddTag(tag)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        inst:AddComponent("bundlemaker")
        inst.components.bundlemaker:SetBundlingPrefabs(containerprefab, name)
        inst.components.bundlemaker:SetOnStartBundlingFn(OnStartBundling)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = cheapfuel and TUNING.TINY_FUEL or TUNING.MED_FUEL

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)
        inst.components.propagator.flashpoint = 10 + math.random() * 5
        MakeHauntableLaunchAndIgnite(inst)

        return inst
    end

    return Prefab(name.."wrap", fn, assets, prefabs)
end

local function MakeContainer(name, build)
    local assets =
    {
        Asset("ANIM", "anim/"..build..".zip"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddNetwork()

        inst:AddTag("bundle")

        --V2C: blank string for controller action prompt
        inst.name = " "

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("container")
        inst.components.container:WidgetSetup(name)

        inst.persists = false

        return inst
    end

    return Prefab(name, fn, assets)
end

local function onburnt(inst)
    inst.burnt = true
    inst.components.unwrappable:Unwrap()
end

local function onignite(inst)
    inst.components.unwrappable.canbeunwrapped = false
end

local function onextinguish(inst)
    inst.components.unwrappable.canbeunwrapped = true
end

local function MakeBundle(name, onesize, variations, loot, tossloot, setupdata)
    local assets =
    {
        Asset("ANIM", "anim/"..name..".zip"),
    }

    if variations ~= nil then
        for i = 1, variations do
            if onesize then
                table.insert(assets, Asset("INV_IMAGE", name..tostring(i)))
            else
                table.insert(assets, Asset("INV_IMAGE", name.."_small"..tostring(i)))
                table.insert(assets, Asset("INV_IMAGE", name.."_medium"..tostring(i)))
                table.insert(assets, Asset("INV_IMAGE", name.."_large"..tostring(i)))
            end
        end
    elseif not onesize then
        table.insert(assets, Asset("INV_IMAGE", name.."_small"))
        table.insert(assets, Asset("INV_IMAGE", name.."_medium"))
        table.insert(assets, Asset("INV_IMAGE", name.."_large"))
    end

    local prefabs =
    {
        "ash",
        name.."_unwrap",
    }

    if loot ~= nil then
        for i, v in ipairs(loot) do
            table.insert(prefabs, v)
        end
    end

    local function OnWrapped(inst, num, doer)
        local suffix =
            (onesize and "_onesize") or
            (num > 3 and "_large") or
            (num > 1 and "_medium") or
            "_small"

        if variations ~= nil then
            if inst.variation == nil then
                inst.variation = math.random(variations)
            end
            suffix = suffix..tostring(inst.variation)
            inst.components.inventoryitem:ChangeImageName(name..(onesize and tostring(inst.variation) or suffix))
        elseif not onesize then
            inst.components.inventoryitem:ChangeImageName(name..suffix)
        end

        inst.AnimState:PlayAnimation("idle"..suffix)

        if doer ~= nil and doer.SoundEmitter ~= nil then
            doer.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
        end
    end

    local function OnUnwrapped(inst, pos, doer)
        if inst.burnt then
            SpawnPrefab("ash").Transform:SetPosition(pos:Get())
        else
            local loottable = (setupdata ~= nil and setupdata.lootfn ~= nil) and setupdata.lootfn(inst, doer) or loot
            if loottable ~= nil then
                local moisture = inst.components.inventoryitem:GetMoisture()
                local iswet = inst.components.inventoryitem:IsWet()
                for i, v in ipairs(loottable) do
                    local item = SpawnPrefab(v)
                    if item ~= nil then
						-- 此处添加：如果开到神器，则全服公告
						if item:HasTag("godweapon") and doer:HasTag("player") then
							TheNet:Announce(doer:GetDisplayName().."在开垃圾袋时开到神器【"..item:GetDisplayName().."】！")
						end
						-- 如果为怪物，设置默认攻击对象
						if doer:HasTag("player") and item:HasTag("monster") or (item.components and item.components.combat) then
							item.components.combat:SuggestTarget(doer)
						end
                        if item.Physics ~= nil then
                            item.Physics:Teleport(pos:Get())
                        else
                            item.Transform:SetPosition(pos:Get())
                        end
                        if item.components.inventoryitem ~= nil then
                            item.components.inventoryitem:InheritMoisture(moisture, iswet)
                            if tossloot then
                                item.components.inventoryitem:OnDropped(true, .5)
                            end
                        end
                    end
                end
            end
            SpawnPrefab(name.."_unwrap").Transform:SetPosition(pos:Get())
        end
        if doer ~= nil and doer.SoundEmitter ~= nil then
            doer.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
        end
        inst.components.stackable:Get():Remove()
    end

    local OnSave = variations ~= nil and function(inst, data)
        data.variation = inst.variation
    end or nil

    local OnPreLoad = variations ~= nil and function(inst, data)
        if data ~= nil then
            inst.variation = data.variation
        end
    end or nil

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(name)
        inst.AnimState:SetBuild(name)
        inst.AnimState:PlayAnimation(
            variations ~= nil and
            (onesize and "idle_onesize1" or "idle_large1") or
            (onesize and "idle_onesize" or "idle_large")
        )

        inst:AddTag("bundle")

        --unwrappable (from unwrappable component) added to pristine state for optimization
        inst:AddTag("unwrappable")

        if setupdata ~= nil and setupdata.common_postinit ~= nil then
            setupdata.common_postinit(inst, setupdata)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end
		inst:AddComponent("stackable")
        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")

        if variations ~= nil or not onesize then
            inst.components.inventoryitem:ChangeImageName(
                name..
                (variations == nil and "_large" or (onesize and "1" or "_large1"))
            )
        end

        inst:AddComponent("unwrappable")
        inst.components.unwrappable:SetOnWrappedFn(OnWrapped)
        inst.components.unwrappable:SetOnUnwrappedFn(OnUnwrapped)

        MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
        MakeSmallPropagator(inst)
        inst.components.propagator.flashpoint = 10 + math.random() * 5
        inst.components.burnable:SetOnBurntFn(onburnt)
        inst.components.burnable:SetOnIgniteFn(onignite)
        inst.components.burnable:SetOnExtinguishFn(onextinguish)

        MakeHauntableLaunchAndIgnite(inst)

        if setupdata ~= nil and setupdata.master_postinit ~= nil then
            setupdata.master_postinit(inst, setupdata)
        end

        inst.OnSave = OnSave
        inst.OnPreLoad = OnPreLoad

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local wetpouch =
{
    loottable =
    {
        --怪物  
        hound = 2,--猎狗
	    -- firehound = 2,--火狗
	    icehound = 3,--冰狗
	    merm = 2,--鱼人
		spider = 2, -- 蜘蛛
	    leif = 1,--树精
		bunnyman = 2, -- 兔人
		bat = 2,	-- 蝙蝠
		
		-- 高级怪
	    spat = 0.3,--钢羊
		worm = 0.6,		-- 蠕虫
		krampus = 0.3,   -- 坎普斯
		deerclops = 0.05, 	-- 巨鹿
		
		--资源
		winter_food9 = 2,--神圣蛋奶酒
        winter_food8 = 2,--热可可
        -- winter_food7 = 2,--苹果酒
        -- winter_food6 = 2,--干果布丁
        -- winter_food5 = 2,--巧克力木头蛋糕
        -- winter_food3 = 2,--糖果手杖
        -- winter_food2 = 2,--糖果曲奇
        -- winter_food1 = 2,--姜饼人
		cutreeds = 2,  --芦苇
		lucky_goldnugget = 2,--元宝
        poop = 3,          --便便
	    twigs = 3,         --树枝
	    silk = 3,          --蛛网
		nightmarefuel = 2,		-- 噩梦燃料
		rocks = 2, 		-- 岩石
		marble = 2,  	-- 大理石
		moonrocknugget = 2,	-- 月石
		
		-- 食物
		-- blue_cap = 2, 		-- 蓝蘑菇
		-- red_cap = 2, 		-- 红蘑菇
		-- greem_cap = 2,		-- 绿蘑菇
	--	ice = 2,--冰
		-- seeds = 2, --种子
    --    lightbulb = 2,  --荧光果
        -- petals = 2,  --花瓣
        -- petals_evil = 2,  --噩梦花
	--	butterflywings = 2, 	-- 蝴蝶翅膀
		-- honey = 2, 		-- 蜂蜜
		smallmeat = 2, -- 小肉
		-- berries = 2, -- 浆果
		-- berries_juicy = 2,	-- 多汁浆果
		-- carrot = 2,  -- 胡萝卜
		corn = 1, 	 -- 玉米
		dragonfruit = .5,  -- 火龙果
		
		-- 羽毛
		feather_robin = 2,		-- 红色羽毛
	--	feather_robin_winter = 2,	-- 蓝色羽毛
	--	feather_crow = 2,		-- 黑色羽毛
		feather_canary = 1,		-- 金色羽毛
		
		-- 宝石
	    redgem = 2,       --红宝石
	    goldnugget = 2,    --金子
		yellowgem = 1,    --黄宝石
		orangegem = 1,    --橙宝石
		greengem = .5,     --緑寳石
		purplegem = 1.5,    --紫宝石
		bluegem = 2,      --蓝宝石
		opalpreciousgem = 0.1, --彩虹宝石
		
		
		-- 稀有物品
		gears = .5,		--齿轮
		shroom_skin = .5,	-- 蘑菇皮
		fossil_piece = .5,	-- 化石碎片
		
		lightninggoathorn = .5, -- 电羊角
		deerclops_eyeball = 0.1,	-- 眼球
		royal_jelly = 0.5,  -- 蜂王浆
		butter = .5,		-- 黄油
	    krampus_sack =0.05, --坎普斯背包
		
		---- 特殊物品(非官方物品，慎用！)
		chasethewind_blueprint = .3,	-- 逐风之刃蓝图
		ancient_altar_blueprint = .3,	-- 远古伪科学站蓝图
		oldfish_axe_blueprint = .3,		-- 汲取蓝图
		flyinghunter_blueprint = .3,	-- 斩翼者蓝图
		
		chasethewind = 0.002,			-- 逐风之刃
		oldfish_axe = 0.002,			-- 神器·汲取
		skinstaff = 0.002,				-- 皮肤法杖
		tz_icesword = 0.002,			-- 神器·剑魂
		phoenixspear_fire = 0.002,		-- 火焰凤凰剑
		phoenixspear_ice = 0.002,		-- 冰霜凤凰剑
		flyinghunter = 0.002,			-- 神器·斩翼者
		armorobsidian = 0.002,			-- 黑曜石甲
		
		obsidian = .6,					-- 黑曜石
		-- expbean = 0.5,	-- 经验豆
		
		--====================
		-- 其他活动物品
		
		winter_ornament_light1 = .4,	-- 四种彩灯
		winter_ornament_light2 = .4,
		winter_ornament_light3 = .4,
		winter_ornament_light4 = .4,
		
		winter_ornament_fancy1 = .2,	-- 圣诞装饰
		winter_ornament_fancy2 = .2,
		winter_ornament_fancy3 = .2,
		winter_ornament_fancy4 = .2,
		
		winter_ornament_plain1 = .2,
		winter_ornament_plain2 = .2,
		winter_ornament_plain3 = .2,
		winter_ornament_plain4 = .2,
		winter_ornament_plain5 = .2,
		winter_ornament_plain6 = .2,
		winter_ornament_plain7 = .2,
		winter_ornament_plain8 = .2,
		
		winter_treestand_blueprint = 1.5,	-- 圣诞树盆栽蓝图
    },

    UpdateLootBlueprint = function(loottable, doer)
        local builder = doer ~= nil and doer.components.builder or nil
        loottable["goggleshat_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("goggleshat")) and 1 or 0.01
        loottable["deserthat_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("deserthat") and builder:KnowsRecipe("goggleshat")) and 1 or 0.01
        loottable["succulent_potted_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("succulent_potted")) and 1 or 0.01
        loottable["antliontrinket"] = (builder ~= nil and not builder:KnowsRecipe("deserthat")) and .8 or 0.01
		loottable["winter_treestand_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("winter_treestand")) and .3 or 0
		
		-- 神器蓝图拥有后降低开出的概率
		loottable["chasethewind_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("chasethewind")) and .3 or 0.01
		loottable["ancient_altar_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("ancient_altar")) and .3 or 0.01
		loottable["oldfish_axe_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("oldfish_axe")) and .3 or 0.01
		loottable["flyinghunter_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("flyinghunter")) and .3 or 0.01
    end,
    
    lootfn = function(inst, doer)
        inst.setupdata.UpdateLootBlueprint(inst.setupdata.loottable, doer)

        local total = 0
        for _,v in pairs(inst.setupdata.loottable) do
            total = total + v
        end
        --print ("TOTOAL:", total)
        --for k,v in pairs(inst.setupdata.loottable) do print(" - ", tostring(v/total), k) end

        local item = weighted_random_choice(inst.setupdata.loottable)

        if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and
            string.sub(item, 1, 7) == "trinket" and
            item ~= "trinket_26" then
            --chance to replace trinkets (but not potatocup)
            local rnd = math.random(6)
            if rnd == 1 then
                item = GetRandomBasicWinterOrnament()
            elseif rnd == 2 then
                item = GetRandomFancyWinterOrnament()
            elseif rnd == 3 then
                item = GetRandomLightWinterOrnament()
            end
        end

        return { item }
    end,

    master_postinit = function(inst, setupdata)
        inst.build = "wetpouch"
        inst.setupdata = setupdata
        inst.wet_prefix = STRINGS.WET_PREFIX.POUCH
        inst.components.inventoryitem:InheritMoisture(100, true)
    end,
}

return MakeBundle("wetpouch", true, nil, JoinArrays(table.invert(wetpouch.loottable), GetAllWinterOrnamentPrefabs()), false, wetpouch)
