extends "object.gd"

func object_type():
    return "TILE"

var data setget set_data
func set_data(value):
    data = value

var type setget set_type, get_type
func get_type():
    return data.type
func set_type(value):
    data.type = value
    get_node("MeshInstance").animation = value

func _get(name):
    return data.get(name)

func _get_property_list():
    return data._get_property_list()
