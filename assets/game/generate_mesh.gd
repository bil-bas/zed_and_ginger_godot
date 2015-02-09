extends Spatial

func _ready():
    var mesh_manager = get_node("/root/mesh_manager")
    var player = mesh_manager.new_mesh_object("player")
    var translation = player.get_translation()
    translation.z += 2
    translation.y += 1.75
    player.set_translation(translation)
    self.add_child(player)

    for j in range(20):
        # Floor
        for i in range(5):
            var tile = mesh_manager.new_mesh_object("tile", i)
            tile.set_translation(Vector3(j * 8 * mesh_manager.PIXEL_SIZE, i * 8 * mesh_manager.PIXEL_SIZE, 0))
            add_child(tile)

        # Wall
        for i in range(5):
            var tile = mesh_manager.new_mesh_object("tile", i)
            tile.set_translation(Vector3(j * 8 * mesh_manager.PIXEL_SIZE, 0, i * 8 * mesh_manager.PIXEL_SIZE))
            var rotation = tile.get_rotation()
            rotation.x -= PI / 2
            tile.set_rotation(rotation)
            add_child(tile)