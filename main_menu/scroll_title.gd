extends Label

func _ready():
	set_process(true)

func _process(delta):
	var pos = get_pos()
	set_pos(Vector2(min(pos.x + delta * 200, 200), pos.y))
