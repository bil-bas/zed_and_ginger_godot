extends Node

var _settings
var _audio_server

func _ready():
    _settings = get_node(@"/root/settings")

    get_node(@"Panel/Tabs/Video/Fullscreen").set_pressed(_settings.get_video_fullscreen())

    get_node(@"Panel/Tabs/Audio/MasterVolume").set_value(_settings.get_audio_master_volume())
    get_node(@"Panel/Tabs/Audio/EffectsVolume").set_value(_settings.get_audio_effects_volume())
    get_node(@"Panel/Tabs/Audio/MusicVolume").set_value(_settings.get_audio_music_volume())

func setup():
    yield()

func _on_MasterVolume_value_changed(value):
    _settings.set_audio_master_volume(value)
    update_volumes()

func _on_EffectsVolume_value_changed(value):
    _settings.set_audio_effects_volume(value)
    update_volumes()

func _on_MusicVolume_value_changed(value):
    _settings.set_audio_music_volume(value)
    update_volumes()

func update_volumes():
    var master = _settings.get_audio_master_volume() / 50.0

    var effects = _settings.get_audio_effects_volume() / 100.0
    AudioServer.set_fx_global_volume_scale(effects * master)

    var music = _settings.get_audio_music_volume() / 100.0
    AudioServer.set_stream_global_volume_scale(music * master)

func _on_Fullscreen_toggled(value):
    _settings.set_video_fullscreen(value)

func _on_BackButton_pressed():
    get_node(@'/root/Root/SceneManager').goto("res://main_menu/main_menu.xscn")
