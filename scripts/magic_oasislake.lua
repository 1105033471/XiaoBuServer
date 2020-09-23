local prefabFiles = {
    "new_wetpouch"          -- 修改版的绿洲包裹
}

for _,v in pairs(prefabFiles) do
    table.insert(PrefabFiles, v)
end

-- 钓上来的物品
local function GetFish(inst)
	return math.random() < 0.7 and "wetpouch" or "fish"	--pondfish  fishmeat_small
end 

-- 绿洲参数修改
TUNING.FISHINGROD_USES = 40
GLOBAL.TUNING.GREAT_OASISLAKE_MAX_FISH = 99999 -----设置的最大总量
GLOBAL.TUNING.GREAT_WETPOUCH_IS_STACKABLE = true

AddPrefabPostInit("oasislake", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end
	inst.components.fishable.maxfish = TUNING.GREAT_OASISLAKE_MAX_FISH -- 最大总量，原版15个
    inst.components.fishable:SetRespawnTime(1) -- 鱼的繁殖间隔，原版是90s
    inst.components.fishable:SetGetFishFn(GetFish) -- 钓上来的礼品
end)

-- 修改钓鱼速度
AddPrefabPostInit("fishingrod", function(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.fishingrod:SetWaitTimes(2,3)

    local old_onsave = inst.OnSave
    inst.OnSave = function(inst, data)
        if old_onsave then old_onsave(inst, data) end
        -- print("ming_fishingrod save: "..tostring(inst.no_finiteuse))
        data.no_finiteuse = inst.no_finiteuse
    end

    local old_onload = inst.OnLoad
    inst.OnLoad = function(inst, data)
        if old_onload then old_onload(inst, data) end
        if data then
            inst.no_finiteuse = data.no_finiteuse
            if inst.no_finiteuse then
                inst:RemoveComponent("finiteuses")
            end
        end
    end

end)

-- 钓上来的物品放进背包
AddPlayerPostInit(function(player)
    if not TheWorld.ismastersim then
        return player
    end

    player:ListenForEvent("fishingcollect", function (inst, data)
        local caughtfish = data.fish
        if caughtfish and caughtfish:IsValid() and inst and inst.components.inventory then 
            inst.components.inventory:GiveItem(caughtfish)
        end
    end)
end)

-- 调整原版的鱼肉度和鱼度
AddIngredientValues({"fish"}, {meat=.5,fish=.5}, true)

-- 修改开袋子的速度
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.UNWRAP, function(inst,action)
    if inst:HasTag("quagmire_fasthands") then
        return "domediumaction"
    else
        return "doshortaction"
    end
end))

AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.UNWRAP, function(inst,action)
    if inst:HasTag("quagmire_fasthands") then
        return "domediumaction"
    else
        return "doshortaction"
    end
end))
