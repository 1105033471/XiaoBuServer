local assets =
{
	Asset("ATLAS", "images/inventoryimages/flowerbox.xml"),
	Asset("IMAGE", "images/inventoryimages/flowerbox.tex"),
	Asset("ANIM", "anim/flowerbox.zip"),
}

local prefabs =
{
    "collapse_small",
}

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()			--掉落基础物品
	
	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	
	inst:Remove()
end

local function onhit(inst, worker, workleft)			-- 其实感觉没必要这个函数。。。
	local flowertype = inst.flowertype
	if workleft > 0 then
		if flowertype == "petals" then
			inst.AnimState:PlayAnimation("idle_flowers")
			inst.AnimState:PushAnimation("idle_flowers", false)
		elseif flowertype == "petals_evil" then
			inst.AnimState:PlayAnimation("idle_evil")
			inst.AnimState:PushAnimation("idle_evil", false)
		elseif flowertype == "foliage" then
			inst.AnimState:PlayAnimation("idle_cave")
			inst.AnimState:PushAnimation("idle_cave", false)
		else
			inst.AnimState:PlayAnimation("idle")
			inst.AnimState:PushAnimation("idle", false)
		end
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:PushAnimation("idle", false)
end

local function getstatus(inst)
	if inst.flowertype then
		if inst.flowertype == "petals" then
			return "PETALS"
		elseif inst.flowertype == "petals_evil" then
			return "EVIL"
		elseif inst.flowertype == "foliage" then
			return "CAVE"
		end
	else		-- 没有花装饰
		return "GENERIC"
	end
end

local function acceptTest(inst, item, giver)
	if item.prefab == "petals" or item.prefab == "petals_evil" or item.prefab == "foliage" then
		return true
	end
	return false
end

local function GivePetalsBuff(inst)		-- 普通花装饰时，范围回san
    inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL
end

local function GiveEvilBuff(inst)		-- 恶魔花装饰时，范围降san(降san光环比回san光环稍微大一点)
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
end

local function GiveCaveBuff(inst)		-- 蕨叶装饰时，范围发光
    inst.components.sanityaura.aura = 0
	inst.AnimState:SetLightOverride(0.3)
    inst.Light:Enable(true)
end

local function GiveFlower(inst, flowertype)
	if flowertype then
		inst:AddTag("flower")
	else
		inst:RemoveTag("flower")
	end
	if flowertype == "petals" then
		inst.AnimState:PlayAnimation("idle_flowers")
		inst.AnimState:PushAnimation("idle_flowers", false)
		GivePetalsBuff(inst)
	elseif flowertype == "petals_evil" then
		inst.AnimState:PlayAnimation("idle_evil")
		inst.AnimState:PushAnimation("idle_evil", false)
		GiveEvilBuff(inst)
	elseif flowertype == "foliage" then
		inst.AnimState:PlayAnimation("idle_cave")
		inst.AnimState:PushAnimation("idle_cave", false)
		GiveCaveBuff(inst)
	end
end

local function ongetitem(inst, giver, item)
	inst.SoundEmitter:PlaySound("dontstarve/creatures/together/stagehand/hit")
	if item.prefab then
		inst.flowertype = item.prefab
	end
	GiveFlower(inst, inst.flowertype)
end

local function onsave(inst, data)
	data.flowertype = inst.flowertype
end

local function onload(inst, data)
	if data then
		inst.flowertype = data.flowertype
		GiveFlower(inst, data.flowertype)
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
	
	MakeObstaclePhysics(inst, .5)
	
	inst.Light:SetFalloff(0.9)			-- 此处抄自茶几
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(1.5)
    inst.Light:SetColour(169/255, 231/255, 245/255)
    inst.Light:Enable(false)
	
	inst.MiniMapEntity:SetIcon("flowerbox.tex")
	inst.AnimState:SetBank("flowerbox")
	inst.AnimState:SetBuild("flowerbox")
	inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("structure")
	inst:AddTag("playerowned")
	
	MakeSnowCoveredPristine(inst)
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
		return inst
	end 
	
	MakeSnowCovered(inst)
	
	inst:AddComponent("inspectable")		-- 可检查的组件，由getstatus获取状态并读取STRING里的描述内容
	inst.components.inspectable.getstatus = getstatus
	
	inst:AddComponent("lootdropper")
	
	inst:AddComponent("sanityaura")			-- 精神光环
	inst.components.sanityaura.aura = 0
	
	inst:AddComponent("trader")				-- 可以用花瓣装饰
    inst.components.trader:SetAbleToAcceptTest(acceptTest)
	inst.components.trader.onaccept = ongetitem
	
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(3)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	
	MakeHauntableWork(inst)
	MakeSnowCovered(inst)
	
	-- inst:ListenForEvent("onbuilt", onbuilt)		-- 如果没有建造时的动画，写这句话也没啥意思。。。。
	
	inst.OnSave = onsave 			-- 保存当前装饰状态
    inst.OnLoad = onload
	
	return inst
end

return
Prefab("common/objects/flowerbox", fn, assets, prefabs),
MakePlacer("common/flowerbox_placer", "flowerbox", "flowerbox", "idle")
