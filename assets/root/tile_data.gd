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
       
    func type_index():
        return types[type]["index"]

    func uses_transparency():
        return types[type]["uses_transparency"]

    func depth():
        return types[type]["depth"]

    func speed_multiplier():
        return types[type]["speed_multiplier"]

    func is_sticky():
        return types[type]["is_sticky"]

    func creates_footprints():
        return footprints_color() != null

    func footprints_color():
        return types[type]["footprints_color"]


func create(type, grid):
    return Tile.new(type, grid, TYPES)


func get_config_from_index(index, key):
    if not index in INDEX_TO_NAME:
       index = 0
    var type = TYPES[INDEX_TO_NAME[index]]
    return type[key]


func _ready():
    var logger = get_node("/root/logger")
    logger.info("Loading TileData config")

    TYPES = get_node("/root/utilities").load_json("config/tiles")

    var default = TYPES["_default"]

    TYPES.erase("_default")

    # Set default values in each type.
    for type in TYPES:
        for key in default:
            if not key in TYPES[type]:
                TYPES[type][key] = default[key]

        var footprints = TYPES[type]["footprints_color"]
        if footprints != null:
            TYPES[type]["footprints_color"] = Color(footprints[0], footprints[1], footprints[2])

    # Fill dict for reverse lookup.
    for type in TYPES:
        INDEX_TO_NAME[int(TYPES[type]["index"])] = type
