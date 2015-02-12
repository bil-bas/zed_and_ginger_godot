extends RigidBody


const MOVE_VEL = 2
const JUMP_VEL = 6

var logger
var mesh
var shape
var on_floor = true
var velocity_y = 0


func _ready():
    logger = get_node("/root/logger")
    mesh = get_node("MeshInstance")
    shape = get_node("CapsuleShape")

    set_fixed_process(true)

    mesh.animation = "walking"

    logger.info("Created player")


func move_direction():
    var dir = Vector3()

    if (Input.is_action_pressed("move_forward")):
        dir += Vector3(0, 0, 1)
    elif (Input.is_action_pressed("move_backwards")):
        dir += Vector3(0, 0, -1)

    if (Input.is_action_pressed("move_left")):
        dir += Vector3(-1, 0, 0)
    elif (Input.is_action_pressed("move_right")):
        dir += Vector3(1, 0, 0)

    return dir.normalized()

func update_animation(velocity):
    var animation

    if on_floor:
        if velocity.x > 0:
            animation = "walking"
        else:
            animation = "sitting"
    else:
        if velocity.y > 0.7:
            animation = "jumping_up"
        elif velocity.y < -0.7:
            animation = "jumping_down"
        else:
            animation = "jumping_across"

    if animation != mesh.animation:
        mesh.animation = animation


func _fixed_process(delta):
    return
    logger.debug(get_linear_velocity())

    #if state.get_contact_count() == 0:
    #    on_floor = false
    #else:
    #    on_floor = true
                
    #if not on_floor and is_colliding():
    #    on_floor = true

    if shape.is_colliding():
        on_floor = true

    var velocity = get_linear_velocity()
    update_animation(velocity)

    var jump_pressed = Input.is_action_pressed("jump")

    if on_floor:
        if jump_pressed:
            apply_impulse(get_translation() + Vector3(0, -1, 0), Vector3(0, JUMP_VEL * 100, 0))

            on_floor = false
            #get_node("sfx").play("jump")

    velocity = move_direction() * MOVE_VEL * delta
    
    apply_impulse(get_translation() - velocity.normalized(), velocity * 100)
