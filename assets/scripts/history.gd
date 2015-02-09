extends Node

class Action:
    func do_action():
        # Override please.

    func undo_action():
        # Override please.

var _actions = []
var _current = -1


var can_undo setget get_can_undo
func get_can_undo():
    return _current > -1


var can_redo setget get_can_redo
func get_can_redo():
    return _current < _actions.size() - 1


func add(action):
    if can_redo:
        _actions.resize(_current)

    _actions.append(action)
    _current += 1

    action.do_action()


func redo():
    assert(can_redo)

    _current += 1
    _actions[_current].do_action()


func undo():
    assert(can_undo)

    _actions[_current].undo_action()
    _current -= 1


func clear():
    _current = -1
    _actions.clear()