
local configuration_options = {
    {
        name = "admin_option",
        label = "管理员受权限控制",
        options = {
            {description = "受", data = false, hover = "服务器管理员受权限控制"},
            {description = "不受", data = true, hover = "服务器管理员不受权限控制"}
        },
        default = true
    },
    {
        name = "test_mode",
        label = "管理测试模式",
        options = {
            {description = "开启", data = true, hover = "开启测试模式"},
            {description = "关闭", data = false, hover = "关闭测试模式"}
        },
        default = false
    },
    {
        name = "permission_mode",
        label = "权限保护模式",
        hover = "(关闭后所有有权限的物品失去保护)",
        options = {
            {description = "开启", data = true, hover = "开启防熊相关权限验证功能"},
            {description = "关闭", data = false, hover = "关闭防熊相关权限验证功能"}
        },
        default = true
    },
    {
        name = "language",
        label = "选择语言风格",
        options = {
            {description = "正常版", data = "normal", hover = "正常"},
            {description = "欢乐版", data = "redpig_fun", hover = "欢乐"}
        },
        default = "normal"
    },
    {
        name = "give_start_item",
        label = "玩家初始物品",
        hover = "给予初进入服务器的玩家一些有利于当前环境生存的初始物品",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    },
    {
        name = "give_start_trinket",
        label = "给予高级物品",
        hover = "此选项只有在开启[玩家初始物品]选项后有效",
        options = {
            {description = "开启", data = true, hover = "给予玩家白色主教、白色战车、白色骑士、8个化石碎片"},
            {description = "关闭", data = false}
        },
        default = false
    },
    {
        name = "door_lock",
        label = "木门权限增强",
        options = {
            {description = "有权限控制", data = "111", hover = "木门有权限的玩家才能砸和打开，免疫怪物伤害"},
            {description = "有权限控制2", data = "101", hover = "木门有权限的玩家才能砸和打开，怪物可摧毁"},
            {description = "部分权限控制", data = "110", hover = "木门有权限的玩家才能砸，任何玩家都能打开，免疫怪物伤害"},
            {description = "部分权限控制2", data = "100", hover = "木门有权限的玩家才能砸，任何玩家都能打开，怪物可摧毁"},
            {description = "无权限控制", data = "010", hover = "木门任何玩家都能砸和打开，免疫怪物伤害"},
            {description = "关闭", data = "000", hover = "关闭"}
        },
        default = "111"
    },
    {
        name = "fence_lock",
        label = "栅栏权限增强",
        options = {
            {description = "有权限控制", data = "111", hover = "木栅栏有权限的玩家才能砸，免疫怪物伤害"},
            {description = "有权限控制2", data = "101", hover = "木栅栏有权限的玩家才能砸，怪物可摧毁"},
            {description = "关闭", data = "000", hover = "关闭"}
        },
        default = "111"
    },
    {
        name = "wall_hay_lock",
        label = "草墙权限增强",
        options = {
            {description = "有权限控制", data = "111", hover = "草墙有权限的玩家才能砸，免疫怪物伤害"},
            {description = "有权限控制2", data = "101", hover = "草墙有权限的玩家才能砸，怪物可摧毁"},
            {description = "关闭", data = "000", hover = "关闭"}
        },
        default = "111"
    },
    {
        name = "wall_wood_lock",
        label = "木墙权限增强",
        options = {
            {description = "有权限控制", data = "111", hover = "木墙有权限的玩家才能砸，免疫怪物伤害"},
            {description = "有权限控制2", data = "101", hover = "木墙有权限的玩家才能砸，怪物可摧毁"},
            {description = "关闭", data = "000", hover = "关闭"}
        },
        default = "111"
    },
    {
        name = "wall_stone_lock",
        label = "石墙权限增强",
        options = {
            {description = "有权限控制", data = "111", hover = "石墙有权限的玩家才能砸，免疫怪物伤害"},
            {description = "有权限控制2", data = "101", hover = "石墙有权限的玩家才能砸，怪物可摧毁"},
            {description = "关闭", data = "000", hover = "关闭"}
        },
        default = "111"
    },
    {
        name = "wall_ruins_lock",
        label = "铥墙权限增强",
        options = {
            {description = "有权限控制", data = "111", hover = "铥矿墙有权限的玩家才能砸，免疫怪物伤害"},
            {description = "有权限控制2", data = "101", hover = "铥矿墙有权限的玩家才能砸，怪物可摧毁"},
            {description = "关闭", data = "000", hover = "关闭"}
        },
        default = "111"
    },
    {
        name = "wall_moonrock_lock",
        label = "月墙权限增强",
        options = {
            {description = "有权限控制", data = "111", hover = "月石墙有权限的玩家才能砸，免疫怪物伤害"},
            {description = "有权限控制2", data = "101", hover = "月石墙有权限的玩家才能砸，怪物可摧毁"},
            {description = "关闭", data = "000", hover = "关闭"}
        },
        default = "111"
    },
    {
        name = "cant_destroyby_monster",
        label = "防止怪物摧毁",
        options = {
            {description = "开启", data = true, hover = "开启，门和墙体为单独设置"},
            {description = "关闭", data = false, hover = "为了更全面的游戏体验，建议关闭，门和墙体为单独设置"}
        },
        default = true
    },
    {
        name = "portal_clear",
        label = "防止玩家封门",
        hover = "定期清理出生点,落水洞,地下阶梯,主要boss周边不良物体",
        options = {
            {description = "50码", data = 50},
            {description = "40码", data = 40},
            {description = "30码", data = 30},
            {description = "25码", data = 25},
            {description = "20码", data = 20},
            {description = "15码", data = 15},
            {description = "10码", data = 10},
            {description = "5码", data = 5},
            {description = "关闭", data = 0}
        },
        default = 5
    },
    {
        name = "firesuppressor_dig",
        label = "防止作物被挖",
        hover = "农作物与自己建筑之间的距离",
        options = {
            {description = "50码", data = 50},
            {description = "40码", data = 40},
            {description = "30码", data = 30},
            {description = "25码", data = 25},
            {description = "20码", data = 20},
            {description = "15码", data = 15},
            {description = "10码", data = 10},
            {description = "5码", data = 5},
            {description = "关闭", data = -1}
        },
        default = 10
    },
    {
        name = "is_allow_build_near",
        label = "防止违规建筑",
        hover = "不允许未授权的玩家在自己家附近造建筑",
        options = {
            {description = "开启", data = false},
            {description = "关闭", data = true}
        },
        default = true
    },
    {
        name = "remove_owner_time",
        label = "离线解锁时间",
        hover = "玩家离开游戏后，其所有物的自动解锁时间",
        options = {
            {description = "10秒", data = 10},
            {description = "8分钟", data = 480},
            {description = "40分钟", data = 2400},
            {description = "1小时", data = 3600},
            {description = "3小时", data = 10800},
            {description = "9小时", data = 32400},
            {description = "24小时", data = 86400},
            {description = "48小时", data = 172800},
            {description = "96小时", data = 345600},
            {description = "1周", data = 604800}, 
            {description = "永远不解锁", data = "never"}
        },
        default = 172800
    },
    {
        name = "spread_fire",
        label = "火焰蔓延半径",
        hover = "游戏中火焰的蔓延范围",
        options = {
            {description = "不蔓延", data = 0, hover = "防止大火烧山"},
            {description = "一半半径", data = 1, hover = "防止大火烧山"},
            {description = "正常半径", data = 2}
        },
        default = 2
    },
    {
        name = "beefalo_power",
        label = "宠物牛★加强",
        hover = "防止服从度大于0的牛抖落鞍或主人，并且当牛有主人时防御增强",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    },
    {
        name = "krampus_sack_ice",
        label = "小偷包能保鲜",
        hover = "小偷包保鲜,保鲜度同冰箱",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    },
    {
        name = "pack_pickup",
        label = "背包拾取增强",
        hover = "当身上有背包时拾取地上的背包将持有在手上而不是直接装备",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    },
    {
        name = "auto_stack",
        label = "掉落物品堆叠",
        hover = "猪王/喂鸟/挖矿/砍树等掉落物品自动堆叠",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    },
    {
        name = "respawn_beeqeen",
        label = "毒蕈重生时间",
        hover = "Toadstool Respawn Time",
        options = {
            {description = "5天", data = 5},
            {description = "10天", data = 10},
            {description = "15天", data = 15},
            {description = "默认", data = 0}
        },
        default = 0,
    },
    {
        name = "respawn_toadstool",
        label = "蜂后重生时间",
        hover = "Beequeen Respawn Time",
        options = {
            {description = "5天", data = 5},
            {description = "10天", data = 10},
            {description = "15天", data = 15},
            {description = "默认", data = 0}
        },
        default = 0,
    },
    {
        name = "respawn_atrium",
        label = "中庭冷却时间",
        hover = "Atrium Stalker Respawn Time",
        options = {
            {description = "5天", data = 5},
            {description = "10天", data = 10},
            {description = "15天", data = 15},
            {description = "默认", data = 0}
        },
        default = 0,
    },
    {
        name = "minotaur_regenerate",
        label = "犀牛刷新时间",
        options = {
            {description = "10天", data = 10, hover = "远古犀牛死亡10天后刷新"},
            {description = "20天", data = 20, hover = "远古犀牛死亡20天后刷新"},
            {description = "30天", data = 30, hover = "远古犀牛死亡30天后刷新"},
            {description = "40天", data = 40, hover = "远古犀牛死亡40天后刷新"},
            {description = "50天", data = 50, hover = "远古犀牛死亡50天后刷新"},
            {description = "60天", data = 60, hover = "远古犀牛死亡60天后刷新"},
            {description = "70天", data = 70, hover = "远古犀牛死亡70天后刷新"},
            {description = "80天", data = 80, hover = "远古犀牛死亡80天后刷新"},
            {description = "90天", data = 90, hover = "远古犀牛死亡90天后刷新"},
            {description = "100天", data = 100, hover = "远古犀牛死亡100天后刷新"},
            {description = "关闭", data = -1}
        },
        default = 60
    },
    {
        name = "minotaur_destroy",
        label = "犀牛摧毁建筑",
        hover = "在开启防止怪物摧毁建筑时允许犀牛拆毁建筑,建筑不包括墙类",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    },
    {
        name = "ancient_altar_no_destroy",
        label = "完整的远古祭坛防摧毁",
        hover = "防止完整的远古祭坛被玩家破坏",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    },
    {
        name = "house_plain_nodestroy",
        label = "野外猪人兔人房防摧毁",
        hover = "防止野外猪人、兔人、鱼人房被玩家破坏",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = true
    },
    {
        name = "trap_teeth_player",
        label = "犬牙陷阱攻击无权限玩家",
        hover = "犬牙陷阱会被没有权限的玩家触发,造成伤害",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    },
    {
        name = "eyeturret_player",
        label = "眼球塔攻击无权限玩家",
        hover = "眼球塔会主动攻击没有权限的玩家，眼球塔之间互相无仇恨",
        options = {
            {description = "开启", data = true},
            {description = "关闭", data = false}
        },
        default = false
    },
    {
        name = "clean_level",
        label = "定期清理级别",
        hover = "清理文件在目录scripts\manager_clean",
        options = {
            {description = "贫瘠", data = 1},
            {description = "略微贫瘠", data = 2},
            {description = "普通", data = 3},
            {description = "略微富饶", data = 4},
            {description = "富饶", data = 5},
            {description = "关闭", data = -1}
        },
        default = -1
    },
    {
        name = "clean_period",
        label = "定期清理周期",
        hover = "此选项只有在开启[清理级别]选项后有效",
        options = {
            {description = "非常短", data = 1, hover = "1天"},
            {description = "短", data = 5, hover = "5天"},
            {description = "普通", data = 10, hover = "10天"},
            {description = "长", data = 15, hover = "15天"},
            {description = "非常长", data = 20, hover = "20天"}
        },
        default = 10
    },
    {
        name = "clean_custom",
        -- 配置为 名称:数量
        -- 如 bearger:1|deerclops:1
        default = ""
    }
}

function GetLockConfig(index)
	for k, v in pairs(configuration_options) do
		if v["name"] == index then
			return v["default"]
		end
	end
end