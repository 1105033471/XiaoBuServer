local chasethewindstatus = Class(function(self, inst)
    self.inst = inst
    self.level = 0
	self.level2 = 0
    self.use = 200
end,
nil,
{
})

function chasethewindstatus:OnSave()
    local data = {
        level = self.level,
        level2 = self.level2,
        use = self.use,
    }
    return data
end

function chasethewindstatus:OnLoad(data)
    self.level = data.level or 0
    self.level2 = data.level2 or 0
    self.use = data.use or 0
end

function chasethewindstatus:DoDeltaLevel(delta)
    self.level = self.level + delta
    self.inst:PushEvent("DoDeltaLevelChaseTheWind")
end

function chasethewindstatus:DoDeltaLevel2(delta)
    self.level2 = self.level2 + delta
    self.inst:PushEvent("DoDeltaLevelChaseTheWind")
end

return chasethewindstatus