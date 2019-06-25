import sktcod

const
    GLYPH_WALL*         = '#'
    GLYPH_FLOOR_DIRT*   = char(249) #'.'
    GLYPH_FLOOR_WOODEN* = char(249) #'.'
    GLYPH_FLOOR_GRASS*  = ','# '\''
    GLYPH_WINDOW_H*     = char(196)
    GLYPH_WINDOW_V*     = char(179)
    GLYPH_WATER*        = '~'
    GLYPH_OAKTREE*      = char(5)
    GLYPH_PINETREE*     = char(6)
    GLYPH_DOOR_V*       = char(179)
    GLYPH_DOOR_H*       = char(196)

let
    COLOR_GRASS_FLOOR*   = DarkerGreen
    COLOR_DIRT_FLOOR*    = DarkerSepia
    COLOR_WOODEN_FLOOR*  = Sepia
    COLOR_STONE_WALL*    = DarkGrey
    COLOR_WOODEN_WALL*   = LightSepia
    COLOR_WATER*         = Blue
    COLOR_WINDOW*        = LighterBlue
    COLOR_PINE_TREE*     = colorRGB(0, 180, 50)
    COLOR_OAK_TREE*      = colorRGB(129, 150, 0)
    COLOR_DOOR*          = LightSepia