extends "object.gd"

func _ready():
    var mesh = get_node(@"MeshInstance")
    mesh.set_flag(3, data.cast_shadow)
    mesh.set_flag(4, data.receive_shadow)
    mesh.animation = "default"