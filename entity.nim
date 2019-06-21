import sktcod


type Entity* = ref object
    x*:int
    y*:int
    glyph*:char
    color*:Color


proc new_entity*(x, y:int, glyph:char, color:Color):Entity =
    new result
    result.x = x
    result.y = y
    result.glyph = glyph
    result.color = color


method move*(e:Entity, dx, dy:int) {.base.} =
    e.x += dx
    e.y += dy