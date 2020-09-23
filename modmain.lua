GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local strength_monster = GetModConfigData("strength_monster")
local extra_open = GetModConfigData("extra_open")

-- 设置随机数种子
math.randomseed(tostring(os.time()):reverse():sub(1, 7))

PrefabFiles = {
    "altar_placer",
    "cave_chocolate", -- 巧克力

    "moonrock_chip",    -- 月亮石
    "moon_armor",       -- 月亮石甲

    "rawling",          -- 罗琳（排球）
    "conch",            -- 贝壳

    "maxwelllight",         -- 麦斯威尔光柱
    "maxwelllight_flame",

    "skull_chest",
    "personal_chest",
    
    "treeroot",             -- 树根
}

Assets = {
    Asset("ATLAS", "images/inventoryimages/altar.xml"),
    Asset("ANIM", "anim/altar.zip"),
    Asset("ATLAS", "images/inventoryimages/cave_chocolate.xml"),

    Asset("ATLAS", "images/inventoryimages/moonrock_chip.xml"),
    Asset("ATLAS", "images/inventoryimages/armor_greengem.xml"),
    Asset("ATLAS", "images/inventoryimages/skinstaff.xml"),
    
    -- 罗琳
	Asset("ANIM", "anim/basketball.zip"),
    Asset("ANIM", "anim/swap_basketball.zip"),
    Asset("ATLAS", "images/inventoryimages/rawling.xml"),

    -- 贝壳
    Asset("ANIM", "anim/conch.zip"),
    Asset("ANIM", "anim/swap_conch.zip"),   -- 这个是用来覆盖吹牛角时的牛角
    Asset("ATLAS", "images/inventoryimages/conch.xml"),
    
    Asset("ATLAS", "images/inventoryimages/skull_chest.xml"),        -- 末影箱
    Asset("ATLAS", "images/inventoryimages/personal_chest.xml"),    -- 私人箱子
    
    Asset("ANIM", "anim/ui_chest_5x5.zip"),
    Asset("ATLAS", "images/inventoryimages/ui_chest_5x5.xml"),
    Asset("IMAGE", "images/inventoryimages/ui_chest_5x5.tex"),
    
    Asset("ANIM", "anim/ui_chest_5x10.zip"),
    Asset("ATLAS", "images/inventoryimages/ui_chest_5x10.xml"),
    Asset("IMAGE", "images/inventoryimages/ui_chest_5x10.tex"),
    
    Asset("ATLAS", "images/inventoryimages/treeroot.xml"),

    -- 按钮
    Asset("ATLAS", "images/button/skull_chest_btn.xml"),
    
    -- 音乐包
    Asset("SOUNDPACKAGE", "sound/dontstarve_DLC003.fev"),
}
AddMinimapAtlas("images/inventoryimages/altar.xml")

require "utils/bu_shadow_chest_find"

modimport("scripts/ming_util.lua")                      -- global function
modimport("scripts/allstrings.lua")                     -- 所有描述
modimport("scripts/others.lua")                         -- 其他杂项
modimport("scripts/pighousetrader.lua")                 -- 猪窝可交易
modimport("scripts/stack.lua")                          -- 自动堆叠
modimport("scripts/clean.lua")                          -- 自动清理
modimport("scripts/lab2trash.lua")                      -- 二本垃圾桶
modimport("scripts/magic_oasislake.lua")                -- 神奇沙漠湖
modimport("scripts/morehats.lua")                       -- 帽子升级
modimport("scripts/minglock.lua")                       -- 防熊锁
modimport("scripts/wormholemark.lua")                   -- 虫洞标记
modimport("scripts/extraequipslot.lua")                 -- 额外装备栏
modimport("scripts/usefulboats.lua")                    -- 更实用的船
modimport("scripts/extraturf.lua")                      -- 额外的地皮

if extra_open then
    modimport("scripts/godweapon.lua")                  -- 神器
    modimport("scripts/coffee.lua")                     -- 咖啡
    modimport("scripts/transplant.lua")                 -- 移植
    modimport("scripts/flowerbox.lua")                  -- 花盒
    modimport("scripts/hamlets.lua")                    -- 哈姆雷特物品
    modimport("scripts/shadowbox.lua")                  -- 末影箱
    modimport("scripts/shipwrecked.lua")                -- 海难物品
end

-- modimport("scripts/extrabackpack.lua")               -- 额外的背包

modimport("scripts/bu_recipes.lua")                     -- 配方

--生物加强
if strength_monster then
    modimport("scripts/strengthen.lua")
end

ACTIONS.TOSS.distance = 15

-- 牛死亡后，一定几率生出小牛（变相提高牛群繁殖速度）
AddPrefabPostInit("beefalo", function(inst)
    local function SpawnBabyBeefalo(inst)
        local chance = math.random()
        if chance <= 0.6 then
            local baby = SpawnPrefab("babybeefalo")
            if baby then
                local x, y, z = inst.Transform:GetWorldPosition()
                baby.Transform:SetPosition(x+math.random(-2,2), y, z+math.random(-2,2))
            end
        end
    end

    if not TheWorld.ismastersim then
        return
    end
    
    inst:ListenForEvent("death", SpawnBabyBeefalo)
end)

-- 吹贝壳的sg
AddStategraphState("wilson", State{
    name = "play_conch",
    tags = {"doing", "playing"},

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("horn")
        inst.AnimState:Show("ARM_normal")
        inst.AnimState:OverrideSymbol("horn01", 'swap_conch', 'swap_conch')
    end,

    timeline={
        TimeEvent(22*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/horn_beefalo")
            inst:PerformBufferedAction()
        end),

        TimeEvent(30*FRAMES, function(inst)
            
        end),
    },

    events={
        EventHandler("animqueueover", function(inst)
        	if inst.AnimState:AnimDone() then
        		inst.sg:GoToState("idle")
        	end
        end),
    },

    onexit = function(inst)
        if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
            inst.AnimState:Show("ARM_carry")
            inst.AnimState:Hide("ARM_normal")
        end
    end,
})

AddStategraphState("wilson_client", State{
    name = "play_conch",
    tags = {"doing", "playing"},

    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("horn")
        inst.AnimState:Show("ARM_normal")
        inst.AnimState:OverrideSymbol("horn01", 'swap_conch', 'swap_conch')
    end,

    timeline={
        TimeEvent(22*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/common/horn_beefalo")
            inst:PerformBufferedAction()
        end),

        TimeEvent(30*FRAMES, function(inst)
            
        end),
    },

    events={
        EventHandler("animqueueover", function(inst)
        	if inst.AnimState:AnimDone() then
        		inst.sg:GoToState("idle")
        	end
        end),
    },
})

AddComponentAction("INVENTORY", "play_conch" , function(inst, doer, actions)
    if doer and inst:HasTag("canuseconch") then
        table.insert(actions, ACTIONS.USE_CONCH)
    end
end)

AddStategraphActionHandler("wilson",
    ActionHandler(ACTIONS.PLAY, function(inst, action)
        if action.invobject ~= nil then
            return (action.invobject:HasTag("flute") and "play_flute")
                or (action.invobject:HasTag("horn") and "play_horn")
                or (action.invobject:HasTag("bell") and "play_bell")
                or (action.invobject:HasTag("whistle") and "play_whistle")
                or (action.invobject:HasTag("canuseconch") and "play_conch")
                or nil
        end
    end)
)

AddStategraphActionHandler("wilson_client",
    ActionHandler(ACTIONS.PLAY, function(inst, action)
        if action.invobject ~= nil then
            return (action.invobject:HasTag("canuseconch") and "play_conch")
                or "play"
        end
    end)
)

AddPrefabPostInit("treasurechest", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    local old_onsave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_onsave then old_onsave(inst, data) end
        data.not_triggered = inst.not_triggered
    end

    local old_onload = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_onload then old_onload(inst, data) end
        if data then
            inst.not_triggered = data.not_triggered
            -- print("treasurechest entity onload")
        end
    end
end)

-- 挂在controls的客户端代码
AddModRPCHandler("XiaoBu_Server", "shadow_box_info", function(player)
    print("server handle rpc")
    if not TheWorld.key_point_info then
        Bu_InitKeyPointInfo()
    end
    player._key_point:set_local("")     -- 以确保下面的操作一定能触发key_point_dirty事件
    player._key_point:set(Bu_GetShadowBoxInfo(player))
    print("set net var ok!")
end)

AddPlayerPostInit(function(player)
    -- if TheWorld.ismastersim then
        player._key_point = net_string(player.GUID, "player.key_point", "key_point_dirty")
    -- end
end)

local bu_ui_shadowbox = require("widgets/bu_ui_shadowbox")
local function Bu_UI_controls(self)
    self.bu_ui_shadowbox = self.top_root:AddChild(bu_ui_shadowbox())
    self.bu_ui_shadowbox:SetHAnchor(0)
    self.bu_ui_shadowbox:SetVAnchor(0)
    self.bu_ui_shadowbox:MoveToFront()
end

AddClassPostConstruct("widgets/controls", Bu_UI_controls)
