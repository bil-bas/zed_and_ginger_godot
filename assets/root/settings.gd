extends Node

const CONFIG_FILE = "user://settings.ini"

const VIDEO_SECTION = "video"
const FULLSCREEN = "fullscreen"

const AUDIO_SECTION = "audio"
const MASTER_VOLUME = "master_volume"
const EFFECTS_VOLUME = "effects_volume"
const MUSIC_VOLUME = "music_volume"

var _config

func _ready():
    _config = ConfigFile.new()

    if File.new().file_exists(CONFIG_FILE):
        _config.load(CONFIG_FILE)

    default_video_settings()
    default_audio_settings()

    save()

    update_volumes()
    update_screen_size()

func save():
    _config.save(CONFIG_FILE)

# Set defaults

func default_video_settings():
    var keys = _config.get_section_keys(VIDEO_SECTION)
    if not FULLSCREEN in keys:
        _config.set_value(VIDEO_SECTION, FULLSCREEN, false)

func default_audio_settings():
    var keys = _config.get_section_keys(AUDIO_SECTION);
    if not MASTER_VOLUME in keys:
        _config.set_value(AUDIO_SECTION, MASTER_VOLUME, 50)

    if not EFFECTS_VOLUME in keys:
        _config.set_value(AUDIO_SECTION, EFFECTS_VOLUME, 100)

    if not MUSIC_VOLUME in keys:
        _config.set_value(AUDIO_SECTION, MUSIC_VOLUME, 100)

# Update engine values

func update_screen_size():
    # TODO: This doesn't actually do ANYTHING!
    if get_video_fullscreen():
        OS.set_video_mode(Vector2(1680, 1050), true, false)
    else:
        OS.set_video_mode(Vector2(800, 600), false, false)

func update_volumes():
    var master = get_audio_master_volume() / 50.0

    var effects = get_audio_effects_volume() / 100.0
    AudioServer.set_fx_global_volume_scale(effects * master * 0.25)

    var music = get_audio_music_volume() / 100.0
    AudioServer.set_stream_global_volume_scale(music * master)

# Video settings.

func get_video_fullscreen():
    return _config.get_value(VIDEO_SECTION, FULLSCREEN)

func set_video_fullscreen(value):
    _config.set_value(VIDEO_SECTION, FULLSCREEN, value)
    update_screen_size()
    save()

# Audio settings.

func get_audio_master_volume():
    return _config.get_value(AUDIO_SECTION, MASTER_VOLUME)

func set_audio_master_volume(value):
    _config.set_value(AUDIO_SECTION, MASTER_VOLUME, value)
    update_volumes()
    save()

func get_audio_effects_volume():
    return _config.get_value(AUDIO_SECTION, EFFECTS_VOLUME)

func set_audio_effects_volume(value):
    _config.set_value(AUDIO_SECTION, EFFECTS_VOLUME, value)
    update_volumes()
    save()

func get_audio_music_volume():
    return _config.get_value(AUDIO_SECTION, MUSIC_VOLUME)

func set_audio_music_volume(value):
    _config.set_value(AUDIO_SECTION, MUSIC_VOLUME, value)
    update_volumes()
    save()
