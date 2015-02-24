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

func _on_EffectsVolume_value_changed(value):
    _settings.set_audio_effects_volume(value)

func _on_MusicVolume_value_changed(value):
    _settings.set_audio_music_volume(value)

func _on_Fullscreen_toggled(value):
    _settings.set_video_fullscreen(value)

func _on_BackButton_pressed():
    get_node(@'/root/Root/SceneManager').goto("res://main_menu/main_menu.xscn")
