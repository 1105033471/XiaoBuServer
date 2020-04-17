GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})


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
		table.insert(taskset.tasks, "The hunters")		-- 世界生成的基本任务中加入生成海象平原任务
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

AddTaskPreInit("MoonIsland_Mine", function(task)    -- 将对应的room加入task中，出现这个task时就肯定有这个room出现
	task.room_choices["FountainPatch"] = 1	-- 月岛矿区附近出现喷泉
	task.room_choices["PlantPatch"] = 2		-- 植物群
end)