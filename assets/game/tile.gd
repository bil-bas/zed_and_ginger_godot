extends "object.gd"

func object_type():
    return "TILE"

var type setget set_type, get_type
func get_type():
    return data.type
func set_type(value):
    data.type = value
    get_node("MeshInstance").animation = value
