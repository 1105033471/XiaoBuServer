return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 9,
  height = 9,
  tilewidth = 64,		-- 这里和下面的参数，是控制这个static_layout的大小！！
  tileheight = 64,
  properties = {},
  tilesets = {
    {
      name = "tiles",
      firstgid = 1,
	  -- filename = "../../../../tools/tiled/dont_starve/ground.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../tools/tiled/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 256,
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 9,
      height = 9,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        13, 3, 3, 6, 13, 6, 6, 6, 13,
        6, 26, 26, 5, 26, 26, 13, 26, 6,
        13, 6, 11, 13, 5, 11, 3, 13, 6,
        5, 6, 3, 5, 3, 13, 11, 26, 6,
        3, 26, 11, 3, 3, 5, 3, 6, 13,
        26, 13, 11, 13, 3, 3, 11, 13, 6,
        6, 13, 3, 11, 11, 3, 3, 6, 26,
        6, 26, 5, 13, 3, 6, 5, 6, 6,
        13, 6, 26, 6, 13, 13, 6, 3, 13
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "pugalisk_fountain",
          shape = "rectangle",
          x = 256,
          y = 256,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
