
type Tile* = ref object
    obstacle*:bool
    opaque*:bool

proc new_tile*(obstacle:bool, opaque:bool):Tile =
    new result
    result.obstacle = obstacle
    result.opaque = opaque

proc new_tile*(obstacle:bool):Tile =
    return new_tile(obstacle, obstacle)

