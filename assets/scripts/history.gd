extends Node

var logger
var _actions = []
var _current = -1

func _ready():
    logger = get_node("/root/logger")

func get_can_undo():
    return _current > -1

func get_can_redo():
    return _current < _actions.size() - 1


func add(action):
    if get_can_redo():
        _actions.resize(_current)
    _actions.append(action)
    _current += 1

    action.do_action()

func redo():
    assert(get_can_redo())

    _current += 1
    _actions[_current].do_action()


func undo():
    assert(get_can_undo())

    _actions[_current].undo_action()
    _current -= 1


func clear():
    _current = -1
    _actions.clear()