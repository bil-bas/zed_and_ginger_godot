# Handle button clicks on the main menu
# Resize the active area of the game to fill the window.

extends Node2D

const LEVEL_OFFSET = Vector2(40, 0)
const NUM_LEVELS = 2
const CAMERA_IN_OFFSET = Vector2(-210, 130)

var scene_manager
var logger
var camera
var menu_buttons
var level_buttons
var current_level = 1
var camera_animator

func _ready():
    scene_manager = get_node(@'/root/Root/SceneManager')
    logger = get_node(@'/root/logger')
    camera = get_node(@"Viewport/Camera")
    menu_buttons = get_node(@"GUI/MenuButtons")
    camera_animator = get_node(@"Viewport/Camera/CameraAnimator")
    level_buttons = get_node(@"GUI/LevelButtons")

    get_node(@"Viewport/Ship/ShipAnimator").play("move")
    level_buttons.hide()

func setup():
    yield()

func _on_Play_pressed():
    menu_buttons.hide()

    var offset = CAMERA_IN_OFFSET + (current_level - 1) * LEVEL_OFFSET
    var zoom_in = camera_animator.get_animation("zoom_in")
    zoom_in.track_set_key_value(1, 1, offset)
    camera_animator.play("zoom_in")

func _on_Back_pressed():
    level_buttons.hide()

    var zoom_out = camera_animator.get_animation("zoom_out")
    zoom_out.track_set_key_value(1, 0, camera.get_offset())
    camera_animator.play("zoom_out")

func _on_CameraAnimator_finished():
    if camera_animator.get_current_animation() == "zoom_in":
        level_buttons.show()
        update_level_buttons()
    else:
        menu_buttons.show()
    
func _on_Editor_pressed():
    scene_manager.show_dialog("res://pick_level/pick_level_to_edit.xscn", funcref(self, "_on_edit_level_selected"))

func _on_edit_level_selected(filename, level_data):
    Globals.set("level_filename", filename)
    Globals.set("level_data", level_data)
    scene_manager.goto("res://game/editor.xscn")

func _on_Settings_pressed():
    scene_manager.show_dialog("res://settings/settings.xscn")

func _on_Quit_pressed():
    OS.get_main_loop().quit()

func _on_Last_pressed():
    camera.set_offset(camera.get_offset() - LEVEL_OFFSET)
    current_level -= 1
    update_level_buttons()

func _on_Next_pressed():
    camera.set_offset(camera.get_offset() + LEVEL_OFFSET)
    current_level += 1
    update_level_buttons()

func _on_Start_pressed():
    scene_manager.goto("res://game/play.xscn")

func update_level_buttons():
    var last = get_node(@"GUI/LevelButtons/Last")
    last.set_disabled(current_level == 1)
    var next = get_node(@"GUI/LevelButtons/Next")
    next.set_disabled(current_level == NUM_LEVELS)

    var filename = "res://levels/%d.json" % current_level
    Globals.set("level_filename", filename)
    var level_data = get_node(@"/root/utilities").load_json(filename)
    Globals.set("level_data", level_data)

    var level_label = get_node(@"GUI/LevelButtons/Center/Box/Panel/LevelLabel")
    level_label.set_text("%d: %s" % [current_level, level_data["name"]])

