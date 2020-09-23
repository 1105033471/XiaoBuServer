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
AddIngredientValues({ "coffeebeans" }, { veggie = .5}, true, false)
local coffee ={    
    name = "coffee",
    test = function(cooker, names, tags) 
		return names.coffeebeans_cooked
			and ((names.coffeebeans_cooked == 3 and (names.butter or tags.dairy or names.honey or tags.sweetener))
			or (names.coffeebeans_cooked == 4))
    end,
    priority = 30,
    weight = 1,
    perishtime = TUNING.PERISH_FAST,
    cooktime = .25,
    tags = {},
    atlas = "images/inventoryimages/coffee.xml",
}
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
    perishtime = TUNING.PERISH_MED,
    cooktime = 1.5,
    potlevel = "low",
	floater = {"small", nil, nil},
    tags = {},
    atlas = "images/inventoryimages/tomato_soup.xml",
}
AddCookerRecipe("cookpot", tomato_soup)
AddCookerRecipe("portablecookpot", tomato_soup)

-- 八宝饭食谱
AddIngredientValues( { "jellybug" }, { veggie = .5, meat = .5 }, true, false)
local feijoada ={    
    name = "feijoada",
    test = function(cooker, names, tags) 
		return names.jellybug_cooked
			and (names.jellybug_cooked == 3 and (tags.meat and tags.meat >= 1))
    end,
    priority = 30,
    weight = 1,
    perishtime = TUNING.PERISH_SLOW,
    cooktime = .25,
    tags = {},
    atlas = "images/inventoryimages/feijoada.xml",
}
AddCookerRecipe("cookpot", feijoada)
AddCookerRecipe("portablecookpot", feijoada)

-- 为玩家添加咖啡组件，用于保存咖啡食用后的buff
AddPlayerPostInit(function(player)
  player:AddComponent("caffeinated")
end)
