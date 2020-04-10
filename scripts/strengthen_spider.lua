-- 蜘蛛
TUNING.SPIDER_HEALTH = 200
TUNING.SPIDER_DAMAGE = 30
TUNING.SPIDER_ATTACK_PERIOD = 2
TUNING.SPIDER_WALK_SPEED = 5
TUNING.SPIDER_RUN_SPEED = 8
AddPrefabPostInit("spider", function(inst)
	if inst.components.health then
		inst.components.health.absorb = .2
	end
	if inst.components.lootdropper then
		inst.components.lootdropper:SetLoot({ "monstermeat" })
		inst.components.lootdropper:SpawnLootPrefab("pigskin")
		inst.components.lootdropper:AddRandomLoot("spidergland", .6)
		inst.components.lootdropper:AddRandomLoot("silk", .6)
		inst.components.lootdropper:AddRandomLoot("redgem", .1)
		inst.components.lootdropper:AddRandomLoot("bluegem", .1)
		inst.components.lootdropper:AddRandomLoot("purplegem", .05)
		inst.components.lootdropper.numrandomloot = 1
	end
end)

-- 蜘蛛巢
local function IsDefender(child)
    return child.prefab == "spider_warrior"
end

local function SpawnDefenders(inst, attacker)
	---[[
	if not inst.components.health:IsDead() then
        inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_hit")
        inst.AnimState:PlayAnimation(inst.anims.hit)
        inst.AnimState:PushAnimation(inst.anims.idle)
        if inst.components.childspawner ~= nil then
            local max_release_per_stage = { 2, 4, 6 }
            local num_to_release = math.min(max_release_per_stage[inst.data.stage] or 1, inst.components.childspawner.childreninside)
            local num_warriors = math.min(num_to_release, TUNING.SPIDERDEN_WARRIORS[inst.data.stage])
            num_to_release = math.floor(SpringCombatMod(num_to_release))
            num_warriors = math.floor(SpringCombatMod(num_warriors))
            num_warriors = num_warriors - inst.components.childspawner:CountChildrenOutside(IsDefender)
            for k = 1, num_to_release do
                inst.components.childspawner.childname = k <= num_warriors and "spider_warrior" or "spider"
                local spider = inst.components.childspawner:SpawnChild()
                if spider ~= nil and attacker ~= nil and spider.components.combat ~= nil then
                    spider.components.combat:SetTarget(attacker)
                    spider.components.combat:BlankOutAttacks(1.5 + math.random() * 2)
					
					if spider.components.health ~= nil then
						spider.components.health:SetMaxHealth(999)
					end
                end
            end
            inst.components.childspawner.childname = "spider"

            local emergencyspider = inst.components.childspawner:TrySpawnEmergencyChild()
            if emergencyspider ~= nil then
                emergencyspider.components.combat:SetTarget(attacker)
                emergencyspider.components.combat:BlankOutAttacks(1.5 + math.random() * 2)
            end
        end
    end
	--]]
end

local function SetStage(inst, stage)
    if stage <= 3 and inst.components.childspawner ~= nil then -- if childspawner doesn't exist, then this den is burning down
        inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spiderLair_grow")
        inst.components.childspawner:SetMaxChildren(math.floor(SpringCombatMod(TUNING.SPIDERDEN_SPIDERS[stage])))
        inst.components.childspawner:SetMaxEmergencyChildren(TUNING.SPIDERDEN_EMERGENCY_WARRIORS[stage])
        inst.components.childspawner:SetEmergencyRadius(TUNING.SPIDERDEN_EMERGENCY_RADIUS[stage])
        inst.components.health:SetMaxHealth(TUNING.SPIDERDEN_HEALTH[stage])

        inst.AnimState:PlayAnimation(inst.anims.init)
        inst.AnimState:PushAnimation(inst.anims.idle, true)
    end

    inst.components.upgradeable:SetStage(stage)
    inst.data.stage = stage -- track here, as growable component may go away
end

local function SetLarge(inst)
    inst.anims = {
        hit = "cocoon_large_hit",
        idle = "cocoon_large",
        init = "grow_medium_to_large",
        freeze = "frozen_large",
        thaw = "frozen_loop_pst_large",
    }
    SetStage(inst, 3)
    inst.components.lootdropper:SetLoot({ "silk", "silk", "silk", "silk", "silk", "silk", "spidereggsack" })

    if inst.components.burnable ~= nil then
        inst.components.burnable:SetFXLevel(4)
        inst.components.burnable:SetBurnTime(30)
    end

    if inst.components.freezable ~= nil then
        inst.components.freezable:SetShatterFXLevel(5)
        inst.components.freezable:SetResistance(4)
    end

    local my_x, my_y, my_z = inst.Transform:GetWorldPosition()
    if TheWorld.Map:GetPlatformAtPoint(my_x, my_z) == nil then
        inst.GroundCreepEntity:SetRadius(9)
    end
end

local function PlayLegBurstSound(inst)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spiderqueen/legburst")
end

local function SpawnQueen(inst, should_duplicate)
    local map = TheWorld.Map
    local x, y, z = inst.Transform:GetWorldPosition()
    local offs = FindValidPositionByFan(math.random() * 2 * PI, 1.25, 5, function(offset)
        local x1 = x + offset.x
        local z1 = z + offset.z
        return map:IsPassableAtPoint(x1, 0, z1)
            and not map:IsPointNearHole(Vector3(x1, 0, z1))
    end)

    if offs ~= nil then
        x = x + offs.x
        z = z + offs.z
    end

    local queen = SpawnPrefab("spiderqueen")
    queen.Transform:SetPosition(x, 0, z)
    queen.sg:GoToState("birth")

    if not should_duplicate then
        inst:Remove()
    end
end

local function AttemptMakeQueen(inst)
	---[[
	if inst.components.growable == nil then
        --failsafe in case we still got here after we are burning
        return
    end

    if inst.data.stage == nil or inst.data.stage ~= 3 then
        -- we got here directly (probably by loading), so reconfigure to the level 3 state.
        SetLarge(inst)
    end

    if not inst:IsNearPlayer(30) then
        inst.components.growable:StartGrowing(60 + math.random(60))
        return
    end

    local check_range = 60
    local cap = 4
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, check_range, nil, nil, { "spiderden", "spiderqueen" })
    local num_dens = #ents

    inst.components.growable:SetStage(1)

    inst.AnimState:PlayAnimation("cocoon_large_burst")
    inst.AnimState:PushAnimation("cocoon_large_burst_pst")
    inst.AnimState:PushAnimation("cocoon_small", true)

    PlayLegBurstSound(inst)
    inst:DoTaskInTime(5 * FRAMES, PlayLegBurstSound)
    inst:DoTaskInTime(15 * FRAMES, PlayLegBurstSound)
    inst:DoTaskInTime(35 * FRAMES, SpawnQueen, num_dens < cap)

    inst.components.growable:StartGrowing(60)
    return true
end

local function CanTarget(guy)
    return not guy.components.health:IsDead()
end

local function OnHaunt(inst)
	---[[
	if math.random() <= TUNING.HAUNT_CHANCE_HALF then
        local target = FindEntity(
            inst,
            25,
            CanTarget,
            { "_combat", "_health", "character" }, --see entityreplica.lua
            { "player", "spider", "INLIMBO" }
        )
        if target ~= nil then
            SpawnDefenders(inst, target)
            inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
            return true
        end
    end

    if inst.data.stage == 3 and
        math.random() <= TUNING.HAUNT_CHANCE_RARE and
        AttemptMakeQueen(inst) then
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE
        return true
    end
	--]]
    return false
end

local function setHauntFunction(inst)
	if inst.components.hauntable ~= nil then
		inst.components.hauntable:SetOnHauntFn(OnHaunt)
	end
end

spiderden_list = {
	"spiderden",
	"spiderden_2",
	"spiderden_3"
}

for k,item_name in pairs(spiderden_list) do
	AddPrefabPostInit(item_name, setHauntFunction)
end
