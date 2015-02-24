extends Node

var scene_manager
var button_prefab = preload("res://prefabs/my_button.xscn")
var utilities

func _ready():
    scene_manager = get_node(@'/root/Root/SceneManager')
    utilities = get_node(@"/root/utilities")

func setup():
    yield()

    var container = get_node("Panel/List/Levels")
    
    var files = utilities.list_files_in_directory("levels")
    files.sort()
    for i in range(files.size()):
        var filename = "res://levels/%s" % files[i]
        var level_data = utilities.load_json(filename)

        var button = button_prefab.instance()
        button.set_text("%d: %s" % [i + 1, level_data["name"]])
        button.connect("pressed", self, "_on_level_selected", [filename, level_data])
        container.add_child(button)
        #yield()

func _on_level_selected(filename, level_data):
    Globals.set("level_filename", filename)
    Globals.set("level_data", level_data)
    scene_manager.goto("res://game/editor.xscn")

func _on_BackButton_pressed():
	scene_manager.goto("res://main_menu/main_menu.xscn")
