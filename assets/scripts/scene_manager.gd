extends Node

const INITIAL_SCENE = "res://main_menu/main_menu.xscn"

var current_scene = null
var loader
var wait_frames
var root_node
var progress_bar
var loading_label
var logger
var time_max = 1
var setup_routine
var setup_progress

func _ready():
    logger = get_node("/root/logger")
    logger.level = logger.Level.DEBUG
    logger.truncate_log_file = true
    logger.filename = "user://log.txt"

    loading_label = get_node("LoadingLabel")
    progress_bar = get_node("LoadingProgress")
    root_node = get_node("..")

    goto(INITIAL_SCENE) # Load first scene.

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
        root_node.get_node("Background").set_layer(-1)

func update_loading_progress():
    var progress = loader.get_stage() * 100.0 / loader.get_stage_count()
    progress_bar.set_value(progress)

func set_new_scene(scene_resource):
    logger.info("Loaded scene")
    current_scene = scene_resource.instance()
    root_node.add_child(current_scene)

    # Hide everything behind the background
    root_node.get_node("Background").set_layer(127)
    
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

    set_process(true)
    wait_frames = 1
    progress_bar.show()
    loading_label.show()
    loading_label.set_text("LOADING_SCENE")
