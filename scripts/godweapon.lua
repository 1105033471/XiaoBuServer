local prefabfiles = {
    "tz_icesword",
    "chasethewind",
    "oldfish_axe",
    "phoenixspear",
    "flyinghunter",
    "tz_projectile",
    "skinstaff",
    -- "killer",

    "boss_heart",
    "armor_obsidian",
    "obsidian",
    "obsidianfirepit",
    "obsidianfirefire",
}

local assets = {
    Asset("ATLAS", "images/inventoryimages/skinstaff.xml"),
    Asset("ATLAS", "images/inventoryimages/tz_icesword.xml"),
    Asset("ATLAS", "images/inventoryimages/oldfish_axe.xml"),
    Asset("ATLAS", "images/inventoryimages/chasethewind.xml"),
    Asset("ATLAS", "images/inventoryimages/phoenixspear_ice.xml"),
    Asset("ATLAS", "images/inventoryimages/phoenixspear_fire.xml"),
    Asset("ATLAS", "images/inventoryimages/flyinghunter.xml"),
    Asset("ATLAS", "images/inventoryimages/volcanoinventory.xml"),
    Asset("ATLAS", "images/inventoryimages/armor_obsidian.xml"),
    Asset("ATLAS", "images/inventoryimages/obsidian.xml"),
}

for k,v in pairs(prefabfiles) do
    table.insert(PrefabFiles, v)
end

for k,v in pairs(assets) do
    table.insert(Assets, v)
end

-- 逐风之刃
AddRecipe("chasethewind",
    {
        Ingredient("walrus_tusk", 1),
        Ingredient("dragon_scales", 1),
        Ingredient("moonrocknugget", 2),
        Ingredient("opalpreciousgem", 1)
    },
    RECIPETABS.WAR,
    TECH.LOST,
    nil,
    nil,
    nil,
    nil,
    nil,
    "images/inventoryimages/chasethewind.xml",
    "chasethewind.tex"
)

-- 皮肤法杖
AddRecipe("skinstaff",
    {
        Ingredient("greengem", 1),
        Ingredient("opalpreciousgem", 1),
        Ingredient("feather_robin", 4)
    },
    RECIPETABS.WAR,
    TECH.MAGIC_THREE,
    nil, --placer
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/skinstaff.xml", -- atlas
    "skinstaff.tex"                         -- image
)

-- 红宝石
AddRecipe("redgem",
    {
        Ingredient("bluegem", 1),
        Ingredient("honey", 5)
    },
    RECIPETABS.REFINE,
    TECH.MAGIC_TWO, 
    nil, --placer
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    nil, -- atlas
    nil  -- image
)

-- 蓝宝石
AddRecipe("bluegem",
    {
        Ingredient("redgem", 1),
        Ingredient("honey", 5)
    },
    RECIPETABS.REFINE,
    TECH.MAGIC_TWO, 
    nil, --placer
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    nil, -- atlas
    nil  -- image
)

-- 添加远古科技塔制造配方
AddRecipe("ancient_altar",
    {
        Ingredient("thulecite", 15),
        Ingredient("cutstone", 20),
        Ingredient("greengem", 2)
    },
    RECIPETABS.TOWN,
    TECH.LOST, 
    "ancient_altar_placer", --placer
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/altar.xml", -- atlas
    "altar.tex"                             -- image
)

-- 老余武器1
AddRecipe("tz_icesword",
    {
        Ingredient("fossil_piece", 6),
        Ingredient("horn", 2)
        -- Ingredient("opalpreciousgem", 1)
    },
    RECIPETABS.WAR,
    TECH.SCIENCE_TWO,
    nil,
    nil,
    nil,
    nil,
    nil,
    "images/inventoryimages/tz_icesword.xml",
    "tz_icesword.tex"
)

-- 老余武器2
AddRecipe("oldfish_axe",
    {
        Ingredient("batwing", 20),
        Ingredient("nightmarefuel", 20),
        Ingredient("opalpreciousgem", 2)
    },
        RECIPETABS.WAR,
        TECH.LOST,
    nil,
    nil,
    nil,
    nil,
    nil,
    "images/inventoryimages/oldfish_axe.xml",
    "oldfish_axe.tex"
)

-- 火焰凤凰剑
AddRecipe("phoenixspear_fire",
    {
        Ingredient("redgem", 15),
        Ingredient("cave_chocolate", 3, "images/inventoryimages/cave_chocolate.xml", false, "cave_chocolate.tex")
    },
    RECIPETABS.WAR,
    TECH.SCIENCE_TWO,
    nil,
    nil,
    nil,
    nil,
    nil,
    "images/inventoryimages/phoenixspear_fire.xml",
    "phoenixspear_fire.tex"
)

-- 冰霜凤凰剑
AddRecipe("phoenixspear_ice",
    {
        Ingredient("bluegem", 15),
        Ingredient("cave_chocolate", 3, "images/inventoryimages/cave_chocolate.xml", true, "cave_chocolate.tex")
    },
    RECIPETABS.WAR,
    TECH.SCIENCE_TWO,
    nil,
    nil,
    nil,
    nil,
    nil,
    "images/inventoryimages/phoenixspear_ice.xml",
    "phoenixspear_ice.tex"
)

-- 斩翼者
AddRecipe("flyinghunter",
    {
        Ingredient("dragon_heart_gem", 3, "images/inventoryimages/dragon_heart_gem.xml", true, "dragon_heart_gem.tex"),
        Ingredient("beequeen_heart_gem", 3, "images/inventoryimages/beequeen_heart_gem.xml", true, "beequeen_heart_gem.tex"),
        Ingredient("malbatross_heart_gem", 3, "images/inventoryimages/malbatross_heart_gem.xml", true, "malbatross_heart_gem.tex")
    },
    RECIPETABS.WAR,
    TECH.LOST,
    nil,
    nil,
    nil,
    nil,
    nil,
    "images/inventoryimages/flyinghunter.xml",
    "flyinghunter.tex"
)

-- 黑曜石甲
AddRecipe("armorobsidian",
    {
        Ingredient("obsidian", 4, "images/inventoryimages/obsidian.xml", true, "obsidian.tex"),
        Ingredient("armormarble", 1),
        Ingredient("armorruins", 1),
    },
    RECIPETABS.ANCIENT,  --ANCIENT
    TECH.ANCIENT_FOUR,
    nil,
    nil,
    true,
    nil,
    nil,
    "images/inventoryimages/armor_obsidian.xml",    -- 制造栏的贴图
    "armor_obsidian.tex"
)

-- 黑曜石火堆
AddRecipe("obsidianfirepit",
    {
        Ingredient("obsidian", 2, "images/inventoryimages/obsidian.xml"),
        Ingredient("yellowgem", 3),
        Ingredient("cutstone", 8),
    },
    RECIPETABS.LIGHT,
    TECH.MAGIC_THREE,
    "obsidianfirepit_placer",
    nil,
    nil,
    nil,
    nil,
    "images/inventoryimages/volcanoinventory.xml"
)

-- 木甲增强
AddPrefabPostInit("armormarble", function(inst) inst:AddComponent("tradable") end)
AddPrefabPostInit("walrus_tusk", function(inst) inst:AddComponent("tradable") end)
AddPrefabPostInit("yellowamulet", function(inst) inst:AddComponent("tradable") end)
Recipe("armorwood", {Ingredient("boards", 8),Ingredient("rope", 2)}, RECIPETABS.WAR,  TECH.NONE)

AddPrefabPostInit("armorwood", function (inst)
    inst.entity:AddSoundEmitter()
    if not GLOBAL.TheWorld.ismastersim then
        return inst
    end
    local function ItemTradeTest(inst,item)
        if item == nil then

            return false
        end
        
        if inst.components.armorwoodstatus then
            if inst.components.armorwoodstatus.level == 0 then     -- 第一阶段给5大理石甲,每个增加1%防御但是减少2%移速
                if item.prefab ~= "armormarble" then
                    return false
                end
            elseif inst.components.armorwoodstatus.level == 1 then    -- 第二阶段给2象牙,每个恢复5%移速
                if item.prefab ~= "walrus_tusk" then
                    return false
                end
            elseif inst.components.armorwoodstatus.level == 2 then    -- 第三阶段给2暗影之心，第一个耐久度+3000，第二个获得永久耐久
                if item.prefab ~= "shadowheart" then
                    return false
                end
            elseif inst.components.armorwoodstatus.level == 3 then    -- 第四阶段给6黄护符，给满后小范围发光并提升15%移速
                if item.prefab ~= "yellowamulet" then
                    return false
                end
            else
                return false
            end
        end
        return true
    end

    local old_onequip = inst.components.equippable.onequipfn
    local function onequip(inst, owner)
        old_onequip(inst, owner)
        
        -- 装备发光
        if inst._light == nil or not inst._light:IsValid() then
            inst._light = SpawnPrefab("heatrocklight")
        end
        inst._light.entity:SetParent(owner.entity)
        inst._light.Light:SetIntensity(.7)
        inst._light.Light:Enable(true)
        inst._light.Light:SetRadius(.4)        -- 发光范围
    end
    
    local old_onunequip = inst.components.equippable.onunequipfn
    local function onunequip(inst, owner) 
        old_onunequip(inst, owner)
        
        -- 卸下后不发光
        if inst._light ~= nil then
            if inst._light:IsValid() then
                inst._light:Remove()
            end
            inst._light = nil
        end
    end
    
    local function valuecheck(inst)
        local speed_down = inst.components.armorwoodstatus:GetSpeed()    -- 计算速度
        inst.components.equippable.walkspeedmult = speed_down
        
        local absorption_wood = inst.components.armorwoodstatus:GetDefense()    -- 防御值
        local maxcondition = inst.components.armorwoodstatus:GetCondition()        -- 最大耐久
        
        inst.components.armor.maxcondition = maxcondition
        inst.components.armor.absorb_percent = absorption_wood
        
        -- inst.components.armor:InitCondition(maxcondition, absorption_wood)    -- 计算防御值和耐久
        if inst.components.armorwoodstatus.level >= 3 then
            inst.components.armor:InitIndestructible(absorption_wood)    -- 满级后耐久不掉
            inst.components.armor.condition = inst.components.armor.maxcondition
            inst:AddTag("hide_percentage")
        end
        if inst.components.armorwoodstatus.level > 3 then
            -- 添加发光属性，重写木甲的装备和卸下函数
            inst.components.equippable:SetOnEquip(onequip)
            inst.components.equippable:SetOnUnequip(onunequip)
            inst:RemoveComponent("trader")
        end
        if inst.components.armorwoodstatus.level > 0 and inst.components.burnable ~= nil then
            inst:RemoveComponent("burnable")
        end
    end
    
    local function OnGoldGiven(inst, giver, item)
        if inst.components.armorwoodstatus.level == 0 then
            inst.components.armorwoodstatus:DoMarbleLevel()
            if inst.components.armorwoodstatus.armormarble_count < 5 then
                inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
                giver.components.talker:Say("当前为0阶，大理石盔甲数量\n"..inst.components.armorwoodstatus.armormarble_count.."/5")
            else
                inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
                giver.components.talker:Say("进阶成功！\n下阶需要材料：海象牙")
            end
        elseif inst.components.armorwoodstatus.level == 1 then
            inst.components.armorwoodstatus:DoTuskLevel()
            if inst.components.armorwoodstatus.tusk_count < 2 then
                inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
                giver.components.talker:Say("当前为1阶，海象牙数量\n"..inst.components.armorwoodstatus.tusk_count.."/2")
            else
                inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
                giver.components.talker:Say("进阶成功！\n下阶需要材料：暗影心脏")
            end
        elseif inst.components.armorwoodstatus.level == 2 then
            inst.components.armorwoodstatus:DoHeartLevel()
            if inst.components.armorwoodstatus.heart_count < 2 then
                inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
                giver.components.talker:Say("当前为2阶，暗影心脏数量\n"..inst.components.armorwoodstatus.heart_count.."/2")
            else
                inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
                giver.components.talker:Say("进阶成功！\n下阶需要材料：魔光护符")
            end
        elseif inst.components.armorwoodstatus.level == 3 then
            inst.components.armorwoodstatus:DoYelAmuletLevel()
            if inst.components.armorwoodstatus.yellowamulet_count < 6 then
                inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
                giver.components.talker:Say("当前为3阶，魔光护符数量\n"..inst.components.armorwoodstatus.yellowamulet_count.."/6")
            else
                inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
                giver.components.talker:Say("进阶成功！(满级)")
            end
        end
        valuecheck(inst)
        inst.components.armor:SetPercent(1)    -- 给予物品后修复成满耐久
    end
    inst:RemoveComponent("armor")
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(850, .8)
    
    inst:AddComponent("armorwoodstatus")

    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGoldGiven
    inst.valuecheck = valuecheck        -- 用于兼容皮肤法杖更换皮肤时的属性更新
    
    inst:DoTaskInTime(0, function() valuecheck(inst) end)
end)

-- 邪天翁
AddPrefabPostInit("malbatross", function(inst)
    inst:AddTag("flyingboss")
    if inst.components.lootdropper then
        inst.components.lootdropper:AddChanceLoot("malbatross_heart_gem", .5)
        inst.components.lootdropper:AddChanceLoot("malbatross_heart_gem", .5)
    end
end)

-- 蜂后
AddPrefabPostInit("beequeen", function(inst)
    inst:AddTag("flyingboss")
    if inst.components.lootdropper then
        inst.components.lootdropper:AddChanceLoot("beequeen_heart_gem", .5)
        inst.components.lootdropper:AddChanceLoot("beequeen_heart_gem", .5)
    end
end)

-- 鹿鹅
AddPrefabPostInit("moose", function(inst)
    inst:AddTag("flyingboss")
end)

-- 龙鹰
AddPrefabPostInit("dragonfly", function(inst)
    inst:AddTag("flyingboss")
    if inst.components.lootdropper then
        inst.components.lootdropper:AddChanceLoot("dragon_heart_gem", .5)
        inst.components.lootdropper:AddChanceLoot("dragon_heart_gem", .5)
    end
end)

-- 电羊掉落黑曜石
AddPrefabPostInit("lightninggoat", function(inst)
    if inst.components.lootdropper then
        inst.components.lootdropper:AddChanceLoot("obsidian", .35)
    end
end)

-- 高脚鸟掉落黑曜石
AddPrefabPostInit("tallbird", function(inst)
    if inst.components.lootdropper then
        inst.components.lootdropper:AddChanceLoot("obsidian", .35)
    end
end)

-- 钢羊掉落黑曜石
AddPrefabPostInit("spat", function(inst)
    if inst.components.lootdropper then
        inst.components.lootdropper:AddChanceLoot("obsidian", .5)
    end
end)

-- 绿杖分解: 无法分解神器
AddPrefabPostInit("greenstaff", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    local old_spell = inst.components.spellcaster.spell
    if old_spell == nil then old_spell = function(inst, target) end end
    local function new_spell(inst, target)
        if target:HasTag("godweapon") then return end
        old_spell(inst, target)
    end
    inst.components.spellcaster:SetSpellFn(new_spell)
end)