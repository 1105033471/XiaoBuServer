local loot_table = {        -- 包裹开出的物品列表，key为prefab名字，value为物品对应的权重
    --===================== 怪物 ========================
    hound = 2,--猎狗
    -- firehound = 2,--火狗
    icehound = 3,--冰狗
    merm = 2,--鱼人
    spider = 2, -- 蜘蛛
    leif = 1,--树精
    bunnyman = 2, -- 兔人
    bat = 2,    -- 蝙蝠
    
    -- 高级怪
    spat = 0.3,--钢羊
    worm = 0.6,        -- 蠕虫
    krampus = 0.3,   -- 坎普斯
    deerclops = 0.05,     -- 巨鹿
    
    --===================== 资源 ========================
    -- winter_food9 = 2,--神圣蛋奶酒
    -- winter_food8 = 2,--热可可
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
    silk = 1.5,          --蛛网
    nightmarefuel = 2,        -- 噩梦燃料
    rocks = 2,         -- 岩石
    marble = 2,      -- 大理石
    moonrocknugget = 2,    -- 月石

    -- feather_robin = 2,        -- 红色羽毛
    -- feather_robin_winter = 2,    -- 蓝色羽毛
    -- feather_crow = 2,        -- 黑色羽毛
    -- feather_canary = 1,        -- 金色羽毛
    
    -- 宝石
    redgem = 2,       --红宝石
    goldnugget = 2,    --金子
    yellowgem = 1,    --黄宝石
    orangegem = 1,    --橙宝石
    greengem = .5,     --緑寳石
    purplegem = 1.5,    --紫宝石
    bluegem = 2,      --蓝宝石
    opalpreciousgem = 0.2, --彩虹宝石
    
    --===================== 食物 ========================
    -- blue_cap = 2,         -- 蓝蘑菇
    -- red_cap = 2,         -- 红蘑菇
    -- greem_cap = 2,        -- 绿蘑菇
    -- ice = 2,--冰
    -- seeds = 2, --种子
    -- lightbulb = 2,  --荧光果
    -- petals = 2,  --花瓣
    -- petals_evil = 2,  --噩梦花
    -- butterflywings = 2,     -- 蝴蝶翅膀
    -- honey = 2,         -- 蜂蜜
    -- smallmeat = 2, -- 小肉
    -- berries = 2, -- 浆果
    -- berries_juicy = 2,    -- 多汁浆果
    -- carrot = 2,  -- 胡萝卜
    corn = 1,      -- 玉米
    dragonfruit = .5,  -- 火龙果
    
    --===================== 稀有物品 =====================
    gears = .5,        --齿轮
    shroom_skin = .5,    -- 蘑菇皮
    fossil_piece = .5,    -- 化石碎片

    trinket_15 = .1,    -- 白主教棋子
    -- trinket_16 = .1,    -- 黑主教棋子
    trinket_28 = .1,    -- 白战车棋子
    -- trinket_29 = .1,    -- 黑战车棋子
    trinket_30 = .1,    -- 白骑士棋子
    -- trinket_31 = .1,    -- 黑骑士棋子

    lightninggoathorn = .5, -- 电羊角
    deerclops_eyeball = 0.1,    -- 眼球
    royal_jelly = 0.5,  -- 蜂王浆
    goose_feather = .7,  -- 鹅毛
    butter = .5,        -- 黄油
    krampus_sack =0.05, --坎普斯背包
    
    --===========特殊物品(非官方物品，慎用！)===============
    chasethewind_blueprint = .3,    -- 逐风之刃蓝图
    ancient_altar_blueprint = .3,    -- 远古伪科学站蓝图
    oldfish_axe_blueprint = .3,        -- 汲取蓝图
    flyinghunter_blueprint = .3,    -- 斩翼者蓝图
    
    chasethewind = 0.003,            -- 逐风之刃
    oldfish_axe = 0.003,            -- 神器·汲取
    skinstaff = 0.003,                -- 皮肤法杖
    tz_icesword = 0.003,            -- 神器·剑魂
    phoenixspear_fire = 0.003,        -- 火焰凤凰剑
    phoenixspear_ice = 0.003,        -- 冰霜凤凰剑
    flyinghunter = 0.003,            -- 神器·斩翼者
    armorobsidian = 0.003,            -- 黑曜石甲
    
    obsidian = .6,                    -- 黑曜石
    -- expbean = 0.5,                    -- 经验豆
    
    --================= 其他活动物品 =======================
    winter_ornament_light1 = .3,    -- 四种彩灯
    winter_ornament_light2 = .3,
    winter_ornament_light3 = .3,
    winter_ornament_light4 = .3,
}

-- 开启collect them all模组时，将封锁的物品制造配方修改为绿洲掉落
if KnownModIndex:IsModEnabled(KnownModIndex:GetModActualName("Collect them all")) then
    local blueprint_tbl =
    {
        dug_grass_blueprint = .3,
        dug_sapling_blueprint = .3,
        dug_coffeebush_blueprint = .3,
        flowerbox_blueprint = .3,
        skull_chest_blueprint = .3,
        skinstaff_blueprint = .3,
        redgem_blueprint = .3,
        bluegem_blueprint = .3,
        tz_icesword_blueprint = .3,
        phoenixspear_fire_blueprint = .3,
        phoenixspear_ice_blueprint = .3,
        obsidianfirepit_blueprint = .3,

        reskin_tool_blueprint = .3,
    }

    for k,v in pairs(blueprint_tbl) do
        loot_table[k] = v
    end
end

local function UpdateLootBlueprint(loottable, doer)
    local builder = doer ~= nil and doer.components.builder or nil
    loottable["goggleshat_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("goggleshat")) and 1 or 0.01
    loottable["deserthat_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("deserthat") and builder:KnowsRecipe("goggleshat")) and 1 or 0.01
    loottable["succulent_potted_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("succulent_potted")) and 1 or 0.01
    loottable["antliontrinket"] = (builder ~= nil and not builder:KnowsRecipe("deserthat")) and .8 or 0.01
    loottable["winter_treestand_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("winter_treestand")) and .3 or 0
    loottable["giftwrap_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("giftwrap")) and .3 or 0
    
    -- 神器蓝图拥有后降低开出的概率
    loottable["chasethewind_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("chasethewind")) and .3 or 0.01
    loottable["ancient_altar_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("ancient_altar")) and .3 or 0.01
    loottable["oldfish_axe_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("oldfish_axe")) and .3 or 0.01
    loottable["flyinghunter_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("flyinghunter")) and .3 or 0.01
    
    if KnownModIndex:IsModEnabled(KnownModIndex:GetModActualName("Collect them all")) then
        loottable["dug_grass_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("dug_grass")) and .3 or 0.01
        loottable["dug_sapling_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("dug_sapling")) and .3 or 0.01
        loottable["dug_coffeebush_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("dug_coffeebush")) and .3 or 0.01
        loottable["flowerbox_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("flowerbox")) and .3 or 0.01
        loottable["skull_chest_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("skull_chest")) and .3 or 0.01
        loottable["skinstaff_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("skinstaff")) and .3 or 0.01
        loottable["redgem_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("redgem")) and .3 or 0.01
        loottable["bluegem_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("bluegem")) and .3 or 0.01
        loottable["tz_icesword_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("tz_icesword")) and .3 or 0.01
        loottable["phoenixspear_fire_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("phoenixspear_fire")) and .3 or 0.01
        loottable["phoenixspear_ice_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("phoenixspear_ice")) and .3 or 0.01
        loottable["obsidianfirepit_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("obsidianfirepit")) and .3 or 0.01
        loottable["reskin_tool_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("reskin_tool")) and .3 or 0.01
    end
end

local function lootfn(inst, doer)
    inst.setupdata.UpdateLootBlueprint(inst.setupdata.loottable, doer)

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

    return item
end

local function master_postinit(inst, setupdata)
    inst.build = "wetpouch"
    inst.setupdata = setupdata
    inst.wet_prefix = STRINGS.WET_PREFIX.POUCH
    inst.components.inventoryitem:InheritMoisture(100, true)
end

local wetpouch =
{
    loottable = loot_table,

    UpdateLootBlueprint = UpdateLootBlueprint,
    
    lootfn = lootfn,

    master_postinit = master_postinit,
}

local assets =
{
    Asset("ANIM", "anim/wetpouch.zip"),
}

local prefabs =
{
    "wetpouch_unwrap",
}

local function OnUnwrapped(inst, pos, doer)
    local loot = wetpouch.lootfn(inst, doer)
    if loot ~= nil then
        local item = SpawnPrefab(loot)
        if item ~= nil then
            -- 如果开到神器，则全服公告
            if doer:HasTag("player") and item:HasTag("godweapon") then
                TheNet:Announce("【"..doer:GetDisplayName().."】在开启袋子时开到了【"..item:GetDisplayName().."】！")
            end
            
            -- 如果为怪物，设置默认攻击对象
            if doer:HasTag("player") and item.components.combat then
                item.components.combat:SuggestTarget(doer)
            end
            
            if item.Physics ~= nil then
                item.Physics:Teleport(pos:Get())
            else
                item.Transform:SetPosition(pos:Get())
            end

            if item.components.inventoryitem ~= nil then
                local moisture = inst.components.inventoryitem:GetMoisture()
                local iswet = inst.components.inventoryitem:IsWet()
                item.components.inventoryitem:InheritMoisture(moisture, iswet)
            end
        end
    end

    SpawnPrefab("wetpouch_unwrap").Transform:SetPosition(pos:Get())

    if doer ~= nil and doer.SoundEmitter ~= nil then
        doer.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
    end
    inst.components.stackable:Get():Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("wetpouch")
    inst.AnimState:SetBuild("wetpouch")
    inst.AnimState:PlayAnimation("idle_onesize")

    inst:AddTag("bundle")

    --unwrappable (from unwrappable component) added to pristine state for optimization
    inst:AddTag("unwrappable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("unwrappable")
    inst.components.unwrappable:SetOnUnwrappedFn(OnUnwrapped)

    MakeHauntableLaunchAndIgnite(inst)

    wetpouch.master_postinit(inst, wetpouch)

    return inst
end

return Prefab("wetpouch", fn, assets, prefabs)
