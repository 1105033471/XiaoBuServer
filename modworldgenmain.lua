GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

modimport("tile_adder.lua")
--[[
    ������ļ��Ǵ�Turfed(514078314)��copy�����ģ���Ϊ���߷�װ��һЩ�ǳ�����Ľӿ�
    �����ٷ�Ӧ���ṩ��Щ�ӿڣ����ǹٷ�ע�͵��ˣ���֪��Ϊɶ������
    (Ҳ����Щ�ӿ����Ե�����)
]]

local function AddTriple(taskset)
    -- ����Ϊforest������Ϊcave����������ʳ�quagmire����¯lavaarena
    if taskset.location ~= "forest" then
        return
    end
    -- The huntersΪ����ƽԭ�ĵ�������
    local has_triple = false
    for _,i in pairs(taskset.tasks) do
        if i == "The hunters" then
            has_triple = true
            break
        end
    end
    if not has_triple then
        table.insert(taskset.tasks, "The hunters")        -- �������ɵĻ��������м������ɺ���ƽԭ����
    end
    
    -- �Ƴ�������ɵĺ���ƽԭ����Ϊ�Ѿ��ض�������
    for index,i in pairs(taskset.optionaltasks) do
        if i == "The hunters" then
            table.remove(taskset.optionaltasks, index)
            taskset.numoptionaltasks = taskset.numoptionaltasks - 1
            break
        end
    end
end

-- �޸�TaskSet�Ľӿ�
AddTaskSetPreInitAny(AddTriple)

require("map/tasks")			-- ��ȡ��ͼ���ɵ����ģ��
local LAYOUTS = require("map/layouts").Layouts
local STATICLAYOUT = require("map/static_layout")

LAYOUTS["Fountains"] = STATICLAYOUT.Get("map/static_layouts/fountains")   --����һ�̶ֹ���ʽ�ĵ��Σ��������ĵ����أ�(��Room��)

require("map/rooms/forest/rooms_fountains")   --����һ��room���ļ�����Χ������ֲ�

-- AddTaskPreInit("MoonIsland_Mine", function(task)    -- ����Ӧ��room����task�У��������taskʱ�Ϳ϶������room����
    -- task.room_choices["FountainPatch"] = 1    -- �µ���������������Ȫ
    -- task.room_choices["PlantPatch"] = 2        -- ֲ��Ⱥ
-- end)

AddTask("FountainIsland", {     -- ����ӽ��ٷ���task�������Լ���һ����
    locks = {LOCKS.ISLAND_TIER2},
    keys_given={KEYS.ISLAND_TIER3},
    region_id = "fountain_island",
    -- level_set_piece_blocker = true,
    -- room_tags = {"RoadPoison", "moonhunt", "nohasslers", "lunacyarea", "not_mainland"},
    room_tags = {"RoadPoison", "not_mainland"},     -- û����������ϻ���Road
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

AddLevelPreInitAny(function(level)      -- ��ӵ���Ĵ��밡���������ǱʼǼǱʼ�
    if level.location ~= "forest" then  -- ��Ϊ�������޶���
        return
    end
    table.insert(level.tasks, "FountainIsland")     -- ������õ�task�ӽ����ϵ�level��
end)
-- sounds names taken from base tile types in worldtiledefs.lua
local sound_run_dirt = "dontstarve/movement/run_dirt"
local sound_run_marsh = "dontstarve/movement/run_marsh"
local sound_run_tallgrass = "dontstarve/movement/run_tallgrass"     -- �߲ݵأ�������������
local sound_run_forest = "dontstarve/movement/run_woods"            -- ɭ�ֵ�Ƥ
local sound_run_grass = "dontstarve/movement/run_grass"             -- �ݵص�Ƥ
local sound_run_wood = "dontstarve/movement/run_wood"               -- ľ�Ƶذ�
local sound_run_marble = "dontstarve/movement/run_marble"           -- ����ʯ��Ƥ
local sound_run_carpet = "dontstarve/movement/run_carpet"           -- ��̺
local sound_run_moss = "dontstarve/movement/run_moss"               -- ̦޺
local sound_run_mud = "dontstarve/movement/run_mud"                 -- ��Ţ

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

local isflooring = false        -- Ϊtrue��������ֲ

local speed_players = {         -- affect only non-ghost players(ֻ�Ի��ŵ������Ч�Ĳ���)
    {"player,!playerghost", 0},
}

local speed_players_groundmobs = { -- affect non-ghost players and ground-walking mobs(�Ի��ŵ���Һ����ڵ����ߵ�������Ч)
    {"player,!playerghost", 0},
    {"!player,!ghost,!flying,!mole,!shadow,!shadowhand,!worm,!%tumbleweed", 0},
    -- !ghost for abigail and ghosts, !flying for bats etc., !mole for mole, !shadow for shadow creatures, !shadowhand for shadowhands, !worm for worm, !%tumbleweed for tumbleweed
    -- note: although bees, butterflies and mosquitos have flying tag, they don't evaluate the tile type they are currently on at all due to their inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    --    similar with mushtree spores (but without the flying tag part)
}

local turfed_default = {        -- ��ƤĬ�ϲ���
    insulationWinterMult = 1,
    insulationWinterAdd = 0,        -- ��ůЧ��
    insulationSummerMult = 1,
    insulationSummerAdd = 0,        -- ����Ч��
    sanityMult = 1,
    sanityAdd = 0,                  -- ��SANЧ��
    moistureMult = 0,
    speedMult = 1,
    speedAdd = 0,                   -- ����Ч��
    speed = speed_players,          -- ����Ч����Ч����
}

AddTile(        -- ��ӵ�Ƥ
    "PIGRUINS",           -- id, GROUND�������
    69,                     -- numerical_id ��Ƥ���
    "pigruins",           -- name,��Ƥ����--levels/tiles/Ŀ¼�µ��ļ�����
    {
        name = "pigruins",    -- real_name, ������Ը��������name(Ҫ��GROUND������֡�ͼƬ����һ�£�����������)
        noise_texture = "levels/textures/noise_pigruins.tex",     -- ���úܶ��ذ��ͼƬ
        runsound = sound_run_tallgrass,                  -- run ������
        walksound = sound_walk_tallgrass,                -- walk ������
        snowsound = sound_snow,                     -- ��snowʱ��·������
        turfed = turfed_default,                    -- turf�Ļ�������
    },
    {
        noise_texture = "levels/textures/mini_noise_pigruins.tex",     -- ����1��ذ��ͼƬ
    },
    false           -- �Ƿ�Ϊ����ذ壨����ذ岻����ֲ��
)

ChangeTileTypeRenderOrder(GLOBAL.GROUND.WOODFLOOR, GLOBAL.GROUND.PIGRUINS)    -- �޸ĵ�Ƥ��˳��ǰ�� < ����
