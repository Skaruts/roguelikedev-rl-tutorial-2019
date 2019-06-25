import tables
import sktcod, entity, game_map, settings

{.experimental: "codeReordering".}


proc render_all*(con:Console, entities:seq[Entity], game_map:GameMap, SW, SH:int) =
    # draw map
    for y in 0..<game_map.h:
        for x in 0..<game_map.w:
            let tile = game_map.get_tile(x, y)

            consoleSetDefaultForeground(con, tile.color)
            consolePutChar(con, x, y, tile.glyph, BKGND_NONE)

    # draw entities
    for e in entities:
        draw_entity(con, e)

    # draw fps rates
    if settings.show_fps:
        consoleSetDefaultForeground(con, LightGrey)
        consolePrintfEx(    # print fps rates
            con, 0, 0, BKGND_NONE, LEFT, "fps:%d (%d ms)",
            sysGetFps(), int((sysGetLastFrameLength() * 1000))
        )

    # finish
    consoleBlit(con, 0, 0, SW, SH, nil, 0, 0)


proc clear_all*(con:Console, entities:seq[Entity]) =
    consolePrintfEx(con, 0, 0, BKGND_NONE, LEFT, "                                     ")
    for e in entities:
        clear_entity(con, e)


proc draw_entity(con:Console, e:Entity) =
    consoleSetDefaultForeground(con, e.color)
    consolePutChar(con, e.x, e.y, e.glyph, BKGND_NONE)


proc clear_entity(con:Console, e:Entity) =
    consolePutChar(con, e.x, e.y, ' ', BKGND_NONE)

