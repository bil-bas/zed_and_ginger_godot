extends Node

const BACKGROUND_LAYER = -1
const SCENE_LAYER = 0
const GUI_LAYER = 1
const DIALOG_LAYER = 2
const LOADING_LAYER = 3
const FOREGROUND_LAYER = 4

const INITIAL_SCENE = "res://main_menu/main_menu.xscn"
const BASE_SIZE = Vector2(800, 600) # Size the game is developed for.

var current_scene = null
var loader
var wait_frames
var progress_bar
var loading_label
var logger
var time_max = 1
var setup_routine
var setup_progress
var dialog
var dialog_base
var timer
var scene
var background
var dialog_timer

func _ready():
    logger = get_node(@'/root/logger')
    logger.level = logger.Level.DEBUG
    logger.truncate_log_file = true
    logger.filename = "user://log.txt"

    dialog_base = get_node(@'../Dialog/Control')
    dialog = dialog_base.get_node(@'Center/Dialog')
    loading_label = get_node(@'../Loading/Label')
    progress_bar = get_node(@'../Loading/Progress')
    scene = get_node(@'../Scene')
    background = get_node(@'../Background')
    dialog_timer = Timer.new()
    dialog_timer.set_wait_time(0.001)
    dialog_timer.connect("timeout", self, "_pause_tree")

    goto(INITIAL_SCENE) # Load first scene.

    logger.info("Operating system: %s" % OS.get_name())

func _process(delta):
    if wait_frames > 0: # wait for frames to let the "loading" animation to show up
        wait_frames -= 1
        return

    # Load stuff until we are done.
    var load_until = OS.get_ticks_msec() + time_max
    while (loader or setup_routine) and OS.get_ticks_msec() < load_until:
        if loader:
            load_scene()
        else:
            setup_scene()

func load_scene():
    var err = loader.poll() # Load a bit more

    if err == ERR_FILE_EOF: # Load finished
        var resource = loader.get_resource()
        loader = null
        set_new_scene(resource)
    elif err == OK:
        update_loading_progress()
    else: # error during loading
        assert(false)
        loader = null

func setup_scene():
    setup_routine.resume()
    setup_progress += 1
    progress_bar.set_value(setup_progress % int(progress_bar.get_max()))
    
    if not setup_routine.is_valid():
        setup_routine = false
        set_process(false)
        loading_label.hide()
        progress_bar.hide()
        background.set_layer(BACKGROUND_LAYER)

func update_loading_progress():
    var progress = loader.get_stage() * 100.0 / loader.get_stage_count()
    progress_bar.set_value(progress)

func set_new_scene(scene_resource):
    logger.info("Loaded scene")
    current_scene = scene_resource.instance()
    scene.add_child(current_scene)

    # Hide everything behind the background
    background.set_layer(FOREGROUND_LAYER)
    
    logger.info("Setting up scene")
    setup_routine = current_scene.setup()

    # Start a new count
    loading_label.set_text("SETUP_SCENE")
    setup_progress = 0
    progress_bar.set_value(setup_progress)

func goto(scene_file):
    logger.info("Loading scene: %s" % scene_file)

    loader = ResourceLoader.load_interactive(scene_file)
    assert(loader != null)

    if current_scene != null:
        current_scene.queue_free()

    close_dialog()

    set_process(true)
    wait_frames = 1
    progress_bar.show()
    loading_label.show()
    loading_label.set_text("LOADING_SCENE")

func show_dialog(scene_file, callback=null):
    close_dialog()
    var scene = load(scene_file).instance()
    if callback != null:
        scene.set_callback(callback)

    dialog.add_child(scene)
    dialog.show()
    dialog_base.show()
    dialog_timer.start()

func _pause_tree():
    get_tree().set_pause(true)

func close_dialog():
    if dialog.get_child_count() > 0:
        var scene = dialog.get_child(0)
        scene.queue_free()
        dialog_base.hide()
        get_tree().set_pause(false)
