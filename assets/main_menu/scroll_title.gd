extends Label

func _ready():
    set_process(true)

func _process(delta):
    var pos = get_pos()
    
    if pos.x >= 200:
        set_process(false)
        return

    set_pos(Vector2(pos.x + delta * 200, pos.y))
