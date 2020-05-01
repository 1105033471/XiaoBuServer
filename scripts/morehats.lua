-- 能够升级的帽子列表
local hatList = {
	-- 有新鲜度的帽子
	"red_mushroomhat",			-- 红蘑菇帽
	"green_mushroomhat",		-- 绿蘑菇帽
	"blue_mushroomhat",			-- 蓝蘑菇帽
	"flowerhat",				-- 花环
	"watermelonhat",			-- 时尚西瓜帽
	
	-- 无新鲜度的帽子
	"rainhat",					-- 雨帽
	"earmuffshat",				-- 兔毛耳罩(保暖)
	"winterhat",				-- 寒冬帽(保暖)
	"tophat",					-- 高礼帽(保暖)
	"strawhat",					-- 草帽
	"catcoonhat",				-- 猫帽(保暖)
	"beefalohat",				-- 牛帽(保暖)
}

-- 升级材料列表
local acceptList = {
	"spiderhat",				-- 蜘蛛帽:3个去除西瓜帽湿润副作用
	
	"houndstooth",				-- 狗牙:160个获得永久耐久，只对无新鲜度的帽子有效
	"skeletonhat",				-- 白骨头盔:1个获得永久新鲜度，只对有新鲜度的帽子有效
	
	"deserthat",				-- 沙漠护目镜:10个获得沙漠护目镜效果
	
	"goose_feather",			-- 鹅毛:一个加1%防水
	
	"spidergland",				-- 蜘蛛腺体:250个加25%减缓饥饿速度
	
	"beefalohat",				-- 牛帽:一个加15保暖，五个获得亲牛光环
	"winterhat",				-- 寒冬帽:一个加10保暖，上限300
	"walrushat",				-- 贝雷帽:一个加10保暖，+1回san，上限8
	
	"hivehat",					-- 蜂王帽:一个加40隔热，上限300
	"icehat",					-- 冰块:一个加15隔热，上限300
	
	"opalpreciousgem",			-- 彩虹宝石，一个获得概率双倍采集效果，两个获得快速采集效果
}

-- 给升级材料加上tradable组件
for _,v in pairs(acceptList) do
	AddPrefabPostInit(v,function(inst)
	   if inst.components.tradable == nil then inst:AddComponent("tradable") end
	end)
end

-- 接受物品判定
local function GetItemFromPlayer(inst, item)
	if item == nil or inst == nil then
		return false
												-- 西瓜帽没有去除副作用时接受蜘蛛帽
	elseif item.prefab == "spiderhat" and inst.prefab == "watermelonhat" and inst.components.hatstatus.spiderhat_count < 3 then
		return true
												-- 有新鲜度的帽子,在新鲜度未去除时接受白骨头盔
	elseif item.prefab == "skeletonhat" and inst.components.perishable and inst.components.hatstatus.skeletonhat_count < 1 then
		return true
												-- 有耐久的帽子，在耐久未去除时接受狗牙
	elseif item.prefab == "houndstooth" and inst.components.fueled and inst.components.hatstatus.houndstooth_count < 160 then
		return true
												-- 接受的沙漠护目镜小于10个的时候，接受沙漠护目镜
	elseif item.prefab == "deserthat" and inst.components.hatstatus and inst.components.hatstatus.deserthat_count < 10 then
		return true
												-- 未获得满防水效果时，接受鹅毛
	elseif item.prefab == "goose_feather" and inst.components.hatstatus.waterproof == 0 then
		return true
												-- 未获得25%减缓饥饿速度时，接受蜘蛛腺体
	elseif item.prefab == "spidergland" and inst.components.hatstatus.hungry == 0 then
		return true
												-- 未获得亲牛光环时，接受牛帽
	elseif item.prefab == "beefalohat" and inst.components.hatstatus.closebeefalo == 0 then
		return true
												-- 未获得满保暖效果时，接受牛帽、冬帽以及海象帽
	elseif (item.prefab == "beefalohat" or item.prefab == "winterhat" or item.prefab == "walrushat") and inst.components.hatstatus.warm == 0 and inst.components.hatstatus.iswarm == 1 then
		return true
												-- 未获得满回san效果时，接受海象帽
	elseif item.prefab == "walrushat" and inst.components.hatstatus.sanity == 0 then
		return true
												-- 未获得满隔热效果时，接受蜂王帽、冰块
	elseif (item.prefab == "hivehat" or item.prefab == "icehat") and inst.components.hatstatus.heart == 0 and inst.components.hatstatus.iswarm == 0 then
		return true
	elseif item.prefab == "cutgrass" or item.prefab == "twigs" then		-- 给小树枝或者草查看全属性
		return true
	elseif item.prefab == "opalpreciousgem" and inst.components.hatstatus.opal_count < 2 then	-- 接受的彩虹宝石小于两个时，重复接受
		return true
	else
		return false
	end
	return false
end

-- 存储帽子的基本属性
local function UpdateBaseValue(inst)
												-- 蘑菇帽基本属性
	if inst.prefab == "red_mushroomhat" or inst.prefab == "green_mushroomhat" or inst.prefab == "blue_mushroomhat" then
		inst.components.hatstatus.base_waterproof = 20	-- 防水
		inst.components.hatstatus.base_heart = 60		-- 隔热
		inst.components.hatstatus.base_hungry = 25		-- 减缓饥饿
		inst.components.hatstatus.hungry = 1			-- 满级了
		inst.components.hatstatus.base_perishtime_fresh = TUNING.PERISH_FAST
	elseif inst.prefab == "flowerhat" then		-- 花环
		inst.components.hatstatus.base_sanity = 1.2		-- 回san
		inst.components.hatstatus.base_perishtime_fresh = TUNING.PERISH_FAST
	elseif inst.prefab == "watermelonhat" then	-- 西瓜帽
		inst.components.hatstatus.base_waterproof = 20
		inst.components.hatstatus.base_sanity = -1.8
		inst.components.hatstatus.base_heart = 120
		inst.components.hatstatus.base_perishtime_fresh = TUNING.PERISH_FAST
	elseif inst.prefab == "rainhat" then		-- 雨帽
		inst.components.hatstatus.base_waterproof = 70
		inst.components.hatstatus.base_perishtime = TUNING.RAINHAT_PERISHTIME
	elseif inst.prefab == "earmuffshat" then	-- 兔毛耳罩
		inst.components.hatstatus.base_warm = 60		-- 保暖
		inst.components.hatstatus.base_perishtime = TUNING.EARMUFF_PERISHTIME
		inst.components.hatstatus.iswarm = 1
	elseif inst.prefab == "winterhat" then		-- 冬帽
		inst.components.hatstatus.base_sanity = 1.2
		inst.components.hatstatus.base_warm = 120
		inst.components.hatstatus.base_perishtime = TUNING.WINTERHAT_PERISHTIME
		inst.components.hatstatus.iswarm = 1
	elseif inst.prefab == "tophat" then			-- 高礼帽
		inst.components.hatstatus.base_sanity = 3
		inst.components.hatstatus.base_waterproof = 20
		inst.components.hatstatus.base_perishtime = TUNING.TOPHAT_PERISHTIME
		inst.components.hatstatus.iswarm = 1
	elseif inst.prefab == "strawhat" then		-- 草帽
		inst.components.hatstatus.base_waterproof = 20
		inst.components.hatstatus.base_heart = 60
		inst.components.hatstatus.base_perishtime = TUNING.STRAWHAT_PERISHTIME
	elseif inst.prefab == "catcoonhat" then		-- 猫帽
		inst.components.hatstatus.base_warm = 60		-- 保暖
		inst.components.hatstatus.base_sanity = 3
		inst.components.hatstatus.base_perishtime = TUNING.CATCOONHAT_PERISHTIME
		inst.components.hatstatus.iswarm = 1
	elseif inst.prefab == "beefalohat" then		-- 牛帽
		inst.components.hatstatus.base_warm = 240		-- 保暖
		inst.components.hatstatus.base_waterproof = 20
		inst.components.hatstatus.closebeefalo = 1
		inst.components.hatstatus.base_perishtime = TUNING.BEEFALOHAT_PERISHTIME
		inst.components.hatstatus.iswarm = 1
	end
end

-- 数据更新，更新帽子的属性，根据组件hatstatus的参数进行更新
local function ValueCheck(inst)
	if inst.prefab == "watermelonhat" then		-- 西瓜帽更新潮湿属性
		local spiderhat_count = inst.components.hatstatus.spiderhat_count
		local equippedmoisture = 0.5
		local maxequippedmoisture = 32
		if spiderhat_count < 3 then
			equippedmoisture = 0.5 - 0.2 * spiderhat_count
			maxequippedmoisture = 32 - 10 * spiderhat_count
		else
			equippedmoisture = 0
			maxequippedmoisture = 0
		end
		inst.components.equippable.equippedmoisture = equippedmoisture				-- 潮湿速度
		inst.components.equippable.maxequippedmoisture = maxequippedmoisture		-- 最大潮湿值
	end
	
	if inst.components.perishable then			-- 新鲜度未去除
		local skeletonhat_count = inst.components.hatstatus.skeletonhat_count
		local base_perishtime_fresh = inst.components.hatstatus.base_perishtime_fresh
		if skeletonhat_count < 1 then
			local preishTime = base_perishtime_fresh + skeletonhat_count * 10 * 16*30		-- 计算腐烂时间，每个骨头头盔耐久为10天
			inst.components.perishable:SetNewMaxPerishTime(preishTime)
		else
			inst:RemoveComponent("perishable")
		end
	end
	
	if inst.components.fueled then				-- 耐久更新
		local houndstooth_count = inst.components.hatstatus.houndstooth_count
		if houndstooth_count < 160 then
			local current_percent = inst.components.fueled:GetPercent()
			local base_perishtime = inst.components.hatstatus.base_perishtime
			local perishtime_all = base_perishtime + 10*houndstooth_count	-- 每个狗牙增加10s耐久
			inst.components.fueled:InitializeFuelLevel(perishtime_all)
			inst.components.fueled:SetPercent(current_percent)
		else
			inst:RemoveComponent("fueled")
			inst:AddTag("hide_percentage")
		end
	end
	
	if inst.components.hatstatus.deserthat_count >= 10 and inst.components.hatstatus.has_goggles == 0 then -- 给予沙漠护目镜效果
		inst.components.hatstatus.has_goggles = 1
	end
	
	if inst.components.hatstatus.waterproof == 0 then		-- 更新防水效果
		local base_waterproof = inst.components.hatstatus.base_waterproof
		local goose_count = inst.components.hatstatus.goose_count
		if inst.components.waterproofer == nil then
			inst:AddComponent("waterproofer")
		end
		local effectiveness = (base_waterproof + goose_count) / 100
		inst.components.waterproofer:SetEffectiveness(effectiveness)
	else
		if inst.components.waterproofer == nil then
			inst:AddComponent("waterproofer")
		end
		inst.components.waterproofer:SetEffectiveness(1)
	end
	
	local function doublepick(inst, data)		-- 双倍采集效果
		local doublechance = 0.3
		local jellybugchance = 0.2
		if data.object and data.object.components.pickable and not data.object.components.trader then
			if data.object.components.pickable.product ~= nil then
				if math.random() <= doublechance then		--原有物品的双倍
					local item = SpawnPrefab(data.object.components.pickable.product)
					if item.components.stackable then
						item.components.stackable:SetStackSize(data.object.components.pickable.numtoharvest)
					end
					inst.components.inventory:GiveItem(item, nil, data.object:GetPosition())
					if inst:HasTag("player") and not inst:HasTag("playerghost") and  ( data.object.prefab  == "cactus" or data.object.prefab  == "oasis_cactus" )  and  data.object.has_flower  then 
						local lootcactus_flower = SpawnPrefab("cactus_flower")
						if lootcactus_flower ~= nil then
							inst.components.inventory:GiveItem(lootcactus_flower, nil, data.object:GetPosition())
						end
					end
				end
				if math.random() <= jellybugchance then
					if inst:HasTag("player") and not inst:HasTag("playerghost") and  data.object.prefab  == "coffeebush" then
						local jellybug = SpawnPrefab("jellybug")
						if jellybug ~= nil then
							inst.components.inventory:GiveItem(jellybug, nil, data.object:GetPosition())
						end
					end
				end
			end
		end
	end
	
	local old_onequipfn = inst.components.equippable.onequipfn
	local function base_onequip(inst, owner, symbol_override)	-- base equip function
		if inst.components.hatstatus.has_goggles == 1 and owner:HasTag("player") and owner:GetSandstormLevel() >= TUNING.SANDSTORM_FULL_LEVEL and not owner.components.playervision:HasGoggleVision() then
			inst:AddTag("goggles")						-- 添加沙漠护目镜buff
		end
		if inst.components.hatstatus.closebeefalo == 1 then								-- 亲牛
			owner:AddTag("beefalo")
		end
		if inst.components.hatstatus.opal_count > 0 and owner.has_doublepick ~= true then	-- 双倍采集
			owner:RemoveEventCallback("picksomething", doublepick)
			owner:ListenForEvent("picksomething", doublepick)
			print("give "..owner:GetDisplayName().." doublepick buff")
			owner.has_doublepick = true
		end
		if inst.components.hatstatus.opal_count > 1 then
			owner:AddTag("fastpicker")	-- 快速采集
		end
        old_onequipfn(inst, owner, symbol_override)
    end
	
	local old_onunequip = inst.components.equippable.onunequipfn
	local function new_onunequip(inst, owner)		-- 卸下后不减缓饥饿
		if inst:HasTag("goggles") then
			inst:RemoveTag("goggles")						-- 移除沙漠护目镜buff
		end
		
		if owner:HasTag("beefalo") then		-- 移除亲牛效果
			owner:RemoveTag("beefalo")
		end
		
		owner:RemoveEventCallback("picksomething", doublepick)
		owner.has_doublepick = nil
		owner:RemoveTag("fastpicker")
		
		if owner.components.hunger ~= nil then
            owner.components.hunger.burnratemodifiers:RemoveModifier(inst)
        end
		
		old_onunequip(inst, owner)
	end
	
	if inst.components.hatstatus.hungry == 0 then			-- 更新减缓饥饿buff
		local spidergland = inst.components.hatstatus.spidergland
		local hungryBuff = 1 - spidergland / 1000
		
		local function new_onequip(inst, owner)
			base_onequip(inst, owner)
			if owner.components.hunger ~= nil then
				owner.components.hunger.burnratemodifiers:SetModifier(inst, hungryBuff)
			end
		end
		
		inst.components.equippable:SetOnEquip(new_onequip)
		inst.components.equippable:SetOnUnequip(new_onunequip)
	else
		local function new_onequip(inst, owner)
			base_onequip(inst, owner)
			if owner.components.hunger ~= nil then
				owner.components.hunger.burnratemodifiers:SetModifier(inst, 0.75)
			end
		end
		
		inst.components.equippable:SetOnEquip(new_onequip)
		inst.components.equippable:SetOnUnequip(new_onunequip)
	end
	
	if inst.components.hatstatus.iswarm == 1 then
		if inst.components.hatstatus.warm == 0 then			-- 更新保暖效果
			local base_warm = inst.components.hatstatus.base_warm
			local beefalohat_count = inst.components.hatstatus.beefalohat_count
			local winterhat_count = inst.components.hatstatus.winterhat_count
			local walrushat_count = inst.components.hatstatus.walrushat_count
			
			local warm_all = base_warm + beefalohat_count*15 + winterhat_count*10 + walrushat_count*10
			if warm_all > 300 then		-- 因为其他能力导致此处可能超过设定值
				warm_all = 300
			end
			if inst.components.insulator == nil then
				inst:AddComponent("insulator")
			end
			inst.components.insulator:SetInsulation(warm_all)
		else
			if inst.components.insulator == nil then
				inst:AddComponent("insulator")
			end
			inst.components.insulator:SetInsulation(300)
		end
	else
		if inst.components.hatstatus.heart == 0 then		-- 更新隔热效果
			local base_heart = inst.components.hatstatus.base_heart
			local hivehat_count = inst.components.hatstatus.hivehat_count
			local icehat_count = inst.components.hatstatus.icehat_count
			local heart_all = base_heart + hivehat_count*40 + icehat_count*15
			if heart_all > 300 then
				heart_all = 300
			end
			if inst.components.insulator == nil then
				inst:AddComponent("insulator")
			end
			inst.components.insulator:SetSummer()
			inst.components.insulator:SetInsulation(heart_all)
		else
			if inst.components.insulator == nil then
				inst:AddComponent("insulator")
			end
			inst.components.insulator:SetSummer()
			inst.components.insulator:SetInsulation(300)
		end
	end
	
	if inst.components.hatstatus.sanity == 0 then		-- 更新回san效果
		local base_sanity = inst.components.hatstatus.base_sanity
		local walrushat_count = inst.components.hatstatus.walrushat_count
		local sanity_all = (base_sanity + walrushat_count) / 54
		if sanity_all > (8/54) then
			sanity_all = 8/54
		end
		inst.components.equippable.dapperness = sanity_all
	else
		inst.components.equippable.dapperness = 8/54
	end

end

-- 给予树枝和草查看全属性
local function SayWholeAbility(inst, giver)
	local spiderhat_count = inst.components.hatstatus.spiderhat_count
	local skeletonhat_count = inst.components.hatstatus.skeletonhat_count
	local houndstooth_count = inst.components.hatstatus.houndstooth_count
	local deserthat_count = inst.components.hatstatus.deserthat_count
	local goose_count = inst.components.hatstatus.goose_count
	local waterproof = inst.components.hatstatus.waterproof
	local spidergland = inst.components.hatstatus.spidergland
	local hungry = inst.components.hatstatus.hungry
	local beefalohat_count = inst.components.hatstatus.beefalohat_count
	local closebeefalo = inst.components.hatstatus.closebeefalo
	local winterhat_count = inst.components.hatstatus.winterhat_count
	local warm = inst.components.hatstatus.warm
	local walrushat_count = inst.components.hatstatus.walrushat_count
	local sanity = inst.components.hatstatus.sanity
	local hivehat_count = inst.components.hatstatus.hivehat_count
	local icehat_count = inst.components.hatstatus.icehat_count
	local heart = inst.components.hatstatus.heart
	local base_waterproof = inst.components.hatstatus.base_waterproof
	local base_warm = inst.components.hatstatus.base_warm
	local base_sanity = inst.components.hatstatus.base_sanity
	local base_heart = inst.components.hatstatus.base_heart
	local base_hungry = inst.components.hatstatus.base_hungry
	local base_perishtime = inst.components.hatstatus.base_perishtime
	local base_perishtime_fresh = inst.components.hatstatus.base_perishtime_fresh
	local iswarm = inst.components.hatstatus.iswarm
	local has_goggles = inst.components.hatstatus.has_goggles
	local opal_count = inst.components.hatstatus.opal_count
	
	local waterproof = base_waterproof + goose_count	-- 防水
	if waterproof > 100 then waterproof = 100 end
	
	local sanity = base_sanity + walrushat_count		-- 提升精神
	if sanity > 8 then sanity = 8 end
	
	local warm_all = beefalohat_count*15 + base_warm + walrushat_count*10 + winterhat_count*10	-- 保暖
	if warm_all > 300 then warm_all = 300 end
	
	local heart_all = base_heart + hivehat_count*40 + icehat_count*15	-- 隔热
	if heart_all > 300 then heart_all = 300 end
	
	local sayString = "这个帽子的当前属性:\n帽子类型: "
	
	sayString = sayString..(iswarm == 1 and "保暖\n保暖效果: " or "隔热\n隔热效果: ")
	sayString = sayString..(iswarm == 1 and warm_all.."s/300s(寒冬帽、牛帽、海象帽)\n" or heart_all.."s/300s(蜂王帽、冰帽)\n")
	sayString = sayString.."防水: "..waterproof.."%(鹅毛)\n"
	if inst.components.fueled then
		sayString = sayString.."耐久去除进度: "..houndstooth_count.."/160(狗牙)\n"
	elseif inst.components.perishable then
		sayString = sayString.."新鲜度去除进度: "..skeletonhat_count.."/1(白骨头盔)\n"
	end
	
	if has_goggles == 0 then
		sayString = sayString.."沙漠护目能力进度: "..deserthat_count.."/10(沙漠护目镜)\n"
	else
		sayString = sayString.."已获得沙漠护目能力\n"
	end
	
	sayString = sayString.."提升精神: "..(sanity >= 0 and "+"..sanity or sanity).."(海象帽)\n"
	if hungry == 0 then				-- 未获得饥饿减缓时
		sayString = sayString.."减缓饥饿进度: "..spidergland.."/250(蜘蛛腺体)\n"
	else
		sayString = sayString.."减缓饥饿进度: 250/250(蜘蛛腺体)\n"
	end
	sayString = sayString.."亲牛效果: "..beefalohat_count.."/5(牛帽)\n"
	if inst.prefab == "watermelonhat" and spiderhat_count < 3 then
		sayString = sayString.."西瓜帽副作用去除进度: "..spiderhat_count.."/3(蜘蛛帽)\n"
	end
	sayString = sayString.."特殊能力: "
	if opal_count == 0 then
		sayString = sayString.."无(彩虹宝石)"
	elseif opal_count == 1 then
		sayString = sayString.."概率双倍采集(彩虹宝石)"
	else
		sayString = sayString.."概率双倍采集 + 快速采集"
	end
	
	giver.components.talker:Say(sayString)
end

-- 接受物品后的处理，更新组件hatstatus的参数
local function OnGemGiven(inst, giver, item)
	if item.prefab == "spiderhat" then
		inst.components.hatstatus.spiderhat_count = inst.components.hatstatus.spiderhat_count + 1
		giver.components.talker:Say("蜘蛛帽数量: "..inst.components.hatstatus.spiderhat_count.."/3\n满级后移除湿润效果")
	elseif item.prefab == "houndstooth" then
		inst.components.hatstatus.houndstooth_count = inst.components.hatstatus.houndstooth_count + 1
		giver.components.talker:Say("狗牙数量: "..inst.components.hatstatus.houndstooth_count.."/160\n满级后无限耐久")
	elseif item.prefab == "skeletonhat" then
		inst.components.hatstatus.skeletonhat_count = inst.components.hatstatus.skeletonhat_count + 1
		giver.components.talker:Say("白骨头盔数量: "..inst.components.hatstatus.skeletonhat_count.."/1\n满级后不会腐烂")
	elseif item.prefab == "deserthat" then
		inst.components.hatstatus.deserthat_count = inst.components.hatstatus.deserthat_count + 1
		giver.components.talker:Say("沙漠护目镜数量: "..inst.components.hatstatus.deserthat_count.."/10\n满级后获得沙漠护目镜效果")
	elseif item.prefab == "goose_feather" then
		inst.components.hatstatus.goose_count = inst.components.hatstatus.goose_count + 1
		giver.components.talker:Say("防水 + 1%")
	elseif item.prefab == "spidergland" then
		inst.components.hatstatus.spidergland = inst.components.hatstatus.spidergland + 1
		local now_hungry = inst.components.hatstatus.spidergland / 10
		giver.components.talker:Say("饥饿减缓 + 0.1%\n当前进度  "..now_hungry.."%/25%")
	elseif item.prefab == "beefalohat" then
		inst.components.hatstatus.beefalohat_count = inst.components.hatstatus.beefalohat_count + 1
		local beefalohat_count = inst.components.hatstatus.beefalohat_count
		local closebeefalo = inst.components.hatstatus.closebeefalo
		if beefalohat_count <= 5 and closebeefalo == 0 then
			if inst.components.hatstatus.iswarm == 1 and inst.components.hatstatus.warm == 0 then
				giver.components.talker:Say("保暖 + 15s\n牛帽数量: "..beefalohat_count.."/5\n满级后获得亲牛效果")
			else
				giver.components.talker:Say("牛帽数量: "..beefalohat_count.."/5\n满级后获得亲牛效果")
			end
		else
			giver.components.talker:Say("保暖 + 15s\n已获得亲牛效果")
		end
	elseif item.prefab == "winterhat" then
		inst.components.hatstatus.winterhat_count = inst.components.hatstatus.winterhat_count + 1
		giver.components.talker:Say("保暖 + 10s")
	elseif item.prefab == "walrushat" then
		inst.components.hatstatus.walrushat_count = inst.components.hatstatus.walrushat_count + 1
		if inst.components.hatstatus.iswarm == 1 and inst.components.hatstatus.warm == 0 then
			if inst.components.hatstatus.sanity == 0 then
				giver.components.talker:Say("保暖 + 10\n提升精神 + 1/min")
			else
				giver.components.talker:Say("保暖 + 10")
			end
		else
			giver.components.talker:Say("提升精神 + 1/min")
		end
	elseif item.prefab == "hivehat" then
		inst.components.hatstatus.hivehat_count = inst.components.hatstatus.hivehat_count + 1
		giver.components.talker:Say("隔热 + 40s")
	elseif item.prefab == "icehat" then
		inst.components.hatstatus.icehat_count = inst.components.hatstatus.icehat_count + 1
		giver.components.talker:Say("隔热 + 15s")
	elseif item.prefab == "cutgrass" or item.prefab == "twigs" then	-- 查看全属性
		SayWholeAbility(inst, giver)
	elseif item.prefab == "opalpreciousgem" then
		inst.components.hatstatus.opal_count = inst.components.hatstatus.opal_count + 1
		if inst.components.hatstatus.opal_count > 1 then
			giver.components.talker:Say("彩虹宝石："..inst.components.hatstatus.opal_count.."/2\n已获得快速采集和双倍采集效果\n(重新装备后生效)")
		else
			giver.components.talker:Say("彩虹宝石："..inst.components.hatstatus.opal_count.."/2\n已获得双倍采集效果(重新装备后生效)")
		end
	end
	
	-- 更新waterproof
	if inst.components.hatstatus.waterproof == 0 and inst.components.hatstatus.base_waterproof + inst.components.hatstatus.goose_count >= 100 then
		inst.components.hatstatus.waterproof = 1
	end
	
	-- 更新hungry
	if inst.components.hatstatus.hungry == 0 and inst.components.hatstatus.spidergland >= 250 then
		inst.components.hatstatus.hungry = 1
	end
	
	-- 更新closebeefalo
	if inst.components.hatstatus.closebeefalo == 0 and inst.components.hatstatus.beefalohat_count >= 5 then
		inst.components.hatstatus.closebeefalo = 1
	end
	if inst.components.hatstatus.iswarm == 0 then
		-- 更新heart
		if inst.components.hatstatus.heart == 0 then
			local heart_all = inst.components.hatstatus.base_heart + inst.components.hatstatus.hivehat_count*40
			heart_all = heart_all + inst.components.hatstatus.icehat_count*15
			if heart_all >= 300 then
				inst.components.hatstatus.heart = 1
			end
		end
	else
		-- 更新warm
		-- giver.components.talker:Say("iswarm = "..inst.components.hatstatus.iswarm)
		if inst.components.hatstatus.warm == 0 then
			local warm_all = inst.components.hatstatus.beefalohat_count*15 + inst.components.hatstatus.base_warm
			warm_all = warm_all + inst.components.hatstatus.walrushat_count*10 + inst.components.hatstatus.winterhat_count*10
			-- giver:DoTaskInTime(2, function() giver.components.talker:Say("保暖效果:"..warm_all) end)
			if warm_all >= 300 then
				inst.components.hatstatus.warm = 1
			end
		end
	end
	
	-- 更新sanity
	if inst.components.hatstatus.sanity == 0 and inst.components.hatstatus.base_sanity + inst.components.hatstatus.walrushat_count >= 8 then
		inst.components.hatstatus.sanity = 1
	end
	
	inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
	if inst.components.fueled then			-- 每次给材料都修复满耐久
		inst.components.fueled.currentfuel = inst.components.fueled.maxfuel
	end
	if inst.components.perishable then
		inst.components.perishable:SetPercent(1)
	end
	ValueCheck(inst)
end

-- 公用函数
local function fn(inst)
	if inst.SoundEmitter == nil then
		inst.entity:AddSoundEmitter()
	end
	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:AddComponent("hatstatus")
	UpdateBaseValue(inst)
	inst.ValueCheck = ValueCheck
	
	inst:AddComponent("trader")
	inst.components.trader:SetAbleToAcceptTest(GetItemFromPlayer)
	inst.components.trader.onaccept = OnGemGiven
	
	inst:DoTaskInTime(0, function() ValueCheck(inst) end)
end

-- 对hatList中的帽子添加升级功能
for _,v in pairs(hatList) do
	AddPrefabPostInit(v, fn)
end

