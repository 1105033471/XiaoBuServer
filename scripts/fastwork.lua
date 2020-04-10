AddStategraphPostInit("wilson", function(sg)
	local state_dolongaction = sg.states["dolongaction"]
	state_dolongaction.onenter = function(inst)
		inst.components.locomotor:Stop()
		inst.AnimState:PlayAnimation("pickup")

		inst.sg.statemem.action = inst.bufferedaction
		inst.sg:SetTimeout(5 * FRAMES)
	end
	state_dolongaction.timeline =
	{
		TimeEvent(2 * FRAMES, function(inst)
			inst.sg:RemoveStateTag("busy")
		end),
		TimeEvent(3 * FRAMES, function(inst)
			inst:PerformBufferedAction()
		end),
	}
	state_dolongaction.ontimeout = function(inst)
		inst.sg:GoToState("idle", true)
	end
	state_dolongaction.onexit = function(inst)
		if inst.bufferedaction == inst.sg.statemem.action then
			inst:ClearBufferedAction()
		end
	end
	state_dolongaction.events =
	{
		
	}

	local state_doshortaction = sg.states["doshortaction"]
	state_doshortaction.onenter = function(inst)
		inst.components.locomotor:Stop()
		inst.AnimState:PlayAnimation("pickup")

		inst.sg.statemem.action = inst.bufferedaction
		inst.sg:SetTimeout(5 * FRAMES)
	end
	state_doshortaction.timeline =
	{
		TimeEvent(2 * FRAMES, function(inst)
			inst.sg:RemoveStateTag("busy")
		end),
		TimeEvent(3 * FRAMES, function(inst)
			inst:PerformBufferedAction()
		end),
	}
	state_doshortaction.ontimeout = function(inst)
		inst.sg:GoToState("idle", true)
	end
	state_doshortaction.onexit = function(inst)
		if inst.bufferedaction == inst.sg.statemem.action then
			inst:ClearBufferedAction()
		end
	end
	state_doshortaction.events =
	{
		
	}
end)