extends Spatial

var floor_tiles = []
var wall_tiles = []
var name = "MyLevel"
var filename = "res://levels/level0.json"
var logger
var player


func _ready():
    logger = get_node("/root/logger")

    if File.new().file_exists(filename):
        restore()
    else:
        create()
        save()

    generate_tiles()
    create_player(Vector2(4, 3))

    for i in range(3):
        create_flytrap_swallower(Vector2(i, i % 2))

    create_flytrap_sleeper(Vector2(8, 4))


func create_player(grid):
    var mesh_manager = get_node("/root/mesh_manager")
    player = mesh_manager.new_mesh_object("player")
    add_child(player)

    player.set_translation(grid_to_world(grid) + Vector3(0, 0, 0))


func restore():
    logger.info("Loading level")

    var tile_data = get_node("/root/tile_data")

    var data = get_node("/root/utilities").load_json(filename)
    name = data["name"]

    for tile_hash in data["floor_tiles"]:
       var tile = tile_data.create(tile_hash["type"], Vector2(tile_hash["grid"][0], tile_hash["grid"][1]))
       floor_tiles.append(tile)

    for tile_hash in data["wall_tiles"]:
       var tile = tile_data.create(tile_hash["type"], Vector2(tile_hash["grid"][0], tile_hash["grid"][1]))
       wall_tiles.append(tile)


func create():
    logger.info("Creating level")

    var tile_data = get_node("/root/tile_data")

    for x in range(20):
        for y in range(5):
            # Wall
            var tile_info = tile_data.create("BLUE_TILE", Vector2(x, y))
            wall_tiles.append(tile_info)

            # Floor
            tile_info = tile_data.create("WHITE_TILE", Vector2(x, y))
            floor_tiles.append(tile_info)


func generate_tiles():
    var mesh_manager = get_node("/root/mesh_manager")
    var scale = 8 * mesh_manager.PIXEL_SIZE

    for wall_tile in wall_tiles:
        var tile = mesh_manager.new_mesh_object("tile")
        tile.get_node("MeshInstance").animation = wall_tile.type
        tile.set_translation(Vector3(wall_tile.grid.x * scale, wall_tile.grid.y * scale, 0))
        add_child(tile)
   
    for floor_tile in floor_tiles:
        var tile = mesh_manager.new_mesh_object("tile")
        tile.get_node("MeshInstance").animation = floor_tile.type
        tile.set_translation(Vector3(floor_tile.grid.x * scale, 0, floor_tile.grid.y * scale))
        var rotation = tile.get_rotation()
        rotation.x -= PI / 2
        tile.set_rotation(rotation)
        add_child(tile)


func create_flytrap_swallower(grid):
    var mesh_manager = get_node("/root/mesh_manager")
    var flytrap = mesh_manager.new_mesh_object("flytrap")
    add_child(flytrap)

    flytrap.get_node("MeshInstance").animation = "swallowing"

    flytrap.set_translation(grid_to_world(grid))


func create_flytrap_sleeper(grid):
    var mesh_manager = get_node("/root/mesh_manager")
    var flytrap = mesh_manager.new_mesh_object("flytrap")
    flytrap.player_kill_type = player.State.DEAD
    add_child(flytrap)

    flytrap.get_node("MeshInstance").animation = "inactive"

    flytrap.set_translation(grid_to_world(grid))
    var rotation = flytrap.get_rotation()
    rotation.x -= PI / 2
    flytrap.set_rotation(rotation)
    add_child(flytrap)


func grid_to_world(grid):
    return Vector3(grid.x + 0.5, 0, grid.y + 0.5)


func save():
    logger.info("Saving level: %s" % name)

    var data = { "name": name,  "floor_tiles": [], "wall_tiles": [] }

    for floor_tile in floor_tiles:
        data["floor_tiles"].append(floor_tile.to_data())

    for wall_tile in wall_tiles:
        data["wall_tiles"].append(wall_tile.to_data())

    get_node("/root/utilities").save_json(filename, data)
    