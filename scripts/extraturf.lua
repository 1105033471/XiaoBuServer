local assets = {
    Asset("IMAGE", "levels/textures/noise_pigruins.tex"),
    Asset("IMAGE", "levels/textures/mini_noise_pigruins.tex"),
}

for _,v in pairs(assets) do
    table.insert(Assets, v)
end

local prefabfiles = {
    "turfs_t",
}

for _,v in pairs(prefabfiles) do
    table.insert(PrefabFiles, v)
end

local MOD_GROUND_TURFS = {
    [GROUND.PIGRUINS] = "turf_pigruins",
    [GROUND.QUAGMIRE_GATEWAY] = "turf_quagmire_gateway",
}

local function SpawnTurf(turf, pt)      -- 在指定地点生成地形
    if turf ~= nil then
        local loot = SpawnPrefab(turf)

        if loot.components.inventoryitem ~= nil then
            loot.components.inventoryitem:InheritMoisture(TheWorld.state.wetness, TheWorld.state.iswet)
        end

        loot.Transform:SetPosition(pt:Get())

        if loot.Physics ~= nil then
            local angle = math.random() * 2 * PI
            loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))

			loot:DoTaskInTime(0.5, function(inst)   -- 地皮自动堆叠(新地皮)
				if inst:IsValid() then
					local pos = inst:GetPosition()
					local x, y, z = pos:Get()
					local ents = TheSim:FindEntities(x, y, z, 10, { "_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
					for _,obj in pairs(ents) do
						LM_AnimPut(loot, obj)
					end
				end
			end)
        end
    end
end

-- Not necessary for the AddComponentPostInit version
local Terraformer = require("components/terraformer")
local OldTerraform = Terraformer.Terraform or function() return false end

-- A heavily-gutted version of the original Terraform function
-- Ultimately, it checks for the turf type at the intended dig spot and will spawn it if the original function didn't
function Terraformer:Terraform(pt, spawnturf)       -- 地形生成器
    if not TheWorld.Map:CanTerraformAtPoint(pt:Get()) then
        return false
    end

    local original_tile_type = TheWorld.Map:GetTileAtPoint(pt:Get())
    --local dugSomethingUp = OldTerraform(self, pt)

    -- If the old terraform successfully dug up some turf and it's a ruins turf, spawn the item
    if OldTerraform(self, pt, spawnturf) then
        local turfPrefab = MOD_GROUND_TURFS[original_tile_type]

        if spawnturf and turfPrefab ~= nil then
            SpawnTurf(turfPrefab, pt)
        end

        return true
    end

    return false
end

-- end