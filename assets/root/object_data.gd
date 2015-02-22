extends Node

var TILE_TYPES
var TILE_ORDER_IN_EDITOR
var ITEM_TYPES
var ITEM_ORDER_IN_EDITOR

class CollisionLayer:
    const TILES_PLAYER = 1
    const TILES_ITEMS = 2
    const ITEMS_PLAYER = 4
    const TILES_MOVING_ITEMS = 8
    const PLAYER_MOVING_ITEMS = 16

var logger
var utilities

class ObjectData:
    var types

    var grid setget , get_grid
    func get_grid():
        return grid

    var type setget set_type, get_type
    func get_type():
        return type
    func set_type(value):
        assert(type in types)
        type = value
        
    func _init(type, types, grid):
        self.types = types
        self.type = type
        self.grid = grid

    func _get(name):
        return types[type][name]

    func _get_property_list():
        var properties = []
        for name in types[type]:
            var value = types[type][name]
            properties.append({"name": name, "type": typeof(value) })

        return properties

    func to_data():
        return { "type": type }



func create_tile(type, grid):
    return ObjectData.new(type, TILE_TYPES, grid)

func create_item(type, grid):
    return ObjectData.new(type, ITEM_TYPES, grid)

func _ready():
    logger = get_node(@'/root/logger')
    utilities = get_node(@'/root/utilities')

    load_tile_data()
    load_item_data()

func load_tile_data():
    logger.info("Loading TileData config")

    var data = utilities.load_json("res://config/tiles.json")
    var default = data["default"]
    TILE_TYPES = data["types"]
    TILE_ORDER_IN_EDITOR = data["order_in_editor"]

    # Set default values in each type.
    for type in TILE_TYPES:
        for key in default:
            if not key in TILE_TYPES[type]:
                TILE_TYPES[type][key] = default[key]

        # Convert colour array into something sensible.
        var channels = TILE_TYPES[type]["footprints_color"]
        TILE_TYPES[type]["footprints_color"] = Color(channels[0] * 255, channels[1] * 255, channels[2] * 255, channels[3] * 255)

        var push_speed = TILE_TYPES[type]["push_speed"]
        TILE_TYPES[type]["push_speed"] = Vector3(push_speed[0], push_speed[1], push_speed[2])

func load_item_data():
    var logger = get_node(@'/root/logger')
    var utilities = get_node(@'/root/utilities')

    logger.info("Loading ItemData config")

    var data = utilities.load_json("res://config/items.json")
    var default = data["default"]
    ITEM_TYPES = data["types"]
    ITEM_ORDER_IN_EDITOR = data["order_in_editor"]

    # Set default values in each type.
    for type in ITEM_TYPES:
        for key in default:
            if not key in ITEM_TYPES[type]:
                ITEM_TYPES[type][key] = default[key]

        var safe_frames = []
        for frame in ITEM_TYPES[type]["safe_frames"]:
            safe_frames.append(int(frame))
        ITEM_TYPES[type]["safe_frames"] = safe_frames

        var vel = ITEM_TYPES[type]["initial_velocity"]
        ITEM_TYPES[type]["initial_velocity"] = Vector3(vel[0], vel[1], vel[2])