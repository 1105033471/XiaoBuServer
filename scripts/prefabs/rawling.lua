local assets =
{
	Asset("ANIM", "anim/basketball.zip"),
	Asset("ANIM", "anim/swap_basketball.zip"),
}

local prefabs =
{

}

local function onthrown(inst, thrower, pt)
    inst:AddTag("NOCLICK")

    inst.AnimState:PlayAnimation("throw", true)

    inst.Physics:SetMass(1)				-- 集群
    inst.Physics:SetCapsule(0.2, 0.2)	-- 设置胶囊？
    inst.Physics:SetFriction(0)			-- 摩擦力
    inst.Physics:SetDamping(0)			-- 阻尼
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)	-- 碰撞单位
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
	inst.Physics:CollidesWith(COLLISION.ITEMS)
end

local function OnHit(inst, attacker, target)	-- 这里的target是个假的。。。神TM官方
    SpawnPrefab("waterballoon_splash").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.components.wateryprotection:SpreadProtection(inst)
	
    inst:RemoveTag("NOCLICK")
    inst.AnimState:PlayAnimation("idle")

	if attacker.components.sanity then
		attacker.components.sanity:DoDelta(TUNING.SANITY_SUPERTINY)
	end
	
	local target = FindEntity(inst, 2.5, nil, { "player" }, { "playerghost", "busy" })
	if target ~= nil then
		-- print("接住！")
		if not (target.components.health ~= nil and target.components.health:IsDead()) then  --玩家还活着，自动接住
            -- 如果使用者已装备手持武器，就放进物品栏，没有的话就直接装备上
            if inst.components.equippable ~= nil and not target.components.inventory:GetEquippedItem(inst.components.equippable.equipslot) then
                target.components.inventory:Equip(inst)
            else
                target.components.inventory:GiveItem(inst)
            end
        else  --玩家已死亡，落到地面
            inst.AnimState:PlayAnimation("idle")
		end
		
		target.components.talker:Say("接住了！")
		target.components.sanity:DoDelta(TUNING.SANITY_SUPERTINY * 2)
	end
end

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
	local pos = Vector3()
	
    for r = 6.5, 3.5, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_basketball", "swap_basketball")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_object")
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function fn()
    local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    
	inst.AnimState:SetBank("basketball")
	inst.AnimState:SetBuild("basketball")
	inst.AnimState:PlayAnimation("idle")
	
	MakeInventoryFloatable(inst, "idle_water", "idle")

	inst:AddTag("nopunch")
	
    --projectile (from complexprojectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    
	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/rawling.xml"

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.equipstack = true
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

	inst:AddComponent("wateryprotection")	-- 灭火组件
	
    inst:AddComponent("complexprojectile")		-- 复杂抛射物组件
    inst.components.complexprojectile:SetHorizontalSpeed(25)	-- 水平速度
    inst.components.complexprojectile:SetGravity(-35)		-- 重力
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))	-- 发射偏移
    inst.components.complexprojectile:SetOnLaunch(onthrown)
    inst.components.complexprojectile:SetOnHit(OnHit)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ease = true

	return inst
end

return Prefab( "rawling", fn, assets, prefabs)
