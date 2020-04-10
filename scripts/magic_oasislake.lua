-- GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
TUNING.FISHINGROD_USES = 40
GLOBAL.TUNING.GREAT_OASISLAKE_MAX_FISH = 99999 -----设置的最大总量
GLOBAL.TUNING.GREAT_WETPOUCH_IS_STACKABLE = true


-------------------------------------------------------------------------------

local function AddOasislakeGetFish(inst)
	return math.random() < 0.7 and "wetpouch" or "fish"	--pondfish  fishmeat_small
end 

local function AddOasislake(inst)-------增大沙漠湖的容量！
    if not TheWorld.ismastersim then
        return inst
    end
	inst.components.fishable.maxfish = TUNING.GREAT_OASISLAKE_MAX_FISH ---最大总量，原版15个
    inst.components.fishable:SetRespawnTime(1) ----恢复间隔，原版是90s
    inst.components.fishable:SetGetFishFn(AddOasislakeGetFish) ------钓上来的礼品
end
AddPrefabPostInit("oasislake",AddOasislake)

-------------------------------------------------------------------------------

local function AddFishingrod(inst)--------快速的钓鱼！
	if not TheWorld.ismastersim then
        return inst
    end
    inst.components.fishingrod:SetWaitTimes(2,3)
    --inst.components.fishingrod:SetStrainTimes(0, 5)
end
AddPrefabPostInit("fishingrod",AddFishingrod)

-------------------------------------------------------------------------------

local function onfishingcollect(inst,data)
	local caughtfish = data.fish
	-- print("Quick give fish!",caughtfish,inst,inst.components.inventory)
	if caughtfish and caughtfish:IsValid() and inst and inst.components.inventory then 
		inst.components.inventory:GiveItem(caughtfish)--------鱼会自己进背包里
	end
end 

local function AddPlayerCollectFish(inst)
	if not TheWorld.ismastersim then
        return inst
    end
	inst:ListenForEvent("fishingcollect",onfishingcollect)
end 
AddPlayerPostInit(AddPlayerCollectFish)

-------------------------------------------------------------------------------


local wetpouch = ---------------妈的直接照抄，我去你妈的兼容性
{
    loottable =
    {
        goggleshat_blueprint = 0,
        deserthat_blueprint = 0,
        succulent_potted_blueprint = 0,
        antliontrinket = 0,
        trinket_1 = 1, -- marbles
        trinket_3 = 1, -- knot
        trinket_8 = 1, -- plug
        trinket_9 = 1, -- buttons
        trinket_26 = .1, -- potatocup
        TOOLS_blueprint = .05,
        LIGHT_blueprint = .05,
        SURVIVAL_blueprint = .05,
        FARM_blueprint = .05,
        SCIENCE_blueprint = .05,
        REFINE_blueprint = .05,
        DRESS_blueprint = .05,
    },

    UpdateLootBlueprint = function(loottable, doer)
        local builder = doer ~= nil and doer.components.builder or nil
        loottable["goggleshat_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("goggleshat")) and 1 or 0.1
        loottable["deserthat_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("deserthat") and builder:KnowsRecipe("goggleshat")) and 1 or 0.1
        loottable["succulent_potted_blueprint"] = (builder ~= nil and not builder:KnowsRecipe("succulent_potted")) and 1 or 0.1
        loottable["antliontrinket"] = (builder ~= nil and builder:KnowsRecipe("deserthat")) and .8 or 0.1
    end,
    
    lootfn = function(inst, doer)
        inst.setupdata.UpdateLootBlueprint(inst.setupdata.loottable, doer)

        local total = 0
        for _,v in pairs(inst.setupdata.loottable) do
            total = total + v
        end
        --print ("TOTOAL:", total)
        --for k,v in pairs(inst.setupdata.loottable) do print(" - ", tostring(v/total), k) end

        local item = weighted_random_choice(inst.setupdata.loottable)

        if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) and
            string.sub(item, 1, 7) == "trinket" and
            item ~= "trinket_26" then
            --chance to replace trinkets (but not potatocup)
            local rnd = math.random(6)
            if rnd == 1 then
                item = GetRandomBasicWinterOrnament()
            elseif rnd == 2 then
                item = GetRandomFancyWinterOrnament()
            elseif rnd == 3 then
                item = GetRandomLightWinterOrnament()
            end
        end

        return { item }
    end,

    master_postinit = function(inst, setupdata)
        inst.build = "wetpouch"
        inst.setupdata = setupdata
        inst.wet_prefix = STRINGS.WET_PREFIX.POUCH
        inst.components.inventoryitem:InheritMoisture(100, true)
    end,
}



local function OnUnwrapped_Klei(inst, pos, doer) ---------------我去你妈的兼容性
	local loot, tossloot, setupdata = JoinArrays(table.invert(wetpouch.loottable), GetAllWinterOrnamentPrefabs()), false, wetpouch
    if inst.burnt then
        SpawnPrefab("ash").Transform:SetPosition(pos:Get())
    else
        local loottable = (setupdata ~= nil and setupdata.lootfn ~= nil) and setupdata.lootfn(inst, doer) or loot
        if loottable ~= nil then
			local moisture = inst.components.inventoryitem:GetMoisture()
            local iswet = inst.components.inventoryitem:IsWet()
            for i, v in ipairs(loottable) do
                local item = SpawnPrefab(v)
                if item ~= nil then
                    if item.Physics ~= nil then
                        item.Physics:Teleport(pos:Get())
                    else
                        item.Transform:SetPosition(pos:Get())
                    end
                    if item.components.inventoryitem ~= nil then
                        item.components.inventoryitem:InheritMoisture(moisture, iswet)
                        if tossloot then
                            item.components.inventoryitem:OnDropped(true, .5)
                        end
                    end
                end
            end
        end
        SpawnPrefab("wetpouch_unwrap").Transform:SetPosition(pos:Get())
    end
    if doer ~= nil and doer.SoundEmitter ~= nil then
        doer.SoundEmitter:PlaySound("dontstarve/common/together/packaged")
    end
	--local one = inst.components.stackable and inst.components.stackable:Get() or inst
    --one:Remove()
end

local extra_droploot = { ------在这里修改互斥掉落物及其几率
	spear = 0.33,
	footballhat = 0.5,
	armorwood = 0.33,
}

local function GetRandLoot(list)
	local total = 0
	for k,v in pairs(list) do 
		total = total + v
	end
	local rand = total*math.random()
	for k,v in pairs(list) do 
		rand = rand - v
		if rand <= 0 then 
			return k
		end
	end
end 

local function OnUnwrapped_My(inst, pos, doer)---------------我去你妈的兼容性
	local stacksize = inst.components.stackable.stacksize
	for i=1,stacksize do 
		OnUnwrapped_Klei(inst, pos, doer)
		local loot = {}
		local randloot = GetRandLoot(extra_droploot)
		table.insert(loot, randloot)
		inst.components.lootdropper:SetLoot(loot)
		inst.components.lootdropper:DropLoot(pos)
	end
	inst:Remove()
end 

-- 调整原版的鱼肉度和鱼度
AddIngredientValues({"fish"}, {meat=.5,fish=.5}, true)