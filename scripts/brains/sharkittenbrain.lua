require "behaviours/follow"
require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/panic"
require "behaviours/runaway"

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 12
local TARGET_FOLLOW_DIST = 6
local MAX_WANDER_DIST = 4

local SEE_FOOD_DIST = 15

local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5

local FOOD_TAGS = {"kittenchow"}
local NO_TAGS = {"FX", "NOCLICK", "DECOR","INLIMBO"}

local function EatFoodAction(inst)  --Look for food to eat.
    local target = nil
    local action = nil

    if inst.sg:HasStateTag("busy") and not
    inst.sg:HasStateTag("wantstoeat") then
        return
    end

    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, SEE_FOOD_DIST, FOOD_TAGS, NO_TAGS)

    if not target then
        for k,v in pairs(ents) do
            if v and v:IsOnValidGround() and
            inst.components.eater:CanEat(v) and
            v:GetTimeAlive() > 5 and
            v.components.inventoryitem and not
            v.components.inventoryitem:IsHeld() then
                target = v
                break
            end
        end
    end

    if target then
        local action = BufferedAction(inst,target,ACTIONS.EAT)
        return action
    end
end

local function GetFaceTargetFn(inst)
    return FindEntity(inst, 5, nil, {"tigershark"})
end

local function KeepFaceTargetFn(inst, target)
    return inst:GetPosition():Dist(target:GetPosition()) < 10
end

local function GoHomeAction(inst)
    if inst.components.homeseeker and 
       inst.components.homeseeker.home and 
       inst.components.homeseeker.home:IsValid() then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function HomeOffset(inst)
    local home = inst.components.homeseeker and inst.components.homeseeker.home

    if home then
        local rad = home.Physics:GetRadius() + inst.Physics:GetRadius() + 0.2
        local vec = (inst:GetPosition() - home:GetPosition()):Normalize()
        local offset = Vector3(vec.x * rad, 0, vec.z * rad)

        return home:GetPosition() + offset
    else
        return inst:GetPosition()
    end
end

-- �̳и���Brain
local SharkittenBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

-- ����ķ��ز���visit�ڵ��ķ���ֵ��ֻ������visit�ýڵ�󣬸ýڵ��״̬
-- BT(inst, root) ��Ϊ�� rootΪ��Ϊ���ĸ��ڵ�
-- BehaviourNode(name, children) ��Ϊ�ڵ� �����нڵ��Լ���Ϊ�ĸ��࣬ͨ������ֱ�ӳ�����brain�� childrenΪ��ǰ�ڵ���ӽڵ㼯
    -- DecoratorNode(name, child) װ�νڵ� װ�νڵ����1���ӽڵ㣬ͨ���������ӽڵ��ֵ��һ���ı任����Ϊ�������֣�
        -- NotDecorator(child) �����ӽڵ����н���ķǣ����ӽڵ����н��ΪSUCCESS���򷵻�FAIL���ӽڵ����н��ΪRUNING�򷵻�RUNING
        -- FailIfRunningDecorator(child) ����ӽڵ㷵��RUNING���򷵻�FAIL�����򷵻��ӽڵ����н��
        -- FailIfSuccessDecorator(child) ����ӽڵ㷵��SUCCESS���򷵻�FAIL�����򷵻��ӽڵ����н��
    -- ConditionNode(fn, name) �����ڵ� ���fn()�������㣬�򷵻�SUCCESS�����򷵻�FAIL
    -- ConditionWaitNode(fn, name) ��������ȴ��ڵ� ���fn()�������㣬�򷵻�SUCCESS�����򷵻�RUNING
    -- ActionNode(action, name) �����ڵ� ִ��ָ���Ķ����󣬷���SUCCESS
    -- WaitNode(time) �ȴ��ڵ� �ȴ�ָ�����ӳٺ󣬷���SUCCESS���ȴ��з���RUNING
    -- SequenceNode(children) ���нڵ� ����ִ�����е��ӽڵ㣬ֱ����һ��û��SUCCESS���ӽڵ㣬����ӽڵ�ִ�н��ΪFAIL�����´�Visit��ͷ��ʼ
    -- SelectorNode(children) ѡ��ڵ� ����ִ�����е��ӽڵ㣬���ĳһ�ӽڵ㷵�ز���FAIL���򷵻ظ��ӽڵ�״̬
    -- LoopNode(children, maxreps) ѭ���ڵ� ����ִ�����е��ӽڵ㣬ÿһ��visit��������ӽڵ㷵��FAIL�����ͷ��ʼ��������ӽڵ㷵��RUNING�򷵻�RUNING����������ӽڵ�
                                    -- ������SUCCESS����ѭ������+1��������������ѭ���������ҵ�ǰѭ�������������ֵ���򷵻�SUCCESS���������������ӽڵ�
                                    -- ѭ���ڵ�����нڵ��е����ƣ�ֻ�Ƕ��˸�ѭ������
    -- RandomNode(children) ������ʽڵ� �����һ���ӽڵ㿪ʼ��˳����������ӽڵ㣬��������ӽڵ㶼����FAIL�򷵻�FAIL�����򷵻�
    -- PriorityNode(children, period, noscatter) ���ȶȽڵ㣬ͨ����Ϊһ����Ϊ���ĸ��ڵ㣬childrenΪ�ӽڵ㼯��periodΪ���ȶ�
                                    -- TODO
    -- ParallelNode(child, name) ���нڵ� ͬʱִ�������ӽڵ㣬�����ִ����Ϸ���SUCCESS�����򷵻�RUNING
        -- ParallelNodeAny(child) ���нڵ� ͬʱִ�������ӽڵ㣬�����һ���ӽڵ�ִ������򷵻�SUCCESS�����򷵻�RUNING
    -- EventNode(inst, event, child, priority) �¼��ڵ� ��������Ӧ�¼���ִ���ӽڵ�
    -- LatchNode = ��inst, latchduration, child)
-- WhileNode(cond, name, node)
-- IfNode(cond, name, node)

-- behaviours(��Ϊ) ��Ϊ����Ϊ��Ϊ����Ҷ�ӽڵ㣬ͬ���̳���BehaviourNode
-- AttackWall(inst) ������ǰ��ǽ��
-- AvoidLight(inst) ��ʱû�ж����õ��������Ƿ����ˡ�����


function SharkittenBrain:OnStart()
    local root =
    PriorityNode({
        EventNode(self.inst, "gohome", 
            DoAction(self.inst, GoHomeAction, "go home", true )),
        DoAction(self.inst, EatFoodAction),
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst, function() return HomeOffset(self.inst) end, MAX_WANDER_DIST),
    }, .25)
    self.bt = BT(self.inst, root)
end

return SharkittenBrain