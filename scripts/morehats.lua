local HAT_TUNING = {
    DOUBLECHANCE = 0.3,         -- 双倍采集概率
    JELLYBUGCHANCE = 0.2,       -- 采集获得豆虫概率
}

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.HARVEST, function(inst,action)
    if inst:HasTag("quagmire_fasthands") then
        return "domediumaction" 
    elseif inst:HasTag("fastharvester") then
        return "doshortaction" 
    else
        return "dolongaction"
    end
end))

AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.HARVEST, function(inst,action)
    if inst:HasTag("quagmire_fasthands") then
        return "domediumaction" 
    elseif inst:HasTag("fastharvester")  then
        return "doshortaction" 
    else
        return "dolongaction"
    end
end))

-- 收获蜂箱时，picker有beenice标签则蜜蜂不攻击
AddPrefabPostInit("beebox", function(inst)
	local updatelevel = GetUpvalueHelper(require("prefabs/beebox").fn, "updatelevel")
	
	local function onharvest(inst, picker)
		if not inst:HasTag("burnt") then
			updatelevel(inst)
            if inst.components.childspawner and not GLOBAL.TheWorld.state.iswinter then
                if picker and picker:HasTag("beenice") then
                    inst.components.childspawner:ReleaseAllChildren(nil)
                else
                    inst.components.childspawner:ReleaseAllChildren(picker)
                end
			end
		end
	end
	
	if inst.components.harvestable then
        inst.components.harvestable:SetUp("honey", 6, nil, onharvest, updatelevel)
    end
end)

-- 春天蜜蜂不主动攻击带有beenice标签的玩家
local function SpringBeeRetarget(inst)
    return GLOBAL.TheWorld.state.isspring and
        GLOBAL.FindEntity(inst, 4,
            function(guy)
                return not guy:HasTag("beenice") and inst.components.combat:CanTarget(guy)
            end,
            { "_combat", "_health" },
            { "insect", "INLIMBO" },
            { "character", "animal", "monster" })
        or nil
end

AddPrefabPostInit("bee", function(inst)
    if inst.components.combat then
        inst.components.combat:SetRetargetFunction(2, SpringBeeRetarget)
    end
end)

local function MushroomhatBaseFn(inst)
    inst.components.hatstatus.base_waterproof = 20    -- 防水
    inst.components.hatstatus.base_heart = 60        -- 隔热
    inst.components.hatstatus.base_hungry = 25        -- 减缓饥饿
    inst.components.hatstatus.base_perishtime_fresh = TUNING.PERISH_FAST
end

local function FlowerhatBaseFn(inst)
    inst.components.hatstatus.base_sanity = 1.2        -- 回san
    inst.components.hatstatus.base_perishtime_fresh = TUNING.PERISH_FAST
end

local function WatermelonhatBaseFn(inst)
    inst.components.hatstatus.base_waterproof = 20
    inst.components.hatstatus.base_sanity = -1.8
    inst.components.hatstatus.base_heart = 120
    inst.components.hatstatus.base_perishtime_fresh = TUNING.PERISH_FAST
end

local function RainhatBaseFn(inst)
    inst.components.hatstatus.base_waterproof = 70
    inst.components.hatstatus.base_perishtime = TUNING.RAINHAT_PERISHTIME
end

local function EarmuffshatBaseFn(inst)
    inst.components.hatstatus.base_warm = 60        -- 保暖
    inst.components.hatstatus.base_perishtime = TUNING.EARMUFF_PERISHTIME
    inst.components.hatstatus.iswarm = 1
end

local function WinterhatBaseFn(inst)
    inst.components.hatstatus.base_sanity = 1.2
    inst.components.hatstatus.base_warm = 120
    inst.components.hatstatus.base_perishtime = TUNING.WINTERHAT_PERISHTIME
    inst.components.hatstatus.iswarm = 1
end

local function TophatBaseFn(inst)
    inst.components.hatstatus.base_sanity = 3
    inst.components.hatstatus.base_waterproof = 20
    inst.components.hatstatus.base_perishtime = TUNING.TOPHAT_PERISHTIME
    inst.components.hatstatus.iswarm = 1
end

local function StrawhatBaseFn(inst)
    inst.components.hatstatus.base_waterproof = 20
    inst.components.hatstatus.base_heart = 60
    inst.components.hatstatus.base_perishtime = TUNING.STRAWHAT_PERISHTIME
end

local function CatcoonhatBaseFn(inst)
    inst.components.hatstatus.base_warm = 60        -- 保暖
    inst.components.hatstatus.base_sanity = 3
    inst.components.hatstatus.base_perishtime = TUNING.CATCOONHAT_PERISHTIME
    inst.components.hatstatus.iswarm = 1
end

local function BeefalohatBaseFn(inst)
    inst.components.hatstatus.base_warm = 240        -- 保暖
    inst.components.hatstatus.base_waterproof = 20
    inst.components.hatstatus.closebeefalo = 1
    inst.components.hatstatus.base_perishtime = TUNING.BEEFALOHAT_PERISHTIME
    inst.components.hatstatus.iswarm = 1
end

local function WalrushatBaseFn(inst)
    inst.components.hatstatus.base_sanity = 6
    inst.components.hatstatus.base_warm = 120
    inst.components.hatstatus.base_perishtime = TUNING.WALRUSHAT_PERISHTIME
    inst.components.hatstatus.iswarm = 1
end

local function EyebrellahatBaseFn(inst)
    inst.components.hatstatus.base_waterproof = 100
    inst.components.hatstatus.base_heart = 240
    inst.components.hatstatus.base_perishtime = TUNING.EYEBRELLA_PERISHTIME
end

local function FeatherhatBaseFn(inst)
    inst.components.hatstatus.base_sanity = 3
    inst.components.hatstatus.base_perishtime = TUNING.FEATHERHAT_PERISHTIME
    inst.components.hatstatus.iswarm = 1
end

local function BushhatBaseFn(inst)
-- 浆果丛帽没有任何初始能力...
end

-- 能够升级的帽子列表
local hatList = {
    -- 有新鲜度的帽子
    red_mushroomhat = { BaseFn = MushroomhatBaseFn },               -- 红蘑菇帽
    green_mushroomhat = { BaseFn = MushroomhatBaseFn },             -- 绿蘑菇帽
    blue_mushroomhat = { BaseFn = MushroomhatBaseFn },              -- 蓝蘑菇帽
    flowerhat = { BaseFn = FlowerhatBaseFn },                       -- 花环
    watermelonhat = { BaseFn = WatermelonhatBaseFn },               -- 时尚西瓜帽
    
    -- 无新鲜度的帽子
    rainhat = { BaseFn = RainhatBaseFn },                           -- 雨帽
    earmuffshat = { BaseFn = EarmuffshatBaseFn },                   -- 兔毛耳罩(保暖)
    winterhat = { BaseFn = WinterhatBaseFn },                       -- 寒冬帽(保暖)
    tophat = { BaseFn = TophatBaseFn },                             -- 高礼帽(保暖)
    strawhat = { BaseFn = StrawhatBaseFn },                         -- 草帽
    catcoonhat = { BaseFn = CatcoonhatBaseFn },                     -- 猫帽(保暖)
    beefalohat = { BaseFn = BeefalohatBaseFn },                     -- 牛帽(保暖)
    walrushat = { BaseFn = WalrushatBaseFn },                       -- 海象帽(保暖)
    eyebrellahat = { BaseFn = EyebrellahatBaseFn },                 -- 眼球伞
    featherhat = { BaseFn = FeatherhatBaseFn },                     -- 羽毛帽
    bushhat = { BaseFn = BushhatBaseFn },                           -- 浆果丛帽
}

local function SpiderhatTestFn(inst)    -- 西瓜帽没有去除副作用时接受蜘蛛帽
    local propetyall = inst.components.hatstatus.propetyall
    return (inst.prefab == "watermelonhat" and inst.components.hatstatus.spiderhat_count < 3 and not propetyall)
end

local function HoundstoothTestFn(inst)    -- 有耐久的帽子，在耐久未去除时接受狗牙
    local propetyall = inst.components.hatstatus.propetyall
    return (inst.components.fueled and inst.components.hatstatus.houndstooth_count < 160 and not propetyall)
end

local function SkeletonhatTestFn(inst)    -- 有新鲜度的帽子,在新鲜度未去除时接受白骨头盔
    local propetyall = inst.components.hatstatus.propetyall
    return (inst.components.perishable and inst.components.hatstatus.skeletonhat_count < 1 and not propetyall)
end

local function DeserthatTestFn(inst)    -- 接受的沙漠护目镜小于10个的时候，接受沙漠护目镜
    local propetyall = inst.components.hatstatus.propetyall
    return (inst.components.hatstatus.deserthat_count < 10 and not propetyall)
end

local function GoosefeatherTestFn(inst)    -- 未获得满防水效果时，接受鹅毛、眼球伞
    local propetyall = inst.components.hatstatus.propetyall
    return (inst.components.hatstatus.waterproof == 0 and not propetyall)
end

local function SpiderglandTestFn(inst)    -- 未获得50%减缓饥饿速度时，接受蜘蛛腺体
    local propetyall = inst.components.hatstatus.propetyall
    return (inst.components.hatstatus.spidergland /5 + inst.components.hatstatus.base_hungry < 50 and not propetyall)
end

local function BeefalohatTestFn(inst)    -- 未获得亲牛光环时，接受牛帽
    local propetyall = inst.components.hatstatus.propetyall
    return (inst.components.hatstatus.closebeefalo == 0 and not propetyall)
end

local function WinterhatTestFn(inst)    -- 未获得满保暖效果时，接受寒冬帽
    local propetyall = inst.components.hatstatus.propetyall
    return (inst.components.hatstatus.warm == 0 and inst.components.hatstatus.iswarm == 1 and not propetyall)
end

local function WalrushatTestFn(inst)    -- 未获得满保暖效果或未获得满回SAN效果时，接受海象帽
    local propetyall = inst.components.hatstatus.propetyall
    return (((inst.components.hatstatus.warm == 0 and inst.components.hatstatus.iswarm == 1) or inst.components.hatstatus.sanity == 0) and not propetyall)
end

local function HivehatTestFn(inst)        -- 未获得满隔热效果时，接受蜂王帽, 冰块
    local propetyall = inst.components.hatstatus.propetyall
    return (inst.components.hatstatus.heart == 0 and inst.components.hatstatus.iswarm == 0 and not propetyall)
end

local function CutgrassTestFn(inst)        -- 给小树枝或者草查看全属性
    return false
end

local function OpalpreciousgemTestFn(inst)  -- 彩虹宝石获得特殊能力
    return (inst.components.hatstatus.opal_count < 2)
end

local function RepairItem(inst)
    -- 每次给材料都修复满耐久
    inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
    if inst.components.fueled then
        inst.components.fueled.currentfuel = inst.components.fueled.maxfuel
    end
    if inst.components.perishable then
        inst.components.perishable:SetPercent(1)
    end
end

local function SpiderhatAcceptFn(inst, giver)
    inst.components.hatstatus.spiderhat_count = inst.components.hatstatus.spiderhat_count + 1
    local SayString = "蜘蛛帽数量: "..inst.components.hatstatus.spiderhat_count.."/3(满级后移除湿润效果)\n"
    SayString = SayString.."湿润速度 - 0.2/s\n湿润上限 - 10"
    giver.components.talker:Say(SayString)
    RepairItem(inst)
end

local function HoundstoothAcceptFn(inst, giver)
    inst.components.hatstatus.houndstooth_count = inst.components.hatstatus.houndstooth_count + 1
    giver.components.talker:Say("耐久 + 30s\n狗牙数量: "..inst.components.hatstatus.houndstooth_count.."/160\n满级后无限耐久")
    RepairItem(inst)
end

local function SkeletonhatAcceptFn(inst, giver)
    inst.components.hatstatus.skeletonhat_count = inst.components.hatstatus.skeletonhat_count + 1
    giver.components.talker:Say("白骨头盔数量: "..inst.components.hatstatus.skeletonhat_count.."/1\n满级后不会腐烂")
    RepairItem(inst)
end

local function DeserthatAcceptFn(inst, giver)
    inst.components.hatstatus.deserthat_count = inst.components.hatstatus.deserthat_count + 1
    giver.components.talker:Say("沙漠护目镜数量: "..inst.components.hatstatus.deserthat_count.."/10\n满级后获得沙漠护目镜效果")
    RepairItem(inst)
end

local function GoosefeatherAcceptFn(inst, giver)
    inst.components.hatstatus.goose_count = inst.components.hatstatus.goose_count + 1
    local waterproof = inst.components.hatstatus.base_waterproof + inst.components.hatstatus.goose_count
    waterproof = waterproof > 100 and 100 or waterproof
    giver.components.talker:Say("防水 + 1% (".. waterproof .. "%/100%)")
    -- 更新waterproof
    if inst.components.hatstatus.waterproof == 0 and inst.components.hatstatus.base_waterproof + inst.components.hatstatus.goose_count >= 100 then
        inst.components.hatstatus.waterproof = 1
    end
    RepairItem(inst)
end

local function EyebrellahatAcceptFn(inst, giver)
    inst.components.hatstatus.goose_count = inst.components.hatstatus.goose_count + 30
    local waterproof = inst.components.hatstatus.base_waterproof + inst.components.hatstatus.goose_count
    waterproof = waterproof > 100 and 100 or waterproof
    giver.components.talker:Say("防水 + 30% (".. waterproof .. "%/100%)")
    -- 更新waterproof
    if inst.components.hatstatus.waterproof == 0 and inst.components.hatstatus.base_waterproof + inst.components.hatstatus.goose_count >= 100 then
        inst.components.hatstatus.waterproof = 1
    end
    RepairItem(inst)
end

local function SpiderglandAcceptFn(inst, giver)
    inst.components.hatstatus.spidergland = inst.components.hatstatus.spidergland + 1
    local now_hungry = inst.components.hatstatus.spidergland /5 + inst.components.hatstatus.base_hungry
    giver.components.talker:Say("饥饿减缓 + 0.2% ("..now_hungry.."%/50%)")
    RepairItem(inst)
end

local function BeefalohatAcceptFn(inst, giver)
    inst.components.hatstatus.beefalohat_count = inst.components.hatstatus.beefalohat_count + 1
    local beefalohat_count = inst.components.hatstatus.beefalohat_count
    local closebeefalo = inst.components.hatstatus.closebeefalo
    local warm_all = inst.components.hatstatus.beefalohat_count*15 + inst.components.hatstatus.base_warm
    warm_all = warm_all + inst.components.hatstatus.walrushat_count*10 + inst.components.hatstatus.winterhat_count*10
    if warm_all >= 300 then
        warm_all = 300
    end
    if beefalohat_count < 5 then
        if inst.components.hatstatus.iswarm == 1 and inst.components.hatstatus.warm == 0 then
            giver.components.talker:Say("保暖 + 15s ("..warm_all.."/300)\n牛帽数量: "..beefalohat_count.."/5\n满级后获得亲牛效果")
        else
            giver.components.talker:Say("牛帽数量: "..beefalohat_count.."/5\n满级后获得亲牛效果")
        end
    else
        giver.components.talker:Say("保暖 + 15s ("..warm_all.."/300)\n已获得亲牛效果")
        inst.components.hatstatus.closebeefalo = 1
    end
    -- 更新warm
    if inst.components.hatstatus.warm == 0 and warm_all >= 300 then
        inst.components.hatstatus.warm = 1
    end
    RepairItem(inst)
end

local function WinterhatAcceptFn(inst, giver)
    inst.components.hatstatus.winterhat_count = inst.components.hatstatus.winterhat_count + 1
    local warm_all = inst.components.hatstatus.beefalohat_count*15 + inst.components.hatstatus.base_warm
    warm_all = warm_all + inst.components.hatstatus.walrushat_count*10 + inst.components.hatstatus.winterhat_count*10
    if warm_all >= 300 then
        warm_all = 300
    end
    giver.components.talker:Say("保暖 + 10s ("..warm_all.."/300)")
    -- 更新warm
    if inst.components.hatstatus.warm == 0 and warm_all >= 300 then
        inst.components.hatstatus.warm = 1
    end
    RepairItem(inst)
end

local function WalrushatAcceptFn(inst, giver)
    local hatstatus = inst.components.hatstatus
    hatstatus.walrushat_count = hatstatus.walrushat_count + 1
    local warm_all = hatstatus.beefalohat_count*15 + hatstatus.base_warm
    warm_all = warm_all + hatstatus.walrushat_count*10 + hatstatus.winterhat_count*10
    warm_all = warm_all >= 300 and 300 or warm_all

    if hatstatus.iswarm == 1 and hatstatus.warm == 0 then
        if hatstatus.sanity == 0 then
            giver.components.talker:Say("保暖 + 10 ("..warm_all.."/300)\n提升精神 + 1/min")
        else
            giver.components.talker:Say("保暖 + 10 ("..warm_all.."/300)")
        end
    else
        giver.components.talker:Say("提升精神 + 1/min ("..(hatstatus.walrushat_count < 0 and hatstatus.walrushat_count or "+"..hatstatus.walrushat_count).."/+8)")
    end
    -- 更新warm
    if hatstatus.warm == 0 and warm_all >= 300 then
        hatstatus.warm = 1
    end
    -- 更新sanity
    if hatstatus.sanity == 0 and hatstatus.base_sanity + hatstatus.walrushat_count >= 8 then
        hatstatus.sanity = 1
    end
    RepairItem(inst)
end

local function HivehatAcceptFn(inst, giver)
    inst.components.hatstatus.hivehat_count = inst.components.hatstatus.hivehat_count + 1
    local heart_all = inst.components.hatstatus.base_heart + inst.components.hatstatus.hivehat_count*40
    heart_all = heart_all + inst.components.hatstatus.icehat_count*15
    if heart_all >= 300 then
        heart_all = 300
    end
    giver.components.talker:Say("隔热 + 40s ("..heart_all.."/300)")
    -- 更新heart
    if inst.components.hatstatus.heart == 0 and heart_all >= 300 then
        inst.components.hatstatus.heart = 1
    end
    RepairItem(inst)
end

local function IcehatAcceptFn(inst, giver)
    inst.components.hatstatus.icehat_count = inst.components.hatstatus.icehat_count + 1
    local heart_all = inst.components.hatstatus.base_heart + inst.components.hatstatus.hivehat_count*40
    heart_all = heart_all + inst.components.hatstatus.icehat_count*15
    if heart_all >= 300 then
        heart_all = 300
    end
    giver.components.talker:Say("隔热 + 15s ("..heart_all.."/300)")
    -- 更新heart
    if inst.components.hatstatus.heart == 0 and heart_all >= 300 then
        inst.components.hatstatus.heart = 1
    end
    RepairItem(inst)
end

-- 概率双倍采集BUFF
local function doublepick(inst, data)        -- 双倍采集效果
    if data.object and data.object.components.pickable and not data.object.components.trader then
        if data.object.components.pickable.product ~= nil then
            if math.random() <= HAT_TUNING.DOUBLECHANCE then        --原有物品的双倍
                local item = SpawnPrefab(data.object.components.pickable.product)
                if item.components.stackable then
                    item.components.stackable:SetStackSize(data.object.components.pickable.numtoharvest)
                end
                inst.components.inventory:GiveItem(item, nil, data.object:GetPosition())
                if inst:HasTag("player") and not inst:HasTag("playerghost") and  ( data.object.prefab  == "cactus" or data.object.prefab  == "oasis_cactus" )  and  data.object.has_flower  then 
                    local lootcactus_flower = SpawnPrefab("cactus_flower")  -- 仙人掌花
                    if lootcactus_flower ~= nil then
                        inst.components.inventory:GiveItem(lootcactus_flower, nil, data.object:GetPosition())
                    end
                end
            end
            if math.random() <= HAT_TUNING.JELLYBUGCHANCE then
                if inst:HasTag("player") and not inst:HasTag("playerghost") and  data.object.prefab  == "coffeebush" then
                    local jellybug = SpawnPrefab("jellybug")
                    if jellybug ~= nil then
                        inst.components.inventory:GiveItem(jellybug, nil, data.object:GetPosition())
                    end
                end
            end
        end
    end
end

local function DoublePickEquipFn(inst, owner)
    if owner.has_doublepick ~= true then    -- 双倍采集(请不要删除has_doublepick!!!!因为下线再上线，BUFF会叠加)
        owner:RemoveEventCallback("picksomething", doublepick)
        owner:ListenForEvent("picksomething", doublepick)
        owner.has_doublepick = true
    end
end

local function DoublePickUnequipFn(inst, owner)
    owner:RemoveEventCallback("picksomething", doublepick)
    owner.has_doublepick = nil
end

-- 快速采集BUFF
local function FastPickEquipFn(inst, owner)
    owner:AddTag("fastpicker")
    owner:AddTag("fastharvester")
end

local function FastPickUnequipFn(inst, owner)
    if not (owner.components.allachivcoin and owner.components.allachivcoin.newpower221) then
        owner:RemoveTag("fastpicker")
        owner:RemoveTag("fastharvester")
    end
end

-- 植物人特效BUFF
local function WormwoodflowerEquipFn(inst, owner)
    owner.pollenpool = { 1, 2, 3, 4, 5 }
    for i = #owner.pollenpool, 1, -1 do
        table.insert(owner.pollenpool, table.remove(owner.pollenpool, math.random(i)))
    end
    
    owner.plantpool = { 1, 2, 3, 4 }
    for i = #owner.plantpool, 1, -1 do
        table.insert(owner.plantpool, table.remove(owner.plantpool, math.random(i)))
    end
    
    local PLANTS_RANGE = 1.5
    local MAX_PLANTS = 20
    local fx_name = "wormwood_plant_fx"
    -- print("植物人特效，帽子装备")
    if owner.planttask == nil then  -- 由于ValueCheck函数执行机制，这里会多次调用
        owner.planttask = owner:DoPeriodicTask(.21, function()
            if owner.sg:HasStateTag("ghostbuild") or owner.components.health:IsDead() or not owner.entity:IsVisible() then
                return
            end
            
            local x, y, z = owner.Transform:GetWorldPosition()
            if #TheSim:FindEntities(x, y, z, PLANTS_RANGE, { fx_name }) < MAX_PLANTS then
                local map = TheWorld.Map
                local pt = Vector3(0, 0, 0)
                local offset = FindValidPositionByFan(
                    math.random() * 2 * PI,
                    math.random() * PLANTS_RANGE,
                    3,
                    function(offset)
                        pt.x = x + offset.x
                        pt.z = z + offset.z
                        local tile = map:GetTileAtPoint(pt:Get())
        
                        return tile ~= GROUND.IMPASSABLE
                            and tile ~= GROUND.INVALID
                            and #TheSim:FindEntities(pt.x, 0, pt.z, .5, { fx_name}) < 3
                            and map:IsDeployPointClear(pt, nil, .5)
                            and not map:IsPointNearHole(pt, .4)
                    end
                )
                if offset ~= nil then
                    local plant = SpawnPrefab(fx_name)
                    local plant2 = SpawnPrefab(fx_name)
                    
                    if plant ~= nil then
                        plant.Transform:SetPosition(x + offset.x, 0, z + offset.z)
                        local rnd = math.random()
                        rnd = table.remove(owner.plantpool, math.clamp(math.ceil(rnd * rnd * #owner.plantpool), 1, #owner.plantpool))
                        table.insert(owner.plantpool, rnd)
                        plant:SetVariation(rnd)  
                    end
                    if plant2 ~= nil then
                        plant2.Transform:SetPosition(x - offset.x, 0, z - offset.z)
                        local rnd = math.random()
                        rnd = table.remove(owner.plantpool, math.clamp(math.ceil(rnd * rnd * #owner.plantpool), 1, #owner.plantpool))
                        table.insert(owner.plantpool, rnd)
                        plant2:SetVariation(rnd)  
                    end
                end
            end
        end)
    end
end

local function WormwoodflowerUnequipFn(inst, owner)
    -- print("植物人特效，帽子卸下")
    if owner.planttask ~= nil then
        -- print("植物人特效，任务终结")
        owner.planttask:Cancel()
        owner.planttask = nil
    end
end

-- 火焰免疫BUFF
local function FireimmunityEquipFn(inst, owner)
    --owner:AddTag("pyromaniac")    -- 制作打火机和伯尼的tag
    owner:AddTag("expertchef")      -- 快速烤食材的tag
    owner:AddTag("heatresistant")   -- 减少火焰伤害的tag
    owner.components.health.fire_damage_scale = TUNING.WILLOW_FIRE_DAMAGE
end

local function FireimmunityUnequipFn(inst, owner)
    --owner:RemoveTag("pyromaniac")
    owner:RemoveTag("expertchef")
    owner:RemoveTag("heatresistant")

    if owner.prefab == "willow" then    -- 将火焰伤害设置为人物原值
        owner.components.health.fire_damage_scale = TUNING.WILLOW_FIRE_DAMAGE
    elseif owner.prefab == "wormwood" then
        owner.components.health.fire_damage_scale = TUNING.WORMWOOD_FIRE_DAMAGE
    else
        owner.components.health.fire_damage_scale = 1
    end
end

--[[
-- 制造大师BUFF
local function BuildmasterEquipFn(inst, owner)

end

local function BuildmasterUnequipFn(inst, owner)

end
--]]

-- 属性全满BUFF
local function PropetyallValuecheckFn(inst)
    inst.components.hatstatus.propetyall = true
end

-- 季节适应
local function SeasonautoEquipFn(inst, owner)

end

local function SeasonautoUnequioFn(inst, owner)

end

local function BeeniceEquipFn(inst, owner)
    owner:AddTag("beenice")
end

local function BeeniceUnequipFn(inst, owner)
    owner:RemoveTag("beenice")
end

local AbilityList = {
    doublepick = { name = "概率双倍采集", EquipFn = DoublePickEquipFn, UnequipFn = DoublePickUnequipFn, ValueCheckFn = nil, weight = 1 },
    fastpick = { name = "快速采集", EquipFn = FastPickEquipFn, UnequipFn = FastPickUnequipFn, ValueCheckFn = nil, weight = 1 },
    wormwoodflower = { name = "植物人特效", EquipFn = WormwoodflowerEquipFn, UnequipFn = WormwoodflowerUnequipFn, ValueCheckFn = nil, weight = 1 },
    fireimmunity = { name = "火焰免疫", EquipFn = FireimmunityEquipFn, UnequipFn = FireimmunityUnequipFn, ValueCheckFn = nil, weight = 1 },
    -- buildmaster = { name = "制造大师", EquipFn = BuildmasterEquipFn, UnequipFn = BuildmasterUnequipFn, ValueCheckFn = nil, weight = 1 },
    propetyall = { name = "属性全满", EquipFn = nil, UnequipFn = nil, ValueCheckFn = PropetyallValuecheckFn, weight = 1 },
    -- seasonauto = { name = "季节适应", EquipFn = SeasonautoEquipFn, UnequipFn = SeasonautoUnequioFn, ValueCheckFn = nil, weight = 1 },
    beenice = { name = "蜜蜂友好", EquipFn = BeeniceEquipFn, UnequipFn = BeeniceUnequipFn, ValueCheckFn = nil, weight = 1 },
}

local function GetRandomAblity(baseAbilities)
    local abilities_key = table.getkeys(AbilityList)
    local abilities = {}
    for _,v in pairs(abilities_key) do
        abilities[v] = AbilityList[v].weight or 1
    end
    while true do
        if GetTableSize(abilities) < 1 then  -- 没有能力则返回失败
            return false
        end
        local randomAblity = weighted_random_choice(abilities)      -- 按权重随机一项能力
        if table.contains(baseAbilities, randomAblity) then         -- 如果能力已经有了，则重新随机
            -- table.remove(abilities, randomAblity)
            abilities[randomAblity] = nil
        else
            table.insert(baseAbilities, randomAblity)
            return true, randomAblity
        end
    end
end

local function OpalpreciousgemAcceptFn(inst, giver)
    local hatstatus = inst.components.hatstatus
    local result, newAbility = GetRandomAblity(hatstatus.abilities)
    if result and AbilityList[newAbility] ~= nil and AbilityList[newAbility].name ~= nil then
        hatstatus.opal_count = hatstatus.opal_count + 1
        M_PlayerSay(giver, "彩虹宝石数量： "..hatstatus.opal_count.."/2\n获得能力："..AbilityList[newAbility].name)
    else
        M_PlayerSay(giver, "失败！没有获取额外的能力")
        print("error: doesn't give any ability to player: "..tostring(giver.userid).."  "..tostring(result).."  "..tostring(newAbility))
    end
    RepairItem(inst)
end

local function SpiderhatRefuseFn(inst, giver)
    M_PlayerSay(giver, "这个帽子不需要去除湿润buff啦！")
end

local function HoundstoothRefuseFn(inst, giver)
    M_PlayerSay(giver, "这个帽子的耐久已满！")
end

local function SkeletonhatRefuseFn(inst, giver)
    M_PlayerSay(giver, "这个帽子已经没有新鲜度啦！")
end

local function DeserthatRefuseFn(inst, giver)
    M_PlayerSay(giver, "这个帽子已经获得了沙漠护目能力！")
end

local function GoosefeatherRefuseFn(inst, giver)
    M_PlayerSay(giver, "这个帽子防水效果已经满啦！")
end

local function SpiderglandRefuseFn(inst, giver)
    M_PlayerSay(giver, "这个帽子减缓饥饿buff已达上限！")
end

local function BeefalohatRefuseFn(inst, giver)
    M_PlayerSay(giver, "这个帽子已经获得亲牛能力啦！\n这个帽子不是保暖帽子或保暖效果已经满啦！")
end

local function WinterhatRefuseFn(inst, giver)
    M_PlayerSay(giver, "这个帽子不是保暖帽子或保暖效果已经满啦！")
end

local function WalrushatRefuseFn(inst, giver)
    M_PlayerSay(giver, "这个帽子的回SAN效果已经满啦！\n这个帽子不是保暖帽子或保暖效果已经满啦！")
end

local function HivehatRefuseFn(inst, giver)
    M_PlayerSay(giver, "这个帽子不是隔热帽子或隔热效果已经满啦！")
end

-- 给予树枝和草查看全属性
local function CutgrassRefuseFn(inst, giver)
    local spiderhat_count = inst.components.hatstatus.spiderhat_count
    local skeletonhat_count = inst.components.hatstatus.skeletonhat_count
    local houndstooth_count = inst.components.hatstatus.houndstooth_count
    local deserthat_count = inst.components.hatstatus.deserthat_count
    local goose_count = inst.components.hatstatus.goose_count
    local waterproof = inst.components.hatstatus.waterproof
    local spidergland = inst.components.hatstatus.spidergland
    local beefalohat_count = inst.components.hatstatus.beefalohat_count
    local closebeefalo = inst.components.hatstatus.closebeefalo
    local winterhat_count = inst.components.hatstatus.winterhat_count
    local warm = inst.components.hatstatus.warm
    local walrushat_count = inst.components.hatstatus.walrushat_count
    local sanity = inst.components.hatstatus.sanity
    local hivehat_count = inst.components.hatstatus.hivehat_count
    local icehat_count = inst.components.hatstatus.icehat_count
    local heart = inst.components.hatstatus.heart
    local base_waterproof = inst.components.hatstatus.base_waterproof
    local base_warm = inst.components.hatstatus.base_warm
    local base_sanity = inst.components.hatstatus.base_sanity
    local base_heart = inst.components.hatstatus.base_heart
    local base_hungry = inst.components.hatstatus.base_hungry
    local base_perishtime = inst.components.hatstatus.base_perishtime
    local base_perishtime_fresh = inst.components.hatstatus.base_perishtime_fresh
    local iswarm = inst.components.hatstatus.iswarm
    local has_goggles = inst.components.hatstatus.has_goggles
    local opal_count = inst.components.hatstatus.opal_count
    local propetyall = inst.components.hatstatus.propetyall

    local waterproof = base_waterproof + goose_count    -- 防水
    if waterproof > 100 or propetyall then waterproof = 100 end
    
    local sanity = base_sanity + walrushat_count        -- 提升精神
    if sanity > 8 or propetyall then sanity = 8 end
    
    local warm_all = beefalohat_count*15 + base_warm + walrushat_count*10 + winterhat_count*10    -- 保暖
    if warm_all > 300 or propetyall then warm_all = 300 end
    
    local heart_all = base_heart + hivehat_count*40 + icehat_count*15    -- 隔热
    if heart_all > 300 or propetyall then heart_all = 300 end
    
    local sayString = "这个帽子的当前属性:\n帽子类型: "
    
    sayString = sayString..(iswarm == 1 and "保暖\n保暖效果: " or "隔热\n隔热效果: ")
    sayString = sayString..(iswarm == 1 and warm_all.."s/300s(寒冬帽、牛帽、海象帽)\n" or heart_all.."s/300s(蜂王帽、冰帽)\n")
    sayString = sayString.."防水: "..waterproof.."%(鹅毛、眼球伞)\n"
    if inst.components.fueled then
        sayString = sayString.."耐久去除进度: "..houndstooth_count.."/160(狗牙)\n"
    elseif inst.components.perishable then
        sayString = sayString.."新鲜度去除进度: "..skeletonhat_count.."/1(白骨头盔)\n"
    end
    
    if has_goggles == 0 and not propetyall then
        sayString = sayString.."沙漠护目能力进度: "..deserthat_count.."/10(沙漠护目镜)\n"
    else
        sayString = sayString.."已获得沙漠护目能力\n"
    end
    sayString = sayString.."提升精神: "..(sanity >= 0 and "+"..sanity or sanity).."(海象帽)\n"
    sayString = sayString.."减缓饥饿进度: "..(propetyall and 50 or (spidergland/5 + base_hungry)).."%/50%(蜘蛛腺体)\n"
    sayString = sayString.."亲牛效果: "..(propetyall and 5 or beefalohat_count).."/5(牛帽)\n"
    if inst.prefab == "watermelonhat" and spiderhat_count < 3 and not propetyall then
        sayString = sayString.."西瓜帽湿润去除进度: "..spiderhat_count.."/3(蜘蛛帽)\n"
    end
    sayString = sayString.."特殊能力: "
    if opal_count == 0 then
        sayString = sayString.."无(彩虹宝石)"
    else
        for k,v in pairs(inst.components.hatstatus.abilities) do
            sayString = sayString..tostring(AbilityList[v] ~= nil and AbilityList[v].name or nil).."  "
        end
    end

    M_PlayerSay(giver, sayString)
end

local function OpalpreciousgemRefuseFn(inst, giver)
    M_PlayerSay(giver, "这个帽子不能再获取更多特殊能力啦！")
end

-- 升级材料列表
local acceptList = {
    spiderhat = { TestFn = SpiderhatTestFn, AcceptFn = SpiderhatAcceptFn, RefuseFn = SpiderhatRefuseFn },    -- 蜘蛛帽:3个去除西瓜帽湿润副作用
    houndstooth = { TestFn = HoundstoothTestFn, AcceptFn = HoundstoothAcceptFn, RefuseFn = HoundstoothRefuseFn },    -- 狗牙:160个获得永久耐久，只对无新鲜度的帽子有效
    skeletonhat = { TestFn = SkeletonhatTestFn, AcceptFn = SkeletonhatAcceptFn, RefuseFn = SkeletonhatRefuseFn },    -- 白骨头盔:1个获得永久新鲜度，只对有新鲜度的帽子有效
    deserthat = { TestFn = DeserthatTestFn, AcceptFn = DeserthatAcceptFn, RefuseFn = DeserthatRefuseFn },    -- 沙漠护目镜:10个获得沙漠护目镜效果
    goose_feather = { TestFn = GoosefeatherTestFn, AcceptFn = GoosefeatherAcceptFn, RefuseFn = GoosefeatherRefuseFn },    -- 鹅毛:一个加1%防水
    eyebrellahat = { TestFn = GoosefeatherTestFn, AcceptFn = EyebrellahatAcceptFn, RefuseFn = GoosefeatherRefuseFn },    -- 眼球伞，一个加30%防水
    spidergland = { TestFn = SpiderglandTestFn, AcceptFn = SpiderglandAcceptFn, RefuseFn = SpiderglandRefuseFn },    -- 蜘蛛腺体:250个加50%减缓饥饿速度
    beefalohat = { TestFn = BeefalohatTestFn, AcceptFn = BeefalohatAcceptFn, RefuseFn = BeefalohatRefuseFn },    -- 牛帽:一个加15保暖，五个获得亲牛光环
    winterhat = { TestFn = WinterhatTestFn, AcceptFn = WinterhatAcceptFn, RefuseFn = WinterhatRefuseFn },    -- 寒冬帽:一个加10保暖，上限300
    walrushat = { TestFn = WalrushatTestFn, AcceptFn = WalrushatAcceptFn, RefuseFn = WalrushatRefuseFn },    -- 贝雷帽:一个加10保暖，+1回san，上限8
    hivehat = { TestFn = HivehatTestFn, AcceptFn = HivehatAcceptFn, RefuseFn = HivehatRefuseFn },    -- 蜂王帽:一个加40隔热，上限300
    icehat = { TestFn = HivehatTestFn, AcceptFn = IcehatAcceptFn, RefuseFn = HivehatRefuseFn },    -- 冰块:一个加15隔热，上限300
    cutgrass = { TestFn = CutgrassTestFn, AcceptFn = nil, RefuseFn = CutgrassRefuseFn },
    twigs = { TestFn = CutgrassTestFn, AcceptFn = nil, RefuseFn = CutgrassRefuseFn },
    opalpreciousgem = { TestFn = OpalpreciousgemTestFn, AcceptFn = OpalpreciousgemAcceptFn, RefuseFn = OpalpreciousgemRefuseFn },    -- 彩虹宝石，随机获得一种特殊能力
}

-- 给升级材料加上tradable组件
for k, v in pairs(acceptList) do
    AddPrefabPostInit(k, function(inst)
       if inst.components.tradable == nil then inst:AddComponent("tradable") end
    end)
end

-- 根据组件hatstatus的参数更新帽子的属性
local function ValueCheck(inst)
    -- print("value check")
    for k, v in pairs(inst.components.hatstatus.abilities) do   -- 带有参数更改的能力，执行相应的参数更改函数
        if AbilityList[v] ~= nil and AbilityList[v].ValueCheckFn ~= nil then
            AbilityList[v].ValueCheckFn(inst)
        end
    end

    local propetyall = inst.components.hatstatus.propetyall

    if inst.prefab == "watermelonhat" then        -- 西瓜帽更新潮湿属性
        local spiderhat_count = inst.components.hatstatus.spiderhat_count
        local equippedmoisture = 0.5
        local maxequippedmoisture = 32
        if spiderhat_count < 3 and not propetyall then
            equippedmoisture = 0.5 - 0.2 * spiderhat_count
            maxequippedmoisture = 32 - 10 * spiderhat_count
        else
            equippedmoisture = 0
            maxequippedmoisture = 0
        end
        inst.components.equippable.equippedmoisture = equippedmoisture              -- 潮湿速度
        inst.components.equippable.maxequippedmoisture = maxequippedmoisture        -- 最大潮湿值
    end
    
    if inst.components.perishable then            -- 新鲜度未去除
        local skeletonhat_count = inst.components.hatstatus.skeletonhat_count
        local base_perishtime_fresh = inst.components.hatstatus.base_perishtime_fresh
        if skeletonhat_count < 1 and not propetyall then
            local preishTime = base_perishtime_fresh + skeletonhat_count * 10 * 16*30       -- 计算腐烂时间，每个骨头头盔耐久为10天
            inst.components.perishable:SetNewMaxPerishTime(preishTime)
        else
            inst:RemoveComponent("perishable")
        end
    end
    
    if inst.components.fueled then                -- 耐久更新
        local houndstooth_count = inst.components.hatstatus.houndstooth_count
        if houndstooth_count < 160 and not propetyall then
            local current_percent = inst.components.fueled:GetPercent()
            local base_perishtime = inst.components.hatstatus.base_perishtime
            local perishtime_all = base_perishtime + 30*houndstooth_count    -- 每个狗牙增加30s耐久
            inst.components.fueled:InitializeFuelLevel(perishtime_all)
            inst.components.fueled:SetPercent(current_percent)
        else
            inst:RemoveComponent("fueled")
            inst:AddTag("hide_percentage")
        end
    end
    
    if (inst.components.hatstatus.deserthat_count >= 10 and inst.components.hatstatus.has_goggles == 0) or propetyall then -- 给予沙漠护目镜效果
        inst.components.hatstatus.has_goggles = 1
    end
    
    if inst.components.hatstatus.waterproof == 0 and not propetyall then        -- 更新防水效果
        local base_waterproof = inst.components.hatstatus.base_waterproof
        local goose_count = inst.components.hatstatus.goose_count
        if inst.components.waterproofer == nil then
            inst:AddComponent("waterproofer")
        end
        local effectiveness = (base_waterproof + goose_count) / 100
        inst.components.waterproofer:SetEffectiveness(effectiveness)
    else
        if inst.components.waterproofer == nil then
            inst:AddComponent("waterproofer")
        end
        inst.components.waterproofer:SetEffectiveness(1)
        inst.components.equippable.insulated = true        -- 2020/06/16 满防水效果时，添加防雷效果
    end

    -- 在ValueCheck里hook装备和卸下的函数带来的问题：
    -- 每次给予物品时，都会调用ValueCheck函数
    -- 进而每次给予物品时，都会hook一次装备和卸下的函数
    -- 每次给予物品时，帽子的buff就多一层
    -- 对标签类的buff，可以无视，但是对task类的buff，task会不断叠加！
    -- 解决办法：
    --    1：每个task都保证只添加一次(问题：容易忘记写task判定)
    local old_onequipfn = inst.components.equippable.onequipfn
    local old_onunequip = inst.components.equippable.onunequipfn
    
    local spidergland = inst.components.hatstatus.spidergland
    local base_hungry = inst.components.hatstatus.base_hungry*5
    local hungryBuff = 1 - (spidergland + base_hungry) / 500
    hungryBuff = propetyall and 0.5 or hungryBuff

    local function new_onequip(inst, owner, symbol_override)
        if inst.components.hatstatus.has_goggles == 1 and owner:HasTag("player") and owner:GetSandstormLevel() >= TUNING.SANDSTORM_FULL_LEVEL and not owner.components.playervision:HasGoggleVision() then
            inst:AddTag("goggles")                        -- 添加沙漠护目镜buff
        end
        if inst.components.hatstatus.closebeefalo == 1 or propetyall then  -- 亲牛
            owner:AddTag("beefalo")
        end
        if inst.components.hatstatus.opal_count > 0 then
            owner:AddTag("Detoxification")  -- 毒抗性
        end

        if owner.components.hunger ~= nil then
            owner.components.hunger.burnratemodifiers:SetModifier(inst, hungryBuff)
        end
        -- print("hook equip function")
        for k, v in pairs(inst.components.hatstatus.abilities) do   -- 装备和卸下有关的能力
            if AbilityList[v] ~= nil and AbilityList[v].EquipFn ~= nil then
                AbilityList[v].EquipFn(inst, owner)
            end
        end

        old_onequipfn(inst, owner, symbol_override)
    end
    
    local function new_onunequip(inst, owner)       -- 卸下后不减缓饥饿
        inst:RemoveTag("goggles")                   -- 移除沙漠护目镜buff
        owner:RemoveTag("beefalo")                  -- 移除亲牛效果
        owner:RemoveTag("Detoxification")           -- 移除毒抗性
        
        if owner.components.hunger ~= nil then
            owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
        end
        
        -- print("hook unequip function")
        for k, v in pairs(inst.components.hatstatus.abilities) do   -- 对应equip函数
            if AbilityList[v] ~= nil and AbilityList[v].UnequipFn ~= nil then
                AbilityList[v].UnequipFn(inst, owner)
            end
        end

        old_onunequip(inst, owner)
    end
    
    inst.components.equippable:SetOnEquip(new_onequip)
    inst.components.equippable:SetOnUnequip(new_onunequip)

    if inst.components.hatstatus.iswarm == 1 then
        if inst.components.hatstatus.warm == 0 and not propetyall then            -- 更新保暖效果
            local base_warm = inst.components.hatstatus.base_warm
            local beefalohat_count = inst.components.hatstatus.beefalohat_count
            local winterhat_count = inst.components.hatstatus.winterhat_count
            local walrushat_count = inst.components.hatstatus.walrushat_count
            
            local warm_all = base_warm + beefalohat_count*15 + winterhat_count*10 + walrushat_count*10
            warm_all = warm_all > 300 and 300 or warm_all        -- 因为其他能力导致此处可能超过设定值

            inst.components.insulator:SetInsulation(warm_all)
        else
            inst.components.insulator:SetInsulation(300)
        end
    else
        if inst.components.hatstatus.heart == 0 and not propetyall then        -- 更新隔热效果
            local base_heart = inst.components.hatstatus.base_heart
            local hivehat_count = inst.components.hatstatus.hivehat_count
            local icehat_count = inst.components.hatstatus.icehat_count

            local heart_all = base_heart + hivehat_count*40 + icehat_count*15
            heart_all = heart_all > 300 and 300 or heart_all
            
            inst.components.insulator:SetSummer()
            inst.components.insulator:SetInsulation(heart_all)
        else
            inst.components.insulator:SetSummer()
            inst.components.insulator:SetInsulation(300)
        end
    end
    
    if inst.components.hatstatus.sanity == 0 and not propetyall then        -- 更新回san效果
        local base_sanity = inst.components.hatstatus.base_sanity
        local walrushat_count = inst.components.hatstatus.walrushat_count

        local sanity_all = (base_sanity + walrushat_count) / 54
        sanity_all = sanity_all > (8/54) and 8/54 or sanity_all
        
        inst.components.equippable.dapperness = sanity_all
    else
        inst.components.equippable.dapperness = 8/54
    end

end

-- 接受物品判定
local function GetItemFromPlayer(inst, item)
    if item == nil or inst == nil then
        return false
    elseif acceptList[item.prefab] ~= nil and acceptList[item.prefab].TestFn ~= nil then
        return acceptList[item.prefab].TestFn(inst)
    else
        return false
    end
end

-- 接受物品后的处理，更新组件hatstatus的参数
local function OnGemGiven(inst, giver, item)
    if acceptList[item.prefab] ~= nil and acceptList[item.prefab].AcceptFn ~= nil then
        acceptList[item.prefab].AcceptFn(inst, giver)
    end
    ValueCheck(inst)
end

-- 拒绝物品后的处理
local function OnRefuseIten(inst, giver, item)
    if acceptList[item.prefab] ~= nil and acceptList[item.prefab].RefuseFn ~= nil then
        acceptList[item.prefab].RefuseFn(inst, giver)
    else
        M_PlayerSay(giver, "这个材料貌似不对......\n (给予树枝或草查看升级进度)")
    end
end

-- 公用函数
local function fn(inst)
    if inst.SoundEmitter == nil then
        inst.entity:AddSoundEmitter()
    end
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("hatstatus")
    hatList[inst.prefab].BaseFn(inst)
    -- UpdateBaseValue(inst)
    inst.ValueCheck = ValueCheck

    if inst.components.insulator == nil then
        inst:AddComponent("insulator")
    end
    
    inst:AddComponent("trader")
    -- inst.components.trader:SetAbleToAcceptTest(GetItemFromPlayer)
    inst.components.trader:SetAcceptTest(GetItemFromPlayer)
    inst.components.trader.onaccept = OnGemGiven
    inst.components.trader.onrefuse = OnRefuseIten
    
    inst:DoTaskInTime(0, function() ValueCheck(inst) end)
end

-- 对hatList中的帽子添加升级功能
for k, v in pairs(hatList) do
    AddPrefabPostInit(k, fn)
end
