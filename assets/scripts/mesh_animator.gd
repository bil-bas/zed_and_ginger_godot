extends MeshInstance


class Animation:
    var frame_indices = []
    var frame_durations = []

    var name setget , get_name
    func get_name():
        return name

    func size():
        return frame_indices.size()

    func _init(name, frames):
        self.name = name
        for frame in frames:
            frame_indices.append(int(frame["tile"]))
            frame_durations.append(frame["duration"])

    func frame_index(index):
        return frame_indices[index]

    func frame_duration(index):
        return frame_durations[index]


var index
var anim_index


var meshes = [] setget set_meshes
func set_meshes(value):
    meshes = value
    self.frame = 0


var animation setget set_animation, get_animation
func get_animation():
    return animation.name
func set_animation(value):
    if typeof(animation) == typeof(""):
        animation = null

    # Don't do anything if repeating same animation.
    if animation != null and value == animation.name:
        return

    assert(value in animations)
    stop()

    animation = animations[value]
    if animation.size() == 1:
        self.frame = animation.frame_index(0)
    else:
        anim_index = 0
        _on_animate()


var animations = {} setget set_animations
func set_animations(value):
    for name in value:
        animations[name] = Animation.new(name, value[name])


var frame = -1 setget set_frame, get_frame
func get_frame():
    return frame
func set_frame(value):
    frame = value
    set_mesh(meshes[frame])


func stop():
    var timer = get_child("Timer")
    if timer != null:
        timer.stop()


func _on_animate():
    var timer = get_child("Timer")
    if timer == null:
        timer = Timer.new()
        add_child(timer)
        timer.set_one_shot(false)
        timer.connect("timeout", self, "_on_animate")

    self.frame = animation.frame_index(anim_index)

    var timer = get_child("Timer")
    timer.set_wait_time(animation.frame_duration(anim_index))
    timer.start()

    anim_index = (anim_index + 1) % animation.size()

