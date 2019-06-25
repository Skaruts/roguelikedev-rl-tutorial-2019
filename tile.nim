import sktcod, tile_types, glyphs
export tile_types


type Tile* = ref object
    obstacle*:bool
    opaque*:bool
    tile_type*:TileType
    glyph*:char
    color*:Color


proc new_tile*(tile_type:TileType=EmptyTile, glyph:char=char(0), color:Color=Black, obstacle:bool=false, opaque:bool=false):Tile =
    new result
    result.obstacle = obstacle
    result.opaque = opaque
    result.glyph = glyph
    result.tile_type = FloorGrass
    result.color = color


method set_as*(self:Tile, tile_type:TileType, glyph:char, color:Color, obstacle:bool=false, opaque:bool=false) {.base.} =
    self.obstacle = obstacle
    self.opaque = opaque
    self.glyph = glyph
    self.tile_type = tile_type
    self.color = color


