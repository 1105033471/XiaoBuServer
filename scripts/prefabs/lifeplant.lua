local assets =
{
    Asset("ANIM", "anim/lifeplant.zip"),
	Asset("ANIM", "anim/lifeplant_fx.zip"),
	
	Asset("SOUNDPACKAGE", "sound/dontstarve_DLC003.fev"),
}

local prefabs =
{
	"waterdrop"
}

local INTENSITY = .5

local function fadein(inst)		-- 缓慢发亮
    inst.components.fader:StopAll()
    inst.Light:Enable(true)
	if inst:IsAsleep() then
		inst.Light:SetIntensity(INTENSITY)
	else
		inst.Light:SetIntensity(0)
		inst.components.fader:Fade(0, INTENSITY, 3+math.random()*2, function(v) inst.Light:SetIntensity(v) end)
	end
end

local function doresurrect(inst, haunter)
	haunter:DoTaskInTime(1, function()
		ExecuteConsoleCommand('local player = UserToPlayer("'..haunter.userid..'") player:PushEvent("respawnfromghost")')	-- 复活
	end)
	inst.AnimState:PlayAnimation("death")
	inst:DoTaskInTime(.8, function()
		inst:Remove()
	end)
	return true		-- 按照hauntable组件的要求，作祟成功后返回true
end

local function sparkle(inst, player)
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    local player_true = FindClosestPlayerInRange(x1, y1, z1, 6, true)
    
    if player_true then
        local sparkle = SpawnPrefab("lifeplant_sparkle")
        -- print("spawn sparkle "..tostring(sparkle))
        -- print("player is "..tostring(player_true))
        local x,y,z = player_true.Transform:GetWorldPosition()
        x = x or 0
        y = y or 0
        z = z or 0
        sparkle.Transform:SetPosition(x, y, z)
    end
end

local function drain(inst, player)
    local x1, y1, z1 = inst.Transform:GetWorldPosition()
    local player_true = FindClosestPlayerInRange(x1, y1, z1, 6, true)
    
	if not TheWorld.ismastersim then		-- 客机不操作
        return inst
    end
    
    if player_true then
        player_true.components.talker:Say("♥")		-- 2333
        local x1, y1, z1 = inst.Transform:GetWorldPosition()
        local x2, y2, z2 = player_true.Transform:GetWorldPosition()
        x2 = x2 or x1		-- 当附近的玩家离开这个世界时，会出现找不到坐标
        y2 = y2 or y1
        z2 = z2 or z1
        local distance = math.sqrt((x1-x2)*(x1-x2) + (z1-z2)*(z1-z2))
        -- print("distance is "..distance)
        local hungry_delta = 2/(distance+0.08)^(0.25) + 0.5		-- 函数模拟：距离为0时饥饿下降速度为4左右，距离为4时饥饿下降速度为1左右
        -- print("delta is "..hungry_delta)
        hungry_delta = math.floor(hungry_delta*100)/100			-- 取两位小数
        player_true.components.hunger:DoDelta(-hungry_delta)
    end
end

local function onnear(inst, player)
	inst.starvetask = inst:DoPeriodicTask(0.5, function() sparkle(inst, player) end)
	inst.starvetask2 = inst:DoPeriodicTask(2, function() drain(inst, player) end)
	inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/flower_of_life/fx_LP","drainloop")
end

local function onfar(inst, player)
	if inst.starvetask then
		inst.starvetask:Cancel()
		inst.starvetask = nil

		inst.starvetask2:Cancel()
		inst.starvetask2 = nil	
		inst.SoundEmitter:KillSound("drainloop")	
	end
end

local function dig_up(inst, chopper)
	if not TheWorld.ismastersim then
        return inst
    end
	local drop = inst.components.lootdropper:SpawnLootPrefab("waterdrop")
	inst.SoundEmitter:KillSound("drainloop")

	inst:Remove()
end

local function CalcSanityAura(inst, observer)
	return TUNING.SANITYAURA_LARGE
end

local function manageidle(inst)
	local anim = "idle_gargle"
	if math.random() < 0.5 then
		anim = "idle_vanity"
	end

	inst.AnimState:PlayAnimation(anim)
	inst.AnimState:PushAnimation("idle_loop",true)

	inst:DoTaskInTime(8+(math.random()*20), function() inst.manageidle(inst) end)
end

local function onplanted(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle_loop",true)
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/flower_of_life/plant")
end

local function testforplant(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	local ent = TheSim:FindFirstEntityWithTag("lifeplant")

	if ent and ent:GetDistanceSqToInst(inst) < 1 then
		inst:Remove()
	end
end

local function onspawn(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	local ent = TheSim:FindFirstEntityWithTag("lifeplant")
	if ent then
		local x2,y2,z2 = ent.Transform:GetWorldPosition()
    	local angle = inst:GetAngleToPoint(x2, y2, z2)
    	inst.Transform:SetRotation(angle)

		inst.components.locomotor:WalkForward()
		inst:DoPeriodicTask(0.1,function() testforplant(inst) end)
	else
		inst:Remove()
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()		-- TODO 小地图显示的图标
    inst.entity:AddNetwork()
	
	inst.entity:AddLight()
    inst.Light:SetIntensity(INTENSITY)
    inst.Light:SetColour(180/255, 195/255, 150/255)
    inst.Light:SetFalloff( 0.9 )
    inst.Light:SetRadius( 2 )
    inst.Light:Enable(true)

    MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("lifeplant")
    inst.AnimState:SetBuild("lifeplant")
    inst.AnimState:PlayAnimation("idle_loop", true)

	MakeInventoryFloatable(inst)
	
    inst:AddTag("lifeplant")
	inst:AddTag('resurrector')		-- 复活的标签

	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(6,7)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)
	
    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	
	inst:AddComponent('hauntable')
    inst.components.hauntable:SetOnHauntFn( doresurrect )
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_INSTANT_REZ)
	
	inst:AddComponent("lootdropper")
	
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(dig_up)
	
	inst:AddComponent("fader")
	fadein(inst)
	
	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura
	
	inst.onplanted = onplanted
	
	inst.manageidle = manageidle
    inst:DoTaskInTime(8+(math.random()*20), function() inst.manageidle(inst) end)
	
	-- MakeHauntableIgnite(inst)		-- 上面已经写了组件，这里不需要再调用标准组件函数了

    return inst
end

local function sparklefn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	inst.AnimState:SetBank("lifeplant_fx")
    inst.AnimState:SetBuild("lifeplant_fx")
    inst.AnimState:PlayAnimation("single"..math.random(1,3),true)
	
    inst:AddTag("flying")
    inst:AddTag("NOCLICK")
    inst:AddTag("fx")
	
	MakeInventoryPhysics(inst)
	
	inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2
	inst.components.locomotor:SetTriggersCreep(false)
	
	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
	
    inst:DoTaskInTime(0,function() onspawn(inst) end)
	
	inst.OnEntitySleep = function() inst:Remove() end
	
    RemovePhysicsColliders(inst)
	
	if not TheWorld.ismastersim then
		return inst
	end
	
    -- MakeNoPhysics(inst, 1, 0.3)
	
    inst.persists = false

    return inst
end

return
Prefab("lifeplant", fn, assets, prefabs),
Prefab("lifeplant_sparkle", sparklefn, assets, prefabs)