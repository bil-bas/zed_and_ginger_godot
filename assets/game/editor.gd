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

    logger.debug("Created 3d viewport")

func setup():
    var level_setup = level.setup()
    while level_setup.is_valid():
        level_setup.resume()
        yield()

    fill_item_picker()
    #yield()
    fill_tile_picker()
    #yield()
    update_history_buttons()

    set_process(true)

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
    get_node("/root/Root/SceneManager").goto("res://main_menu/main_menu.xscn")

func update_history_buttons():
    undo_button.set_disabled(not history.get_can_undo())
    redo_button.set_disabled(not history.get_can_redo())
    
func _on_TilePicker_pressed(control):
    logger.info("Picked tile: %s" % control.name)
    current_tile_type = control.name

func _on_ItemPicker_pressed(control):
    logger.info("Picked item: %s" % control.name)
    return

func fill_item_picker():
    var pickers = get_node("Tabs/Items/ScrollArea/Pickers")
    pickers.add_child(create_item_picker("flytrap"))
    pickers.add_child(create_item_picker("flytrap"))

func create_item_picker(name):
    var mesh_manager = get_node("/root/mesh_manager")
    var item = mesh_manager.new_mesh_object(name)

    var picker = load("res://prefabs/item_picker.xscn").instance()
    picker.get_node("Viewport").add_child(item)
    item.get_node("MeshInstance").frame = 1
    item.get_node("MeshInstance").stop() # Stop animation.
    picker.name = name
    picker.callback =funcref(self, "_on_ItemPicker_pressed")
    return picker

func fill_tile_picker():
    var pickers = get_node("Tabs/Tiles/ScrollArea/Pickers")
    var mesh_manager = get_node("/root/mesh_manager")
    var animations = mesh_manager.get_animations("tile")
    var utilities = get_node("/root/utilities")
    var tiles = utilities.load_json("res://config/tile_order_editor.json")["tiles"]

    for tile in tiles:
        var frame = animations[tile][0]["tile"]
        pickers.add_child(create_tile_picker(frame, tile))

func create_tile_picker(frame, tile):
    var prefab = load("res://prefabs/tile_picker.xscn")
    var picker = prefab.instance()
    picker.get_node("Sprite").set_frame(frame)
    picker.name = tile
    picker.callback = funcref(self, "_on_TilePicker_pressed")
    return picker
