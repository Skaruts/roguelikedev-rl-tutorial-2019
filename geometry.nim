
###############################################################################
#
#       Simple point coordinates (int)
#
###############################################################################
type Point* = ref object of RootObj
    x*:int
    y*:int


proc point*(x, y:int):Point =
    new result
    result.x = x
    result.y = y


# not tested
proc `==`*(a, b:Point):bool = a.x == b.x and a.y == b.y

proc `$`*(p: Point): string =
  return "Point(" & $(p.x) & "," & $(p.y) & ")"


###############################################################################
#
#       Rectangle (int)
#
###############################################################################
# this allows calling rect.x as rect.x1 if desired. Same for y and y1.
template x1(self : untyped): untyped = self.x
template y1(self : untyped): untyped = self.y


type Rect* = ref object of RootObj
    x*:int
    y*:int
    x2*:int
    y2*:int
    w*:int
    h*:int
    pos*, size*:Point


proc `$`*(r: Rect): string =
  return "Rect(" & $(r.x) & "," & $(r.y) & $(r.w) & "," & $(r.h) & ")"


proc rect*(x, y, w, h:int):Rect =
    new result
    result.x = x
    result.y = y

    result.x2 = x + w
    result.y2 = y + h
    result.w = w
    result.h = h

    result.pos = point(x, y)
    result.size = point(w, h)


method center*(self:Rect):Point {.base.} =
    new result
    result.x = int( (self.x1 + self.x2) div 2 )
    result.y = int( (self.y1 + self.y2) div 2 )


method intersects*(a, b:Rect):bool {.base.} =
    return a.x1 <= b.x2 and a.x2 >= b.x1 and
           a.y1 <= b.y2 and a.y2 >= b.y1

method intersects*(r:Rect, p:Point):bool {.base.} =
    return p.x >= r.x and p.x <= r.x2 and
           p.y >= r.y and p.y <= r.y2

method intersects*(r:Rect, x, y:int):bool {.base.} =
    return x >= r.x and x <= r.x2 and
           y >= r.y and y <= r.y2