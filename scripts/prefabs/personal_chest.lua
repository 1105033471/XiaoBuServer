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
    data.permission_list = {}
    if inst.permission_list ~= nil then
        for _,v in pairs(inst.permission_list) do
            table.insert(data.permission_list, v)
        end
    end
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt and inst.components.burnable ~= nil then
            inst.components.burnable.onburnt(inst)
        end
        if data.permission_list ~= nil then
            inst.permission_list = {}
            for _,v in pairs(data.permission_list) do
                table.insert(inst.permission_list, v)
            end
        end
    end
end

local function turnon(inst)

end

local function turnoff(inst)

end

local function turnon_fn(inst, doer)
    if inst.ownerlist then
        if inst.ownerlist.master ~= doer.userid then
            M_PlayerSay(doer, "这是别人的箱子，我无法修改权限")
        elseif inst.player_buff == nil then
            M_PlayerSay(doer, "要给予特定玩家权限，需要该玩家在15s内尝试打开箱子哦~")
        elseif table.contains(inst.permission_list, inst.player_buff) then
            M_PlayerSay(doer, "该玩家已经有这个箱子的权限了哦~")
        else
            table.insert(inst.permission_list, inst.player_buff)
            M_PlayerSay(doer, "已给予玩家【"..UserToName(inst.player_buff).."】该箱子的权限\n(使用皮肤法杖可以清除所有人的权限)")
        end
    end
    return false
end

local function reskin_func(inst, doer)    -- 清除所有权限
    if inst.ownerlist and inst.ownerlist.master == doer.userid then    -- 权限为施法者
        if inst.permission_list ~= nil and #inst.permission_list > 0 then
            inst.permission_list = {}
            doer.components.talker:Say("清除成功！\n这个箱子目前只有我能打开了")
        else
            doer.components.talker:Say("这个箱子已经够私密了！")
        end
    else
        doer.components.talker:Say("这是别人的箱子，我不能这么做")
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

    inst.AnimState:SetBank("roottrunk")            -- scml里的entity名
    inst.AnimState:SetBuild("treasure_chest_roottrunk")            -- 文件夹名
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

    inst:AddComponent("machine")
    inst.components.machine.cooldowntime = 1
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff

    MakeSmallBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:ListenForEvent("onbuilt", onbuilt)
    MakeSnowCovered(inst)

    inst.reskin_func = reskin_func
    inst.turnon_fn = turnon_fn

    inst.permission_list = {}

    inst.OnSave = onsave 
    inst.OnLoad = onload

    return inst
end

return
Prefab("personal_chest", fn, assets, prefabs),
MakePlacer("personal_chest_placer", "roottrunk", "treasure_chest_roottrunk", "closed")