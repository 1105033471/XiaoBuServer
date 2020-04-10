local assets =
{
    Asset("ANIM", "anim/campfire_fire.zip"),
    Asset("SOUND", "sound/common.fsb"),
}

local heats = { 75, 90, 105, 120 }

local function GetHeatFn(inst)
    return heats[inst.components.firefx.level] or 20
end

local firelevels =
{
	-- radius:发光范围		intensity:也是范围？		falloff:扩散强度，越大则扩散越难
    {anim="level1", sound="dontstarve/common/campfire", radius=12, intensity=.8, falloff=.6, colour = {255/255,255/255,192/255}, soundintensity=.1},
    {anim="level2", sound="dontstarve/common/campfire", radius=15, intensity=.8, falloff=.6, colour = {255/255,255/255,192/255}, soundintensity=.3},
    {anim="level3", sound="dontstarve/common/campfire", radius=19, intensity=.8, falloff=.6, colour = {255/255,255/255,192/255}, soundintensity=.6},
    {anim="level4", sound="dontstarve/common/campfire", radius=23, intensity=.8, falloff=.6, colour = {255/255,255/255,192/255}, soundintensity=1},
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("campfire_fire")
    inst.AnimState:SetBuild("campfire_fire")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetFinalOffset(-1)

    inst:AddTag("FX")

    --HASHEATER (from heater component) added to pristine state for optimization
    inst:AddTag("HASHEATER")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeatFn

    inst:AddComponent("firefx")
    inst.components.firefx.levels = firelevels
	
    inst.components.firefx:SetLevel(1)
    inst.components.firefx.usedayparamforsound = true
	
	-- if inst.components.fueled == nil then
		-- inst:AddComponent("fueled")
	-- end
	-- inst.components.fueled.maxfuel = 12 * 60

    return inst
end

return Prefab("obsidianfirefire", fn, assets)
