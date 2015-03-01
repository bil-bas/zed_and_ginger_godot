extends Node

const CHASE_SPEED = 2
const LEVEL_MARGIN = 12 # Tiles at the ends.

var player
var level 
var mesh_manager
var progress
var finish_x
var chase_x
var theme_music
var finish_music
var level_number
var achievements
var x_distance

func _ready():
    mesh_manager = get_node(@'/root/mesh_manager')
    level = get_node(@'World/Viewport/Level')
    progress = get_node(@'CanvasLayer/ScorePanel/LevelProgress')
    theme_music = get_node(@'Music/Theme')
    finish_music = get_node(@'Music/Finish')
    achievements = get_node(@'/root/achievements')

func setup():
    var data = Globals.get("level_data")
    var filename = Globals.get("level_filename")
    level_number = Globals.get("level_number")

    var level_setup = level.setup(data, filename, false)
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
    x_distance = start_x

    set_fixed_process(true)

func _fixed_process(delta):
    chase_x += CHASE_SPEED * delta
    var player_x = player.get_translation().x
    progress.set_value(player_x)
    progress.chase_x = chase_x

    if player_x > x_distance:
        achievements.increment_stat("METRES_WALKED", player_x - x_distance)
        x_distance = player_x

    if player_x <= chase_x:
        player.caught()
        set_fixed_process(false)
        achievements.save()
    elif player_x >= finish_x:
        player.finish()
        theme_music.stop()
        finish_music.play()
        set_fixed_process(false)
        if level_number > 0:
            achievements.increment_stat("COMPLETED_LEVEL_%d" % level_number)
        achievements.save()

func create_player(grid):
    player = mesh_manager.new_mesh_object("player")

    var level = get_node(@'World/Viewport/Level')
    level.add_child(player)
    player.set_translation(level.grid_to_world(grid))

func _on_BackButton_pressed():
    get_node(@'/root/Root/SceneManager').goto("res://main_menu/main_menu.xscn")
