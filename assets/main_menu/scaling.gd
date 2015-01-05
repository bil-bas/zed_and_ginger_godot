
# Resize the active area of the game to fill the window.

extends Node2D

const BASE_SIZE = Vector2(800, 600) # Size the game is developed for.

func _ready():
	print("Operating system: ", OS.get_name())
	
	var size = OS.get_video_mode_size()
	var scale = size.y / BASE_SIZE.y
	
	set_scale(Vector2(scale, scale))
	
	set_pos(Vector2((size.width - BASE_SIZE.x * scale) / 2, 0))
	print("Setting pos as: ", get_pos())

