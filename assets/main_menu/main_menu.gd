# Handle button clicks on the main menu
# Resize the active area of the game to fill the window.

extends Node2D

var scene_manager
var logger

func _ready():
    scene_manager = get_node(@'/root/Root/SceneManager')
    logger = get_node(@'/root/logger')

func setup():
    yield()

func _on_Play_pressed():
    var filename = "res://levels/1.json"
    Globals.set("level_filename", filename)
    var level_data = get_node(@"/root/utilities").load_json(filename)
    Globals.set("level_data", level_data)

    scene_manager.goto("res://game/play.xscn")

func _on_Editor_pressed():
    scene_manager.show_dialog("res://pick_level/pick_level_to_edit.xscn")

func _on_Settings_pressed():
    scene_manager.show_dialog("res://settings/settings.xscn")

func _on_Quit_pressed():
    OS.get_main_loop().quit()
