import tables, random
import sktcod, entity, rendering, game_map, settings

{.experimental: "codeReordering".}


type
    ActionKind = enum
        ATup, ABool

    Action = ref object
        name:string
        case kind:ActionKind
            of ATup:   dir:tuple[x:int, y:int]
            of ABool:  val:bool
            else:      discard


proc main() =
    randomize() # <-- seed goes here (for now)

    let
        SW:int = 80     # screen width
        SH:int = 50     # screen height

        MW:int = 80     # map width
        MH:int = 45     # map height
    var
        running:bool = true

        fov_map:Map
        fov_recompute:bool = true
        # TODO: move these to settings
        fov_light_walls:bool = true
        fov_algo:FovAlgorithm = Fov_Restrictive # Fov_Basic, Fov_Diamond, Fov_Shadow, Fov_Permissive_0 - 8, Fov_Restrictive
        fov_radius:int = 80

        key:Key
        mouse:Mouse
        window_title:string = "Seriously Amazing Village Of Death        (nim/libtcod)        r/roguelikedev rl tutorial thing 2019"
        con:Console = consoleNew(SW, SH)

        player:Entity = new_entity(int(SW/2), int(SH/2), '@', Amber)
        # npc:Entity = new_entity(int(SW/2-5), int(SH/2-4), '@', Green)
        entities:seq[Entity] = @[player]

        game_map:GameMap = create_map(MW, MH, player, entities, fov_map)

    # consoleSetCustomFont("./data/fonts/dejavu16x16_gs_tc.png", FONT_TYPE_GREYSCALE or FONT_LAYOUT_TCOD)
    # consoleSetCustomFont("./data/fonts/terminal16x16_gs_ro.png", FONT_TYPE_GREYSCALE or FONT_LAYOUT_CP437)
    # consoleSetCustomFont("./data/fonts/cp437_8x8.png", FONT_TYPE_GREYSCALE or FONT_LAYOUT_ASCII_INROW)
    # consoleSetCustomFont("./data/fonts/cp437_10x10.png", FONT_TYPE_GREYSCALE or FONT_LAYOUT_ASCII_INROW)
    # consoleSetCustomFont("./data/fonts/cp437_16x16.png", FONT_TYPE_GREYSCALE or FONT_LAYOUT_ASCII_INROW)
    consoleSetCustomFont("./data/fonts/cp437_20x20.png", FONT_TYPE_GREYSCALE or FONT_LAYOUT_ASCII_INROW)

    consoleInitRoot(SW, SH, window_title, false)

    sysSetRenderer(RENDERER_SDL2)
    sysSetFps(60)

    while true:
        discard sysCheckForEvent((ord(EVENT_KEY_PRESS) or ord(EVENT_MOUSE)), key, mouse)

        if fov_recompute:
            game_map.recompute_fov(player.x, player.y, fov_radius, fov_algo)

        render_all(con, entities, game_map, SW, SH, fov_recompute)
        fov_recompute = false
        consoleFlush()
        clear_all(con, entities)

        let action:Action = handle_keys(key)
        case action.name
            of "move":
                let dx:int = action.dir.x
                let dy:int = action.dir.y

                if not game_map.is_obstacle(player.x + dx, player.y + dy):
                    player.move(dx, dy)
                    fov_recompute = true

            of "exit":          return
            of "fullscreen":    consoleSetFullscreen(action.val)
            of "new_map":       game_map = create_map(MW, MH, player, entities, fov_map)
            of "toggle_debug":  show_fps = not show_fps
            of "toggle_fov":    toggle_fov(con, game_map, player, fov_radius, fov_algo)
            else:
                discard


proc handle_keys(key:Key):Action =
    if key.vk == K_Up:       return Action( name:"move", kind:ATup, dir:( 0, -1) )
    if key.vk == K_Down:     return Action( name:"move", kind:ATup, dir:( 0,  1) )
    if key.vk == K_Left:     return Action( name:"move", kind:ATup, dir:(-1,  0) )
    if key.vk == K_Right:    return Action( name:"move", kind:ATup, dir:( 1,  0) )

    if key.vk == K_Space:    return Action( name:"new_map" )
    if key.vk == K_F1:       return Action( name:"toggle_debug" )
    if key.vk == K_F2:       return Action( name:"toggle_fov" )

    if consoleIsWindowClosed() or key.vk == K_Escape:
        return Action( name:"exit" )

    if key.vk == K_Enter and key.lalt:
        return Action( name:"fullscreen", kind:ABool, val:not consoleIsFullscreen() )

    return Action()


proc toggle_fov(con:Console, game_map:GameMap, player:Entity, fov_radius:int, fov_algo:FovAlgorithm) =
    use_fov = not use_fov
    consoleClear(con)
    game_map.recompute_fov(player.x, player.y, fov_radius, fov_algo)


proc create_map(MW, MH: int, player:Entity, entities:var seq[Entity], fov_map:var Map):GameMap =
    entities = @[player] # reset the entity list
    result = new_game_map(MW, MH)
    result.make_map(player, entities)
    fov_map = result.init_fov()





###############################################################################
#       Run Forest, run!
###############################################################################
main()

sktcod.quit()
quit(QUIT_SUCCESS)


