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
const RMB = 2

var logger
var camera
var ray
var history
var save_button
var undo_button
var redo_button
var level
var current_tile_type = "WHITE_TILE"
var paint

func _ready():
    logger = get_node("/root/logger")

    camera = get_node("World/Viewport/Camera")
    level = get_node("World/Viewport/Level")
    ray = camera.get_node("RayCast")

    history = get_node("History")
    save_button = get_node("ButtonsPanel/Buttons/SaveButton")
    undo_button = get_node("ButtonsPanel/Buttons/UndoButton")
    redo_button = get_node("ButtonsPanel/Buttons/RedoButton")

    fill_item_picker()

    set_process(true)

    logger.debug("Created 3d viewport")

func _process(delta):
    if ray.is_enabled() and ray.is_colliding():
        var collider = ray.get_collider()
        if collider != null:
            if collider.object_type() == "TILE":
                if paint:
                    var action = ChangeTileAction.new(collider, current_tile_type)
                    history.add(action)
                    update_history_buttons()
                else:
                    current_tile_type = collider.type

        ray.set_enabled(false)

func _on_EditorPanel_input_event(event):
    if event.type == InputEvent.MOUSE_BUTTON and event.is_pressed():
        if event.button_index == LMB:
            paint = true # Paint.
        elif event.button_index == RMB:
            paint = false # Pick type.
        
        select_with_cursor(event.pos)

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
    get_node("/root/scene_manager").goto("res://main_menu/main_menu.xscn")

func update_history_buttons():
	undo_button.set_disabled(not history.get_can_undo())
	redo_button.set_disabled(not history.get_can_redo())
    
func _on_TilePicker_input_event(event):
    if event.type == InputEvent.MOUSE_BUTTON and event.is_pressed():
        var tile_index = int(event.pos.x / 50) + int(event.pos.y / 50) * 8
        current_tile_type = get_node("/root/tile_data").INDEX_TO_NAME[tile_index]

func _on_ItemPicker_input_event(event):
    pass

func fill_item_picker():
    var item_pickers = get_node("ItemPickerPanel/ItemPickers")
    item_pickers.add_child(item_picker("flytrap"))
    item_pickers.add_child(item_picker("flytrap"))

func item_picker(name):
    var mesh_manager = get_node("/root/mesh_manager")
    var item = mesh_manager.new_mesh_object(name)

    var picker = load("res://prefabs/item_picker.xscn").instance()
    picker.get_node("Viewport").add_child(item)
    item.get_node("MeshInstance").frame = 1
    item.get_node("MeshInstance").stop() # Stop animation.
    return picker
