import sktcod

var
    show_fps*:bool = false
    tile_use_faded_dark_color*:bool = true                  # use faded colors or single color outside fov
    tile_constant_dark_color*:Color = colorRGB(0, 32, 96)   # color to use for tiles outside fov, if faded-color is off
    tile_dark_factor*:float = 0.25                          # how much to darken the tiles' colors outside fov - 0 = fully faded, 1 = no fade

    use_fov*:bool = false
    # use_lighting:bool = true
