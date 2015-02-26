extends "pick_level.gd"

var edit

func _ready():
    edit = get_node("Edit/Edit")

func _on_SaveButton_pressed():
    var name = edit.get_text()
    if name == "":
        return # TODO: deal with empty name.

    var drive
    if OS.is_debug_build():
        drive = "res"
    else:
        drive = "user"
        
    var filename = "%s://levels/%s.json" % [drive, edit.get_text()]
    if File.new().file_exists(filename):
        pass # TODO: warn about same file.

    callback.call_func(filename, null)
    scene_manager.close_dialog()
