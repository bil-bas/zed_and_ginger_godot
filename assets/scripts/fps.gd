extends Label

func _ready():
    update_text()

func _on_Timer_2_timeout():
    update_text()

func update_text():
    set_text("FPS: %d" %OS.get_frames_per_second())