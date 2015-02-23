extends Node

const CHASE_SPEED = 2
const LEVEL_MARGIN = 10 # Tiles at the ends.

var player
var level 
var mesh_manager
var progress
var finish_x
var chase_x
var theme_music
var finish_music

func _ready():
    mesh_manager = get_node(@'/root/mesh_manager')
    level = get_node(@'World/Viewport/Level')
    progress = get_node(@'CanvasLayer/ScorePanel/LevelProgress')
    theme_music = get_node(@'Music/Theme')
    finish_music = get_node(@'Music/Finish')

func setup():
    var level_setup = level.setup(false)
    while level_setup.is_valid():
        level_setup.resume()
        yield()

    var start_x = LEVEL_MARGIN
    chase_x = start_x - 2
    progress.chase_x = chase_x
    
    finish_x = level.get_length() - LEVEL_MARGIN
    progress.set_min(start_x)
    progress.set_max(finish_x)

    create_player(Vector2(start_x, 3))

    set_fixed_process(true)

func _fixed_process(delta):
    chase_x += CHASE_SPEED * delta
    var player_x = player.get_translation().x
    progress.set_value(player_x)
    progress.chase_x = chase_x

    if player_x <= chase_x:
        player.caught()
        set_fixed_process(false)
    elif player_x >= finish_x:
        player.finish()
        theme_music.stop()
        finish_music.play()
        set_fixed_process(false)

func create_player(grid):
    player = mesh_manager.new_mesh_object("player")

    var level = get_node(@'World/Viewport/Level')
    level.add_child(player)
    player.set_translation(level.grid_to_world(grid))

func _on_BackButton_pressed():
    get_node(@'/root/Root/SceneManager').goto("res://main_menu/main_menu.xscn")
