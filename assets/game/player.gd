extends Spatial

var player
var right_vel = 1
var up_vel = 0

const RIGHT_ACCEL = 1
const RIGHT_DECEL = -2
const MAX_RIGHT_VEL = 2
const MIN_RIGHT_VEL = 0

const SIDEWAYS_VEL = 2

const JUMP_VEL = 6
const GRAVITY = -9.81

func _ready():
    var mesh_manager = get_node("/root/mesh_manager")
    player = mesh_manager.new_mesh_object("player")
    var translation = player.get_translation()
    translation.z += 2.5
    translation.y += 2
    player.set_translation(translation)
    self.add_child(player)
    set_fixed_process(true)


func _fixed_process(delta):
    var translation = get_translation()

    var accel_right

    if Input.is_action_pressed("ui_right"):
        accel_right = RIGHT_ACCEL
    elif Input.is_action_pressed("ui_left"):
        accel_right = RIGHT_DECEL
    else:
        accel_right = 0

    right_vel = max(min(right_vel + delta * accel_right, MAX_RIGHT_VEL), MIN_RIGHT_VEL)

    translation.x += delta * right_vel

    if Input.is_action_pressed("ui_up"):
        translation.z -= delta * SIDEWAYS_VEL
    elif Input.is_action_pressed("ui_down"):
        translation.z += delta * SIDEWAYS_VEL

    if translation.y == 0:
        if Input.is_action_pressed("ui_accept"):
          up_vel = JUMP_VEL
          translation.y = max(translation.y + delta * up_vel, 0)
    else:
        up_vel += delta * GRAVITY
        translation.y = max(translation.y + delta * up_vel, 0)
    
    set_translation(translation)
