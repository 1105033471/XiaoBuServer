AddRoom("FountainPatch", 
{
	colour = {r=.8,g=.2,b=.8,a=.50}, 
	value = GROUND.MUD,	-- 地皮类型
	-- tags = {"ExitPiece", "Chester_Eyebone"},
	contents =  
	{
		countprefabs =	--必定会出现对应数量的物品的表
		{
			-- pugalisk_fountain = function () return 1 end,	-- 喷泉(标志性建筑)
		},
		countstaticlayouts = {		-- static_layout在这里调用
			["Fountains"] = 1,	-- 为什么static_layout里不加载物品，因为prefab名字要写在type里而不是name里
			["MushroomRingLarge"] = 0.6,
			["LivingTree"] = 0.3,
		},
		distributepercent = 0.2,	--distributeprefabs中物品的区域密集程度
		distributeprefabs =	--物品的数量分布比例
		{
            fireflies = 0.1,
			flower = 0.5,
			flower_rose = 0.03,
			-- deciduoustree = 0.52,
			-- catcoonden = 0.05,
			-- pond = 0.05,
			evergreen = 0.15,
			red_mushroom = 0.21,
			green_mushroom = 0.21,
			blue_mushroom = 0.21,
			berrybush=.03,
			berrybush_juicy = 0.015,
			carrat_planted = 0.21,
			carrot_planted = 0.21,
			sweet_potato_planted = 0.21,
			sapling = 0.2,
			grass = 0.2,
			beehive=.05,
		},
	}
})

AddRoom("PlantPatch", 
{
	colour = {r=.8,g=.2,b=.8,a=.50}, 
	value = GROUND.QUAGMIRE_GATEWAY,	-- 地皮类型
	tags = {"ExitPiece", "Chester_Eyebone"},
	contents =  
	{
		countprefabs =	--必定会出现对应数量的物品的表
		{
			sweet_potato_planted = function () return 10 end,	-- 喷泉(标志性建筑)
		},
		countstaticlayouts = {		-- static_layout在这里调用
			["MushroomRingLarge"] = 0.6,
			["LivingTree"] = 0.4,
		},
		distributepercent = 0.4,	--distributeprefabs中物品的区域密集程度
		distributeprefabs =	--物品的数量分布比例
		{
            -- fireflies = 0.1,
			flower = 0.5,
			flower_rose = 0.03,
			-- deciduoustree = 0.52,
			-- catcoonden = 0.05,
			-- pond = 0.05,
			evergreen = 0.15,
			red_mushroom = 0.21,
			green_mushroom = 0.21,
			blue_mushroom = 0.21,
			berrybush=.03,
			berrybush_juicy = 0.015,
			carrat_planted = 0.21,
			carrot_planted = 0.21,
			sweet_potato_planted = 0.21,
			sapling = 0.2,
			grass = 0.2,
			beehive=.05,
		},
	}
})