import tables
import sktcod, entity, game_map, settings

{.experimental: "codeReordering".}


proc render_all*(con:Console, entities:seq[Entity], game_map:GameMap, SW, SH:int, fov_recompute:bool) =
    # I don't like really this
    # BUG: when fov is turned on/off, it only updates visually when the player moves again
    # if fov_recompute:
    if use_fov:  render_with_fov(con, entities, game_map, SW, SH)
    else:        render_no_fov(con, entities, game_map, SW, SH)

    draw_fps(con)

    # finish
    consoleBlit(con, 0, 0, SW, SH, nil, 0, 0)


proc render_no_fov(con:Console, entities:seq[Entity], game_map:GameMap, SW, SH:int) =
    # echo "render no fov"
    for y in 0..<game_map.h:
        for x in 0..<game_map.w:
            let tile = game_map.get_tile(x, y)
            consoleSetDefaultForeground(con, tile.color)
            consolePutChar(con, x, y, tile.glyph, BKGND_NONE)

    # draw entities
    for e in entities:
        draw_entity(con, e)


proc render_with_fov(con:Console, entities:seq[Entity], game_map:GameMap, SW, SH:int) =
    # echo "render with fov"
    for y in 0..<game_map.h:
        for x in 0..<game_map.w:
            let visible = mapIsInFov(game_map.fov_map, x, y)
            let tile = game_map.get_tile(x, y)

            if visible and not tile.explored:
                tile.explored = true

            if tile.explored:
                if visible:
                    ### TODO: implement lighting - something like:
                    # if use_lighting:
                    #     let light_level = game_map.light_map[y][x]
                    #     var color = tile.color
                    #     colorScaleHSV(addr(color), 1.0, light_level)
                    #     consoleSetDefaultForeground(con, color)

                    consoleSetDefaultForeground(con, tile.color)
                else:
                    ### TODO: implement lighting - something like:
                    # if use_lighting:
                    #     let light_level = game_map.light_map[y][x]
                    #     var color = tile.color_dark
                    #     colorScaleHSV(addr(color), 1.0, light_level)
                    #     consoleSetDefaultForeground(con, color)

                    consoleSetDefaultForeground(con, tile.color_dark)

                consolePutChar(con, x, y, tile.glyph, BKGND_NONE)

    # draw entities
    for e in entities:
        ### TODO: stationary entities should be always visible. Like light sources, furniture, etc
        if mapIsInFov(game_map.fov_map, e.x, e.y):
            draw_entity(con, e)


proc draw_fps(con:Console) =
    # draw fps rates
    if settings.show_fps:
        consoleSetDefaultForeground(con, LightGrey)
        consolePrintfEx(
            con, 0, 0, BKGND_NONE, LEFT, "fps:%d (%d ms)",
            sysGetFps(), int((sysGetLastFrameLength() * 1000))
        )


proc clear_all*(con:Console, entities:seq[Entity]) =
    consolePrintfEx(con, 0, 0, BKGND_NONE, LEFT, "                                     ")
    for e in entities:
        clear_entity(con, e)


proc draw_entity(con:Console, e:Entity) =
    consoleSetDefaultBackground(con, e.bg)
    consoleSetDefaultForeground(con, e.fg)
    consolePutChar(con, e.x, e.y, e.glyph, BKGND_SET)


proc clear_entity(con:Console, e:Entity) =
    consoleSetDefaultBackground(con, Black)
    consolePutChar(con, e.x, e.y, ' ', BKGND_SET)

