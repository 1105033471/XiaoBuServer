-- 这个文件不要和官方的名字一样啊啊啊啊，会覆盖官方的！！！！！！！！

local function ondeploy(inst, pt, deployer)
    if deployer and deployer.SoundEmitter then
        deployer.SoundEmitter:PlaySound("dontstarve/wilson/dig")
    end

    local map = TheWorld.Map
    local original_tile_type = map:GetTileAtPoint(pt:Get())
    local x, y = map:GetTileCoordsAtPoint(pt:Get())
    if x and y then
        map:SetTile(x,y, inst.data.tile)
        map:RebuildLayer( original_tile_type, x, y )
        map:RebuildLayer( inst.data.tile, x, y )
    end

    local minimap = TheWorld.minimap.MiniMap
    minimap:RebuildLayer(original_tile_type, x, y)
    minimap:RebuildLayer(inst.data.tile, x, y)

    inst.components.stackable:Get():Remove()
end

local prefabs =
{
    "gridplacer",
}

local function make_turf(data)
    data.anim = data.anim or data.name
    data.invname = data.invname or data.name
    
    local GROUND_lookup = table.invert(GROUND)

    local assets = {
        Asset("ANIM", "anim/turf_t.zip"),
        Asset("IMAGE", "images/inventoryimages/" .. data.anim .. ".tex"),
        Asset("ATLAS", "images/inventoryimages/" .. data.anim .. ".xml"),
    }

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
    
        MakeInventoryPhysics(inst)
    
        inst:AddTag("groundtile")       -- 地皮的tag

        inst.AnimState:SetBank("turf_t")
        inst.AnimState:SetBuild("turf_t")
        --inst.AnimState:PlayAnimation(data.anim)
        inst.AnimState:PlayAnimation(data.anim)
    
        inst:AddTag("molebait")         -- 这玩意是干嘛的，忘了
        --MakeDragonflyBait(inst, 3)

        inst.entity:SetPristine()
    
        if not TheWorld.ismastersim then
            return inst
        end
    
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.atlasname = "images/inventoryimages/" .. data.anim .. ".xml"
        inst.components.inventoryitem.imagename = data.anim

        inst.data = data
    
        inst:AddComponent("bait")

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL
        MakeMediumBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)
        MakeHauntableLaunchAndIgnite(inst)

        inst:AddComponent("deployable")
        --inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
        inst.components.deployable.ondeploy = ondeploy
        inst.components.deployable:SetDeployMode(DEPLOYMODE.TURF)
        inst.components.deployable:SetUseGridPlacer(true)

        ---------------------
        return inst
    end

    return Prefab("turf_" .. data.name, fn, assets, prefabs)
end

local turfs_t = {
    -- pigruins 地砖1
    {name = "pigruins", anim = "pigruins", tile = GROUND.PIGRUINS}, -- 1
    {name = "quagmire_gateway", anim = "quagmire_gateway", tile = GROUND.QUAGMIRE_GATEWAY},  -- 2
    {name = "beach", anim = "pigruins", tile = GROUND.BEACH},
}

local turfs_prefab = {}
for k, v in ipairs(turfs_t) do
    table.insert(turfs_prefab, make_turf(v))
end

return unpack(turfs_prefab)
