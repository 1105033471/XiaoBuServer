local accept_data = Class(function(self, inst)
    self.inst = inst
    self.accept_mandrake = 0
    self.accept_greengem = 0
end,
nil,
{
})

function accept_data:OnSave()
    local data = {
        accept_mandrake = self.accept_mandrake,
        accept_greengem = self.accept_greengem,
    }
    return data
end

function accept_data:OnLoad(data)
    self.accept_mandrake = data.accept_mandrake or 0
    self.accept_greengem = data.accept_greengem or 0
end

return accept_data