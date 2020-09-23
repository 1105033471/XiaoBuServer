require("stategraphs/commonstates")

-- ActionHandler(action, state, condition) ִ�ж���������������ʱ�����Ӧ״̬
-- EventHandler(name, fn) ��������Ӧ�¼���ִ����Ӧ����
-- TimeEvent(time, fn) �ڽ���״̬��time�ӳ�ʱ��ִ����Ӧ�ĺ���
-- State(args)  ״̬����״̬
        -- args.name ״̬��
        -- args.onenter(inst, params) �ڽ���״̬ʱ��ִ�еĺ���������Ĳ���Ϊinst.sg.GoToState("xxx", params)
        -- args.onexit(inst)    ���뿪״̬ʱ��ִ�еĺ��� Ҳ����inst.sg.GoToStateʱ����
        -- args.onupdate() ��״̬������ʱ��ִ�еĺ��� �����ˢ��Ӧ����ÿһ֡
        -- args.ontimeout(inst) ������timeout�¼�ʱ��ִ�еĺ����������timeout�¼���inst.sg:SetTimeout(time)����
        -- args.tags �����Ӧ״̬ʱ����inst��ӵı�ǩ������Ҫ�ر�ע�⣡
                    -- 1. ʵ��ı�ǩ������״̬�����õı�ǩ������Ϊ��ÿ���л�״̬ʱ�����Ƴ�����Ŀ��״̬û�е�tag���������ʵ���״̬��������һ��tag����ᷢ����ͻ
                    -- 2. ״̬��Ӧ��tag�������д������¼�һ��tag����Ҫ�޸�SGTagsToEntTags�����Ǹ�local��
        -- args.events �����Ӧ״̬ʱ�����õļ����¼������������뿪״̬ʱ�Ƴ�
        -- args.timeline �ڽ���״̬�󣬰�ָ����ʱ��˳��ִ����Ӧ���������뿪״̬ʱ�Ƴ�
-- StateGraph(name, states, events, defaultstate, actionhandles) ����������sg������Ŀ�꣬һ��������״̬��
    -- name ״̬��������
    -- states ״̬����״̬��
    -- events ״̬������Ҫ������¼���������������State���events������������״̬����Ҫ������¼�
    -- defaultstate ��ʼ״̬
    -- actionhandlers ״̬����Ҫ��������ж���

-- StateGraphInstance ����״̬���ṩ��ʵ�����sg�Ľӿڣ������о�һ��inst.sg��ʹ�õ�һЩ����
    -- GetTimeInState() ��ȡ��ǰ״̬������ʱ��
    -- PlayRandomAnim(anims, loop) ������Ŷ����б��е�һ������
    -- PushEvent(event, data) ��ǰ״̬����һ���¼��������data��ʵûɶ�ã����Բ�����
    -- IsListeningForEvent(event) ��ǰ״̬�Ƿ����ڼ���ĳһ�¼��������������״̬����Ҫ������¼�
    -- PreviewAction(action) ִ��ĳһ��������������״̬����Ӧ��ActionHandler
    -- StartAction(action) ִ��ĳһ�����������PreviewAction���쳣��������һ��ϸ΢������
    -------- HandleEvents() ���ﲻ���ṩ��modderʹ�õģ������ṩ��ȫ�ֵ�״̬��������ʹ�ã���Updateʱ���ã��������еĻ������¼�
    -------- ClearBufferedEvents() ����������¼���ͬ�������ṩ��modderʹ��
    -- InNewState() ��ǰ�Ƿ����µ�״̬
    -- HasState(state) ״̬���Ƿ���ĳһ״̬
    -- GoToState(state, params) ��״̬��Ǩ�Ƶ�ָ����״̬
    -- AddStateTag(tag) ��ǰ״̬���һ��״̬��tag��ע�⣡
                -- 1. ָ����tag����SGTagsToEntTags����ʱ�������ʵ�����tag
                -- 2. ��״̬Ǩ��ʱ����tag�ᱻ��Ч����������״̬��Ҳͬ������˸�tag
    -- RemoveStateTag(tag) ��ǰ״̬�Ƴ�һ��״̬��tag������ʵ�壬ֻ���Ƴ�SGTagsToEntTags���д��ڵ�tag
    -- HasStateTag(tag) ��ǰ״̬�Ƿ�ӵ��ĳһ״̬��tag������ӵ��tag���������Ӧ��ʵ��Ҳ�и�tag
    -- SetTimeout(time) ���ó�ʱ�¼������¼���ʱʱ��ִ��״̬������״̬��Ӧ��ontimeout
    
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
