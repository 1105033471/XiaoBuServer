local prefabfiles = {
    "pugalisk_fountain",
    "waterdrop",        -- 水滴
    "lifeplant",        -- 水滴种植后的植物
    
    "sweet_potato",  	-- 甜菜根

    "grabbing_vine",    -- 藤曼
}
for _,v in pairs(prefabfiles) do
    table.insert(PrefabFiles, v)
end

local assets = {
    Asset("ATLAS", "images/inventoryimages/pugaliskfountain.xml"),
    Asset("ATLAS", "images/inventoryimages/waterdrop.xml"),

	Asset("ANIM", "anim/cave_exit_rope.zip"),
	Asset("ANIM", "anim/cave_exit_rope_build.zip"),
    Asset("ANIM", "anim/copycreep_build.zip"),
    
	-- Asset("SOUND", "sound/frog.fsb"),
}
for _,v in pairs(assets) do
    table.insert(Assets, v)
end

AddMinimapAtlas("images/inventoryimages/pugaliskfountain.xml")

AddIngredientValues({"sweet_potato"}, {veggie=1})
AddIngredientValues({"sweet_potato_cooked"}, {veggie=1})

TUNING.GRABBING_VINE_HEALTH = 100
TUNING.GRABBING_VINE_DAMAGE = 10
TUNING.GRABBING_VINE_ATTACK_PERIOD = 1
TUNING.GRABBING_VINE_TARGET_DIST = 3

--[[
AddRecipe("pugalisk_fountain",
    {
        Ingredient("cutstone", 10),
        Ingredient("ice", 15),
        Ingredient("moonglass", 5)
    },
    RECIPETABS.TOWN,
    TECH.SCIENCE_TWO,
    "pugalisk_fountain_placer",
    5,
    nil,
    nil,
    nil,
    "images/inventoryimages/pugaliskfountain.xml",
    "pugaliskfountain.tex"
)
--]]