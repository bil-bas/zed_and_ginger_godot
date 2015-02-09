extends MeshInstance


class Animation:
    var frame_indices = []
    var frame_durations = []

    var type setget , get_type
    func get_type():
        return type

    func size():
        return frame_indices.size()

    func init(type, frames):
        self.type = type

        for frame in frames:
            frame_indices.append(frame[0])
            frame_durations.append(frame[1])

    func frame_index(index):
        return frame_indices[index]

    func frame_duration(index):
        return frame_durations[index]


var index
var direction


var meshes = [] setget set_meshes
func set_meshes(value):
    meshes = value
    self.frame = 0


var animation = [] setget set_animation, get_animation
func get_animation():
    return animation

func set_animation(value):
    if value == animation:
        return
    animation = value
    if animation != null:
        if animation.type == "bounce":
            animate_bounce()
        elif animation.type == "loop":
            animate_loop()
        elif animation.type == "static":
            self.frame = animation.frame_index(0)


var animations = {} setget set_animations
func set_animations(value):
    animations = value


var frame = -1 setget set_frame, get_frame
func get_frame():
    return frame

func set_frame(value):
    frame = value
    set_mesh(meshes[frame])


func _ready():
    frame = -1


func animate_loop():
    index = 0

    while true:
        self.frame = animation.frame_index(index)
        yield()# WaitForSeconds(animation.frame_duration(index))
        index = (index + 1) % animation.size()


func animate_bounce():
    index = 0
    direction = 1

    while true:
        self.frame = animation.frame_index(index)
        yield()# WaitForSeconds(animation.frame_duration(index))

        index += direction
        if index == animation.size():
            direction = -1
            index -= 2
        elif index == -1:
            direction = 1
            index = 1
