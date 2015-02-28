extends Node

var _settings
var _audio_server

func _ready():
    _settings = get_node(@"/root/settings")

    get_node(@"Tabs/Video/Fullscreen").set_pressed(_settings.get_video_fullscreen())
    get_node(@"Tabs/Video/ShowFPS").set_pressed(_settings.get_video_show_fps())
    get_node(@"Tabs/Video/VSync").set_pressed(_settings.get_video_vsync())

    get_node(@"Tabs/Audio/MasterVolume").set_value(_settings.get_audio_master_volume())
    get_node(@"Tabs/Audio/EffectsVolume").set_value(_settings.get_audio_effects_volume())
    get_node(@"Tabs/Audio/MusicVolume").set_value(_settings.get_audio_music_volume())

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

func _on_ShowFPS_toggled(value):
    _settings.set_video_show_fps(value)

func _on_VSync_toggled(value):
    _settings.set_video_vsync(value)

func _on_BackButton_pressed():
    get_node(@'/root/Root/SceneManager').close_dialog()
