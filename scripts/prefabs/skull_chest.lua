require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/skull_chest.zip"),
    Asset("ANIM", "anim/ui_chest_5x5.zip"),
    
    Asset("IMAGE", "images/inventoryimages/skull_chest.tex"),
    Asset("ATLAS", "images/inventoryimages/skull_chest.xml"),
}

local prefabs = {
    "collapse_small"
}

local function getStuffChest(inst)
    for k,v in pairs(Ents) do
        if v.prefab == "skull_chest" and v.ownerlist and inst.ownerlist and v.ownerlist.master == inst.ownerlist.master and v ~= inst
            and not v.components.container:IsEmpty() then    -- 找到第一个有东西的箱子直接返回
                return v
        end
    end
    return nil    -- 没有找到有东西的箱子，返回nil
end

local function getChest(inst)    -- 找到第一个箱子
    for k,v in pairs(Ents) do
        if v.prefab == "skull_chest" and v.ownerlist and inst.ownerlist and v.ownerlist.master == inst.ownerlist.master and v ~= inst then
            return v
        end
    end
    return nil    -- 没有找到，返回nil
end

local function synchronize(source, destination)        -- 将source的箱子内容转移到destination的箱子中
    if source and destination then
        local i = 1
        for i=1, destination.components.container:GetNumSlots() do    -- 对每个槽而言
            local item = source.components.container:RemoveItemBySlot(i)    -- 先移除再同步
            -- print(tostring(item and item.prefab or nil))
            destination.components.container:GiveItem(item, i)
        end
    end
end

local function onopen(inst)
    local another = getStuffChest(inst)
    if another then        -- 如果有另一个箱子，则同步到当前的箱子
        synchronize(another, inst)
    end
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("open")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
end 

local function onclose(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", false)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
end

local function onhammered(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        if not inst.components.container:IsEmpty() then        -- 有东西才做处理
            local another = getChest(inst)
            if another == nil then        -- 如果没有对应的箱子，则掉落所有东西
                inst.components.container:DropEverything()
            else
                synchronize(inst, another)        -- 如果有另一个，则将物品转移到另一个箱子里
            end
        end
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
        if inst.components.container ~= nil then
            if not inst.components.container:IsEmpty() then        -- 有东西才做处理
                local another = getChest(inst)
                if another == nil then        -- 如果没有对应的箱子，则掉落所有东西
                    inst.components.container:DropEverything()
                else
                    synchronize(inst, another)        -- 如果有另一个，则将物品转移到另一个箱子里
                end
            end
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

local function GetStatus(inst)
    local another = getChest(inst)
    if another then
        return "CONNECT"
    else
        return "ALONE"
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("skull_chest.tex")

    inst:AddTag("structure")
    inst:AddTag("chest")
    inst:AddTag("shadowbox")

    inst.AnimState:SetBank("skull_chest")            -- scml里的entity名
    inst.AnimState:SetBuild("skull_chest")            -- 文件夹名
    inst.AnimState:PlayAnimation("closed")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("skull_chest")
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
Prefab("skull_chest", fn, assets, prefabs),
MakePlacer("skull_chest_placer", "skull_chest", "skull_chest", "closed")