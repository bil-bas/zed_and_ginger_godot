extends Node

class ChangeTileAction:
    var _tile
    var _old_type
    var _new_type

    func _init(tile, new_type):
        _tile = tile
        _old_type = tile.type
        _new_type = new_type

    func do_action():
        _tile.type = _new_type

    func undo_action():
        _tile.type = _old_type

const LMB = 1

var logger
var camera
var ray
var history
var save_button
var undo_button
var redo_button
var level

func _ready():
    logger = get_node("/root/logger")

    camera = get_node("World/Viewport/Camera")
    level = get_node("World/Viewport/Level")
    ray = camera.get_node("RayCast")

    history = get_node("History")
    save_button = get_node("ButtonPanel/Buttons/SaveButton")
    undo_button = get_node("ButtonPanel/Buttons/UndoButton")
    redo_button = get_node("ButtonPanel/Buttons/RedoButton")
    
    set_process(true)

    logger.debug("Created 3d viewport")

func _process(delta):
    if ray.is_enabled() and ray.is_colliding():
        var collider = ray.get_collider()
        if collider != null:
            if collider.object_type() == "TILE":
                var type 
                if collider.type == "GOO":
                    type = "WHITE_TILE"
                else:
                    type = "GOO"

                var action = ChangeTileAction.new(collider, type)
                history.add(action)
                update_history_buttons()

        ray.set_enabled(false)

func _input_event(event):
    if event.type == InputEvent.MOUSE_BUTTON and event.is_pressed():
        if event.button_index == LMB:
            select_with_cursor(event.global_pos)

func select_with_cursor(mouse_pos, length=100):
    var dir = camera.project_ray_normal(mouse_pos) # Uses camera projection matrix to project mouse 2D coordinates to 3D vector in world space
   
    # Since the direction has to be in local space, we transform it by cameras inverse transformation matrix
    var transform = camera.get_camera_transform().basis.inverse()
    var local_dir = transform * dir
   
    ray.set_cast_to(local_dir * length)
    ray.set_enabled(true)

func _on_SaveButton_pressed():
	level.save()

func _on_UndoButton_pressed():
	history.undo()
	update_history_buttons()

func _on_RedoButton_pressed():
	history.redo()
	update_history_buttons()

func _on_BackButton_pressed():
    get_node("/root/utilities").goto_scene("res://main_menu/main_menu.xscn")

func update_history_buttons():
	undo_button.set_disabled(not history.get_can_undo())
	redo_button.set_disabled(not history.get_can_redo())
    