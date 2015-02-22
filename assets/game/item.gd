extends "object.gd"

var is_horizontal = false
var collision_layer

func object_type():
    return "ITEM"

func _ready():
    var object_data = get_node(@'/root/object_data')
    collision_layer = object_data.CollisionLayer

    set_layer_mask(collision_layer.ITEMS_PLAYER)

    set_is_horizontal(data.initially_horizontal)

func on_in_area(area):
    pass

func set_is_horizontal(value):
    if is_horizontal == value:
        return

    is_horizontal = value

    if is_horizontal:
        set_rotation(Vector3(PI / 2, 0, 0))
        set_translation(get_translation() + Vector3(0, 0, -0.5))
    else:
        set_translation(get_translation() - Vector3(0, 0, -0.5))
        set_rotation(Vector3(0, 0, 0))

var velocity = Vector3() setget set_velocity
func set_velocity(value):
    velocity = value
    set_mode(RigidBody.MODE_RIGID)
    set_fixed_process(true)

func _fixed_process(delta):
    set_linear_velocity(velocity)
