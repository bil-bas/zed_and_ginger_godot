extends MeshInstance


var meshes = [] setget set_meshes
func set_meshes(value):
    meshes = value
    self.frame = 0


var animation = [] setget set_animation, get_animation
func get_animation():
    return animation

func set_animation(value):
    animation = value


var frame = -1 setget set_frame, get_frame
func get_frame():
    return frame

func set_frame(value):
    frame = value
    set_mesh(meshes[frame])
