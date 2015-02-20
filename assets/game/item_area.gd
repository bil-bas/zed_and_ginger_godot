extends "object.gd"

func object_type():
    return "ITEM_AREA"

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
    for body in get_overlapping_bodies():
        body.on_in_area(self)
