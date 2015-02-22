extends "object.gd"

func object_type():
    return "TILE"

var is_floor setget set_is_floor, get_is_floor
func get_is_floor():
    return is_floor
func set_is_floor(value):
    is_floor = value

var type setget set_type, get_type
func get_type():
    return data.type
func set_type(value):
    data.type = value
    get_node(@'MeshInstance').animation = value

func _ready():
    var object_data = get_node(@'/root/object_data')
    var layer = object_data.CollisionLayer
    set_layer_mask(layer.TILES_PLAYER + layer.TILES_ITEMS + layer.TILES_MOVING_ITEMS)
