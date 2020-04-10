local prefabs = {
    "skull_chest",
    "personal_chest",
    
    "treeroot",             -- 树根
}
for _,v in pairs(prefabs) do
    table.insert(PrefabFiles, v)
end

local assets = {
    Asset("ATLAS", "images/inventoryimages/skull_chest.xml"),        -- 末影箱
    Asset("ATLAS", "images/inventoryimages/personal_chest.xml"),    -- 私人箱子
    
    Asset("ANIM", "anim/ui_chest_5x5.zip"),
    Asset("ATLAS", "images/inventoryimages/ui_chest_5x5.xml"),
    Asset("IMAGE", "images/inventoryimages/ui_chest_5x5.tex"),
    
    Asset("ANIM", "anim/ui_chest_5x10.zip"),
    Asset("ATLAS", "images/inventoryimages/ui_chest_5x10.xml"),
    Asset("IMAGE", "images/inventoryimages/ui_chest_5x10.tex"),
    
    Asset("ATLAS", "images/inventoryimages/treeroot.xml"),
}

for _,v in pairs(assets) do
    table.insert(Assets, v)
end

local PERSONAL_CHEST_MAX = 3            -- 私人箱子建造上限
local SKULL_CHEST_MAX = 3                -- 末影箱建造上限

-- 末影箱
AddRecipe("skull_chest",
    {
        Ingredient("purplegem", 1),
        Ingredient("boneshard", 4),
        Ingredient("boards", 2),
    },
    RECIPETABS.MAGIC,
    TECH.MAGIC_TWO,
    "skull_chest_placer",
    1,
    nil,
    nil,
    nil,
    "images/inventoryimages/skull_chest.xml",
    "skull_chest.tex"
)
AddMinimapAtlas("images/inventoryimages/skull_chest.xml")

-- 私人箱子
AddRecipe("personal_chest",
    {
        -- Ingredient("purplegem", 1),
        Ingredient("treeroot", 4, "images/inventoryimages/treeroot.xml", false, "treeroot.tex"),
        Ingredient("boards", 6),
    },
    RECIPETABS.TOWN,
    TECH.NONE,
    "personal_chest_placer",
    1,
    nil,
    nil,
    nil,
    "images/inventoryimages/personal_chest.xml",
    "personal_chest.tex"
)
AddMinimapAtlas("images/inventoryimages/personal_chest.xml")

-- 管理末影箱的建造数量
local old_BUILD = ACTIONS.BUILD.fn
ACTIONS.BUILD.fn = function(act)
    if not TheWorld.ismastersim then
        return old_BUILD(act)
    end
    local player = act.doer
    -- print("act.recipe is "..tostring(act.recipe))
    -- print("act.recipe.product is "..tostring(act.recipe.product))    nil这里有点奇怪
    -- print("act.doer is "..tostring(act.doer))
    -- print("act.doer.userid is "..tostring(act.doer.userid))
    
    if tostring(act.recipe) == "skull_chest" then        -- 有点不太一样
        -- print("start find!!!!!!!!")
        local skull_chest_count = 0        -- 统计建造者在世界上建造的末影箱数量
        local found_res = nil
        local found_dst = 99999999
        local x1, y1, z1 = player.Transform:GetWorldPosition()
        for k,v in pairs(Ents) do
            if v.prefab == "skull_chest" and v.ownerlist and v.ownerlist.master == player.userid then
                -- print("find")
                -- print("    v.owners is "..tostring(v.owners))
                skull_chest_count = skull_chest_count + 1
                
                local x2, y2, z2 = v.Transform:GetWorldPosition()
                local dst = math.sqrt((x1-x2)*(x1-x2)+(z1-z2)*(z1-z2))
                if dst < found_dst then        -- 找到更近的
                    found_res = v
                    found_dst = dst
                end
            end
        end
        -- print("end find!!!!!!!")
        
        if skull_chest_count >= SKULL_CHEST_MAX then    -- 建造数量不能超过SKULL_CHEST_MAX个
            player:DoTaskInTime(0.01, function()    -- 为什么延迟，因为官方会说: i cant do that
                if player.components and player.components.talker then
                    player.components.talker:Say("末影箱建造上限："..tostring(SKULL_CHEST_MAX))
                end
            end)
            return false
        end
        
        if found_dst < 8 then
            player:DoTaskInTime(0.01, function()
                if player.components and player.components.talker then
                    player.components.talker:Say("这里离我的另一个末影箱太近了！")
                end
            end)
            return false
        end
    end
    
    if tostring(act.recipe) == "personal_chest" then
        local personal_chest_count = 0
        for k,v in pairs(Ents) do
            if v.prefab == "personal_chest" and v.ownerlist and v.ownerlist.master == player.userid then    -- 这里试用防熊锁的ID
                personal_chest_count = personal_chest_count + 1
            end
        end
        
        if personal_chest_count >= PERSONAL_CHEST_MAX then        -- 建造超出数量了
            player:DoTaskInTime(0.01, function()
                if player.components and player.components.talker then
                    player.components.talker:Say("私人箱子建造上限："..tostring(PERSONAL_CHEST_MAX))
                end
            end)
            return false
        end
    end
    
    return old_BUILD(act)
end

-- 只有建造者才能拆除末影箱
local old_HAMMER = ACTIONS.HAMMER.fn
ACTIONS.HAMMER.fn = function(act)
    if act.doer:HasTag("beaver") then    -- 这个是海狸标签？
        return false
    end
    
    local player = act.doer
    -- print("start hammer!!!!!!!")
    if act.target and act.target.prefab == "skull_chest" then
        -- print("    hammer skull_chest!!!")
        -- print("    act.target.owners is "..tostring(act.target.owners))
        -- print("    act.doer.userid is "..tostring(act.doer.userid))
        if act.target.ownerlist and act.target.ownerlist.master ~= player.userid then
            player:DoTaskInTime(0.01, function()
                if player.components and player.components.talker then
                    player.components.talker:Say("这是别人建造的末影箱，我不能拆除")
                end
            end)
            return false
        end
    end
    
    if act.target and act.target.prefab == "personal_chest" then
        -- local personal_chest_count = 0
        if act.target.ownerlist and act.target.ownerlist.master ~= player.userid and not (player.Network and player.Network:IsServerAdmin()) then    -- 这里用防熊锁的ID
            player:DoTaskInTime(0.01, function()
                if player.components and player.components.talker then
                    player.components.talker:Say("这是别人的私人箱子，我不能拆！")
                end
            end)
            return false
        end
    end
    
    -- print("end hammer!!!!!!!")
    return old_HAMMER(act)
end

-- 不允许将东西放在别人的末影箱里
local old_STORE = ACTIONS.STORE.fn
ACTIONS.STORE.fn = function(act)
    local target = act.target
    local player = act.doer
    if target and target.prefab == "skull_chest" then
        if player and target.ownerlist and target.ownerlist.master ~= player.userid then
            player:DoTaskInTime(0.01, function()
                if player.components and player.components.talker then
                    player.components.talker:Say("这是别人的末影箱，我不能存东西进去")
                end
            end)
            return false
        end
    end
    
    return old_STORE(act)
end

-- 只有建造者才能打开
AddComponentPostInit("container", function(Container, target)
    local old_OpenFn = Container.Open
    function Container:Open(doer)
        -- print("start open!!!!!!!!")
        if target.prefab == "skull_chest" then
            -- print("    open skull_chest")
            -- print("    target is "..tostring(target))
            -- print("    doer is "..tostring(doer))
            -- print("    target.owners is "..tostring(target.owners))
            -- print("    doer.userid is "..tostring(doer.userid))
            if target and doer and target.ownerlist and target.ownerlist.master ~= doer.userid then
                doer.components.talker:Say("这是别人的末影箱，我无法打开")
                return false
            end
        end
        
        if target.prefab == "personal_chest" then
            -- print("    open skull_chest")
            -- print("    target is "..tostring(target))
            -- print("    doer is "..tostring(doer))
            -- print("    target.owners is "..tostring(target.owners))
            -- print("    doer.userid is "..tostring(doer.userid))
            if target and doer and target.ownerlist and target.ownerlist.master ~= doer.userid and not (doer.Network and doer.Network:IsServerAdmin()) then
                doer.components.talker:Say("这是别人的箱子，我无法打开")
                return false
            end
        end
        -- print("end open!!!!!")
        return old_OpenFn(self, doer)
    end
end)

-- 只有建造者才能魔法攻击
local old_CASTSPELL = ACTIONS.CASTSPELL.fn
ACTIONS.CASTSPELL.fn = function(act)
    local staff = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)        -- 如果施法的不是手部装备呢。。
    local act_pos = act:GetActionPoint()
    if         staff
        and staff.components.spellcaster
        and staff.components.spellcaster:CanCast(act.doer, act.target, act_pos)
        and act.target then
            -- print("start castspell!!!!!!!!")
            local player = act.doer
            if act.target.prefab == "skull_chest" then
                -- print("    castspell skull_chest")
                -- print("    act.target.owners is "..tostring(act.target.owners))
                -- print("    player.userid is "..tostring(player.userid))
                if act.target.ownerlist and act.target.ownerlist.master ~= player.userid then
                    player:DoTaskInTime(0.01, function()
                        if player.components and player.components.talker then
                            player.components.talker:Say("这是别人的末影箱，我不能这么做")
                        end
                    end)
                    return false
                end
            end
            
            if act.target.prefab == "personal_chest" then
                -- print("    castspell skull_chest")
                -- print("    act.target.owners is "..tostring(act.target.owners))
                -- print("    player.userid is "..tostring(player.userid))
                if act.target.ownerlist and act.target.ownerlist.master ~= player.userid and not (player.Network and player.Network:IsServerAdmin()) then
                    player:DoTaskInTime(0.01, function()
                        if player.components and player.components.talker then
                            player.components.talker:Say("这是别人的箱子，我不能这么做")
                        end
                    end)
                    return false
                end
            end
            -- print("end castspell!!!!!!!!")
        end
        
    return old_CASTSPELL(act)
end

-- 管理箱子的UI(不写则会出现客机无法加载开箱子的UI)
local containers = require "containers"

local params = {}

-- [[
-- 5*10 私人箱子
params.personal_chest = {
    widget = {
        slotpos = {},
        animbank = "ui_chest_5x10",        -- 箱子背景bank
        animbuild = "ui_chest_5x10",    -- 箱子背景build
        pos = Vector3(0, 160, 0),
        side_align_tip = 160,
    },
    type = "chest"
}

for y = 3.5, -0.5, -1 do    -- 这里设置每个格子在屏幕的坐标
    for x = -0, 9 do
        table.insert(params.personal_chest.widget.slotpos, Vector3(80 * x - 446 + 80, 80 * y - 80 * 2.5 + 83, 0))
    end
end
--]]

-- 5*5 末影箱
-- [[
params.skull_chest = {
    widget = {
        slotpos = {},
        animbank = "ui_chest_5x5",
        animbuild = "ui_chest_5x5",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
    type = "chest"
}

for y = 3, -1, -1 do
    for x = -1, 3 do
        table.insert(params.skull_chest.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end
--]]

local old_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
    local pref = prefab or container.inst.prefab
    if pref == "skull_chest" or pref == "personal_chest" then
        local t = params[pref]
        if t ~= nil then
            for k, v in pairs(t) do
                container[k] = v
            end
            container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
        end
    else
        return old_widgetsetup(container, prefab, data)
    end
end

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end

-- 挖树桩概率掉落树根
local function dropTreeRoot(player)
    player:ListenForEvent("finishedwork", function(player, data)
        local action = data and data.action or nil      -- 获取动作
        local target = data and data.target             -- 目标
        if not target then return end
        if action == ACTIONS.DIG and target:HasTag("tree") then
            -- print("try to drop treeroot")
            local x, y, z = target.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, 30, {"tree"})
            local trees = ents and #ents or 0           -- 附近树的数量
            local rootChance = 0.05 + 0.005*trees
            -- local rootChance = 1
            -- print("chance = "..rootChance)
            -- print("target position: "..x.."   "..y.."   "..z)
            if math.random() < rootChance then
                local root = target.components.lootdropper:SpawnLootPrefab("treeroot", Vector3(x, y, z))    -- 不加坐标会生成在0，0，0处
                -- local root = SpawnPrefab("treeroot")
                -- root.Transform:SetPosition(x, y, z)
                -- print("hit chance!")
            end
        end
    end)
end

AddPlayerPostInit(dropTreeRoot)
