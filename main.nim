import tables
import sktcod, entity, rendering, game_map

{.experimental: "codeReordering".}


type
    ActionKind = enum
        AKtup, AKbool

    Action = ref object
        name:string
        case kind:ActionKind
            of AKtup:   dir:tuple[x:int, y:int]
            of AKbool:  val:bool
            else:       discard


proc main() =
    let
        SW:int = 80
        SH:int = 50

        MW:int = 80
        MH:int = 45

        colors:Table[string, Color] = {
            "dark_wall":colorRGB(50, 50, 150),
            "dark_ground":colorRGB(0, 0, 100)
        }.toTable

    var
        running:bool = true

        key:Key
        mouse:Mouse
        window_title:string = "Seriously Amazing Dungeons Of Death        (nim/libtcod)        r/roguelikedev rl tutorial thing 2019"
        con:Console = consoleNew(SW, SH)

        player:Entity = new_entity(int(SW/2), int(SH/2), '@', Amber)
        npc:Entity = new_entity(int(SW/2-5), int(SH/2-4), '@', Green)
        entities:seq[Entity] = @[player, npc]

        game_map:GameMap = new_game_map(MW, MH)


    # consoleSetCustomFont("./data/fonts/dejavu16x16_gs_tc.png", FONT_TYPE_GREYSCALE or FONT_LAYOUT_TCOD)
    consoleSetCustomFont("./data/fonts/terminal16x16_gs_ro.png", FONT_TYPE_GREYSCALE or FONT_LAYOUT_CP437)

    consoleInitRoot(SW, SH, window_title, false)

    # gigantic improvement in performance from SDL1 renderer
    # SLD1 ~80fps vs SDL2 3100+ fps
    sysSetRenderer(RENDERER_SDL2)
    sysSetFps(60)

    while true:
        discard sysCheckForEvent((ord(EVENT_KEY_PRESS) or ord(EVENT_MOUSE)), key, mouse)

        render_all(con, entities, game_map, SW, SH, colors)
        consoleFlush()
        clear_all(con, entities)

        let action:Action = handle_keys(key)
        case action.name
            of "move":
                let dx:int = action.dir.x
                let dy:int = action.dir.y
                if not game_map.is_obstacle(player.x + dx, player.y + dy):
                    player.move(dx, dy)
            of "exit":
                return
            of "fullscreen":
                consoleSetFullscreen(action.val)
            else:
                discard


proc handle_keys(key:Key):Action =
    if key.vk == K_Up:       return Action( name:"move", kind:AKtup, dir:( 0, -1) )
    if key.vk == K_Down:     return Action( name:"move", kind:AKtup, dir:( 0,  1) )
    if key.vk == K_Left:     return Action( name:"move", kind:AKtup, dir:(-1,  0) )
    if key.vk == K_Right:    return Action( name:"move", kind:AKtup, dir:( 1,  0) )

    if consoleIsWindowClosed() or key.vk == K_Escape:
        return Action( name:"exit" )

    if key.vk == K_Enter and key.lalt:
        return Action( name:"fullscreen", kind:AKbool, val:not consoleIsFullscreen() )

    return Action()






###############################################################################
#       Run Forest, run!
###############################################################################
main()

sktcod.quit()
quit(QUIT_SUCCESS)


