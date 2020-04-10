local bossstatus = Class(function(self, inst)
    self.inst = inst
    self.deerclops = 0
    self.bearger = 0
    self.dragonfly = 0
    self.moose = 0
    self.beequeen = 0
    self.minotaur = 0
    self.antlion = 0
    self.malbatross = 0
end,
nil,
{
})

function bossstatus:OnSave()
    local data = {
        deerclops = self.deerclops,
        bearger = self.bearger,
        dragonfly = self.dragonfly,
        moose = self.moose,
        beequeen = self.beequeen,
        minotaur = self.minotaur,
        antlion = self.antlion,
        malbatross = self.malbatross,
    }
    return data
end

function bossstatus:OnLoad(data)
    self.deerclops = data.deerclops or 0
    self.bearger = data.bearger or 0
    self.dragonfly = data.dragonfly or 0
    self.moose = data.moose or 0
    self.beequeen = data.beequeen or 0
    self.minotaur = data.minotaur or 0
    self.antlion = data.antlion or 0
    self.malbatross = data.malbatross or 0
end

return bossstatus