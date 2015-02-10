extends Node

const LEVEL_DEBUG = 0
const LEVEL_INFO = 1
const LEVEL_WARNING = 2
const LEVEL_ERROR = 3
const LEVEL_CRITICAL = 4

var level = LEVEL_DEBUG

var _file

func _ready():
    _file = File.new()
    _file.open("res://log.txt", File.WRITE)

func debug(text):
    if level <= LEVEL_DEBUG:
        _write("DEBUG", text)

func info(text):
    if level <= LEVEL_INFO:
        _write("INFO", text)
  
func warning(text):
    if level <= LEVEL_WARNING:
        _write("WARN", text)

func error(text):
    if level <= LEVEL_ERROR:
        _write("ERROR", text)

func critical(text):
    if level <= LEVEL_ERROR:
        _write("CRIT", text)

func _write(type, text):
    var message = "%-5s %s" % [type + ":", text]
    print(message)
    _file.store_line(message)