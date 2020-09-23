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
      name = "tiles",       --  TODO，什么意思     ground or tiles
      firstgid = 1,
      filename = "../../../../tools/tiled/dont_starve/ground.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../tools/tiled/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 384,
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
        2, 2, 2, 10, 10, 10, 2, 2, 2,
        2, 2, 2, 10, 9, 10, 2, 2, 2,
        2, 2, 10, 9, 9, 9, 10, 2, 2,
        10, 10, 9, 9, 9, 9, 9, 10, 10,
        10, 9, 9, 9, 9, 9, 9, 9, 10,
        10, 10, 9, 9, 9, 9, 9, 10, 10,
        2, 2, 10, 9, 9, 9, 10, 2, 2,
        2, 2, 2, 10, 9, 10, 2, 2, 2,
        2, 2, 2, 10, 10, 10, 2, 2, 2
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
          width = 64,
          height = 64,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "skeleton_player",
          shape = "rectangle",
          x = 0,
          y = 448,
          width = 64,
          height = 64,
          visible = true,
          properties = {
            ["scenario"] = "skeleton_death",
          }
        },
        {
          name = "",
          type = "skeleton_player",
          shape = "rectangle",
          x = 64,
          y = 512,
          width = 64,
          height = 64,
          visible = true,
          properties = {
            ["scenario"] = "skeleton_death",
          }
        },
        {
          name = "",
          type = "skeleton_player",
          shape = "rectangle",
          x = 448,
          y = 512,
          width = 64,
          height = 64,
          visible = true,
          properties = {
            ["scenario"] = "skeleton_death",
          }
        },
        {
          name = "",
          type = "skeleton_player",
          shape = "rectangle",
          x = 512,
          y = 448,
          width = 64,
          height = 64,
          visible = true,
          properties = {
            ["scenario"] = "skeleton_death",
          }
        },
        {
          name = "",
          type = "skeleton_player",
          shape = "rectangle",
          x = 448,
          y = 0,
          width = 64,
          height = 64,
          visible = true,
          properties = {
            ["scenario"] = "skeleton_death",
          }
        },
        {
          name = "",
          type = "skeleton_player",
          shape = "rectangle",
          x = 512,
          y = 64,
          width = 64,
          height = 64,
          visible = true,
          properties = {
            ["scenario"] = "skeleton_death",
          }
        },
        {
          name = "",
          type = "skeleton_player",
          shape = "rectangle",
          x = 64,
          y = 0,
          width = 64,
          height = 64,
          visible = true,
          properties = {
            ["scenario"] = "skeleton_death",
          }
        },
        {
          name = "",
          type = "skeleton_player",
          shape = "rectangle",
          x = 0,
          y = 64,
          width = 64,
          height = 64,
          visible = true,
          properties = {
            ["scenario"] = "skeleton_death",
          }
        },
        {
          name = "",
          type = "maxwelllight",
          shape = "rectangle",
          x = 128,
          y = 128,
          width = 64,
          height = 64,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "maxwelllight",
          shape = "rectangle",
          x = 384,
          y = 128,
          width = 64,
          height = 64,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "maxwelllight",
          shape = "rectangle",
          x = 128,
          y = 384,
          width = 64,
          height = 64,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "maxwelllight",
          shape = "rectangle",
          x = 384,
          y = 384,
          width = 64,
          height = 64,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "treasurechest",
          shape = "rectangle",
          x = 256,
          y = 64,
          width = 64,
          height = 64,
          visible = true,
          properties = {
            ["scenario"] = "pray_chest",
          }
        },
        {
          name = "",
          type = "treasurechest",
          shape = "rectangle",
          x = 448,
          y = 256,
          width = 64,
          height = 64,
          visible = true,
          properties = {
            ["scenario"] = "pray_chest_fake",
          }
        },
        {
          name = "",
          type = "treasurechest",
          shape = "rectangle",
          x = 256,
          y = 448,
          width = 64,
          height = 64,
          visible = true,
          properties = {
            ["scenario"] = "pray_chest_fake",
          }
        },
        {
          name = "",
          type = "treasurechest",
          shape = "rectangle",
          x = 64,
          y = 256,
          width = 64,
          height = 64,
          visible = true,
          properties = {
            ["scenario"] = "pray_chest_fake",
          }
        }
      }
    }
  }
}
