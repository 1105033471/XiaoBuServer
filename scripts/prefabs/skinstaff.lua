local assets = {
    Asset("ANIM", "anim/skinstaff.zip"),
    Asset("ANIM", "anim/swap_skinstaff.zip"),
    Asset("ATLAS", "images/inventoryimages/skinstaff.xml"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_skinstaff", "skinstaff")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

require("prefabskins")

local function setflowertype(inst, name) 
    if inst.animname == nil or (name ~= nil and inst.animname ~= name) then
        if inst.animname == "rose" then 
            inst:RemoveTag("thorny") 
        end 
        
        inst.animname = name 
        inst.AnimState:PlayAnimation(inst.animname) 
        
        if inst.animname == "rose" then 
            inst:AddTag("thorny") 
        end 
    end 
end 

local names = {"f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","rose"} 

local function reskin(inst, target)
    -- 禁止更换皮肤的物品列表
    local disableItems = {
        -- "hua_player_house",    -- 蘑菇房子
        -- "hua_player_house1"    -- 齿轮房子
    }
    for k,item in pairs(disableItems) do
        if target.prefab == item then
            return
        end
    end
    -- 无法更换焚烧后的建筑
    if target:HasTag("burnt") or (target.components.burnable ~= nil and target.components.burnable:IsBurning())then
        print("target is burnt or burning")
        return
    end
    
    if target.prefab == "pighouse" or target.prefab == "rabbithouse" then        -- 猪房兔房刷生物修复
        local x, y, z = target.Transform:GetWorldPosition()
        -- pos.x, pos.y, pos.z, musttags, canttags, mustoneoftags
        local ents = TheSim:FindEntities(x, y, z, 40, {}, {}, { "pig" })    -- 寻找附近的猪人
        for k, v in pairs(ents) do
            if v and v.components and v.components.homeseeker and v.components.homeseeker.home then    -- 判断是否有家
                local homepos = v.components.homeseeker:GetHomePos()
                if homepos.x == x and homepos.y == y and homepos.z == z then    -- 判断家是否为当前更换皮肤的对象
                    v:Remove()
                    break            -- 因为一个家只有一个猪人，所以提前结束减少不必要的判断
                end
            end
        end
    end
    
    if target.prefab == "beebox" then
        local x, y, z = target.Transform:GetWorldPosition()
        -- pos.x, pos.y, pos.z, musttags, canttags, mustoneoftags
        local ents = TheSim:FindEntities(x, y, z, 20, {}, {}, { "bee" })    -- 寻找附近的蜜蜂
        for k, v in pairs(ents) do
            if v and v.components and v.components.homeseeker and v.components.homeseeker.home then    -- 判断是否有家
                local homepos = v.components.homeseeker:GetHomePos()
                if homepos.x == x and homepos.y == y and homepos.z == z then    -- 判断家是否为当前更换皮肤的对象
                    v:Remove()
                end
            end
        end
    end
    
    local user = inst.components.inventoryitem.owner
    
    if target:HasTag("flower") and not target:HasTag("player") then
        if target.animname ~= names[inst.flowertype] then
            setflowertype(target, names[inst.flowertype])
        else
            inst.flowertype = inst.flowertype % #names + 1
            setflowertype(target,names[inst.flowertype])
        end
        return
    end
    
    local start = 1
    local name = target.prefab
    local current_skin = target.skinname
    local skin_prefab = nil
    if PREFAB_SKINS[name] == nil then    --    官方没有该物品的皮肤
        return
    end
    for k,v in pairs(PREFAB_SKINS[name]) do 
        if v == current_skin then 
            start = k + 1 
            break 
        end
    end
    local skin
    for i=start,#PREFAB_SKINS[name] do
        skin = ValidateRecipeSkinRequest(user.userid, name, PREFAB_SKINS[name][i])
        print("try to "..PREFAB_SKINS[name][i])
        if skin then
            print("skin: "..skin)
        end
        if skin then
            skin_prefab = SpawnPrefab(name,PREFAB_SKINS[name][i],nil,user.userid)
            break
        end
    end
    if skin_prefab == nil then
        skin_prefab = SpawnPrefab(name)
    end
    if target.components.container then
        local i = 1
        for i=1, target.components.container:GetNumSlots() do    -- 对每个槽而言
            local slot_item = target.components.container:GetItemInSlot(i)
            -- print("give item: "..tostring(slot_item))
            skin_prefab.components.container:GiveItem(slot_item, i)
        end
    end
    -- 校验所有组件的状态
    if target.components.fueled then
        skin_prefab.components.fueled:SetPercent(target.components.fueled:GetPercent())
    end
    if target.components.finiteuses then
        skin_prefab.components.finiteuses:SetPercent(target.components.finiteuses:GetPercent())
    end
    if target.components.perishable then
        skin_prefab.components.perishable:SetPercent(target.components.perishable:GetPercent())
    end
    if target.components.armor then
        skin_prefab.components.armor.condition = target.components.armor.condition
    end
    if target.components.stackable then
        skin_prefab.components.stackable:SetStackSize(target.components.stackable.stacksize)
        print("stack:"..skin_prefab.components.stackable.stacksize)
    end
    if target.components.shelf then        -- 鸟笼     TODO
        skin_prefab.components.shelf.itemonshelf = target.components.shelf.itemonshelf
    end
    if target.components.harvestable then    -- 蘑菇农场和蜂房产物 TODO 显示问题
        skin_prefab.components.harvestable.produce = target.components.harvestable.produce
        skin_prefab.components.harvestable.maxproduce = target.components.harvestable.maxproduce
    end
    
    if target.components.spawner then    -- 能够生成物品的建筑：猪房兔房，蜂房为childspawner
        skin_prefab:DoTaskInTime(3, function()    -- 让新生成的物品死亡(防止重复击杀生物用来刷物品)
            local x, y, z = skin_prefab.Transform:GetWorldPosition()    -- 为什么不用target而用skin_prefab: 因为target已经被删除了
            -- pos.x, pos.y, pos.z, radius, musttags, canttags, mustoneoftags
            local ents = TheSim:FindEntities(x, y, z, 40, {}, {}, { "pig", "bee" })    -- 寻找附近的猪人
            for k, v in pairs(ents) do
                if v and v.components and v.components.homeseeker and v.components.homeseeker.home then    -- 判断是否有家
                    local homepos = v.components.homeseeker:GetHomePos()
                    if homepos.x == x and homepos.y == y and homepos.z == z then    -- 判断家是否为当前更换皮肤的对象
                        v:Remove()
                    end
                end
            end
        end)
        -- 开启生成
        local delay = TUNING.TOTAL_DAY_TIME*1
        if target.prefab == "pighouse" or target.prefab == "rabbithouse" then
            delay = TUNING.TOTAL_DAY_TIME*4
        end
        skin_prefab.components.spawner:SpawnWithDelay(delay)
        
    end
    -- 锅 TODO
    -- 晾肉架 TODO
    -- 木甲升级的状态校验
    if target.components.armorwoodstatus then
        skin_prefab:AddComponent("armorwoodstatus")
        skin_prefab.components.armorwoodstatus.level = target.components.armorwoodstatus.level
        skin_prefab.components.armorwoodstatus.armormarble_count = target.components.armorwoodstatus.armormarble_count
        skin_prefab.components.armorwoodstatus.tusk_count = target.components.armorwoodstatus.tusk_count
        skin_prefab.components.armorwoodstatus.heart_count = target.components.armorwoodstatus.heart_count
        skin_prefab.components.armorwoodstatus.yellowamulet_count = target.components.armorwoodstatus.yellowamulet_count
        
        skin_prefab.valuecheck = target.valuecheck
        skin_prefab.valuecheck(skin_prefab)
    end
    -- 帽子升级的状态校验
    if target.components.hatstatus then
        skin_prefab:AddComponent("hatstatus")
        skin_prefab.components.hatstatus.spiderhat_count = target.components.hatstatus.spiderhat_count
        skin_prefab.components.hatstatus.skeletonhat_count = target.components.hatstatus.skeletonhat_count
        skin_prefab.components.hatstatus.houndstooth_count = target.components.hatstatus.houndstooth_count
        skin_prefab.components.hatstatus.deserthat_count = target.components.hatstatus.deserthat_count
        skin_prefab.components.hatstatus.goose_count = target.components.hatstatus.goose_count
        skin_prefab.components.hatstatus.waterproof = target.components.hatstatus.waterproof
        skin_prefab.components.hatstatus.spidergland = target.components.hatstatus.spidergland
        skin_prefab.components.hatstatus.hungry = target.components.hatstatus.hungry
        skin_prefab.components.hatstatus.beefalohat_count = target.components.hatstatus.beefalohat_count
        skin_prefab.components.hatstatus.closebeefalo = target.components.hatstatus.closebeefalo
        skin_prefab.components.hatstatus.winterhat_count = target.components.hatstatus.winterhat_count
        skin_prefab.components.hatstatus.warm = target.components.hatstatus.warm
        skin_prefab.components.hatstatus.walrushat_count = target.components.hatstatus.walrushat_count
        skin_prefab.components.hatstatus.sanity = target.components.hatstatus.sanity
        skin_prefab.components.hatstatus.hivehat_count = target.components.hatstatus.hivehat_count
        skin_prefab.components.hatstatus.icehat_count = target.components.hatstatus.icehat_count
        skin_prefab.components.hatstatus.heart = target.components.hatstatus.heart
        skin_prefab.components.hatstatus.base_waterproof = target.components.hatstatus.base_waterproof
        skin_prefab.components.hatstatus.base_warm = target.components.hatstatus.base_warm
        skin_prefab.components.hatstatus.base_sanity = target.components.hatstatus.base_sanity
        skin_prefab.components.hatstatus.base_heart = target.components.hatstatus.base_heart
        skin_prefab.components.hatstatus.base_hungry = target.components.hatstatus.base_hungry
        skin_prefab.components.hatstatus.base_perishtime = target.components.hatstatus.base_perishtime
        skin_prefab.components.hatstatus.base_perishtime_fresh = target.components.hatstatus.base_perishtime_fresh
        skin_prefab.components.hatstatus.iswarm = target.components.hatstatus.iswarm
        skin_prefab.components.hatstatus.has_goggles = target.components.hatstatus.has_goggles
        skin_prefab.components.hatstatus.opal_count = target.components.hatstatus.opal_count
        
        skin_prefab.ValueCheck = target.ValueCheck
        skin_prefab.ValueCheck(skin_prefab)
    end
    -- 防熊锁兼容
    local master = target.ownerlist ~= nil and target.ownerlist.master or nil
    if master then SetItemPermission(skin_prefab, master) end
    -- 特效
    local fx_list = {"sand_puff_large_front", "shadow_puff_large_front", "chester_transform_fx"}
    local fx = SpawnPrefab(fx_list[math.random(1, #fx_list)])
    if fx then fx.Transform:SetPosition(target.Transform:GetWorldPosition()) end
    
    skin_prefab.Transform:SetPosition(target.Transform:GetWorldPosition())
    target:Remove()
end

local function ItemTradeTest(inst, item)
    if item == nil then
        return false
    end
    if inst.components.skinstaffstatus.level == 0 then        -- 等级为0时只接受花瓣
        if item.prefab ~= "petals" then
            return false
        end
    elseif inst.components.skinstaffstatus.level == 1 then    -- 等级为1时只接受月石
        if item.prefab ~= "moonrocknugget" then
            return false
        end
    else                                                    -- 暂时只支持二阶
        return false
    end
    return true
end

local function ValueCheck(inst)
    if inst.components.skinstaffstatus.level == 2 then        -- 满级后移除升级属性
        inst:RemoveComponent("trader")
    end
    local range = inst.components.skinstaffstatus:GetRange()
    inst.components.weapon:SetDamage(inst.components.skinstaffstatus:GetDamage())
    inst.components.weapon:SetRange(range)
    -- inst.components.weapon:SetRange(8, 10)
    if range > 1 then
        inst.components.weapon:SetProjectile("tz_projectile_bai")
    end
end

local function OnGemGiven(inst, giver, item)
    if inst.components.skinstaffstatus.level == 0 then
        if inst.components.skinstaffstatus.petals_count < 57 then
            inst.components.skinstaffstatus:DoPetalLevel()
            local petals_count = inst.components.skinstaffstatus.petals_count
            giver.components.talker:Say("当前为0阶\n花瓣 "..tostring(petals_count).."/58")
        else
            inst.components.skinstaffstatus:DoPetalLevel()
            giver.components.talker:Say("进阶成功,当前为1阶!\n下一阶需要材料为：月石")
        end
    elseif inst.components.skinstaffstatus.level == 1 then
        if inst.components.skinstaffstatus.moonrock_count < 21 then
            inst.components.skinstaffstatus:DoMoonrockLevel()
            local moonrock_count = inst.components.skinstaffstatus.moonrock_count
            giver.components.talker:Say("当前为1阶\n月石 "..tostring(moonrock_count).."/22")
        else
            inst.components.skinstaffstatus:DoMoonrockLevel()
            giver.components.talker:Say("进阶成功,当前为2阶(满级)!")
        end
    end
    
    inst.SoundEmitter:PlaySound("dontstarve/common/telebase_gemplace")
    
    ValueCheck(inst)
end

local function OnRefuseItem(inst, giver, item)
    if item then
        if inst.components.skinstaffstatus.level == 0 then
            giver.components.talker:Say("它现在需要花瓣")
        elseif inst.components.skinstaffstatus.level == 1 then
            giver.components.talker:Say("它现在需要月石")
        end
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("skinstaff")
    inst.AnimState:SetBuild("skinstaff")
    inst.AnimState:PlayAnimation("idle")
    inst.entity:SetPristine()
    
    MakeInventoryFloatable(inst)
    
    inst:AddTag("godweapon")
    
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("tradable")
    
    inst.flowertype = 1
    
    inst:AddComponent("weapon")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skinstaff.xml"
    inst.components.inventoryitem.imagename = "skinstaff"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    
    MakeHauntableLaunch(inst)
    
    inst.components.weapon:SetDamage(1)
    
    inst:AddComponent("skinstaffstatus")

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(reskin)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canonlyuseonrecipes = true
    inst.components.spellcaster.quickcast = true
    
    inst:AddComponent("trader")
    inst.components.trader:SetAbleToAcceptTest(ItemTradeTest)
    inst.components.trader.onaccept = OnGemGiven
    inst.components.trader.onrefuse = OnRefuseItem
    
    inst:DoTaskInTime(0, function() ValueCheck(inst) end)        -- 防止重新进入游戏时载入数据出错
    
    return inst
end

return Prefab( "skinstaff", fn, assets)