extends "object.gd"

func object_type():
    return "TILE"

func _ready():
    var object_data = get_node(@'/root/object_data')
    var layer = object_data.CollisionLayer
    set_layer_mask(layer.TILES_PLAYER + layer.TILES_ITEMS + layer.TILES_MOVING_ITEMS)

    get_node(@"MeshInstance").animation = data.type
