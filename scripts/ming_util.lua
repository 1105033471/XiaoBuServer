--  延迟0.01s说话，保证覆盖官方的话语
local function M_PlayerSay(player, str)
    if player and player.components.talker then
        player:DoTaskInTime(0.01, function()
            player.components.talker:Say(str)
        end)
    end
end
GLOBAL.M_PlayerSay = M_PlayerSay

-- 获取upvalue
local function GetUpvalueHelper(fn, name)
	local i = 1
	while debug.getupvalue(fn, i) and debug.getupvalue(fn, i) ~= name do
		i = i + 1
	end
	local name, value = debug.getupvalue(fn, i)
	return value, i
end
GLOBAL.GetUpvalueHelper = GetUpvalueHelper

