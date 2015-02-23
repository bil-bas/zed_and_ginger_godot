extends Node

var player
var level 
var mesh_manager
var progress
var camera
var finish_x

func _ready():
    mesh_manager = get_node(@'/root/mesh_manager')
    level = get_node(@'World/Viewport/Level')
    progress = get_node(@'CanvasLayer/ScorePanel/LevelProgress')
    camera = get_node(@'World/Viewport/Camera')

func setup():
    var level_setup = level.setup(false)
    while level_setup.is_valid():
        level_setup.resume()
        yield()

    var start_x = 8
    finish_x = level.get_length() - 8
    progress.set_min(start_x)
    progress.set_max(finish_x)

    create_player(Vector2(start_x, 3))

    set_process(true)

func _process(delta):
    var x = player.get_translation().x
    progress.set_value(x)
    var camera_pos = camera.get_translation()
    camera_pos.x = x
    camera.set_translation(camera_pos)

func create_player(grid):
    player = mesh_manager.new_mesh_object("player")

    var level = get_node(@'World/Viewport/Level')
    level.add_child(player)
    player.set_translation(level.grid_to_world(grid))

func _on_BackButton_pressed():
    get_node(@'/root/Root/SceneManager').goto("res://main_menu/main_menu.xscn")
