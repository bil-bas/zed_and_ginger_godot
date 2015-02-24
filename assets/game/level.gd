extends Spatial

const FLOOR_SIZE = 5
var SCALE


# Stored data.
var tiles = []
var items = {} # grid => item-data
var name = "MyLevel"

var filename = "res://levels/level0.json"
var logger
var mesh_manager
var object_data
var utilities
var item_objects = {} # grid => item nodes
var tile_objects = {}
var is_editor
var tile_nodes
var item_nodes

func _ready():
    logger = get_node(@'/root/logger')
    mesh_manager = get_node(@'/root/mesh_manager')
    object_data = get_node(@'/root/object_data')
    utilities = get_node(@'/root/utilities')
    tile_nodes = get_node(@'Tiles')
    item_nodes = get_node(@'Items')

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
    for tile_row in data["tiles"]:
        var y = 0
        var row = []
        for tile_hash in tile_row:
            var tile = object_data.create_tile(tile_hash["type"], Vector2(x, y))
            row.append(tile)
            y += 1
        x += 1
        tiles.append(row)

    for item_data in data["items"]:
        var grid = Vector2(item_data["grid"][0], item_data["grid"][1])
        var item = object_data.create_item(item_data["data"]["type"], grid)
        items[grid] = item

func create():
    logger.info("Creating level")

    for x in range(50):
        var row = []
        for y in range(FLOOR_SIZE * 2):
            var tile_info
            if y < FLOOR_SIZE:
                tile_info = object_data.create_tile("WHITE_TILE", Vector2(x, y))
                row.append(tile_info)
            else:
                tile_info = object_data.create_tile("BLUE_TILE", Vector2(x, y))
                row.append(tile_info)
            
        tiles.append(row)

    logger.info("Created level")

func generate_tiles():
    var i = 0
    for tile_row in tiles:
        var j = 0
        for tile_data in tile_row:
            create_tile(tile_data, i, j)
            j += 1
        i += 1
   
func create_tile(tile_data, i, j):
    var tile = mesh_manager.new_mesh_object("tile", is_editor)
    tile.data = tile_data

    if j < FLOOR_SIZE:
        tile.set_rotation(Vector3(-PI / 2, 0, 0))
        tile.set_translation(Vector3(i * SCALE, 0, j * SCALE))
    else:
        tile.set_translation(Vector3(i * SCALE, (j - FLOOR_SIZE + 1) * SCALE, 0))       

    tile_nodes.add_child(tile)
    tile_objects[tile_data.grid] = tile

func generate_items():
    for grid in items:
        var item_data = items[grid]
        create_item_object(item_data, grid)

func create_item_object(item_data, grid):
    var item = mesh_manager.new_mesh_object(item_data.type, is_editor)
    item.data = item_data

    item.set_translation(grid_to_world(grid))

    item_objects[grid] = item

    item_nodes.add_child(item)

    if item.grid.y >= FLOOR_SIZE:
        item.set_rotation(item.get_rotation() + Vector3(PI / 2, 0, 0))

    if not is_editor and item.initial_velocity.length() > 0.1:
        item.set_velocity(item.initial_velocity)

func grid_to_world(grid):
    if grid.y < FLOOR_SIZE:
        return Vector3(grid.x + 0.5, 0, grid.y + 0.5)
    else:
        return Vector3(grid.x + 0.5, (grid.y - FLOOR_SIZE) + 0.5, 0.5)

func save():
    logger.info("Saving level: %s" % name)

    var data = { "name": name,  "tiles": [], "items": [] }

    for tile_row in tiles:
        var row = []
        for tile in tile_row:
            row.append(tile.to_data())
        data["tiles"].append(row)

    for grid in items:
        var item = items[grid]
        data["items"].append({"grid": [grid.x, grid.y], "data": item.to_data()})

    get_node(@'/root/utilities').save_json(filename, data)

func get_length():
    return tiles.size()

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

func get_tile_at(grid):
    return tile_objects[grid]

func change_tile(type, grid):
    var tile = tile_objects[grid]
    tile_objects.erase(tile)
    tile.queue_free()

    var tile_data = object_data.create_tile(type, grid)
    tiles[grid.x][grid.y] = tile_data
    create_tile(tile_data, grid.x, grid.y)
