
###############################################################################
#   Sort of a wrapper to libtcod_nim, to avoid having to cast everything
#   to and from C types and pointers
###############################################################################

import libtcod
export libtcod


proc consoleInitRoot*(w, h:int, title:string, fullscreen:bool = false, renderer:Renderer = RENDERER_SDL) =
    libtcod.consoleInitRoot(cint(w), cint(h), cstring(title), fullscreen, renderer)



proc sysCheckForEvent*(event_mask:int, key:var Key, mouse:var Mouse): Event =
    return libtcod.sysCheckForEvent(cint(event_mask), addr(key), addr(mouse))



proc consolePutChar*(con:Console, x, y, c:SomeInteger, flag:BkgndFlag = BKGND_DEFAULT) =
    libtcod.consolePutChar(con, x.cint, y.cint, c.cint, flag)

proc consolePutChar*(con:Console, x, y:SomeInteger, c:char, flag:BkgndFlag = BKGND_DEFAULT) =
    libtcod.consolePutChar(con, x.cint, y.cint, c.cint, flag)

