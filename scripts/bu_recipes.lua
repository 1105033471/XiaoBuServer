AddRecipe("moonrock_chip",
    {
        Ingredient("moonrocknugget", 3),
        Ingredient("moonglass", 6),
    },
    RECIPETABS.MOON_ALTAR,
    TECH.MOON_ALTAR_TWO,
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
    RECIPETABS.MOON_ALTAR,
    TECH.MOON_ALTAR_TWO,
    nil,
    nil,
    true,
    nil,
    nil,
    "images/inventoryimages/armor_greengem.xml",
    "armor_greengem.tex"
)

AddRecipe("rawling",
    {
        Ingredient("shroom_skin", 1),
        Ingredient("rope", 1),
        Ingredient("feather_robin", 2),
    },
    RECIPETABS.SURVIVAL,
    TECH.SCIENCE_ONE,
    nil,
    nil,
    false,
    3,
    nil,
    "images/inventoryimages/rawling.xml",
    "rawling.tex"
)

-- Ä©Ó°Ïä
AddRecipe("skull_chest",
    {
        Ingredient("purplegem", 1),
        Ingredient("boards", 1),
    },
    RECIPETABS.MAGIC,
    TECH.MAGIC_TWO,
    "skull_chest_placer",
    1,
    nil,
    nil,
    nil,
    "images/inventoryimages/skull_chest.xml",
    "skull_chest.tex"
)

-- Ë½ÈËÏä×Ó
AddRecipe("personal_chest",
    {
        -- Ingredient("purplegem", 1),
        Ingredient("treeroot", 4, "images/inventoryimages/treeroot.xml", false, "treeroot.tex"),
        Ingredient("boards", 6),
        Ingredient("livinglog", 4),
    },
    RECIPETABS.TOWN,
    TECH.NONE,
    "personal_chest_placer",
    1,
    nil,
    nil,
    nil,
    "images/inventoryimages/personal_chest.xml",
    "personal_chest.tex"
)

-- ±´¿ÇÏä×Ó
-- AddRecipe("pearlmussel",
--     {
--         -- Ingredient("purplegem", 1),
--         Ingredient("treeroot", 4, "images/inventoryimages/treeroot.xml", false, "treeroot.tex"),
--         Ingredient("boards", 6),
--         Ingredient("livinglog", 4),
--     },
--     RECIPETABS.TOWN,
--     TECH.NONE,
--     "pearlmussel_placer",
--     1,
--     nil,
--     nil,
--     nil,
--     "images/inventoryimages/personal_chest.xml",
--     "personal_chest.tex"
-- )
