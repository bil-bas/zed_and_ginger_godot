extends Spatial

const MIN_EMIT_DISTANCE = 0.1

var previous_pos
var surface_tool
var quads = []
var base_material
var previous_color
var elapsed_time = 0

var height = 0.4 setget set_height
func set_height(value):
	height = value

var is_emitting = true setget set_is_emitting
func set_is_emitting(value):
    is_emitting = value

func _ready():
    set_process(true)
    previous_pos = get_parent().get_translation()

    surface_tool = SurfaceTool.new()

    base_material = FixedMaterial.new()
    base_material.set_fixed_flag(FixedMaterial.FLAG_USE_COLOR_ARRAY, true)
    base_material.set_fixed_flag(FixedMaterial.FLAG_USE_ALPHA, true)
    base_material.set_flag(Material.FLAG_UNSHADED, true)
    base_material.set_blend_mode(Material.BLEND_MODE_ADD)
    
    previous_color = Color(0, 0, 0, 0)

func emit(pos):
    var r = (sin((elapsed_time + 10) * 4.05) + 1) * 0.5
    var g = (sin((elapsed_time + 4) * 2.21) + 1) * 0.5
    var b = (sin((elapsed_time + 3) * 9.43) + 1) * 0.5
    var color = Color(r, g, b, 0.5)

    surface_tool.clear()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
    var material = base_material.duplicate()
    surface_tool.set_material(material)

    surface_tool.add_color(previous_color)
    surface_tool.add_vertex(previous_pos)

    surface_tool.add_color(previous_color)
    surface_tool.add_vertex(previous_pos + Vector3(0, height, 0))

    surface_tool.add_color(color)
    surface_tool.add_vertex(pos)

    surface_tool.add_color(color)
    surface_tool.add_vertex(pos + Vector3(0, height, 0))

    var mesh = MeshInstance.new()
    mesh.set_mesh(surface_tool.commit())
    get_node("../..").add_child(mesh)

    quads.append([mesh, material])

    previous_pos = pos
    previous_color = color

func _process(delta):
    elapsed_time += delta

    if is_emitting:
        var pos = get_parent().get_translation()
        if pos.distance_to(previous_pos) >= MIN_EMIT_DISTANCE:
            emit(pos)
        
    if not is_emitting:
        if quads.size() > 0:
            quads[0][0].queue_free()
            quads.remove(0)
        else:
            queue_free()
            is_emitting = false

    for i in range(quads.size() - 1, -1, -1):
        var quad = quads[i]
        var color = quad[1].get_parameter(FixedMaterial.PARAM_DIFFUSE)
        color.a -= 0.02
        if color.a <= 0:
            quads[i][0].queue_free()
            quads.remove(i)
        quad[1].set_parameter(FixedMaterial.PARAM_DIFFUSE, color)

