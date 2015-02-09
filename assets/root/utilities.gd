extends Node


func load_json(name):
    var json = File.new()
    json.open("res://%s.json" % name, File.READ)

    var data = {}

    var err = data.parse_json(json.get_as_text())
    json.close()

    assert(err == OK)

    return data
