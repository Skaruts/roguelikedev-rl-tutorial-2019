
###############################################################################
#   Sort of a wrapper to libtcod_nim, to avoid having to cast everything
#   to and from C types and pointers
###############################################################################

import libtcod
export libtcod

proc consoleNew*(w, h: int): Console =
    return libtcod.consoleNew(w.cint, h.cint)


proc consoleInitRoot*(w, h:int, title:string, fullscreen:bool = false, renderer:Renderer = RENDERER_SDL) =
    libtcod.consoleInitRoot(w.cint, h.cint, title.cstring, fullscreen, renderer)


proc sysCheckForEvent*(event_mask:int, key:var Key, mouse:var Mouse): Event =
    return libtcod.sysCheckForEvent(cint(event_mask), addr(key), addr(mouse))


proc consolePutChar*(con:Console, x, y, c:SomeInteger, flag:BkgndFlag = BKGND_DEFAULT) =
    libtcod.consolePutChar(con, x.cint, y.cint, c.cint, flag)


proc consolePutChar*(con:Console, x, y:SomeInteger, c:char, flag:BkgndFlag = BKGND_DEFAULT) =
    libtcod.consolePutChar(con, x.cint, y.cint, c.cint, flag)


proc consoleBlit*(src:Console, xSrc, ySrc, wSrc, hSrc:int, dst:Console, xDst, yDst:int, foregroundAlpha:float=1.0, backgroundAlpha:float=1.0) =
    libtcod.consoleBlit(src, cint(xSrc), cint(ySrc), cint(wSrc), cint(hSrc), dst, cint(xDst), cint(yDst), cfloat(foregroundAlpha), cfloat(backgroundAlpha))


proc consoleSetCharBackground*(con:Console, x, y:int, col:Color, flag:BkgndFlag) =
    libtcod.consoleSetCharBackground(con, x.cint, y.cint, col, flag)


proc mapNew*(width, height: int):Map =
    return mapNew(cint(width), cint(height))

proc mapSetProperties*(map: Map, x, y: int, isTransparent, isWalkable: bool) =
    mapSetProperties(map, cint(x), cint(y), isTransparent, isWalkable)

proc mapComputeFov*(map:Map, player_x, player_y:int, max_radius:int = 0, lightWalls:bool = true, algo:FovAlgorithm = FOV_BASIC) =
    mapComputeFov(map, cint(player_x), cint(player_y), cint(max_radius), light_walls, algo)

proc mapIsInFov*(map:Map; x, y:int): bool =
    mapIsInFov(map, cint(x), cint(y))

proc colorScaleHSV*(color:ptr Color, saturationCoef, valueCoef:float) =
    colorScaleHSV(color, cfloat(saturationCoef), cfloat(valueCoef))