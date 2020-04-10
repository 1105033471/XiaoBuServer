local chestmark = Class(function(self, inst)
    self.inst = inst
    self.mark = false
end)

function chestmark:OnSave()
    local data = {
        mark = self.mark,
    }
    return data
end

function chestmark:OnLoad(data)
	if data then
    	self.mark = data.mark
	end
end

return chestmark