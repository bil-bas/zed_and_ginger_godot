extends PhysicsBody

var player_kill_type = 0 setget set_player_kill_type, get_player_kill_type
func get_player_kill_type():
    return player_kill_type
func set_player_kill_type(value):
    player_kill_type = value
