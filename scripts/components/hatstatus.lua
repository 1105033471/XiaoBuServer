local hatstatus = Class(function(self, inst)
    self.inst = inst
    self.spiderhat_count = 0        -- 接受的蜘蛛帽数量
    self.skeletonhat_count = 0        -- 接受的白骨头盔数量
    self.houndstooth_count = 0        -- 接受的狗牙数量
    self.deserthat_count = 0        -- 接受的沙漠护目镜数量
    
    self.goose_count = 0            -- 接受的鹅毛数量
    self.waterproof = 0                -- 是否有满防水效果(为了适应不同帽子的初始防水功能，需要设置此变量)
    
    self.spidergland = 0            -- 接受的蜘蛛腺体数量
    
    self.beefalohat_count = 0        -- 接受的牛帽数量
    self.closebeefalo = 0            -- 是否有亲牛光环
    
    self.winterhat_count = 0        -- 接受的冬帽数量
    self.warm = 0                    -- 是否有满保暖效果
    
    self.walrushat_count = 0        -- 接受的海象帽数量
    self.sanity = 0                    -- 是否有满回san效果
    
    self.hivehat_count = 0            -- 接受的蜂王帽数量
    self.icehat_count = 0            -- 接受的冰块数量
    
    self.heart = 0                    -- 是否有满隔热效果
    
    self.base_waterproof = 0        -- 帽子基础防水
    self.base_warm = 0                -- 帽子基础保暖
    self.base_sanity = 0            -- 帽子基础回san
    self.base_heart = 0                -- 帽子基础隔热
    self.base_hungry = 0            -- 帽子基础减缓饥饿
    self.base_perishtime = 0        -- 帽子基础耐久
    self.base_perishtime_fresh = 0    -- 帽子基础新鲜度
    
    self.iswarm = 0                    -- 帽子是否为保暖类型
    
    self.has_goggles = 0            -- 帽子是否拥有沙漠护目镜属性
    
    self.opal_count = 0                -- 快速采集和双倍采集效果
    self.abilities = {}

    self.propetyall = false         -- 属性全满
end,
nil,
{
})

function hatstatus:OnSave()
    local data = {
        spiderhat_count = self.spiderhat_count,
        skeletonhat_count = self.skeletonhat_count,
        houndstooth_count = self.houndstooth_count,
        deserthat_count = self.deserthat_count,
        
        goose_count = self.goose_count,
        waterproof = self.waterproof,
        
        spidergland = self.spidergland,
        hungry = self.hungry,
        
        beefalohat_count = self.beefalohat_count,
        closebeefalo = self.closebeefalo,
        
        winterhat_count = self.winterhat_count,
        warm = self.warm,
        
        walrushat_count = self.walrushat_count,
        sanity = self.sanity,
        
        hivehat_count = self.hivehat_count,
        icehat_count = self.icehat_count,
        
        heart = self.heart,
        
        base_waterproof = self.base_waterproof,
        base_warm = self.base_warm,
        base_sanity = self.base_sanity,
        base_heart = self.base_heart,
        base_hungry = self.base_hungry,
        base_perishtime = self.base_perishtime,
        base_perishtime_fresh = self.base_perishtime_fresh,
        
        iswarm = self.iswarm,
        
        has_goggles = self.has_goggles,
        
        opal_count = self.opal_count,
        abilities = {},

        propetyall = self.propetyall,
    }
    for k, v in pairs(self.abilities) do
        table.insert(data.abilities, v)
    end
    return data
end

function hatstatus:OnLoad(data)
    self.spiderhat_count = data.spiderhat_count or 0
    self.skeletonhat_count = data.skeletonhat_count or 0
    self.houndstooth_count = data.houndstooth_count or 0
    self.deserthat_count = data.deserthat_count or 0
    
    self.goose_count = data.goose_count or 0
    self.waterproof = data.waterproof or 0
    
    self.spidergland = data.spidergland or 0
    self.hungry = data.hungry or 0
    
    self.beefalohat_count = data.beefalohat_count or 0
    self.closebeefalo = data.closebeefalo or 0
    
    self.winterhat_count = data.winterhat_count or 0
    self.warm = data.warm or 0
    
    self.walrushat_count = data.walrushat_count or 0
    self.sanity = data.sanity or 0
    
    self.hivehat_count = data.hivehat_count or 0
    self.icehat_count = data.icehat_count or 0
    
    self.heart = data.heart or 0
    
    self.base_waterproof = data.base_waterproof or 0
    self.base_warm = data.base_warm or 0
    self.base_sanity = data.base_sanity or 0
    self.base_heart = data.base_heart or 0
    self.base_hungry = data.base_hungry or 0
    self.base_perishtime = data.base_perishtime or 0
    self.base_perishtime_fresh = data.base_perishtime_fresh or 0
    
    self.iswarm = data.iswarm or 0
    
    self.has_goggles = data.has_goggles or 0
    
    self.opal_count = data.opal_count or 0
    if data.abilities ~= nil then
        for k, v in pairs(data.abilities) do
            table.insert(self.abilities, v)
        end
    end

    self.propetyall = data.propetyall or false
end

return hatstatus