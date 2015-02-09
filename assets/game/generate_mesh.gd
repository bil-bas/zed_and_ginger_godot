extends Spatial

func _ready():
    var mesh_manager = get_node("/root/mesh_manager")
    var player = mesh_manager.new_mesh_object("player")
    var translation = player.get_translation()
    translation.z += 2
    translation.y += 2
    player.set_translation(translation)
    self.add_child(player)
