-- 获取所有末影箱
function Bu_GetAllShadowBox(owner)
    local result = {}
    if not owner then
        -- print("owner is nil!")
        return result
    end

    for k,v in pairs(Ents) do
        -- print("test: "..tostring(v and v.prefab or nil))
        if v and v.prefab == "skull_chest" then
            -- print("find skull_chest! "..tostring(v.ownerlist).."  "..tostring(v.ownerlist and v.ownerlist.master or nil))
            if v.ownerlist and v.ownerlist.master == owner.userid then
                -- print("find a chest!")
                result[#result + 1] = v
                -- break
            end
        end
    end

    -- 按远近排序
    local posOwner = owner:GetPosition()
    table.sort(result, function(a, b)
        return distsq(posOwner, a:GetPosition()) < distsq(posOwner, b:GetPosition())
    end)

    return result
end

-- 获取最近一个末影箱
function Bu_GetClosestShadowBox(owner)
    local boxes = Bu_GetAllShadowBox(owner)
    return boxes and boxes[1] or nil
end

local key_points = {
    {
        name = "猪王",
        code = "pigking",
    },
    {
        name = "蜂后",
        code = "beequeenhive",
    },
    {
        name = "月台",
        code = "moonbase",
    },
    {
        name = "宠物巢穴",
        code = "critterlab",
    },
    {
        name = "绿洲",
        code = "oasislake",
    },
    {
        name = "龙蝇",
        code = "dragonfly_spawner",
    },
    {
        name = "绚丽之门",
        code = "multiplayer_portal",
    }
}

local DEGREE_STR = {
    {
        text = "较远",
        distance = 5000
    },
    {
        text = "较近",
        distance = 1200
    },
    {
        text = "很近",
        distance = 250,
    },
}
local DEFAULT_DEGREE_STR = "有点远"
local MAX_DIS = 9999999999

-- 初始化所有关键点的位置信息
function Bu_InitKeyPointInfo()
    for k, key_point in pairs(key_points) do
        for _, ent in pairs(Ents) do
            if ent and ent.prefab == key_point.code then
                key_point.pos = ent:GetPosition()
                break
            end
        end
    end

    TheWorld.key_point_info = key_points
end

local function GetClosestKeyPoint(entity)
    if not TheWorld.key_point_info then
        Bu_InitKeyPointInfo()
    end

    local degree
    local dis = MAX_DIS
    local point_result
    local dis_entity = entity:GetPosition()
    for k, key_point in pairs(TheWorld.key_point_info) do
        local dis_temp = distsq(dis_entity, key_point.pos)
        if dis_temp < dis then
            dis = dis_temp
            point_result = key_point
            degree = DEFAULT_DEGREE_STR
            for i=1, #DEGREE_STR do
                if DEGREE_STR[i].distance > dis then
                    degree = DEGREE_STR[i].text
                end
            end
        end
    end

    return point_result, degree
end

-- 获取末影箱的位置信息（模糊）
function Bu_GetShadowBoxInfo(owner)
    if not owner then
        -- print("owner is nil!")
        return ""
    end

    local boxes = Bu_GetAllShadowBox(owner)
    if boxes == nil or #boxes == 0 then
        -- print("no boxes!"..tostring(boxes))
        return "你没有建造任何末影箱"
    end

    local say_tbl = {}
    for i = 1, #boxes do
        local point, degree = GetClosestKeyPoint(boxes[i])
        table.insert(say_tbl, "["..tostring(i).."]: "..point.name.."  "..degree)
    end
    print("return info")
    return tostring(table.concat(say_tbl, "\n"))
end