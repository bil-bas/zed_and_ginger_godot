extends Label

var pos

func _ready():
    set_process(true)
    pos = get_pos()

func _process(delta):    
    if pos.x >= 200:
        set_process(false)
        return
        
    pos.x +=delta * 200

    set_pos(pos)
