extends Label

func _ready():
    if not OS.is_debug_build():
        queue_free()
        
func _on_Timer_2_timeout():
    set_text("FPS: %d" %OS.get_frames_per_second())