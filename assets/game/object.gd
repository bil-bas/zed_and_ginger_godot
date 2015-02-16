extends RigidBody

var kills_player = true setget set_kills_player, get_kills_player
func get_kills_player():
	return kills_player
func set_kills_player(value):
	assert(value in [true, false])
	kills_player = value