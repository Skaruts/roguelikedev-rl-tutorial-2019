import random
import ../tile_types
import ../geometry

{.experimental: "codeReordering".}


type
    House* = ref object of Rect
        id:int
        # rect*:Rect
        door_pos*:Point
        cellmap*:seq[seq[TileType]]

    HouseGenerator* = ref object
        tilemap*:seq[seq[TileType]]


proc `$`*(h: House): string =
  return "House(" & "x:" & $(h.x) & " y:" & $(h.y) & " w:" & $(h.w) & " h:" & $(h.h) & ")"


proc new_house*(x, y, w, h:int):House =
    new result
    result.x = x
    result.y = y

    result.x2 = x + w
    result.y2 = y + h
    result.w = w
    result.h = h

    result.pos = point(x, y)
    result.size = point(w, h)


method create_house*(self:HouseGenerator, house:House) {.base.} =
    # var rect = house.rect
    house.cellmap = newSeq[ seq[TileType] ](house.h)
    for j in 0..<house.h:
        house.cellmap[j] = newSeq[TileType](house.w)

    # make walls
    # --------------------------------------------
    for j in 0..<house.h:
        for i in 0..<house.w:
            if i == 0 or i == house.w-1 or j == 0 or j == house.h-1:
                house.cellmap[j][i] = WallStone
            else:
                house.cellmap[j][i] = FloorWooden

    # Find place for a door
    # --------------------------------------------
    var num_doors:int = 2

    # if house is too small make only one door
    if house.w * house.h <= 40:
        num_doors = 1

    # TODO: maybe check which quadrant of the map the house is in
    # and favor pointing the doors toward the center (or wherever the
    # town square is, or something like that)

    self.place_door(house)


method place_door(self:HouseGenerator, house:House) {.base.} =
    # pick a random tile on a wall
    let v = rand(1..house.h-2)
    let h = rand(1..house.w-2)
    let wall = rand(100)

    if wall < 25:                               # left wall
        house.cellmap[v][0] = Door_V
        house.door_pos = point(0, v)
    elif wall < 50:                             # right wall
        house.cellmap[v][house.w-1] = Door_V
        house.door_pos = point(house.w-1, v)
    elif wall < 75:                             # top wall
        house.cellmap[0][h] = Door_H
        house.door_pos = point(h, 0)
    else:                                       # bottom wall
        house.cellmap[house.h-1][h] = Door_H
        house.door_pos = point(h, house.h-1)


