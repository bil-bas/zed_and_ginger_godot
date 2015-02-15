extends RigidBody


const WALK_SPEED = 4
const JUMP_SPEED = 6
const UP = Vector3(0, 1, 0)

var logger
var mesh
var shape
var audio
var on_floor = false
var velocity_y = 0


func _ready():
    logger = get_node("/root/logger")
    mesh = get_node("MeshInstance")
    shape = get_node("CapsuleShape")
    audio = get_node("SpatialSamplePlayer")

    mesh.animation = "walking"

    logger.info("Created player")


func move_direction():
    var dir = Vector3()

    if Input.is_action_pressed("move_up"):
        dir += Vector3(0, 0, -1)
    if Input.is_action_pressed("move_down"):
        dir += Vector3(0, 0, 1)

    if Input.is_action_pressed("move_left"):
        dir += Vector3(-1, 0, 0)
    if Input.is_action_pressed("move_right"):
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


func _integrate_forces(state):
    var velocity = state.get_linear_velocity()
    var delta = state.get_step()
    var gravity = state.get_total_gravity()

    # Check if on a horizontalish surface.
    on_floor = false
    for i in range(state.get_contact_count()):
        logger.debug(state.get_contact_local_normal(i))
        logger.debug(state.get_contact_local_normal(i).dot(UP))
        if state.get_contact_local_normal(i).dot(UP) > 0.7:
            on_floor = true
            break

    # Jump up from the floor.
    if on_floor:
        var jump_pressed = Input.is_action_pressed("jump")

        if jump_pressed:
            velocity.y = JUMP_SPEED

    # Move by walking/swimming in the air :D
    var direction = move_direction()
    velocity.x = direction.x * WALK_SPEED
    velocity.z = direction.z * WALK_SPEED

    # Apply gravity
    velocity += gravity * delta

    # Update new state.
    state.set_linear_velocity(velocity)
    update_animation(velocity)
