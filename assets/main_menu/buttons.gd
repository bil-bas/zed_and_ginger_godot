
# Handle button clicks on the main menu

extends GridContainer

var utilities

func _ready():
    utilities = get_node("/root/utilities")

func _on_Play_pressed():
    utilities.goto_scene("res://game/editor.xscn")

func _on_Editor_pressed():
    utilities.goto_scene("res://game/editor.xscn")

func _on_Quit_pressed():
    OS.get_main_loop().quit()
