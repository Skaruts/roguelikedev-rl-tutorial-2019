# const
#     FloorGrass  = 0
#     FloorDirt   = 1
#     FloorWooden = 2
#     WallStone   = 3
#     WallWooden  = 4
#     WindowSmall = 5
#     WindowTall  = 6

type
    TileType* = enum
        EmptyTile,
        FloorGrass, FloorDirt, FloorWooden,
        WallStone, WallWooden,
        TreeOak, TreePine,
        Window_V, Window_H,
        Door_V, Door_H, Door_Open

# const TILETYPES* = [ FloorGrass, FloorDirt, FloorWooden, WallStone, WallWooden, Window ]
# const OBSTACLES* = [ WallStone, WallWooden, TreeOak, TreePine, Window_V, Window_H, Door_V, Door_H ]
# const WALLS* = [ WallStone, WallWooden ]
# const TRANSPARENTS* = [ Window ]
# const WALKABLES* = [ FloorGrass, FloorDirt, FloorWooden ]
# const FLOORS* = [ FloorGrass, FloorDirt, FloorWooden ]