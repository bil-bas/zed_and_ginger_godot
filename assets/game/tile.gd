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

    for item in get_node(@'Items').get_children():
        item.queue_free()

    create_spawn_items()

func _ready():
    var object_data = get_node(@'/root/object_data')
    var layer = object_data.CollisionLayer
    set_layer_mask(layer.TILES_PLAYER + layer.TILES_ITEMS + layer.TILES_MOVING_ITEMS)
    create_spawn_items()

func create_spawn_items():
    for name in get("spawn_items"):
        var item = get_node(@'/root/mesh_manager').new_mesh_object(name)
        item.get_node("MeshInstance").animation = "default"
        get_node(@'Items').add_child(item)
