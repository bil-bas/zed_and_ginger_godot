extends CollisionObject

var data setget set_data
func set_data(value):
    data = value

func _get(name):
    return data.get(name)

func _get_property_list():
    return data._get_property_list()
