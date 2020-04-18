GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

local strength_monster = GetModConfigData("strength_monster")

-- 设置随机数种子
math.randomseed(tostring(os.time()):reverse():sub(1, 7))

PrefabFiles = {
    "lajidai",
    "altar_placer",
    "cave_chocolate", -- 巧克力
}

Assets = {
    Asset("ATLAS", "images/inventoryimages/altar.xml"),
    Asset("ANIM", "anim/altar.zip"),
    Asset("ATLAS", "images/inventoryimages/cave_chocolate.xml"),
    
    Asset("SOUNDPACKAGE", "sound/dontstarve_DLC003.fev"),
}
AddMinimapAtlas("images/inventoryimages/altar.xml")

modimport("scripts/allstrings.lua")                     -- 所有描述
modimport("scripts/godweapon.lua")                      -- 神器
modimport("scripts/others.lua")                         -- 其他杂项
modimport("scripts/pighousetrader.lua")                 -- 猪窝可交易
modimport("scripts/stack.lua")                          -- 自动堆叠
modimport("scripts/clean.lua")                          -- 自动清理
modimport("scripts/lab2trash.lua")                      -- 二本垃圾桶
modimport("scripts/magic_oasislake.lua")                -- 神奇沙漠湖
modimport("scripts/morehats.lua")                       -- 帽子升级
modimport("scripts/coffee.lua")                         -- 咖啡
modimport("scripts/minglock.lua")                       -- 防熊锁
modimport("scripts/wormholemark.lua")                   -- 虫洞标记
modimport("scripts/extraequipslot.lua")                 -- 额外装备栏
modimport("scripts/transplant.lua")                     -- 移植
modimport("scripts/flowerbox.lua")                      -- 花盒
modimport("scripts/hamlets.lua")                        -- 哈姆雷特物品
modimport("scripts/usefulboats.lua")                    -- 更实用的船
modimport("scripts/shadowbox.lua")                      -- 末影箱
modimport("scripts/extraturf.lua")                      -- 额外的地皮
modimport("scripts/moon.lua")                           -- 月岛物品

--生物加强
if strength_monster then
    modimport("scripts/strengthen.lua")
    -- modimport("scripts/strengthen_spider.lua")
end
