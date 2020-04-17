local prefabfiles = {
    "moonrock_chip",
    "moon_armor",
}

for _,v in pairs(prefabfiles) do
    table.insert(PrefabFiles, v)
end

local assets = {
    Asset("ATLAS", "images/inventoryimages/moonrock_chip.xml"),
    Asset("ATLAS", "images/inventoryimages/armor_greengem.xml"),
}

for _,v in pairs(assets) do
    table.insert(Assets, v)
end

AddRecipe("moonrock_chip",
    {
        Ingredient("moonrocknugget", 3),
        Ingredient("moonglass", 6),
    },
    RECIPETABS.MOON_ALTAR,    -- tab
    TECH.MOON_ALTAR_TWO,   -- level
    nil,
    nil,
    true,
    nil,
    nil,
    "images/inventoryimages/moonrock_chip.xml",
    "moonrock_chip.tex"
)

AddRecipe("moon_armor",
    {
        Ingredient("moonrock_chip", 3, "images/inventoryimages/moonrock_chip.xml", false, "moonrock_chip.tex"),
        Ingredient("yellowgem", 1),
        Ingredient("armorruins", 1),
    },
    RECIPETABS.MOON_ALTAR,    -- tab
    TECH.MOON_ALTAR_TWO,   -- level
    nil,
    nil,
    true,
    nil,
    nil,
    "images/inventoryimages/armor_greengem.xml",
    "armor_greengem.tex"
)