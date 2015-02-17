func _ready():
    hide()
    set_process(true)

func _process(delta):
    show()
    set_process(false)