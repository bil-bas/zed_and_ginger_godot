
# Handle button clicks on the main menu

extends GridContainer

func _ready():
	pass

func _on_Play_pressed():
	print("play")
	
func _on_Editor_pressed():
	print("editor")
	
func _on_Quit_pressed():
	OS.get_main_loop().quit()
