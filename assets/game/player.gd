extends KinematicBody

const WALK_SPEED = 4
const JUMP_SPEED = 6
const UP = Vector3(0, 1, 0)
const GRAVITY = -9.81

class State:
    const ALIVE = 0
    const DEAD = 1
    const ELECTROCUTED = 2
    const FLATTENED = 3
    const BURNT = 4
    const EATEN = 5

var logger
var mesh
var audio
var floor_tile
var floor_ray
var on_floor = false
var velocity = Vector3(0, 0, 0)
var state = State.ALIVE

func object_type():
    return "PLAYER"

func _ready():
    logger = get_node("/root/logger")
    mesh = get_node("MeshInstance")
    audio = get_node("SpatialSamplePlayer")
    floor_ray = get_node("FloorRay")

    mesh.animation = "walking"

    set_fixed_process(true)

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

    if state == State.ALIVE:
        if on_floor:
            if velocity.x != 0 or velocity.z != 0:
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

    elif state == State.DEAD:
        animation = "on_back"
    elif state == State.ELECTROCUTED:
        animation = "electrocuted"
    elif state == State.FLATTENED:
        animation = "flattened"
    elif state == State.BURNT:
        animation = "burnt"
    elif state == State.EATEN:
        animation = "none" # Show nothing.

    if animation != mesh.animation:
        mesh.animation = animation

func _fixed_process(delta):
    velocity.y += GRAVITY * delta

    if state == State.ALIVE:
        if floor_ray.is_colliding():
            var collider = floor_ray.get_collider()
            if collider != null and collider.object_type() == "TILE":
                floor_tile = collider

        var walk_speed = WALK_SPEED

        if on_floor:
            var jump_pressed = Input.is_action_pressed("jump")
            if jump_pressed:
                if floor_tile.is_sticky:
                    pass # TODO: play sound?
                else:
                    velocity.y = JUMP_SPEED
                    on_floor = false

            walk_speed *= floor_tile.speed_multiplier

        var direction = move_direction()
        velocity.x = direction.x * walk_speed
        velocity.z = direction.z * walk_speed

    var motion = velocity * delta
    motion = move(motion)

    if is_colliding():
        var collider = get_collider()
        if collider.player_kill_type != State.ALIVE:
            state = collider.player_kill_type
            velocity = Vector3()

        var normal = get_collision_normal()

        if normal.dot(UP) > 0.7:
            on_floor = true

        motion = normal.slide(motion)
        velocity = normal.slide(velocity)
        move(motion)
    else:
        on_floor = false

    update_animation(velocity)

