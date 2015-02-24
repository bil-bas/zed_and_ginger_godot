extends CollisionObject

var data setget set_data
func set_data(value):
    data = value

func _get(name):
    return data.get(name)

func _get_property_list():
    return data._get_property_list()

func _ready():
    var object_data = get_node(@'/root/object_data')
    var mesh_manager = get_node(@'/root/mesh_manager')

    for name in data.get("spawn_items"):
        var item = mesh_manager.new_mesh_object(name)
        item.data = object_data.create_item(name, self.grid)
        get_node(@'Items').add_child(item)