extends Node


#const DEPTH = 2.5
var TYPES
var INDEX_TO_NAME = {}


class Tile:
    var types

    var grid setget , get_grid
    func get_grid():
        return grid

    var type setget set_type, get_type
    func get_type():
        return type
    func set_type(value):
        if not type in types:
            value = "GOO"
        type = value
        
    func _init(type, grid, types):
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
        return { "type": type, "grid": [grid.x, grid.y] }


func create(type, grid):
    return Tile.new(type, grid, TYPES)
    

func get_config_from_index(index, key):
    if not index in INDEX_TO_NAME:
       index = 0

    var type = TYPES[INDEX_TO_NAME[int(index)]]
    return type[key]


func _ready():
    var logger = get_node("/root/logger")
    var utilities = get_node("/root/utilities")

    logger.info("Loading TileData config")

    TYPES = utilities.load_json("res://config/tiles.json")

    var default = TYPES["_default"]

    TYPES.erase("_default")

    # Set default values in each type.
    for type in TYPES:
        for key in default:
            if not key in TYPES[type]:
                TYPES[type][key] = default[key]

        # Convert colour array into something sensible.
        var channels = TYPES[type]["footprints_color"]
        TYPES[type]["footprints_color"] = Color(channels[0] * 255, channels[1] * 255, channels[2] * 255, channels[3] * 255)

    # Fill dict for reverse lookup.
    var animations = utilities.load_json("res://atlases/tile.json")["animations"]
    for type in animations:
        var frame = animations[type][0]
        INDEX_TO_NAME[int(frame["tile"])] = type
