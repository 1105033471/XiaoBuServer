local assets =
{
    Asset("ANIM", "anim/python_fountain.zip"),      
}

local prefabs =
{
    "waterdrop",
    --"lifeplant",
}

--[[
local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end
--]]

local function MakeFull(inst)
	inst.AnimState:PlayAnimation("flow_pre", false)			-- 从空水到满水的动画
	inst.state = "pre"
    inst:DoTaskInTime(1.3, function(inst)
		if inst.state == "pre" then				-- 此处必须判断，防止在1.3s之间改变了状态出现错误
			if not TheWorld.ismastersim then
				return inst
			end
			inst.AnimState:PlayAnimation("flow_loop", true)		-- 装水的动画1.3s，之后循环播放流水动画
			inst.state = "full"
			inst.Light:Enable(true)
			inst.components.activatable.inactive = true
			inst.components.sanityaura.aura = TUNING.SANITYAURA_MED
		end
	end)
end

local function MakeEmpty(inst)
	inst.AnimState:PlayAnimation("flow_pst", false)
	inst.state = "pst"
	inst:DoTaskInTime(0.97, function(inst)
		if inst.state == "pst" then
			if not TheWorld.ismastersim then
				return inst
			end
			inst.AnimState:PlayAnimation("off", true)
			inst.state = "empty"
			inst.Light:Enable(false)				-- 移除发光
			inst.components.activatable.inactive = false	-- 关闭状态无法采集
			inst.components.sanityaura.aura = 0				-- 移除精神光环
		end
	end)
end

--[[
local function onhit(inst, worker)
    -- 
end
--]]
local function onsave(inst, data)
	data.state = inst.state
	data.old_season = inst.old_season
end

local function onload(inst, data)
	inst.state = data and data.state or "full"
	inst.old_season = data and data.old_season or "autumn"
	if inst.state == "full" then
		-- print("at load make full")
		MakeFull(inst)
	else
		-- print("at load make empty")
		MakeEmpty(inst)
	end
end

local function getstatus(inst)
	local state = inst.state
	if state then
		if state == "pre" then
			return "PRE"
		elseif state == "full" then
			return "FULL"
		elseif state == "pst" then
			return "PST"
		elseif state == "empty" then
			return "EMPTY"
		end
	end
	return nil
end

local function OnChanged(inst)
	local now_season = TheWorld.state.season
	if now_season == "winter" and inst.state ~= "empty" then
		-- print("at season to winter, make empty")
		MakeEmpty(inst)
	elseif inst.old_season == "winter" then		-- 只有从冬天变为其他季节时播放动画
		-- print("at season leave winter, make full")
		MakeFull(inst)
	end
	
	inst.old_season = now_season		-- 保存上一次的季节
end

local function OnActivate(inst, doer)			-- 激活
	-- print("at active make empty")
	MakeEmpty(inst)
	
	local drop = SpawnPrefab("waterdrop")
	if drop then
		doer.components.inventory:GiveItem(drop)
	end
end

local function fn()
    local inst = CreateEntity()
    
	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst.Light:SetFalloff(0.9)			-- 发光
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(3)
    inst.Light:SetColour(169/255, 231/255, 245/255)
    inst.Light:Enable(false)

    inst.AnimState:SetBuild("python_fountain")
    inst.AnimState:SetBank("fountain")
	-- print("at init makefull")
    MakeFull(inst)
	
	inst:AddTag("watersource")
    -- inst:AddTag("antlion_sinkhole_blocker")		-- 单机相关的Tag
    -- inst:AddTag("birdblocker")
    
    MakeObstaclePhysics(inst, 1)			-- 阻碍生物通过的范围
	
	inst.MiniMapEntity:SetIcon("pugaliskfountain.tex")

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.old_season = TheWorld.state.season
	inst:WatchWorldState("season", OnChanged)		-- 监听世界季节变化
	
	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus
	
	inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = false
	
	inst:AddComponent("sanityaura")			-- 精神光环
	inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL
	
	inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
	
	-- inst:AddComponent("lootdropper")
	
    -- inst:AddComponent("workable")
	-- inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	-- inst.components.workable:SetOnFinishCallback(onhammered)
    -- inst.components.workable:SetOnWorkCallback(onhit) 
	-- inst.components.workable:SetWorkLeft(4)
	
	inst.OnSave = onsave
	inst.OnLoad = onload
	
    return inst
end

return
Prefab("pugalisk_fountain", fn, assets, prefabs),
MakePlacer("pugalisk_fountain_placer", "fountain", "python_fountain", "off")