local prefabfiles = {
    "sharkitten",           -- 小虎鲨
    "shark_gills",          -- 虎鲨皮
    "shark_fin",            -- 虎鲨鳍
    "fish_raw",             -- 大鱼肉
    "sharkittenspawner",    -- 小虎鲨刷新点
    "tigershark",           -- 虎鲨
    "tigereye",             -- 虎鲨之眼
    "tigersharkshadow",     -- fx
}

for _,v in pairs(prefabfiles) do
    table.insert(PrefabFiles, v)
end

local assets = {
    Asset("ATLAS", "images/inventoryimages/shark_gills.xml"),
    Asset("ATLAS", "images/inventoryimages/shark_fin.xml"),
    Asset("ATLAS", "images/inventoryimages/fish_raw.xml"),
    Asset("ATLAS", "images/inventoryimages/fish_med_cooked.xml"),
    
    Asset("SOUNDPACKAGE", "sound/volcano.fev"),
    Asset("SOUNDPACKAGE", "sound/dontstarve_DLC002.fev"),
    Asset("SOUND", "sound/volcano.fsb"),
}

for _,v in pairs(assets) do
    table.insert(Assets, v)
end

TUNING.SHARKITTEN_SPEED_WALK = 4    -- 小虎鲨移动速度
TUNING.SHARKITTEN_SPEED_RUN = 5     -- 小虎鲨移动速度
TUNING.SHARKITTEN_HEALTH = 300      -- 小虎鲨血量

AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("tigersharker")
end)

-- 中毒！
local function poinson(player)
    if player.components and player.components.health then
        player.components.health:DoDelta(-2)
    end
end

AddPlayerPostInit(function(player)
    if not TheWorld.ismastersim then
        return player
    end
    
    player:DoPeriodicTask(1, function()     -- 每秒检测一次
        if player.components.areaaware and player.components.areaaware:CurrentlyInTag("poinsonLand") and not player:HasTag("Detoxification") then
            if player.poinsontask == nil then
                player.poinsontask = player:DoPeriodicTask(4, poinson)
                player.components.talker:Say("我得赶快离开！")
            end
            --print("is poinsoning, player:"..tostring(player))
        else
            if player.poinsontask ~= nil then
                player.poinsontask:Cancel()
                player.poinsontask = nil
            end
            --print("is not poinsoning, player:"..tostring(player))
        end
    end)
end)

-- 虎鲨的feed 动作添加
AddAction(
    "TIGERSHARK_FEED",
    "Tigershark Feed",
    function(act)
        local doer = act.doer
        if doer and doer.components.lootdropper then
            doer.components.lootdropper:SpawnLootPrefab("wetgoop")
        end
    end
)