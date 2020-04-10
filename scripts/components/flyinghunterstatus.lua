local flyinghunterstatus = Class(function(self, inst)
    self.inst = inst
    self.heart_count = 0
end,
nil,
{
})

function flyinghunterstatus:OnSave()
    local data = {
        heart_count = self.heart_count,
    }
    return data
end

function flyinghunterstatus:OnLoad(data)
    self.heart_count = data.heart_count or 0
end

function flyinghunterstatus:DoDeltaLevel()
    self.heart_count = self.heart_count + 1
end

function flyinghunterstatus:GetExtraDamage()
    return (self.heart_count * 1.5)
end

function flyinghunterstatus:GetSpeed()
    return (math.ceil(self.heart_count / 2) * 0.01 + 1)
end

return flyinghunterstatus