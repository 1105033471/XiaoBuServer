local prefabfiles = {
	"pugalisk_fountain",
	"waterdrop",		-- ˮ��
	"lifeplant",		-- ˮ����ֲ���ֲ��
	
	"sweet_potato",		-- ��˸�
}
for _,v in pairs(prefabfiles) do
	table.insert(PrefabFiles, v)
end

local assets = {
	Asset("ATLAS", "images/inventoryimages/pugaliskfountain.xml"),
	Asset("ATLAS", "images/inventoryimages/waterdrop.xml"),
}
for _,v in pairs(assets) do
	table.insert(Assets, v)
end

AddMinimapAtlas("images/inventoryimages/pugaliskfountain.xml")

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