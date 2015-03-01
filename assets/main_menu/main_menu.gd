# Handle button clicks on the main menu
# Resize the active area of the game to fill the window.

extends Node2D

const LEVEL_OFFSET = Vector2(40, 0)
const NUM_LEVELS = 2
const CAMERA_IN_OFFSET = Vector2(-216, 130)

var scene_manager
var logger
var camera
var menu_buttons
var level_buttons
var current_level = 1
var camera_animator
var previous
var next
var start
var level_name_panel

func _ready():
    scene_manager = get_node(@'/root/Root/SceneManager')
    logger = get_node(@'/root/logger')
    camera = get_node(@"Viewport/Camera")
    menu_buttons = get_node(@"GUI/MenuButtons")
    camera_animator = get_node(@"Viewport/Camera/CameraAnimator")
    level_buttons = get_node(@"GUI/LevelButtons")
    previous = level_buttons.get_node(@"Previous")
    next = level_buttons.get_node(@"Next")
    start = level_buttons.get_node(@"CenterStart/Start")
    level_name_panel = level_buttons.get_node(@"CenterLevelName/Panel")

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
    var animation = camera_animator.get_current_animation()
    if animation == "zoom_in":
        level_buttons.show()
        update_level_buttons()
    elif animation == "zoom_out":
        menu_buttons.show()
    elif animation == "move_level":
        level_buttons.show()
        update_level_buttons()
    
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

func _on_Previous_pressed():
    current_level -= 1
    disable_level_buttons()
    move_level(-LEVEL_OFFSET)

func _on_Next_pressed():
    current_level += 1
    disable_level_buttons()
    move_level(LEVEL_OFFSET)

func move_level(offset):
    var move_level = camera_animator.get_animation("move_level")
    move_level.track_set_key_value(0, 0, camera.get_offset())
    move_level.track_set_key_value(0, 1, camera.get_offset() + offset)
    camera_animator.play("move_level")

func _on_Start_pressed():
    scene_manager.goto("res://game/play.xscn")

func disable_level_buttons():
    previous.set_disabled(true)
    next.set_disabled(true)
    start.set_disabled(true)
    level_name_panel.hide()

func update_level_buttons():
    start.set_disabled(false)
    level_name_panel.show()
    previous.set_disabled(current_level == 1)
    next.set_disabled(current_level == NUM_LEVELS)

    var filename = "res://levels/%d.json" % current_level
    Globals.set("level_filename", filename)
    var level_data = get_node(@"/root/utilities").load_json(filename)
    Globals.set("level_data", level_data)

    var level_label = level_name_panel.get_node(@"LevelLabel")
    level_label.set_text("%d: %s" % [current_level, level_data["name"]])
