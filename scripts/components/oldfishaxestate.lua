local oldfishaxestate = Class(function(self, inst)
    self.inst = inst
    self.level = 0
    self.soup_count = 0
	self.give_count = 0
end,
nil,
{
})

function oldfishaxestate:OnSave()
    local data = {
        level = self.level,
        soup_count = self.soup_count,
		give_count = self.give_count,
    }
    return data
end

function oldfishaxestate:OnLoad(data)
    self.level = data.level or 0
    self.soup_count = data.soup_count or 0
	self.give_count = data.give_count or 0
end

function oldfishaxestate:DoGiveSoup(delta)
    self.soup_count = self.soup_count + delta
	if self.soup_count >= 10 then		-- 超过10个曼德拉汤后，升级
		self.level = self.level + 1
	end
    self.inst:PushEvent("DoGiveSoup")
end

function oldfishaxestate:DoGiveGodweapon()
    self.level = self.level + 1
    self.inst:PushEvent("DoGiveGodweapon")
end

return oldfishaxestate