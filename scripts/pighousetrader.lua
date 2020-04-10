local acceptPrefabs = {
	"goldnugget",	-- 金子
	
	"redgem",		-- 红宝石
	"bluegem",		-- 蓝宝石
	"purplegem",	-- 紫宝石
	
	"orangegem",	-- 橙宝石
	"yellowgem",	-- 黄宝石
	"greengem",		-- 绿宝石
}
--添加交易属性
for k, v in pairs(acceptPrefabs) do
	AddPrefabPostInit(v, function(inst)
		if inst.components.tradable == nil then
			inst:AddComponent("tradable")
		end
	end)
end
--检验value是否在tb中
local function InTable(tb, value)
	if tb == nil then
		return false
	end
		
	for k, v in pairs(tb) do
		if v == value then 
			return true
		end
	end
	
	return false
end

AddPrefabPostInit("pighouse", function (inst)
	if not GLOBAL.TheWorld.ismastersim then
		return inst
	end
	local function ItemTradeTest(inst,item)
		if item == nil then
			return false
		end
		
		if InTable(acceptPrefabs, item.prefab) then
			return true
		end
		
		return false
	end
	
	--给予随机物品
	local function OnGiven(inst, giver, item)
		local pt = giver:GetPosition()
				
		itemList1 = {
			"goldnugget",	--金子
		}
		
		itemList2 = {
			"redgem",		--红宝石
			"bluegem",		--蓝宝石
			"purplegem",	--紫宝石
		}
		
		itemList3 = {
			"orangegem",	-- 橙宝石
			"yellowgem",	-- 黄宝石
			"greengem",		-- 绿宝石
		}
		
		-- 判断玩家是否有小偷包
		local has_krampus_sack = false
		local krampus_sack_chance = 0.2		-- 有小偷包之后的掉落概率
		for k,v in pairs(giver.components.inventory.equipslots) do
			if v.prefab == "krampus_sack" then
				has_krampus_sack = true
				-- print(" i have a krampus_sack ")
				break
			end
		end
		
		-- 生成物品
		local function spawnItem(item, number, level)
			local num = 0
			while num < number do
				itemEntity = SpawnPrefab(item)
				
				local theta = math.random() * 2 * PI
				local radius = math.random(5,6)
				
				local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
					local pos = pt + offset
					-- NOTE: The first search includes invisible entities
					return #TheSim:FindEntities(pos.x, 0, pos.z, 1, nil, { "INLIMBO", "FX" }) <= 0
						and TheWorld.Map:IsPassableAtPoint(pos:Get())
						and TheWorld.Map:IsDeployPointClear(pos, nil, 1)
				end)
				
				-- 如果找不到位置生成，则使用默认值
				if result_offset == nil then
					result_offset = {x = 2, y = 0, z = 2}
				end
				
				-- 如果为怪物，设置默认攻击对象
				if level > 1 then
					itemEntity.components.combat:SuggestTarget(giver)
				end
				
				-- 设置物品坐标
				itemEntity.Transform:SetPosition(pt.x + result_offset.x, 0, pt.z + result_offset.z)
				
				-- 设置生成物品的动画效果
				if level <= 2 then
					SpawnPrefab("collapse_small").Transform:SetPosition(pt.x + result_offset.x, 0, pt.z + result_offset.z)
				elseif level == 3 then
					SpawnPrefab("werebeaver_transform_fx").Transform:SetPosition(pt.x + result_offset.x, 0, pt.z + result_offset.z)
				else
					SpawnPrefab("werebeaver_shock_fx").Transform:SetPosition(pt.x + result_offset.x, 0, pt.z + result_offset.z)
				end
				num = num + 1
			end
		end
		
		-- 第一类物品
		-- 20%给猪皮，同时生成1只蜘蛛
		-- 20%给大肉，同时生成1只蜘蛛
		-- 20%给大便，同时生成1只蜘蛛
		-- 20%给小肉，同时生成1只蜘蛛
		-- 20%给月石
		if InTable(itemList1, item.prefab) then
			--判定物品的随机数
			local num = math.random(0,10)
			---[[
			if num > 8 then
				inst:DoTaskInTime(math.random(), function () spawnItem("pigskin", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("spider", 1, 2) end)
			elseif num > 6 then
				inst:DoTaskInTime(math.random(), function () spawnItem("meat", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("spider", 1, 2) end)
			elseif num > 4 then
				inst:DoTaskInTime(math.random(), function () spawnItem("poop", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("spider", 1, 2) end)
			elseif num > 2 then
				inst:DoTaskInTime(math.random(), function () spawnItem("smallmeat", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("spider", 1, 2) end)
			else
				inst:DoTaskInTime(math.random(), function () spawnItem("moonrocknugget", 1, 1) end)
			end
			--]]
		end
		
		-- 第二类物品
		-- 30%给1个礼物包裹
		-- 15%给生命护符，同时生成1只鬼魂
		-- 10%给2个冰块
		-- 10%给传送魔杖，同时生成4只蝙蝠
		-- 10%给齿轮gears，同时生成2只暴躁猴
		-- 9%给冰魔杖
		-- 5%给蘑菇皮，同时生成1只蠕虫
		-- 5%给多肉球茎
		-- 5%给曼德拉草，同时生成1只暗影骑士
		-- 1%给小偷包，同时生成1只钢羊spat
		if InTable(itemList2, item.prefab) then
			local num = math.random(0, 100)
			---[[
			if num > 70 then
				inst:DoTaskInTime(math.random(), function () spawnItem("giftwrap", 1, 1) end)
			elseif num > 55 then
				inst:DoTaskInTime(math.random(), function () spawnItem("amulet", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("ghost", 1, 2) end)
			elseif num > 45 then
				inst:DoTaskInTime(math.random(), function () spawnItem("ice", 2, 1) end)
			elseif num > 35 then
				inst:DoTaskInTime(math.random(), function () spawnItem("icestaff", 1, 1) end)
			elseif num > 25 then
				inst:DoTaskInTime(math.random(), function () spawnItem("telestaff", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("bat", 4, 2) end)
			elseif num > 16 then
				inst:DoTaskInTime(math.random(), function () spawnItem("gears", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("monkey", 2, 2) end)
			elseif num > 11 then
				inst:DoTaskInTime(math.random(), function () spawnItem("shroom_skin", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("worm", 1, 3) end)
			elseif num > 6 then
				inst:DoTaskInTime(math.random(), function () spawnItem("lureplant", 1, 1) end)
			elseif num > 1 then
				inst:DoTaskInTime(math.random(), function () spawnItem("mandrake", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("shadow_knight", 1, 4) end)
			else
				if (has_krampus_sack == false) or (math.random() < krampus_sack_chance) then	-- 没有包，或者有包的时候二次概率又符合
					inst:DoTaskInTime(math.random(), function () spawnItem("krampus_sack", 1, 1)end)
					inst:DoTaskInTime(math.random(), function () spawnItem("spat", 1, 4) end)
				else
					inst:DoTaskInTime(math.random(), function () spawnItem("lureplant", 1, 1) end)
				end
			end
			--]]
		end
		
		-- 第三类物品  橙黄绿宝石
		-- 25%给2铥矿thulecite
		-- 8%给星杖yellowstaff，同时生成2只大嘴nightmarebeak
		-- 8%给铥矿皇冠ruinshat，同时生成4只蜜蜂守卫beeguard
		-- 8%给铥矿护甲armorruins，同时生成2只触手tentacle
		-- 8%给铥矿武器ruins_bat，同时生成2只鱼人merm
		-- 8%给曼德拉草，同时生成1只暗影骑士
		-- 6%给眼球deerclops_eyeball，同时生成3只坎普斯krampus
		-- 6%给月杖opalstaff，同时生成1只主教bishop
		-- 6%给蜂王帽hivehat，同时生成1只猪人守卫pigguard
		-- 6%给海象帽walrushat，同时生成1只暗影主教shadow_bishop
		-- 6%给海象牙walrus_tusk，同时生成1只暗影战车shadow_rook
		-- 5%给小偷包，同时生成1只钢羊spat
		if InTable(itemList3, item.prefab) then
			local num = math.random(0, 100)
			local monster_x = math.random(4,5)
			local monster_y = math.random(4,5)
			local item_x = math.random(1,2)
			local item_y = math.random(1,2)
			---[[
			if num > 75 then
				inst:DoTaskInTime(math.random(), function () spawnItem("thulecite", 2, 1) end)
			elseif num > 67 then
				inst:DoTaskInTime(math.random(), function () spawnItem("yellowstaff", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("nightmarebeak", 2, 3) end)
			elseif num > 59 then
				inst:DoTaskInTime(math.random(), function () spawnItem("ruinshat", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("beeguard", 4, 2) end)
			elseif num > 51 then
				inst:DoTaskInTime(math.random(), function () spawnItem("armorruins", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("tentacle", 2, 2) end)
			elseif num > 43 then
				inst:DoTaskInTime(math.random(), function () spawnItem("ruins_bat", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("merm", 2, 2) end)
			elseif num > 35 then
				inst:DoTaskInTime(math.random(), function () spawnItem("mandrake", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("shadow_knight", 1, 4) end)
			elseif num > 29 then
				inst:DoTaskInTime(math.random(), function () spawnItem("deerclops_eyeball", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("krampus", 3, 3) end)
			elseif num > 23 then
				inst:DoTaskInTime(math.random(), function () spawnItem("opalstaff", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("bishop", 1, 3) end)
			elseif num > 17 then
				inst:DoTaskInTime(math.random(), function () spawnItem("hivehat", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("pigguard", 1, 2) end)
			elseif num > 11 then
				inst:DoTaskInTime(math.random(), function () spawnItem("walrushat", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("shadow_bishop", 1, 4) end)
			elseif num > 5 then
				inst:DoTaskInTime(math.random(), function () spawnItem("walrus_tusk", 1, 1) end)
				inst:DoTaskInTime(math.random(), function () spawnItem("shadow_rook", 1, 4) end)
			else
				if (has_krampus_sack == false) or (math.random() < krampus_sack_chance) then	-- 没有包，或者有包的时候二次概率又符合
					inst:DoTaskInTime(math.random(), function () spawnItem("krampus_sack", 1, 1)end)
					inst:DoTaskInTime(math.random(), function () spawnItem("spat", 1, 4) end)
				else
					inst:DoTaskInTime(math.random(), function () spawnItem("walrus_tusk", 1, 1) end)
					inst:DoTaskInTime(math.random(), function () spawnItem("shadow_rook", 1, 4) end)
				end
			end
			--]]
		end	
	end

	inst:AddComponent("trader")
	inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
	inst.components.trader.onaccept = OnGiven 

end)

--兔窝
AddPrefabPostInit("rabbithouse", function (inst)
	if not GLOBAL.TheWorld.ismastersim then
		return inst
	end
	local function ItemTradeTest(inst,item)
		if item == nil then

			return false
		end
		--暂时只接受金子
		if item.prefab ~= "goldnugget" then

			return false
		end
		return true
	end
	
	--给予随机物品
	local function OnGoldGiven(inst, giver, item)
		local x, y, z = inst.Transform:GetWorldPosition()
		local num = math.random(1,100)
		if num >= 90 then
			giver.components.inventory:GiveItem(DebugSpawn("manrabbit_tail"))
		elseif num >= 70 then
			giver.components.inventory:GiveItem(DebugSpawn("meat"))
		elseif num >= 30 then
			giver.components.inventory:GiveItem(DebugSpawn("carrot"))
		else
			giver.components.inventory:GiveItem(DebugSpawn("guano"))
		end
	end

	inst:AddComponent("trader")
	inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
	inst.components.trader.onaccept = OnGoldGiven 

end)