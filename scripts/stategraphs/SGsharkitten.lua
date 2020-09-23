require("stategraphs/commonstates")

-- ActionHandler(action, state, condition) 执行动作，在条件满足时进入对应状态
-- EventHandler(name, fn) 监听到对应事件后，执行相应函数
-- TimeEvent(time, fn) 在进入状态后time延迟时，执行相应的函数
-- State(args)  状态机的状态
        -- args.name 状态名
        -- args.onenter(inst, params) 在进入状态时，执行的函数，这里的参数为inst.sg.GoToState("xxx", params)
        -- args.onexit(inst)    在离开状态时，执行的函数 也是在inst.sg.GoToState时触发
        -- args.onupdate() 在状态机更新时，执行的函数 这里的刷新应该是每一帧
        -- args.ontimeout(inst) 监听到timeout事件时，执行的函数，这里的timeout事件由inst.sg:SetTimeout(time)设置
        -- args.tags 进入对应状态时，给inst添加的标签，这里要特别注意！
                    -- 1. 实体的标签不能用状态机所用的标签集，因为在每次切换状态时，会移除所有目标状态没有的tag，这里如果实体和状态机共用了一个tag，则会发生冲突
                    -- 2. 状态对应的tag不是随便写，如果新加一个tag可能要修改SGTagsToEntTags表，这是个local表
        -- args.events 进入对应状态时，设置的监听事件处理器，在离开状态时移除
        -- args.timeline 在进入状态后，按指定的时间顺序执行相应函数，在离开状态时移除
-- StateGraph(name, states, events, defaultstate, actionhandles) 这里是所有sg的最终目标，一个完整的状态机
    -- name 状态机的名字
    -- states 状态机的状态集
    -- events 状态机所需要处理的事件集，这里区别于State里的events，这里是所有状态都需要处理的事件
    -- defaultstate 初始状态
    -- actionhandlers 状态机所要处理的所有动作

-- StateGraphInstance 这是状态机提供给实体添加sg的接口，这里列举一下inst.sg能使用的一些函数
    -- GetTimeInState() 获取当前状态持续的时间
    -- PlayRandomAnim(anims, loop) 随机播放动画列表中的一个动画
    -- PushEvent(event, data) 向当前状态推送一个事件，这里的data其实没啥用，可以不用填
    -- IsListeningForEvent(event) 当前状态是否正在监听某一事件，这里包括所有状态都需要处理的事件
    -- PreviewAction(action) 执行某一动作，这里会调用状态机对应的ActionHandler
    -- StartAction(action) 执行某一动作，这里和PreviewAction在异常处理上有一点细微的区别
    -------- HandleEvents() 这里不是提供给modder使用的，而是提供给全局的状态机管理器使用，在Update时调用，处理所有的缓冲区事件
    -------- ClearBufferedEvents() 清除缓冲区事件，同样不是提供给modder使用
    -- InNewState() 当前是否在新的状态
    -- HasState(state) 状态机是否有某一状态
    -- GoToState(state, params) 将状态机迁移到指定的状态
    -- AddStateTag(tag) 向当前状态添加一个状态机tag，注意！
                -- 1. 指定的tag不在SGTagsToEntTags表中时，不会给实体添加tag
                -- 2. 当状态迁移时，该tag会被无效化，除非新状态中也同样添加了该tag
    -- RemoveStateTag(tag) 向当前状态移除一个状态机tag，对于实体，只会移除SGTagsToEntTags表中存在的tag
    -- HasStateTag(tag) 当前状态是否拥有某一状态机tag，这里拥有tag并不代表对应的实体也有该tag
    -- SetTimeout(time) 设置超时事件，在事件超时时，执行状态机所在状态对应的ontimeout
    
local actionhandlers =
{
	ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.GOHOME, "action"),
}

local events=
{
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst, data) if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then inst.sg:GoToState("attack", data.target) end end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnLocomote(false,true),
    CommonHandlers.OnFreeze(),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            -- inst.SoundEmitter:PlaySound("sound/dontstarve_DLC002/creatures/tiger_kitten/idle", "idle")
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
            inst.sg:SetTimeout(2*math.random()+.5)
        end,
        
        onexit = function(inst, playanim)
            inst.SoundEmitter:KillSound("idle")
        end,
    },

    State{
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,

        timeline=
        {

            TimeEvent( 5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/attack_voice") end),
			TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/attack_bite") end),
            TimeEvent(16*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst) if math.random() < .333 then inst.components.combat:SetTarget(nil) inst.sg:GoToState("taunt") else inst.sg:GoToState("idle", "atk_pst") end end),
        },
    },

	State{
        name = "eat",
        tags = {"busy"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat_pre")
            inst.AnimState:PushAnimation("eat_loop")
            inst.AnimState:PushAnimation("eat_pst", false)
        end,

		timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/attack_bite") end),
            TimeEvent(11*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "hit",
        tags = {"busy", "hit"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
        end,

        timeline=
        {
            TimeEvent( 0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/hit_bodyfall") end),
            TimeEvent( 5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/hit_voice") end),
        },

        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
		name = "taunt",
        tags = {"busy"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,

		timeline=
        {
			TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/taunt") end),
			TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/taunt") end),
        },

        events=
        {
            EventHandler("animover", function(inst) if math.random() < .333 then inst.sg:GoToState("taunt") else inst.sg:GoToState("idle") end end),
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/death_A")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        end,
    },

    State{
        name = "action",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation('idle')
        end,

        events =
        {
			EventHandler("animover", function(inst) 
                inst:PerformBufferedAction()
                inst.sg:GoToState("idle") 
            end),
        },
    },
}

CommonStates.AddSleepStates(states,
{
	sleeptimeline = {
        -- TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("sound/dontstarve_DLC002/creatures/tiger_kitten/sleep") end),
	},
})

CommonStates.AddWalkStates(states,
{
    walktimeline = {
        TimeEvent(5*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/walk_voice")
            inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/walk_bounce")
        end),
        TimeEvent(20*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/walk_voice")
            inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/walk_bounce")
        end),
    },    
})

CommonStates.AddRunStates(states,
{
    runtimeline = {
        TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/walk_voice") end),
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/walk_bounce") end),
        TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/walk_bounce") end),
		TimeEvent(31*FRAMES, function(inst) inst.SoundEmitter:PlaySound("volcano/creatures/tiger_kitten/walk_bounce") end),
	},
})

CommonStates.AddFrozenStates(states)

return StateGraph("sharkitten", states, events, "idle", actionhandlers)
