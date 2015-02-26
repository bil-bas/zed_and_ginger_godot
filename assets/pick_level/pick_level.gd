extends Node

var scene_manager
var button_prefab = preload("res://prefabs/my_button.xscn")
var utilities
var callback

func set_callback(value):
    callback = value

func _ready():
    scene_manager = get_node(@'/root/Root/SceneManager')
    utilities = get_node(@"/root/utilities")
    
    var files = utilities.list_files_in_directory("levels")
    files.sort()
    for i in range(files.size()):
        var filename = "res://levels/%s" % files[i]
        var level_data = utilities.load_json(filename)

        var button = button_prefab.instance()
        button.set_text("%d: %s" % [i + 1, level_data["name"]])
        button.connect("pressed", self, "_on_level_selected", [filename, level_data])
        get_node("Levels").add_child(button)

func _on_level_selected(filename, level_data):
    callback.call_func(filename, level_data)

func _on_CancelButton_pressed():
    scene_manager.close_dialog()
