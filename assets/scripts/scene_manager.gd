extends Node

const INITIAL_SCENE = "res://main_menu/main_menu.xscn"

var current_scene = null
var loader
var wait_frames
var progress_bar
var logger
var time_max = 100

func _ready():
    logger = get_node("/root/logger")
    logger.level = logger.Level.DEBUG
    logger.truncate_log_file = true
    logger.filename = "user://log.txt"

    progress_bar = get_node("LoadingProgress")

    goto(INITIAL_SCENE) # Load first scene.

func _process(delta):
    if loader == null:
        # no need to process anymore
        set_process(false)
        return

    if wait_frames > 0: # wait for frames to let the "loading" animation to show up
        wait_frames -= 1
        return

    # Load stuff until we are done.
    var load_until = OS.get_ticks_msec() + time_max
    while OS.get_ticks_msec() < load_until:
        # poll your loader
        var err = loader.poll()

        if err == ERR_FILE_EOF: # load finished
            var resource = loader.get_resource()
            loader = null
            set_new_scene(resource)
            break
        elif err == OK:
            update_loading_progress()
        else: # error during loading
            show_error()
            loader = null
            break

func update_loading_progress():
    var progress = loader.get_stage() * 100.0 / loader.get_stage_count()
    logger.debug("Loading progress: %d%%" % progress)
    progress_bar.set_value(progress)

func set_new_scene(scene_resource):
    logger.info("Loaded scene")
    current_scene = scene_resource.instance()
    add_child(current_scene)
    progress_bar.hide()

    current_scene.setup()

func goto(scene_file):
    logger.info("Loading scene: %s" % scene_file)

    loader = ResourceLoader.load_interactive(scene_file)
    assert(loader != null)

    if current_scene != null:
    	current_scene.queue_free()

    set_process(true)
    wait_frames = 1
    progress_bar.show()
