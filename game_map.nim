import random
import sktcod, settings, tile, entity, glyphs, geometry
import map_gen/map_ids
import map_gen/cave_gen
import map_gen/dungeon_gen

{.experimental: "codeReordering".}


type
    GameMap* = ref object
        w*:int
        h*:int
        tiles:seq[seq[Tile]]
        fov_map*:Map


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


method init_fov*(self:GameMap):Map {.base.} =
    self.fov_map = mapNew(self.w, self.h)

    for y in 0..<self.h:
        for x in 0..<self.w:
            mapSetProperties(self.fov_map, x, y, not self.tiles[y][x].opaque, not self.tiles[y][x].obstacle)

    return self.fov_map


method recompute_fov*(self:GameMap, x, y:int, radius:int, algo:FovAlgorithm=FovBasic, light_walls:bool=true) {.base.} =
    mapComputeFov(self.fov_map, x, y, radius, light_walls, algo)


method is_obstacle*(self:GameMap, x, y:int):bool {.base.} =
    return x < 0 or x >= self.w or y < 0 or y >= self.h or
        self.tiles[y][x].obstacle


method is_opaque*(self:GameMap, x, y:int):bool {.base.} =
    return self.tiles[y][x].opaque


method get_tile*(self:GameMap, x, y:int):Tile {.base.} =
    return self.tiles[y][x]


method set_tile(self:GameMap, x, y:int, tt:TileType) {.base.} =
    if x >= 0 and y >= 0 and x < self.w and y < self.h:
       self.set_tile_nc(x, y, tt)


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

        of Door_V:      self.tiles[y][x].set_as(Door_V,       GLYPH_DOOR_V,         COLOR_DOOR,         true, true)
        of Door_H:      self.tiles[y][x].set_as(Door_H,       GLYPH_DOOR_H,         COLOR_DOOR,         true, true)
        # of Door_Open:   self.tiles[y][x].set_as(Door_H,       GLYPH_DOOR_O,         COLOR_DOOR_O,       false, false)

        of Window_V:    self.tiles[y][x].set_as(Window_V,     GLYPH_WINDOW_V,       COLOR_WINDOW,       true, false)
        of Window_H:    self.tiles[y][x].set_as(Window_H,     GLYPH_WINDOW_H,       COLOR_WINDOW,       true, false)
        else:
            discard





###############################################################################
#
#       map generation
#
###############################################################################
method make_map*(self:GameMap, player:Entity, entities:var seq[Entity]) {.base.} =
    let MW = self.w     # for readibility
    let MH = self.h

    # create a temporary tile map
    #---------------------------------------------------------------------------
    var tilemap = newSeq[ seq[int] ](MH)
    for j in 0..<MH:
        tilemap[j] = newSeq[int](MW)


    #   MAKE THE MAPS
    #---------------------------------------------------------------------------
    # make the forest map   - tree = 1, path = 3
    let cg = CaveGenerator(w:MW, h:MH, birth_limit:3, death_limit:3, alive_chance:25, smooth_steps:10)
    cg.build_caves(tilemap)

    # # make the village map  - house = 2
    let dg = DungeonGenerator(w:MW, h:MH, room_min_size:6, room_max_size:8, max_rooms:30)
    dg.make_rooms(tilemap)

    # # make houses' walls
    for room in dg.rooms:
        for j in 0..<room.h:
            for i in 0..<room.w:
                if i == 0 or j == 0 or i == room.w-1 or j == room.h-1:
                    tilemap[room.y+j][room.x+i] = WALL_ID
                else:
                    tilemap[room.y+j][room.x+i] = ROOM_ID


    # # CREATE ENTITIES
    # #---------------------------------------------------------------------------

    # maybe doors should be the last thing, but for now that would make some houses inaccessible

    self.create_doors(tilemap, dg.rooms, entities)     # (make walls into invisible walls)
    self.create_windows(tilemap, dg.rooms, entities)
    self.create_furniture(tilemap, dg.rooms, entities) # (make walls into invisible walls if they block sight)
    # self.create_lights(tilemap)


    # # MAKE THE PATHS MAP    - path = 4
    # (using tunneler 2-3 wide A*s going from door to door?)
    # #---------------------------------------------------------------------------
    # self.make_paths(tilemap)


    # # ERODE THE PATH TILES
    # #---------------------------------------------------------------------------
    # cg.smooth(tilemap)


    # FINISH THE MAP, SET THE ACTUAL TILES
    #---------------------------------------------------------------------------
    for j in 0..<MH:
        for i in 0..<MW:
            var tile = tilemap[j][i]
            case tile
                of TREE_ID:
                    if rand(100) < 95:  self.set_tile_nc(i, j, TreePine)
                    else:               self.set_tile_nc(i, j, TreeOak)

                of FLOOR_ID:
                    # if any cell in cardinal directions is a tree, make this grass
                    if  tilemap[j-1][ i ] == TREE_ID or
                        tilemap[j+1][ i ] == TREE_ID or
                        tilemap[ j ][i-1] == TREE_ID or
                        tilemap[ j ][i+1] == TREE_ID:
                            self.set_tile_nc(i, j, FloorGrass)
                    # if not, make it dirt, but have a 25% chance to still be grass
                    else:
                        if rand(100) < 75:  self.set_tile_nc(i, j, FloorDirt)
                        else:               self.set_tile_nc(i, j, FloorGrass)

                of HALLWAY_ID:  self.set_tile_nc(i, j, FloorDirt)
                of WALL_ID:     self.set_tile_nc(i, j, WallStone)
                of ROOM_ID:     self.set_tile_nc(i, j, FloorWooden)
                of DOOR_V_ID:   self.set_tile_nc(i, j, Door_V)
                of DOOR_H_ID:   self.set_tile_nc(i, j, Door_H)
                of WINDOW_V_ID: self.set_tile_nc(i, j, Window_V)
                of WINDOW_H_ID: self.set_tile_nc(i, j, Window_H)
                # of WATER_ID:    self.set_tile_nc(i, j, Water)
                else: discard


    # PLACE THE PLAYER SOMEWHERE, WHERE IT'S A FLOOR AND IT'S OUTDOORS
    #---------------------------------------------------------------------------
    let WALKABLES = [VOID_ID, FLOOR_ID, HALLWAY_ID]
    while true:
        let pos = point( rand(5..MW-5), rand(5..MH-5) )
        if tilemap[pos.y][pos.x] in WALKABLES:
            player.x = pos.x
            player.y = pos.y
            break


method create_doors(self:GameMap, tilemap:var seq[seq[int]], rooms:seq[Rect], entities:var seq[Entity]) {.base.} =
    # naively put down some doors for now
    for room in rooms:
        while true:
            let v = rand(2..<room.h-2)
            let h = rand(2..<room.w-2)
            let wall = rand(100)

            if wall < 25:                               # left wall
                let x = room.x
                let y = room.y+v
                if tilemap[y][x-1] == FLOOR_ID:
                    tilemap[y][x] = DOOR_V_ID
                    # entities.add( new_door(x, y, char(GLYPH_DOOR_V)) )
                    break
            elif wall < 50:                             # right wall
                let x = room.x+room.w-1
                let y = room.y+v
                if tilemap[y][x+1] == FLOOR_ID:
                    tilemap[y][x] = DOOR_V_ID
                    # entities.add( new_door(x, y, char(GLYPH_DOOR_V)) )
                    break
            elif wall < 75:                             # top wall
                let x = room.x+h
                let y = room.y
                if tilemap[y-1][x] == FLOOR_ID:
                    tilemap[y][x] = DOOR_H_ID
                    # entities.add( new_door(x, y, char(GLYPH_DOOR_H)) )
                    break
            else:                                       # bottom wall
                let x = room.x+h
                let y = room.y+room.h-1
                if tilemap[y+1][x] == FLOOR_ID:
                    tilemap[y][x] = DOOR_H_ID
                    # entities.add( new_door(x, y, char(GLYPH_DOOR_H)) )
                    break


method create_windows(self:GameMap, tilemap:var seq[seq[int]], rooms:seq[Rect], entities:var seq[Entity]) {.base.} =
    # naively put down some windows
    for room in rooms:
        var num_windows = 5

        while num_windows > 0:
            let v = rand(2..<room.h-2)
            let h = rand(2..<room.w-2)
            let wall = rand(100)

            if wall < 25:                               # left wall
                let x = room.x
                let y = room.y+v
                if tilemap[y][x] notin DOOR_IDS and tilemap[y-1][x] notin DOOR_IDS and tilemap[y+1][x] notin DOOR_IDS:
                    tilemap[y][x] = WINDOW_V_ID
                    # entities.add( new_window(x, y, char(GLYPH_WINDOW_V)) )
                    num_windows -= 1
            elif wall < 50:                             # right wall
                let x = room.x+room.w-1
                let y = room.y+v
                if tilemap[y][x] notin DOOR_IDS and tilemap[y-1][x] notin DOOR_IDS and tilemap[y+1][x] notin DOOR_IDS:
                    tilemap[y][x] = WINDOW_V_ID
                    # entities.add( new_window(x, y, char(GLYPH_WINDOW_V)) )
                    num_windows -= 1
            elif wall < 75:                             # top wall
                let x = room.x+h
                let y = room.y
                if tilemap[y][x] notin DOOR_IDS and tilemap[y][x-1] notin DOOR_IDS and tilemap[y][x+1] notin DOOR_IDS:
                    tilemap[y][x] = WINDOW_H_ID
                    # entities.add( new_window(x, y, char(GLYPH_WINDOW_H)) )
                    num_windows -= 1
            else:                                       # bottom wall
                let x = room.x+h
                let y = room.y+room.h-1
                if tilemap[y][x] notin DOOR_IDS and tilemap[y][x-1] notin DOOR_IDS and tilemap[y][x+1] notin DOOR_IDS:
                    tilemap[y][x] = WINDOW_H_ID
                    # entities.add( new_window(x, y, char(GLYPH_WINDOW_H)) )
                    num_windows -= 1


method create_furniture(self:GameMap, tilemap:var seq[seq[int]], rooms:seq[Rect], entities:var seq[Entity]) {.base.} =
    # place a bed and night stand
    for room in rooms:
        let x1 = room.x+1
        let y1 = room.y+1
        let x2 = room.x+room.w-2
        let y2 = room.y+room.h-2

        var bed_corner:string

        # place beds
        while true:
            # pick a corner
            let r = rand(100)

            if   r < 25:   bed_corner = "tl"  # top left
            elif r < 50:   bed_corner = "tr"  # top right
            elif r < 75:   bed_corner = "br"  # bottom right
            else:          bed_corner = "bl"  # bottom left

            # TODO: beds should be a multi-tile entity
            if bed_corner == "tl":                              # top-left (x1, y1)
                if tilemap[y1-1][x1+1] notin DOOR_IDS and tilemap[y1+1][x1-1] notin DOOR_IDS:
                    # if there aren't doors around it, place bed and night stand
                    entities.add( new_entity(x1  , y1  , char(220), DesaturatedPink, LighterGrey) )
                    entities.add( new_entity(x1  , y1+1, char(219), DesaturatedPink) )
                    entities.add( new_entity(x1+1, y1  , char(254), Sepia) )
                    # stuff was placed successfuly, break out of the loop
                    break
            elif bed_corner == "tr":                            # top-right (x2, y1)
                if tilemap[y1-1][x2-1] notin DOOR_IDS and tilemap[y1+1][x2+1] notin DOOR_IDS:
                    entities.add( new_entity(x2  , y1  , char(221), DesaturatedPink, LighterGrey) )
                    entities.add( new_entity(x2-1, y1  , char(219), DesaturatedPink) )
                    entities.add( new_entity(x2  , y1+1, char(254), Sepia) )
                    break
            elif bed_corner == "br":                            # bottom-right (x2, y2)
                if tilemap[y2-1][x2+1] notin DOOR_IDS and tilemap[y2+1][x2-1] notin DOOR_IDS:
                    entities.add( new_entity(x2  , y2  , char(223), DesaturatedPink, LighterGrey) )
                    entities.add( new_entity(x2  , y2-1, char(219), DesaturatedPink) )
                    entities.add( new_entity(x2-1, y2  , char(254), Sepia) )
                    break
            else:                                               # bottom-left (x1, y2)
                if tilemap[y2+1][x1+1] notin DOOR_IDS and tilemap[y2-1][x1-1] notin DOOR_IDS:
                    entities.add( new_entity(x1  , y2  , char(222), DesaturatedPink, LighterGrey) )
                    entities.add( new_entity(x1+1, y2  , char(219), DesaturatedPink) )
                    entities.add( new_entity(x1  , y2-1, char(254), Sepia) )
                    break

        # place tables
        while true:
            # pick a corner
            let r = rand(100)

            var table_corner:string

            # avoid placing in the same corner as the beds
            if   bed_corner == "tl":
                if   r < 33:    table_corner = "tr"
                elif r < 66:    table_corner = "br"
                else:           table_corner = "bl"
            elif bed_corner == "tr":
                if   r < 33:    table_corner = "tl"
                elif r < 66:    table_corner = "br"
                else:           table_corner = "bl"
            elif bed_corner == "br":
                if   r < 33:    table_corner = "tl"
                elif r < 66:    table_corner = "tr"
                else:           table_corner = "bl"
            else: # bed_corner == "bl":
                if   r < 33:    table_corner = "tl"
                elif r < 66:    table_corner = "tr"
                else:           table_corner = "br"

            if table_corner == "tl":                              # top-left (x1, y1)
                if tilemap[y1-1][x1+1] notin DOOR_IDS and tilemap[y1+1][x1-1] notin DOOR_IDS:
                    # if there aren't doors around it, place bed and night stand
                    entities.add( new_entity(x1  , y1  , char(4), Sepia) )  # table
                    entities.add( new_entity(x1+1, y1  , char(7), DarkSepia) )  # chairs
                    entities.add( new_entity(x1  , y1+1, char(7), DarkSepia) )
                    # stuff was placed successfuly, break out of the loop
                    break
            elif table_corner == "tr":                            # top-right (x2, y1)
                if tilemap[y1-1][x2-1] notin DOOR_IDS and tilemap[y1+1][x2+1] notin DOOR_IDS:
                    entities.add( new_entity(x2  , y1  , char(4), Sepia) )
                    entities.add( new_entity(x2-1, y1  , char(7), DarkSepia) )
                    entities.add( new_entity(x2  , y1+1, char(7), DarkSepia) )
                    break
            elif table_corner == "br":                            # bottom-right (x2, y2)
                if tilemap[y2-1][x2+1] notin DOOR_IDS and tilemap[y2+1][x2-1] notin DOOR_IDS:
                    entities.add( new_entity(x2  , y2  , char(4), Sepia) )
                    entities.add( new_entity(x2-1, y2  , char(7), DarkSepia) )
                    entities.add( new_entity(x2  , y2-1, char(7), DarkSepia) )
                    break
            else:                                               # bottom-left (x1, y2)
                if tilemap[y2-1][x1-1] notin DOOR_IDS and tilemap[y2+1][x1+1] notin DOOR_IDS:
                    entities.add( new_entity(x1  , y2  , char(4), Sepia) )
                    entities.add( new_entity(x1  , y2-1, char(7), DarkSepia) )
                    entities.add( new_entity(x1+1, y2  , char(7), DarkSepia) )
                    break

