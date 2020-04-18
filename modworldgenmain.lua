GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

modimport("tile_adder.lua")
--[[
    上面的文件是从Turfed(514078314)里copy过来的，因为作者封装了一些非常不错的接口
    本来官方应该提供这些接口，但是官方注释掉了，不知道为啥。。。
    (也许这些接口来自单机？)
]]

local function AddTriple(taskset)
    -- 地上为forest，地下为cave，还包括暴食活动quagmire和熔炉lavaarena
    if taskset.location ~= "forest" then
        return
    end
    -- The hunters为海象平原的地形名字
    local has_triple = false
    for _,i in pairs(taskset.tasks) do
        if i == "The hunters" then
            has_triple = true
            break
        end
    end
    if not has_triple then
        table.insert(taskset.tasks, "The hunters")        -- 世界生成的基本任务中加入生成海象平原任务
    end
    
    -- 移除随机生成的海象平原，因为已经必定生成了
    for index,i in pairs(taskset.optionaltasks) do
        if i == "The hunters" then
            table.remove(taskset.optionaltasks, index)
            taskset.numoptionaltasks = taskset.numoptionaltasks - 1
            break
        end
    end
end

-- 修改TaskSet的接口
AddTaskSetPreInitAny(AddTriple)

require("map/tasks")			-- 获取地图生成的相关模块
local LAYOUTS = require("map/layouts").Layouts
local STATICLAYOUT = require("map/static_layout")

LAYOUTS["Fountains"] = STATICLAYOUT.Get("map/static_layouts/fountains")   --引用一种固定格式的地形，但是在哪调用呢？(在Room中)

require("map/rooms/forest/rooms_fountains")   --引入一种room的文件，范围内随机分布

-- AddTaskPreInit("MoonIsland_Mine", function(task)    -- 将对应的room加入task中，出现这个task时就肯定有这个room出现
    -- task.room_choices["FountainPatch"] = 1    -- 月岛矿区附近出现喷泉
    -- task.room_choices["PlantPatch"] = 2        -- 植物群
-- end)

AddTask("FountainIsland", {     -- 与其加进官方的task，不如自己做一个？
    locks = {LOCKS.ISLAND_TIER2},
    keys_given={KEYS.ISLAND_TIER3},
    region_id = "fountain_island",
    -- level_set_piece_blocker = true,
    -- room_tags = {"RoadPoison", "moonhunt", "nohasslers", "lunacyarea", "not_mainland"},
    room_tags = {"RoadPoison", "not_mainland"},     -- 没有这个，岛上会有Road
    -- entrance_room = "MoonIsland_Blank",
    room_choices =
    {
        -- ["MoonIsland_Beach"] = 2,
        ["FountainPatch"] = 1,
        ["PlantPatch"] = 2,
    },
    room_bg = GROUND.MUD,
    background_room = "Blank",
    cove_room_name = "Blank",
    cove_room_chance = 1,
    make_loop = false,
    crosslink_factor = 1,
    cove_room_max_edges = 2,
    colour={r=0.6,g=0.6,b=0.0,a=1},
})

AddLevelPreInitAny(function(level)      -- 添加岛屿的代码啊啊！！！记笔记记笔记
    if level.location ~= "forest" then  -- 不为地上则无动作
        return
    end
    table.insert(level.tasks, "FountainIsland")     -- 将定义好的task加进地上的level中
end)
-- sounds names taken from base tile types in worldtiledefs.lua
local sound_run_dirt = "dontstarve/movement/run_dirt"
local sound_run_marsh = "dontstarve/movement/run_marsh"
local sound_run_tallgrass = "dontstarve/movement/run_tallgrass"     -- 高草地，听起来还不错
local sound_run_forest = "dontstarve/movement/run_woods"            -- 森林地皮
local sound_run_grass = "dontstarve/movement/run_grass"             -- 草地地皮
local sound_run_wood = "dontstarve/movement/run_wood"               -- 木制地板
local sound_run_marble = "dontstarve/movement/run_marble"           -- 大理石地皮
local sound_run_carpet = "dontstarve/movement/run_carpet"           -- 地毯
local sound_run_moss = "dontstarve/movement/run_moss"               -- 苔藓
local sound_run_mud = "dontstarve/movement/run_mud"                 -- 泥泞

local sound_walk_dirt = "dontstarve/movement/walk_dirt"
local sound_walk_marsh = "dontstarve/movement/walk_marsh"
local sound_walk_tallgrass = "dontstarve/movement/walk_tallgrass"
local sound_walk_forest = "dontstarve/movement/walk_woods"
local sound_walk_grass = "dontstarve/movement/walk_grass"
local sound_walk_wood = "dontstarve/movement/walk_wood"
local sound_walk_marble = "dontstarve/movement/walk_marble"
local sound_walk_carpet = "dontstarve/movement/walk_carpet"
local sound_walk_moss = "dontstarve/movement/walk_moss"
local sound_walk_mud = "dontstarve/movement/walk_mud"

local sound_ice = "dontstarve/movement/run_ice"
local sound_snow = "dontstarve/movement/run_snow"

local isflooring = false        -- 为true代表不可种植

local speed_players = {         -- affect only non-ghost players(只对活着的玩家生效的参数)
    {"player,!playerghost", 0},
}

local speed_players_groundmobs = { -- affect non-ghost players and ground-walking mobs(对活着的玩家和能在地上走的生物生效)
    {"player,!playerghost", 0},
    {"!player,!ghost,!flying,!mole,!shadow,!shadowhand,!worm,!%tumbleweed", 0},
    -- !ghost for abigail and ghosts, !flying for bats etc., !mole for mole, !shadow for shadow creatures, !shadowhand for shadowhands, !worm for worm, !%tumbleweed for tumbleweed
    -- note: although bees, butterflies and mosquitos have flying tag, they don't evaluate the tile type they are currently on at all due to their inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    --    similar with mushtree spores (but without the flying tag part)
}

local turfed_default = {        -- 地皮默认参数
    insulationWinterMult = 1,
    insulationWinterAdd = 0,        -- 保暖效果
    insulationSummerMult = 1,
    insulationSummerAdd = 0,        -- 隔热效果
    sanityMult = 1,
    sanityAdd = 0,                  -- 回SAN效果
    moistureMult = 0,
    speedMult = 1,
    speedAdd = 0,                   -- 加速效果
    speed = speed_players,          -- 加速效果生效对象
}

AddTile(        -- 添加地皮
    "PIGRUINS",           -- id, GROUND里的名字
    69,                     -- numerical_id 地皮编号
    "pigruins",           -- name,地皮名字--levels/tiles/目录下的文件名？
    {
        name = "pigruins",    -- real_name, 这里可以覆盖上面的name(要和GROUND里的名字、图片名字一致，否则有问题)
        noise_texture = "levels/textures/noise_pigruins.tex",     -- 放置很多块地板的图片
        runsound = sound_run_tallgrass,                  -- run 的声音
        walksound = sound_walk_tallgrass,                -- walk 的声音
        snowsound = sound_snow,                     -- 有snow时走路的声音
        turfed = turfed_default,                    -- turf的基本属性
    },
    {
        noise_texture = "levels/textures/mini_noise_pigruins.tex",     -- 放置1块地板的图片
    },
    false           -- 是否为人造地板（人造地板不可种植）
)

ChangeTileTypeRenderOrder(GLOBAL.GROUND.WOODFLOOR, GLOBAL.GROUND.PIGRUINS)    -- 修改地皮的顺序，前面 < 后面
