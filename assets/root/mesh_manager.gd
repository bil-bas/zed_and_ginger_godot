extends Node


const PIXELS_PER_METER = 8
const PIXEL_SIZE = 1.0 / PIXELS_PER_METER
const FRONT = Vector3(0, 0, 1)
const BACK = Vector3(0, 0, -1)
const LEFT = Vector3(-1, 0, 0)
const RIGHT = Vector3(1, 0, 0)
const TOP = Vector3(0, 1, 0)
const BOTTOM = Vector3(0, -1, 0)

var _meshes = {}
var _materials = {}
var _sprite_sizes = {} # In fractions of sheet.
var _metadata = {}
var _world_offsets = {} # In pixels, without the margin.
var logger
var object_data


func _ready():
    logger = get_node(@'/root/logger') # Won't exist until we are ready.
    object_data = get_node(@'/root/object_data')

func _load_sheet(spritesheet):
    var is_transparent
    var depth
    var is_centered
    var create_sides
    var is_light_source
    var light_color

    if spritesheet == "tile":
        depth = 3
        is_centered = false
        is_light_source = false
        create_sides = true
    elif spritesheet == "player":
        is_transparent = false
        is_centered = true
        depth = 1
        is_centered = true
        is_light_source = false
        create_sides = true
    else:
        var data = object_data.ITEM_TYPES[spritesheet]
        is_transparent = data["is_transparent"]
        is_light_source = data["light_color"].a > 0
        depth = data["depth"]
        create_sides = data["create_sides"]
        is_centered = create_sides

    # Load the sprites themselves and create meshes from them.
    var texture = load("res://atlases/%s.png" % spritesheet)
    logger.debug("Loading texture for spritesheet: %s" % spritesheet)
    assert(texture)

    # Create a material for all meshes created from the spritesheet
    var material = FixedMaterial.new()
    material.set_texture(FixedMaterial.PARAM_DIFFUSE, texture)
    # DEPTH_DRAW_OPAQUE_PRE_PASS_ALPHA, DEPTH_DRAW_OPAQUE_ONLY
    material.set_depth_draw_mode(Material.DEPTH_DRAW_OPAQUE_ONLY)
    if is_transparent:
        material.set_fixed_flag(FixedMaterial.FLAG_USE_ALPHA, true)
        if is_light_source:
            material.set_blend_mode(Material.BLEND_MODE_ADD)
        else:
            pass#material.set_blend_mode(Material.BLEND_MODE_PREMULT_ALPHA)
    if is_light_source:
        material.set_flag(FixedMaterial.FLAG_UNSHADED, true)

    _materials[spritesheet] = material

    var sprites = texture.get_data()
    
    # Read metadata.
    _metadata[spritesheet] = get_node(@'/root/utilities').load_json("res://atlases/%s.json" % spritesheet)
    var width = _metadata[spritesheet]["tile_size"][0]
    var height = _metadata[spritesheet]["tile_size"][1]

    if spritesheet == "tile":
        _world_offsets[spritesheet] = Vector3()
    else:
        _world_offsets[spritesheet] = Vector3(-(width - 2) * PIXEL_SIZE / 2, (height - 2) * PIXEL_SIZE, 0)
    
    _sprite_sizes[spritesheet] = Vector3(texture.get_width() / width, texture.get_height() / height, depth)

    # Create save data.
    var meshes = []
    var dir = "res://voxels/%s/" % spritesheet
    Directory.new().make_dir_recursive(dir)

    for y_offset in range(0, texture.get_height(), height):
        for x_offset in range(0, texture.get_width(), width):
            var index = meshes.size()
            
            if spritesheet == "tile":
                pass# TODO: work out if tile wants sides.

            var margin = 1
                
            var rect = Rect2(x_offset + margin, y_offset + margin, width - margin * 2, height - margin * 2)
            var mesh = create_mesh(sprites, texture, rect, depth, is_centered, create_sides, is_transparent, material)
            if mesh != null:
                pass
                #ResourceSaver.save(dir + str(meshes.size()) + ".xml", mesh)
            meshes.append(mesh)

    _meshes[spritesheet] = meshes

    logger.info("Created spritesheet: %s" % spritesheet)

    return meshes.size()

func get_animations(spritesheet):
    return _metadata[spritesheet]["animations"]

func new_mesh_object(spritesheet, is_editor=false):
    if not spritesheet in _meshes:
       _load_sheet(spritesheet)

    var obj_type
    if spritesheet == "player":
        obj_type = "player"
    elif spritesheet == "tile":
        obj_type = "tile"
    else:
        if object_data.ITEM_TYPES[spritesheet]["is_area"] and not is_editor:
            obj_type = "item_area"
        else:
            obj_type = "item_solid"

    var obj = load("res://prefabs/%s.xscn" % obj_type).instance()
    obj.set_name(spritesheet)
    if obj_type == "item_solid":
        obj.set_mass(object_data.ITEM_TYPES[spritesheet]["mass"])
    
    var mesh = obj.get_node(@'MeshInstance')
    mesh.set_rotation(Vector3(PI, 0, 0))
    mesh.set_translation(_world_offsets[spritesheet])
    mesh.meshes = _meshes[spritesheet]
    mesh.animations = get_animations(spritesheet)

    if obj_type in ["item_area", "item_solid"]:
        var light_color = object_data.ITEM_TYPES[spritesheet]["light_color"]
        if light_color.a > 0:
            var light = OmniLight.new()
            light.set_parameter(OmniLight.PARAM_RADIUS, 2)
            light.set_color(0, light_color)
            light.set_parameter(OmniLight.PARAM_ATTENUATION, 2)
            light.set_translation(Vector3(0, 0.5, 0))
            obj.add_child(light)

    var is_centered = (spritesheet != "tile")

#    box = obj.AddComponent(BoxCollider)
#    size = _sprite_sizes[spritesheet]
#    width, height, depth = size.x, size.y, size.z
#    if is_centered:
#        box.center = Vector3(0, height / 2, 0) * PIXEL_SIZE
#        box.size = Vector3(width, height, depth) * PIXEL_SIZE
#    else:
#        box.center = Vector3(0, height / 2, -depth / 2) * PIXEL_SIZE
#        box.size = Vector3(width, height, depth) * PIXEL_SIZE

#    var collision_object = CollisionObject.new()
#    var shape = BoxShape.new()
#    shape.extents = Vector3(1, 1, 1)
#    collision_object.add_shape(shape)
#    obj.add_child(collision_object)

#    box.material = Resources.Load("PhysicsMaterials/Floor")

    return obj


func create_bottom_quad(x, y, front, back, uv): # acw
    return [
        [Vector3(x, y, back), BOTTOM, uv],
        [Vector3(x + 1, y, front), BOTTOM, uv],
        [Vector3(x + 1, y, back), BOTTOM, uv],

        [Vector3(x + 1, y, front), BOTTOM, uv],
        [Vector3(x, y, back), BOTTOM, uv],
        [Vector3(x, y, front), BOTTOM, uv]
    ]


func create_top_quad(x, y, front, back, uv): # cw.
    return [
        [Vector3(x, y, front), TOP, uv],
        [Vector3(x + 1, y, back), TOP, uv],
        [Vector3(x + 1, y, front), TOP, uv],

        [Vector3(x + 1, y, back), TOP, uv],
        [Vector3(x, y, front), TOP, uv],
        [Vector3(x, y, back), TOP, uv]
    ]


func create_back_quad(x, y, bottom_y, back, uv, bottom_uv):
    return [
        [Vector3(x, bottom_y, back), BACK, bottom_uv],
        [Vector3(x + 1, bottom_y, back), BACK, bottom_uv],
        [Vector3(x, y, back), BACK, uv],
        
        [Vector3(x, y, back), BACK, uv],
        [Vector3(x + 1, bottom_y, back), BACK, bottom_uv],
        [Vector3(x + 1, y, back), BACK, uv]
    ]


func create_front_quad(x, y, bottom_y, front, uv, bottom_uv):
    return [
        [Vector3(x, bottom_y, front), FRONT, bottom_uv],
        [Vector3(x, y, front), FRONT, uv],
        [Vector3(x + 1, bottom_y, front), FRONT, bottom_uv],
        
        [Vector3(x + 1, bottom_y, front), FRONT, bottom_uv],
        [Vector3(x, y, front), FRONT, uv],
        [Vector3(x + 1, y, front), FRONT, uv]
    ]


func create_left_quad(x, y, front, back, uv):
    return [
        [Vector3(x, y, back), LEFT, uv],
        [Vector3(x, y + 1, back), LEFT, uv],
        [Vector3(x, y + 1, front), LEFT, uv],

        [Vector3(x, y + 1, front), LEFT, uv],
        [Vector3(x, y, front), LEFT, uv],
        [Vector3(x, y, back), LEFT, uv]
    ]


func create_right_quad(x, y, front, back, uv):
    return [
        [Vector3(x, y, back), RIGHT, uv],
        [Vector3(x, y + 1, front), RIGHT, uv],
        [Vector3(x, y + 1, back), RIGHT, uv],

        [Vector3(x, y + 1, front), RIGHT, uv],
        [Vector3(x, y, back), RIGHT, uv],
        [Vector3(x, y, front), RIGHT, uv]
    ]


func pos_in_sheet_to_uv(position, sheet_size):
    return Vector2(position.x + 0.5, position.y) / sheet_size


func create_mesh(sprites, texture, rect, depth, is_centered, create_sides, is_transparent, material):
    var bottom_y
    var color
    
    var front
    var back
    if is_centered:
        front = depth * 0.5
        back = -front
    else:
        front = depth
        back = 0
    
    var surface_tool = SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    surface_tool.set_material(material)

    var sprite_sheet_size = Vector2(sprites.get_width(), sprites.get_height())
    var bottom_uv = null

    # Vertical pass.
    for x in range(rect.size.width + 1):
        var is_visible = false
        for y in range(rect.size.height + 1):
            var pos_in_sheet = Vector2(rect.pos.x + x, rect.pos.y + y)
            var uv = pos_in_sheet_to_uv(pos_in_sheet, sprite_sheet_size)
            
            var pixel_opaque = false
            if x != rect.size.width and y != rect.size.height:
                color = sprites.get_pixel(pos_in_sheet.x, pos_in_sheet.y)
                pixel_opaque = (color.a > 0)

            if pixel_opaque:
                if not is_visible:# or not create_sides:
                # Changed from invisible to visible, so draw BOTTOM quad.
                    bottom_y = y
                    bottom_uv = uv
                    if create_sides:
                        add_quad(surface_tool, create_bottom_quad(x, y, front, back, uv))

                    is_visible = true
            else:
                if is_visible: 
                    # Use the points from the bottom and, now, top, to create long strip.
                    add_quad(surface_tool, create_back_quad(x, y, bottom_y, back, uv, bottom_uv))
                    
                    if create_sides:
                        add_quad(surface_tool, create_front_quad(x, y, bottom_y, front, uv, bottom_uv))
                        add_quad(surface_tool, create_top_quad(x, y, front, back, uv))
                           
                    is_visible = false

    # Horizontal pass.
    if create_sides:
        for y in range(rect.size.height + 1):
            var is_visible = false           
            for x in range(rect.size.width + 1):
                var pos_in_sheet = Vector2(rect.pos.x + x, rect.pos.y + y)
                var uv = pos_in_sheet_to_uv(pos_in_sheet, sprite_sheet_size)
                var pixel_opaque = false
                
                if x != rect.size.width and y != rect.size.height:
                    color = sprites.get_pixel(pos_in_sheet.x, pos_in_sheet.y)
                    pixel_opaque = (color.a > 0)

                if pixel_opaque:
                    if not is_visible:
                        # Changed from invisible to visible, so draw LEFT quad.
                        add_quad(surface_tool, create_left_quad(x, y, front, back, uv))
                        is_visible = true
                else:
                    if is_visible:
                        # Changed from visible to invisible, so draw RIGHT quad.
                        add_quad(surface_tool, create_right_quad(x, y, front, back, uv))
                        is_visible = false


    surface_tool.index() # Convert vertexes into unique vertices + indexes.
    var mesh = surface_tool.commit()
    if mesh.get_surface_count() == 1:
        assert mesh.surface_get_array_len(0) > 0
        assert mesh.surface_get_array_index_len(0) >= mesh.surface_get_array_len(0)

        #logger.debug("num vertexes: %s" % mesh.surface_get_array_len(0))
        #logger.debug("num indexes: %s" % mesh.surface_get_array_index_len(0))
        return mesh
    else:
        return null
    
    
func add_quad(surface_tool, vertices):
    for vertex in vertices:
        surface_tool.add_normal(vertex[1])
        surface_tool.add_uv(vertex[2])
        surface_tool.add_vertex(vertex[0] * PIXEL_SIZE)