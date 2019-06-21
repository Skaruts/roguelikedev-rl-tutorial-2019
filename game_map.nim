import tile

{.experimental: "codeReordering".}



type GameMap* = ref object
    w*:int
    h*:int
    tiles:seq[seq[Tile]]


proc new_game_map*(w, h:int):GameMap =
    new result
    result.w = w
    result.h = h

    result.init_tiles()


method init_tiles(self:GameMap) {.base.} =
    self.tiles = newSeq[ seq[Tile] ](self.h)

    for j in 0..<self.h:
        self.tiles[j] = newSeq[Tile](self.w)
        for i in 0..<self.w:
            self.tiles[j][i] = new_tile(false)
            # self.tiles[j].add( new_tile(false) )

    self.tiles[22][30].obstacle = true
    self.tiles[22][30].opaque = true
    self.tiles[22][31].obstacle = true
    self.tiles[22][31].opaque = true
    self.tiles[22][32].obstacle = true
    self.tiles[22][32].opaque = true


method is_obstacle*(self:GameMap, x, y:int):bool {.base.} =
    return x < 0 or x >= self.w or y < 0 or y >= self.h or
        self.tiles[y][x].obstacle

method is_opaque*(self:GameMap, x, y:int):bool {.base.} =
    return self.tiles[y][x].opaque