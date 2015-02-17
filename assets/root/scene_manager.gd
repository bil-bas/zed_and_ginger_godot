extends Node

var current_scene
var root_scene

func _ready():
    # Load first scene.
    root_scene = get_tree().get_root().get_node("RootScene")
    if root_scene != null:
        current_scene = root_scene.get_node("DummyScene")
        goto("res://main_menu/main_menu.xscn")

func goto(scene):
    # remove current scene from root and enqueue it for deletion
    # (when deleted, it will be removed)
    current_scene.queue_free()

    # load and add new scene to root
    current_scene = load(scene).instance()
    root_scene.add_child(current_scene)