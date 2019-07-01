import sktcod
# import components


type Entity* = ref object
    x*:int
    y*:int
    glyph*:char
    fg*:Color
    bg*:Color
    # comps:seq[Component]

proc new_entity*(x, y:int, glyph:char, fg:Color, bg:Color = Black):Entity =
    new result
    result.x = x
    result.y = y
    result.glyph = glyph
    result.fg = fg
    result.bg = bg


method move*(e:Entity, dx, dy:int) {.base.} =
    e.x += dx
    e.y += dy


