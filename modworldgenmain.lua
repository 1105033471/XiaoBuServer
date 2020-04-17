GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})


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
		table.insert(taskset.tasks, "The hunters")		-- �������ɵĻ��������м������ɺ���ƽԭ����
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

AddTaskPreInit("MoonIsland_Mine", function(task)    -- ����Ӧ��room����task�У��������taskʱ�Ϳ϶������room����
	task.room_choices["FountainPatch"] = 1	-- �µ���������������Ȫ
	task.room_choices["PlantPatch"] = 2		-- ֲ��Ⱥ
end)