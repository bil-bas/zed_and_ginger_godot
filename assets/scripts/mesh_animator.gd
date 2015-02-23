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


var anim_index
var timer

var meshes = [] setget set_meshes
func set_meshes(value):
    meshes = value
    self.frame = 0

var animation_name
var animation_obj
var animation setget set_animation, get_animation
func get_animation():
    return animation_name
func set_animation(value):
    # Don't do anything if repeating same animation.
    if value == animation_name:
        return

    assert(value in animations)
    animation_name = value
    animation_obj = animations[value]
    stop()

    if animation_obj.size() == 1:
        self.frame = animation_obj.frame_index(0)
    else:
        anim_index = 0
        timer = Timer.new()
        add_child(timer)
        timer.set_one_shot(false)
        timer.connect("timeout", self, "_on_animate")
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
    if timer != null:
        timer.stop()
        timer = null

var stop_on_completion = false setget set_stop_on_completion
func set_stop_on_completion(value):
    stop_on_completion = value

func _on_animate():
    self.frame = animation_obj.frame_index(anim_index)
    var wait_time = animation_obj.frame_duration(anim_index)

    anim_index += 1
    if anim_index == animation_obj.size():
        if stop_on_completion:
            anim_index = animation_obj.size() - 1
            return
        else:
            anim_index = 0

    timer.set_wait_time(wait_time)
    timer.start()
