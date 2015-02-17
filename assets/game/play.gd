extends Node

var player
var mesh_manager

func _ready():
    mesh_manager = get_node("/root/mesh_manager")
    create_player(Vector2(4, 3))

func create_player(grid):
    player = mesh_manager.new_mesh_object("player")

    var level = get_node("World/Viewport/Level")
    level.add_child(player)
    player.set_translation(level.grid_to_world(grid))