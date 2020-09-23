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

-- 继承父类Brain
local SharkittenBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

-- 这里的返回不是visit节点后的返回值，只是设置visit该节点后，该节点的状态
-- BT(inst, root) 行为树 root为行为树的根节点
-- BehaviourNode(name, children) 行为节点 是所有节点以及行为的父类，通常不会直接出现在brain中 children为当前节点的子节点集
    -- DecoratorNode(name, child) 装饰节点 装饰节点带有1个子节点，通常用来对子节点的值做一定的变换，分为以下三种：
        -- NotDecorator(child) 返回子节点运行结果的非，如子节点运行结果为SUCCESS，则返回FAIL，子节点运行结果为RUNING则返回RUNING
        -- FailIfRunningDecorator(child) 如果子节点返回RUNING，则返回FAIL，否则返回子节点运行结果
        -- FailIfSuccessDecorator(child) 如果子节点返回SUCCESS，则返回FAIL，否则返回子节点运行结果
    -- ConditionNode(fn, name) 条件节点 如果fn()条件满足，则返回SUCCESS，否则返回FAIL
    -- ConditionWaitNode(fn, name) 条件满足等待节点 如果fn()条件满足，则返回SUCCESS，否则返回RUNING
    -- ActionNode(action, name) 动作节点 执行指定的动作后，返回SUCCESS
    -- WaitNode(time) 等待节点 等待指定的延迟后，返回SUCCESS，等待中返回RUNING
    -- SequenceNode(children) 序列节点 依次执行所有的子节点，直到第一个没有SUCCESS的子节点，如果子节点执行结果为FAIL，则下次Visit从头开始
    -- SelectorNode(children) 选择节点 依次执行所有的子节点，如果某一子节点返回不是FAIL，则返回该子节点状态
    -- LoopNode(children, maxreps) 循环节点 依次执行所有的子节点，每一次visit，如果有子节点返回FAIL，则从头开始，如果有子节点返回RUNING则返回RUNING，如果所有子节点
                                    -- 都返回SUCCESS，则循环计数+1，如果有设置最大循环次数并且当前循环次数超过最大值，则返回SUCCESS，否则重置所有子节点
                                    -- 循环节点和序列节点有点类似，只是多了个循环计数
    -- RandomNode(children) 随机访问节点 随机从一个子节点开始按顺序访问所有子节点，如果所有子节点都返回FAIL则返回FAIL，否则返回
    -- PriorityNode(children, period, noscatter) 优先度节点，通常作为一棵行为树的根节点，children为子节点集，period为优先度
                                    -- TODO
    -- ParallelNode(child, name) 并行节点 同时执行所有子节点，如果都执行完毕返回SUCCESS，否则返回RUNING
        -- ParallelNodeAny(child) 并行节点 同时执行所有子节点，如果有一个子节点执行完毕则返回SUCCESS，否则返回RUNING
    -- EventNode(inst, event, child, priority) 事件节点 监听到对应事件后执行子节点
    -- LatchNode = （inst, latchduration, child)
-- WhileNode(cond, name, node)
-- IfNode(cond, name, node)

-- behaviours(行为) 行为是作为行为树的叶子节点，同样继承于BehaviourNode
-- AttackWall(inst) 攻击面前的墙体
-- AvoidLight(inst) 暂时没有东西用到，可能是废弃了。。。


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