import random
import ../geometry
import map_ids


type DungeonGenerator* = ref object
    room_min_size*:int
    room_max_size*:int
    max_rooms*:int
    w*:int
    h*:int
    rooms*:seq[Rect]


method make_rooms*(self:DungeonGenerator, tilemap:var seq[seq[int]]) {.base.} =
    for n in 0..<self.max_rooms:
        let
            w:int = rand(self.room_min_size .. self.room_max_size)
            h:int = rand(self.room_min_size .. self.room_max_size)
            x:int = rand(3 .. self.w - w - 3)
            y:int = rand(3 .. self.h - h - 3)
        var
            new_room:Rect = rect(x, y, w, h)
            intersects:bool = false

        # check for intersections
        for room in self.rooms:
            # echo new_room
            if new_room.intersects(room):
                intersects = true
                break

        # if room is valid, carve the room in the tilemap
        if not intersects:
            for j in 0..<new_room.h:
                for i in 0..<new_room.w:
                    tilemap[new_room.y+j][new_room.x+i] = ROOM_ID
                    # if i == 0 or j == 0 or i == new_room.w-1 or j == new_room.h-1:
                    #     tilemap[new_room.y+j][new_room.x+i] = WALL_ID
                    # else:
                    #     tilemap[new_room.y+j][new_room.x+i] = ROOM_ID

            self.rooms.add(new_room)


# make hallways
