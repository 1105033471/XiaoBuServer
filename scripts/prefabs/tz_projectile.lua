local assets = {
    Asset("ANIM", "anim/baiball_2_fx.zip"),
    Asset("ANIM", "anim/deer_bai_charge.zip"),
}

local assets_2 = {
	Asset("ANIM", "anim/baiball_2_fx.zip"),
}

local prefabs = {
	"tz_baiball_hit_fx",
}

local function CreateTail()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    inst.Physics:ClearCollisionMask()

    inst.AnimState:SetBank("baiball_2_fx")
    inst.AnimState:SetBuild("baiball_2_fx")
    inst.AnimState:PlayAnimation("disappear")
    inst.AnimState:SetMultColour(1, 1, 1, 1)
    inst.AnimState:SetFinalOffset(-1)

    inst:ListenForEvent("animover", inst.Remove)

    return inst
end

local function OnUpdateProjectileTail(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local tails = {}
	
	for tail, _ in pairs(tails) do
        tail:ForceFacePoint(x, y, z)
    end
    if inst.entity:IsVisible() then
        local tail = CreateTail()
        local rot = inst.Transform:GetRotation()
        tail.Transform:SetRotation(rot)
        rot = rot * DEGREES
        local offsangle = math.random() * 2 * PI
        local offsradius = math.random() * .2 + .2
        local hoffset = math.cos(offsangle) * offsradius
        local voffset = math.sin(offsangle) * offsradius
        tail.Transform:SetPosition(x + math.sin(rot) * hoffset, y + voffset, z + math.cos(rot) * hoffset)
        tail.Physics:SetMotorVel(15 * (.2 + math.random() * .3), 0, 0)
        tails[tail] = true
        inst:ListenForEvent("onremove", function(tail)
            tails[tail] = nil
        end, tail)
        tail:ListenForEvent("onremove", function(inst)
            tail.Transform:SetRotation(tail.Transform:GetRotation() + math.random() * 30 - 15)
        end, inst)
    end
end


local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)

	inst.AnimState:SetBank("baiball_2_fx")
	inst.AnimState:SetBuild("baiball_2_fx")
	inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:SetFinalOffset(-1)
	inst.AnimState:SetMultColour(1, 1, 1, 1)
	
	inst:AddTag("projectile")

	if not TheNet:IsDedicated() then
		--??
		inst:DoPeriodicTask(0, OnUpdateProjectileTail, nil)
	end
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	inst.persists = false
	inst:AddComponent("projectile")
	inst.components.projectile:SetSpeed(15)
	inst.components.projectile:SetOnMissFn(inst.Remove)
	inst.components.projectile:SetOnHitFn(function(inst, owner, target)
		if target:IsValid() then
			local fx = SpawnPrefab("tz_baiball_hit_fx")
			fx.Transform:SetPosition(target.Transform:GetWorldPosition())
		end
		inst:Remove()
	end)
	return inst
end

local function fireballbaihit_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("fireball_fx")
    inst.AnimState:SetBuild("deer_bai_charge")
    inst.AnimState:PlayAnimation("blast")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(-1)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    inst:ListenForEvent("animover", inst.Remove)
    inst.persists = false
    inst:DoTaskInTime(1, inst.Remove)
    return inst
end

return
Prefab("tz_projectile_bai", fn, assets_2, prefabs),
Prefab("tz_baiball_hit_fx", fireballbaihit_fn, assets)
