import random
import sktcod, tile, entity, glyphs, geometry
import map_generators/cave_generator
import map_generators/house_generator

{.experimental: "codeReordering".}


type
    GameMap* = ref object
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
            self.tiles[j][i] = new_tile()


method get_tile*(self:GameMap, x, y:int):Tile {.base.} =
    return self.tiles[y][x]


method is_obstacle*(self:GameMap, x, y:int):bool {.base.} =
    return x < 0 or x >= self.w or y < 0 or y >= self.h or
        self.tiles[y][x].obstacle


method is_opaque*(self:GameMap, x, y:int):bool {.base.} =
    return self.tiles[y][x].opaque


# no bounds check
method set_tile_nc(self:GameMap, x, y:int, tt:TileType) {.base.} =
    case tt
        of FloorGrass:
            let r = rand(100)
            var color:Color
            if   r < 10: color = DarkestGreen
            elif r < 80: color = DarkerGreen
            else:        color = DarkGreen
            self.tiles[y][x].set_as(FloorGrass, GLYPH_FLOOR_GRASS, color, false, false)

        of FloorDirt:   self.tiles[y][x].set_as(FloorDirt,    GLYPH_FLOOR_DIRT,     COLOR_DIRT_FLOOR,   false, false)
        of FloorWooden: self.tiles[y][x].set_as(FloorWooden,  GLYPH_FLOOR_WOODEN,   COLOR_WOODEN_FLOOR, false, false)
        of WallStone:   self.tiles[y][x].set_as(WallStone,    GLYPH_WALL,           COLOR_STONE_WALL,   true, true)
        of WallWooden:  self.tiles[y][x].set_as(WallWooden,   GLYPH_WALL,           COLOR_WOODEN_WALL,  true, true)
        of TreeOak:     self.tiles[y][x].set_as(TreeOak,      GLYPH_OAKTREE,        COLOR_OAK_TREE,     true, true)
        of TreePine:    self.tiles[y][x].set_as(TreePine,     GLYPH_PINETREE,       COLOR_PINE_TREE,    true, true)

        of Door_V:      self.tiles[y][x].set_as(Door_V,       GLYPH_DOOR_V,         COLOR_DOOR,         true, false)
        of Door_H:      self.tiles[y][x].set_as(Door_H,       GLYPH_DOOR_H,         COLOR_DOOR,         true, false)

        of Window_V:    self.tiles[y][x].set_as(Window_V,     GLYPH_WINDOW_V,       COLOR_WINDOW,       true, false)
        of Window_H:    self.tiles[y][x].set_as(Window_H,     GLYPH_WINDOW_H,       COLOR_WINDOW,       true, false)
        else:
            discard


method set_tile(self:GameMap, x, y:int, tt:TileType) {.base.} =
    if x >= 0 and y >= 0 and x < self.w and y < self.h:
       self.set_tile_nc(x, y, tt)


###############################################################################
#
#       Village map algorithm
#
###############################################################################
method make_village*(self:GameMap, player:Entity) {.base.} =
    let MW = self.w     # for readibility
    let MH = self.h

    var tilemap = newSeq[ seq[TileType] ](MH)
    for j in 0..<MH:
        tilemap[j] = newSeq[TileType](self.w)

    # make the forest
    #---------------------------------------------------------------------------
    let
        cg = CaveGenerator(w:self.w, h:MH, birth_limit:3, death_limit:4, alive_chance:35, smooth_steps:4)
        cavemap = cg.build_caves()
        HOUSES = [WallStone, WallWooden, Door_V, Door_H, Window_V, Window_H, FloorWooden]

    # carve the caves
    for j in 0..<MH:
        for i in 0..<MW:
            if tilemap[j][i] notin HOUSES:
                if cavemap[j][i] or i < 1 or j < 1 or i >= MW-1 or j >= MH-1:
                    # place trees
                    if rand(100) > 95:  tilemap[j][i] = TreeOak
                    else:               tilemap[j][i] = TreePine
                else:
                    # place grass around trees, and dirt everywhere else
                    let nbs = cg.count_neighbors(cavemap, i, j)
                    let r = rand(100)
                    if nbs > 0 or r > 90:  tilemap[j][i] = FloorGrass
                    else:                  tilemap[j][i] = FloorDirt

    # make the houses (this code should be in a village_generator)
    #---------------------------------------------------------------------------
    let
        house_max_size:int = 10
        house_min_size:int = 6
        max_houses:int = 30
    var
        houses:seq[House] = newSeq[House](0)
        num_houses:int = 0

    for r in 0..<max_houses:
        let
            w:int = rand(house_min_size .. house_max_size)
            h:int = rand(house_min_size .. house_max_size)
            x:int = rand(3 .. MW - w - 3)
            y:int = rand(3 .. MH - h - 3)
        var
            # r = rect(x, y, w, h)
            new_house:House = new_house(x, y, w, h) # House(x:x, y:y, w:w, h:h)
            intersects:bool = false

        # check for intersections
        for house in houses:
            if new_house.intersects(house):
                intersects = true
                break

        # if house is valid
        if not intersects:
            let hg = HouseGenerator(tilemap:tilemap)
            hg.create_house(new_house)

            # carve the house in the tilemap
            for j in 0..<new_house.h:
                for i in 0..<new_house.w:
                    tilemap[new_house.y+j][new_house.x+i] = new_house.cellmap[j][i]

            houses.add(new_house)
            num_houses += 1

    # place the player somewhere, where it's a floor and it's outdoors
    #---------------------------------------------------------------------------
    while true:
        let pos = point( rand(5..MW-5), rand(5..MH-5) )
        if tilemap[pos.y][pos.x] in [FloorGrass, FloorDirt]:
            player.x = pos.x
            player.y = pos.y
            break

    # finish the map, set the actual tiles
    #---------------------------------------------------------------------------
    for j in 0..<MH:
        for i in 0..<MW:
            self.set_tile_nc(i, j, tilemap[j][i])

