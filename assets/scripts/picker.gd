extends Control

const LMB = 1
const SELECTED_COLOR = Color(1, 0, 0)

var name setget set_name, get_name
func get_name():
    return name
func set_name(value):
    name = value

var is_selected = false setget set_is_selected
func set_is_selected(value):
    is_selected = value
    update() # Force redraw.

func _draw():
    if is_selected:
        var rect = Rect2(0, 0, get_size().x, get_size().y)
        draw_rect(rect, SELECTED_COLOR)

var callback setget set_callback
func set_callback(value):
    callback = value

func _input_event(event):
    if event.type == InputEvent.MOUSE_BUTTON and event.is_pressed() and event.button_index == LMB:
        is_selected = true
        callback.call_func(self)
