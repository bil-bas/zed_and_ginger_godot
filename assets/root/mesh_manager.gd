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


func _ready():
    logger = get_node("/root/logger") # Won't exist until we are ready.


func _load_sheet(spritesheet):
    var uses_transparency
    var depth
    var is_centered
    
    if spritesheet == "tile":
        uses_transparency = true
        depth = 3#TileData.DEPTH
        is_centered = false
    else:
        uses_transparency = false
        depth = 1
        is_centered = true

    # Load the sprites themselves and create meshes from them.
    var texture = load("res://atlases/%s.png" % spritesheet)

    # Create a material for all meshes created from the spritesheet
    var material = FixedMaterial.new()
    material.set_texture(FixedMaterial.PARAM_DIFFUSE, texture)
    _materials[spritesheet] = material

    var sprites = texture.get_data()
    
    # Read metadata.
    _metadata[spritesheet] = get_node("/root/utilities").load_json("res://atlases/%s.json" % spritesheet)
    var width = _metadata[spritesheet]["tile_size"][0]
    var height = _metadata[spritesheet]["tile_size"][1]

    if spritesheet == "tile":
        _world_offsets[spritesheet] = Vector3()
    else:
        _world_offsets[spritesheet] = Vector3(-(width - 2) * PIXEL_SIZE / 2, (height - 2) * PIXEL_SIZE, 0)
    
    _sprite_sizes[spritesheet] = Vector3(texture.get_width() / width, texture.get_height() / height, depth)
    var tile_data = get_node("/root/tile_data")

    # Create save data.
    var meshes = []
    var dir = "res://voxels/%s/" % spritesheet
    Directory.new().make_dir_recursive(dir)

    for y_offset in range(0, texture.get_height(), height):
        for x_offset in range(0, texture.get_width(), width):
            var create_sides = false
            var index = meshes.size()
            
            if spritesheet == "tile":
                create_sides = tile_data.get_config_from_index(index, "create_sides")
            else:
                create_sides = true

            var margin = 1
                
            var rect = Rect2(x_offset + margin, y_offset + margin, width - margin * 2, height - margin * 2)
            var mesh = create_mesh(sprites, texture, rect, depth, is_centered, create_sides, uses_transparency, material)
            if mesh == null:
                logger.info("Skipping spritesheet frame: %s" % index)
            else:
                logger.info("Created spritesheet frame: %s" % index)
                #ResourceSaver.save(dir + str(meshes.size()) + ".xml", mesh)
            meshes.append(mesh)

    _meshes[spritesheet] = meshes

    logger.info("Created spritesheet: %" % spritesheet)
    
    #load_animation(spritesheet)
    
    return meshes.size()


#    func default_material(spritesheet as string) as Material:
#        load_sheet(spritesheet)
#
#        return _materials[spritesheet]["diffuse"]

#    func transparency_material(spritesheet as string) as Material:
#        _load_sheet(spritesheet)
#
#        return _materials[spritesheet]["transparency"]

#    func load_animation(spritesheet):
#        start = Time.realtimeSinceStartup
#        n_anims = 0
#
#        data = JSON.load_resource("Config/Animations/$spritesheet")
#        item_anims = Dictionary[of string, VoxelAnimator.Animation]()
#        _animations[spritesheet] = item_anims
#
#        for anim as KeyValuePair[of string, duck] in data:
#            anim_data = anim.Value as Dictionary[of string, duck]
#            item_anims[anim.Key] = VoxelAnimator.Animation(anim_data["type"], anim_data["frames"])
#            n_anims += 1
#
#        Debug.Log("Loaded $n_anims animations for spritesheet '$spritesheet' in $(Time.realtimeSinceStartup - start)s")

func new_mesh_object(spritesheet, index=0):
    if not spritesheet in _meshes:
       _load_sheet(spritesheet)

    var obj_type
    if spritesheet == "player":
        obj_type = "player"
    elif spritesheet == "tile":
        obj_type = "tile"
    else:
        obj_type = "object"

    var obj = load("res://prefabs/%s.xscn" % obj_type).instance()
    
    obj.set_name(spritesheet)
    
    var mesh_instance = obj.get_node("MeshInstance")
    mesh_instance.set_rotation(Vector3(PI, 0, 0))
    mesh_instance.set_translation(_world_offsets[spritesheet])
    mesh_instance.meshes = _meshes[spritesheet]
    mesh_instance.frame = index
    mesh_instance.animations = _metadata[spritesheet]["animations"]

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


func create_mesh(sprites, texture, rect, depth, is_centered, create_sides, uses_transparency, material):
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

        logger.debug("num vertexes: %s" % mesh.surface_get_array_len(0))
        logger.debug("num indexes: %s" % mesh.surface_get_array_index_len(0))
        return mesh
    else:
        return null
    
    
func add_quad(surface_tool, vertices):
    for vertex in vertices:
        surface_tool.add_normal(vertex[1])
        surface_tool.add_uv(vertex[2])
        surface_tool.add_vertex(vertex[0] * PIXEL_SIZE)