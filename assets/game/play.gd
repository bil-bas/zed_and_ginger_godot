extends Node

var player
var level 
var mesh_manager

func _ready():
    mesh_manager = get_node("/root/mesh_manager")
    level = get_node("World/Viewport/Level")

func setup():
    var level_setup = level.setup()
    while level_setup.is_valid():
        level_setup.resume()
        yield()

    create_player(Vector2(4, 3))

func create_player(grid):
    player = mesh_manager.new_mesh_object("player")

    var level = get_node("World/Viewport/Level")
    level.add_child(player)
    player.set_translation(level.grid_to_world(grid))
