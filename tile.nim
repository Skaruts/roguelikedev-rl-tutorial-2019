import sktcod, tile_types, glyphs, settings
export tile_types


type Tile* = ref object
    explored*:bool
    obstacle*:bool
    opaque*:bool
    tile_type*:TileType
    glyph*:char
    color*:Color
    color_dark*:Color


proc new_tile*(tile_type:TileType=EmptyTile, glyph:char=char(0), color:Color=Black, obstacle:bool=false, opaque:bool=false):Tile =
    new result
    result.explored = false
    result.obstacle = obstacle
    result.opaque = opaque
    result.glyph = glyph
    result.tile_type = FloorGrass
    result.color = color
    if tile_use_faded_dark_color:
        result.color_dark = color
        colorScaleHSV(addr(result.color_dark), 1.0, tile_dark_factor)
    else:
        result.color_dark = tile_constant_dark_color


method set_as*(self:Tile, tile_type:TileType, glyph:char, color:Color, obstacle:bool=false, opaque:bool=false) {.base.} =
    self.explored = false
    self.obstacle = obstacle
    self.opaque = opaque
    self.glyph = glyph
    self.tile_type = tile_type
    self.color = color
    if tile_use_faded_dark_color:
        self.color_dark = color
        colorScaleHSV(addr(self.color_dark), 1.0, tile_dark_factor)
    else:
        self.color_dark = tile_constant_dark_color

