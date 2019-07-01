import sktcod

var
    show_fps*:bool = false
    tile_use_faded_dark_color*:bool = true
    tile_constant_dark_color*:Color = colorRGB(0, 32, 96)
    tile_dark_factor*:float = 0.25

    use_fov*:bool = false
    use_lighting:bool = true
