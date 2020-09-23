-- 茶几永不坏
local conf_light = 1
local conf_flower = 1
local FLOWER_MAP =
{
	petals              = { flowerids = { 1, 2, 3, 4, 6, 10, 11, 12 } },
	lightbulb           = { flowerids = { 5, 7, 8 } },
	wormlight           = { flowerids = { 9 } },
	wormlight_lesser    = { flowerids = { 9 } },
}

local FLOWERID_MAP =
{
	'petals',
	'petals',
	'petals',
	'petals',
	'lightbulb',
	'petals',
	'lightbulb',
	'lightbulb',
	'wormlight',
	'petals',
	'petals',
	'petals',
}

local FLOWER_SWAPS =
{
	{ lightsource = false, sanityboost = TUNING.SANITY_TINY }, -- Rose
	{ lightsource = false, sanityboost = TUNING.SANITY_TINY },
	{ lightsource = false, sanityboost = TUNING.SANITY_TINY },
	{ lightsource = false, sanityboost = TUNING.SANITY_TINY },
	{ lightsource = true, sanityboost = 0 }, -- Lightbulb
	{ lightsource = false, sanityboost = TUNING.SANITY_TINY },
	{ lightsource = true, sanityboost = 0 }, -- Lightbulb
	{ lightsource = true, sanityboost = 0 }, -- Lightbulb
	{ lightsource = true, sanityboost = 0 }, -- Glowberry
	{ lightsource = false, sanityboost = TUNING.SANITY_TINY },
	{ lightsource = false, sanityboost = TUNING.SANITY_TINY },
	{ lightsource = false, sanityboost = TUNING.SANITY_TINY },
}

local function updatelight(inst)
	--local remaining = _G.GetTaskRemaining(inst.task) / TUNING.ENDTABLE_FLOWER_WILTTIME
	local remaining = 1
	inst.Light:SetRadius(1.5 + (1.5 * remaining))
	inst.Light:SetIntensity(0.4 + (0.4 * remaining))
	inst.Light:SetFalloff(0.8 + (1 - 1 * remaining))
end

local function setEternal(inst)
	-- light stays bright
	if conf_light == 1 and inst.lighttask ~= nil then
		inst.lighttask:Cancel()
		inst.lighttask = nil
	end

	if inst.task ~= nil then
		if (FLOWERID_MAP[inst.flowerid]=='petals' and conf_flower==1) or 
			(FLOWERID_MAP[inst.flowerid]~='petals' and conf_light==1) then 
			inst.task:Cancel()
			inst.task = nil
			inst.wilttime = TUNING.ENDTABLE_FLOWER_WILTTIME
		end
	end

	if inst.flowerid then
		if FLOWER_SWAPS[inst.flowerid].lightsource then
			if conf_light == 1 then
				inst.AnimState:SetLightOverride(0.3)
				inst.Light:Enable(true)
				updatelight(inst)
			end
		else
			if conf_flower == 1 then
				inst.AnimState:SetLightOverride(0)
				inst.Light:Enable(false)
			end
		end
	end
end

local function onsave(inst, data)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
		data.burnt = true
	elseif inst.flowerid ~= nil then
		data.flowerid = inst.flowerid
		if conf_flower == 1 then
			data.wilttime = TUNING.ENDTABLE_FLOWER_WILTTIME
		else
			if inst.task ~= nil then
				data.wilttime = GetTaskRemaining(inst.task)
			end
		end
	end
end

local function AddEternalFn3(inst)

	if not GLOBAL.TheWorld.ismastersim then
		return inst
	end

	inst:AddTag('eternal')
	if inst.components.vase then
		local old_ondecorate = inst.components.vase.ondecorate
		inst.components.vase.ondecorate = function(inst, giver, item)
			old_ondecorate(inst, giver, item)
			setEternal(inst)
		end
	end

	inst.OnSave = onsave 

	local old_onload = inst.OnLoad
	inst.OnLoad = function(inst, data)
		old_onload(inst, data)
		setEternal(inst)
	end
end
AddPrefabPostInit('endtable', AddEternalFn3)

-- 曼德拉复活
AddPrefabPostInit("mandrake",function(inst)
   if inst.components.tradable == nil then inst:AddComponent("tradable") end
end)
AddPrefabPostInit("greengem",function(inst)
   if inst.components.tradable == nil then inst:AddComponent("tradable") end
end)

AddPrefabPostInit("statueglommer", function (inst)
	if not GLOBAL.TheWorld.ismastersim then
		return inst
	end
	local function ItemTradeTest(inst,item)
		if item == nil then

			return false
		end
		--只接受曼德拉或绿宝石
		if item.prefab ~= "mandrake" and item.prefab ~= "greengem" then

			return false
		end
		--不重复接受曼德拉或绿宝石
		if item.prefab == "mandrake" and inst.components.accept_data.accept_mandrake >= 1 then 

			return false
		end
		if item.prefab == "greengem" and inst.components.accept_data.accept_greengem >= 1  then 

			return false
		end
		return true
	end
	
	--条件满足时在雕像附近生成曼德拉
	local function OnGemGiven(inst, giver, item)
		if item.prefab == "mandrake" and inst.components.accept_data then
			inst.components.accept_data.accept_mandrake =  1
			if inst.components.accept_data.accept_greengem == 1  then 
				local x, y, z = inst.Transform:GetWorldPosition()
				local x2 = math.random(-3,3)
				local y2 = math.random(-3,3)
				GLOBAL.SpawnPrefab("small_puff").Transform:SetPosition(x+x2, y, z+y2)
				GLOBAL.SpawnPrefab("collapse_small").Transform:SetPosition(x+x2, y, z+y2)
				local plant = SpawnPrefab("mandrake_planted")
				if plant then 
					plant.Transform:SetPosition(x+x2, y, z+y2) 
					inst.components.accept_data.accept_mandrake =  0 
					inst.components.accept_data.accept_greengem =  0
				end
			end
		end


		if inst.components.accept_data and item.prefab == "greengem"  then
			inst.components.accept_data.accept_greengem =  1
			if inst.components.accept_data.accept_mandrake == 1  then 
				local x, y, z = inst.Transform:GetWorldPosition()
				local x2 = math.random(-3,3)
				local y2 = math.random(-3,3)
				GLOBAL.SpawnPrefab("small_puff").Transform:SetPosition(x+x2, y, z+y2)
				GLOBAL.SpawnPrefab("collapse_small").Transform:SetPosition(x+x2, y, z+y2)
				local plant = SpawnPrefab("mandrake_planted")
				if plant then 
					plant.Transform:SetPosition(x+x2, y, z+y2) 
					inst.components.accept_data.accept_mandrake =  0 
					inst.components.accept_data.accept_greengem =  0     
				end
			end
		end
	end

	inst:AddComponent("accept_data")
	inst:AddComponent("trader")
	inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
	inst.components.trader.onaccept = OnGemGiven 

end)

-- 草蜥蜴不变异
TUNING.GRASSGEKKO_MORPH_CHANCE = 0
   
-- no more disease appearing
TUNING.DISEASE_CHANCE = 0
TUNING.DISEASE_DELAY_TIME = 0
TUNING.DISEASE_DELAY_TIME_VARIANCE = 0

local modmastersim = GLOBAL.TheNet:GetIsMasterSimulation()

if modmastersim then
	-- 草蜥蜴变草
	local function TurnIntoGrass(inst)
		local x, y, z = inst.Transform:GetWorldPosition()
		local grass = SpawnPrefab("grass")
		grass.Transform:SetPosition(x, y, z)
		inst:Remove()
	end
	local function DelaySwap(inst)
		inst:DoTaskInTime(0, TurnIntoGrass)
	end
	AddPrefabPostInit("grassgekko", DelaySwap)

	-- 治疗疾病
	local function TurnIntoNormal(inst)
		local x, y, z = inst.Transform:GetWorldPosition()
		local normal = SpawnPrefab(inst.prefab)
		normal.Transform:SetPosition(x, y, z)
		inst:Remove()
	end
	local function DelayCure(self)
		if self:IsDiseased() or self:IsBecomingDiseased() then
			self.inst:DoTaskInTime(0, TurnIntoNormal)
		end
	end
	AddComponentPostInit("diseaseable", DelayCure)
	
	--多枝树变小树枝
    --[[
	local Twiggys = 
	{
		"twiggytree",
		"twiggy_normal",
		"twiggy_tall",
		"twiggy_short",
		"twiggy_old",
		"twiggy_nut_sapling"
	}

	local function TurnIntoSapling(inst)
		local x, y, z = inst.Transform:GetWorldPosition()
		local sapling = SpawnPrefab("sapling")
		sapling.Transform:SetPosition(x, y, z)
		inst:Remove()
	end
	local function SaplingCure(inst)
		inst:DoTaskInTime(0, TurnIntoSapling)
	end
	for k, v in ipairs(Twiggys) do
		AddPrefabPostInit(v, SaplingCure)
	end
    --]]
end

-- 暖石无耐久
local old_TemperatureChange

local function new_TemperatureChange(inst, data)
	inst.components.fueled = {
		GetPercent = function() return 1 end,
		SetPercent = function() end,
	}
	old_TemperatureChange(inst, data)
	inst.components.fueled = nil
end

local function new_heatrock_fn(inst)
	if GLOBAL.TheWorld.ismastersim then
		inst:RemoveComponent("fueled")

		local function switchListenerFns(t)
			local listeners = t["temperaturedelta"]
			local listener_fns = listeners[inst]
			old_TemperatureChange = listener_fns[1]
			listener_fns[1] = new_TemperatureChange
		end

		switchListenerFns(inst.event_listeners)
		switchListenerFns(inst.event_listening)
	end
end
AddPrefabPostInit("heatrock", new_heatrock_fn)

--锤子攻击力
TUNING.HAMMER_DAMAGE = 2.7

--物品堆叠
TUNING.STACK_SIZE_LARGEITEM = 40
TUNING.STACK_SIZE_MEDITEM = 40
TUNING.STACK_SIZE_SMALLITEM = 40

--灭火器燃料
TUNING.FIRESUPPRESSOR_MAX_FUEL_TIME = 12000

-- 眼球塔生命值加强
TUNING.EYETURRET_HEALTH = 5000

-- 月台附近刷鱼缸
AddPrefabPostInit("moonbase",function(inst)
	if not TheWorld.ismastersim then
		return inst
	end
	if not GLOBAL.TheNet:GetIsClient() then		-- 这个条件有必要吗
		inst:AddComponent("chestmark")
		inst.mod_chestmark = inst:DoTaskInTime(6, function()
			local x, y, z = inst.Transform:GetWorldPosition()
			if x and y and z and inst.components.chestmark and inst.components.chestmark.mark ~= true then
				local hutch_fishbowl = SpawnPrefab("hutch_fishbowl")
				if hutch_fishbowl then
					hutch_fishbowl.Transform:SetPosition(x+math.random(-12,12), y, z+math.random(-12,12))
					inst.components.chestmark.mark = true
				end
			end
		end)
	end
end)

-- 浣猫掉落巧克力
local function catcoonfn(inst)
	if not TheWorld.ismastersim then
		return inst
	end
	
	inst.components.lootdropper:AddChanceLoot("cave_chocolate", .4)
end
AddPrefabPostInit('catcoon', catcoonfn)

--冰箱
TUNING.PERISH_FRIDGE_MULT = 0
TUNING.PERISH_MUSHROOM_LIGHT_MULT = 0 -- 蘑菇灯的腐烂速度也修改

-- 浆果丛、草根、树枝根制造
AddRecipe("dug_berrybush2",
    {
        Ingredient("goldnugget",1),
        Ingredient("dug_berrybush",1),
        Ingredient("poop", 1),
    },
    RECIPETABS.REFINE,
    TECH.LOST
)

AddRecipe("dug_berrybush_juicy",
    {
        Ingredient("goldnugget",1),
        Ingredient("dug_berrybush2",1),
        Ingredient("poop", 1),
    },
    RECIPETABS.REFINE,
    TECH.LOST
)

AddRecipe("dug_berrybush",
    {
        Ingredient("goldnugget",1),
        Ingredient("dug_berrybush_juicy",1),
        Ingredient("poop", 1),
    },
    RECIPETABS.REFINE,
    TECH.LOST
)

AddRecipe("dug_berrybush_1",      -- 这里和上面的科技栏不同,然而就算科技栏不同也会冲突,修改配方名字就行了
    {
        Ingredient("treeroot",1, "images/inventoryimages/treeroot.xml", false, "treeroot.tex"),
        Ingredient("livinglog",1),
        Ingredient("goldnugget",3),
    },
    RECIPETABS.FARM,    -- tab          -- 
    TECH.SCIENCE_TWO,   -- level
    nil,                -- placer
    nil,                -- min_spacing
    false,              -- nounlock
    2,                  -- numtogive
    nil,                -- builder_tag
    nil,-- atlas
    "dug_berrybush.tex",-- image
    nil,                -- testfn
    "dug_berrybush"     -- product
)

AddRecipe("dug_grass",
    {
        Ingredient("treeroot",1, "images/inventoryimages/treeroot.xml", false, "treeroot.tex"),
        Ingredient("livinglog",1),
        Ingredient("goldnugget",3),
    },
    RECIPETABS.FARM,
    TECH.SCIENCE_TWO,
    nil,
    nil,
    false,
    2
)

AddRecipe("dug_sapling",
    {
        Ingredient("treeroot",1, "images/inventoryimages/treeroot.xml", false, "treeroot.tex"),
        Ingredient("livinglog",1),
        Ingredient("goldnugget",3),
    },
    RECIPETABS.FARM,
    TECH.SCIENCE_TWO,
    nil,
    nil,
    false,
    2
)

-- 浆果丛图纸掉落
AddPrefabPostInit("perd",function(inst)
	inst:ListenForEvent("death", function()
		inst.components.lootdropper:AddChanceLoot("dug_berrybush_blueprint", 0.1)
		inst.components.lootdropper:AddChanceLoot("dug_berrybush2_blueprint", 0.1)
		inst.components.lootdropper:AddChanceLoot("dug_berrybush_juicy_blueprint", 0.1)
	end)
end)

-- 荧光果新鲜度去除
AddPrefabPostInit("lightbulb", function(inst)
	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:RemoveComponent("perishable")
end)

-- 新月刷新坟墓
AddPrefabPostInit("mound", function(inst)
	-- 获取之前的onfinishcallback函数
	local onfinishcallback = GetUpvalueHelper(require("prefabs/mound").fn, "onfinishcallback")

	local function onnewmoon(inst, isnewmoon)
		if isnewmoon then		-- 新月时
			if inst.components.workable ~= nil then
				return			-- 没有挖掘则不变
			end
			inst.AnimState:PlayAnimation("gravedirt")

			inst:AddComponent("workable")
			inst.components.workable:SetWorkAction(ACTIONS.DIG)
			inst.components.workable:SetWorkLeft(1)
			inst.components.workable:SetOnFinishCallback(onfinishcallback)
		end
	end

	inst:WatchWorldState("isnewmoon", onnewmoon)
end)

-- 大理石苗可用书催熟
local marble_list = {
	"marbleshrub",
	"marbleshrub_short",
	"marbleshrub_normal",
	"marbleshrub_tall"
}
for _,v in pairs(marble_list) do
	AddPrefabPostInit(v, function(inst)
		-- inst:AddTag("tree")
		
		---[[	-- 虽然两种方法都可以，但是...鬼知道tree标签还有什么其他的作用......
		if not TheWorld.ismastersim then
			return inst
		end
		
		inst.components.growable.magicgrowable = true
		--]]
	end)
end

-- 盐箱缓慢反鲜
TUNING.PERISH_SALTBOX_MULT = -0.5