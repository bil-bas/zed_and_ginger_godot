
extends MeshInstance

const PIXELS_PER_METER = 10
const PIXEL_SIZE = 1.0 / PIXELS_PER_METER
const FRONT = Vector3(0, 0, 1)
const BACK = Vector3(0, 0, -1)
const LEFT = Vector3(-1, 0, 0)
const RIGHT = Vector3(1, 0, 0)
const TOP = Vector3(0, 1, 0)
const BOTTOM = Vector3(0, -1, 0)

var _meshes = {}
var _materials = {}
var _sprite_sizes = {}
var _animations = {}
var _n = 0.0


func _ready():
    print("loading sheet")
    load_sheet("player")
    print("loaded sheet")
    set_process(true)
    

func _process(delta):
    var r = delta * 1
    set_rotation(Vector3(get_rotation().x + r, get_rotation().y + -r /2, get_rotation().z + r / 3))
    set_mesh(load("voxels/player/%d.xml" % _n))
    _n += 0.01


func load_sheet(spritesheet):
    if spritesheet in _materials:
        return 0 
    
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
    
    # Create a material for all meshes created from the spritesheet
    #diffuse_material = Instantiate(Resources.Load[of Material]("Materials/Diffuse"))
    #diffuse_material.mainTexture = texture
    #var diffuse_material = null
    
    # Create a material for all transparent meshes created from the spritesheet
    #if uses_transparency:
    #    pass
        #transparency_material = Instantiate(Resources.Load[of Material]("materials/TransparentDiffuse"))
        #transparency_material.mainTexture = texture
    #var transparency_material = null
    
    #var materials = { diffuse=diffuse_material, transparency=transparency_material }
    #_materials[spritesheet] = materials
    
    # Load the sprites themselves and create meshes from them.
    var texture = load("res://atlases/" + spritesheet + ".png")
    var sprites = texture.get_data()
    var meshes = []
    var dir = "res://voxels/" + spritesheet + "/"
    Directory.new().make_dir_recursive(dir)

    var width = 18
    var height = 18
    
    _sprite_sizes[spritesheet] = Vector3(texture.get_width() / width, texture.get_height() / height, depth)
    
    for y_offset in range(0, texture.get_height(), height):
        for x_offset in range(0, texture.get_width(), width):
            var create_sides = false
            
            if spritesheet == "tile":
                pass #create_sides = TileData.get_config_from_index(index, "create_sides") cast bool
            else:
                create_sides = true
                
            var rect = Rect2(x_offset, y_offset, width, height)
            var mesh = create_mesh(sprites, texture, rect, depth, is_centered, create_sides, uses_transparency)
            if mesh == null:
                print("Skipping spritesheet frame: ", meshes.size())
            else:
                print("Created spritesheet frame: ", meshes.size())
                ResourceSaver.save(dir + str(meshes.size()) + ".xml", mesh)
            meshes.append(mesh)

    #set_mesh(meshes[0]) # DEBUG
    set_mesh(load(dir + "0.xml"))
    _meshes[spritesheet] = meshes

    print("Created spritesheet: ", spritesheet)
    
    #load_animation(spritesheet)
    
    return meshes.size()


#    func default_material(spritesheet as string) as Material:
#        load_sheet(spritesheet)
#
#        return _materials[spritesheet]["diffuse"]

#    func transparency_material(spritesheet as string) as Material:
#        load_sheet(spritesheet)
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
#
#    func new_mesh_object(spritesheet as string) as GameObject:
#        load_sheet(spritesheet)
#
#        obj = GameObject()
#        obj.name = spritesheet
#
#        rend = obj.AddComponent(MeshRenderer)
#        rend.material = default_material(spritesheet)
#
#        obj.AddComponent(MeshFilter)
#        assert spritesheet in _meshes, spritesheet
#
#        voxel_animator = obj.AddComponent(VoxelAnimator)
#        voxel_animator.meshes = _meshes[spritesheet]
#        voxel_animator.animations = _animations[spritesheet]
#
#        is_centered = (spritesheet != "tile")
#
#        box = obj.AddComponent(BoxCollider)
#        size = _sprite_sizes[spritesheet]
#        width, height, depth = size.x, size.y, size.z
#        if is_centered:
#            box.center = Vector3(0, height / 2, 0) * PIXEL_SIZE
#            box.size = Vector3(width, height, depth) * PIXEL_SIZE
#        else:
#            box.center = Vector3(0, height / 2, -depth / 2) * PIXEL_SIZE
#            box.size = Vector3(width, height, depth) * PIXEL_SIZE
#
#        box.material = Resources.Load("PhysicsMaterials/Floor")
#
#        return obj


func create_bottom_quad(x, y, front, back): # acw
    return [
		[Vector3(x, y, back), BOTTOM],
		[Vector3(x + 1, y, front), BOTTOM],
		[Vector3(x + 1, y, back), BOTTOM],

		[Vector3(x + 1, y, front), BOTTOM],
		[Vector3(x, y, back), BOTTOM],
		[Vector3(x, y, front), BOTTOM]
	]


func create_top_quad(x, y, front, back): # cw.
	return [
		[Vector3(x, y, front), TOP],
		[Vector3(x + 1, y, back), TOP],
		[Vector3(x + 1, y, front), TOP],

		[Vector3(x + 1, y, back), TOP],
		[Vector3(x, y, front), TOP],
		[Vector3(x, y, back), TOP]
	]


func create_back_quad(x, y, bottom_y, back):
	return [
		[Vector3(x, bottom_y, back), BACK],
		[Vector3(x + 1, bottom_y, back), BACK],
		[Vector3(x, y, back), BACK],
        
		[Vector3(x, y, back), BACK],
		[Vector3(x + 1, bottom_y, back), BACK],
		[Vector3(x + 1, y, back), BACK]
	]


func create_front_quad(x, y, bottom_y, front):
	return [
		[Vector3(x, bottom_y, front), FRONT],
		[Vector3(x, y, front), FRONT],
		[Vector3(x + 1, bottom_y, front), FRONT],
        
		[Vector3(x + 1, bottom_y, front), FRONT],
		[Vector3(x, y, front), FRONT],
		[Vector3(x + 1, y, front), FRONT]
	]


func create_left_quad(x, y, front, back):
	return [
		[Vector3(x, y, back), LEFT],
		[Vector3(x, y + 1, back), LEFT],
		[Vector3(x, y + 1, front), LEFT],

		[Vector3(x, y + 1, front), LEFT],
		[Vector3(x, y, front), LEFT],
		[Vector3(x, y, back), LEFT]
	]


func create_right_quad(x, y, front, back):
	return [
		[Vector3(x, y, back), RIGHT],
		[Vector3(x, y + 1, front), RIGHT],
		[Vector3(x, y + 1, back), RIGHT],

		[Vector3(x, y + 1, front), RIGHT],
		[Vector3(x, y, back), RIGHT],
		[Vector3(x, y, front), RIGHT]
	]


func create_mesh(sprites, texture, rect, depth, is_centered, create_sides, uses_transparency):
	var bottom_y
	var color
    
	var front
	var back
	if is_centered:
		front = depth * 0.5
		back = -front
	else:
		front = 0
		back = depth
    
	var material = FixedMaterial.new()
	material.set_texture(FixedMaterial.PARAM_DIFFUSE, texture)
    
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	surface_tool.set_material(material)
	var sprite_sheet_size = Vector2(sprites.get_width(), sprites.get_height())
    
	# Vertical pass.
	for x in range(rect.size.width + 1):
		var is_visible = false
		for y in range(rect.size.height + 1):
			var pos_in_sheet = Vector2(rect.pos.x + x, rect.pos.y + y)
			var uv = Vector2(pos_in_sheet.x + 0.5, pos_in_sheet.y + 0.5) / sprite_sheet_size
			
			var pixel_opaque = false
			if x != rect.size.width and y != rect.size.height:
				color = sprites.get_pixel(pos_in_sheet.x, pos_in_sheet.y)
				pixel_opaque = (color.a > 0)

			if pixel_opaque:
				if not is_visible:# or not create_sides:
				# Changed from invisible to visible, so draw BOTTOM quad.
					bottom_y = y
					if create_sides:
						add_quad(surface_tool, create_bottom_quad(x, y, front, back), uv)

					is_visible = true
			else:
				if is_visible: 
					# Use the points from the bottom and, now, top, to create long strip.
					add_quad(surface_tool, create_back_quad(x, y, bottom_y, back), uv)
					add_quad(surface_tool, create_front_quad(x, y, bottom_y, front), uv)
	                   
					if create_sides:
						add_quad(surface_tool, create_top_quad(x, y, front, back), uv)
	                       
					is_visible = false

    # Horizontal pass.
	if create_sides:
		for y in range(rect.size.height + 1):
			var is_visible = false           
			for x in range(rect.size.width + 1):
				var pos_in_sheet = Vector2(rect.pos.x + x, rect.pos.y + y)
				var uv = Vector2(pos_in_sheet.x + 0.5, pos_in_sheet.y + 0.5) / sprite_sheet_size
				var pixel_opaque = false
                
				if x != rect.size.width and y != rect.size.height:
					color = sprites.get_pixel(pos_in_sheet.x, pos_in_sheet.y)
					pixel_opaque = (color.a > 0)
    
				if pixel_opaque:
					if not is_visible:
						# Changed from invisible to visible, so draw LEFT quad.
						add_quad(surface_tool, create_left_quad(x, y, front, back), uv)
						is_visible = true
				else:
					if is_visible:
						# Changed from visible to invisible, so draw RIGHT quad.
						add_quad(surface_tool, create_right_quad(x, y, front, back), uv)
						is_visible = false


	surface_tool.index() # Convert vertexes into unique vertices + indexes.
	var mesh = surface_tool.commit()
	if mesh.get_surface_count() == 1:
		assert mesh.surface_get_array_len(0) > 0
		assert mesh.surface_get_array_index_len(0) >= mesh.surface_get_array_len(0)
		print("num vertexes: ", mesh.surface_get_array_len(0))
		print("num indexes: ", mesh.surface_get_array_index_len(0))
		return mesh
	else:
		return null
    
    
func add_quad(surface_tool, vertices, uv):
	for vertex in vertices:
		surface_tool.add_normal(vertex[1])
		surface_tool.add_uv(uv)
		surface_tool.add_vertex(vertex[0] / 2)