extends "object.gd"

func object_type():
    return "TILE"

var is_floor setget set_is_floor, get_is_floor
func get_is_floor():
    return is_floor
func set_is_floor(value):
    is_floor = value  

func _ready():
    var object_data = get_node(@'/root/object_data')
    var layer = object_data.CollisionLayer
    set_layer_mask(layer.TILES_PLAYER + layer.TILES_ITEMS + layer.TILES_MOVING_ITEMS)
    create_spawn_items()

    get_node(@"MeshInstance").animation = data.type

func create_spawn_items():
    var object_data = get_node(@'/root/object_data')
    var mesh_manager = get_node(@'/root/mesh_manager')

    for name in get("spawn_items"):
        var item = mesh_manager.new_mesh_object(name)
        item.data = object_data.create_item(name, self.grid)
        get_node(@'Items').add_child(item)
