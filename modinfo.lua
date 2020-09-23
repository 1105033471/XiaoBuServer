--The name of the mod displayed in the 'mods' screen.

name = "小布服务器综合"

--A description of the mod.

description = "服务器自用mod"

--Who wrote this awesome mod?

author = "明明就"

--A version number so you can ask people if they are running an old version of your mod.

version = "2.8.4"

--This lets other players know if your mod is out of date. This typically needs to be updated every time there's a new game update.

api_version = 10

--Compatible with Don't Starve Together

dst_compatible = true

--Compatible with both the base game and reign of giants

-- dont_starve_compatible = true

-- reign_of_giants_compatible = true

--Some mods may crash or not work correctly until the game is restarted after the mod is enabled/disabled

-- restart_required = false

--Set this to true to prevent _ANY_ other mods from loading while this mod is enabled.

-- standalone = false

priority = -999999

all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

configuration_options =
{	
    {
        name = "strength_monster",
        label = "生物加强",
		hover = "开启后加强部分生物属性",
        options =
        {
            {description = "开启", data = true, hover = "open"},
            {description = "关闭", data = false, hover = "close"},
        },
        default = true,
    },

    {
        name = "extra_open",
        label = "额外内容开启",
		hover = "开启后添加额外内容，不开启则只包含部分小功能",
        options =
        {
            {description = "开启", data = true, hover = "open"},
            {description = "关闭", data = false, hover = "close"},
        },
        default = true,
    },
}