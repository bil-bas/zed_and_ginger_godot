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
    scene_manager.goto("res://game/play.xscn")

func _on_Editor_pressed():
    scene_manager.goto("res://game/editor.xscn")

func _on_Settings_pressed():
    scene_manager.goto("res://settings/settings.xscn")

func _on_Quit_pressed():
    OS.get_main_loop().quit()
