local armorwoodstatus = Class(function(self, inst)
    self.inst = inst
    self.level = 0
    self.armormarble_count = 0
    self.tusk_count = 0
    self.heart_count = 0
    self.yellowamulet_count = 0
end,
nil,
{
})

function armorwoodstatus:OnSave()
    local data = {
        level = self.level,
        armormarble_count = self.armormarble_count,
        tusk_count = self.tusk_count,
        heart_count = self.heart_count,
        yellowamulet_count = self.yellowamulet_count,
    }
    return data
end

function armorwoodstatus:OnLoad(data)
    self.level = data.level or 0
    self.armormarble_count = data.armormarble_count or 0
    self.tusk_count = data.tusk_count or 0
    self.heart_count = data.heart_count or 0
    self.yellowamulet_count = data.yellowamulet_count or 0
end

function armorwoodstatus:DoMarbleLevel()
    self.armormarble_count = self.armormarble_count + 1
    if self.armormarble_count >= 5 then
        self.level = 1
    end
end

function armorwoodstatus:DoTuskLevel()
    self.tusk_count = self.tusk_count + 1
    if self.tusk_count >= 2 then
        self.level = 2
    end
end

function armorwoodstatus:DoHeartLevel()
    self.heart_count = self.heart_count + 1
    if self.heart_count >= 2 then
        self.level = 3
    end
end

function armorwoodstatus:DoYelAmuletLevel()
    self.yellowamulet_count = self.yellowamulet_count + 1
    if self.yellowamulet_count >= 6 then
        self.level = 4
    end
end

function armorwoodstatus:GetDefense()
    if self.level == 0 then
        return ((80 + self.armormarble_count) / 100)
    else
        return .85
    end
end

function armorwoodstatus:GetCondition()
    if self.level <= 2 then
        return (850 + self.heart_count * 3000)
    else
        return (99999)
    end
end

function armorwoodstatus:GetSpeed()
    if self.level == 0 then
        return (1 - 0.02 * self.armormarble_count)
    elseif self.level == 1 then
        return (0.9 + 0.05 * self.tusk_count)
    elseif self.level == 2 then
        return 1.0
    elseif self.level == 3 then
        local amulet_speed = math.ceil((self.yellowamulet_count / 6) * 15) / 100
        return (1 + amulet_speed)
    else
        return 1.15
    end
end

return armorwoodstatus