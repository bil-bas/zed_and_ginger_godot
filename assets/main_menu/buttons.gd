
# Handle button clicks on the main menu

extends GridContainer

var scene_manager

func _ready():
    scene_manager = get_node("/root/scene_manager")

func _on_Play_pressed():
    scene_manager.goto("res://game/play.xscn")

func _on_Editor_pressed():
    scene_manager.goto("res://game/editor.xscn")

func _on_Quit_pressed():
    OS.get_main_loop().quit()
