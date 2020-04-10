local skinstaffstatus = Class(function(self, inst)
    self.inst = inst
    self.level = 0
    self.petals_count = 0
	self.moonrock_count = 0
end,
nil,
{
})

function skinstaffstatus:OnSave()
    local data = {
        level = self.level,
        petals_count = self.petals_count,
		moonrock_count = self.moonrock_count
    }
    return data
end

function skinstaffstatus:OnLoad(data)
    self.level = data.level or 0
    self.petals_count = data.petals_count or 0
	self.moonrock_count = data.moonrock_count or 0
end

function skinstaffstatus:DoPetalLevel()
	self.petals_count = self.petals_count + 1
	if self.petals_count >= 58 then
		self.level = 1
	end
end

function skinstaffstatus:DoMoonrockLevel()
	self.moonrock_count = self.moonrock_count + 1
	if self.moonrock_count >= 22 then
		self.level = 2
	end
end

function skinstaffstatus:GetDamage()
	if self.level ~= 0 then
		return 30
	else
		return (self.petals_count / 2 + 1)
	end
end

function skinstaffstatus:GetRange()
	if self.level >= 1 then
		return (self.moonrock_count / 2 + 1)
	else
		return 1
	end
end

return skinstaffstatus