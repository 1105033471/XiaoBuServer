require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/treasure_chest_roottrunk.zip"),
	Asset("ANIM", "anim/ui_chest_5x10.zip"),
	
	Asset("IMAGE", "images/inventoryimages/personal_chest.tex"),
	Asset("ATLAS", "images/inventoryimages/personal_chest.xml"),
}

local prefabs = {
	"collapse_small",
	-- "treasurechest",
}

local function onopen(inst, data)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("open")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
end 

local function onclose(inst, doer)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", false)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
		inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
        if inst.components.container ~= nil then
			inst.components.container:DropEverything()
            inst.components.container:Close()
        end
    end
end

local function onbuilt(inst, data)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil then
        inst.components.burnable.onburnt(inst)
    end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst.MiniMapEntity:SetIcon("personal_chest.tex")

	inst:AddTag("structure")
	inst:AddTag("chest")
	inst:AddTag("personal_chest")

	inst.AnimState:SetBank("roottrunk")			-- scml里的entity名
	inst.AnimState:SetBuild("treasure_chest_roottrunk")			-- 文件夹名
	inst.AnimState:PlayAnimation("closed")

	MakeSnowCoveredPristine(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")
	
	inst:AddComponent("container")
	inst.components.container:WidgetSetup("personal_chest")
	inst.components.container.onopenfn = onopen
	inst.components.container.onclosefn = onclose

	inst:AddComponent("lootdropper")
	
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(2)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	MakeSmallBurnable(inst, nil, nil, true)
	MakeMediumPropagator(inst)

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	inst:ListenForEvent("onbuilt", onbuilt)
	MakeSnowCovered(inst)

	inst.OnSave = onsave 
	inst.OnLoad = onload

	return inst
end

return
Prefab("personal_chest", fn, assets, prefabs),
MakePlacer("personal_chest_placer", "roottrunk", "treasure_chest_roottrunk", "closed")