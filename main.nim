import sktcod

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
    var
        running:bool = true
        SW:int = 80
        SH:int = 50
        player_x:int = int(SW/2)
        player_y:int = int(SH/2)
        key:Key
        mouse:Mouse
        window_title:string = "Seriously Amazing Dungeons Of Death        (nim/libtcod)        r/roguelikedev rl tutorial thing 2019"

    # consoleSetCustomFont("./data/fonts/dejavu16x16_gs_tc.png", FONT_TYPE_GREYSCALE or FONT_LAYOUT_TCOD)
    consoleSetCustomFont("./data/fonts/terminal16x16_gs_ro.png", FONT_TYPE_GREYSCALE or FONT_LAYOUT_CP437)

    consoleInitRoot(SW, SH, window_title, false)

    # gigantic improvement in performance from SDL1 renderer
    # SLD1 ~80fps vs SDL2 3100+ fps
    sysSetRenderer(RENDERER_SDL2)
    sysSetFps(60)

    while true:
        discard sysCheckForEvent((ord(EVENT_KEY_PRESS) or ord(EVENT_MOUSE)), key, mouse)

        consoleSetDefaultForeground(nil, Amber)
        consoleSetDefaultBackground(nil, Black)

        consolePutChar(nil, player_x, player_y, '@', BKGND_NONE)

        consolePrintfEx(    # print fps rates
            nil, 0, 0, BKGND_NONE, LEFT, "fps:%d (%d ms)",
            sysGetFps(), (int)(sysGetLastFrameLength() * 1000)
        )

        consoleFlush()

        # clear stuff
        consolePutChar(nil, player_x, player_y, ' ', BKGND_NONE)
        consolePrintfEx(nil, 0, 0, BKGND_NONE, LEFT, "                                     ")

        let action:Action = handle_keys(key)
        case action.name
            of "move":
                player_x += action.dir.x
                player_y += action.dir.y
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


