table.insert(PrefabFiles, "flowerbox")

table.insert(Assets, Asset( "ATLAS", "images/inventoryimages/flowerbox.xml" ))

AddMinimapAtlas("images/inventoryimages/flowerbox.xml")

AddRecipe("flowerbox",		-- 花盒制造配方
	{
		Ingredient("boards", 2),
		Ingredient("poop", 4)
	},
	RECIPETABS.TOWN,
	TECH.SCIENCE_TWO,
	"flowerbox_placer",
	1.5,		-- 建造距离，此处等同于蘑菇灯
	nil,
	nil,
	nil,
	"images/inventoryimages/flowerbox.xml",
	"flowerbox.tex"
)