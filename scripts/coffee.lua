table.insert(PrefabFiles, "coffee")
table.insert(PrefabFiles, "coffeebush")
table.insert(PrefabFiles, "coffeebeans")
table.insert(PrefabFiles, "dug_coffeebush")
table.insert(PrefabFiles, "jellybug")

table.insert(Assets, Asset("ATLAS", "images/inventoryimages/coffee.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/coffeebush.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/coffeebeans.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/coffeebeans_cooked.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/dug_coffeebush.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/feijoada.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/jellybug.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/jellybug_cooked.xml"))
table.insert(Assets, Asset("ATLAS", "images/inventoryimages/tomato_soup.xml"))

-- 咖啡丛
AddRecipe("dug_coffeebush",
    { 
		Ingredient("pomegranate", 1),
		Ingredient("dug_berrybush",1),
		Ingredient("redgem", 1),
    }, 
    RECIPETABS.REFINE,TECH.MAGIC_TWO,
    nil, -- placer
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/dug_coffeebush.xml", -- atlas
    "dug_coffeebush.tex"        -- image
) 
AddMinimapAtlas("images/inventoryimages/coffeebush.xml")

-- 咖啡食谱
AddIngredientValues({"coffeebeans"}, {veggie=.5})
AddIngredientValues({"coffeebeans_cooked"}, {veggie=.5})
local coffee ={    
    name = "coffee",
    test = function(cooker, names, tags) 
		return names.coffeebeans_cooked
			and ((names.coffeebeans_cooked == 3 and (names.butter or tags.dairy or names.honey or tags.sweetener))
			or (names.coffeebeans_cooked == 4))
    end,
    priority = 30,
    weight = 1,
    foodtype = "GOODIES",		-- 这里设置的食物属性会被prefab里的覆盖
    health = 3,					-- 所以重点在priority，test以及cooktime上
    hunger = 10,
    perishtime = TUNING.PERISH_FAST,
    sanity = -5,
    cooktime = .25,
    tags = {},
}
coffee.atlas = "images/inventoryimages/coffee.xml"
AddPrefabPostInit("images/inventoryimages/coffee.tex")
AddCookerRecipe("cookpot", coffee)
AddCookerRecipe("portablecookpot", coffee)

-- 番茄汤
local tomato_soup ={    
    name = "tomato_soup",
    test = function(cooker, names, tags) 
		return names.tomato and names.tomato_cooked and (names.tomato + names.tomato_cooked >= 3) and names.bird_egg and names.bird_egg == 1
    end,
    priority = 30,
	weight = 1,
    foodtype = "GOODIES",
    health = 3,
    hunger = 30,
    perishtime = TUNING.PERISH_MED,
    sanity = 25,
    cooktime = 1.5,
    potlevel = "low",
	floater = {"small", nil, nil},
    tags = {},
}
tomato_soup.atlas = "images/inventoryimages/tomato_soup.xml"
AddPrefabPostInit("images/inventoryimages/tomato_soup.tex")
AddCookerRecipe("cookpot", tomato_soup)
AddCookerRecipe("portablecookpot", tomato_soup)

local HookInitCaffeinated = function(player)
    if player.components.caffeinated == nil then
        player:AddComponent("caffeinated")
    end
end
local OnEverySpawn = function(src, player)
    HookInitCaffeinated(player)
end
local OnPlayerSpawn = function(src, player)
	OnEverySpawn(src, player)
    player.prev_OnNewSpawn = player.OnNewSpawn
    player.OnNewSpawn = function()
        if player.prev_OnNewSpawn ~= nil then
            player:prev_OnNewSpawn()
            player.prev_OnNewSpawn = nil
        end
    end
end

local function ListenForPlayers(inst)
    if GLOBAL.TheWorld.ismastersim then
        inst:ListenForEvent("ms_playerspawn", OnPlayerSpawn)
    end
end

AddPrefabPostInit("world", ListenForPlayers)

-- 八宝饭食谱
AddIngredientValues({"jellybug"}, {veggie=.5})
AddIngredientValues({"jellybug_cooked"}, {veggie=.5})
local feijoada ={    
    name = "feijoada",
    test = function(cooker, names, tags) 
		return names.jellybug_cooked
			and (names.jellybug_cooked == 3 and (tags.meat and tags.meat >= 1))
    end,
    priority = 30,
    weight = 1,
    foodtype = "GOODIES",
    health = 3,
    hunger = 10,
    perishtime = TUNING.PERISH_SLOW,
    sanity = -5,
    cooktime = .25,
    tags = {},
}
feijoada.atlas = "images/inventoryimages/feijoada.xml"
AddPrefabPostInit("images/inventoryimages/feijoada.tex")
AddCookerRecipe("cookpot", feijoada)
AddCookerRecipe("portablecookpot", feijoada)