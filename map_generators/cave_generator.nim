################################################################################
# cellular automata based off of
# https://gamedevelopment.tutsplus.com/tutorials/generate-random-cave-levels-using-cellular-automata--gamedev-9664
################################################################################
import random

{.experimental: "codeReordering".}


type
    CaveGenerator* = ref object
        w*:int
        h*:int
        birth_limit*:int
        death_limit*:int
        alive_chance*:int
        smooth_steps*:int


method init_map(self:CaveGenerator):seq[seq[bool]] {.base.} =
    result = newSeq[ seq[bool] ](self.h)
    for j in 0..<self.h:
        result[j] = newSeq[bool](self.w)


method build_caves*(self:CaveGenerator):seq[seq[bool]] {.base.} =
    var cavemap = self.init_map()

    # randomize cave map
    for j in 0..<self.h:
        for i in 0..<self.w:
            if rand(100) < self.alive_chance:   cavemap[j][i] = true
            else:                               cavemap[j][i] = false

    # smooth it out
    for i in 0..<self.smooth_steps:
        self.smooth_cave(cavemap)

    return cavemap


method smooth_cave(self:CaveGenerator, old_map:var seq[seq[bool]]) {.base.} =
    var new_map = old_map

    for j in 0..<self.h:
        for i in 0..<self.w:
            var nbs = self.count_neighbors(old_map, i, j)

            # if cell alive with too many neighbors, KILL!
            if old_map[j][i]:
                if nbs < self.death_limit:   new_map[j][i] = false      # <= 3
                else:                        new_map[j][i] = true   # if it's already a tree, don't need to make it one again
            else:
                if nbs > self.birth_limit:   new_map[j][i] = true       # >= 4
                else:                        new_map[j][i] = false

    old_map = new_map


method count_neighbors*(self:CaveGenerator, cavemap:seq[seq[bool]], x, y:int):int {.base.} =
    result = 0

    for j in -1..1:
        for i in -1..1:
            if not (i == 0 and j == 0):
                var nb_x = x+i  # neighbor coords
                var nb_y = y+j

                # if it's out of bounds, count 1
                if nb_x < 1 or nb_y < 1 or nb_x >= self.w-1 or nb_y >= self.h-1 or cavemap[nb_y][nb_x]:
                    result += 1