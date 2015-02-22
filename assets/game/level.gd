extends Spatial

var SCALE

# Stored data.
var floor_tiles = []
var wall_tiles = []
var items = {} # grid => item-data
var name = "MyLevel"

var filename = "res://levels/level0.json"
var logger
var mesh_manager
var object_data
var utilities
var item_objects = {} # grid => item nodes
var floor_tile_objects = {}
var wall_tile_objects = {}
var is_editor

func _ready():
    logger = get_node(@'/root/logger')
    mesh_manager = get_node(@'/root/mesh_manager')
    object_data = get_node(@'/root/object_data')
    utilities = get_node(@'/root/utilities')
    SCALE = 8 * mesh_manager.PIXEL_SIZE

func setup(is_editor):
    self.is_editor = is_editor
    if File.new().file_exists(filename):
        restore()
    else:
        create()
        save()

    yield()

    generate_tiles()
    # yield()
    generate_items()

func restore():
    logger.info("Loading level")

    var data = utilities.load_json(filename)
    name = data["name"]

    var x = 0
    for tile_row in data["floor_tiles"]:
        var y = 0
        var row = []
        for tile_hash in tile_row:
            var tile = object_data.create_tile(tile_hash["type"], Vector2(x, y))
            row.append(tile)
            y += 1
        x += 1
        floor_tiles.append(row)

    var x = 0
    for tile_row in data["wall_tiles"]:
        var y = 0
        var row = []
        for tile_hash in tile_row:
            var tile = object_data.create_tile(tile_hash["type"], Vector2(x, y))
            row.append(tile)
            y += 1
        x += 1
        wall_tiles.append(row)

    for item_data in data["items"]:
        var grid = Vector2(item_data["grid"][0], item_data["grid"][1])
        var item = object_data.create_item(item_data["data"]["type"], grid)
        items[grid] = item

func create():
    logger.info("Creating level")

    for x in range(50):
        var wall_row = []
        var floor_row = []
        for y in range(5):
            logger.info("Creating wall tile")
            # Wall
            var tile_info = object_data.create_tile("BLUE_TILE", Vector2(x, y))
            wall_row.append(tile_info)
            logger.info("Creating floor tile")
            # Floor
            tile_info = object_data.create_tile("WHITE_TILE", Vector2(x, y))
            floor_row.append(tile_info)

        wall_tiles.append(wall_row)
        floor_tiles.append(floor_row)

    logger.info("Created level")

func generate_tiles():
    var i = 0
    for tile_row in wall_tiles:
        var j = 0
        for tile_data in tile_row:
            create_wall_tile(tile_data, i, j)
            j += 1
        i += 1
   
    var i = 0
    for tile_row in floor_tiles:
        var j = 0
        for tile_data in tile_row:
            create_floor_tile(tile_data, i, j)
            j += 1
        i += 1

func create_wall_tile(tile_data, i, j):
    var tile = mesh_manager.new_mesh_object("tile", is_editor)
    tile.data = tile_data
    tile.set_translation(Vector3(i * SCALE, (j + 1) * SCALE, 0))
    tile.is_floor = false
    add_child(tile)
    wall_tile_objects[tile_data.grid] = tile

func create_floor_tile(tile_data, i, j):
    var tile = mesh_manager.new_mesh_object("tile", is_editor)
    tile.data = tile_data
    tile.set_rotation(Vector3(-PI / 2, 0, 0))
    tile.set_translation(Vector3(i * SCALE, 0, j * SCALE))
    tile.is_floor = true
    add_child(tile)
    floor_tile_objects[tile_data.grid] = tile

func generate_items():
    for grid in items:
        var item_data = items[grid]
        create_item_object(item_data, grid)

func create_item_object(item_data, grid):
    var item = mesh_manager.new_mesh_object(item_data.type, is_editor)
    item.data = item_data

    item.set_translation(grid_to_world(grid))
    item_objects[grid] = item

    add_child(item)

    if not is_editor and item.initial_velocity.length() > 0.1:
        item.set_velocity(item.initial_velocity)

func grid_to_world(grid):
    return Vector3(grid.x + 0.5, 0, grid.y + 0.5)

func save():
    logger.info("Saving level: %s" % name)

    var data = { "name": name,  "floor_tiles": [], "wall_tiles": [], "items": [] }

    for floor_row in floor_tiles:
        var row = []
        for floor_tile in floor_row:
            row.append(floor_tile.to_data())
        data["floor_tiles"].append(row)

    for wall_row in wall_tiles:
        var row = []
        for wall_tile in wall_row:
            row.append(wall_tile.to_data())
        data["wall_tiles"].append(row)

    for grid in items:
        var item = items[grid]
        data["items"].append({"grid": [grid.x, grid.y], "data": item.to_data()})

    get_node(@'/root/utilities').save_json(filename, data)

func get_length():
    return wall_tiles.size()

# -- Editor manipulation...

func add_item(grid, item_type):
    logger.debug("Added %s at %s" % [item_type, var2str(grid)])

    assert(not grid in items)

    var item_data = object_data.create_item(item_type, grid)
    items[grid] = item_data
    create_item_object(item_data, grid)
    
func remove_item(grid):
    assert(grid in items)

    logger.debug("Removed %s at %s" % [items[grid].type, var2str(grid)])
    var item = item_objects[grid]
    items.erase(grid)
    item_objects.erase(grid)
    item.queue_free()

func get_item_at(grid):
    if grid in item_objects:
        return items[grid]
    else:
        return null

func get_floor_tile_at(grid):
    return floor_tile_objects[grid]

func get_wall_tile_at(grid):
    return wall_tile_objects[grid]

func change_wall_tile(type, grid):
    var tile = wall_tile_objects[grid]
    wall_tile_objects.erase(tile)
    tile.queue_free()

    var tile_data = object_data.create_tile(type, grid)
    wall_tiles[grid.x][grid.y] = tile_data
    create_wall_tile(tile_data, grid.x, grid.y)

func change_floor_tile(type, grid):
    var tile = floor_tile_objects[grid]
    floor_tile_objects.erase(tile)
    tile.queue_free()

    var tile_data = object_data.create_tile(type, grid)
    floor_tiles[grid.x][grid.y] = tile_data
    create_floor_tile(tile_data, grid.x, grid.y)
