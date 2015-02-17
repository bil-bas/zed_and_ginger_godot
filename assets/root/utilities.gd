extends Node

var current_scene
var root_scene

func _ready():
    var logger = get_node("/root/logger")
    logger.level = logger.Level.DEBUG
    logger.truncate_log_file = true
    logger.filename = "user://log.txt"

    # Load first scene.
    root_scene = get_tree().get_root().get_node("RootScene")
    if root_scene != null:
        current_scene = root_scene.get_node("DummyScene")
        goto_scene("res://main_menu/main_menu.xscn")


func load_json(name):
    var json = File.new()
    assert(json.file_exists(name))
    json.open(name, File.READ)
    var data = {}
    var status = data.parse_json(json.get_as_text())
    json.close()
    assert(status == OK)

    return data


func save_json(name, data):
    var json = File.new()
    json.open(name, File.WRITE)
    json.store_string(data.to_json())
    json.close()


func goto_scene(scene):
    # remove current scene from root and enqueue it for deletion
    # (when deleted, it will be removed)
    current_scene.queue_free()

    # load and add new scene to root
    current_scene = load(scene).instance()
    root_scene.add_child(current_scene)
