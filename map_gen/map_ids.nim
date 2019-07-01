const
    VOID_ID*:int      = 0
    TREE_ID*:int      = 1
    FLOOR_ID*:int      = 2 # natural floor
    ROOM_ID*:int      = 3
    HALLWAY_ID*:int      = 4 # floor carved by AI or tunneling algorithms (in case the distinction is needed)
    WATER_ID*:int     = 5

    WALL_ID*:int      = 10
    DOOR_V_ID*:int      = 11
    DOOR_H_ID*:int      = 12
    WINDOW_V_ID*:int    = 13
    WINDOW_H_ID*:int    = 14

let DOOR_IDS* = [DOOR_V_ID, DOOR_H_ID]
let WINDOW_IDS* = [WINDOW_V_ID, WINDOW_H_ID]