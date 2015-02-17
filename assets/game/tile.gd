extends "object.gd"

func object_type():
    return "TILE"

var data setget set_data
func set_data(value):
    data = value

var is_floor setget set_is_floor, get_is_floor
func get_is_floor():
    return is_floor
func set_is_floor(value):
    assert(value in [true, false])
    is_floor = value

# Tile data.
var type setget set_type, get_type
func get_type():
    return data.type
func set_type(value):
    data.type = value
    get_node("MeshInstance").animation = value